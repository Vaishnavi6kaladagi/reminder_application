# Installs Android NDK for Flutter builds (fixes "NDK not configured" error).
# Run in PowerShell: .\scripts\install_ndk.ps1

$ErrorActionPreference = "Stop"
$sdk = "$env:LOCALAPPDATA\Android\Sdk"
$ndkVersion = "27.0.12077973"
$ndkPath = Join-Path $sdk "ndk\$ndkVersion"
$zipUrl = "https://dl.google.com/android/repository/android-ndk-r27-windows.zip"
$zipFile = Join-Path $env:TEMP "android-ndk-r27-windows.zip"

if (Test-Path (Join-Path $ndkPath "source.properties")) {
    Write-Host "NDK already installed at $ndkPath"
    exit 0
}

Write-Host "SDK folder: $sdk"
New-Item -ItemType Directory -Force -Path (Split-Path $ndkPath) | Out-Null

if (-not (Test-Path $zipFile) -or (Get-Item $zipFile).Length -lt 700000000) {
    Write-Host "Downloading NDK (~745 MB). This can take 10-20 minutes..."
    if (Get-Command curl.exe -ErrorAction SilentlyContinue) {
        curl.exe --ssl-no-revoke -L -o $zipFile $zipUrl
    } elseif (Get-Command Start-BitsTransfer -ErrorAction SilentlyContinue) {
        Start-BitsTransfer -Source $zipUrl -Destination $zipFile
    } else {
        Invoke-WebRequest -Uri $zipUrl -OutFile $zipFile -UseBasicParsing
    }
}

Write-Host "Extracting NDK..."
$extractRoot = Join-Path $env:TEMP "android-ndk-extract"
if (Test-Path $extractRoot) { Remove-Item $extractRoot -Recurse -Force }
New-Item -ItemType Directory -Force -Path $extractRoot | Out-Null
tar -xf $zipFile -C $extractRoot

$extracted = Get-ChildItem $extractRoot -Directory | Select-Object -First 1
if (-not $extracted) { throw "NDK zip extraction failed." }

if (Test-Path $ndkPath) { Remove-Item $ndkPath -Recurse -Force }
New-Item -ItemType Directory -Force -Path $ndkPath | Out-Null
Copy-Item -Path (Join-Path $extracted.FullName "*") -Destination $ndkPath -Recurse -Force

Write-Host "NDK installed at: $ndkPath"
Write-Host "Now run: flutter doctor --android-licenses"
Write-Host "Then:  flutter run"
