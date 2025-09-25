/// @Branch: Network Error Widget
///
/// Animated error widget for network-related issues
/// Similar to Instagram, WhatsApp error states
library;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../core/services/network_service.dart';
import '../../core/theme/app_spacing.dart';

class NetworkErrorWidget extends StatefulWidget {
  final String? title;
  final String? message;
  final String? buttonText;
  final VoidCallback? onRetry;
  final bool showIllustration;
  final Color? color;

  const NetworkErrorWidget({
    super.key,
    this.title,
    this.message,
    this.buttonText,
    this.onRetry,
    this.showIllustration = true,
    this.color,
  });

  @override
  State<NetworkErrorWidget> createState() => _NetworkErrorWidgetState();
}

class _NetworkErrorWidgetState extends State<NetworkErrorWidget>
    with TickerProviderStateMixin {
  late AnimationController _shakeController;
  late AnimationController _fadeController;
  late AnimationController _scaleController;

  bool _isRetrying = false;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    // Start animations
    _fadeController.forward();
    _scaleController.forward();
  }

  @override
  void dispose() {
    _shakeController.dispose();
    _fadeController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  Future<void> _handleRetry() async {
    if (_isRetrying) return;

    setState(() {
      _isRetrying = true;
    });

    // Shake animation on retry
    _shakeController.forward().then((_) {
      _shakeController.reverse();
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
          child: ScaleTransition(
            scale: _scaleController,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (widget.showIllustration) ...[
                      _buildIllustration(networkService),
                      const SizedBox(height: AppSpacing.xl),
                    ],
                    _buildContent(networkService),
                    const SizedBox(height: AppSpacing.xl),
                    _buildRetryButton(networkService),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildIllustration(NetworkService networkService) {
    return AnimatedBuilder(
      animation: _shakeController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(_shakeController.value * 10, 0),
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  (widget.color ?? Theme.of(context).colorScheme.error)
                      .withOpacity(0.1),
                  (widget.color ?? Theme.of(context).colorScheme.error)
                      .withOpacity(0.05),
                ],
              ),
            ),
            child: Center(
              child: Icon(
                _getErrorIcon(networkService.status),
                size: 60,
                color: widget.color ?? Theme.of(context).colorScheme.error,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildContent(NetworkService networkService) {
    return Column(
      children: [
        Text(
          widget.title ?? _getErrorTitle(networkService.status),
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: widget.color ?? Theme.of(context).colorScheme.error,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          widget.message ?? _getErrorMessage(networkService.status),
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: Theme.of(
              context,
            ).textTheme.bodyLarge?.color?.withOpacity(0.7),
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
        if (networkService.isCheckingConnection) ...[
          const SizedBox(height: AppSpacing.lg),
          _buildCheckingIndicator(),
        ],
      ],
    );
  }

  Widget _buildCheckingIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(
              widget.color ?? Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Text(
          'Checking connection...',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(
              context,
            ).textTheme.bodyMedium?.color?.withOpacity(0.6),
          ),
        ),
      ],
    );
  }

  Widget _buildRetryButton(NetworkService networkService) {
    return AnimatedBuilder(
      animation: _scaleController,
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
          label: Text(
            _isRetrying ? 'Retrying...' : (widget.buttonText ?? 'Try Again'),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor:
                widget.color ?? Theme.of(context).colorScheme.error,
            foregroundColor: Theme.of(context).colorScheme.onError,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xl,
              vertical: AppSpacing.md,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
            elevation: 2,
          ),
        );
      },
    );
  }

  IconData _getErrorIcon(NetworkStatus status) {
    switch (status) {
      case NetworkStatus.connected:
        return Icons.wifi;
      case NetworkStatus.disconnected:
        return Icons.wifi_off;
      case NetworkStatus.unknown:
        return Icons.wifi_find;
    }
  }

  String _getErrorTitle(NetworkStatus status) {
    switch (status) {
      case NetworkStatus.connected:
        return 'Connection Restored';
      case NetworkStatus.disconnected:
        return 'No Internet Connection';
      case NetworkStatus.unknown:
        return 'Connection Problem';
    }
  }

  String _getErrorMessage(NetworkStatus status) {
    switch (status) {
      case NetworkStatus.connected:
        return 'Your internet connection has been restored.';
      case NetworkStatus.disconnected:
        return 'Please check your internet connection and try again. Make sure you\'re connected to WiFi or mobile data.';
      case NetworkStatus.unknown:
        return 'We\'re having trouble checking your connection. Please try again.';
    }
  }
}

/// Network error page wrapper
class NetworkErrorPage extends StatelessWidget {
  final String? title;
  final String? message;
  final String? buttonText;
  final VoidCallback? onRetry;
  final bool showIllustration;

  const NetworkErrorPage({
    super.key,
    this.title,
    this.message,
    this.buttonText,
    this.onRetry,
    this.showIllustration = true,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NetworkErrorWidget(
        title: title,
        message: message,
        buttonText: buttonText,
        onRetry: onRetry,
        showIllustration: showIllustration,
      ),
    );
  }
}






