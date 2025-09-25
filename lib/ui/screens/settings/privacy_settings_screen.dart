/// @Branch: Privacy Settings Screen Implementation
///
/// User privacy settings with profile visibility, data sharing, and privacy controls
/// Includes profile visibility, data sharing preferences, and privacy options
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_spacing.dart';

class PrivacySettingsScreen extends StatefulWidget {
  const PrivacySettingsScreen({super.key});

  @override
  State<PrivacySettingsScreen> createState() => _PrivacySettingsScreenState();
}

class _PrivacySettingsScreenState extends State<PrivacySettingsScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;

  bool _isLoading = true;
  String _profileVisibility = 'public';
  bool _showEmail = true;
  bool _showPhone = false;
  bool _showLocation = true;
  bool _allowMessages = true;
  bool _showOnlineStatus = true;
  bool _dataAnalytics = true;
  bool _marketingEmails = false;

  final List<String> _visibilityOptions = ['public', 'friends', 'private'];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadPrivacySettings();
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

  Future<void> _loadPrivacySettings() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // TODO: Implement getPrivacySettings in FirebaseRepository
      await Future<void>.delayed(const Duration(seconds: 1));

      setState(() {
        _profileVisibility = 'public';
        _showEmail = true;
        _showPhone = false;
        _showLocation = true;
        _allowMessages = true;
        _showOnlineStatus = true;
        _dataAnalytics = true;
        _marketingEmails = false;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading privacy settings: $e')),
        );
      }
    }
  }

  Future<void> _savePrivacySettings() async {
    try {
      // TODO: Implement savePrivacySettings in FirebaseRepository
      await Future<void>.delayed(const Duration(seconds: 1));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Privacy settings saved successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving privacy settings: $e')),
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _savePrivacySettings,
        icon: const Icon(Icons.save),
        label: const Text('Save Settings'),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: Colors.white,
      ),
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
      'Privacy Settings',
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
            _buildProfileVisibilitySection(theme),
            const SizedBox(height: AppSpacing.lg),
            _buildContactInfoSection(theme),
            const SizedBox(height: AppSpacing.lg),
            _buildActivitySection(theme),
            const SizedBox(height: AppSpacing.lg),
            _buildDataSharingSection(theme),
            const SizedBox(height: AppSpacing.lg),
            _buildMarketingSection(theme),
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
          'Loading privacy settings...',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.outline,
          ),
        ),
      ],
    ),
  );

  Widget _buildProfileVisibilitySection(ThemeData theme) => Container(
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
                child: Icon(Icons.visibility, color: Colors.blue, size: 24),
              ),
              const SizedBox(width: AppSpacing.md),
              Text(
                'Profile Visibility',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Who can see your profile?',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.outline,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          ..._visibilityOptions.map(
            (option) => _buildVisibilityOption(
              option,
              _getVisibilityDescription(option),
              _profileVisibility == option,
              theme,
              () => setState(() => _profileVisibility = option),
            ),
          ),
        ],
      ),
    ),
  );

  Widget _buildContactInfoSection(ThemeData theme) => Container(
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
                child: Icon(Icons.contact_phone, color: Colors.green, size: 24),
              ),
              const SizedBox(width: AppSpacing.md),
              Text(
                'Contact Information',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          _buildToggleOption(
            'Show Email Address',
            'Allow others to see your email address',
            Icons.email,
            _showEmail,
            (value) => setState(() => _showEmail = value),
            theme,
          ),
          const SizedBox(height: AppSpacing.sm),
          _buildToggleOption(
            'Show Phone Number',
            'Allow others to see your phone number',
            Icons.phone,
            _showPhone,
            (value) => setState(() => _showPhone = value),
            theme,
          ),
          const SizedBox(height: AppSpacing.sm),
          _buildToggleOption(
            'Show Location',
            'Allow others to see your general location',
            Icons.location_on,
            _showLocation,
            (value) => setState(() => _showLocation = value),
            theme,
          ),
        ],
      ),
    ),
  );

  Widget _buildActivitySection(ThemeData theme) => Container(
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
                child: Icon(Icons.timeline, color: Colors.orange, size: 24),
              ),
              const SizedBox(width: AppSpacing.md),
              Text(
                'Activity & Status',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          _buildToggleOption(
            'Allow Messages',
            'Let others send you messages',
            Icons.message,
            _allowMessages,
            (value) => setState(() => _allowMessages = value),
            theme,
          ),
          const SizedBox(height: AppSpacing.sm),
          _buildToggleOption(
            'Show Online Status',
            'Let others see when you\'re online',
            Icons.circle,
            _showOnlineStatus,
            (value) => setState(() => _showOnlineStatus = value),
            theme,
          ),
        ],
      ),
    ),
  );

  Widget _buildDataSharingSection(ThemeData theme) => Container(
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
                  color: Colors.purple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.data_usage, color: Colors.purple, size: 24),
              ),
              const SizedBox(width: AppSpacing.md),
              Text(
                'Data & Analytics',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          _buildToggleOption(
            'Data Analytics',
            'Help improve the app by sharing anonymous usage data',
            Icons.analytics,
            _dataAnalytics,
            (value) => setState(() => _dataAnalytics = value),
            theme,
          ),
        ],
      ),
    ),
  );

  Widget _buildMarketingSection(ThemeData theme) => Container(
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
                  color: Colors.teal.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.campaign, color: Colors.teal, size: 24),
              ),
              const SizedBox(width: AppSpacing.md),
              Text(
                'Marketing & Communications',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          _buildToggleOption(
            'Marketing Emails',
            'Receive promotional content and special offers',
            Icons.email,
            _marketingEmails,
            (value) => setState(() => _marketingEmails = value),
            theme,
          ),
        ],
      ),
    ),
  );

  Widget _buildVisibilityOption(
    String value,
    String description,
    bool isSelected,
    ThemeData theme,
    VoidCallback onTap,
  ) => Container(
    margin: const EdgeInsets.only(bottom: AppSpacing.sm),
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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getVisibilityTitle(value),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isSelected
                            ? theme.colorScheme.primary
                            : theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.outline,
                      ),
                    ),
                  ],
                ),
              ),
              Radio<String>(
                value: value,
                groupValue: _profileVisibility,
                onChanged: (_) => onTap(),
                activeColor: theme.colorScheme.primary,
              ),
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

  String _getVisibilityTitle(String value) {
    switch (value) {
      case 'public':
        return 'Public';
      case 'friends':
        return 'Friends Only';
      case 'private':
        return 'Private';
      default:
        return value;
    }
  }

  String _getVisibilityDescription(String value) {
    switch (value) {
      case 'public':
        return 'Anyone can see your profile';
      case 'friends':
        return 'Only your friends can see your profile';
      case 'private':
        return 'Only you can see your profile';
      default:
        return '';
    }
  }
}
