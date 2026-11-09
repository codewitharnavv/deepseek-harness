$ErrorActionPreference = 'Stop'
$headers = @{ 'User-Agent' = 'DeepSeek-Harness-local-setup' }
$release = Invoke-RestMethod -Uri 'https://api.github.com/repos/projectdiscovery/nuclei/releases/latest' -Headers $headers
$assetName = "nuclei_$($release.tag_name.TrimStart('v'))_windows_amd64.zip"
$asset = $release.assets | Where-Object { $_.name -eq $assetName } | Select-Object -First 1
$checksumsAsset = $release.assets | Where-Object { $_.name -eq "nuclei_$($release.tag_name.TrimStart('v'))_checksums.txt" } | Select-Object -First 1
if (-not $asset -or -not $checksumsAsset) { throw "Could not find the Windows x64 binary and checksum for $($release.tag_name)." }

$tempRoot = Join-Path ([IO.Path]::GetTempPath()) ("nuclei-setup-" + [guid]::NewGuid().ToString('N'))
$null = New-Item -ItemType Directory -Path $tempRoot
$zipPath = Join-Path $tempRoot $assetName
$checksumsPath = Join-Path $tempRoot $checksumsAsset.name
Invoke-WebRequest -Uri $asset.browser_download_url -OutFile $zipPath -Headers $headers
Invoke-WebRequest -Uri $checksumsAsset.browser_download_url -OutFile $checksumsPath -Headers $headers
$checksumLine = (Select-String -LiteralPath $checksumsPath -Pattern ([regex]::Escape($assetName)) | Select-Object -First 1).Line
$expectedHash = ($checksumLine -split '\s+')[0]
if ($expectedHash -notmatch '^[a-fA-F0-9]{64}$') { throw 'Could not parse the official SHA-256 checksum.' }
$actualHash = (Get-FileHash -LiteralPath $zipPath -Algorithm SHA256).Hash
if ($actualHash -ne $expectedHash) { throw 'Nuclei archive SHA-256 does not match the official release checksum.' }

$installDir = Join-Path $env:LOCALAPPDATA 'Programs\Nuclei'
$null = New-Item -ItemType Directory -Path $installDir -Force
Expand-Archive -LiteralPath $zipPath -DestinationPath $tempRoot -Force
Copy-Item -LiteralPath (Join-Path $tempRoot 'nuclei.exe') -Destination (Join-Path $installDir 'nuclei.exe') -Force
$userPath = [Environment]::GetEnvironmentVariable('Path', 'User')
$pathEntries = if ($userPath) { @($userPath -split ';' | Where-Object { $_ }) } else { @() }
if (-not ($pathEntries | Where-Object { $_.TrimEnd('\') -ieq $installDir.TrimEnd('\') })) {
    [Environment]::SetEnvironmentVariable('Path', (($pathEntries + $installDir) -join ';'), 'User')
}
$env:PATH = "$installDir;$env:PATH"
& (Join-Path $installDir 'nuclei.exe') -version
