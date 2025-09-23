#!/bin/bash

# Production Build Script for Campus Market Flutter App
# This script builds the app for production deployment

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Parse command line arguments
SKIP_TESTS=false
SKIP_ANALYSIS=false
VERBOSE=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --skip-tests)
            SKIP_TESTS=true
            shift
            ;;
        --skip-analysis)
            SKIP_ANALYSIS=true
            shift
            ;;
        --verbose)
            VERBOSE=true
            shift
            ;;
        -h|--help)
            echo "Usage: $0 [OPTIONS]"
            echo "Options:"
            echo "  --skip-tests      Skip running tests"
            echo "  --skip-analysis   Skip code analysis"
            echo "  --verbose         Enable verbose output"
            echo "  -h, --help        Show this help message"
            exit 0
            ;;
        *)
            print_error "Unknown option: $1"
            exit 1
            ;;
    esac
done

echo "🚀 Starting production build for Campus Market..."

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    print_error "Flutter is not installed or not in PATH"
    exit 1
fi

# Check Flutter version
FLUTTER_VERSION=$(flutter --version | head -n 1 | cut -d ' ' -f 2)
print_status "Using Flutter version: $FLUTTER_VERSION"

# Clean previous builds
print_status "Cleaning previous builds..."
flutter clean
print_success "Project cleaned successfully"

# Get dependencies
print_status "Getting dependencies..."
flutter pub get
print_success "Dependencies retrieved successfully"

# Run tests (unless skipped)
if [ "$SKIP_TESTS" = false ]; then
    print_status "Running tests..."
    if flutter test; then
        print_success "All tests passed"
    else
        print_warning "Tests failed, but continuing..."
    fi
else
    print_warning "Skipping tests as requested"
fi

# Run code analysis (unless skipped)
if [ "$SKIP_ANALYSIS" = false ]; then
    print_status "Running code analysis..."
    if flutter analyze; then
        print_success "Code analysis passed"
    else
        print_warning "Code analysis found issues, but continuing..."
    fi
else
    print_warning "Skipping code analysis as requested"
fi

# Build APK
print_status "Building APK..."
if flutter build apk --release --target-platform android-arm,android-arm64,android-x64; then
    print_success "APK built successfully"
else
    print_error "APK build failed"
    exit 1
fi

# Build AAB (Android App Bundle)
print_status "Building AAB (Android App Bundle)..."
if flutter build appbundle --release; then
    print_success "AAB built successfully"
else
    print_error "AAB build failed"
    exit 1
fi

# Build Web
print_status "Building Web..."
if flutter build web --release; then
    print_success "Web build completed successfully"
else
    print_error "Web build failed"
    exit 1
fi

# Get build information
BUILD_DATE=$(date)
BUILD_COMMIT=$(git rev-parse HEAD 2>/dev/null || echo "unknown")

# Create build summary
print_status "Creating build summary..."
cat > build_summary.txt << EOF
Campus Market Production Build Summary
=====================================
Build Date: $BUILD_DATE
Git Commit: $BUILD_COMMIT
Flutter Version: $FLUTTER_VERSION

Build Artifacts:
- Android APK: build/app/outputs/flutter-apk/app-release.apk
- Android AAB: build/app/outputs/bundle/release/app-release.aab
- Web: build/web/

Next Steps:
1. Test the built applications
2. Upload APK to Google Play Store or distribute directly
3. Upload AAB to Google Play Store for optimized distribution
4. Deploy web version to hosting service

Build Configuration:
- APK: Multi-architecture (arm, arm64, x64)
- AAB: Optimized for Google Play Store
- Web: Production-optimized with tree shaking
EOF

print_success "Build summary created: build_summary.txt"

# Show build artifacts
print_status "Build artifacts:"

# Check APK
APK_PATH="build/app/outputs/flutter-apk/app-release.apk"
if [ -f "$APK_PATH" ]; then
    APK_SIZE=$(stat -f%z "$APK_PATH" 2>/dev/null || stat -c%s "$APK_PATH" 2>/dev/null || echo "0")
    APK_SIZE_MB=$(echo "scale=2; $APK_SIZE / 1024 / 1024" | bc 2>/dev/null || echo "0")
    print_success "✓ APK: $APK_PATH"
    print_status "  Size: ${APK_SIZE_MB}MB ($APK_SIZE bytes)"
else
    print_warning "✗ No APK found"
fi

# Check AAB
AAB_PATH="build/app/outputs/bundle/release/app-release.aab"
if [ -f "$AAB_PATH" ]; then
    AAB_SIZE=$(stat -f%z "$AAB_PATH" 2>/dev/null || stat -c%s "$AAB_PATH" 2>/dev/null || echo "0")
    AAB_SIZE_MB=$(echo "scale=2; $AAB_SIZE / 1024 / 1024" | bc 2>/dev/null || echo "0")
    print_success "✓ AAB: $AAB_PATH"
    print_status "  Size: ${AAB_SIZE_MB}MB ($AAB_SIZE bytes)"
else
    print_warning "✗ No AAB found"
fi

# Check Web
WEB_PATH="build/web"
if [ -d "$WEB_PATH" ]; then
    WEB_FILES=$(find "$WEB_PATH" -type f | wc -l)
    WEB_SIZE=$(find "$WEB_PATH" -type f -exec stat -f%z {} + 2>/dev/null | awk '{sum+=$1} END {print sum}' || find "$WEB_PATH" -type f -exec stat -c%s {} + 2>/dev/null | awk '{sum+=$1} END {print sum}' || echo "0")
    WEB_SIZE_MB=$(echo "scale=2; $WEB_SIZE / 1024 / 1024" | bc 2>/dev/null || echo "0")
    print_success "✓ Web: $WEB_PATH"
    print_status "  Files: $WEB_FILES files"
    print_status "  Size: ${WEB_SIZE_MB}MB ($WEB_SIZE bytes)"
else
    print_warning "✗ No web build found"
fi

# Create deployment package
print_status "Creating deployment package..."
DEPLOYMENT_DIR="deployment_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$DEPLOYMENT_DIR"

# Copy APK
if [ -f "$APK_PATH" ]; then
    cp "$APK_PATH" "$DEPLOYMENT_DIR/campus_market.apk"
fi

# Copy AAB
if [ -f "$AAB_PATH" ]; then
    cp "$AAB_PATH" "$DEPLOYMENT_DIR/campus_market.aab"
fi

# Copy Web
if [ -d "$WEB_PATH" ]; then
    cp -r "$WEB_PATH" "$DEPLOYMENT_DIR/"
fi

# Copy build summary
cp "build_summary.txt" "$DEPLOYMENT_DIR/"

print_success "Deployment package created: $DEPLOYMENT_DIR"

echo ""
print_success "🎉 Production build completed successfully!"
print_status "Check build_summary.txt for details"
print_status "Deployment package: $DEPLOYMENT_DIR"
echo ""
print_status "Build completed at: $(date)"