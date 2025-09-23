# Production Build Guide for Campus Market

This guide explains how to build the Campus Market Flutter app for production deployment across multiple platforms.

## Prerequisites

- Flutter SDK (3.9.0 or higher)
- Dart SDK (included with Flutter)
- Android SDK (for Android builds)
- Git (for version tracking)
- Internet connection (for dependencies)

## Build Scripts

We provide three build scripts for different platforms:

### 1. Windows Batch Script (`scripts/build_production.bat`)
```cmd
scripts\build_production.bat
```

### 2. PowerShell Script (`scripts/build_production.ps1`)
```powershell
# Basic build
.\scripts\build_production.ps1

# Skip tests and analysis
.\scripts\build_production.ps1 -SkipTests -SkipAnalysis

# Verbose output
.\scripts\build_production.ps1 -Verbose
```

### 3. Unix/Linux/macOS Shell Script (`scripts/build_production.sh`)
```bash
# Make executable (first time only)
chmod +x scripts/build_production.sh

# Basic build
./scripts/build_production.sh

# Skip tests and analysis
./scripts/build_production.sh --skip-tests --skip-analysis

# Verbose output
./scripts/build_production.sh --verbose

# Show help
./scripts/build_production.sh --help
```

## Build Outputs

The build process creates the following artifacts:

### Android APK (`build/app/outputs/flutter-apk/app-release.apk`)
- **Purpose**: Direct installation on Android devices
- **Architecture**: Multi-architecture (arm, arm64, x64)
- **Use Case**: 
  - Direct distribution to users
  - Testing on physical devices
  - Side-loading installations

### Android App Bundle (`build/app/outputs/bundle/release/app-release.aab`)
- **Purpose**: Optimized distribution through Google Play Store
- **Architecture**: Dynamic delivery (Google Play generates APKs)
- **Use Case**:
  - Google Play Store uploads
  - Optimized app size for users
  - Dynamic feature delivery

### Web Build (`build/web/`)
- **Purpose**: Web application deployment
- **Format**: Static HTML, CSS, JavaScript files
- **Use Case**:
  - Web hosting deployment
  - Progressive Web App (PWA)
  - Cross-platform web access

## Build Process

The build scripts perform the following steps:

1. **Clean**: Remove previous build artifacts
2. **Dependencies**: Download and install Flutter packages
3. **Tests**: Run unit and widget tests (optional)
4. **Analysis**: Run static code analysis (optional)
5. **APK Build**: Create Android APK with multiple architectures
6. **AAB Build**: Create Android App Bundle for Play Store
7. **Web Build**: Create optimized web application
8. **Summary**: Generate build report and deployment package

## Production Optimizations

### APK Optimizations
- **Multi-architecture**: Supports ARM, ARM64, and x64 devices
- **Release mode**: Optimized for performance and size
- **ProGuard**: Code obfuscation and optimization
- **Resource shrinking**: Removes unused resources

### AAB Optimizations
- **Dynamic delivery**: Google Play generates optimized APKs
- **Asset packs**: Efficient resource management
- **App signing**: Production-ready signing
- **Size optimization**: Smaller download sizes

### Web Optimizations
- **Tree shaking**: Removes unused code
- **Minification**: Compressed JavaScript and CSS
- **Asset optimization**: Optimized images and fonts
- **Service worker**: PWA capabilities

## Deployment

### Android Deployment

#### Google Play Store (AAB)
1. Upload `app-release.aab` to Google Play Console
2. Configure app signing
3. Set up release tracks (internal, alpha, beta, production)
4. Configure store listing and metadata

#### Direct Distribution (APK)
1. Host APK on your website or file sharing service
2. Provide download link to users
3. Users need to enable "Install from unknown sources"

### Web Deployment

#### Static Hosting
1. Upload contents of `build/web/` to your web server
2. Configure web server for SPA routing
3. Set up HTTPS and domain

#### Popular Hosting Services
- **Firebase Hosting**: `firebase deploy`
- **Netlify**: Drag and drop `build/web/` folder
- **Vercel**: Connect GitHub repository
- **GitHub Pages**: Push to `gh-pages` branch

## Build Configuration

### Android Configuration (`android/app/build.gradle.kts`)
```kotlin
buildTypes {
    release {
        minifyEnabled = true
        shrinkResources = true
        proguardFiles(
            getDefaultProguardFile("proguard-android-optimize.txt"),
            "proguard-rules.pro"
        )
        signingConfig = signingConfigs.getByName("debug") // TODO: Add production signing
    }
}
```

### Web Configuration (`web/index.html`)
- Optimized for production
- Service worker for PWA
- Meta tags for SEO
- Performance optimizations

## Troubleshooting

### Common Issues

#### Build Failures
```bash
# Clean and rebuild
flutter clean
flutter pub get
flutter build apk --release
```

#### Dependency Issues
```bash
# Update dependencies
flutter pub upgrade
flutter pub get
```

#### Signing Issues
- Ensure you have proper signing configuration
- Check keystore file exists and is accessible
- Verify signing configuration in `build.gradle.kts`

#### Web Build Issues
```bash
# Clear web build cache
flutter clean
flutter build web --release --web-renderer html
```

### Performance Issues

#### Large APK Size
- Enable ProGuard rules
- Use AAB instead of APK
- Optimize images and assets
- Remove unused dependencies

#### Slow Build Times
- Use `--skip-tests` and `--skip-analysis` flags
- Enable build caching
- Use faster development machines

## Security Considerations

### Code Obfuscation
- ProGuard rules are configured for Android
- Sensitive code is obfuscated in release builds
- API keys should be stored securely

### Signing
- Production builds should use proper signing keys
- Never commit signing keys to version control
- Use secure key management systems

### Web Security
- HTTPS is required for PWA features
- Content Security Policy is configured
- Secure headers are set

## Monitoring and Analytics

### Firebase Integration
- Crashlytics for crash reporting
- Analytics for usage tracking
- Performance monitoring
- Remote configuration

### Production Logging
- Structured logging with different levels
- Error tracking and reporting
- Performance metrics collection
- User action tracking

## Maintenance

### Regular Updates
- Update Flutter SDK regularly
- Update dependencies monthly
- Monitor security advisories
- Test builds on different devices

### Version Management
- Use semantic versioning
- Tag releases in Git
- Maintain changelog
- Document breaking changes

## Support

For build-related issues:
1. Check this documentation
2. Review build logs
3. Check Flutter documentation
4. Contact development team

## Build Summary

After successful build, you'll find:
- `build_summary.txt`: Detailed build information
- `deployment_YYYYMMDD_HHMMSS/`: Ready-to-deploy package
- Individual build artifacts in their respective directories

The build process ensures your Campus Market app is production-ready with optimal performance, security, and user experience across all platforms.
