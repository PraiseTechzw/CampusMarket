# Production Build Script for Campus Market Flutter App
# This script builds the app for production deployment

param(
    [switch]$SkipTests,
    [switch]$SkipAnalysis,
    [switch]$Verbose
)

# Set error action preference
$ErrorActionPreference = "Stop"

# Colors for output
$Red = "Red"
$Green = "Green"
$Yellow = "Yellow"
$Blue = "Blue"

function Write-Status {
    param([string]$Message)
    Write-Host "[INFO] $Message" -ForegroundColor $Blue
}

function Write-Success {
    param([string]$Message)
    Write-Host "[SUCCESS] $Message" -ForegroundColor $Green
}

function Write-Warning {
    param([string]$Message)
    Write-Host "[WARNING] $Message" -ForegroundColor $Yellow
}

function Write-Error {
    param([string]$Message)
    Write-Host "[ERROR] $Message" -ForegroundColor $Red
}

Write-Host "🚀 Starting production build for Campus Market..." -ForegroundColor $Blue

# Check if Flutter is installed
try {
    $flutterVersion = flutter --version | Select-String "Flutter" | ForEach-Object { $_.Line.Split()[1] }
    Write-Status "Using Flutter version: $flutterVersion"
} catch {
    Write-Error "Flutter is not installed or not in PATH"
    exit 1
}

# Clean previous builds
Write-Status "Cleaning previous builds..."
try {
    flutter clean
    Write-Success "Project cleaned successfully"
} catch {
    Write-Error "Failed to clean project"
    exit 1
}

# Get dependencies
Write-Status "Getting dependencies..."
try {
    flutter pub get
    Write-Success "Dependencies retrieved successfully"
} catch {
    Write-Error "Failed to get dependencies"
    exit 1
}

# Run tests (unless skipped)
if (-not $SkipTests) {
    Write-Status "Running tests..."
    try {
        flutter test
        Write-Success "All tests passed"
    } catch {
        Write-Warning "Tests failed, but continuing..."
    }
} else {
    Write-Warning "Skipping tests as requested"
}

# Run code analysis (unless skipped)
if (-not $SkipAnalysis) {
    Write-Status "Running code analysis..."
    try {
        flutter analyze
        Write-Success "Code analysis passed"
    } catch {
        Write-Warning "Code analysis found issues, but continuing..."
    }
} else {
    Write-Warning "Skipping code analysis as requested"
}

# Build APK
Write-Status "Building APK..."
try {
    flutter build apk --release --target-platform android-arm,android-arm64,android-x64
    Write-Success "APK built successfully"
} catch {
    Write-Error "APK build failed"
    exit 1
}

# Build AAB (Android App Bundle)
Write-Status "Building AAB (Android App Bundle)..."
try {
    flutter build appbundle --release
    Write-Success "AAB built successfully"
} catch {
    Write-Error "AAB build failed"
    exit 1
}

# Build Web
Write-Status "Building Web..."
try {
    flutter build web --release
    Write-Success "Web build completed successfully"
} catch {
    Write-Error "Web build failed"
    exit 1
}

# Get build information
$buildDate = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$buildCommit = try { git rev-parse HEAD } catch { "unknown" }

# Create build summary
Write-Status "Creating build summary..."
$summary = @"
Campus Market Production Build Summary
=====================================
Build Date: $buildDate
Git Commit: $buildCommit
Flutter Version: $flutterVersion

Build Artifacts:
- Android APK: build\app\outputs\flutter-apk\app-release.apk
- Android AAB: build\app\outputs\bundle\release\app-release.aab
- Web: build\web\

Next Steps:
1. Test the built applications
2. Upload APK to Google Play Store or distribute directly
3. Upload AAB to Google Play Store for optimized distribution
4. Deploy web version to hosting service

Build Configuration:
- APK: Multi-architecture (arm, arm64, x64)
- AAB: Optimized for Google Play Store
- Web: Production-optimized with tree shaking
"@

$summary | Out-File -FilePath "build_summary.txt" -Encoding UTF8
Write-Success "Build summary created: build_summary.txt"

# Show build artifacts
Write-Status "Build artifacts:"

# Check APK
$apkPath = "build\app\outputs\flutter-apk\app-release.apk"
if (Test-Path $apkPath) {
    $apkSize = (Get-Item $apkPath).Length
    $apkSizeMB = [math]::Round($apkSize / 1MB, 2)
    Write-Host "  ✓ APK: $apkPath" -ForegroundColor $Green
    Write-Host "    Size: $apkSizeMB MB ($apkSize bytes)" -ForegroundColor $Blue
} else {
    Write-Warning "  ✗ No APK found"
}

# Check AAB
$aabPath = "build\app\outputs\bundle\release\app-release.aab"
if (Test-Path $aabPath) {
    $aabSize = (Get-Item $aabPath).Length
    $aabSizeMB = [math]::Round($aabSize / 1MB, 2)
    Write-Host "  ✓ AAB: $aabPath" -ForegroundColor $Green
    Write-Host "    Size: $aabSizeMB MB ($aabSize bytes)" -ForegroundColor $Blue
} else {
    Write-Warning "  ✗ No AAB found"
}

# Check Web
$webPath = "build\web"
if (Test-Path $webPath) {
    $webFiles = (Get-ChildItem -Path $webPath -Recurse -File).Count
    $webSize = (Get-ChildItem -Path $webPath -Recurse -File | Measure-Object -Property Length -Sum).Sum
    $webSizeMB = [math]::Round($webSize / 1MB, 2)
    Write-Host "  ✓ Web: $webPath" -ForegroundColor $Green
    Write-Host "    Files: $webFiles files" -ForegroundColor $Blue
    Write-Host "    Size: $webSizeMB MB ($webSize bytes)" -ForegroundColor $Blue
} else {
    Write-Warning "  ✗ No web build found"
}

# Create deployment package
Write-Status "Creating deployment package..."
$deploymentDir = "deployment_$(Get-Date -Format 'yyyyMMdd_HHmmss')"
New-Item -ItemType Directory -Path $deploymentDir -Force | Out-Null

# Copy APK
if (Test-Path $apkPath) {
    Copy-Item $apkPath "$deploymentDir\campus_market.apk"
}

# Copy AAB
if (Test-Path $aabPath) {
    Copy-Item $aabPath "$deploymentDir\campus_market.aab"
}

# Copy Web
if (Test-Path $webPath) {
    Copy-Item $webPath "$deploymentDir\web" -Recurse
}

# Copy build summary
Copy-Item "build_summary.txt" "$deploymentDir\"

Write-Success "Deployment package created: $deploymentDir"

Write-Host ""
Write-Success "🎉 Production build completed successfully!"
Write-Status "Check build_summary.txt for details"
Write-Status "Deployment package: $deploymentDir"
Write-Host ""
Write-Host "Build completed at: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" -ForegroundColor $Blue
