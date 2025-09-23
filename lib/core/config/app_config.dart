/// @Branch: Application Configuration
///
/// Production-ready configuration for Campus Market
/// Handles environment-specific settings and feature flags
library;

import 'package:flutter/foundation.dart';

class AppConfig {
  // App Information
  static const String appName = 'Campus Market';
  static const String appVersion = '1.0.0';
  static const int buildNumber = 1;

  // Environment
  static bool get isProduction => kReleaseMode;
  static bool get isDebug => kDebugMode;
  static bool get isProfile => kProfileMode;

  // Feature Flags
  static bool get enableAnalytics => isProduction;
  static bool get enableCrashlytics => isProduction;
  static bool get enableLogging => !isProduction;
  static bool get enableDebugMode => isDebug;

  // API Configuration
  static const String apiBaseUrl = 'https://api.campusmarket.com';
  static const Duration apiTimeout = Duration(seconds: 30);
  static const int maxRetryAttempts = 3;

  // Image Configuration
  static const int maxImageSize = 2 * 1024 * 1024; // 2MB
  static const List<String> allowedImageTypes = ['jpg', 'jpeg', 'png', 'webp'];
  static const int maxImagesPerItem = 10;

  // Chat Configuration
  static const int maxMessageLength = 1000;
  static const int maxMessagesPerPage = 50;
  static const Duration messageRetentionDays = Duration(days: 90);

  // Marketplace Configuration
  static const int maxTitleLength = 100;
  static const int maxDescriptionLength = 2000;
  static const int maxPrice = 1000000; // $10,000
  static const int minPrice = 1; // $0.01

  // User Configuration
  static const int maxProfileImageSize = 1 * 1024 * 1024; // 1MB
  static const int maxBioLength = 500;
  static const int maxUniversityLength = 100;

  // Security Configuration
  static const int maxLoginAttempts = 5;
  static const Duration loginLockoutDuration = Duration(minutes: 15);
  static const Duration sessionTimeout = Duration(hours: 24);

  // Performance Configuration
  static const int cacheSize = 100; // Number of items to cache
  static const Duration cacheExpiration = Duration(hours: 1);
  static const int maxConcurrentUploads = 3;

  // UI Configuration
  static const Duration animationDuration = Duration(milliseconds: 300);
  static const Duration splashScreenDuration = Duration(seconds: 2);
  static const int maxSearchResults = 100;

  // Error Messages
  static const String networkErrorMessage =
      'Please check your internet connection and try again.';
  static const String serverErrorMessage =
      'Server error. Please try again later.';
  static const String unknownErrorMessage =
      'An unexpected error occurred. Please try again.';
  static const String authenticationErrorMessage =
      'Please sign in to continue.';
  static const String permissionErrorMessage =
      'Permission denied. Please check your settings.';

  // Success Messages
  static const String itemCreatedMessage = 'Item created successfully!';
  static const String itemUpdatedMessage = 'Item updated successfully!';
  static const String itemDeletedMessage = 'Item deleted successfully!';
  static const String messageSentMessage = 'Message sent successfully!';
  static const String profileUpdatedMessage = 'Profile updated successfully!';

  // Validation Messages
  static const String requiredFieldMessage = 'This field is required.';
  static const String invalidEmailMessage =
      'Please enter a valid email address.';
  static const String invalidPhoneMessage =
      'Please enter a valid phone number.';
  static const String passwordTooShortMessage =
      'Password must be at least 8 characters.';
  static const String passwordMismatchMessage = 'Passwords do not match.';
  static const String imageTooLargeMessage =
      'Image size must be less than 2MB.';
  static const String invalidImageFormatMessage =
      'Please select a valid image format.';

  // Development Configuration
  static const bool enableMockData = false;
  static const bool enablePerformanceOverlay = false;
  static const bool enableSemanticsDebugger = false;
  static const bool enableInspectorSelect = false;

  // Logging Configuration
  static const String logLevel = 'INFO';
  static const bool enableConsoleLogging = true;
  static const bool enableFileLogging = false;
  static const int maxLogFileSize = 10 * 1024 * 1024; // 10MB

  // Rate Limiting
  static const int maxRequestsPerMinute = 60;
  static const int maxUploadsPerHour = 10;
  static const int maxMessagesPerMinute = 10;

  // Backup Configuration
  static const bool enableAutoBackup = true;
  static const Duration backupInterval = Duration(hours: 6);
  static const int maxBackupFiles = 5;

  // Update Configuration
  static const bool enableAutoUpdate = true;
  static const Duration updateCheckInterval = Duration(hours: 24);
  static const bool forceUpdate = false;

  // Privacy Configuration
  static const bool enableDataCollection = true;
  static const bool enableCrashReporting = true;
  static const bool enableAnalyticsCollection = true;
  static const bool enablePersonalizedAds = false;

  // Accessibility Configuration
  static const bool enableAccessibilityFeatures = true;
  static const double minTouchTargetSize = 48.0;
  static const double maxTextScaleFactor = 2.0;

  // Localization Configuration
  static const String defaultLocale = 'en';
  static const List<String> supportedLocales = ['en', 'sn'];
  static const bool enableRTL = false;

  // Theme Configuration
  static const bool enableDarkMode = true;
  static const bool enableSystemTheme = true;
  static const bool enableCustomThemes = false;

  // Notification Configuration
  static const bool enablePushNotifications = true;
  static const bool enableEmailNotifications = true;
  static const bool enableSMSNotifications = false;
  static const Duration notificationCooldown = Duration(minutes: 5);

  // Search Configuration
  static const int minSearchQueryLength = 2;
  static const int maxSearchQueryLength = 100;
  static const Duration searchDebounceDelay = Duration(milliseconds: 500);
  static const int maxSearchHistory = 20;

  // Filter Configuration
  static const int maxPriceRange = 100000;
  static const int minPriceRange = 0;
  static const int maxDistanceKm = 100;
  static const int minDistanceKm = 0;

  // Pagination Configuration
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;
  static const int preloadThreshold = 5;

  // Cache Configuration
  static const Duration imageCacheExpiration = Duration(days: 7);
  static const Duration dataCacheExpiration = Duration(hours: 1);
  static const Duration userCacheExpiration = Duration(minutes: 30);

  // Security Headers
  static const Map<String, String> securityHeaders = {
    'X-Content-Type-Options': 'nosniff',
    'X-Frame-Options': 'DENY',
    'X-XSS-Protection': '1; mode=block',
  };

  // Content Security Policy
  static const String contentSecurityPolicy =
      "default-src 'self'; "
      "script-src 'self' 'unsafe-inline' 'unsafe-eval'; "
      "style-src 'self' 'unsafe-inline'; "
      "img-src 'self' data: https:; "
      "font-src 'self' data:; "
      "connect-src 'self' https:;";

  // Feature Toggles
  static const Map<String, bool> featureToggles = {
    'enableMarketplace': true,
    'enableAccommodations': true,
    'enableEvents': true,
    'enableChat': true,
    'enableFavorites': true,
    'enableReviews': true,
    'enableNotifications': true,
    'enableLocationServices': true,
    'enableCamera': true,
    'enableFileUpload': true,
    'enableSocialLogin': false,
    'enableBiometricAuth': false,
    'enableOfflineMode': false,
    'enableBetaFeatures': false,
  };

  // Get feature toggle value
  static bool isFeatureEnabled(String feature) {
    return featureToggles[feature] ?? false;
  }

  // Get environment-specific configuration
  static Map<String, dynamic> getEnvironmentConfig() => {
    'isProduction': isProduction,
    'isDebug': isDebug,
    'isProfile': isProfile,
    'appName': appName,
    'appVersion': appVersion,
    'buildNumber': buildNumber,
    'enableAnalytics': enableAnalytics,
    'enableCrashlytics': enableCrashlytics,
    'enableLogging': enableLogging,
  };
}
