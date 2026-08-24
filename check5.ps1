$env:SHOPIFY_CLI_AGENT_INFO="n:opencode|v:0.1.0|p:none|m:mimo-v2.5-free"
$env:SHOPIFY_CLI_AGENT_IDS="s:none|r:none|i:none"

# Get all products with variants
$query = '{ products(first: 25) { edges { node { id title variants(first: 1) { edges { node { id price } } } } } } }'
$f = [System.IO.Path]::GetTempFileName()
Set-Content -Path $f -Value $query -NoNewline
$r = shopify store execute --store nfkeu1-jx.myshopify.com --query-file $f 2>&1
Remove-Item $f -ErrorAction SilentlyContinue

Write-Output $r
