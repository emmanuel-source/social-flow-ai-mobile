param(
    [switch]$Build
)

$ErrorActionPreference = "Stop"
$projectRoot = Split-Path -Parent $PSScriptRoot

if (-not (Get-Command flutter -ErrorAction SilentlyContinue)) {
    throw "Flutter n'est pas installe ou n'est pas disponible dans PATH."
}

$requiredPaths = @(
    "pubspec.yaml",
    "android",
    "ios",
    "web"
)

foreach ($requiredPath in $requiredPaths) {
    $resolvedPath = Join-Path $projectRoot $requiredPath
    if (-not (Test-Path -LiteralPath $resolvedPath)) {
        throw "Structure Flutter incomplete : '$requiredPath' est absent. Restaurez-le depuis Git avant de continuer."
    }
}

Push-Location $projectRoot
try {
    Write-Host "Social Flow AI - verification de la fondation Flutter"
    flutter --version
    dart --version
    flutter pub get
    dart format --output=none --set-exit-if-changed lib test
    flutter analyze
    flutter test

    if ($Build) {
        flutter build web
        flutter build apk --debug
    }
} finally {
    Pop-Location
}

Write-Host "Fondation Flutter validee."
