/// @Branch: Splash Screen Implementation
///
/// Modern splash screen with app logo and smooth transitions
/// Provides loading animation and automatic navigation to onboarding
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/theme/app_spacing.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _textController;
  late AnimationController _progressController;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startSplashSequence();
  }

  void _initializeAnimations() {
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _textController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _progressController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
  }

  Future<void> _startSplashSequence() async {
    // Start logo animation
    _logoController.forward();

    // Wait a bit then start text animation
    await Future<void>.delayed(const Duration(milliseconds: 500));
    _textController.forward();

    // Start progress animation
    await Future<void>.delayed(const Duration(milliseconds: 300));
    _progressController.forward();

    // Wait for all animations to complete then let router handle navigation
    await Future<void>.delayed(const Duration(milliseconds: 1500));
    if (mounted) {
      // Let the router's redirect logic handle where to go next
      // This prevents navigation loops by allowing auth state to determine routing
      context.go('/home');
    }
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    const isWeb = kIsWeb;
    final screenWidth = size.width;

    return Scaffold(
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.colorScheme.primary.withOpacity(0.1),
              theme.colorScheme.secondary.withOpacity(0.05),
              theme.colorScheme.tertiary.withOpacity(0.1),
            ],
          ),
        ),
        child: SafeArea(
          child: isWeb && screenWidth > 768
              ? _buildWebLayout(theme, size)
              : _buildMobileLayout(theme, size),
        ),
      ),
    );
  }

  Widget _buildWebLayout(ThemeData theme, Size size) => Row(
    children: [
      // Left side - Content
      Expanded(
        flex: 1,
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.xxxl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // App logo with animation
              AnimatedBuilder(
                animation: _logoController,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _logoController.value,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            theme.colorScheme.primary,
                            theme.colorScheme.secondary,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(60),
                        boxShadow: [
                          BoxShadow(
                            color: theme.colorScheme.primary.withOpacity(0.3),
                            blurRadius: 30,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(60),
                        child: Image.asset(
                          'assets/images/logo.png',
                          width: 120,
                          height: 120,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(
                              Icons.store,
                              size: 60,
                              color: Colors.white,
                            );
                          },
                        ),
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: AppSpacing.xxxl),

              // App name with animation
              AnimatedBuilder(
                animation: _textController,
                builder: (context, child) {
                  return Opacity(
                    opacity: _textController.value,
                    child: Transform.translate(
                      offset: Offset(-20 * (1 - _textController.value), 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Campus Market',
                            style: theme.textTheme.displayLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                              fontSize: 56,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          Text(
                            'Zimbabwe\'s Premier Student Marketplace',
                            style: theme.textTheme.headlineMedium?.copyWith(
                              color: theme.colorScheme.onSurface.withOpacity(
                                0.8,
                              ),
                              fontWeight: FontWeight.w500,
                              fontSize: 24,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          Text(
                            'Connect, trade, and thrive in your university community',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: theme.colorScheme.onSurface.withOpacity(
                                0.7,
                              ),
                              fontSize: 18,
                              height: 1.6,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),

              const Spacer(),

              // Loading section
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Animated progress indicator
                  AnimatedBuilder(
                    animation: _progressController,
                    builder: (context, child) {
                      return Container(
                        width: 300,
                        height: 6,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.outline.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(3),
                        ),
                        child: FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: _progressController.value,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  theme.colorScheme.primary,
                                  theme.colorScheme.secondary,
                                ],
                              ),
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  // Loading text
                  Text(
                    'Initializing your campus experience...',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),

      // Right side - Visual elements
      Expanded(
        flex: 1,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                theme.colorScheme.primary.withOpacity(0.05),
                theme.colorScheme.secondary.withOpacity(0.03),
              ],
            ),
          ),
          child: Center(child: _buildWebVisualElements(theme)),
        ),
      ),
    ],
  );

  Widget _buildMobileLayout(ThemeData theme, Size size) => Column(
    children: [
      // Top spacing
      SizedBox(height: size.height * 0.15),

      // Logo section
      Expanded(
        flex: 3,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App logo with animation
            AnimatedBuilder(
              animation: _logoController,
              builder: (context, child) {
                return Transform.scale(
                  scale: _logoController.value,
                  child: Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          theme.colorScheme.primary,
                          theme.colorScheme.secondary,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(75),
                      boxShadow: [
                        BoxShadow(
                          color: theme.colorScheme.primary.withOpacity(0.3),
                          blurRadius: 30,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(75),
                      child: Image.asset(
                        'assets/images/logo.png',
                        width: 150,
                        height: 150,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(
                            Icons.store,
                            size: 80,
                            color: Colors.white,
                          );
                        },
                      ),
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: AppSpacing.xxxl),

            // App name with animation
            AnimatedBuilder(
              animation: _textController,
              builder: (context, child) {
                return Opacity(
                  opacity: _textController.value,
                  child: Transform.translate(
                    offset: Offset(0, 20 * (1 - _textController.value)),
                    child: Column(
                      children: [
                        Text(
                          'Campus Market',
                          style: theme.textTheme.displayMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          'Zimbabwe\'s Premier Student Marketplace',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.7),
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),

      // Loading section
      Expanded(
        flex: 1,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated progress indicator
            AnimatedBuilder(
              animation: _progressController,
              builder: (context, child) {
                return Container(
                  width: 200,
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.outline.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: _progressController.value,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            theme.colorScheme.primary,
                            theme.colorScheme.secondary,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: AppSpacing.lg),

            // Loading text
            Text(
              'Loading...',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),

      // Bottom spacing
      SizedBox(height: size.height * 0.1),
    ],
  );

  Widget _buildWebVisualElements(ThemeData theme) => Stack(
    alignment: Alignment.center,
    children: [
      // Background circles
      ...List.generate(3, (index) {
        final size = 200.0 + (index * 100.0);
        final opacity = 0.1 - (index * 0.03);
        return Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: theme.colorScheme.primary.withOpacity(opacity),
              ),
            )
            .animate()
            .scale(
              duration: Duration(milliseconds: 2000 + (index * 500)),
              curve: Curves.easeInOut,
            )
            .then()
            .scale(
              duration: Duration(milliseconds: 2000 + (index * 500)),
              curve: Curves.easeInOut,
            );
      }),

      // Main visual element
      Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  theme.colorScheme.primary.withOpacity(0.2),
                  theme.colorScheme.secondary.withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(150),
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.primary.withOpacity(0.2),
                  blurRadius: 40,
                  offset: const Offset(0, 20),
                ),
              ],
            ),
            child: Icon(
              Icons.school,
              size: 120,
              color: theme.colorScheme.primary.withOpacity(0.6),
            ),
          )
          .animate()
          .scale(
            duration: const Duration(milliseconds: 2000),
            curve: Curves.elasticOut,
          )
          .then()
          .scale(
            duration: const Duration(milliseconds: 2000),
            curve: Curves.easeInOut,
          ),
    ],
  );
}
