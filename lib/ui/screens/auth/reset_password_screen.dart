/// @Branch: Reset Password Screen Implementation
///
/// Password reset screen for users who clicked the reset link
/// Allows users to set a new password with validation
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter/foundation.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/gradient_text.dart';
import '../../../core/widgets/glow_card.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/localization/app_localizations.dart';

class ResetPasswordScreen extends StatefulWidget {

  const ResetPasswordScreen({super.key, required this.email, this.token});
  final String email;
  final String? token;

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final isWeb = kIsWeb;
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
        child: SafeArea(
          child: isWeb && screenWidth > 768
              ? _buildWebLayout(theme, l10n, screenWidth)
              : _buildMobileLayout(theme, l10n),
        ),
      ),
    );
  }

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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo and title
                _buildLogoAndTitle(theme, l10n),

                const SizedBox(height: AppSpacing.xxxl),

                // Reset password form
                _buildResetPasswordForm(theme, l10n),
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

  Widget _buildMobileLayout(ThemeData theme, AppLocalizations l10n) => SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: AppSpacing.xxxl),

          // Logo and title
          _buildLogoAndTitle(theme, l10n),

          const SizedBox(height: AppSpacing.xxxl),

          // Reset password form
          _buildResetPasswordForm(theme, l10n),

          const SizedBox(height: AppSpacing.xl),

          // Back to sign in
          _buildBackToSignInLink(theme, l10n),
        ],
      ),
    );

  Widget _buildLogoAndTitle(ThemeData theme, AppLocalizations l10n) => Column(
      children: [
        Container(
          width: 80,
          height: 80,
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
          child: Icon(Icons.lock_reset, size: 40, color: Colors.white),
        ).animate().scale(
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeOutBack,
        ),

        const SizedBox(height: AppSpacing.lg),

        GradientText(
          'Reset Password',
          style: theme.textTheme.displayMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ).animate().fadeIn(
          duration: const Duration(milliseconds: 800),
          delay: const Duration(milliseconds: 200),
        ),

        const SizedBox(height: AppSpacing.sm),

        Text(
          'Set a new password for your account',
          style: theme.textTheme.headlineSmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.7),
          ),
          textAlign: TextAlign.center,
        ).animate().fadeIn(
          duration: const Duration(milliseconds: 800),
          delay: const Duration(milliseconds: 400),
        ),

        const SizedBox(height: AppSpacing.sm),

        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            border: Border.all(
              color: theme.colorScheme.primary.withOpacity(0.3),
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.email_outlined,
                color: theme.colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  'Resetting password for: ${widget.email}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ).animate().fadeIn(
          duration: const Duration(milliseconds: 800),
          delay: const Duration(milliseconds: 600),
        ),
      ],
    );

  Widget _buildResetPasswordForm(ThemeData theme, AppLocalizations l10n) => GlowCard(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Create New Password',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: AppSpacing.xl),

                // New password field
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'New Password',
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
                    hintText: 'Enter your new password',
                    helperText: 'Minimum 6 characters',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a new password';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: AppSpacing.lg),

                // Confirm password field
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: _obscureConfirmPassword,
                  decoration: InputDecoration(
                    labelText: 'Confirm New Password',
                    prefixIcon: const Icon(Icons.lock_outlined),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirmPassword
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureConfirmPassword = !_obscureConfirmPassword;
                        });
                      },
                    ),
                    hintText: 'Confirm your new password',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please confirm your new password';
                    }
                    if (value != _passwordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: AppSpacing.xl),

                // Reset password button
                Consumer<AuthProvider>(
                  builder: (context, authProvider, child) {
                    return ElevatedButton(
                      onPressed: authProvider.isLoading ? null : _resetPassword,
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
                          : const Text('Reset Password'),
                    );
                  },
                ),

                const SizedBox(height: AppSpacing.lg),

                // Error message
                Consumer<AuthProvider>(
                  builder: (context, authProvider, child) {
                    if (authProvider.error != null) {
                      return Container(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.error.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(
                            AppSpacing.radiusSm,
                          ),
                          border: Border.all(
                            color: theme.colorScheme.error.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.error_outline,
                              color: theme.colorScheme.error,
                              size: 20,
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Expanded(
                              child: Text(
                                authProvider.error!,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.error,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close, size: 16),
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
        );

  Widget _buildBackToSignInLink(ThemeData theme, AppLocalizations l10n) => Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Remember your password? ',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
        TextButton(
          onPressed: () => context.go('/sign-in'),
          child: Text(l10n.signIn),
        ),
      ],
    ).animate().fadeIn(
      duration: const Duration(milliseconds: 800),
      delay: const Duration(milliseconds: 800),
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
                Icons.lock_reset,
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

  Future<void> _resetPassword() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = context.read<AuthProvider>();

      final success = await authProvider.resetPassword(
        widget.email,
        _passwordController.text,
      );

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Password reset successfully! You can now sign in with your new password.',
            ),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
        context.go('/sign-in');
      }
    }
  }
}
