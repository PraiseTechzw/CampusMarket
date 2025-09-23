/// @Branch: Payment Methods Screen Implementation
///
/// User's payment methods management with add/edit/delete functionality
/// Includes card management, bank account setup, and payment preferences
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/providers/auth_provider.dart';

class PaymentMethodsScreen extends StatefulWidget {
  const PaymentMethodsScreen({super.key});

  @override
  State<PaymentMethodsScreen> createState() => _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends State<PaymentMethodsScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  bool _isLoading = true;
  List<Map<String, dynamic>> _paymentMethods = [];
  String _selectedMethod = '';

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadPaymentMethods();
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

  Future<void> _loadPaymentMethods() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = context.read<AuthProvider>();
      final user = authProvider.currentUser;

      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please sign in to view payment methods'),
          ),
        );
        return;
      }

      // TODO: Implement getPaymentMethodsByUserId in SupabaseRepository
      // For now, using mock data
      await Future<void>.delayed(const Duration(seconds: 1));

      setState(() {
        _paymentMethods = [
          {
            'id': '1',
            'type': 'card',
            'cardNumber': '**** **** **** 1234',
            'cardHolder': 'John Doe',
            'expiryDate': '12/25',
            'isDefault': true,
            'brand': 'visa',
          },
          {
            'id': '2',
            'type': 'card',
            'cardNumber': '**** **** **** 5678',
            'cardHolder': 'John Doe',
            'expiryDate': '08/26',
            'isDefault': false,
            'brand': 'mastercard',
          },
          {
            'id': '3',
            'type': 'bank',
            'accountNumber': '****1234',
            'bankName': 'CBZ Bank',
            'accountHolder': 'John Doe',
            'isDefault': false,
            'accountType': 'savings',
          },
        ];
        _selectedMethod =
            _paymentMethods.firstWhere(
                  (method) => method['isDefault'] as bool,
                  orElse: () => _paymentMethods.first,
                )['id']
                as String;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading payment methods: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _setDefaultMethod(String methodId) async {
    try {
      // TODO: Implement setDefaultPaymentMethod in SupabaseRepository
      await Future<void>.delayed(const Duration(seconds: 1));

      setState(() {
        // Update all methods to not be default
        for (final method in _paymentMethods) {
          method['isDefault'] = false;
        }
        // Set selected method as default
        final methodIndex = _paymentMethods.indexWhere(
          (m) => m['id'] == methodId,
        );
        if (methodIndex != -1) {
          _paymentMethods[methodIndex]['isDefault'] = true;
        }
        _selectedMethod = methodId;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Default payment method updated')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating default method: $e')),
        );
      }
    }
  }

  Future<void> _deletePaymentMethod(String methodId) async {
    try {
      // TODO: Implement deletePaymentMethod in SupabaseRepository
      await Future<void>.delayed(const Duration(seconds: 1));

      setState(() {
        _paymentMethods.removeWhere((method) => method['id'] == methodId);
        if (_selectedMethod == methodId && _paymentMethods.isNotEmpty) {
          _selectedMethod = _paymentMethods.first['id'] as String;
        }
      });

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Payment method deleted')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting payment method: $e')),
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
      floatingActionButton: _buildFloatingActionButton(theme),
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
        'Payment Methods',
        style: theme.textTheme.headlineSmall?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: _loadPaymentMethods,
        ),
      ],
    );

  Widget _buildBody(ThemeData theme) {
    if (_isLoading) {
      return _buildLoadingState(theme);
    }

    if (_paymentMethods.isEmpty) {
      return _buildEmptyState(theme);
    }

    return _buildPaymentMethodsList(theme);
  }

  Widget _buildLoadingState(ThemeData theme) => Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: theme.colorScheme.primary),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Loading payment methods...',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.outline,
            ),
          ),
        ],
      ),
    );

  Widget _buildEmptyState(ThemeData theme) => Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.xl),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.payment,
                size: 64,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(
              'No Payment Methods',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Add a payment method to make purchases and bookings easier.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            ElevatedButton.icon(
              onPressed: () => _showAddPaymentMethodDialog(theme),
              icon: const Icon(Icons.add),
              label: const Text('Add Payment Method'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xl,
                  vertical: AppSpacing.md,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );

  Widget _buildPaymentMethodsList(ThemeData theme) => AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: ListView.builder(
            padding: const EdgeInsets.all(AppSpacing.lg),
            itemCount: _paymentMethods.length,
            itemBuilder: (context, index) {
              return AnimatedBuilder(
                animation: _slideAnimation,
                builder: (context, child) {
                  return SlideTransition(
                    position: _slideAnimation,
                    child: _buildPaymentMethodCard(
                      theme,
                      _paymentMethods[index],
                      index,
                    ),
                  );
                },
              );
            },
          ),
        );
      },
    );

  Widget _buildPaymentMethodCard(
    ThemeData theme,
    Map<String, dynamic> method,
    int index,
  ) {
    final isSelected = _selectedMethod == method['id'];
    final isDefault = method['isDefault'] as bool;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.lg),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isSelected
              ? theme.colorScheme.primary
              : theme.colorScheme.outline.withOpacity(0.2),
          width: isSelected ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildPaymentMethodHeader(theme, method, isDefault),
          _buildPaymentMethodContent(theme, method),
          _buildPaymentMethodActions(theme, method),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodHeader(
    ThemeData theme,
    Map<String, dynamic> method,
    bool isDefault,
  ) => Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: _getMethodColor(
          theme,
          method['type'] as String,
        ).withOpacity(0.1),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: _getMethodColor(theme, method['type'] as String),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _getMethodIcon(method['type'] as String),
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getMethodTitle(method),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (isDefault)
                  Container(
                    margin: const EdgeInsets.only(top: AppSpacing.xs),
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'DEFAULT',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Radio<String>(
            value: method['id'] as String,
            groupValue: _selectedMethod,
            onChanged: (value) {
              if (value != null) {
                _setDefaultMethod(value);
              }
            },
            activeColor: theme.colorScheme.primary,
          ),
        ],
      ),
    );

  Widget _buildPaymentMethodContent(
    ThemeData theme,
    Map<String, dynamic> method,
  ) => Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        children: [
          if (method['type'] == 'card') ...[
            _buildCardDetails(theme, method),
          ] else if (method['type'] == 'bank') ...[
            _buildBankDetails(theme, method),
          ],
        ],
      ),
    );

  Widget _buildCardDetails(ThemeData theme, Map<String, dynamic> method) => Column(
      children: [
        Row(
          children: [
            Icon(
              _getCardBrandIcon(method['brand'] as String),
              size: 32,
              color: theme.colorScheme.outline,
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    method['cardNumber'] as String,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    method['cardHolder'] as String,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              method['expiryDate'] as String,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.outline,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );

  Widget _buildBankDetails(ThemeData theme, Map<String, dynamic> method) => Column(
      children: [
        Row(
          children: [
            Icon(
              Icons.account_balance,
              size: 32,
              color: theme.colorScheme.outline,
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    method['bankName'] as String,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    '${method['accountType'] as String} • ${method['accountNumber'] as String}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    method['accountHolder'] as String,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );

  Widget _buildPaymentMethodActions(
    ThemeData theme,
    Map<String, dynamic> method,
  ) => Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => _editPaymentMethod(theme, method),
              icon: const Icon(Icons.edit),
              label: const Text('Edit'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => _showDeleteDialog(theme, method),
              icon: const Icon(Icons.delete),
              label: const Text('Delete'),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.error,
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
    );

  Widget _buildFloatingActionButton(ThemeData theme) => FloatingActionButton.extended(
      onPressed: () => _showAddPaymentMethodDialog(theme),
      icon: const Icon(Icons.add),
      label: const Text('Add Method'),
      backgroundColor: theme.colorScheme.primary,
      foregroundColor: Colors.white,
    );

  void _editPaymentMethod(ThemeData theme, Map<String, dynamic> method) {
    // TODO: Implement edit payment method functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Edit payment method functionality coming soon'),
      ),
    );
  }

  void _showAddPaymentMethodDialog(ThemeData theme) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Payment Method'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.credit_card),
              title: const Text('Credit/Debit Card'),
              onTap: () {
                Navigator.of(context).pop();
                _showAddCardDialog(theme);
              },
            ),
            ListTile(
              leading: const Icon(Icons.account_balance),
              title: const Text('Bank Account'),
              onTap: () {
                Navigator.of(context).pop();
                _showAddBankDialog(theme);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _showAddCardDialog(ThemeData theme) {
    // TODO: Implement add card dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Add card functionality coming soon')),
    );
  }

  void _showAddBankDialog(ThemeData theme) {
    // TODO: Implement add bank account dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Add bank account functionality coming soon'),
      ),
    );
  }

  void _showDeleteDialog(ThemeData theme, Map<String, dynamic> method) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Payment Method'),
        content: Text('Are you sure you want to delete this payment method?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _deletePaymentMethod(method['id'] as String);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Color _getMethodColor(ThemeData theme, String type) {
    switch (type) {
      case 'card':
        return Colors.blue;
      case 'bank':
        return Colors.green;
      default:
        return theme.colorScheme.outline;
    }
  }

  IconData _getMethodIcon(String type) {
    switch (type) {
      case 'card':
        return Icons.credit_card;
      case 'bank':
        return Icons.account_balance;
      default:
        return Icons.payment;
    }
  }

  String _getMethodTitle(Map<String, dynamic> method) {
    switch (method['type'] as String) {
      case 'card':
        return '${_getCardBrandName(method['brand'] as String)} Card';
      case 'bank':
        return '${method['bankName'] as String} Account';
      default:
        return 'Payment Method';
    }
  }

  String _getCardBrandName(String brand) {
    switch (brand.toLowerCase()) {
      case 'visa':
        return 'Visa';
      case 'mastercard':
        return 'Mastercard';
      case 'amex':
        return 'American Express';
      default:
        return brand.toUpperCase();
    }
  }

  IconData _getCardBrandIcon(String brand) {
    switch (brand.toLowerCase()) {
      case 'visa':
        return Icons.credit_card;
      case 'mastercard':
        return Icons.credit_card;
      case 'amex':
        return Icons.credit_card;
      default:
        return Icons.credit_card;
    }
  }
}
