$env:SHOPIFY_CLI_AGENT_INFO="n:opencode|v:0.1.0|p:none|m:mimo-v2.5-free"
$env:SHOPIFY_CLI_AGENT_IDS="s:none|r:none|i:none"

$ids = @(
  "gid://shopify/Product/10317017678137",
  "gid://shopify/Product/10317018038585",
  "gid://shopify/Product/10317018431801",
  "gid://shopify/Product/10317018923321",
  "gid://shopify/Product/10317019251001",
  "gid://shopify/Product/10317019611449",
  "gid://shopify/Product/10317019939129",
  "gid://shopify/Product/10317020299577",
  "gid://shopify/Product/10317020594489",
  "gid://shopify/Product/10317020922169",
  "gid://shopify/Product/10317021282617",
  "gid://shopify/Product/10317022069049",
  "gid://shopify/Product/10317023150393",
  "gid://shopify/Product/10317024100665",
  "gid://shopify/Product/10317024854329"
)

$count = 0
foreach ($id in $ids) {
  $queryContent = @"
mutation { productPublish(input: {id: "$id"}) { product { id title status publishedAt } userErrors { field message } } }
"@
  $tempFile = [System.IO.Path]::GetTempFileName()
  Set-Content -Path $tempFile -Value $queryContent -NoNewline
  $result = shopify store execute --store nfkeu1-jx.myshopify.com --query-file $tempFile --allow-mutations 2>&1
  Remove-Item $tempFile -ErrorAction SilentlyContinue

  if ($result -match "productPublish") {
    $count++
    Write-Host "OK $count/15"
  } else {
    Write-Host "FAIL - $id"
    Write-Host $result
  }
}

Write-Host "`nPublicados: $count/15"
