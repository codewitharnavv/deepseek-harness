$ErrorActionPreference = 'Stop'
$target = 'http://127.0.0.1:5000/'
$nuclei = Join-Path $env:LOCALAPPDATA 'Programs\Nuclei\nuclei.exe'

if (-not (Test-Path -LiteralPath $nuclei)) {
    throw 'Nuclei is not installed. Run Install-Nuclei.ps1 first.'
}

$status = & curl.exe --silent --show-error --max-time 8 --max-redirs 0 --output NUL --write-out '%{http_code}' $target
if ($LASTEXITCODE -ne 0 -or $status -notmatch '^[1-5][0-9][0-9]$') {
    throw 'The local test app is not responding at http://127.0.0.1:5000. Start it, then run this script again.'
}

Write-Host "Scanning only $target (HTTP $status); redirects and OAST templates are disabled."
& $nuclei -u $target -rate-limit 5 -concurrency 5 -no-interactsh -disable-redirects -disable-update-check
exit $LASTEXITCODE
