$env:SHOPIFY_CLI_AGENT_INFO="n:opencode|v:0.1.0|p:none|m:mimo-v2.5-free"
$env:SHOPIFY_CLI_AGENT_IDS="s:none|r:none|i:none"

# Delete all existing products
$deleteIds = @(
  "gid://shopify/Product/10317019611449",
  "gid://shopify/Product/10317019939129",
  "gid://shopify/Product/10317020299577",
  "gid://shopify/Product/10317020594489",
  "gid://shopify/Product/10317020922169",
  "gid://shopify/Product/10317021282617",
  "gid://shopify/Product/10317022069049",
  "gid://shopify/Product/10317023150393",
  "gid://shopify/Product/10317024100665",
  "gid://shopify/Product/10317024854329",
  "gid://shopify/Product/10317065781561"
)

$deleted = 0
foreach ($id in $deleteIds) {
  $q = 'mutation { productDelete(input: {id: "' + $id + '"}) { deletedProductId userErrors { field message } } }'
  $f = [System.IO.Path]::GetTempFileName()
  Set-Content -Path $f -Value $q -NoNewline
  $r = shopify store execute --store nfkeu1-jx.myshopify.com --query-file $f --allow-mutations 2>&1
  Remove-Item $f -ErrorAction SilentlyContinue
  if ($r -match "deletedProductId") { $deleted++ }
}
Write-Host "Eliminados: $deleted"
