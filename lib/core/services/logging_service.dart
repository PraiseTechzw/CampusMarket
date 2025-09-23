/// @Branch: Logging Service
///
/// Production-ready logging service for Campus Market
/// Handles different log levels and output destinations
library;

import 'package:flutter/foundation.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import '../config/app_config.dart';
import '../config/firebase_config.dart';

enum LogLevel { debug, info, warning, error, fatal }

class LoggingService {
  static final LoggingService _instance = LoggingService._internal();
  factory LoggingService() => _instance;
  LoggingService._internal();

  static const String _tag = 'CampusMarket';

  /// Log a debug message
  static void debug(
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
  }) {
    _log(
      LogLevel.debug,
      message,
      tag: tag,
      error: error,
      stackTrace: stackTrace,
    );
  }

  /// Log an info message
  static void info(
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
  }) {
    _log(
      LogLevel.info,
      message,
      tag: tag,
      error: error,
      stackTrace: stackTrace,
    );
  }

  /// Log a warning message
  static void warning(
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
  }) {
    _log(
      LogLevel.warning,
      message,
      tag: tag,
      error: error,
      stackTrace: stackTrace,
    );
  }

  /// Log an error message
  static void error(
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
  }) {
    _log(
      LogLevel.error,
      message,
      tag: tag,
      error: error,
      stackTrace: stackTrace,
    );
  }

  /// Log a fatal error message
  static void fatal(
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
  }) {
    _log(
      LogLevel.fatal,
      message,
      tag: tag,
      error: error,
      stackTrace: stackTrace,
    );
  }

  /// Internal logging method
  static void _log(
    LogLevel level,
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
  }) {
    final logTag = tag ?? _tag;
    final timestamp = DateTime.now().toIso8601String();
    final levelString = level.name.toUpperCase();

    // Format the log message
    final formattedMessage = '[$timestamp] [$levelString] [$logTag] $message';

    // Console logging (debug mode only)
    if (AppConfig.enableLogging && kDebugMode) {
      switch (level) {
        case LogLevel.debug:
          print('🐛 $formattedMessage');
          break;
        case LogLevel.info:
          print('ℹ️ $formattedMessage');
          break;
        case LogLevel.warning:
          print('⚠️ $formattedMessage');
          break;
        case LogLevel.error:
          print('❌ $formattedMessage');
          break;
        case LogLevel.fatal:
          print('💀 $formattedMessage');
          break;
      }

      if (error != null) {
        print('Error: $error');
      }
      if (stackTrace != null) {
        print('Stack trace: $stackTrace');
      }
    }

    // Firebase Crashlytics logging (production only)
    if (AppConfig.enableCrashlytics && !kDebugMode) {
      try {
        // Log to Crashlytics
        FirebaseConfig.logMessage(formattedMessage);

        // Log errors and fatal messages as crashes
        if (level == LogLevel.error || level == LogLevel.fatal) {
          if (error != null) {
            FirebaseConfig.logCrash(error, stackTrace);
          } else {
            FirebaseConfig.logCrash(Exception(message), stackTrace);
          }
        }
      } catch (e) {
        // Fallback to console if Crashlytics fails
        if (kDebugMode) {
          print('Failed to log to Crashlytics: $e');
        }
      }
    }
  }

  /// Log user actions for analytics
  static void logUserAction(String action, {Map<String, dynamic>? parameters}) {
    if (AppConfig.enableAnalytics) {
      info('User Action: $action', tag: 'Analytics');

      // Log to Firebase Analytics if available
      try {
        if (FirebaseConfig.isInitialized) {
          // Note: Firebase Analytics logging would go here
          // This is a placeholder for future implementation
        }
      } catch (e) {
        error('Failed to log user action to analytics', error: e);
      }
    }
  }

  /// Log performance metrics
  static void logPerformance(
    String operation,
    Duration duration, {
    Map<String, dynamic>? metadata,
  }) {
    if (AppConfig.enableLogging) {
      info(
        'Performance: $operation took ${duration.inMilliseconds}ms',
        tag: 'Performance',
      );
    }
  }

  /// Log network requests
  static void logNetworkRequest(
    String method,
    String url,
    int statusCode,
    Duration duration,
  ) {
    if (AppConfig.enableLogging) {
      info(
        'Network: $method $url -> $statusCode (${duration.inMilliseconds}ms)',
        tag: 'Network',
      );
    }
  }

  /// Log authentication events
  static void logAuthEvent(
    String event, {
    String? userId,
    Map<String, dynamic>? metadata,
  }) {
    if (AppConfig.enableLogging) {
      info(
        'Auth: $event${userId != null ? ' (User: $userId)' : ''}',
        tag: 'Auth',
      );
    }
  }

  /// Log database operations
  static void logDatabaseOperation(
    String operation,
    String collection, {
    Map<String, dynamic>? metadata,
  }) {
    if (AppConfig.enableLogging) {
      info('Database: $operation on $collection', tag: 'Database');
    }
  }

  /// Log file operations
  static void logFileOperation(
    String operation,
    String fileName, {
    int? fileSize,
    Map<String, dynamic>? metadata,
  }) {
    if (AppConfig.enableLogging) {
      final sizeInfo = fileSize != null
          ? ' (${(fileSize / 1024).toStringAsFixed(1)}KB)'
          : '';
      info('File: $operation $fileName$sizeInfo', tag: 'File');
    }
  }

  /// Log security events
  static void logSecurityEvent(String event, {Map<String, dynamic>? metadata}) {
    warning('Security: $event', tag: 'Security');
  }

  /// Log business logic events
  static void logBusinessEvent(String event, {Map<String, dynamic>? metadata}) {
    info('Business: $event', tag: 'Business');
  }

  /// Log UI events
  static void logUIEvent(
    String event, {
    String? screen,
    Map<String, dynamic>? metadata,
  }) {
    if (AppConfig.enableLogging) {
      final screenInfo = screen != null ? ' on $screen' : '';
      info('UI: $event$screenInfo', tag: 'UI');
    }
  }

  /// Log errors with context
  static void logErrorWithContext(
    String message, {
    required String context,
    Object? error,
    StackTrace? stackTrace,
    Map<String, dynamic>? metadata,
  }) {
    LoggingService.error(
      '$context: $message',
      error: error,
      stackTrace: stackTrace,
    );
  }

  /// Log startup information
  static void logStartup() {
    info('App started', tag: 'Startup');
    info(
      'Environment: ${AppConfig.isProduction ? 'Production' : 'Development'}',
      tag: 'Startup',
    );
    info(
      'Version: ${AppConfig.appVersion} (${AppConfig.buildNumber})',
      tag: 'Startup',
    );
    info('Platform: ${defaultTargetPlatform.name}', tag: 'Startup');
  }

  /// Log shutdown information
  static void logShutdown() {
    info('App shutting down', tag: 'Shutdown');
  }

  /// Log memory usage
  static void logMemoryUsage() {
    if (AppConfig.enableLogging) {
      // Note: Memory usage logging would require platform-specific implementation
      info('Memory usage logged', tag: 'Memory');
    }
  }

  /// Log battery usage
  static void logBatteryUsage() {
    if (AppConfig.enableLogging) {
      // Note: Battery usage logging would require platform-specific implementation
      info('Battery usage logged', tag: 'Battery');
    }
  }

  /// Log network connectivity
  static void logNetworkConnectivity(bool isConnected, String connectionType) {
    info(
      'Network: ${isConnected ? 'Connected' : 'Disconnected'} ($connectionType)',
      tag: 'Network',
    );
  }

  /// Log location services
  static void logLocationServices(
    bool enabled, {
    double? latitude,
    double? longitude,
  }) {
    final locationInfo = (latitude != null && longitude != null)
        ? ' at ($latitude, $longitude)'
        : '';
    info(
      'Location services: ${enabled ? 'Enabled' : 'Disabled'}$locationInfo',
      tag: 'Location',
    );
  }

  /// Log camera usage
  static void logCameraUsage(
    String action, {
    String? imagePath,
    int? fileSize,
  }) {
    final sizeInfo = fileSize != null
        ? ' (${(fileSize / 1024).toStringAsFixed(1)}KB)'
        : '';
    info(
      'Camera: $action${imagePath != null ? ' -> $imagePath' : ''}$sizeInfo',
      tag: 'Camera',
    );
  }

  /// Log file upload
  static void logFileUpload(
    String fileName,
    int fileSize,
    bool success, {
    String? error,
  }) {
    final status = success ? 'Success' : 'Failed';
    final errorInfo = error != null ? ' ($error)' : '';
    info(
      'File Upload: $fileName (${(fileSize / 1024).toStringAsFixed(1)}KB) -> $status$errorInfo',
      tag: 'Upload',
    );
  }

  /// Log chat events
  static void logChatEvent(
    String event, {
    String? chatRoomId,
    String? messageId,
    Map<String, dynamic>? metadata,
  }) {
    final roomInfo = chatRoomId != null ? ' (Room: $chatRoomId)' : '';
    final messageInfo = messageId != null ? ' (Message: $messageId)' : '';
    info('Chat: $event$roomInfo$messageInfo', tag: 'Chat');
  }

  /// Log marketplace events
  static void logMarketplaceEvent(
    String event, {
    String? itemId,
    String? category,
    Map<String, dynamic>? metadata,
  }) {
    final itemInfo = itemId != null ? ' (Item: $itemId)' : '';
    final categoryInfo = category != null ? ' (Category: $category)' : '';
    info('Marketplace: $event$itemInfo$categoryInfo', tag: 'Marketplace');
  }
}
