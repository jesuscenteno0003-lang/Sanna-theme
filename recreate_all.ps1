$env:SHOPIFY_CLI_AGENT_INFO="n:opencode|v:0.1.0|p:none|m:mimo-v2.5-free"
$env:SHOPIFY_CLI_AGENT_IDS="s:none|r:none|i:none"

# Step 1: List all products
$query = '{ products(first: 50) { edges { node { id title } } } }'
$f = [System.IO.Path]::GetTempFileName()
Set-Content -Path $f -Value $query -NoNewline
$r = shopify store execute --store nfkeu1-jx.myshopify.com --query-file $f 2>&1
Remove-Item $f -ErrorAction SilentlyContinue

# Extract product IDs using regex
$ids = [regex]::Matches($r, '"id":\s*"(gid://shopify/Product/\d+)"') | ForEach-Object { $_.Groups[1].Value }

Write-Host "Found $($ids.Count) products to delete"

# Step 2: Delete each product
$deleted = 0
foreach ($id in $ids) {
  $dq = 'mutation { productDelete(input: {id: "' + $id + '"}) { deletedProductId userErrors { field message } } }'
  $df = [System.IO.Path]::GetTempFileName()
  Set-Content -Path $df -Value $dq -NoNewline
  $dr = shopify store execute --store nfkeu1-jx.myshopify.com --query-file $df --allow-mutations 2>&1
  Remove-Item $df -ErrorAction SilentlyContinue
  if ($dr -match "deletedProductId") { $deleted++; Write-Host "Deleted $deleted" }
}
Write-Host "Total deleted: $deleted"

# Step 3: Create products with productOptions (creates default variant)
$products = @(
  @("Sérum Coreano de Colágeno Silk", "Sérum", "skincare", "69.99"),
  @("Sérum de Retinol Coreano 1988", "Sérum", "skincare", "79.99"),
  @("Sérum de Ácido Hialurónico", "Sérum", "skincare", "49.99"),
  @("Sérum Vitamina C + Niacinamida", "Sérum", "skincare", "69.99"),
  @("Crema Facial de Colágeno Coreana", "Crema", "skincare", "59.99"),
  @("Sérum Coreano Anti-Edad", "Sérum", "skincare", "89.99"),
  @("Rodillo de Jade Rosa Natural", "Accesorio", "accesorios", "39.99"),
  @("Esponja de Maquillaje Beauty Blender", "Accesorio", "accesorios", "29.99"),
  @("Rodillo de Hielo Facial de Jade", "Accesorio", "accesorios", "34.99"),
  @("Set de Pinceles de Maquillaje", "Accesorio", "accesorios", "49.99"),
  @("Brocha para Delineador Gel", "Accesorio", "accesorios", "19.99"),
  @("Spray Fijador de Maquillaje", "Maquillaje", "maquillaje", "39.99"),
  @("Labial Líquido Matte Coreano", "Maquillaje", "maquillaje", "34.99"),
  @("Máscara de Pestañas Voluminizadora", "Maquillaje", "maquillaje", "29.99"),
  @("Aceite Capilar de Argán Premium", "Aceite Capilar", "cuidado-capilar", "44.99")
)

$created = 0
foreach ($p in $products) {
  $title = $p[0]
  $pType = $p[1]
  $coll = $p[2]
  $price = $p[3]
  
  $cq = 'mutation { productCreate(product: {title: "' + $title + '", vendor: "REPISA", productType: "' + $pType + '", tags: "' + $coll + '", status: ACTIVE, productOptions: [{name: "Default Title", values: [{name: "Default"}]}]}) { product { id title } userErrors { field message } } }'
  $cf = [System.IO.Path]::GetTempFileName()
  Set-Content -Path $cf -Value $cq -NoNewline
  $cr = shopify store execute --store nfkeu1-jx.myshopify.com --query-file $cf --allow-mutations 2>&1
  Remove-Item $cf -ErrorAction SilentlyContinue
  
  $match = [regex]::Match($cr, '"id":\s*"(gid://shopify/Product/\d+)"')
  if ($match.Success) {
    $pid = $match.Groups[1].Value
    $created++
    Write-Host "Created $created/15: $title ($pid)"
    
    # Get variant ID
    $vq = '{ product(id: "' + $pid + '") { variants(first: 1) { edges { node { id } } } } }'
    $vf = [System.IO.Path]::GetTempFileName()
    Set-Content -Path $vf -Value $vq -NoNewline
    $vr = shopify store execute --store nfkeu1-jx.myshopify.com --query-file $vf 2>&1
    Remove-Item $vf -ErrorAction SilentlyContinue
    
    $vmatch = [regex]::Match($vr, '"id":\s*"(gid://shopify/ProductVariant/\d+)"')
    if ($vmatch.Success) {
      $vid = $vmatch.Groups[1].Value
      # Update variant price
      $uq = 'mutation { productVariantsBulkUpdate(productId: "' + $pid + '", variants: [{id: "' + $vid + '", price: "' + $price + '"}]) { product { id } userErrors { field message } } }'
      $uf = [System.IO.Path]::GetTempFileName()
      Set-Content -Path $uf -Value $uq -NoNewline
      $ur = shopify store execute --store nfkeu1-jx.myshopify.com --query-file $uf --allow-mutations 2>&1
      Remove-Item $uf -ErrorAction SilentlyContinue
      if ($ur -match "productVariantsBulkUpdate") {
        Write-Host "  Price set: S/.$price"
      }
    }
  } else {
    Write-Host "FAILED: $title"
  }
}

Write-Host "`nCreated: $created/15"
