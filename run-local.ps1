$ErrorActionPreference = 'Stop'
$repoRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$workspaceEnv = Join-Path (Split-Path -Parent $repoRoot) '.env'

if (-not (Test-Path -LiteralPath $workspaceEnv)) {
    throw "Missing workspace .env file: $workspaceEnv"
}

$required = @('ABLITERATION_API_KEY', 'FIRECRAWL_API_KEY')
$envValues = @{}
foreach ($line in Get-Content -LiteralPath $workspaceEnv) {
    if ($line -match '^\s*([A-Za-z_][A-Za-z0-9_]*)\s*=\s*(.*)\s*$') {
        $name = $Matches[1]
        if ($required -contains $name) {
            $value = $Matches[2].Trim()
            if (($value.StartsWith('"') -and $value.EndsWith('"')) -or ($value.StartsWith("'") -and $value.EndsWith("'"))) {
                $value = $value.Substring(1, $value.Length - 2)
            }
            if ($value.Length -gt 0) { $envValues[$name] = $value }
        }
    }
}

foreach ($name in $required) {
    if (-not [Environment]::GetEnvironmentVariable($name, 'Process') -and -not $envValues.ContainsKey($name)) {
        throw "Missing required environment variable $name in the process or workspace .env file."
    }
}
foreach ($name in $required) {
    if ($envValues.ContainsKey($name)) { [Environment]::SetEnvironmentVariable($name, $envValues[$name], 'Process') }
}

$nucleiBin = Join-Path $env:LOCALAPPDATA 'Programs\Nuclei'
if (Test-Path -LiteralPath (Join-Path $nucleiBin 'nuclei.exe')) {
    $env:PATH = "$nucleiBin;$env:PATH"
}

Set-Location -LiteralPath $repoRoot
$pnpmCommand = Get-Command pnpm -ErrorAction SilentlyContinue
if ($pnpmCommand) {
    & $pnpmCommand.Source dsh web --patch .\local-setup.cordis.yml @args
} else {
    npx --yes pnpm@11.28.5 dsh web --patch .\local-setup.cordis.yml @args
}
exit $LASTEXITCODE
