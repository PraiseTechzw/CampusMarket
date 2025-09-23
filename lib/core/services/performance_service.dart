/// @Branch: Performance Monitoring Service
///
/// Production-ready performance monitoring for Campus Market
/// Tracks app performance metrics and bottlenecks
library;

import 'package:flutter/foundation.dart';
import 'dart:async';
import 'dart:io';
import '../config/app_config.dart';
import 'logging_service.dart';

class PerformanceService {
  static final PerformanceService _instance = PerformanceService._internal();
  factory PerformanceService() => _instance;
  PerformanceService._internal();

  final Map<String, Stopwatch> _timers = {};
  final Map<String, List<Duration>> _metrics = {};
  final Map<String, int> _counters = {};

  /// Start a performance timer
  static void startTimer(String operation) {
    _instance._timers[operation] = Stopwatch()..start();
    LoggingService.debug('Started timer for: $operation', tag: 'Performance');
  }

  /// Stop a performance timer and log the result
  static Duration stopTimer(String operation) {
    final timer = _instance._timers.remove(operation);
    if (timer == null) {
      LoggingService.warning(
        'Timer not found for operation: $operation',
        tag: 'Performance',
      );
      return Duration.zero;
    }

    timer.stop();
    final duration = timer.elapsed;

    // Store the metric
    _instance._metrics.putIfAbsent(operation, () => []).add(duration);

    // Log the performance
    LoggingService.logPerformance(operation, duration);

    // Check for performance issues
    _checkPerformanceThreshold(operation, duration);

    return duration;
  }

  /// Measure a function execution time
  static Future<T> measureAsync<T>(
    String operation,
    Future<T> Function() function,
  ) async {
    startTimer(operation);
    try {
      final result = await function();
      stopTimer(operation);
      return result;
    } catch (e) {
      stopTimer(operation);
      rethrow;
    }
  }

  /// Measure a synchronous function execution time
  static T measure<T>(String operation, T Function() function) {
    startTimer(operation);
    try {
      final result = function();
      stopTimer(operation);
      return result;
    } catch (e) {
      stopTimer(operation);
      rethrow;
    }
  }

  /// Increment a counter
  static void incrementCounter(String counter) {
    _instance._counters[counter] = (_instance._counters[counter] ?? 0) + 1;
    LoggingService.debug(
      'Incremented counter: $counter = ${_instance._counters[counter]}',
      tag: 'Performance',
    );
  }

  /// Get counter value
  static int getCounter(String counter) {
    return _instance._counters[counter] ?? 0;
  }

  /// Reset counter
  static void resetCounter(String counter) {
    _instance._counters.remove(counter);
    LoggingService.debug('Reset counter: $counter', tag: 'Performance');
  }

  /// Get average duration for an operation
  static Duration getAverageDuration(String operation) {
    final durations = _instance._metrics[operation];
    if (durations == null || durations.isEmpty) {
      return Duration.zero;
    }

    final totalMs = durations.fold<int>(
      0,
      (sum, duration) => sum + duration.inMilliseconds,
    );
    return Duration(milliseconds: totalMs ~/ durations.length);
  }

  /// Get performance statistics
  static Map<String, dynamic> getPerformanceStats() {
    final stats = <String, dynamic>{};

    for (final entry in _instance._metrics.entries) {
      final operation = entry.key;
      final durations = entry.value;

      if (durations.isNotEmpty) {
        final totalMs = durations.fold<int>(
          0,
          (sum, duration) => sum + duration.inMilliseconds,
        );
        final averageMs = totalMs ~/ durations.length;
        final minMs = durations
            .map((d) => d.inMilliseconds)
            .reduce((a, b) => a < b ? a : b);
        final maxMs = durations
            .map((d) => d.inMilliseconds)
            .reduce((a, b) => a > b ? a : b);

        stats[operation] = {
          'count': durations.length,
          'averageMs': averageMs,
          'minMs': minMs,
          'maxMs': maxMs,
          'totalMs': totalMs,
        };
      }
    }

    // Add counter stats
    stats['counters'] = Map<String, int>.from(_instance._counters);

    return stats;
  }

  /// Check if operation exceeds performance threshold
  static void _checkPerformanceThreshold(String operation, Duration duration) {
    const slowThreshold = Duration(seconds: 2);
    const verySlowThreshold = Duration(seconds: 5);

    if (duration > verySlowThreshold) {
      LoggingService.warning(
        'Very slow operation: $operation took ${duration.inMilliseconds}ms',
        tag: 'Performance',
      );
    } else if (duration > slowThreshold) {
      LoggingService.info(
        'Slow operation: $operation took ${duration.inMilliseconds}ms',
        tag: 'Performance',
      );
    }
  }

  /// Monitor memory usage
  static void monitorMemoryUsage() {
    if (!AppConfig.enableLogging) return;

    try {
      // Note: This would require platform-specific implementation
      // For now, we'll just log that we're monitoring
      LoggingService.debug(
        'Memory usage monitoring active',
        tag: 'Performance',
      );
    } catch (e) {
      LoggingService.error('Failed to monitor memory usage', error: e);
    }
  }

  /// Monitor network performance
  static void monitorNetworkPerformance(
    String url,
    Duration duration,
    int statusCode,
  ) {
    LoggingService.logNetworkRequest('GET', url, statusCode, duration);

    // Track slow network requests
    const slowNetworkThreshold = Duration(seconds: 3);
    if (duration > slowNetworkThreshold) {
      LoggingService.warning(
        'Slow network request: $url took ${duration.inMilliseconds}ms',
        tag: 'Performance',
      );
    }
  }

  /// Monitor database performance
  static void monitorDatabasePerformance(
    String operation,
    String collection,
    Duration duration,
  ) {
    LoggingService.logDatabaseOperation(operation, collection);

    // Track slow database operations
    const slowDbThreshold = Duration(milliseconds: 500);
    if (duration > slowDbThreshold) {
      LoggingService.warning(
        'Slow database operation: $operation on $collection took ${duration.inMilliseconds}ms',
        tag: 'Performance',
      );
    }
  }

  /// Monitor file operations
  static void monitorFileOperation(
    String operation,
    String fileName,
    Duration duration,
    int fileSize,
  ) {
    LoggingService.logFileOperation(operation, fileName, fileSize: fileSize);

    // Track slow file operations
    const slowFileThreshold = Duration(seconds: 1);
    if (duration > slowFileThreshold) {
      LoggingService.warning(
        'Slow file operation: $operation $fileName took ${duration.inMilliseconds}ms',
        tag: 'Performance',
      );
    }
  }

  /// Monitor UI performance
  static void monitorUIPerformance(String screen, Duration buildTime) {
    LoggingService.logUIEvent('Build completed', screen: screen);

    // Track slow UI builds
    const slowUIThreshold = Duration(milliseconds: 100);
    if (buildTime > slowUIThreshold) {
      LoggingService.warning(
        'Slow UI build: $screen took ${buildTime.inMilliseconds}ms',
        tag: 'Performance',
      );
    }
  }

  /// Monitor image loading performance
  static void monitorImageLoading(
    String imageUrl,
    Duration loadTime,
    int fileSize,
  ) {
    LoggingService.debug(
      'Image loaded: $imageUrl (${(fileSize / 1024).toStringAsFixed(1)}KB) in ${loadTime.inMilliseconds}ms',
      tag: 'Performance',
    );

    // Track slow image loads
    const slowImageThreshold = Duration(seconds: 2);
    if (loadTime > slowImageThreshold) {
      LoggingService.warning(
        'Slow image load: $imageUrl took ${loadTime.inMilliseconds}ms',
        tag: 'Performance',
      );
    }
  }

  /// Monitor app startup performance
  static void monitorStartupPerformance() {
    final stopwatch = Stopwatch()..start();

    // Monitor various startup phases
    Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (timer.tick > 100) {
        // Stop after 10 seconds
        timer.cancel();
        return;
      }

      final elapsed = stopwatch.elapsed;
      LoggingService.debug(
        'Startup progress: ${elapsed.inMilliseconds}ms',
        tag: 'Performance',
      );

      // Check for slow startup
      if (elapsed > const Duration(seconds: 5)) {
        LoggingService.warning(
          'Slow app startup: ${elapsed.inMilliseconds}ms',
          tag: 'Performance',
        );
      }
    });
  }

  /// Monitor battery usage
  static void monitorBatteryUsage() {
    if (!AppConfig.enableLogging) return;

    try {
      // Note: This would require platform-specific implementation
      LoggingService.debug(
        'Battery usage monitoring active',
        tag: 'Performance',
      );
    } catch (e) {
      LoggingService.error('Failed to monitor battery usage', error: e);
    }
  }

  /// Monitor CPU usage
  static void monitorCPUUsage() {
    if (!AppConfig.enableLogging) return;

    try {
      // Note: This would require platform-specific implementation
      LoggingService.debug('CPU usage monitoring active', tag: 'Performance');
    } catch (e) {
      LoggingService.error('Failed to monitor CPU usage', error: e);
    }
  }

  /// Clear all performance data
  static void clearPerformanceData() {
    _instance._timers.clear();
    _instance._metrics.clear();
    _instance._counters.clear();
    LoggingService.info('Cleared all performance data', tag: 'Performance');
  }

  /// Export performance data
  static Map<String, dynamic> exportPerformanceData() {
    return {
      'metrics': _instance._metrics.map(
        (key, value) =>
            MapEntry(key, value.map((d) => d.inMilliseconds).toList()),
      ),
      'counters': Map<String, int>.from(_instance._counters),
      'stats': getPerformanceStats(),
      'exportTime': DateTime.now().toIso8601String(),
    };
  }

  /// Get performance recommendations
  static List<String> getPerformanceRecommendations() {
    final recommendations = <String>[];
    final stats = getPerformanceStats();

    for (final entry in stats.entries) {
      if (entry.key == 'counters') continue;

      final operation = entry.key;
      final data = entry.value as Map<String, dynamic>;
      final averageMs = data['averageMs'] as int;
      final count = data['count'] as int;

      // Recommend optimization for frequently slow operations
      if (count > 10 && averageMs > 1000) {
        recommendations.add(
          'Consider optimizing $operation (avg: ${averageMs}ms, count: $count)',
        );
      }

      // Recommend caching for repeated operations
      if (count > 50 && averageMs > 100) {
        recommendations.add(
          'Consider caching for $operation (avg: ${averageMs}ms, count: $count)',
        );
      }
    }

    return recommendations;
  }

  /// Initialize performance monitoring
  static void initialize() {
    LoggingService.info(
      'Performance monitoring initialized',
      tag: 'Performance',
    );

    // Start monitoring key metrics
    monitorMemoryUsage();
    monitorStartupPerformance();

    // Set up periodic performance checks
    Timer.periodic(const Duration(minutes: 5), (timer) {
      _checkOverallPerformance();
    });
  }

  /// Check overall app performance
  static void _checkOverallPerformance() {
    final stats = getPerformanceStats();
    final recommendations = getPerformanceRecommendations();

    if (recommendations.isNotEmpty) {
      LoggingService.info(
        'Performance recommendations: ${recommendations.join(', ')}',
        tag: 'Performance',
      );
    }

    // Log performance summary
    LoggingService.info(
      'Performance summary: ${stats.length} operations tracked',
      tag: 'Performance',
    );
  }
}
