# 🚀 Campus Market Deployment Guide

## Overview
This document provides comprehensive instructions for deploying Campus Market across multiple platforms using our CI/CD pipeline.

## 📋 Prerequisites

### Required Tools
- Flutter SDK 3.35.2+
- Dart SDK 3.9.0+
- Android Studio (for Android builds)
- Xcode (for iOS builds, macOS only)
- Firebase CLI
- Git

### Required Accounts
- GitHub (for CI/CD)
- Firebase (for web hosting)
- Google Play Console (for Android)
- Apple Developer (for iOS)

## 🔧 Environment Setup

### 1. GitHub Secrets Configuration
Configure the following secrets in your GitHub repository:

```bash
# Firebase
FIREBASE_SERVICE_ACCOUNT=<firebase-service-account-json>

# Google Play Store
GOOGLE_PLAY_SERVICE_ACCOUNT=<google-play-service-account-json>

# Slack Notifications (Optional)
SLACK_WEBHOOK_URL=<slack-webhook-url>

# Additional Secrets
GITHUB_TOKEN=<github-token>
```

### 2. Firebase Configuration
1. Create a Firebase project
2. Enable Firebase Hosting
3. Download service account JSON
4. Add to GitHub Secrets as `FIREBASE_SERVICE_ACCOUNT`

### 3. Google Play Console Setup
1. Create a Google Play Console account
2. Create a new app
3. Generate service account JSON
4. Add to GitHub Secrets as `GOOGLE_PLAY_SERVICE_ACCOUNT`

## 🏗️ Build Process

### Local Development Build
```bash
# Install dependencies
flutter pub get

# Run tests
flutter test

# Build for development
flutter build apk --debug
flutter build web --debug
```

### Production Build
```bash
# Use our production script
powershell -ExecutionPolicy Bypass -File scripts/build_production_fixed.ps1

# Or manual build
flutter build apk --release --target-platform android-arm,android-arm64,android-x64
flutter build appbundle --release
flutter build web --release
```

## 🚀 Deployment Workflows

### 1. Automatic Deployment (CI/CD)
Our GitHub Actions automatically handle:
- **Code Quality**: Linting, formatting, analysis
- **Testing**: Unit tests, integration tests
- **Building**: APK, AAB, Web builds
- **Security**: Vulnerability scanning
- **Performance**: Performance testing
- **Deployment**: Firebase Hosting, Google Play Store

### 2. Manual Deployment
For manual deployments, use the workflow dispatch:

1. Go to GitHub Actions
2. Select "Production Deployment"
3. Click "Run workflow"
4. Choose environment and version
5. Click "Run workflow"

### 3. Release Management
Create releases using GitHub's release system:
1. Create a new release
2. Tag with version (e.g., `v1.0.0`)
3. CI/CD automatically builds and deploys

## 📱 Platform-Specific Deployment

### Android Deployment
```bash
# Build APK
flutter build apk --release --target-platform android-arm,android-arm64,android-x64

# Build AAB (for Play Store)
flutter build appbundle --release

# Upload to Play Store (manual)
# Use Google Play Console or Firebase App Distribution
```

### Web Deployment
```bash
# Build web
flutter build web --release

# Deploy to Firebase Hosting
firebase deploy --only hosting

# Or use GitHub Actions (automatic)
```

### iOS Deployment (macOS only)
```bash
# Build iOS
flutter build ios --release

# Archive for App Store
# Use Xcode for final App Store submission
```

## 🔍 Monitoring & Analytics

### Build Monitoring
- GitHub Actions provides real-time build status
- Slack notifications for deployment status
- Build artifacts are stored for 30 days

### Performance Monitoring
- Weekly performance tests
- Load testing for scalability
- Security scanning for vulnerabilities

### Analytics Integration
- Firebase Analytics (automatic)
- Crashlytics for crash reporting
- Performance monitoring

## 🛠️ Troubleshooting

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
flutter pub outdated
```

#### Firebase Issues
```bash
# Reconfigure Firebase
firebase login
firebase use --add
firebase deploy
```

### Debug Commands
```bash
# Check Flutter version
flutter --version

# Check dependencies
flutter pub deps

# Analyze code
flutter analyze

# Run tests
flutter test
```

## 📊 Build Artifacts

### Generated Files
- **APK**: `build/app/outputs/flutter-apk/app-release.apk`
- **AAB**: `build/app/outputs/bundle/release/app-release.aab`
- **Web**: `build/web/` directory

### Deployment Packages
- Created in `deployment_YYYYMMDD_HHMMSS/` directories
- Include all build artifacts
- Include build summary
- Ready for distribution

## 🔐 Security Considerations

### Secrets Management
- All secrets stored in GitHub Secrets
- No hardcoded credentials
- Service accounts with minimal permissions

### Code Security
- Automated vulnerability scanning
- Dependency auditing
- Secret scanning
- Code quality checks

## 📈 Performance Optimization

### Build Optimization
- Tree shaking enabled
- Font optimization
- Asset compression
- Multi-architecture builds

### Runtime Optimization
- Lazy loading
- Image caching
- Network optimization
- Memory management

## 🎯 Best Practices

### Development
1. Always test locally before pushing
2. Use feature branches for development
3. Write comprehensive tests
4. Follow code style guidelines

### Deployment
1. Use staging environment for testing
2. Monitor deployment status
3. Keep rollback plan ready
4. Document all changes

### Maintenance
1. Regular dependency updates
2. Security patch management
3. Performance monitoring
4. User feedback integration

## 📞 Support

For deployment issues:
1. Check GitHub Actions logs
2. Review build summary
3. Check Firebase console
4. Contact development team

## 🔄 Version Management

### Versioning Strategy
- Semantic versioning (MAJOR.MINOR.PATCH)
- Build numbers for mobile apps
- Git tags for releases

### Release Process
1. Update version in `pubspec.yaml`
2. Create release branch
3. Test thoroughly
4. Create GitHub release
5. Deploy automatically

---

**Last Updated**: September 25, 2025  
**Version**: 1.0.0  
**Maintainer**: Campus Market Development Team
