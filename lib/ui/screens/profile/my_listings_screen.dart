/// @Branch: My Listings Screen Implementation
///
/// User's marketplace listings with edit, delete, and status management
/// Includes filtering, sorting, and analytics
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/models/marketplace_item.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/repositories/firebase_repository.dart';
import '../../../core/theme/app_spacing.dart';

class MyListingsScreen extends StatefulWidget {
  const MyListingsScreen({super.key});

  @override
  State<MyListingsScreen> createState() => _MyListingsScreenState();
}

class _MyListingsScreenState extends State<MyListingsScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  List<MarketplaceItem> _listings = [];
  bool _isLoading = true;
  String _selectedFilter = 'all';
  String _sortBy = 'newest';

  final List<String> _filters = ['all', 'active', 'sold', 'draft'];
  final List<String> _sortOptions = [
    'newest',
    'oldest',
    'price_high',
    'price_low',
  ];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadListings();
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

  Future<void> _loadListings() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = context.read<AuthProvider>();
      final user = authProvider.currentUser;

      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please sign in to view your listings')),
        );
        return;
      }

      final products = await FirebaseRepository.getProducts();
      final userListings = products
          .where((product) => product['seller_id'] == user.id)
          .map(MarketplaceItem.fromJson)
          .toList();

      setState(() {
        _listings = userListings;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading listings: $e')));
      }
    }
  }

  Future<void> _deleteListing(MarketplaceItem item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Listing'),
        content: Text('Are you sure you want to delete "${item.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed ?? false) {
      try {
        await FirebaseRepository.deleteProduct(item.id);

        setState(() {
          _listings.removeWhere((listing) => listing.id == item.id);
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Listing deleted successfully')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error deleting listing: $e')));
        }
      }
    }
  }

  Future<void> _toggleListingStatus(MarketplaceItem item) async {
    try {
      final updatedItem = item.copyWith(isAvailable: !item.isAvailable);

      await FirebaseRepository.updateProduct(
        updatedItem.id,
        updatedItem.toJson(),
      );

      setState(() {
        final index = _listings.indexWhere((listing) => listing.id == item.id);
        if (index != -1) {
          _listings[index] = updatedItem;
        }
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              updatedItem.isAvailable
                  ? 'Listing activated successfully'
                  : 'Listing deactivated successfully',
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error updating listing: $e')));
      }
    }
  }

  List<MarketplaceItem> _getFilteredListings() {
    List<MarketplaceItem> filtered = _listings;

    // Apply filter
    switch (_selectedFilter) {
      case 'active':
        filtered = filtered.where((item) => item.isAvailable).toList();
        break;
      case 'sold':
        filtered = filtered.where((item) => !item.isAvailable).toList();
        break;
      case 'draft':
        // TODO: Implement draft status
        break;
    }

    // Apply sorting
    switch (_sortBy) {
      case 'newest':
        filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case 'oldest':
        filtered.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        break;
      case 'price_high':
        filtered.sort((a, b) => b.price.compareTo(a.price));
        break;
      case 'price_low':
        filtered.sort((a, b) => a.price.compareTo(b.price));
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
      body: _isLoading ? _buildLoadingState(theme) : _buildBody(theme),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go('/marketplace/create'),
        icon: const Icon(Icons.add),
        label: const Text('New Listing'),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
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
      'My Listings',
      style: theme.textTheme.headlineSmall?.copyWith(
        fontWeight: FontWeight.bold,
      ),
    ),
    actions: [
      IconButton(icon: const Icon(Icons.refresh), onPressed: _loadListings),
    ],
  );

  Widget _buildLoadingState(ThemeData theme) => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircularProgressIndicator(color: theme.colorScheme.primary),
        const SizedBox(height: AppSpacing.md),
        Text(
          'Loading your listings...',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.outline,
          ),
        ),
      ],
    ),
  );

  Widget _buildBody(ThemeData theme) {
    final filteredListings = _getFilteredListings();

    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) => FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            // Filters and Sort
            _buildFiltersSection(theme),

            // Stats
            _buildStatsSection(theme),

            // Listings
            Expanded(
              child: filteredListings.isEmpty
                  ? _buildEmptyState(theme)
                  : _buildListingsList(theme, filteredListings),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFiltersSection(ThemeData theme) => Container(
    padding: const EdgeInsets.all(AppSpacing.md),
    child: Row(
      children: [
        // Filter dropdown
        Expanded(
          child: DropdownButtonFormField<String>(
            value: _selectedFilter,
            decoration: InputDecoration(
              labelText: 'Filter',
              prefixIcon: const Icon(Icons.filter_list),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
            ),
            items: _filters
                .map(
                  (filter) => DropdownMenuItem(
                    value: filter,
                    child: Text(filter.toUpperCase()),
                  ),
                )
                .toList(),
            onChanged: (value) {
              setState(() {
                _selectedFilter = value!;
              });
            },
          ),
        ),

        const SizedBox(width: AppSpacing.md),

        // Sort dropdown
        Expanded(
          child: DropdownButtonFormField<String>(
            value: _sortBy,
            decoration: InputDecoration(
              labelText: 'Sort',
              prefixIcon: const Icon(Icons.sort),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
            ),
            items: _sortOptions
                .map(
                  (sort) => DropdownMenuItem(
                    value: sort,
                    child: Text(sort.replaceAll('_', ' ').toUpperCase()),
                  ),
                )
                .toList(),
            onChanged: (value) {
              setState(() {
                _sortBy = value!;
              });
            },
          ),
        ),
      ],
    ),
  );

  Widget _buildStatsSection(ThemeData theme) {
    final activeCount = _listings.where((item) => item.isAvailable).length;
    final soldCount = _listings.where((item) => !item.isAvailable).length;
    final totalViews = _listings.fold<int>(
      0,
      (sum, item) => sum + item.viewCount,
    );

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildStatItem(
              theme,
              'Active',
              activeCount.toString(),
              Icons.store,
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: theme.colorScheme.outline.withOpacity(0.2),
          ),
          Expanded(
            child: _buildStatItem(
              theme,
              'Sold',
              soldCount.toString(),
              Icons.check_circle,
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: theme.colorScheme.outline.withOpacity(0.2),
          ),
          Expanded(
            child: _buildStatItem(
              theme,
              'Views',
              totalViews.toString(),
              Icons.visibility,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    ThemeData theme,
    String label,
    String value,
    IconData icon,
  ) => Column(
    children: [
      Icon(icon, color: theme.colorScheme.primary, size: 24),
      const SizedBox(height: AppSpacing.xs),
      Text(
        value,
        style: theme.textTheme.headlineSmall?.copyWith(
          fontWeight: FontWeight.bold,
          color: theme.colorScheme.primary,
        ),
      ),
      Text(
        label,
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.outline,
        ),
      ),
    ],
  );

  Widget _buildEmptyState(ThemeData theme) => Center(
    child: Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.store_outlined,
            size: 64,
            color: theme.colorScheme.outline,
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'No listings yet',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: theme.colorScheme.outline,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Start selling by creating your first listing',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.outline,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.lg),
          ElevatedButton.icon(
            onPressed: () => context.go('/marketplace/create'),
            icon: const Icon(Icons.add),
            label: const Text('Create Listing'),
          ),
        ],
      ),
    ),
  );

  Widget _buildListingsList(ThemeData theme, List<MarketplaceItem> listings) =>
      AnimatedBuilder(
        animation: _slideAnimation,
        builder: (context, child) {
          return SlideTransition(
            position: _slideAnimation,
            child: ListView.builder(
              padding: const EdgeInsets.all(AppSpacing.md),
              itemCount: listings.length,
              itemBuilder: (context, index) {
                final listing = listings[index];
                return _buildListingCard(theme, listing);
              },
            ),
          );
        },
      );

  Widget _buildListingCard(
    ThemeData theme,
    MarketplaceItem listing,
  ) => Container(
    margin: const EdgeInsets.only(bottom: AppSpacing.md),
    decoration: BoxDecoration(
      color: theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: theme.colorScheme.shadow.withOpacity(0.1),
          blurRadius: 10,
          offset: const Offset(0, 5),
        ),
      ],
    ),
    child: Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => context.go('/marketplace/${listing.id}'),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with status and actions
              Row(
                children: [
                  // Status badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: listing.isAvailable
                          ? Colors.green.withOpacity(0.1)
                          : Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      listing.isAvailable ? 'ACTIVE' : 'SOLD',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: listing.isAvailable ? Colors.green : Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Spacer(),
                  // Actions menu
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      switch (value) {
                        case 'edit':
                          context.go('/marketplace/create?id=${listing.id}');
                          break;
                        case 'toggle':
                          _toggleListingStatus(listing);
                          break;
                        case 'delete':
                          _deleteListing(listing);
                          break;
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit),
                            SizedBox(width: AppSpacing.sm),
                            Text('Edit'),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'toggle',
                        child: Row(
                          children: [
                            Icon(
                              listing.isAvailable
                                  ? Icons.pause
                                  : Icons.play_arrow,
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Text(
                              listing.isAvailable ? 'Deactivate' : 'Activate',
                            ),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, color: Colors.red),
                            SizedBox(width: AppSpacing.sm),
                            Text('Delete', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.md),

              // Content
              Row(
                children: [
                  // Image
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: theme.colorScheme.surface,
                    ),
                    child: listing.images.isNotEmpty
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              listing.images.first,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Icon(
                                  Icons.image,
                                  color: theme.colorScheme.outline,
                                );
                              },
                            ),
                          )
                        : Icon(Icons.image, color: theme.colorScheme.outline),
                  ),

                  const SizedBox(width: AppSpacing.md),

                  // Details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          listing.title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          listing.description,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.outline,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Row(
                          children: [
                            Text(
                              '\$${listing.price.toStringAsFixed(2)}',
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              listing.createdAt.toString().split(' ')[0],
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.outline,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
