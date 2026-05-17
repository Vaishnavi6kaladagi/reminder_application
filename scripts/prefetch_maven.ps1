param([string[]]$Coords)

function Get-Artifact($coord) {
    $parts = $coord -split ':'
    $g, $a, $v = $parts[0], $parts[1], $parts[2]
    $gp = $g.Replace('.', '/')
    $repo = if ($g -match '^(androidx|com\.android|com\.google\.android)') { "google" } else { "central" }
    $base = if ($repo -eq "google") { "https://dl.google.com/dl/android/maven2/$gp/$a/$v" } else { "https://repo.maven.apache.org/maven2/$gp/$a/$v" }
    $dir = "$env:USERPROFILE\.m2\repository\$gp\$a\$v"
    New-Item -Force -ItemType Directory -Path $dir | Out-Null
    foreach ($ext in @("pom", "jar", "aar")) {
        $out = "$dir\$a-$v.$ext"
        if (-not (Test-Path $out) -or (Get-Item $out -ErrorAction SilentlyContinue).Length -lt 500) {
            curl.exe --ssl-no-revoke -fSL -o $out "$base/$a-$v.$ext" 2>$null
        }
    }
    Write-Host "Cached $coord"
}

if ($Coords.Count -eq 0) {
    $Coords = @(
        "androidx.core:core:1.13.1",
        "androidx.core:core:1.3.0",
        "androidx.media:media:1.1.0",
        "com.google.code.gson:gson:2.12.0",
        "androidx.datastore:datastore:1.1.7",
        "androidx.datastore:datastore-preferences:1.1.7",
        "androidx.preference:preference:1.2.1",
        "androidx.annotation:annotation:1.8.0",
        "androidx.lifecycle:lifecycle-runtime:2.7.0",
        "androidx.window:window:1.2.0",
        "androidx.fragment:fragment:1.7.1",
        "androidx.activity:activity:1.8.1"
    )
}
foreach ($c in $Coords) { Get-Artifact $c }
