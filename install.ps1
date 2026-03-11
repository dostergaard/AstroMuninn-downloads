param(
    [string]$Version,
    [string]$InstallDir = "$env:LOCALAPPDATA\RavenSky\AstroMuninn\bin",
    [switch]$NoPathUpdate,
    [switch]$Uninstall
)

$ErrorActionPreference = "Stop"

$AppName = "AstroMuninn"
$ExeName = "astromuninn.exe"
$DownloadsRepo = "dostergaard/AstroMuninn-downloads"
$MetadataDir = "$env:LOCALAPPDATA\RavenSky\AstroMuninn"

function Fail([string]$Message) {
    throw $Message
}

function Get-LatestVersion {
    $release = Invoke-RestMethod -Uri "https://api.github.com/repos/$DownloadsRepo/releases/latest" -Headers @{ "User-Agent" = $AppName }
    if (-not $release.tag_name) {
        Fail "Unable to resolve the latest release from $DownloadsRepo."
    }
    return $release.tag_name
}

function Normalize-Version([string]$RequestedVersion) {
    if ([string]::IsNullOrWhiteSpace($RequestedVersion)) {
        return Get-LatestVersion
    }

    if ($RequestedVersion.StartsWith("v")) {
        return $RequestedVersion
    }

    return "v$RequestedVersion"
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
        "x86_64" { return "$AppName-$ResolvedVersion-windows-x86_64.zip" }
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

function Ensure-PathEntry([string]$Dir) {
    $currentUserPath = [Environment]::GetEnvironmentVariable("Path", "User")
    $entries = @()
    if (-not [string]::IsNullOrWhiteSpace($currentUserPath)) {
        $entries = $currentUserPath.Split(';', [System.StringSplitOptions]::RemoveEmptyEntries)
    }

    if ($entries -contains $Dir) {
        return
    }

    if ($NoPathUpdate) {
        Write-Host "$Dir is not on PATH. Add it manually before running $ExeName."
        return
    }

    $newEntries = @($entries + $Dir) | Select-Object -Unique
    $newPath = ($newEntries -join ';')
    [Environment]::SetEnvironmentVariable("Path", $newPath, "User")
    $env:Path = $newPath + ";" + [Environment]::GetEnvironmentVariable("Path", "Machine")
    Write-Host "Updated the user PATH to include $Dir."
}

function Remove-PathEntry([string]$Dir) {
    $currentUserPath = [Environment]::GetEnvironmentVariable("Path", "User")
    if ([string]::IsNullOrWhiteSpace($currentUserPath)) {
        return
    }

    $newEntries = $currentUserPath.Split(';', [System.StringSplitOptions]::RemoveEmptyEntries) | Where-Object { $_ -ne $Dir }
    [Environment]::SetEnvironmentVariable("Path", ($newEntries -join ';'), "User")
}

if ($Uninstall) {
    $target = Join-Path $InstallDir $ExeName
    if (Test-Path $target) {
        Remove-Item -Force $target
    }
    if (Test-Path $MetadataDir) {
        Remove-Item -Recurse -Force $MetadataDir
    }
    Remove-PathEntry -Dir $InstallDir
    Write-Host "Removed $AppName from $target"
    exit 0
}

$ResolvedVersion = Normalize-Version -RequestedVersion $Version
$AssetName = Get-AssetName -ResolvedVersion $ResolvedVersion
$ReleaseBase = "https://github.com/$DownloadsRepo/releases/download/$ResolvedVersion"
$ArchiveUrl = "$ReleaseBase/$AssetName"
$ChecksumUrl = "$ReleaseBase/SHA256SUMS.txt"

$TempDir = Join-Path ([System.IO.Path]::GetTempPath()) ("astromuninn-install-" + [System.Guid]::NewGuid())
$ArchivePath = Join-Path $TempDir $AssetName
$ChecksumPath = Join-Path $TempDir "SHA256SUMS.txt"
$ExtractDir = Join-Path $TempDir "extract"

New-Item -ItemType Directory -Force -Path $TempDir, $ExtractDir, $InstallDir, $MetadataDir | Out-Null

try {
    Write-Host "Downloading $AppName $ResolvedVersion"
    Invoke-WebRequest -Uri $ChecksumUrl -OutFile $ChecksumPath -Headers @{ "User-Agent" = $AppName }
    Invoke-WebRequest -Uri $ArchiveUrl -OutFile $ArchivePath -Headers @{ "User-Agent" = $AppName }

    if (Get-Command Unblock-File -ErrorAction SilentlyContinue) {
        Unblock-File -Path $ArchivePath -ErrorAction SilentlyContinue
    }

    $ExpectedSha = Get-ExpectedSha -ChecksumFile $ChecksumPath -AssetName $AssetName
    $ActualSha = (Get-FileHash -Path $ArchivePath -Algorithm SHA256).Hash.ToLowerInvariant()
    if ($ExpectedSha.ToLowerInvariant() -ne $ActualSha) {
        Fail "SHA256 mismatch for $AssetName."
    }

    Expand-Archive -Path $ArchivePath -DestinationPath $ExtractDir -Force
    $Binary = Get-ChildItem -Path $ExtractDir -Recurse -Filter $ExeName | Select-Object -First 1
    if (-not $Binary) {
        Fail "Unable to locate $ExeName after extracting $AssetName."
    }

    $Target = Join-Path $InstallDir $ExeName
    Copy-Item -Path $Binary.FullName -Destination $Target -Force

    if (Get-Command Unblock-File -ErrorAction SilentlyContinue) {
        Unblock-File -Path $Target -ErrorAction SilentlyContinue
    }

    Set-Content -Path (Join-Path $MetadataDir "install-info.txt") -Value @(
        "version=$ResolvedVersion"
        "installed_at=$(Get-Date -Format o)"
        "install_dir=$InstallDir"
        "downloads_repo=$DownloadsRepo"
    )

    Ensure-PathEntry -Dir $InstallDir

    Write-Host "$AppName installed to $Target"
    Write-Host "Run `"$ExeName --help`" in a new PowerShell session to verify the install."
}
finally {
    if (Test-Path $TempDir) {
        Remove-Item -Recurse -Force $TempDir
    }
}
