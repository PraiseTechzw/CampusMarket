/// @Branch: Network Aware App Wrapper
///
/// Wraps the entire app with network status monitoring
/// Similar to big apps like Instagram, WhatsApp
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/services/network_service.dart';
import 'network_status_widget.dart';
import 'network_loading_widget.dart';
import 'network_error_widget.dart';

class NetworkAwareApp extends StatelessWidget {
  final Widget child;
  final bool showNetworkStatus;
  final bool showLoadingOnDisconnect;
  final bool showErrorOnDisconnect;

  const NetworkAwareApp({
    super.key,
    required this.child,
    this.showNetworkStatus = true,
    this.showLoadingOnDisconnect = false,
    this.showErrorOnDisconnect = false,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<NetworkService>(
      builder: (context, networkService, child) {
        // Show loading screen if disconnected and loading is enabled
        if (showLoadingOnDisconnect && networkService.isDisconnected) {
          return MaterialApp(
            home: Scaffold(
              body: NetworkLoadingWidget(
                message: 'Please check your internet connection',
              ),
            ),
          );
        }

        // Show error screen if disconnected and error is enabled
        if (showErrorOnDisconnect && networkService.isDisconnected) {
          return MaterialApp(
            home: Scaffold(
              body: NetworkErrorWidget(
                title: 'No Internet Connection',
                message: 'Please check your internet connection and try again.',
              ),
            ),
          );
        }

        // Show normal app with network status overlay
        return this.child;
      },
    );
  }
}

/// Network-aware page wrapper
class NetworkAwarePageWrapper extends StatelessWidget {
  final Widget child;
  final bool showNetworkStatus;
  final bool showLoadingOnDisconnect;
  final bool showErrorOnDisconnect;
  final String? loadingMessage;
  final String? errorMessage;
  final VoidCallback? onRetry;

  const NetworkAwarePageWrapper({
    super.key,
    required this.child,
    this.showNetworkStatus = true,
    this.showLoadingOnDisconnect = false,
    this.showErrorOnDisconnect = false,
    this.loadingMessage,
    this.errorMessage,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<NetworkService>(
      builder: (context, networkService, child) {
        // Show loading screen if disconnected and loading is enabled
        if (showLoadingOnDisconnect && networkService.isDisconnected) {
          return Scaffold(
            body: Center(
              child: NetworkLoadingWidget(
                message:
                    loadingMessage ?? 'Please check your internet connection',
                onRetry: onRetry,
              ),
            ),
          );
        }

        // Show error screen if disconnected and error is enabled
        if (showErrorOnDisconnect && networkService.isDisconnected) {
          return Scaffold(
            body: Center(
              child: NetworkErrorWidget(
                title: 'No Internet Connection',
                message:
                    errorMessage ??
                    'Please check your internet connection and try again.',
                onRetry: onRetry,
              ),
            ),
          );
        }

        // Show normal page with network status overlay
        return Stack(
          children: [
            this.child,
            if (showNetworkStatus)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: NetworkStatusWidget(
                  showRetryButton: true,
                  showConnectionType: false,
                  margin: EdgeInsets.zero,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

/// Network-aware list view with retry functionality
class NetworkAwareListView extends StatelessWidget {
  final List<Widget> children;
  final ScrollController? controller;
  final EdgeInsetsGeometry? padding;
  final bool showNetworkStatus;
  final VoidCallback? onRetry;

  const NetworkAwareListView({
    super.key,
    required this.children,
    this.controller,
    this.padding,
    this.showNetworkStatus = true,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<NetworkService>(
      builder: (context, networkService, child) {
        if (networkService.isDisconnected) {
          return Center(
            child: NetworkErrorWidget(
              title: 'No Internet Connection',
              message: 'Please check your internet connection to load content.',
              onRetry: onRetry,
            ),
          );
        }

        return Stack(
          children: [
            ListView(
              controller: controller,
              padding: padding,
              children: children,
            ),
            if (showNetworkStatus)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: NetworkStatusWidget(
                  showRetryButton: true,
                  showConnectionType: false,
                  margin: EdgeInsets.zero,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

/// Network-aware grid view with retry functionality
class NetworkAwareGridView extends StatelessWidget {
  final List<Widget> children;
  final int crossAxisCount;
  final double childAspectRatio;
  final double crossAxisSpacing;
  final double mainAxisSpacing;
  final EdgeInsetsGeometry? padding;
  final bool showNetworkStatus;
  final VoidCallback? onRetry;

  const NetworkAwareGridView({
    super.key,
    required this.children,
    this.crossAxisCount = 2,
    this.childAspectRatio = 1.0,
    this.crossAxisSpacing = 8.0,
    this.mainAxisSpacing = 8.0,
    this.padding,
    this.showNetworkStatus = true,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<NetworkService>(
      builder: (context, networkService, child) {
        if (networkService.isDisconnected) {
          return Center(
            child: NetworkErrorWidget(
              title: 'No Internet Connection',
              message: 'Please check your internet connection to load content.',
              onRetry: onRetry,
            ),
          );
        }

        return Stack(
          children: [
            GridView.count(
              crossAxisCount: crossAxisCount,
              childAspectRatio: childAspectRatio,
              crossAxisSpacing: crossAxisSpacing,
              mainAxisSpacing: mainAxisSpacing,
              padding: padding,
              children: children,
            ),
            if (showNetworkStatus)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: NetworkStatusWidget(
                  showRetryButton: true,
                  showConnectionType: false,
                  margin: EdgeInsets.zero,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

