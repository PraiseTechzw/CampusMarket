/// @Branch: Success Toast Notification Widget
///
/// Custom toast notification with confetti animation for successful actions
/// Used for login, signup, and other success scenarios
library;

import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter_animate/flutter_animate.dart';

class SuccessToast extends StatefulWidget {

  const SuccessToast({
    super.key,
    required this.message,
    this.subtitle,
    this.icon,
    this.duration = const Duration(seconds: 3),
    this.onDismiss,
  });
  final String message;
  final String? subtitle;
  final IconData? icon;
  final Duration duration;
  final VoidCallback? onDismiss;

  /// Show success toast for login
  static void showLoginSuccess(BuildContext context, {String? userName}) {
    _showToast(
      context,
      SuccessToast(
        message: 'Welcome back!',
        subtitle: userName != null ? 'Hello, $userName!' : null,
        icon: Icons.login,
      ),
    );
  }

  /// Show success toast for signup
  static void showSignupSuccess(BuildContext context, {String? userName}) {
    _showToast(
      context,
      SuccessToast(
        message: 'Account created successfully!',
        subtitle: userName != null
            ? 'Welcome to Campus Market, $userName!'
            : 'Welcome to Campus Market!',
        icon: Icons.person_add,
      ),
    );
  }

  /// Show success toast for admin login
  static void showAdminLoginSuccess(BuildContext context) {
    _showToast(
      context,
      SuccessToast(
        message: 'Admin access granted!',
        subtitle: 'Welcome to the admin dashboard',
        icon: Icons.admin_panel_settings,
      ),
    );
  }

  static void _showToast(BuildContext context, SuccessToast toast) {
    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).padding.top + 20,
        left: 16,
        right: 16,
        child: Material(color: Colors.transparent, child: toast),
      ),
    );

    overlay.insert(overlayEntry);

    // Auto dismiss after duration
    Future.delayed(toast.duration, () {
      if (overlayEntry.mounted) {
        overlayEntry.remove();
        toast.onDismiss?.call();
      }
    });
  }

  @override
  State<SuccessToast> createState() => _SuccessToastState();
}

class _SuccessToastState extends State<SuccessToast>
    with TickerProviderStateMixin {
  late ConfettiController _confettiController;
  late AnimationController _slideController;
  late AnimationController _scaleController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 2),
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    // Start animations
    _slideController.forward();
    _scaleController.forward();
    _confettiController.play();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _slideController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Stack(
      children: [
        // Confetti animation
        Positioned.fill(
          child: ConfettiWidget(
            confettiController: _confettiController,
            blastDirection: 1.57, // Downward
            emissionFrequency: 0.05,
            numberOfParticles: 20,
            gravity: 0.3,
            colors: [
              theme.colorScheme.primary,
              theme.colorScheme.secondary,
              theme.colorScheme.tertiary,
              Colors.amber,
              Colors.pink,
            ],
          ),
        ),

        // Toast content
        SlideTransition(
          position: Tween<Offset>(begin: const Offset(0, -1), end: Offset.zero)
              .animate(
                CurvedAnimation(
                  parent: _slideController,
                  curve: Curves.elasticOut,
                ),
              ),
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.8, end: 1).animate(
              CurvedAnimation(
                parent: _scaleController,
                curve: Curves.elasticOut,
              ),
            ),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.primary.withOpacity(0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
                border: Border.all(
                  color: theme.colorScheme.primary.withOpacity(0.2),
                ),
              ),
              child: Row(
                children: [
                  // Success icon with animation
                  Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          widget.icon ?? Icons.check_circle,
                          color: Colors.green,
                          size: 24,
                        ),
                      )
                      .animate()
                      .scale(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.elasticOut,
                      )
                      .then()
                      .shimmer(
                        duration: const Duration(milliseconds: 1000),
                        color: Colors.green.withOpacity(0.3),
                      ),

                  const SizedBox(width: 12),

                  // Message content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.message,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        if (widget.subtitle != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            widget.subtitle!,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurface.withOpacity(
                                0.7,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  // Dismiss button
                  IconButton(
                    onPressed: () {
                      _slideController.reverse().then((_) {
                        if (mounted) {
                          Navigator.of(context).pop();
                        }
                      });
                    },
                    icon: Icon(
                      Icons.close,
                      color: theme.colorScheme.onSurface.withOpacity(0.5),
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
