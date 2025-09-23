/// @Branch: Settings Screen Implementation
///
/// App settings with theme toggle, notifications, and privacy
/// Includes account management and app preferences
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/glow_card.dart';
import '../../../core/providers/theme_provider.dart';
import '../../../core/providers/auth_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
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
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: CustomScrollView(
        slivers: [
          // Enhanced App Bar
          _buildEnhancedAppBar(theme),

          // Settings content
          _buildSettingsContent(theme),
        ],
      ),
    );
  }

  Widget _buildEnhancedAppBar(ThemeData theme) => SliverAppBar(
    expandedHeight: 150,
    floating: false,
    pinned: true,
    backgroundColor: theme.colorScheme.primary,
    foregroundColor: theme.colorScheme.onPrimary,
    leading: IconButton(
      icon: const Icon(Icons.arrow_back, color: Colors.white),
      onPressed: () => context.pop(),
    ),
    flexibleSpace: FlexibleSpaceBar(
      background: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.colorScheme.primary,
              theme.colorScheme.primary.withOpacity(0.8),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Settings',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: theme.colorScheme.onPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Customize your app experience',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onPrimary.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );

  Widget _buildSettingsContent(ThemeData theme) => SliverPadding(
    padding: const EdgeInsets.all(AppSpacing.md),
    sliver: SliverList(
      delegate: SliverChildListDelegate([
        // Theme settings
        _buildThemeSection(theme),

        const SizedBox(height: AppSpacing.lg),

        // Notifications
        _buildNotificationsSection(theme),

        const SizedBox(height: AppSpacing.lg),

        // Privacy
        _buildPrivacySection(theme),

        const SizedBox(height: AppSpacing.lg),

        // Account
        _buildAccountSection(theme),

        const SizedBox(height: AppSpacing.lg),

        // About
        _buildAboutSection(theme),
      ]),
    ),
  );

  Widget _buildThemeSection(ThemeData theme) => AnimatedBuilder(
    animation: _fadeAnimation,
    builder: (context, child) {
      return FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
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
                      child: Icon(Icons.palette, color: Colors.blue, size: 24),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Text(
                      'Appearance',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: AppSpacing.lg),

                Consumer<ThemeProvider>(
                  builder: (context, themeProvider, child) {
                    return Column(
                      children: [
                        _buildThemeOption(
                          'Light',
                          'Always use light theme',
                          Icons.light_mode,
                          ThemeMode.light,
                          themeProvider.themeMode,
                          theme,
                          () => themeProvider.setThemeMode(ThemeMode.light),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        _buildThemeOption(
                          'Dark',
                          'Always use dark theme',
                          Icons.dark_mode,
                          ThemeMode.dark,
                          themeProvider.themeMode,
                          theme,
                          () => themeProvider.setThemeMode(ThemeMode.dark),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        _buildThemeOption(
                          'System',
                          'Follow system settings',
                          Icons.settings_suggest,
                          ThemeMode.system,
                          themeProvider.themeMode,
                          theme,
                          () => themeProvider.setThemeMode(ThemeMode.system),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      );
    },
  );

  Widget _buildThemeOption(
    String title,
    String subtitle,
    IconData icon,
    ThemeMode value,
    ThemeMode groupValue,
    ThemeData theme,
    VoidCallback onTap,
  ) {
    final isSelected = value == groupValue;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: isSelected
            ? theme.colorScheme.primary.withOpacity(0.1)
            : theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected
              ? theme.colorScheme.primary
              : theme.colorScheme.outline.withOpacity(0.2),
          width: isSelected ? 2 : 1,
        ),
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
                Icon(
                  icon,
                  color: isSelected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.outline,
                  size: 24,
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: isSelected
                              ? theme.colorScheme.primary
                              : theme.colorScheme.onSurface,
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
                Radio<ThemeMode>(
                  value: value,
                  groupValue: groupValue,
                  onChanged: (_) => onTap(),
                  activeColor: theme.colorScheme.primary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationsSection(ThemeData theme) => AnimatedBuilder(
    animation: _slideAnimation,
    builder: (context, child) {
      return SlideTransition(
        position: _slideAnimation,
        child: Container(
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
                        Icons.notifications,
                        color: Colors.orange,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Text(
                      'Notifications',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: AppSpacing.lg),

                _buildNotificationOption(
                  'Push Notifications',
                  'Receive notifications on your device',
                  Icons.phone_android,
                  true,
                  theme,
                  (value) {
                    // TODO: Implement notification toggle
                  },
                ),
                const SizedBox(height: AppSpacing.sm),
                _buildNotificationOption(
                  'Email Notifications',
                  'Receive notifications via email',
                  Icons.email,
                  true,
                  theme,
                  (value) {
                    // TODO: Implement email notification toggle
                  },
                ),
                const SizedBox(height: AppSpacing.sm),
                _buildNotificationOption(
                  'Marketing Emails',
                  'Receive promotional content and updates',
                  Icons.campaign,
                  false,
                  theme,
                  (value) {
                    // TODO: Implement marketing email toggle
                  },
                ),
              ],
            ),
          ),
        ),
      );
    },
  );

  Widget _buildNotificationOption(
    String title,
    String subtitle,
    IconData icon,
    bool value,
    ThemeData theme,
    ValueChanged<bool> onChanged,
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

  Widget _buildPrivacySection(ThemeData theme) => GlowCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Privacy',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: AppSpacing.md),

        ListTile(
          leading: const Icon(Icons.visibility),
          title: const Text('Profile Visibility'),
          subtitle: const Text('Control who can see your profile'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            // TODO: Implement profile visibility settings
          },
        ),

        ListTile(
          leading: const Icon(Icons.location_on),
          title: const Text('Location Sharing'),
          subtitle: const Text('Control location data sharing'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            // TODO: Implement location settings
          },
        ),

        ListTile(
          leading: const Icon(Icons.data_usage),
          title: const Text('Data Usage'),
          subtitle: const Text('Manage your data and privacy'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            // TODO: Implement data usage settings
          },
        ),
      ],
    ),
  );

  Widget _buildAccountSection(ThemeData theme) => GlowCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Account',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: AppSpacing.md),

        ListTile(
          leading: const Icon(Icons.person),
          title: const Text('Edit Profile'),
          subtitle: const Text('Update your personal information'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            // TODO: Navigate to edit profile
          },
        ),

        ListTile(
          leading: const Icon(Icons.security),
          title: const Text('Security'),
          subtitle: const Text('Password and security settings'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            // TODO: Navigate to security settings
          },
        ),

        ListTile(
          leading: const Icon(Icons.payment),
          title: const Text('Payment Methods'),
          subtitle: const Text('Manage your payment options'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            // TODO: Navigate to payment methods
          },
        ),

        ListTile(
          leading: const Icon(Icons.download),
          title: const Text('Download Data'),
          subtitle: const Text('Export your account data'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            // TODO: Implement data export
          },
        ),
      ],
    ),
  );

  Widget _buildAboutSection(ThemeData theme) => GlowCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'About',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: AppSpacing.md),

        ListTile(
          leading: const Icon(Icons.info),
          title: const Text('App Version'),
          subtitle: const Text('1.0.0'),
          onTap: () {
            // TODO: Show version info
          },
        ),

        ListTile(
          leading: const Icon(Icons.help),
          title: const Text('Help & Support'),
          subtitle: const Text('Get help and contact support'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            // TODO: Navigate to help
          },
        ),

        ListTile(
          leading: const Icon(Icons.description),
          title: const Text('Terms of Service'),
          subtitle: const Text('Read our terms and conditions'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            // TODO: Navigate to terms
          },
        ),

        ListTile(
          leading: const Icon(Icons.privacy_tip),
          title: const Text('Privacy Policy'),
          subtitle: const Text('Read our privacy policy'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            // TODO: Navigate to privacy policy
          },
        ),

        const Divider(),

        ListTile(
          leading: const Icon(Icons.logout, color: Colors.red),
          title: const Text('Sign Out'),
          subtitle: const Text('Sign out of your account'),
          onTap: () {
            _showSignOutDialog();
          },
        ),
      ],
    ),
  );

  void _showSignOutDialog() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<AuthProvider>().signOut();
              context.go('/sign-in');
            },
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }
}
