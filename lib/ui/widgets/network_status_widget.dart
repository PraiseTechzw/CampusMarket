/// @Branch: Network Status Widget
///
/// Animated network status indicator similar to big apps
/// Shows connection status with smooth animations and retry options
library;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../core/services/network_service.dart';
import '../../core/theme/app_spacing.dart';

class NetworkStatusWidget extends StatefulWidget {
  final bool showRetryButton;
  final bool showConnectionType;
  final VoidCallback? onRetry;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;

  const NetworkStatusWidget({
    super.key,
    this.showRetryButton = true,
    this.showConnectionType = false,
    this.onRetry,
    this.margin,
    this.padding,
  });

  @override
  State<NetworkStatusWidget> createState() => _NetworkStatusWidgetState();
}

class _NetworkStatusWidgetState extends State<NetworkStatusWidget>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _slideController;
  late AnimationController _retryController;

  bool _isRetrying = false;
  String _connectionType = '';

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _retryController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _updateConnectionType();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _slideController.dispose();
    _retryController.dispose();
    super.dispose();
  }

  Future<void> _updateConnectionType() async {
    final networkService = context.read<NetworkService>();
    final type = await networkService.getConnectionType();
    if (mounted) {
      setState(() {
        _connectionType = type;
      });
    }
  }

  Future<void> _handleRetry() async {
    if (_isRetrying) return;

    setState(() {
      _isRetrying = true;
    });

    _retryController.forward();

    final networkService = context.read<NetworkService>();
    final success = await networkService.retryConnection();

    if (mounted) {
      setState(() {
        _isRetrying = false;
      });

      _retryController.reverse();

      if (success) {
        _updateConnectionType();
        if (widget.onRetry != null) {
          widget.onRetry!();
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<NetworkService>(
      builder: (context, networkService, child) {
        // Only show widget when disconnected or checking
        if (networkService.isConnected) {
          return const SizedBox.shrink();
        }

        return AnimatedBuilder(
          animation: _slideController,
          builder: (context, child) {
            return SlideTransition(
              position:
                  Tween<Offset>(
                    begin: const Offset(0, -1),
                    end: Offset.zero,
                  ).animate(
                    CurvedAnimation(
                      parent: _slideController,
                      curve: Curves.easeOutBack,
                    ),
                  ),
              child: Container(
                margin: widget.margin ?? const EdgeInsets.all(AppSpacing.sm),
                padding:
                    widget.padding ??
                    const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm,
                    ),
                decoration: BoxDecoration(
                  color: _getStatusColor(networkService.status),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: _getStatusColor(
                        networkService.status,
                      ).withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    _buildStatusIcon(networkService),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(child: _buildStatusText(networkService)),
                    if (widget.showRetryButton && networkService.isDisconnected)
                      _buildRetryButton(networkService),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildStatusIcon(NetworkService networkService) {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return Transform.scale(
          scale: networkService.isCheckingConnection
              ? 1.0 + (_pulseController.value * 0.2)
              : 1.0,
          child: Icon(
            _getStatusIcon(networkService.status),
            color: Colors.white,
            size: 20,
          ),
        );
      },
    );
  }

  Widget _buildStatusText(NetworkService networkService) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          _getStatusMessage(networkService.status),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        if (widget.showConnectionType && _connectionType.isNotEmpty) ...[
          const SizedBox(height: 2),
          Text(
            'Connection: $_connectionType',
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ],
      ],
    );
  }

  Widget _buildRetryButton(NetworkService networkService) {
    return AnimatedBuilder(
      animation: _retryController,
      builder: (context, child) {
        return GestureDetector(
          onTap: _isRetrying ? null : _handleRetry,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: _isRetrying
                ? SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Colors.white.withOpacity(0.8),
                      ),
                    ),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.refresh, color: Colors.white, size: 16),
                      const SizedBox(width: 4),
                      const Text(
                        'Retry',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
          ),
        );
      },
    );
  }

  Color _getStatusColor(NetworkStatus status) {
    switch (status) {
      case NetworkStatus.connected:
        return Colors.green;
      case NetworkStatus.disconnected:
        return Colors.red;
      case NetworkStatus.unknown:
        return Colors.orange;
    }
  }

  IconData _getStatusIcon(NetworkStatus status) {
    switch (status) {
      case NetworkStatus.connected:
        return Icons.wifi;
      case NetworkStatus.disconnected:
        return Icons.wifi_off;
      case NetworkStatus.unknown:
        return Icons.wifi_find;
    }
  }

  String _getStatusMessage(NetworkStatus status) {
    switch (status) {
      case NetworkStatus.connected:
        return 'Connected';
      case NetworkStatus.disconnected:
        return 'No Internet Connection';
      case NetworkStatus.unknown:
        return 'Checking Connection...';
    }
  }
}

/// Full-screen network status overlay
class NetworkStatusOverlay extends StatelessWidget {
  final Widget child;
  final bool showOverlay;

  const NetworkStatusOverlay({
    super.key,
    required this.child,
    this.showOverlay = true,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (showOverlay)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: NetworkStatusWidget(
              showRetryButton: true,
              showConnectionType: true,
              margin: EdgeInsets.zero,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.md,
              ),
            ),
          ),
      ],
    );
  }
}

/// Network-aware scaffold that shows network status
class NetworkAwareScaffold extends StatelessWidget {
  final Widget body;
  final PreferredSizeWidget? appBar;
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;
  final bool showNetworkStatus;

  const NetworkAwareScaffold({
    super.key,
    required this.body,
    this.appBar,
    this.bottomNavigationBar,
    this.floatingActionButton,
    this.showNetworkStatus = true,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar,
      body: showNetworkStatus ? NetworkStatusOverlay(child: body) : body,
      bottomNavigationBar: bottomNavigationBar,
      floatingActionButton: floatingActionButton,
    );
  }
}




