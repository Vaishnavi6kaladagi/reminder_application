# Downloads Flutter engine Maven artifacts (fixes SSL errors during Gradle build).
$ver = "1.0.0-" + (Get-Content "C:\flutter\bin\internal\engine.version" -Raw).Trim()
$base = "https://storage.flutter-io.cn/download.flutter.io/io/flutter"
$artifacts = @(
    "flutter_embedding_debug",
    "arm64_v8a_debug",
    "armeabi_v7a_debug",
    "x86_64_debug"
)

foreach ($name in $artifacts) {
    $dir = "$env:USERPROFILE\.m2\repository\io\flutter\$name\$ver"
    New-Item -Force -ItemType Directory -Path $dir | Out-Null
    $url = "$base/$name/$ver"
    foreach ($ext in @("pom", "jar")) {
        $out = "$dir\$name-$ver.$ext"
        if (-not (Test-Path $out) -or (Get-Item $out).Length -lt 1000) {
            Write-Host "Downloading $name.$ext ..."
            curl.exe --ssl-no-revoke -fSL -o $out "$url/$name-$ver.$ext"
        }
    }
}
Write-Host "Flutter engine artifacts cached in mavenLocal."
