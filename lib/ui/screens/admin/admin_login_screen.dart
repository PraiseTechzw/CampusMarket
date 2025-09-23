/// @Branch: Admin Login Screen Implementation
///
/// Admin authentication screen with separate login flow
/// Provides access to admin dashboard and management tools
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/gradient_text.dart';
import '../../../core/widgets/glow_card.dart';
import '../../../core/widgets/app_logo.dart';
import '../../../core/widgets/success_toast.dart';
import '../../../core/providers/auth_provider.dart';

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.colorScheme.primary.withOpacity(0.05),
              theme.colorScheme.secondary.withOpacity(0.03),
              theme.colorScheme.tertiary.withOpacity(0.02),
            ],
          ),
        ),
        child: Stack(
          children: [
            // Floating elements for visual appeal
            ..._buildFloatingElements(theme),

            SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: AppSpacing.xxxl),

                    // Logo and title
                    Column(
                      children: [
                        AppLogo.medium(
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary,
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ).animate().scale(
                          duration: const Duration(milliseconds: 600),
                          curve: Curves.easeOutBack,
                        ),

                        const SizedBox(height: AppSpacing.lg),

                        GradientText(
                          'Admin Portal',
                          style: theme.textTheme.displayMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ).animate().fadeIn(
                          duration: const Duration(milliseconds: 800),
                          delay: const Duration(milliseconds: 200),
                        ),

                        const SizedBox(height: AppSpacing.sm),

                        Text(
                          'Campus Market Administration',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.7),
                          ),
                        ).animate().fadeIn(
                          duration: const Duration(milliseconds: 800),
                          delay: const Duration(milliseconds: 400),
                        ),
                      ],
                    ),

                    const SizedBox(height: AppSpacing.xxxl),

                    // Login form
                    GlowCard(
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text(
                                  'Admin Sign In',
                                  style: theme.textTheme.headlineMedium
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ),

                                const SizedBox(height: AppSpacing.xl),

                                // Email field
                                TextFormField(
                                  controller: _emailController,
                                  keyboardType: TextInputType.emailAddress,
                                  decoration: const InputDecoration(
                                    labelText: 'Admin Email',
                                    prefixIcon: Icon(Icons.email_outlined),
                                    hintText: 'admin@campusmarket.com',
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter your admin email';
                                    }
                                    if (!value.contains('@')) {
                                      return 'Please enter a valid email';
                                    }
                                    return null;
                                  },
                                ),

                                const SizedBox(height: AppSpacing.lg),

                                // Password field
                                TextFormField(
                                  controller: _passwordController,
                                  obscureText: _obscurePassword,
                                  decoration: InputDecoration(
                                    labelText: 'Password',
                                    prefixIcon: const Icon(Icons.lock_outlined),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _obscurePassword
                                            ? Icons.visibility
                                            : Icons.visibility_off,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _obscurePassword = !_obscurePassword;
                                        });
                                      },
                                    ),
                                    hintText: 'Enter your admin password',
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter your password';
                                    }
                                    if (value.length < 6) {
                                      return 'Password must be at least 6 characters';
                                    }
                                    return null;
                                  },
                                ),

                                const SizedBox(height: AppSpacing.xl),

                                // Sign in button
                                Consumer<AuthProvider>(
                                  builder: (context, authProvider, child) => ElevatedButton(
                                      onPressed: authProvider.isLoading
                                          ? null
                                          : _signIn,
                                      child: authProvider.isLoading
                                          ? const SizedBox(
                                              width: 20,
                                              height: 20,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                valueColor:
                                                    AlwaysStoppedAnimation<
                                                      Color
                                                    >(Colors.white),
                                              ),
                                            )
                                          : const Text('Sign In'),
                                    ),
                                ),

                                const SizedBox(height: AppSpacing.lg),

                                // Error message
                                Consumer<AuthProvider>(
                                  builder: (context, authProvider, child) {
                                    if (authProvider.error != null) {
                                      return Container(
                                        padding: const EdgeInsets.all(
                                          AppSpacing.md,
                                        ),
                                        decoration: BoxDecoration(
                                          color: theme.colorScheme.error
                                              .withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(
                                            AppSpacing.radiusSm,
                                          ),
                                          border: Border.all(
                                            color: theme.colorScheme.error
                                                .withOpacity(0.3),
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.error_outline,
                                              color: theme.colorScheme.error,
                                              size: 20,
                                            ),
                                            const SizedBox(
                                              width: AppSpacing.sm,
                                            ),
                                            Expanded(
                                              child: Text(
                                                authProvider.error!,
                                                style: theme.textTheme.bodySmall
                                                    ?.copyWith(
                                                      color: theme
                                                          .colorScheme
                                                          .error,
                                                    ),
                                              ),
                                            ),
                                            IconButton(
                                              icon: const Icon(
                                                Icons.close,
                                                size: 16,
                                              ),
                                              onPressed: () {
                                                authProvider.clearError();
                                              },
                                            ),
                                          ],
                                        ),
                                      );
                                    }
                                    return const SizedBox.shrink();
                                  },
                                ),
                              ],
                            ),
                          ),
                        )
                        .animate()
                        .fadeIn(
                          duration: const Duration(milliseconds: 800),
                          delay: const Duration(milliseconds: 600),
                        )
                        .slideY(
                          begin: 0.3,
                          end: 0,
                          duration: const Duration(milliseconds: 800),
                          delay: const Duration(milliseconds: 600),
                        ),

                    const SizedBox(height: AppSpacing.xl),

                    // Back to app
                    TextButton(
                      onPressed: () => context.go('/home'),
                      child: const Text('Back to App'),
                    ).animate().fadeIn(
                      duration: const Duration(milliseconds: 800),
                      delay: const Duration(milliseconds: 800),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildFloatingElements(ThemeData theme) => [
      // Floating circles
      Positioned(
        top: 80,
        right: 30,
        child:
            Container(
                  width: 45,
                  height: 45,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: theme.colorScheme.primary.withOpacity(0.1),
                  ),
                )
                .animate()
                .fadeIn(duration: const Duration(milliseconds: 1000))
                .scale(
                  duration: const Duration(milliseconds: 2000),
                  curve: Curves.easeInOut,
                ),
      ),
      Positioned(
        top: 180,
        left: 25,
        child:
            Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: theme.colorScheme.secondary.withOpacity(0.1),
                  ),
                )
                .animate()
                .fadeIn(duration: const Duration(milliseconds: 1500))
                .scale(
                  duration: const Duration(milliseconds: 2500),
                  curve: Curves.easeInOut,
                ),
      ),
      Positioned(
        bottom: 120,
        right: 50,
        child:
            Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: theme.colorScheme.tertiary.withOpacity(0.1),
                  ),
                )
                .animate()
                .fadeIn(duration: const Duration(milliseconds: 2000))
                .scale(
                  duration: const Duration(milliseconds: 3000),
                  curve: Curves.easeInOut,
                ),
      ),
    ];

  Future<void> _signIn() async {
    if (_formKey.currentState!.validate()) {
      // For demo purposes, accept any email with password "admin123"
      if (_passwordController.text == 'admin123') {
        // Simulate admin login
        await Future<void>.delayed(const Duration(seconds: 1));
        if (mounted) {
          // Show success toast with confetti
          SuccessToast.showAdminLoginSuccess(context);

          // Small delay to ensure state is updated before navigation
          await Future<void>.delayed(const Duration(milliseconds: 100));
          if (mounted) {
            // Use pushReplacement to replace the current route
            context.pushReplacement('/admin');
          }
        }
      } else {
        // Show error
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invalid admin credentials'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
