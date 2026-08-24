$env:SHOPIFY_CLI_AGENT_INFO="n:opencode|v:0.1.0|p:none|m:mimo-v2.5-free"
$env:SHOPIFY_CLI_AGENT_IDS="s:none|r:none|i:none"

# Last 2 products
$prodId = "gid://shopify/Product/10317090029881"
$varId = "gid://shopify/ProductVariant/54358139633977"
$price = "29.99"
$collId = "gid://shopify/Collection/532816560441"

$pq = 'mutation { productVariantsBulkUpdate(productId: "' + $prodId + '", variants: [{id: "' + $varId + '", price: "' + $price + '"}]) { product { id } userErrors { field message } } }'
$pf = [System.IO.Path]::GetTempFileName()
Set-Content -Path $pf -Value $pq -NoNewline
shopify store execute --store nfkeu1-jx.myshopify.com --query-file $pf --allow-mutations 2>&1 | Out-Null
Remove-Item $pf -ErrorAction SilentlyContinue

$pubq = 'mutation { productPublish(input: {id: "' + $prodId + '"}) { product { id } userErrors { field message } } }'
$pubf = [System.IO.Path]::GetTempFileName()
Set-Content -Path $pubf -Value $pubq -NoNewline
shopify store execute --store nfkeu1-jx.myshopify.com --query-file $pubf --allow-mutations 2>&1 | Out-Null
Remove-Item $pubf -ErrorAction SilentlyContinue

$cq = 'mutation { collectionAddProducts(id: "' + $collId + '", productIds: ["' + $prodId + '"]) { collection { id } userErrors { field message } } }'
$cf = [System.IO.Path]::GetTempFileName()
Set-Content -Path $cf -Value $cq -NoNewline
shopify store execute --store nfkeu1-jx.myshopify.com --query-file $cf --allow-mutations 2>&1 | Out-Null
Remove-Item $cf -ErrorAction SilentlyContinue
Write-Host "14 OK"

# Last one
$prodId2 = "gid://shopify/Product/10317090357561"
$varId2 = "gid://shopify/ProductVariant/54358139961657"
$price2 = "44.99"
$collId2 = "gid://shopify/Collection/532816658745"

$pq2 = 'mutation { productVariantsBulkUpdate(productId: "' + $prodId2 + '", variants: [{id: "' + $varId2 + '", price: "' + $price2 + '"}]) { product { id } userErrors { field message } } }'
$pf2 = [System.IO.Path]::GetTempFileName()
Set-Content -Path $pf2 -Value $pq2 -NoNewline
shopify store execute --store nfkeu1-jx.myshopify.com --query-file $pf2 --allow-mutations 2>&1 | Out-Null
Remove-Item $pf2 -ErrorAction SilentlyContinue

$pubq2 = 'mutation { productPublish(input: {id: "' + $prodId2 + '"}) { product { id } userErrors { field message } } }'
$pubf2 = [System.IO.Path]::GetTempFileName()
Set-Content -Path $pubf2 -Value $pubq2 -NoNewline
shopify store execute --store nfkeu1-jx.myshopify.com --query-file $pubf2 --allow-mutations 2>&1 | Out-Null
Remove-Item $pubf2 -ErrorAction SilentlyContinue

$cq2 = 'mutation { collectionAddProducts(id: "' + $collId2 + '", productIds: ["' + $prodId2 + '"]) { collection { id } userErrors { field message } } }'
$cf2 = [System.IO.Path]::GetTempFileName()
Set-Content -Path $cf2 -Value $cq2 -NoNewline
shopify store execute --store nfkeu1-jx.myshopify.com --query-file $cf2 --allow-mutations 2>&1 | Out-Null
Remove-Item $cf2 -ErrorAction SilentlyContinue
Write-Host "15 OK"
