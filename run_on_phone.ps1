# Build and run Reminder App on your Android phone
Set-Location $PSScriptRoot

# Fix SSL for Gradle on this PC (run once)
$trustStore = "$env:USERPROFILE\.android\ssl\cacerts"
if (-not (Test-Path $trustStore)) {
    Write-Host "Setting up SSL trust store (one-time)..."
    $destDir = "$env:USERPROFILE\.android\ssl"
    New-Item -Force -ItemType Directory -Path $destDir | Out-Null
    Copy-Item "C:\Program Files\Android\Android Studio\jbr\lib\security\cacerts" $trustStore -Force
    $keytool = "C:\Program Files\Android\Android Studio\jbr\bin\keytool.exe"
    $certStore = New-Object System.Security.Cryptography.X509Certificates.X509Store("Root", "CurrentUser")
    $certStore.Open([System.Security.Cryptography.X509Certificates.OpenFlags]::ReadOnly)
    $n = 0
    foreach ($cert in $certStore.Certificates) {
        $n++
        $tmp = [System.IO.Path]::GetTempFileName()
        [System.IO.File]::WriteAllBytes($tmp, $cert.Export([System.Security.Cryptography.X509Certificates.X509ContentType]::Cert))
        & $keytool -importcert -noprompt -alias "winroot$n" -file $tmp -keystore $trustStore -storepass changeit 2>$null
        Remove-Item $tmp -Force
    }
    $certStore.Close()
}

Write-Host "Checking for phone..."
$devices = flutter devices 2>&1 | Out-String
if ($devices -notmatch "android-arm") {
    Write-Host ""
    Write-Host "No Android phone found. Please:"
    Write-Host "  1. Connect phone with USB cable"
    Write-Host "  2. Enable USB debugging (Developer options)"
    Write-Host "  3. Tap Allow on the phone"
    Write-Host ""
    flutter devices
    exit 1
}

Write-Host "Launching on your phone..."
flutter run
