/// @Branch: Location Settings Screen Implementation
///
/// User location settings and permissions management
/// Includes location sharing, privacy controls, and location-based features
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_spacing.dart';

class LocationSettingsScreen extends StatefulWidget {
  const LocationSettingsScreen({super.key});

  @override
  State<LocationSettingsScreen> createState() => _LocationSettingsScreenState();
}

class _LocationSettingsScreenState extends State<LocationSettingsScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;

  bool _isLoading = true;
  bool _locationEnabled = true;
  bool _preciseLocation = true;
  bool _locationSharing = true;
  bool _nearbyEvents = true;
  bool _nearbyAccommodation = true;
  bool _locationHistory = false;
  String _locationAccuracy = 'high';

  final List<String> _accuracyOptions = ['high', 'medium', 'low'];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadLocationSettings();
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

  Future<void> _loadLocationSettings() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // TODO: Implement getLocationSettings in FirebaseRepository
      await Future<void>.delayed(const Duration(seconds: 1));

      setState(() {
        _locationEnabled = true;
        _preciseLocation = true;
        _locationSharing = true;
        _nearbyEvents = true;
        _nearbyAccommodation = true;
        _locationHistory = false;
        _locationAccuracy = 'high';
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading location settings: $e')),
        );
      }
    }
  }

  Future<void> _saveLocationSettings() async {
    try {
      // TODO: Implement saveLocationSettings in FirebaseRepository
      await Future<void>.delayed(const Duration(seconds: 1));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location settings saved successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving location settings: $e')),
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
        onPressed: _saveLocationSettings,
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
      'Location Settings',
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
            _buildLocationInfoSection(theme),
            const SizedBox(height: AppSpacing.lg),
            _buildLocationPermissionsSection(theme),
            const SizedBox(height: AppSpacing.lg),
            _buildLocationSharingSection(theme),
            const SizedBox(height: AppSpacing.lg),
            _buildLocationFeaturesSection(theme),
            const SizedBox(height: AppSpacing.lg),
            _buildLocationAccuracySection(theme),
            const SizedBox(height: AppSpacing.lg),
            _buildLocationHistorySection(theme),
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
          'Loading location settings...',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.outline,
          ),
        ),
      ],
    ),
  );

  Widget _buildLocationInfoSection(ThemeData theme) => Container(
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
                child: Icon(Icons.location_on, color: Colors.blue, size: 24),
              ),
              const SizedBox(width: AppSpacing.md),
              Text(
                'Location Services',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Location services help us provide you with relevant content and features. You can control how your location data is used.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.outline,
            ),
          ),
        ],
      ),
    ),
  );

  Widget _buildLocationPermissionsSection(ThemeData theme) => Container(
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
                child: Icon(Icons.security, color: Colors.green, size: 24),
              ),
              const SizedBox(width: AppSpacing.md),
              Text(
                'Location Permissions',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          _buildToggleOption(
            'Enable Location Services',
            'Allow the app to access your location',
            Icons.location_on,
            _locationEnabled,
            (value) => setState(() => _locationEnabled = value),
            theme,
          ),
          const SizedBox(height: AppSpacing.sm),
          _buildToggleOption(
            'Precise Location',
            'Use your exact location for better results',
            Icons.my_location,
            _preciseLocation,
            (value) => setState(() => _preciseLocation = value),
            theme,
          ),
        ],
      ),
    ),
  );

  Widget _buildLocationSharingSection(ThemeData theme) => Container(
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
                  Icons.share_location,
                  color: Colors.orange,
                  size: 24,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Text(
                'Location Sharing',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          _buildToggleOption(
            'Share Location',
            'Allow others to see your general location',
            Icons.public,
            _locationSharing,
            (value) => setState(() => _locationSharing = value),
            theme,
          ),
        ],
      ),
    ),
  );

  Widget _buildLocationFeaturesSection(ThemeData theme) => Container(
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
                child: Icon(Icons.explore, color: Colors.purple, size: 24),
              ),
              const SizedBox(width: AppSpacing.md),
              Text(
                'Location-Based Features',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          _buildToggleOption(
            'Nearby Events',
            'Show events happening near you',
            Icons.event,
            _nearbyEvents,
            (value) => setState(() => _nearbyEvents = value),
            theme,
          ),
          const SizedBox(height: AppSpacing.sm),
          _buildToggleOption(
            'Nearby Accommodation',
            'Show accommodation options near you',
            Icons.hotel,
            _nearbyAccommodation,
            (value) => setState(() => _nearbyAccommodation = value),
            theme,
          ),
        ],
      ),
    ),
  );

  Widget _buildLocationAccuracySection(ThemeData theme) => Container(
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
                child: Icon(Icons.tune, color: Colors.teal, size: 24),
              ),
              const SizedBox(width: AppSpacing.md),
              Text(
                'Location Accuracy',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Choose how accurate your location should be:',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.outline,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          ..._accuracyOptions.map(
            (option) => _buildAccuracyOption(
              option,
              _getAccuracyDescription(option),
              _locationAccuracy == option,
              theme,
              () => setState(() => _locationAccuracy = option),
            ),
          ),
        ],
      ),
    ),
  );

  Widget _buildLocationHistorySection(ThemeData theme) => Container(
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
                child: Icon(Icons.history, color: Colors.red, size: 24),
              ),
              const SizedBox(width: AppSpacing.md),
              Text(
                'Location History',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          _buildToggleOption(
            'Save Location History',
            'Keep a record of your location data',
            Icons.save,
            _locationHistory,
            (value) => setState(() => _locationHistory = value),
            theme,
          ),
          const SizedBox(height: AppSpacing.md),
          _buildLocationOption(
            'Clear Location History',
            'Delete all stored location data',
            Icons.delete_forever,
            Colors.red,
            theme,
            () => _showClearHistoryDialog(theme),
          ),
        ],
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

  Widget _buildLocationOption(
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

  Widget _buildAccuracyOption(
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
                      _getAccuracyTitle(value),
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
                groupValue: _locationAccuracy,
                onChanged: (_) => onTap(),
                activeColor: theme.colorScheme.primary,
              ),
            ],
          ),
        ),
      ),
    ),
  );

  String _getAccuracyTitle(String value) {
    switch (value) {
      case 'high':
        return 'High Accuracy';
      case 'medium':
        return 'Medium Accuracy';
      case 'low':
        return 'Low Accuracy';
      default:
        return value;
    }
  }

  String _getAccuracyDescription(String value) {
    switch (value) {
      case 'high':
        return 'Most accurate, uses GPS and other sensors';
      case 'medium':
        return 'Balanced accuracy and battery usage';
      case 'low':
        return 'Less accurate, saves battery';
      default:
        return '';
    }
  }

  void _showClearHistoryDialog(ThemeData theme) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Location History'),
        content: const Text(
          'Are you sure you want to delete all your location history? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // TODO: Implement clear location history
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Location history cleared')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Clear History'),
          ),
        ],
      ),
    );
  }
}
