/// @Branch: Sign In Screen Implementation
///
/// User authentication sign-in screen
/// Modern design with form validation and error handling
/// Enhanced with Zimbabwe university context and better UX
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter/foundation.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/gradient_text.dart';
import '../../../core/widgets/glow_card.dart';
import '../../../core/widgets/app_logo.dart';
import '../../../core/widgets/success_toast.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/localization/app_localizations.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _rememberMe = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    const isWeb = kIsWeb;
    final screenWidth = MediaQuery.of(context).size.width;

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
              child: isWeb && screenWidth > 768
                  ? _buildWebLayout(theme, l10n, screenWidth)
                  : _buildMobileLayout(theme, l10n),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildFloatingElements(ThemeData theme) => [
    // Floating circles
    Positioned(
      top: 100,
      right: 50,
      child:
          Container(
                width: 60,
                height: 60,
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
      top: 200,
      left: 30,
      child:
          Container(
                width: 40,
                height: 40,
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
      bottom: 150,
      right: 80,
      child:
          Container(
                width: 80,
                height: 80,
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

  Widget _buildWebLayout(
    ThemeData theme,
    AppLocalizations l10n,
    double screenWidth,
  ) => Row(
    children: [
      // Left side - Content
      Expanded(
        flex: 1,
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.xxxl),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo and title
                _buildLogoAndTitle(theme, l10n),

                const SizedBox(height: AppSpacing.xl),

                // Sign in form
                _buildSignInForm(theme, l10n),

                const SizedBox(height: AppSpacing.lg),

                // Sign up link
                _buildSignUpLink(theme, l10n),
              ],
            ),
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
                theme.colorScheme.primary.withOpacity(0.1),
                theme.colorScheme.secondary.withOpacity(0.05),
              ],
            ),
          ),
          child: Center(child: _buildWebVisualElements(theme)),
        ),
      ),
    ],
  );

  Widget _buildMobileLayout(ThemeData theme, AppLocalizations l10n) =>
      SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: AppSpacing.xxxl),

            // Logo and title
            _buildLogoAndTitle(theme, l10n),

            const SizedBox(height: AppSpacing.xl),

            // Sign in form
            _buildSignInForm(theme, l10n),

            const SizedBox(height: AppSpacing.lg),

            // Sign up link
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Don't have an account? ",
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
                TextButton(
                  onPressed: () => context.go('/sign-up'),
                  child: Text(l10n.signUp),
                ),
              ],
            ).animate().fadeIn(
              duration: const Duration(milliseconds: 800),
              delay: const Duration(milliseconds: 800),
            ),
          ],
        ),
      );

  Widget _buildLogoAndTitle(ThemeData theme, AppLocalizations l10n) => Column(
    children: [
      AppLogo.large(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [theme.colorScheme.primary, theme.colorScheme.secondary],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.primary.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
      ).animate().scale(
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeOutBack,
      ),

      const SizedBox(height: AppSpacing.md),

      GradientText(
        l10n.appName,
        style: theme.textTheme.displayMedium?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ).animate().fadeIn(
        duration: const Duration(milliseconds: 800),
        delay: const Duration(milliseconds: 200),
      ),

      const SizedBox(height: AppSpacing.xs),

      Text(
        'Welcome back to Zimbabwe\'s Premier Student Marketplace!',
        style: theme.textTheme.headlineSmall?.copyWith(
          color: theme.colorScheme.onSurface.withOpacity(0.7),
        ),
        textAlign: TextAlign.center,
      ).animate().fadeIn(
        duration: const Duration(milliseconds: 800),
        delay: const Duration(milliseconds: 400),
      ),

      const SizedBox(height: AppSpacing.sm),

      Text(
        'Connect with students across Zimbabwe\'s universities',
        style: theme.textTheme.bodyLarge?.copyWith(
          color: theme.colorScheme.onSurface.withOpacity(0.6),
        ),
        textAlign: TextAlign.center,
      ).animate().fadeIn(
        duration: const Duration(milliseconds: 800),
        delay: const Duration(milliseconds: 600),
      ),
    ],
  );

  Widget _buildSignUpLink(ThemeData theme, AppLocalizations l10n) =>
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Don't have an account? ",
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          TextButton(
            onPressed: () => context.go('/sign-up'),
            child: Text(l10n.signUp),
          ),
        ],
      ).animate().fadeIn(
        duration: const Duration(milliseconds: 800),
        delay: const Duration(milliseconds: 800),
      );

  Widget _buildSignInForm(ThemeData theme, AppLocalizations l10n) =>
      GlowCard(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    l10n.signIn,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  // Email field
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: l10n.email,
                      prefixIcon: const Icon(Icons.email_outlined),
                      hintText: 'your.email@example.com',
                      helperText: 'Enter your email address',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Email address is required';
                      }
                      if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                        return 'Please enter a valid email address';
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
                      labelText: l10n.password,
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
                      hintText: 'Enter your password',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Password is required';
                      }
                      if (value.length < 6) {
                        return 'Password must be at least 6 characters long';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: AppSpacing.md),

                  // Remember me and forgot password
                  Wrap(
                    alignment: WrapAlignment.spaceBetween,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Checkbox(
                            value: _rememberMe,
                            onChanged: (value) {
                              setState(() {
                                _rememberMe = value ?? false;
                              });
                            },
                          ),
                          Text(
                            'Remember me',
                            style: theme.textTheme.bodyMedium,
                          ),
                        ],
                      ),
                      TextButton(
                        onPressed: () =>
                            _showForgotPasswordDialog(context, theme),
                        child: Text(l10n.forgotPassword),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  // Sign in button
                  Consumer<AuthProvider>(
                    builder: (context, authProvider, child) {
                      return ElevatedButton(
                        onPressed: authProvider.isLoading ? null : _signIn,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            vertical: AppSpacing.lg,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: authProvider.isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : Text(l10n.signIn),
                      );
                    },
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  // Error message
                  Consumer<AuthProvider>(
                    builder: (context, authProvider, child) {
                      if (authProvider.error != null) {
                        return Container(
                              margin: const EdgeInsets.only(
                                bottom: AppSpacing.md,
                              ),
                              padding: const EdgeInsets.all(AppSpacing.md),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    theme.colorScheme.error.withOpacity(0.1),
                                    theme.colorScheme.error.withOpacity(0.05),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: theme.colorScheme.error.withOpacity(
                                    0.3,
                                  ),
                                  width: 1,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: theme.colorScheme.error.withOpacity(
                                      0.1,
                                    ),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: theme.colorScheme.error
                                          .withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      Icons.error_outline_rounded,
                                      color: theme.colorScheme.error,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: AppSpacing.md),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Sign In Failed',
                                          style: theme.textTheme.titleSmall
                                              ?.copyWith(
                                                color: theme.colorScheme.error,
                                                fontWeight: FontWeight.w600,
                                              ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          authProvider.error!,
                                          style: theme.textTheme.bodySmall
                                              ?.copyWith(
                                                color: theme.colorScheme.error
                                                    .withOpacity(0.8),
                                                height: 1.4,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      Icons.close_rounded,
                                      size: 18,
                                      color: theme.colorScheme.error
                                          .withOpacity(0.7),
                                    ),
                                    onPressed: () {
                                      authProvider.clearError();
                                    },
                                    tooltip: 'Dismiss',
                                  ),
                                ],
                              ),
                            )
                            .animate()
                            .fadeIn(duration: const Duration(milliseconds: 300))
                            .slideX(begin: -0.1, end: 0, curve: Curves.easeOut);
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
      AppLogo.hero(
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

  void _showForgotPasswordDialog(BuildContext context, ThemeData theme) {
    final emailController = TextEditingController();

    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.lock_reset, color: theme.colorScheme.primary, size: 24),
            const SizedBox(width: AppSpacing.sm),
            const Text('Reset Password'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Enter your email address and we'll send you a password reset link.",
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Email Address',
                  hintText: 'your.email@example.com',
                  prefixIcon: const Icon(Icons.email_outlined),
                  helperText: 'Enter the email address you used to sign up',
                ),
              ),
            ],
          ),
        ),
        actions: [
          Wrap(
            alignment: WrapAlignment.end,
            spacing: AppSpacing.sm,
            children: [
              TextButton(
                onPressed: () {
                  emailController.dispose();
                  Navigator.of(context).pop();
                },
                child: const Text('Cancel'),
              ),
              Consumer<AuthProvider>(
                builder: (context, authProvider, child) => ElevatedButton(
                  onPressed: authProvider.isLoading
                      ? null
                      : () => _handleForgotPassword(
                          context,
                          emailController.text.trim(),
                          authProvider,
                        ),
                  child: authProvider.isLoading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : const Text('Send Reset Link'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _handleForgotPassword(
    BuildContext context,
    String email,
    AuthProvider authProvider,
  ) async {
    if (email.isEmpty) {
      _showErrorToast('Please enter your email address');
      return;
    }

    if (!email.contains('@')) {
      _showErrorToast('Please enter a valid email address');
      return;
    }

    final success = await authProvider.forgotPassword(email);

    if (mounted) {
      if (context.mounted) {
        Navigator.of(context).pop();
      }

      if (success) {
        _showSuccessToast(
          'Password reset link sent to $email! Check your email and follow the instructions.',
        );
      } else {
        _showErrorToast(
          authProvider.error ?? 'Failed to send reset email. Please try again.',
        );
      }
    }
  }

  Future<void> _signIn() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = context.read<AuthProvider>();

      // Clear any previous errors
      authProvider.clearError();

      final success = await authProvider.signIn(
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (success && mounted) {
        // Check user status after successful sign in
        final userStatus = await AuthService.getCurrentUserStatus();

        if (userStatus != null) {
          if (userStatus['isVerified'] == true) {
            _showSuccessToast('Welcome back! You can browse and sell items.');
          } else {
            _showSuccessToast(
              'Welcome! You can browse items. Contact admin for selling privileges.',
            );
          }
        } else {
          _showSuccessToast('Welcome back!');
        }

        // Show success toast with confetti
        if (mounted) {
          SuccessToast.showLoginSuccess(
            context,
            userName: _emailController.text.trim().split('@').first,
          );
        }

        // Wait for auth state to be properly updated and check if user is authenticated
        int attempts = 0;
        while (attempts < 10 && mounted) {
          await Future<void>.delayed(const Duration(milliseconds: 200));
          if (authProvider.isAuthenticated && mounted) {
            print('User is authenticated, navigating to home');
            if (context.mounted) {
              context.go('/home');
            }
            return;
          }
          attempts++;
        }

        // Fallback: try to navigate anyway
        if (mounted && context.mounted) {
          print('Fallback navigation to home');
          context.go('/home');
        }
      }
    }
  }

  void _showSuccessToast(String message) {
    try {
      Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.green,
        textColor: Colors.white,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.green),
      );
    }
  }

  void _showErrorToast(String message) {
    try {
      Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );
    }
  }
}
