/// @Branch: Security Settings Screen Implementation
///
/// User security settings with password management, 2FA, and security options
/// Includes account security, login history, and security alerts
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_spacing.dart';

class SecuritySettingsScreen extends StatefulWidget {
  const SecuritySettingsScreen({super.key});

  @override
  State<SecuritySettingsScreen> createState() => _SecuritySettingsScreenState();
}

class _SecuritySettingsScreenState extends State<SecuritySettingsScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;

  bool _isLoading = true;
  bool _twoFactorEnabled = false;
  bool _biometricEnabled = false;
  bool _loginAlerts = true;
  bool _suspiciousActivityAlerts = true;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadSecuritySettings();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  Future<void> _loadSecuritySettings() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // TODO: Implement getSecuritySettings in FirebaseRepository
      await Future<void>.delayed(const Duration(seconds: 1));

      setState(() {
        _twoFactorEnabled = false;
        _biometricEnabled = true;
        _loginAlerts = true;
        _suspiciousActivityAlerts = true;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading security settings: $e')),
        );
      }
    }
  }

  Future<void> _changePassword() async {
    // TODO: Implement password change functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Password change functionality coming soon'),
      ),
    );
  }

  Future<void> _toggleTwoFactor() async {
    try {
      // TODO: Implement 2FA toggle in FirebaseRepository
      await Future<void>.delayed(const Duration(seconds: 1));

      setState(() {
        _twoFactorEnabled = !_twoFactorEnabled;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _twoFactorEnabled
                  ? 'Two-factor authentication enabled'
                  : 'Two-factor authentication disabled',
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating 2FA settings: $e')),
        );
      }
    }
  }

  Future<void> _toggleBiometric() async {
    try {
      // TODO: Implement biometric toggle in FirebaseRepository
      await Future<void>.delayed(const Duration(seconds: 1));

      setState(() {
        _biometricEnabled = !_biometricEnabled;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _biometricEnabled
                  ? 'Biometric authentication enabled'
                  : 'Biometric authentication disabled',
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating biometric settings: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: _buildAppBar(theme),
      body: _buildBody(theme),
    );
  }

  PreferredSizeWidget _buildAppBar(ThemeData theme) => AppBar(
    backgroundColor: theme.colorScheme.surface,
    elevation: 0,
    leading: IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => context.pop(),
    ),
    title: Text(
      'Security Settings',
      style: theme.textTheme.headlineSmall?.copyWith(
        fontWeight: FontWeight.bold,
      ),
    ),
  );

  Widget _buildBody(ThemeData theme) {
    if (_isLoading) {
      return _buildLoadingState(theme);
    }

    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) => FadeTransition(
        opacity: _fadeAnimation,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            _buildPasswordSection(theme),
            const SizedBox(height: AppSpacing.lg),
            _buildAuthenticationSection(theme),
            const SizedBox(height: AppSpacing.lg),
            _buildSecurityAlertsSection(theme),
            const SizedBox(height: AppSpacing.lg),
            _buildLoginHistorySection(theme),
            const SizedBox(height: AppSpacing.lg),
            _buildDangerZoneSection(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState(ThemeData theme) => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircularProgressIndicator(color: theme.colorScheme.primary),
        const SizedBox(height: AppSpacing.lg),
        Text(
          'Loading security settings...',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.outline,
          ),
        ),
      ],
    ),
  );

  Widget _buildPasswordSection(ThemeData theme) => Container(
    decoration: BoxDecoration(
      color: theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: theme.colorScheme.shadow.withOpacity(0.1),
          blurRadius: 20,
          offset: const Offset(0, 10),
        ),
      ],
    ),
    child: Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.lock, color: Colors.red, size: 24),
              ),
              const SizedBox(width: AppSpacing.md),
              Text(
                'Password & Security',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          _buildSecurityOption(
            'Change Password',
            'Update your account password',
            Icons.key,
            theme,
            _changePassword,
          ),
          const SizedBox(height: AppSpacing.sm),
          _buildSecurityOption(
            'Password Requirements',
            'View password security requirements',
            Icons.security,
            theme,
            () => _showPasswordRequirements(theme),
          ),
        ],
      ),
    ),
  );

  Widget _buildAuthenticationSection(ThemeData theme) => Container(
    decoration: BoxDecoration(
      color: theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: theme.colorScheme.shadow.withOpacity(0.1),
          blurRadius: 20,
          offset: const Offset(0, 10),
        ),
      ],
    ),
    child: Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.fingerprint, color: Colors.blue, size: 24),
              ),
              const SizedBox(width: AppSpacing.md),
              Text(
                'Authentication',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          _buildToggleOption(
            'Two-Factor Authentication',
            'Add an extra layer of security to your account',
            Icons.security,
            _twoFactorEnabled,
            (value) => _toggleTwoFactor(),
            theme,
          ),
          const SizedBox(height: AppSpacing.sm),
          _buildToggleOption(
            'Biometric Authentication',
            'Use fingerprint or face recognition to sign in',
            Icons.fingerprint,
            _biometricEnabled,
            (value) => _toggleBiometric(),
            theme,
          ),
        ],
      ),
    ),
  );

  Widget _buildSecurityAlertsSection(ThemeData theme) => Container(
    decoration: BoxDecoration(
      color: theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: theme.colorScheme.shadow.withOpacity(0.1),
          blurRadius: 20,
          offset: const Offset(0, 10),
        ),
      ],
    ),
    child: Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.notifications_active,
                  color: Colors.orange,
                  size: 24,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Text(
                'Security Alerts',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          _buildToggleOption(
            'Login Alerts',
            'Get notified when someone signs into your account',
            Icons.login,
            _loginAlerts,
            (value) => setState(() => _loginAlerts = value),
            theme,
          ),
          const SizedBox(height: AppSpacing.sm),
          _buildToggleOption(
            'Suspicious Activity',
            'Get alerts for unusual account activity',
            Icons.warning,
            _suspiciousActivityAlerts,
            (value) => setState(() => _suspiciousActivityAlerts = value),
            theme,
          ),
        ],
      ),
    ),
  );

  Widget _buildLoginHistorySection(ThemeData theme) => Container(
    decoration: BoxDecoration(
      color: theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: theme.colorScheme.shadow.withOpacity(0.1),
          blurRadius: 20,
          offset: const Offset(0, 10),
        ),
      ],
    ),
    child: Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.history, color: Colors.green, size: 24),
              ),
              const SizedBox(width: AppSpacing.md),
              Text(
                'Login History',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          _buildSecurityOption(
            'View Login History',
            'See recent sign-ins to your account',
            Icons.history,
            theme,
            () => _showLoginHistory(theme),
          ),
          const SizedBox(height: AppSpacing.sm),
          _buildSecurityOption(
            'Active Sessions',
            'Manage devices signed into your account',
            Icons.devices,
            theme,
            () => _showActiveSessions(theme),
          ),
        ],
      ),
    ),
  );

  Widget _buildDangerZoneSection(ThemeData theme) => Container(
    decoration: BoxDecoration(
      color: theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: Colors.red.withOpacity(0.3)),
      boxShadow: [
        BoxShadow(
          color: theme.colorScheme.shadow.withOpacity(0.1),
          blurRadius: 20,
          offset: const Offset(0, 10),
        ),
      ],
    ),
    child: Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.warning, color: Colors.red, size: 24),
              ),
              const SizedBox(width: AppSpacing.md),
              Text(
                'Danger Zone',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          _buildDangerOption(
            'Delete Account',
            'Permanently delete your account and all data',
            Icons.delete_forever,
            Colors.red,
            theme,
            () => _showDeleteAccountDialog(theme),
          ),
        ],
      ),
    ),
  );

  Widget _buildSecurityOption(
    String title,
    String subtitle,
    IconData icon,
    ThemeData theme,
    VoidCallback onTap,
  ) => Container(
    decoration: BoxDecoration(
      color: theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: theme.colorScheme.outline.withOpacity(0.2)),
    ),
    child: Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              Icon(icon, color: theme.colorScheme.outline, size: 24),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.outline,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: theme.colorScheme.outline),
            ],
          ),
        ),
      ),
    ),
  );

  Widget _buildToggleOption(
    String title,
    String subtitle,
    IconData icon,
    bool value,
    ValueChanged<bool> onChanged,
    ThemeData theme,
  ) => Container(
    decoration: BoxDecoration(
      color: theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: theme.colorScheme.outline.withOpacity(0.2)),
    ),
    child: Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          Icon(icon, color: theme.colorScheme.outline, size: 24),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: theme.colorScheme.primary,
          ),
        ],
      ),
    ),
  );

  Widget _buildDangerOption(
    String title,
    String subtitle,
    IconData icon,
    Color color,
    ThemeData theme,
    VoidCallback onTap,
  ) => Container(
    decoration: BoxDecoration(
      color: color.withOpacity(0.05),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: color.withOpacity(0.3)),
    ),
    child: Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: color,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.outline,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: color),
            ],
          ),
        ),
      ),
    ),
  );

  void _showPasswordRequirements(ThemeData theme) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Password Requirements'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Your password must contain:'),
            SizedBox(height: 8),
            Text('• At least 8 characters'),
            Text('• At least one uppercase letter'),
            Text('• At least one lowercase letter'),
            Text('• At least one number'),
            Text('• At least one special character'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showLoginHistory(ThemeData theme) {
    // TODO: Implement login history screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Login history functionality coming soon')),
    );
  }

  void _showActiveSessions(ThemeData theme) {
    // TODO: Implement active sessions screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Active sessions functionality coming soon'),
      ),
    );
  }

  void _showDeleteAccountDialog(ThemeData theme) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
          'Are you sure you want to delete your account? This action cannot be undone and all your data will be permanently removed.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // TODO: Implement account deletion
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Account deletion functionality coming soon'),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete Account'),
          ),
        ],
      ),
    );
  }
}
