/// @Branch: Network Loading Widget
///
/// Animated loading widget that shows different states based on network connectivity
/// Similar to Instagram, WhatsApp loading animations
library;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../core/services/network_service.dart';
import '../../core/theme/app_spacing.dart';

class NetworkLoadingWidget extends StatefulWidget {
  final String? message;
  final bool showRetryButton;
  final VoidCallback? onRetry;
  final double size;
  final Color? color;

  const NetworkLoadingWidget({
    super.key,
    this.message,
    this.showRetryButton = true,
    this.onRetry,
    this.size = 50.0,
    this.color,
  });

  @override
  State<NetworkLoadingWidget> createState() => _NetworkLoadingWidgetState();
}

class _NetworkLoadingWidgetState extends State<NetworkLoadingWidget>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _rotationController;
  late AnimationController _fadeController;

  bool _isRetrying = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat(reverse: true);

    _rotationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    )..forward();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _rotationController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _handleRetry() async {
    if (_isRetrying) return;

    setState(() {
      _isRetrying = true;
    });

    final networkService = context.read<NetworkService>();
    final success = await networkService.retryConnection();

    if (mounted) {
      setState(() {
        _isRetrying = false;
      });

      if (success && widget.onRetry != null) {
        widget.onRetry!();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<NetworkService>(
      builder: (context, networkService, child) {
        return FadeTransition(
          opacity: _fadeController,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLoadingAnimation(networkService),
              const SizedBox(height: AppSpacing.lg),
              _buildStatusMessage(networkService),
              if (widget.showRetryButton && networkService.isDisconnected) ...[
                const SizedBox(height: AppSpacing.lg),
                _buildRetryButton(networkService),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildLoadingAnimation(NetworkService networkService) {
    return AnimatedBuilder(
      animation: Listenable.merge([_pulseController, _rotationController]),
      builder: (context, child) {
        return Transform.scale(
          scale: networkService.isCheckingConnection
              ? 1.0 + (_pulseController.value * 0.3)
              : 1.0,
          child: Transform.rotate(
            angle: networkService.isCheckingConnection
                ? _rotationController.value * 2 * 3.14159
                : 0,
            child: Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    (widget.color ?? Theme.of(context).primaryColor)
                        .withOpacity(0.3),
                    (widget.color ?? Theme.of(context).primaryColor)
                        .withOpacity(0.1),
                  ],
                ),
              ),
              child: Center(
                child: Icon(
                  _getStatusIcon(networkService.status),
                  size: widget.size * 0.5,
                  color: widget.color ?? Theme.of(context).primaryColor,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusMessage(NetworkService networkService) {
    return Column(
      children: [
        Text(
          _getStatusTitle(networkService.status),
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: widget.color ?? Theme.of(context).primaryColor,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          widget.message ?? _getStatusMessage(networkService.status),
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(
              context,
            ).textTheme.bodyMedium?.color?.withOpacity(0.7),
          ),
          textAlign: TextAlign.center,
        ),
        if (networkService.isCheckingConnection) ...[
          const SizedBox(height: AppSpacing.md),
          _buildDotsAnimation(),
        ],
      ],
    );
  }

  Widget _buildDotsAnimation() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        return AnimatedBuilder(
          animation: _pulseController,
          builder: (context, child) {
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              child: Transform.scale(
                scale: _pulseController.value > (index * 0.33) ? 1.0 : 0.5,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: widget.color ?? Theme.of(context).primaryColor,
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }

  Widget _buildRetryButton(NetworkService networkService) {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return ElevatedButton.icon(
          onPressed: _isRetrying ? null : _handleRetry,
          icon: _isRetrying
              ? SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
                )
              : const Icon(Icons.refresh),
          label: Text(_isRetrying ? 'Retrying...' : 'Try Again'),
          style: ElevatedButton.styleFrom(
            backgroundColor: widget.color ?? Theme.of(context).primaryColor,
            foregroundColor: Theme.of(context).colorScheme.onPrimary,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
          ),
        );
      },
    );
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

  String _getStatusTitle(NetworkStatus status) {
    switch (status) {
      case NetworkStatus.connected:
        return 'Connected!';
      case NetworkStatus.disconnected:
        return 'No Internet';
      case NetworkStatus.unknown:
        return 'Checking...';
    }
  }

  String _getStatusMessage(NetworkStatus status) {
    switch (status) {
      case NetworkStatus.connected:
        return 'You\'re back online!';
      case NetworkStatus.disconnected:
        return 'Please check your internet connection and try again.';
      case NetworkStatus.unknown:
        return 'Checking your connection...';
    }
  }
}

/// Network-aware page with loading states
class NetworkAwarePage extends StatelessWidget {
  final Widget child;
  final bool showLoadingOnDisconnect;
  final String? loadingMessage;
  final VoidCallback? onRetry;

  const NetworkAwarePage({
    super.key,
    required this.child,
    this.showLoadingOnDisconnect = true,
    this.loadingMessage,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<NetworkService>(
      builder: (context, networkService, child) {
        if (showLoadingOnDisconnect && networkService.isDisconnected) {
          return Scaffold(
            body: Center(
              child: NetworkLoadingWidget(
                message: loadingMessage,
                onRetry: onRetry,
              ),
            ),
          );
        }

        return this.child;
      },
    );
  }
}




