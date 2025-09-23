/// @Branch: User Status Widget Implementation
///
/// Widget to display user verification status and permissions
/// Shows role-based access information and verification status
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_spacing.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/services/auth_service.dart';

class UserStatusWidget extends StatefulWidget {
  const UserStatusWidget({super.key});

  @override
  State<UserStatusWidget> createState() => _UserStatusWidgetState();
}

class _UserStatusWidgetState extends State<UserStatusWidget> {
  Map<String, dynamic>? _userStatus;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserStatus();
  }

  Future<void> _loadUserStatus() async {
    try {
      final status = await AuthService.getCurrentUserStatus();
      if (mounted) {
        setState(() {
          _userStatus = status;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authProvider = Provider.of<AuthProvider>(context);

    if (!authProvider.isAuthenticated || _isLoading) {
      return const SizedBox.shrink();
    }

    if (_userStatus == null) {
      return const SizedBox.shrink();
    }

    final isVerified = (_userStatus!['isVerified'] as bool?) ?? false;
    final role = (_userStatus!['role'] as String?) ?? 'user';
    final canSell = (_userStatus!['canSell'] as bool?) ?? false;

    return Container(
      margin: const EdgeInsets.all(AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: _getStatusColor(isVerified, canSell).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _getStatusColor(isVerified, canSell).withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            _getStatusIcon(isVerified, canSell),
            color: _getStatusColor(isVerified, canSell),
            size: 24,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getStatusTitle(isVerified, canSell),
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: _getStatusColor(isVerified, canSell),
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  _getStatusMessage(isVerified, canSell, role),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
          if (!isVerified) ...[
            const SizedBox(width: AppSpacing.sm),
            TextButton(
              onPressed: _showVerificationInfo,
              child: Text(
                'Learn More',
                style: TextStyle(
                  color: _getStatusColor(isVerified, canSell),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Color _getStatusColor(bool isVerified, bool canSell) {
    if (isVerified && canSell) {
      return Colors.green;
    } else if (isVerified && !canSell) {
      return Colors.orange;
    } else {
      return Colors.blue;
    }
  }

  IconData _getStatusIcon(bool isVerified, bool canSell) {
    if (isVerified && canSell) {
      return Icons.verified;
    } else if (isVerified && !canSell) {
      return Icons.info;
    } else {
      return Icons.pending;
    }
  }

  String _getStatusTitle(bool isVerified, bool canSell) {
    if (isVerified && canSell) {
      return 'Verified Student';
    } else if (isVerified && !canSell) {
      return 'Verified User';
    } else {
      return 'Pending Verification';
    }
  }

  String _getStatusMessage(bool isVerified, bool canSell, String role) {
    if (isVerified && canSell) {
      return 'You can browse and sell items on the platform.';
    } else if (isVerified && !canSell) {
      return 'You can browse items. Contact admin for selling privileges.';
    } else {
      return 'Submit your student email for verification to sell items.';
    }
  }

  void _showVerificationInfo() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Verification Information'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'To sell items on Campus Market, you need to be verified as a student:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text('1. Use your official university email address'),
            Text('2. Wait for admin verification'),
            Text('3. Once verified, you can start selling'),
            SizedBox(height: 16),
            Text(
              'Student emails are automatically verified:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('• @uz.ac.zw (University of Zimbabwe)'),
            Text('• @nust.ac.zw (NUST)'),
            Text('• @msu.ac.zw (Midlands State University)'),
            Text('• And other recognized university domains'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }
}
