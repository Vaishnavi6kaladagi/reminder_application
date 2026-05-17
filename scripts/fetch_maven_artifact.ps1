param(
    [string]$GroupId,
    [string]$ArtifactId,
    [string]$Version,
    [string]$Repo = "google"
)

$groupPath = $GroupId.Replace('.', '/')
$dir = Join-Path $env:USERPROFILE ".m2\repository\$groupPath\$artifactId\$Version"
New-Item -ItemType Directory -Force -Path $dir | Out-Null

$base = if ($Repo -eq "google") {
    "https://dl.google.com/dl/android/maven2/$groupPath/$ArtifactId/$Version"
} else {
    "https://repo.maven.apache.org/maven2/$groupPath/$ArtifactId/$Version"
}

$pom = Join-Path $dir "$ArtifactId-$Version.pom"
$jar = Join-Path $dir "$ArtifactId-$Version.jar"

if (-not (Test-Path $pom)) {
    curl.exe --ssl-no-revoke -fsSL -o $pom "$base/$ArtifactId-$Version.pom"
    Write-Host "POM ${GroupId}:${ArtifactId}:${Version}"
}
if (-not (Test-Path $jar)) {
    curl.exe --ssl-no-revoke -fsSL -o $jar "$base/$ArtifactId-$Version.jar" 2>$null
}

if (Test-Path $pom) {
    [xml]$xml = Get-Content $pom
    $ns = @{ m = "http://maven.apache.org/POM/4.0.0" }
    $deps = $xml.project.dependencies.dependency
    if (-not $deps) { $deps = @() }
    if ($deps -isnot [array]) { $deps = @($deps) }
    foreach ($d in $deps) {
        if ($d.version -and $d.groupId -and $d.artifactId) {
            $r = if ("$($d.groupId)" -match '^(com\.android|androidx\.)') { "google" } else { "central" }
            & $PSScriptRoot\fetch_maven_artifact.ps1 -GroupId $d.groupId -ArtifactId $d.artifactId -Version $d.version -Repo $r
        }
    }
}
