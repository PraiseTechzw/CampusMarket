/// @Branch: Admin Verification Management Screen
///
/// Admin screen for managing student email verifications
/// Allows admins to approve or reject verification requests
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/services/email_validation_service.dart';

class VerificationManagementScreen extends StatefulWidget {
  const VerificationManagementScreen({super.key});

  @override
  State<VerificationManagementScreen> createState() =>
      _VerificationManagementScreenState();
}

class _VerificationManagementScreenState
    extends State<VerificationManagementScreen> {
  List<Map<String, dynamic>> _verifications = [];
  bool _isLoading = true;
  String _selectedFilter = 'all';

  @override
  void initState() {
    super.initState();
    _loadVerifications();
  }

  Future<void> _loadVerifications() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final verifications =
          await EmailValidationService.getPendingVerifications();
      setState(() {
        _verifications = verifications;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorToast('Error loading verifications: ${e.toString()}');
    }
  }

  Future<void> _approveVerification(Map<String, dynamic> verification) async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final currentUser = authProvider.currentUser;

      if (currentUser == null) {
        _showErrorToast('You must be signed in to perform this action');
        return;
      }

      final success = await EmailValidationService.approveVerification(
        userId: verification['userId'] as String,
        adminId: currentUser.id,
        notes: 'Approved by admin',
      );

      if (success) {
        _showSuccessToast('Verification approved successfully');
        _loadVerifications(); // Refresh the list
      } else {
        _showErrorToast('Failed to approve verification');
      }
    } catch (e) {
      _showErrorToast('Error: ${e.toString()}');
    }
  }

  Future<void> _rejectVerification(Map<String, dynamic> verification) async {
    final reasonController = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject Verification'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Reject verification for ${verification['email'] as String}?'),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: 'Reason for rejection',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Reject'),
          ),
        ],
      ),
    );

    if (result == true && reasonController.text.trim().isNotEmpty) {
      try {
        if (!mounted) return;
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        final currentUser = authProvider.currentUser;

        if (currentUser == null) {
          _showErrorToast('You must be signed in to perform this action');
          return;
        }

        final success = await EmailValidationService.rejectVerification(
          userId: verification['userId'] as String,
          adminId: currentUser.id,
          reason: reasonController.text.trim(),
        );

        if (success) {
          _showSuccessToast('Verification rejected');
          _loadVerifications(); // Refresh the list
        } else {
          _showErrorToast('Failed to reject verification');
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
        toastLength: Toast.LENGTH_SHORT,
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
        toastLength: Toast.LENGTH_SHORT,
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Verification Management'),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadVerifications,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _verifications.isEmpty
          ? _buildEmptyState(theme)
          : _buildVerificationsList(theme),
    );
  }

  Widget _buildEmptyState(ThemeData theme) => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.verified_user, size: 64, color: theme.colorScheme.outline),
        const SizedBox(height: AppSpacing.md),
        Text(
          'No pending verifications',
          style: theme.textTheme.headlineSmall?.copyWith(
            color: theme.colorScheme.outline,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'All verification requests have been processed',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.outline,
          ),
        ),
      ],
    ),
  );

  Widget _buildVerificationsList(ThemeData theme) => ListView.builder(
    padding: const EdgeInsets.all(AppSpacing.md),
    itemCount: _verifications.length,
    itemBuilder: (context, index) {
      final verification = _verifications[index];
      return _buildVerificationCard(verification, theme);
    },
  );

  Widget _buildVerificationCard(
    Map<String, dynamic> verification,
    ThemeData theme,
  ) => Card(
    margin: const EdgeInsets.only(bottom: AppSpacing.md),
    child: Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with name and email
          Row(
            children: [
              CircleAvatar(
                backgroundColor: theme.colorScheme.primary,
                child: Text(
                  '${verification['firstName'][0]}${verification['lastName'][0]}'
                      .toUpperCase(),
                  style: TextStyle(
                    color: theme.colorScheme.onPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${verification['firstName']} ${verification['lastName']}',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      verification['email'] as String,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.outline,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'PENDING',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: Colors.orange[700],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // University and student ID
          Row(
            children: [
              Icon(Icons.school, size: 16, color: theme.colorScheme.outline),
              const SizedBox(width: AppSpacing.xs),
              Text(
                (verification['university'] as String?) ?? 'Unknown University',
                style: theme.textTheme.bodyMedium,
              ),
            ],
          ),
          if (verification['studentId'] != null) ...[
            const SizedBox(height: AppSpacing.xs),
            Row(
              children: [
                Icon(Icons.badge, size: 16, color: theme.colorScheme.outline),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  'ID: ${verification['studentId']}',
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
          ],
          const SizedBox(height: AppSpacing.md),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _rejectVerification(verification),
                  icon: const Icon(Icons.close),
                  label: const Text('Reject'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: BorderSide(color: Colors.red),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _approveVerification(verification),
                  icon: const Icon(Icons.check),
                  label: const Text('Approve'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}
