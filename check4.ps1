$env:SHOPIFY_CLI_AGENT_INFO="n:opencode|v:0.1.0|p:none|m:mimo-v2.5-free"
$env:SHOPIFY_CLI_AGENT_IDS="s:none|r:none|i:none"

$queryContent = '{ product(id: "gid://shopify/Product/10317065781561") { id title status publishedAt } }'
$tempFile = [System.IO.Path]::GetTempFileName()
Set-Content -Path $tempFile -Value $queryContent -NoNewline
$result = shopify store execute --store nfkeu1-jx.myshopify.com --query-file $tempFile 2>&1
Remove-Item $tempFile -ErrorAction SilentlyContinue
Write-Output $result
