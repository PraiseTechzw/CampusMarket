/// @Branch: Data Usage Settings Screen Implementation
///
/// User data usage settings and data management
/// Includes data usage statistics, storage management, and data controls
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_spacing.dart';

class DataUsageScreen extends StatefulWidget {
  const DataUsageScreen({super.key});

  @override
  State<DataUsageScreen> createState() => _DataUsageScreenState();
}

class _DataUsageScreenState extends State<DataUsageScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;

  bool _isLoading = true;
  Map<String, dynamic> _dataUsage = {};
  List<Map<String, dynamic>> _storageItems = [];
  bool _autoSync = true;
  bool _backgroundRefresh = true;
  bool _imageCompression = true;
  String _dataSaverMode = 'off';

  final List<String> _dataSaverModes = ['off', 'medium', 'high'];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadDataUsage();
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

  Future<void> _loadDataUsage() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // TODO: Implement getDataUsage in FirebaseRepository
      await Future<void>.delayed(const Duration(seconds: 1));

      setState(() {
        _dataUsage = {
          'totalUsed': 125.5, // MB
          'images': 45.2,
          'cache': 32.1,
          'downloads': 28.3,
          'other': 19.9,
        };
        _storageItems = [
          {
            'name': 'Profile Images',
            'size': 15.2,
            'type': 'images',
            'lastUsed': '2024-01-15T10:00:00Z',
          },
          {
            'name': 'Marketplace Images',
            'size': 30.0,
            'type': 'images',
            'lastUsed': '2024-01-14T15:30:00Z',
          },
          {
            'name': 'App Cache',
            'size': 32.1,
            'type': 'cache',
            'lastUsed': '2024-01-15T09:00:00Z',
          },
          {
            'name': 'Downloaded Files',
            'size': 28.3,
            'type': 'downloads',
            'lastUsed': '2024-01-13T12:00:00Z',
          },
        ];
        _autoSync = true;
        _backgroundRefresh = true;
        _imageCompression = true;
        _dataSaverMode = 'off';
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading data usage: $e')));
      }
    }
  }

  Future<void> _clearCache() async {
    try {
      // TODO: Implement clear cache functionality
      await Future<void>.delayed(const Duration(seconds: 1));

      setState(() {
        _dataUsage['cache'] = 0.0;
        _storageItems.removeWhere((item) => item['type'] == 'cache');
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cache cleared successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error clearing cache: $e')));
      }
    }
  }

  Future<void> _clearDownloads() async {
    try {
      // TODO: Implement clear downloads functionality
      await Future<void>.delayed(const Duration(seconds: 1));

      setState(() {
        _dataUsage['downloads'] = 0.0;
        _storageItems.removeWhere((item) => item['type'] == 'downloads');
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Downloads cleared successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error clearing downloads: $e')));
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
      'Data Usage',
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
            _buildDataUsageOverview(theme),
            const SizedBox(height: AppSpacing.lg),
            _buildStorageBreakdown(theme),
            const SizedBox(height: AppSpacing.lg),
            _buildDataSettings(theme),
            const SizedBox(height: AppSpacing.lg),
            _buildDataSaverSection(theme),
            const SizedBox(height: AppSpacing.lg),
            _buildStorageManagement(theme),
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
          'Loading data usage...',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.outline,
          ),
        ),
      ],
    ),
  );

  Widget _buildDataUsageOverview(ThemeData theme) => Container(
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
                child: Icon(Icons.storage, color: Colors.blue, size: 24),
              ),
              const SizedBox(width: AppSpacing.md),
              Text(
                'Data Usage Overview',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: _buildUsageCard(
                  'Total Used',
                  '${(_dataUsage['totalUsed'] as num).toStringAsFixed(1)} MB',
                  Icons.storage,
                  Colors.blue,
                  theme,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: _buildUsageCard(
                  'Available',
                  '${(1000 - (_dataUsage['totalUsed'] as num)).toStringAsFixed(1)} MB',
                  Icons.check_circle,
                  Colors.green,
                  theme,
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );

  Widget _buildStorageBreakdown(ThemeData theme) => Container(
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
                child: Icon(Icons.pie_chart, color: Colors.orange, size: 24),
              ),
              const SizedBox(width: AppSpacing.md),
              Text(
                'Storage Breakdown',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          _buildStorageItem(
            'Images',
            _dataUsage['images'] as double,
            Colors.red,
            theme,
          ),
          _buildStorageItem(
            'Cache',
            _dataUsage['cache'] as double,
            Colors.orange,
            theme,
          ),
          _buildStorageItem(
            'Downloads',
            _dataUsage['downloads'] as double,
            Colors.green,
            theme,
          ),
          _buildStorageItem(
            'Other',
            _dataUsage['other'] as double,
            Colors.grey,
            theme,
          ),
        ],
      ),
    ),
  );

  Widget _buildDataSettings(ThemeData theme) => Container(
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
                child: Icon(Icons.settings, color: Colors.green, size: 24),
              ),
              const SizedBox(width: AppSpacing.md),
              Text(
                'Data Settings',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          _buildToggleOption(
            'Auto Sync',
            'Automatically sync data when connected to Wi-Fi',
            Icons.sync,
            _autoSync,
            (value) => setState(() => _autoSync = value),
            theme,
          ),
          const SizedBox(height: AppSpacing.sm),
          _buildToggleOption(
            'Background Refresh',
            'Allow app to refresh content in the background',
            Icons.refresh,
            _backgroundRefresh,
            (value) => setState(() => _backgroundRefresh = value),
            theme,
          ),
          const SizedBox(height: AppSpacing.sm),
          _buildToggleOption(
            'Image Compression',
            'Compress images to save storage space',
            Icons.compress,
            _imageCompression,
            (value) => setState(() => _imageCompression = value),
            theme,
          ),
        ],
      ),
    ),
  );

  Widget _buildDataSaverSection(ThemeData theme) => Container(
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
                child: Icon(
                  Icons.data_saver_off,
                  color: Colors.purple,
                  size: 24,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Text(
                'Data Saver Mode',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Choose your data saver level:',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.outline,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          ..._dataSaverModes.map(
            (mode) => _buildDataSaverOption(
              mode,
              _getDataSaverDescription(mode),
              _dataSaverMode == mode,
              theme,
              () => setState(() => _dataSaverMode = mode),
            ),
          ),
        ],
      ),
    ),
  );

  Widget _buildStorageManagement(ThemeData theme) => Container(
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
                child: Icon(
                  Icons.cleaning_services,
                  color: Colors.red,
                  size: 24,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Text(
                'Storage Management',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          _buildStorageAction(
            'Clear Cache',
            'Remove temporary files and cache data',
            Icons.delete_sweep,
            Colors.orange,
            theme,
            _clearCache,
          ),
          const SizedBox(height: AppSpacing.sm),
          _buildStorageAction(
            'Clear Downloads',
            'Remove downloaded files and documents',
            Icons.download_done,
            Colors.blue,
            theme,
            _clearDownloads,
          ),
          const SizedBox(height: AppSpacing.sm),
          _buildStorageAction(
            'Clear All Data',
            'Remove all app data (requires re-login)',
            Icons.warning,
            Colors.red,
            theme,
            () => _showClearAllDataDialog(theme),
          ),
        ],
      ),
    ),
  );

  Widget _buildUsageCard(
    String title,
    String value,
    IconData icon,
    Color color,
    ThemeData theme,
  ) => Container(
    padding: const EdgeInsets.all(AppSpacing.md),
    decoration: BoxDecoration(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: color.withOpacity(0.3)),
    ),
    child: Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: AppSpacing.sm),
        Text(
          value,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          title,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.outline,
          ),
        ),
      ],
    ),
  );

  Widget _buildStorageItem(
    String name,
    double size,
    Color color,
    ThemeData theme,
  ) => Padding(
    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
    child: Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            name,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Text(
          '${size.toStringAsFixed(1)} MB',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.outline,
          ),
        ),
      ],
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

  Widget _buildDataSaverOption(
    String mode,
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
                      _getDataSaverTitle(mode),
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
                value: mode,
                groupValue: _dataSaverMode,
                onChanged: (_) => onTap(),
                activeColor: theme.colorScheme.primary,
              ),
            ],
          ),
        ),
      ),
    ),
  );

  Widget _buildStorageAction(
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

  String _getDataSaverTitle(String mode) {
    switch (mode) {
      case 'off':
        return 'Data Saver Off';
      case 'medium':
        return 'Medium Data Saver';
      case 'high':
        return 'High Data Saver';
      default:
        return mode;
    }
  }

  String _getDataSaverDescription(String mode) {
    switch (mode) {
      case 'off':
        return 'Use full quality images and features';
      case 'medium':
        return 'Compress images and reduce some features';
      case 'high':
        return 'Maximum compression and minimal features';
      default:
        return '';
    }
  }

  void _showClearAllDataDialog(ThemeData theme) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Data'),
        content: const Text(
          'This will remove all app data including your account information. You will need to sign in again. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // TODO: Implement clear all data
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Clear all data functionality coming soon'),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Clear All Data'),
          ),
        ],
      ),
    );
  }
}
