/// @Branch: Sign Up Screen Implementation
///
/// User registration screen with form validation
/// Modern design matching the sign-in screen
/// Enhanced with university selection and Zimbabwe context
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter/foundation.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/gestures.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/gradient_text.dart';
import '../../../core/widgets/glow_card.dart';
import '../../../core/widgets/app_logo.dart';
import '../../../core/widgets/success_toast.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/localization/app_localizations.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _customUniversityController = TextEditingController();
  final _studentIdController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _agreeToTerms = false;
  String _selectedUniversity = '';
  bool _showCustomUniversity = false;
  bool _isStudentEmail = false;

  // Zimbabwe universities list
  final List<String> _universities = [
    'University of Zimbabwe',
    'National University of Science and Technology',
    'Midlands State University',
    'Great Zimbabwe University',
    'Lupane State University',
    'Bindura University of Science Education',
    'Chinhoyi University of Technology',
    'Zimbabwe Open University',
    'Solusi University',
    'Africa University',
    'Catholic University of Zimbabwe',
    "Women's University in Africa",
    'Zimbabwe Ezekiel Guti University',
    'Manicaland State University of Applied Sciences',
    'Marondera University of Agricultural Sciences and Technology',
    'Other', // Add "Other" option
  ];

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_onEmailChanged);
  }

  void _onEmailChanged() {
    final email = _emailController.text.trim();
    final isStudent = AuthService.isValidStudentEmail(email);
    final detectedUniversity = AuthService.getUniversityFromEmail(email);

    setState(() {
      _isStudentEmail = isStudent;
      if (isStudent && detectedUniversity != null) {
        _selectedUniversity = detectedUniversity;
        _showCustomUniversity = false;
      }
    });
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _customUniversityController.dispose();
    _studentIdController.dispose();
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
      top: 120,
      right: 40,
      child:
          Container(
                width: 50,
                height: 50,
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
      top: 250,
      left: 20,
      child:
          Container(
                width: 35,
                height: 35,
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
      bottom: 180,
      right: 60,
      child:
          Container(
                width: 70,
                height: 70,
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

                // Sign up form
                _buildSignUpForm(theme, l10n),

                const SizedBox(height: AppSpacing.xl),

                // Sign in link
                _buildSignInLink(theme, l10n),
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
            const SizedBox(height: AppSpacing.xl),

            // Logo and title
            _buildLogoAndTitle(theme, l10n),

            const SizedBox(height: AppSpacing.xl),

            // Sign up form
            _buildSignUpForm(theme, l10n),

            const SizedBox(height: AppSpacing.lg),

            // Sign in link
            _buildSignInLink(theme, l10n),
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
        'Join Zimbabwe\'s Premier Student Marketplace!',
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

  Widget _buildSignUpForm(ThemeData theme, AppLocalizations l10n) =>
      GlowCard(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    l10n.signUp,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  // Name fields - Stacked on mobile for better visibility
                  if (MediaQuery.of(context).size.width < 600) ...[
                    // Mobile layout - stacked fields
                    TextFormField(
                      controller: _firstNameController,
                      decoration: InputDecoration(
                        labelText: l10n.firstName,
                        prefixIcon: const Icon(Icons.person_outline),
                        hintText: 'Enter your first name',
                        helperText: 'Required field',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: theme.colorScheme.surface,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'First name is required';
                        }
                        if (value.length < 2) {
                          return 'First name must be at least 2 characters';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    TextFormField(
                      controller: _lastNameController,
                      decoration: InputDecoration(
                        labelText: l10n.lastName,
                        prefixIcon: const Icon(Icons.person_outline),
                        hintText: 'Enter your last name',
                        helperText: 'Required field',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: theme.colorScheme.surface,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Last name is required';
                        }
                        if (value.length < 2) {
                          return 'Last name must be at least 2 characters';
                        }
                        return null;
                      },
                    ),
                  ] else ...[
                    // Desktop layout - side by side
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _firstNameController,
                            decoration: InputDecoration(
                              labelText: l10n.firstName,
                              prefixIcon: const Icon(Icons.person_outline),
                              hintText: 'First name',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                              fillColor: theme.colorScheme.surface,
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'First name is required';
                              }
                              if (value.length < 2) {
                                return 'First name must be at least 2 characters';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: TextFormField(
                            controller: _lastNameController,
                            decoration: InputDecoration(
                              labelText: l10n.lastName,
                              prefixIcon: const Icon(Icons.person_outline),
                              hintText: 'Last name',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                              fillColor: theme.colorScheme.surface,
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Last name is required';
                              }
                              if (value.length < 2) {
                                return 'Last name must be at least 2 characters';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                  ],

                  const SizedBox(height: AppSpacing.lg),

                  // University selection
                  DropdownButtonFormField<String>(
                    value: _selectedUniversity.isEmpty
                        ? null
                        : _selectedUniversity,
                    decoration: InputDecoration(
                      labelText: 'University',
                      prefixIcon: const Icon(Icons.school),
                      hintText: 'Select your university',
                      helperText: 'Choose your university in Zimbabwe',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: theme.colorScheme.surface,
                    ),
                    items: _universities.map((university) {
                      return DropdownMenuItem(
                        value: university,
                        child: Text(university),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedUniversity = value ?? '';
                        _showCustomUniversity = value == 'Other';
                        if (!_showCustomUniversity) {
                          _customUniversityController.clear();
                        }
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select your university';
                      }
                      return null;
                    },
                  ),

                  // Custom university input field (shown when "Other" is selected)
                  if (_showCustomUniversity) ...[
                    const SizedBox(height: AppSpacing.md),
                    TextFormField(
                      controller: _customUniversityController,
                      decoration: InputDecoration(
                        labelText: 'University Name',
                        prefixIcon: const Icon(Icons.school_outlined),
                        hintText: 'Enter your university name',
                        helperText:
                            'Please enter the full name of your university',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: theme.colorScheme.surface,
                      ),
                      validator: (value) {
                        if (_showCustomUniversity &&
                            (value == null || value.trim().isEmpty)) {
                          return 'Please enter your university name';
                        }
                        if (_showCustomUniversity && value!.trim().length < 3) {
                          return 'University name must be at least 3 characters';
                        }
                        return null;
                      },
                    ),
                  ],

                  const SizedBox(height: AppSpacing.lg),

                  // Student ID field (optional)
                  TextFormField(
                    controller: _studentIdController,
                    decoration: InputDecoration(
                      labelText: 'Student ID (Optional)',
                      prefixIcon: const Icon(Icons.badge),
                      hintText: 'Enter your student ID',
                      helperText: 'This helps with verification',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: theme.colorScheme.surface,
                    ),
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  // Email field
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: l10n.email,
                      prefixIcon: const Icon(Icons.email_outlined),
                      hintText: 'your.email@example.com',
                      helperText: _isStudentEmail
                          ? 'University email detected - you can sell items immediately'
                          : 'Use any email address (university email preferred for faster verification)',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: theme.colorScheme.surface,
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

                  // Email validation indicator
                  if (_isStudentEmail) ...[
                    const SizedBox(height: AppSpacing.sm),
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.sm),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.green.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.verified, color: Colors.green, size: 20),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: Text(
                              'Student email detected! You\'ll be able to sell items immediately.',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: Colors.green[700],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ] else ...[
                    const SizedBox(height: AppSpacing.sm),
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.sm),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.orange.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: Colors.orange[700],
                            size: 20,
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: Text(
                              'Non-university email detected. You can browse items but will need admin verification to sell items.',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: Colors.orange[700],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

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
                      hintText: 'Create a password',
                      helperText: 'Minimum 6 characters',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: theme.colorScheme.surface,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Password is required';
                      }
                      if (value.length < 6) {
                        return 'Password must be at least 6 characters long';
                      }
                      if (!RegExp(r'^(?=.*[a-zA-Z])(?=.*\d)').hasMatch(value)) {
                        return 'Password must contain letters and numbers';
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
                      labelText: 'Confirm Password',
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
                      hintText: 'Confirm your password',
                      helperText: 'Must match the password above',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: theme.colorScheme.surface,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please confirm your password';
                      }
                      if (value != _passwordController.text) {
                        return 'Passwords do not match. Please try again';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: AppSpacing.md),

                  // Terms and conditions
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Checkbox(
                        value: _agreeToTerms,
                        onChanged: (value) {
                          setState(() {
                            _agreeToTerms = value ?? false;
                          });
                        },
                        activeColor: theme.colorScheme.primary,
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () =>
                              setState(() => _agreeToTerms = !_agreeToTerms),
                          child: Text.rich(
                            TextSpan(
                              text: 'I agree to the ',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurface.withOpacity(
                                  0.8,
                                ),
                              ),
                              children: [
                                TextSpan(
                                  text: 'Terms of Service',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.colorScheme.primary,
                                    fontWeight: FontWeight.w600,
                                    decoration: kIsWeb
                                        ? TextDecoration.underline
                                        : TextDecoration.none,
                                    decorationColor: theme.colorScheme.primary,
                                  ),
                                  recognizer: kIsWeb
                                      ? (TapGestureRecognizer()
                                          ..onTap = () => _openTermsOfService())
                                      : null,
                                ),
                                TextSpan(
                                  text: ' and ',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.colorScheme.onSurface
                                        .withOpacity(0.8),
                                  ),
                                ),
                                TextSpan(
                                  text: 'Privacy Policy',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.colorScheme.primary,
                                    fontWeight: FontWeight.w600,
                                    decoration: kIsWeb
                                        ? TextDecoration.underline
                                        : TextDecoration.none,
                                    decorationColor: theme.colorScheme.primary,
                                  ),
                                  recognizer: kIsWeb
                                      ? (TapGestureRecognizer()
                                          ..onTap = () => _openPrivacyPolicy())
                                      : null,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  // Sign up button
                  Consumer<AuthProvider>(
                    builder: (context, authProvider, child) {
                      return ElevatedButton(
                        onPressed: (authProvider.isLoading || !_agreeToTerms)
                            ? null
                            : _signUp,
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
                            : Text(l10n.signUp),
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
                                          'Sign Up Failed',
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

  Widget _buildSignInLink(ThemeData theme, AppLocalizations l10n) =>
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Already have an account? ',
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

  Future<void> _signUp() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = context.read<AuthProvider>();

      // Clear any previous errors
      authProvider.clearError();

      // Determine the final university name
      String finalUniversity = _selectedUniversity;
      if (_selectedUniversity == 'Other' &&
          _customUniversityController.text.trim().isNotEmpty) {
        finalUniversity = _customUniversityController.text.trim();
      }

      try {
        final result = await AuthService.signUpWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          firstName: _firstNameController.text.trim(),
          lastName: _lastNameController.text.trim(),
          university: finalUniversity,
          studentId: _studentIdController.text.trim().isNotEmpty
              ? _studentIdController.text.trim()
              : null,
        );

        if (result != null && mounted) {
          // Check if there was an error
          if (result['error'] == true) {
            _showErrorToast(
              result['message'] ??
                  'Failed to create account. Please try again.',
            );
            return;
          }

          // Show success toast with confetti
          SuccessToast.showSignupSuccess(
            context,
            userName: _firstNameController.text.trim(),
          );

          // Wait for toast to show, then redirect to email verification
          await Future<void>.delayed(const Duration(milliseconds: 1500));

          if (mounted) {
            if (result['isStudentEmail'] == true) {
              _showSuccessToast(
                'Account created! Student email verified automatically.',
              );
              // Redirect to home for verified student emails
              context.go('/home');
            } else {
              _showSuccessToast(
                'Account created! Please check your email to verify your account.',
              );
              // Redirect to email verification page
              context.go(
                '/email-verification?email=${_emailController.text.trim()}',
              );
            }
          }
        } else {
          _showErrorToast('Failed to create account. Please try again.');
        }
      } catch (e) {
        _showErrorToast('Error: ${e.toString()}');
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

  // Methods for opening legal documents
  void _openTermsOfService() {
    context.go('/terms-of-service');
  }

  void _openPrivacyPolicy() {
    context.go('/privacy-policy');
  }
}
