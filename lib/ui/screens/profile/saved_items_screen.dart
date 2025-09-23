/// @Branch: Saved Items Screen Implementation
///
/// User's saved/favorited items from marketplace and accommodations
/// Includes filtering, sorting, and management of saved items
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/providers/auth_provider.dart';

class SavedItemsScreen extends StatefulWidget {
  const SavedItemsScreen({super.key});

  @override
  State<SavedItemsScreen> createState() => _SavedItemsScreenState();
}

class _SavedItemsScreenState extends State<SavedItemsScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  bool _isLoading = true;
  List<Map<String, dynamic>> _savedItems = [];
  String _selectedFilter = 'all';
  String _selectedSort = 'recent';

  final List<String> _filters = [
    'all',
    'marketplace',
    'accommodation',
    'events',
  ];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadSavedItems();
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

  Future<void> _loadSavedItems() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = context.read<AuthProvider>();
      final user = authProvider.currentUser;

      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please sign in to view saved items')),
        );
        return;
      }

      // TODO: Implement getSavedItemsByUserId in SupabaseRepository
      // For now, using mock data
      await Future<void>.delayed(const Duration(seconds: 1));

      setState(() {
        _savedItems = [
          {
            'id': '1',
            'type': 'marketplace',
            'title': 'MacBook Pro 13"',
            'description': 'Excellent condition, barely used',
            'price': 1200.0,
            'image':
                'https://images.unsplash.com/photo-1517336714731-489689fd1ca8?w=400',
            'location': 'Harare, Zimbabwe',
            'saved_at': '2024-01-15T10:00:00Z',
            'category': 'electronics',
            'condition': 'excellent',
          },
          {
            'id': '2',
            'type': 'accommodation',
            'title': 'Modern Apartment near Campus',
            'description': '2 bedroom apartment with modern amenities',
            'price': 800.0,
            'image':
                'https://images.unsplash.com/photo-1560448204-e02f11c3d0e2?w=400',
            'location': 'Harare, Zimbabwe',
            'saved_at': '2024-01-20T14:30:00Z',
            'room_type': 'full_room',
            'property_type': 'apartment',
          },
          {
            'id': '3',
            'type': 'events',
            'title': 'Tech Conference 2024',
            'description': 'Annual technology conference with industry leaders',
            'price': 0.0,
            'image':
                'https://images.unsplash.com/photo-1540575467063-178a50c2df87?w=400',
            'location': 'Harare, Zimbabwe',
            'saved_at': '2024-01-25T09:15:00Z',
            'date': '2024-03-15',
            'time': '09:00',
            'category': 'conference',
          },
        ];
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading saved items: $e')),
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

  Future<void> _removeSavedItem(String itemId) async {
    try {
      // TODO: Implement removeSavedItem in SupabaseRepository
      await Future<void>.delayed(const Duration(seconds: 1));

      setState(() {
        _savedItems.removeWhere((item) => item['id'] == itemId);
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Item removed from saved items')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error removing item: $e')));
      }
    }
  }

  List<Map<String, dynamic>> get _filteredAndSortedItems {
    List<Map<String, dynamic>> filtered = _savedItems;

    // Filter by type
    if (_selectedFilter != 'all') {
      filtered = _savedItems
          .where((item) => (item['type'] as String) == _selectedFilter)
          .toList();
    }

    // Sort items
    switch (_selectedSort) {
      case 'name':
        filtered.sort(
          (a, b) => (a['title'] as String).compareTo(b['title'] as String),
        );
        break;
      case 'price':
        filtered.sort(
          (a, b) => (b['price'] as num).compareTo(a['price'] as num),
        );
        break;
      case 'recent':
      default:
        filtered.sort(
          (a, b) =>
              (b['saved_at'] as String).compareTo(a['saved_at'] as String),
        );
        break;
    }

    return filtered;
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
        'Saved Items',
        style: theme.textTheme.headlineSmall?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: [
        PopupMenuButton<String>(
          onSelected: (value) {
            setState(() {
              _selectedSort = value;
            });
          },
          itemBuilder: (context) => [
            const PopupMenuItem(value: 'recent', child: Text('Most Recent')),
            const PopupMenuItem(value: 'name', child: Text('Name A-Z')),
            const PopupMenuItem(value: 'price', child: Text('Price High-Low')),
          ],
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.sm),
            child: Icon(Icons.sort, color: theme.colorScheme.primary),
          ),
        ),
        IconButton(icon: const Icon(Icons.refresh), onPressed: _loadSavedItems),
      ],
    );

  Widget _buildBody(ThemeData theme) {
    if (_isLoading) {
      return _buildLoadingState(theme);
    }

    if (_savedItems.isEmpty) {
      return _buildEmptyState(theme);
    }

    return Column(
      children: [
        _buildFilterChips(theme),
        Expanded(child: _buildItemsList(theme)),
      ],
    );
  }

  Widget _buildLoadingState(ThemeData theme) => Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: theme.colorScheme.primary),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Loading your saved items...',
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
                Icons.favorite_border,
                size: 64,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(
              'No Saved Items',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'You haven\'t saved any items yet. Start exploring and save items you like!',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: () => context.go('/marketplace'),
                  icon: const Icon(Icons.store),
                  label: const Text('Browse Marketplace'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                      vertical: AppSpacing.md,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                ElevatedButton.icon(
                  onPressed: () => context.go('/accommodation'),
                  icon: const Icon(Icons.hotel),
                  label: const Text('Find Housing'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                      vertical: AppSpacing.md,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );

  Widget _buildFilterChips(ThemeData theme) => Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _filters.length,
        itemBuilder: (context, index) {
          final filter = _filters[index];
          final isSelected = _selectedFilter == filter;

          return Padding(
            padding: const EdgeInsets.only(right: AppSpacing.sm),
            child: FilterChip(
              label: Text(_getFilterLabel(filter)),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedFilter = filter;
                });
              },
              selectedColor: theme.colorScheme.primary.withOpacity(0.2),
              checkmarkColor: theme.colorScheme.primary,
              labelStyle: TextStyle(
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.outline,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          );
        },
      ),
    );

  String _getFilterLabel(String filter) {
    switch (filter) {
      case 'marketplace':
        return 'Products';
      case 'accommodation':
        return 'Housing';
      case 'events':
        return 'Events';
      case 'all':
      default:
        return 'All';
    }
  }

  Widget _buildItemsList(ThemeData theme) {
    final filteredItems = _filteredAndSortedItems;

    if (filteredItems.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.filter_list, size: 64, color: theme.colorScheme.outline),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'No items found',
              style: theme.textTheme.titleLarge?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Try selecting a different filter',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
          ],
        ),
      );
    }

    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) => FadeTransition(
          opacity: _fadeAnimation,
          child: ListView.builder(
            padding: const EdgeInsets.all(AppSpacing.lg),
            itemCount: filteredItems.length,
            itemBuilder: (context, index) {
              return AnimatedBuilder(
                animation: _slideAnimation,
                builder: (context, child) {
                  return SlideTransition(
                    position: _slideAnimation,
                    child: _buildItemCard(theme, filteredItems[index], index),
                  );
                },
              );
            },
          ),
        ),
    );
  }

  Widget _buildItemCard(ThemeData theme, Map<String, dynamic> item, int index) => Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.lg),
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
      child: Column(
        children: [
          _buildItemHeader(theme, item),
          _buildItemContent(theme, item),
          _buildItemActions(theme, item),
        ],
      ),
    );

  Widget _buildItemHeader(ThemeData theme, Map<String, dynamic> item) => Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: _getTypeColor(theme, item['type'] as String).withOpacity(0.1),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: _getTypeColor(theme, item['type'] as String),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _getTypeLabel(item['type'] as String).toUpperCase(),
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const Spacer(),
          Text(
            _formatDate(item['saved_at'] as String),
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.outline,
            ),
          ),
        ],
      ),
    );

  Widget _buildItemContent(ThemeData theme, Map<String, dynamic> item) => Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  item['image'] as String,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 80,
                      height: 80,
                      color: theme.colorScheme.surface,
                      child: Icon(
                        _getTypeIcon(item['type'] as String),
                        color: theme.colorScheme.outline,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item['title'] as String,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      item['description'] as String,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.outline,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 16,
                          color: theme.colorScheme.outline,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            item['location'] as String,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.outline,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          _buildItemDetails(theme, item),
        ],
      ),
    );

  Widget _buildItemDetails(ThemeData theme, Map<String, dynamic> item) => Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outline.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if ((item['price'] as num) > 0)
            Text(
              '\$${item['price'] as num}',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            )
          else
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'FREE',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          if (item['type'] == 'events')
            Text(
              '${item['date'] as String} at ${item['time'] as String}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
        ],
      ),
    );

  Widget _buildItemActions(ThemeData theme, Map<String, dynamic> item) => Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => _viewItem(item),
              icon: const Icon(Icons.visibility),
              label: const Text('View Details'),
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
              onPressed: () => _showRemoveDialog(theme, item),
              icon: const Icon(Icons.favorite),
              label: const Text('Remove'),
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

  void _viewItem(Map<String, dynamic> item) {
    final type = item['type'] as String;
    final id = item['id'] as String;

    switch (type) {
      case 'marketplace':
        context.go('/marketplace/$id');
        break;
      case 'accommodation':
        context.go('/accommodation/$id');
        break;
      case 'events':
        context.go('/events/$id');
        break;
    }
  }

  void _showRemoveDialog(ThemeData theme, Map<String, dynamic> item) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove from Saved'),
        content: Text(
          'Are you sure you want to remove "${item['title'] as String}" from your saved items?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _removeSavedItem(item['id'] as String);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }

  Color _getTypeColor(ThemeData theme, String type) {
    switch (type) {
      case 'marketplace':
        return Colors.blue;
      case 'accommodation':
        return Colors.green;
      case 'events':
        return Colors.purple;
      default:
        return theme.colorScheme.outline;
    }
  }

  String _getTypeLabel(String type) {
    switch (type) {
      case 'marketplace':
        return 'Product';
      case 'accommodation':
        return 'Housing';
      case 'events':
        return 'Event';
      default:
        return type;
    }
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'marketplace':
        return Icons.store;
      case 'accommodation':
        return Icons.hotel;
      case 'events':
        return Icons.event;
      default:
        return Icons.favorite;
    }
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays == 0) {
        return 'Today';
      } else if (difference.inDays == 1) {
        return 'Yesterday';
      } else if (difference.inDays < 7) {
        return '${difference.inDays} days ago';
      } else {
        return '${date.day}/${date.month}/${date.year}';
      }
    } catch (e) {
      return dateString;
    }
  }
}
