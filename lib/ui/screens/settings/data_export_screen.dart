/// @Branch: Data Export Screen Implementation
///
/// User data export and download functionality
/// Includes data export options, download history, and data management
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_spacing.dart';

class DataExportScreen extends StatefulWidget {
  const DataExportScreen({super.key});

  @override
  State<DataExportScreen> createState() => _DataExportScreenState();
}

class _DataExportScreenState extends State<DataExportScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;

  bool _isLoading = true;
  List<Map<String, dynamic>> _exportHistory = [];
  bool _isExporting = false;
  String _selectedFormat = 'json';

  final List<String> _exportFormats = ['json', 'csv', 'pdf'];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadExportHistory();
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

  Future<void> _loadExportHistory() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // TODO: Implement getExportHistory in FirebaseRepository
      await Future<void>.delayed(const Duration(seconds: 1));

      setState(() {
        _exportHistory = [
          {
            'id': '1',
            'format': 'json',
            'date': '2024-01-15T10:00:00Z',
            'status': 'completed',
            'size': '2.5 MB',
            'downloadUrl': 'https://example.com/export1.json',
          },
          {
            'id': '2',
            'format': 'csv',
            'date': '2024-01-10T14:30:00Z',
            'status': 'completed',
            'size': '1.8 MB',
            'downloadUrl': 'https://example.com/export2.csv',
          },
          {
            'id': '3',
            'format': 'pdf',
            'date': '2024-01-05T09:15:00Z',
            'status': 'expired',
            'size': '3.2 MB',
            'downloadUrl': null,
          },
        ];
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading export history: $e')),
        );
      }
    }
  }

  Future<void> _requestDataExport() async {
    setState(() {
      _isExporting = true;
    });

    try {
      // TODO: Implement requestDataExport in FirebaseRepository
      await Future<void>.delayed(const Duration(seconds: 2));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Data export request submitted. You will receive an email when ready.',
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error requesting data export: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isExporting = false;
        });
      }
    }
  }

  Future<void> _downloadExport(String exportId) async {
    // TODO: Implement download functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Download functionality coming soon')),
    );
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
      'Data Export',
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
            _buildExportInfoSection(theme),
            const SizedBox(height: AppSpacing.lg),
            _buildExportOptionsSection(theme),
            const SizedBox(height: AppSpacing.lg),
            _buildExportHistorySection(theme),
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
          'Loading export options...',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.outline,
          ),
        ),
      ],
    ),
  );

  Widget _buildExportInfoSection(ThemeData theme) => Container(
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
                child: Icon(Icons.info, color: Colors.blue, size: 24),
              ),
              const SizedBox(width: AppSpacing.md),
              Text(
                'About Data Export',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'You can download a copy of your data at any time. This includes:',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.outline,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          _buildDataItem('Profile information', theme),
          _buildDataItem('Marketplace listings and transactions', theme),
          _buildDataItem('Accommodation bookings', theme),
          _buildDataItem('Event tickets and RSVPs', theme),
          _buildDataItem('Messages and communications', theme),
          _buildDataItem('App preferences and settings', theme),
        ],
      ),
    ),
  );

  Widget _buildDataItem(String text, ThemeData theme) => Padding(
    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
    child: Row(
      children: [
        Icon(Icons.check_circle, size: 16, color: theme.colorScheme.primary),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            text,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.outline,
            ),
          ),
        ),
      ],
    ),
  );

  Widget _buildExportOptionsSection(ThemeData theme) => Container(
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
                child: Icon(Icons.download, color: Colors.green, size: 24),
              ),
              const SizedBox(width: AppSpacing.md),
              Text(
                'Export Options',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Choose export format:',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.outline,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          ..._exportFormats.map(
            (format) => _buildFormatOption(
              format,
              _getFormatDescription(format),
              _selectedFormat == format,
              theme,
              () => setState(() => _selectedFormat = format),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isExporting ? null : _requestDataExport,
              icon: _isExporting
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.download),
              label: Text(
                _isExporting ? 'Preparing Export...' : 'Request Data Export',
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );

  Widget _buildExportHistorySection(ThemeData theme) => Container(
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
                child: Icon(Icons.history, color: Colors.orange, size: 24),
              ),
              const SizedBox(width: AppSpacing.md),
              Text(
                'Export History',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          if (_exportHistory.isEmpty)
            _buildEmptyHistory(theme)
          else
            ..._exportHistory.map((export) => _buildExportItem(export, theme)),
        ],
      ),
    ),
  );

  Widget _buildEmptyHistory(ThemeData theme) => Center(
    child: Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        children: [
          Icon(Icons.history, size: 64, color: theme.colorScheme.outline),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'No Export History',
            style: theme.textTheme.titleLarge?.copyWith(
              color: theme.colorScheme.outline,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Your data export history will appear here',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.outline,
            ),
          ),
        ],
      ),
    ),
  );

  Widget _buildFormatOption(
    String format,
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
                      format.toUpperCase(),
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
                value: format,
                groupValue: _selectedFormat,
                onChanged: (_) => onTap(),
                activeColor: theme.colorScheme.primary,
              ),
            ],
          ),
        ),
      ),
    ),
  );

  Widget _buildExportItem(
    Map<String, dynamic> export,
    ThemeData theme,
  ) => Container(
    margin: const EdgeInsets.only(bottom: AppSpacing.md),
    decoration: BoxDecoration(
      color: theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: theme.colorScheme.outline.withOpacity(0.2)),
    ),
    child: Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: _getStatusColor(
                export['status'] as String,
              ).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _getStatusIcon(export['status'] as String),
              color: _getStatusColor(export['status'] as String),
              size: 20,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${export['format'] as String} Export',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${export['size'] as String} • ${_formatDate(export['date'] as String)}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                ),
              ],
            ),
          ),
          if (export['status'] == 'completed' && export['downloadUrl'] != null)
            IconButton(
              onPressed: () => _downloadExport(export['id'] as String),
              icon: const Icon(Icons.download),
              color: theme.colorScheme.primary,
            ),
        ],
      ),
    ),
  );

  String _getFormatDescription(String format) {
    switch (format) {
      case 'json':
        return 'Machine-readable format, includes all data';
      case 'csv':
        return 'Spreadsheet format, good for data analysis';
      case 'pdf':
        return 'Human-readable format, includes reports';
      default:
        return '';
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'completed':
        return Colors.green;
      case 'processing':
        return Colors.orange;
      case 'expired':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'completed':
        return Icons.check_circle;
      case 'processing':
        return Icons.hourglass_empty;
      case 'expired':
        return Icons.schedule;
      default:
        return Icons.help;
    }
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateString;
    }
  }
}
