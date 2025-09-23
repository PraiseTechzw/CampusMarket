@echo off
REM Production Build Script for Campus Market Flutter App
REM This script builds the app for production deployment

setlocal enabledelayedexpansion

echo 🚀 Starting production build for Campus Market...

REM Check if Flutter is installed
where flutter >nul 2>nul
if %errorlevel% neq 0 (
    echo [ERROR] Flutter is not installed or not in PATH
    exit /b 1
)

REM Check Flutter version
for /f "tokens=2" %%i in ('flutter --version ^| findstr "Flutter"') do set FLUTTER_VERSION=%%i
echo [INFO] Using Flutter version: %FLUTTER_VERSION%

REM Clean previous builds
echo [INFO] Cleaning previous builds...
call flutter clean
if %errorlevel% neq 0 (
    echo [ERROR] Failed to clean project
    exit /b 1
)

REM Get dependencies
echo [INFO] Getting dependencies...
call flutter pub get
if %errorlevel% neq 0 (
    echo [ERROR] Failed to get dependencies
    exit /b 1
)

REM Run tests
echo [INFO] Running tests...
call flutter test
if %errorlevel% neq 0 (
    echo [WARNING] Tests failed, but continuing...
)

REM Run code analysis
echo [INFO] Running code analysis...
call flutter analyze
if %errorlevel% neq 0 (
    echo [WARNING] Code analysis found issues, but continuing...
)

REM Build APK
echo [INFO] Building APK...
call flutter build apk --release --target-platform android-arm,android-arm64,android-x64
if %errorlevel% neq 0 (
    echo [ERROR] APK build failed
    exit /b 1
)
echo [SUCCESS] APK built successfully

REM Build AAB (Android App Bundle)
echo [INFO] Building AAB (Android App Bundle)...
call flutter build appbundle --release
if %errorlevel% neq 0 (
    echo [ERROR] AAB build failed
    exit /b 1
)
echo [SUCCESS] AAB built successfully

REM Build Web
echo [INFO] Building Web...
call flutter build web --release
if %errorlevel% neq 0 (
    echo [ERROR] Web build failed
    exit /b 1
)
echo [SUCCESS] Web build completed successfully

REM Create build summary
echo [INFO] Creating build summary...
set BUILD_DATE=%date% %time%
for /f "tokens=*" %%i in ('git rev-parse HEAD 2^>nul') do set BUILD_COMMIT=%%i
if "%BUILD_COMMIT%"=="" set BUILD_COMMIT=unknown

(
echo Campus Market Production Build Summary
echo =====================================
echo Build Date: %BUILD_DATE%
echo Git Commit: %BUILD_COMMIT%
echo Flutter Version: %FLUTTER_VERSION%
echo.
echo Build Artifacts:
echo - Android APK: build\app\outputs\flutter-apk\app-release.apk
echo - Android AAB: build\app\outputs\bundle\release\app-release.aab
echo - Web: build\web\
echo.
echo Next Steps:
echo 1. Test the built applications
echo 2. Upload APK to Google Play Store or distribute directly
echo 3. Upload AAB to Google Play Store for optimized distribution
echo 4. Deploy web version to hosting service
) > build_summary.txt

echo [SUCCESS] Build summary created: build_summary.txt

REM Show build artifacts
echo [INFO] Build artifacts:
if exist "build\app\outputs\flutter-apk\app-release.apk" (
    echo - APK: build\app\outputs\flutter-apk\app-release.apk
    for %%i in ("build\app\outputs\flutter-apk\app-release.apk") do echo   Size: %%~zi bytes
) else (
    echo [WARNING] No APK found
)

if exist "build\app\outputs\bundle\release\app-release.aab" (
    echo - AAB: build\app\outputs\bundle\release\app-release.aab
    for %%i in ("build\app\outputs\bundle\release\app-release.aab") do echo   Size: %%~zi bytes
) else (
    echo [WARNING] No AAB found
)

if exist "build\web\" (
    echo - Web: build\web\
    dir /s "build\web" | find /c /v "" | findstr /v "Directory" > temp_count.txt
    set /p WEB_FILES=<temp_count.txt
    del temp_count.txt
    echo   Files: !WEB_FILES! files
) else (
    echo [WARNING] No web build found
)

echo.
echo [SUCCESS] 🎉 Production build completed successfully!
echo [INFO] Check build_summary.txt for details
echo.
echo Build completed at: %date% %time%

endlocal
