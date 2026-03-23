param(
    [string]$Version,
    [string]$DownloadDir = "$env:TEMP\AstroMuninnLite",
    [switch]$DownloadOnly
)

$ErrorActionPreference = "Stop"

$AppName = "AstroMuninn Lite"
$DownloadsRepo = "dostergaard/AstroMuninn-downloads"
$LatestMetadataUrl = "https://raw.githubusercontent.com/dostergaard/AstroMuninn-downloads/main/lite/latest.json"

function Fail([string]$Message) {
    throw $Message
}

function Get-LatestVersion {
    $metadata = Invoke-RestMethod -Uri $LatestMetadataUrl -Headers @{ "User-Agent" = $AppName }
    if (-not $metadata.tag) {
        Fail "Unable to resolve the latest Lite release metadata from $LatestMetadataUrl."
    }
    return $metadata.tag
}

function Normalize-Version([string]$RequestedVersion) {
    if ([string]::IsNullOrWhiteSpace($RequestedVersion)) {
        return Get-LatestVersion
    }

    if ($RequestedVersion.StartsWith("lite-v")) {
        return $RequestedVersion
    }

    if ($RequestedVersion.StartsWith("v")) {
        return "lite-$RequestedVersion"
    }

    return "lite-v$RequestedVersion"
}

function Get-PublicVersionTag([string]$ReleaseTag) {
    if ($ReleaseTag.StartsWith("lite-v")) {
        return "v" + $ReleaseTag.Substring(6)
    }

    if ($ReleaseTag.StartsWith("v")) {
        return $ReleaseTag
    }

    Fail "Unsupported AstroMuninn Lite release tag: $ReleaseTag"
}

function Get-WindowsArchitecture {
    $candidates = @()

    try {
        $runtimeArch = [System.Runtime.InteropServices.RuntimeInformation]::OSArchitecture
        if ($null -ne $runtimeArch) {
            $runtimeArchText = $runtimeArch.ToString().Trim()
            if (-not [string]::IsNullOrWhiteSpace($runtimeArchText)) {
                $candidates += $runtimeArchText
            }
        }
    }
    catch {
    }

    foreach ($value in @($env:PROCESSOR_ARCHITEW6432, $env:PROCESSOR_ARCHITECTURE)) {
        if (-not [string]::IsNullOrWhiteSpace($value)) {
            $candidates += $value.Trim()
        }
    }

    foreach ($candidate in ($candidates | Select-Object -Unique)) {
        switch -Regex ($candidate.ToUpperInvariant()) {
            '^(X64|AMD64)$' { return 'x86_64' }
            '^ARM64$' { return 'arm64' }
        }
    }

    $detected = if ($candidates.Count -gt 0) {
        ($candidates | Select-Object -Unique) -join ', '
    }
    else {
        'unknown'
    }

    Fail "Unable to determine the Windows architecture for this machine. Detected values: $detected"
}

function Get-AssetName([string]$ResolvedVersion) {
    $arch = Get-WindowsArchitecture
    switch ($arch) {
        "x86_64" { return "AstroMuninn-Lite-$ResolvedVersion-windows-x86_64-setup.exe" }
        default { Fail "$AppName currently supports only Windows x86_64." }
    }
}

function Get-ExpectedSha([string]$ChecksumFile, [string]$AssetName) {
    $line = Get-Content -Path $ChecksumFile | Where-Object { $_ -match "\s$([regex]::Escape($AssetName))$" } | Select-Object -First 1
    if (-not $line) {
        Fail "Unable to find checksum entry for $AssetName."
    }
    return ($line -split '\s+')[0]
}

$ResolvedVersion = Normalize-Version -RequestedVersion $Version
$PublicVersionTag = Get-PublicVersionTag -ReleaseTag $ResolvedVersion
$AssetName = Get-AssetName -ResolvedVersion $PublicVersionTag
$ReleaseBase = "https://github.com/$DownloadsRepo/releases/download/$ResolvedVersion"
$InstallerUrl = "$ReleaseBase/$AssetName"
$ChecksumUrl = "$ReleaseBase/SHA256SUMS.txt"

New-Item -ItemType Directory -Force -Path $DownloadDir | Out-Null

$InstallerPath = Join-Path $DownloadDir $AssetName
$ChecksumPath = Join-Path $DownloadDir "SHA256SUMS.txt"

Write-Host "Downloading $AppName $ResolvedVersion"
Invoke-WebRequest -Uri $ChecksumUrl -OutFile $ChecksumPath -Headers @{ "User-Agent" = $AppName }
Invoke-WebRequest -Uri $InstallerUrl -OutFile $InstallerPath -Headers @{ "User-Agent" = $AppName }

if (Get-Command Unblock-File -ErrorAction SilentlyContinue) {
    Unblock-File -Path $InstallerPath -ErrorAction SilentlyContinue
}

$ExpectedSha = Get-ExpectedSha -ChecksumFile $ChecksumPath -AssetName $AssetName
$ActualSha = (Get-FileHash -Path $InstallerPath -Algorithm SHA256).Hash.ToLowerInvariant()
if ($ExpectedSha.ToLowerInvariant() -ne $ActualSha) {
    Fail "SHA256 mismatch for $AssetName."
}

if ($DownloadOnly) {
    Write-Host "$AppName downloaded to $InstallerPath"
    Write-Host "Launch the installer manually after reviewing the file."
    exit 0
}

Write-Host "Launching the $AppName installer..."
Start-Process -FilePath $InstallerPath -Wait
Write-Host "$AppName installer finished. If the app was installed successfully, it should now appear in the Start menu."
