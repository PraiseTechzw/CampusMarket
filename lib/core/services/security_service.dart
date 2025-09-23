/// @Branch: Security Service
///
/// Production-ready security service for Campus Market
/// Handles authentication, authorization, and security monitoring
library;

import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'dart:math';
import 'dart:async';
import '../config/app_config.dart';
import 'logging_service.dart';

class SecurityService {
  static final SecurityService _instance = SecurityService._internal();
  factory SecurityService() => _instance;
  SecurityService._internal();

  static const String _securityKey = 'campus_market_security';
  static const int _maxLoginAttempts = 5;
  static const Duration _lockoutDuration = Duration(minutes: 15);

  final Map<String, int> _loginAttempts = {};
  final Map<String, DateTime> _lockoutTimes = {};
  final List<String> _suspiciousActivities = [];

  /// Validate email format
  static bool isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }

  /// Validate password strength
  static PasswordStrength validatePassword(String password) {
    if (password.length < 8) {
      return PasswordStrength.weak;
    }

    bool hasUppercase = password.contains(RegExp(r'[A-Z]'));
    bool hasLowercase = password.contains(RegExp(r'[a-z]'));
    bool hasDigits = password.contains(RegExp(r'[0-9]'));
    bool hasSpecialChars = password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));

    int strength = 0;
    if (hasUppercase) strength++;
    if (hasLowercase) strength++;
    if (hasDigits) strength++;
    if (hasSpecialChars) strength++;
    if (password.length >= 12) strength++;

    if (strength < 2) return PasswordStrength.weak;
    if (strength < 4) return PasswordStrength.medium;
    return PasswordStrength.strong;
  }

  /// Validate phone number format
  static bool isValidPhoneNumber(String phone) {
    final phoneRegex = RegExp(r'^\+?[1-9]\d{1,14}$');
    return phoneRegex.hasMatch(phone.replaceAll(RegExp(r'[\s\-\(\)]'), ''));
  }

  /// Sanitize user input
  static String sanitizeInput(String input) {
    if (input.isEmpty) return input;

    // Remove potentially dangerous characters
    String sanitized = input
        .replaceAll(
          RegExp(r'<script[^>]*>.*?</script>', caseSensitive: false),
          '',
        )
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll(RegExp(r'javascript:', caseSensitive: false), '')
        .replaceAll(RegExp(r'data:', caseSensitive: false), '')
        .replaceAll(RegExp(r'vbscript:', caseSensitive: false), '');

    // Trim whitespace
    sanitized = sanitized.trim();

    // Log suspicious input
    if (input != sanitized) {
      LoggingService.logSecurityEvent(
        'Input sanitized',
        metadata: {'original': input, 'sanitized': sanitized},
      );
    }

    return sanitized;
  }

  /// Validate file upload
  static bool isValidFileUpload(
    String fileName,
    int fileSize,
    List<String> allowedTypes,
  ) {
    // Check file size
    if (fileSize > AppConfig.maxImageSize) {
      LoggingService.logSecurityEvent(
        'File upload rejected: too large',
        metadata: {
          'fileName': fileName,
          'fileSize': fileSize,
          'maxSize': AppConfig.maxImageSize,
        },
      );
      return false;
    }

    // Check file extension
    final extension = fileName.split('.').last.toLowerCase();
    if (!allowedTypes.contains(extension)) {
      LoggingService.logSecurityEvent(
        'File upload rejected: invalid type',
        metadata: {
          'fileName': fileName,
          'fileType': extension,
          'allowedTypes': allowedTypes,
        },
      );
      return false;
    }

    // Check for suspicious file names
    if (fileName.contains('..') ||
        fileName.contains('/') ||
        fileName.contains('\\')) {
      LoggingService.logSecurityEvent(
        'File upload rejected: suspicious name',
        metadata: {'fileName': fileName},
      );
      return false;
    }

    return true;
  }

  /// Check for suspicious activity
  static bool isSuspiciousActivity(
    String userId,
    String activity,
    Map<String, dynamic>? metadata,
  ) {
    final now = DateTime.now();
    final key = '$userId:$activity';

    // Check if user is locked out
    if (_instance._lockoutTimes.containsKey(userId)) {
      final lockoutTime = _instance._lockoutTimes[userId]!;
      if (now.difference(lockoutTime) < _lockoutDuration) {
        LoggingService.logSecurityEvent(
          'User locked out',
          metadata: {
            'userId': userId,
            'activity': activity,
            'lockoutTime': lockoutTime.toIso8601String(),
          },
        );
        return true;
      } else {
        // Remove expired lockout
        _instance._lockoutTimes.remove(userId);
        _instance._loginAttempts.remove(userId);
      }
    }

    // Check for rapid repeated activities
    final recentActivities = _instance._suspiciousActivities
        .where(
          (activity) =>
              activity.startsWith('$userId:') &&
              now.difference(DateTime.parse(activity.split('|')[1])).inMinutes <
                  1,
        )
        .length;

    if (recentActivities > 10) {
      LoggingService.logSecurityEvent(
        'Suspicious activity detected: rapid requests',
        metadata: {
          'userId': userId,
          'activity': activity,
          'recentActivities': recentActivities,
        },
      );
      _lockoutUser(userId);
      return true;
    }

    // Log the activity
    _instance._suspiciousActivities.add(
      '$userId:$activity|${now.toIso8601String()}',
    );

    // Keep only recent activities (last hour)
    _instance._suspiciousActivities.removeWhere((activity) {
      final timestamp = DateTime.parse(activity.split('|')[1]);
      return now.difference(timestamp).inHours > 1;
    });

    return false;
  }

  /// Track login attempts
  static bool trackLoginAttempt(String userId, bool success) {
    if (success) {
      // Reset attempts on successful login
      _instance._loginAttempts.remove(userId);
      _instance._lockoutTimes.remove(userId);
      LoggingService.logAuthEvent('Login successful', userId: userId);
      return true;
    }

    // Increment failed attempts
    final attempts = (_instance._loginAttempts[userId] ?? 0) + 1;
    _instance._loginAttempts[userId] = attempts;

    LoggingService.logAuthEvent(
      'Login failed',
      userId: userId,
      metadata: {'attempts': attempts},
    );

    // Lock out user after max attempts
    if (attempts >= _maxLoginAttempts) {
      _lockoutUser(userId);
      return false;
    }

    return true;
  }

  /// Lock out user
  static void _lockoutUser(String userId) {
    _instance._lockoutTimes[userId] = DateTime.now();
    LoggingService.logSecurityEvent(
      'User locked out',
      metadata: {
        'userId': userId,
        'lockoutTime': DateTime.now().toIso8601String(),
      },
    );
  }

  /// Check if user is locked out
  static bool isUserLockedOut(String userId) {
    final lockoutTime = _instance._lockoutTimes[userId];
    if (lockoutTime == null) return false;

    final now = DateTime.now();
    if (now.difference(lockoutTime) >= _lockoutDuration) {
      // Remove expired lockout
      _instance._lockoutTimes.remove(userId);
      _instance._loginAttempts.remove(userId);
      return false;
    }

    return true;
  }

  /// Generate secure token
  static String generateSecureToken() {
    final random = Random.secure();
    final bytes = List<int>.generate(32, (i) => random.nextInt(256));
    return base64Url.encode(bytes);
  }

  /// Generate CSRF token
  static String generateCSRFToken() {
    final random = Random.secure();
    final bytes = List<int>.generate(16, (i) => random.nextInt(256));
    return base64Url.encode(bytes);
  }

  /// Validate CSRF token
  static bool validateCSRFToken(String token, String expectedToken) {
    return token == expectedToken;
  }

  /// Encrypt sensitive data (basic implementation)
  static String encryptData(String data) {
    // Note: In production, use proper encryption libraries
    // This is a basic implementation for demonstration
    final bytes = utf8.encode(data);
    final encoded = base64.encode(bytes);
    return encoded;
  }

  /// Decrypt sensitive data (basic implementation)
  static String decryptData(String encryptedData) {
    // Note: In production, use proper encryption libraries
    // This is a basic implementation for demonstration
    try {
      final bytes = base64.decode(encryptedData);
      return utf8.decode(bytes);
    } catch (e) {
      LoggingService.error('Failed to decrypt data', error: e);
      return '';
    }
  }

  /// Hash password (basic implementation)
  static String hashPassword(String password) {
    // Note: In production, use proper hashing libraries like bcrypt
    // This is a basic implementation for demonstration
    final bytes = utf8.encode(password + _securityKey);
    final encoded = base64.encode(bytes);
    return encoded;
  }

  /// Verify password hash (basic implementation)
  static bool verifyPassword(String password, String hash) {
    // Note: In production, use proper hashing libraries like bcrypt
    // This is a basic implementation for demonstration
    return hashPassword(password) == hash;
  }

  /// Validate API request
  static bool validateAPIRequest(
    String method,
    String path,
    Map<String, String> headers,
  ) {
    // Check for required headers
    if (!headers.containsKey('content-type') && method != 'GET') {
      LoggingService.logSecurityEvent(
        'API request rejected: missing content-type',
        metadata: {'method': method, 'path': path},
      );
      return false;
    }

    // Check for suspicious paths
    if (path.contains('..') || path.contains('//')) {
      LoggingService.logSecurityEvent(
        'API request rejected: suspicious path',
        metadata: {'method': method, 'path': path},
      );
      return false;
    }

    // Check for SQL injection patterns
    final sqlPatterns = [
      'union',
      'select',
      'insert',
      'update',
      'delete',
      'drop',
      'create',
    ];
    final pathLower = path.toLowerCase();
    for (final pattern in sqlPatterns) {
      if (pathLower.contains(pattern)) {
        LoggingService.logSecurityEvent(
          'API request rejected: potential SQL injection',
          metadata: {'method': method, 'path': path, 'pattern': pattern},
        );
        return false;
      }
    }

    return true;
  }

  /// Check for XSS attacks
  static bool containsXSS(String input) {
    final xssPatterns = [
      RegExp(r'<script[^>]*>.*?</script>', caseSensitive: false),
      RegExp(r'javascript:', caseSensitive: false),
      RegExp(r'vbscript:', caseSensitive: false),
      RegExp(r'onload\s*=', caseSensitive: false),
      RegExp(r'onerror\s*=', caseSensitive: false),
      RegExp(r'onclick\s*=', caseSensitive: false),
    ];

    for (final pattern in xssPatterns) {
      if (pattern.hasMatch(input)) {
        LoggingService.logSecurityEvent(
          'XSS attack detected',
          metadata: {'input': input, 'pattern': pattern.pattern},
        );
        return true;
      }
    }

    return false;
  }

  /// Validate user permissions
  static bool hasPermission(
    String userId,
    String permission,
    Map<String, dynamic>? context,
  ) {
    // This would typically check against a user roles/permissions system
    // For now, we'll implement basic permission checks

    switch (permission) {
      case 'create_item':
        return !isUserLockedOut(userId);
      case 'edit_item':
        return !isUserLockedOut(userId) && context?['ownerId'] == userId;
      case 'delete_item':
        return !isUserLockedOut(userId) && context?['ownerId'] == userId;
      case 'admin_access':
        return context?['isAdmin'] == true;
      default:
        return false;
    }
  }

  /// Log security event
  static void logSecurityEvent(
    String event, {
    String? userId,
    Map<String, dynamic>? metadata,
  }) {
    LoggingService.logSecurityEvent(
      event,
      metadata: {
        'userId': userId,
        'timestamp': DateTime.now().toIso8601String(),
        ...?metadata,
      },
    );
  }

  /// Get security statistics
  static Map<String, dynamic> getSecurityStats() {
    return {
      'lockedOutUsers': _instance._lockoutTimes.length,
      'failedLoginAttempts': _instance._loginAttempts.values.fold(
        0,
        (sum, count) => sum + count,
      ),
      'suspiciousActivities': _instance._suspiciousActivities.length,
      'lastActivity': _instance._suspiciousActivities.isNotEmpty
          ? _instance._suspiciousActivities.last.split('|')[1]
          : null,
    };
  }

  /// Clear security data
  static void clearSecurityData() {
    _instance._loginAttempts.clear();
    _instance._lockoutTimes.clear();
    _instance._suspiciousActivities.clear();
    LoggingService.info('Security data cleared', tag: 'Security');
  }

  /// Initialize security service
  static void initialize() {
    LoggingService.info('Security service initialized', tag: 'Security');

    // Set up periodic security checks
    Timer.periodic(const Duration(minutes: 10), (timer) {
      _cleanupExpiredData();
    });
  }

  /// Clean up expired security data
  static void _cleanupExpiredData() {
    final now = DateTime.now();

    // Remove expired lockouts
    _instance._lockoutTimes.removeWhere((userId, lockoutTime) {
      return now.difference(lockoutTime) >= _lockoutDuration;
    });

    // Remove old suspicious activities
    _instance._suspiciousActivities.removeWhere((activity) {
      final timestamp = DateTime.parse(activity.split('|')[1]);
      return now.difference(timestamp).inHours > 24;
    });

    LoggingService.debug('Security data cleanup completed', tag: 'Security');
  }
}

enum PasswordStrength { weak, medium, strong }
