/// @Branch: Network Connectivity Service
///
/// Handles network connectivity detection and provides real-time status updates
/// Similar to big apps like Instagram, WhatsApp, etc.
library;

import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

enum NetworkStatus { connected, disconnected, unknown }

class NetworkService extends ChangeNotifier {
  static final NetworkService _instance = NetworkService._internal();
  factory NetworkService() => _instance;
  NetworkService._internal();

  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  NetworkStatus _status = NetworkStatus.unknown;
  bool _isCheckingConnection = false;
  Timer? _connectionCheckTimer;

  // Getters
  NetworkStatus get status => _status;
  bool get isConnected => _status == NetworkStatus.connected;
  bool get isDisconnected => _status == NetworkStatus.disconnected;
  bool get isCheckingConnection => _isCheckingConnection;

  /// Initialize network monitoring
  Future<void> initialize() async {
    try {
      // Get initial connectivity status
      await _checkInitialConnectivity();

      // Listen to connectivity changes
      _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
        _onConnectivityChanged,
        onError: (Object error) {
          debugPrint('Connectivity error: $error');
          _updateStatus(NetworkStatus.unknown);
        },
      );

      // Start periodic connection checks
      _startPeriodicConnectionCheck();

      debugPrint('NetworkService initialized');
    } catch (e) {
      debugPrint('Failed to initialize NetworkService: $e');
    }
  }

  /// Check initial connectivity status
  Future<void> _checkInitialConnectivity() async {
    _isCheckingConnection = true;
    notifyListeners();

    try {
      final connectivityResults = await _connectivity.checkConnectivity();
      await _updateConnectivityStatus(connectivityResults);
    } catch (e) {
      debugPrint('Error checking initial connectivity: $e');
      _updateStatus(NetworkStatus.unknown);
    } finally {
      _isCheckingConnection = false;
      notifyListeners();
    }
  }

  /// Handle connectivity changes
  Future<void> _onConnectivityChanged(List<ConnectivityResult> results) async {
    debugPrint('Connectivity changed: $results');
    await _updateConnectivityStatus(results);
  }

  /// Update connectivity status based on results
  Future<void> _updateConnectivityStatus(
    List<ConnectivityResult> results,
  ) async {
    _isCheckingConnection = true;
    notifyListeners();

    try {
      // Check if any connectivity result indicates connection
      bool hasConnection = results.any(
        (result) =>
            result == ConnectivityResult.mobile ||
            result == ConnectivityResult.wifi ||
            result == ConnectivityResult.ethernet ||
            result == ConnectivityResult.vpn,
      );

      if (hasConnection) {
        if (kIsWeb) {
          // For web platforms, trust the connectivity result initially
          // and only verify internet if there are issues
          _updateStatus(NetworkStatus.connected);

          // Do a background check without blocking the UI
          _hasInternetConnection().then((hasInternet) {
            if (!hasInternet) {
              _updateStatus(NetworkStatus.disconnected);
            }
          });
        } else {
          // For mobile/desktop platforms, verify actual internet connectivity
          final hasInternet = await _hasInternetConnection();
          _updateStatus(
            hasInternet ? NetworkStatus.connected : NetworkStatus.disconnected,
          );
        }
      } else {
        _updateStatus(NetworkStatus.disconnected);
      }
    } catch (e) {
      debugPrint('Error updating connectivity status: $e');
      _updateStatus(NetworkStatus.unknown);
    } finally {
      _isCheckingConnection = false;
      notifyListeners();
    }
  }

  /// Check if device has actual internet connection
  Future<bool> _hasInternetConnection() async {
    try {
      if (kIsWeb) {
        // For web platforms, use a simple HTTP request to a reliable endpoint
        try {
          final response = await http
              .get(Uri.parse('https://www.google.com'))
              .timeout(const Duration(seconds: 3));
          return response.statusCode == 200;
        } catch (e) {
          // Fallback to a different endpoint if Google is blocked
          try {
            final response = await http
                .get(Uri.parse('https://httpbin.org/status/200'))
                .timeout(const Duration(seconds: 3));
            return response.statusCode == 200;
          } catch (e2) {
            debugPrint('Both connectivity checks failed: $e, $e2');
            return false;
          }
        }
      } else {
        // For mobile/desktop platforms, use DNS lookup
        final result = await InternetAddress.lookup(
          'google.com',
        ).timeout(const Duration(seconds: 5));
        return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
      }
    } catch (e) {
      debugPrint('Internet connection check failed: $e');
      return false;
    }
  }

  /// Update network status and notify listeners
  void _updateStatus(NetworkStatus newStatus) {
    if (_status != newStatus) {
      final previousStatus = _status;
      _status = newStatus;

      debugPrint('Network status changed: $previousStatus -> $newStatus');
      notifyListeners();
    }
  }

  /// Start periodic connection checks
  void _startPeriodicConnectionCheck() {
    _connectionCheckTimer?.cancel();
    _connectionCheckTimer = Timer.periodic(
      const Duration(seconds: 30), // Check every 30 seconds
      (_) async {
        if (!_isCheckingConnection) {
          await _checkInitialConnectivity();
        }
      },
    );
  }

  /// Manually check connection
  Future<bool> checkConnection() async {
    await _checkInitialConnectivity();
    return isConnected;
  }

  /// Retry connection with exponential backoff
  Future<bool> retryConnection({
    int maxRetries = 3,
    Duration initialDelay = const Duration(seconds: 1),
  }) async {
    for (int attempt = 0; attempt < maxRetries; attempt++) {
      debugPrint('Retry attempt ${attempt + 1}/$maxRetries');

      final isConnected = await checkConnection();
      if (isConnected) {
        debugPrint('Connection restored on attempt ${attempt + 1}');
        return true;
      }

      if (attempt < maxRetries - 1) {
        final delay = Duration(
          milliseconds: initialDelay.inMilliseconds * (1 << attempt),
        );
        debugPrint('Waiting ${delay.inSeconds}s before next retry...');
        await Future<void>.delayed(delay);
      }
    }

    debugPrint('All retry attempts failed');
    return false;
  }

  /// Get connection quality indicator
  String get connectionQuality {
    switch (_status) {
      case NetworkStatus.connected:
        return 'Good';
      case NetworkStatus.disconnected:
        return 'No Connection';
      case NetworkStatus.unknown:
        return 'Checking...';
    }
  }

  /// Get connection type
  Future<String> getConnectionType() async {
    try {
      final results = await _connectivity.checkConnectivity();
      if (results.contains(ConnectivityResult.wifi)) {
        return 'WiFi';
      } else if (results.contains(ConnectivityResult.mobile)) {
        return 'Mobile Data';
      } else if (results.contains(ConnectivityResult.ethernet)) {
        return 'Ethernet';
      } else if (results.contains(ConnectivityResult.vpn)) {
        return 'VPN';
      } else {
        return 'Unknown';
      }
    } catch (e) {
      return 'Unknown';
    }
  }

  /// Dispose resources
  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    _connectionCheckTimer?.cancel();
    super.dispose();
  }
}
