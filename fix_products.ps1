$env:SHOPIFY_CLI_AGENT_INFO="n:opencode|v:0.1.0|p:none|m:mimo-v2.5-free"
$env:SHOPIFY_CLI_AGENT_IDS="s:none|r:none|i:none"

$updates = @(
  @("gid://shopify/Product/10317080658233", "gid://shopify/ProductVariant/54358128558393", "69.99", "gid://shopify/Collection/532816429369"),
  @("gid://shopify/Product/10317081510201", "gid://shopify/ProductVariant/54358129574201", "79.99", "gid://shopify/Collection/532816429369"),
  @("gid://shopify/Product/10317082362169", "gid://shopify/ProductVariant/54358130852153", "49.99", "gid://shopify/Collection/532816429369"),
  @("gid://shopify/Product/10317083443513", "gid://shopify/ProductVariant/54358131933497", "69.99", "gid://shopify/Collection/532816429369"),
  @("gid://shopify/Product/10317084393785", "gid://shopify/ProductVariant/54358133539129", "59.99", "gid://shopify/Collection/532816429369"),
  @("gid://shopify/Product/10317085344057", "gid://shopify/ProductVariant/54358134489401", "89.99", "gid://shopify/Collection/532816429369"),
  @("gid://shopify/Product/10317086261561", "gid://shopify/ProductVariant/54358135406905", "39.99", "gid://shopify/Collection/532816724281"),
  @("gid://shopify/Product/10317087080761", "gid://shopify/ProductVariant/54358136226105", "29.99", "gid://shopify/Collection/532816724281"),
  @("gid://shopify/Product/10317087899961", "gid://shopify/ProductVariant/54358137504057", "34.99", "gid://shopify/Collection/532816724281"),
  @("gid://shopify/Product/10317088620857", "gid://shopify/ProductVariant/54358138224953", "49.99", "gid://shopify/Collection/532816724281"),
  @("gid://shopify/Product/10317089014073", "gid://shopify/ProductVariant/54358138618169", "19.99", "gid://shopify/Collection/532816724281"),
  @("gid://shopify/Product/10317089374521", "gid://shopify/ProductVariant/54358138978617", "39.99", "gid://shopify/Collection/532816560441"),
  @("gid://shopify/Product/10317089702201", "gid://shopify/ProductVariant/54358139306297", "34.99", "gid://shopify/Collection/532816560441"),
  @("gid://shopify/Product/10317090029881", "gid://shopify/ProductVariant/54358139633977", "29.99", "gid://shopify/Collection/532816560441"),
  @("gid://shopify/Product/10317090357561", "gid://shopify/ProductVariant/54358139961657", "44.99", "gid://shopify/Collection/532816658745")
)

$count = 0
foreach ($u in $updates) {
  $prodId = $u[0]
  $varId = $u[1]
  $price = $u[2]
  $collId = $u[3]
  
  # Set price
  $pq = 'mutation { productVariantsBulkUpdate(productId: "' + $prodId + '", variants: [{id: "' + $varId + '", price: "' + $price + '"}]) { product { id } userErrors { field message } } }'
  $pf = [System.IO.Path]::GetTempFileName()
  Set-Content -Path $pf -Value $pq -NoNewline
  shopify store execute --store nfkeu1-jx.myshopify.com --query-file $pf --allow-mutations 2>&1 | Out-Null
  Remove-Item $pf -ErrorAction SilentlyContinue
  
  # Publish to Online Store
  $pubq = 'mutation { productPublish(input: {id: "' + $prodId + '"}) { product { id } userErrors { field message } } }'
  $pubf = [System.IO.Path]::GetTempFileName()
  Set-Content -Path $pubf -Value $pubq -NoNewline
  shopify store execute --store nfkeu1-jx.myshopify.com --query-file $pubf --allow-mutations 2>&1 | Out-Null
  Remove-Item $pubf -ErrorAction SilentlyContinue
  
  # Add to collection
  $cq = 'mutation { collectionAddProducts(id: "' + $collId + '", productIds: ["' + $prodId + '"]) { collection { id } userErrors { field message } } }'
  $cf = [System.IO.Path]::GetTempFileName()
  Set-Content -Path $cf -Value $cq -NoNewline
  shopify store execute --store nfkeu1-jx.myshopify.com --query-file $cf --allow-mutations 2>&1 | Out-Null
  Remove-Item $cf -ErrorAction SilentlyContinue
  
  $count++
  Write-Host "OK $count/15 - price S/.$price"
}

Write-Host "`nDone: $count/15"
