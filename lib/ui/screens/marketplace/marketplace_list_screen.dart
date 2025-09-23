/// @Branch: Marketplace List Screen Implementation
///
/// Enhanced marketplace items listing with modern UI, advanced filters and search
/// Displays all marketplace items with improved filtering capabilities and animations
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/repositories/firebase_repository.dart';
import '../../../core/models/marketplace_item.dart';
// import '../../../core/widgets/glow_card.dart';
// import '../../../core/widgets/shimmer_card.dart';
import '../../widgets/marketplace_item_card.dart';

class MarketplaceListScreen extends StatefulWidget {
  const MarketplaceListScreen({super.key});

  @override
  State<MarketplaceListScreen> createState() => _MarketplaceListScreenState();
}

class _MarketplaceListScreenState extends State<MarketplaceListScreen>
    with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'all';
  String _sortBy = 'newest';
  bool _isLoading = false;
  List<dynamic> _items = [];
  bool _isSearchFocused = false;
  late AnimationController _searchAnimationController;
  late AnimationController _filterAnimationController;
  // late Animation<double> _searchAnimation;
  // late Animation<double> _filterAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadItems();
  }

  void _initializeAnimations() {
    _searchAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _filterAnimationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    // _searchAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
    //   CurvedAnimation(parent: _searchAnimationController, curve: Curves.easeInOut),
    // );
    // _filterAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
    //   CurvedAnimation(parent: _filterAnimationController, curve: Curves.easeInOut),
    // );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchAnimationController.dispose();
    _filterAnimationController.dispose();
    super.dispose();
  }

  Future<void> _loadItems() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final itemsData = await FirebaseRepository.getMarketplaceItems(
        category: _selectedCategory != 'all' ? _selectedCategory : null,
        searchQuery: _searchController.text.isNotEmpty ? _searchController.text : null,
      );
      final items = itemsData
          .map((item) => MarketplaceItem.fromJson(item))
          .toList();

      setState(() {
        _items = items;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading items: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: CustomScrollView(
        slivers: [
          // Enhanced App Bar
          _buildSliverAppBar(theme),

          // Search and Filter Section
          _buildSearchAndFilterSection(theme),

          // Category Chips
          _buildCategoryChips(theme),

          // Items Grid
          _buildItemsGrid(theme),
        ],
      ),
      floatingActionButton: _buildFloatingActionButton(theme),
    );
  }

  Widget _buildSliverAppBar(ThemeData theme) => SliverAppBar(
    expandedHeight: 120,
    floating: false,
    pinned: true,
    backgroundColor: theme.colorScheme.surface,
    elevation: 0,
    flexibleSpace: FlexibleSpaceBar(
      title: Text(
        'Marketplace',
        style: theme.textTheme.headlineMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: theme.colorScheme.onSurface,
        ),
      ),
      background: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.colorScheme.primary.withOpacity(0.1),
              theme.colorScheme.secondary.withOpacity(0.05),
            ],
          ),
        ),
      ),
    ),
    actions: [
      IconButton(
        icon: const Icon(Icons.tune),
        onPressed: _showFilterBottomSheet,
        tooltip: 'Filters',
      ),
      IconButton(
        icon: const Icon(Icons.view_module),
        onPressed: () {
          // TODO: Toggle between grid and list view
        },
        tooltip: 'View Options',
      ),
    ],
  );

  Widget _buildSearchAndFilterSection(ThemeData theme) => SliverToBoxAdapter(
    child: Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        children: [
          // Enhanced Search Bar
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
              boxShadow: _isSearchFocused
                  ? [
                      BoxShadow(
                        color: theme.colorScheme.primary.withOpacity(0.2),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ]
                  : [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
            ),
            child: TextField(
              controller: _searchController,
              onTap: () {
                setState(() {
                  _isSearchFocused = true;
                });
                _searchAnimationController.forward();
              },
              onSubmitted: (value) {
                setState(() {
                  _isSearchFocused = false;
                });
                _searchAnimationController.reverse();
              },
              decoration: InputDecoration(
                hintText: 'Search for items, brands, or categories...',
                hintStyle: TextStyle(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: theme.colorScheme.primary,
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(
                          Icons.clear,
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {});
                          _filterItems();
                        },
                      )
                    : Icon(
                        Icons.mic,
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                filled: true,
                fillColor: theme.colorScheme.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
                  borderSide: BorderSide(
                    color: theme.colorScheme.outline.withOpacity(0.2),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
                  borderSide: BorderSide(
                    color: theme.colorScheme.primary,
                    width: 2,
                  ),
                ),
              ),
              onChanged: (value) {
                setState(() {});
                _filterItems();
              },
            ),
          ),

          const SizedBox(height: AppSpacing.md),

          // Quick Filter Chips
          _buildQuickFilterChips(theme),
        ],
      ),
    ),
  );

  Widget _buildQuickFilterChips(ThemeData theme) {
    final quickFilters = [
      {'label': 'Near Me', 'icon': Icons.location_on},
      {'label': 'New Today', 'icon': Icons.new_releases},
      {'label': r'Under $50', 'icon': Icons.attach_money},
      {'label': 'Negotiable', 'icon': Icons.handshake},
    ];

    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: quickFilters.length,
        itemBuilder: (context, index) {
          final filter = quickFilters[index];
          return Padding(
            padding: const EdgeInsets.only(right: AppSpacing.sm),
            child: FilterChip(
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    filter['icon']! as IconData,
                    size: 16,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Text(filter['label']! as String),
                ],
              ),
              onSelected: (selected) {
                // TODO: Implement quick filter logic
              },
              backgroundColor: theme.colorScheme.surface,
              selectedColor: theme.colorScheme.primary.withOpacity(0.2),
              checkmarkColor: theme.colorScheme.primary,
              side: BorderSide(
                color: theme.colorScheme.outline.withOpacity(0.3),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCategoryChips(ThemeData theme) {
    final categories = [
      {'label': 'All', 'value': 'all', 'icon': Icons.apps},
      {'label': 'Electronics', 'value': 'electronics', 'icon': Icons.devices},
      {'label': 'Books', 'value': 'books', 'icon': Icons.menu_book},
      {
        'label': 'Transportation',
        'value': 'transportation',
        'icon': Icons.directions_car,
      },
      {'label': 'Furniture', 'value': 'furniture', 'icon': Icons.chair},
      {'label': 'Clothing', 'value': 'clothing', 'icon': Icons.checkroom},
      {'label': 'Sports', 'value': 'sports', 'icon': Icons.sports},
      {'label': 'Services', 'value': 'services', 'icon': Icons.work},
    ];

    return SliverToBoxAdapter(
      child: Container(
        height: 50,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final category = categories[index];
            final isSelected = _selectedCategory == category['value'];

            return Padding(
              padding: const EdgeInsets.only(right: AppSpacing.sm),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                child: FilterChip(
                  label: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        category['icon']! as IconData,
                        size: 18,
                        color: isSelected
                            ? theme.colorScheme.onPrimary
                            : theme.colorScheme.primary,
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        category['label']! as String,
                        style: TextStyle(
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      _selectedCategory = category['value'] as String;
                    });
                    _filterItems();
                  },
                  backgroundColor: theme.colorScheme.surface,
                  selectedColor: theme.colorScheme.primary,
                  checkmarkColor: theme.colorScheme.onPrimary,
                  side: BorderSide(
                    color: isSelected
                        ? theme.colorScheme.primary
                        : theme.colorScheme.outline.withOpacity(0.3),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildItemsGrid(ThemeData theme) {
    if (_isLoading) {
      return _buildLoadingGrid();
    }

    if (_items.isEmpty) {
      return _buildEmptyState();
    }

    return SliverPadding(
      padding: const EdgeInsets.all(AppSpacing.md),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.75,
          crossAxisSpacing: AppSpacing.md,
          mainAxisSpacing: AppSpacing.md,
        ),
        delegate: SliverChildBuilderDelegate((context, index) {
          final item = _items[index];
          final itemData = item as Map<String, dynamic>;

          // Map the database response to MarketplaceItem model
          final marketplaceItem = MarketplaceItem(
            id: itemData['id']?.toString() ?? '',
            title: itemData['title']?.toString() ?? '',
            description: itemData['description']?.toString() ?? '',
            price: (itemData['price'] as num? ?? 0.0).toDouble(),
            currency: itemData['currency']?.toString() ?? 'USD',
            images: List<String>.from(itemData['images'] as List? ?? []),
            category: itemData['category']?.toString() ?? '',
            subcategory: itemData['subcategory']?.toString(),
            condition: itemData['condition']?.toString() ?? 'good',
            userId: itemData['user_id']?.toString() ?? '',
            university: itemData['university']?.toString(),
            location: itemData['location']?.toString(),
            latitude: (itemData['latitude'] as num?)?.toDouble(),
            longitude: (itemData['longitude'] as num?)?.toDouble(),
            tags: List<String>.from(itemData['tags'] as List? ?? []),
            isAvailable: itemData['is_available'] as bool? ?? true,
            isFeatured: itemData['is_featured'] as bool? ?? false,
            isNegotiable: itemData['is_negotiable'] as bool? ?? true,
            createdAt: DateTime.parse(
              itemData['created_at']?.toString() ??
                  DateTime.now().toIso8601String(),
            ),
            updatedAt: DateTime.parse(
              itemData['updated_at']?.toString() ??
                  DateTime.now().toIso8601String(),
            ),
            viewCount: itemData['view_count'] as int? ?? 0,
            favoriteCount: itemData['favorite_count'] as int? ?? 0,
            status: itemData['status']?.toString() ?? 'active',
            sellerName: itemData['users'] != null
                ? '${itemData['users']['first_name'] ?? ''} ${itemData['users']['last_name'] ?? ''}'
                      .trim()
                : 'Unknown Seller',
            sellerProfileImage: itemData['users']?['profile_image_url']
                ?.toString(),
          );

          return AnimatedContainer(
            duration: Duration(milliseconds: 300 + (index * 100)),
            curve: Curves.easeOutCubic,
            child: MarketplaceItemCard(
              item: marketplaceItem,
              onTap: () => context.go('/marketplace/${itemData['id']}'),
              onFavorite: () {
                // TODO: Implement favorite functionality
              },
            ),
          );
        }, childCount: _items.length),
      ),
    );
  }

  Widget _buildLoadingGrid() => SliverPadding(
    padding: const EdgeInsets.all(AppSpacing.md),
    sliver: SliverGrid(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: AppSpacing.md,
        mainAxisSpacing: AppSpacing.md,
      ),
      delegate: SliverChildBuilderDelegate((context, index) {
        final theme = Theme.of(context);
        return Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
            border: Border.all(
              color: theme.colorScheme.outline.withOpacity(0.1),
            ),
          ),
          child: Center(
            child: CircularProgressIndicator(color: theme.colorScheme.primary),
          ),
        );
      }, childCount: 6),
    ),
  );

  Widget _buildFloatingActionButton(ThemeData theme) =>
      FloatingActionButton.extended(
        onPressed: () => context.go('/marketplace/create'),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        icon: const Icon(Icons.add),
        label: const Text('Sell Item'),
        elevation: 8,
      );

  Widget _buildEmptyState() {
    final theme = Theme.of(context);

    return SliverFillRemaining(
      child: Center(
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
                Icons.search_off,
                size: 64,
                color: theme.colorScheme.primary.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'No items found',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Try adjusting your search or filters',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            ElevatedButton.icon(
              onPressed: () => context.go('/marketplace/create'),
              icon: const Icon(Icons.add),
              label: const Text('List Your First Item'),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xl,
                  vertical: AppSpacing.md,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildFilterBottomSheet(),
    );
  }

  Widget _buildFilterBottomSheet() {
    final theme = Theme.of(context);
    double minPrice = 0;
    double maxPrice = 1000;
    RangeValues priceRange = RangeValues(minPrice, maxPrice);

    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppSpacing.radiusXl),
        ),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: AppSpacing.md),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: theme.colorScheme.onSurface.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Row(
              children: [
                Text(
                  'Filters & Sort',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _selectedCategory = 'all';
                      _sortBy = 'newest';
                    });
                  },
                  child: const Text('Reset'),
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Sort Section
                  _buildFilterSection(
                    theme,
                    'Sort By',
                    Icons.sort,
                    [
                      {
                        'label': 'Newest First',
                        'value': 'newest',
                        'icon': Icons.new_releases,
                      },
                      {
                        'label': 'Oldest First',
                        'value': 'oldest',
                        'icon': Icons.history,
                      },
                      {
                        'label': 'Price: Low to High',
                        'value': 'price_low',
                        'icon': Icons.arrow_upward,
                      },
                      {
                        'label': 'Price: High to Low',
                        'value': 'price_high',
                        'icon': Icons.arrow_downward,
                      },
                      {
                        'label': 'Most Popular',
                        'value': 'popular',
                        'icon': Icons.trending_up,
                      },
                    ],
                    _sortBy,
                    (value) {
                      setState(() {
                        _sortBy = value;
                      });
                    },
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  // Price Range Section
                  _buildPriceRangeSection(theme, priceRange),

                  const SizedBox(height: AppSpacing.xl),

                  // Condition Section
                  _buildFilterSection(
                    theme,
                    'Condition',
                    Icons.verified,
                    [
                      {'label': 'New', 'value': 'new'},
                      {'label': 'Like New', 'value': 'like_new'},
                      {'label': 'Good', 'value': 'good'},
                      {'label': 'Fair', 'value': 'fair'},
                      {'label': 'Poor', 'value': 'poor'},
                    ],
                    null,
                    (value) {
                      // TODO: Implement condition filtering
                    },
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  // Location Section
                  _buildLocationSection(theme),

                  const SizedBox(height: AppSpacing.xl),
                ],
              ),
            ),
          ),

          // Apply Button
          Container(
            padding: const EdgeInsets.all(AppSpacing.xl),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              border: Border(
                top: BorderSide(
                  color: theme.colorScheme.outline.withOpacity(0.2),
                ),
              ),
            ),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _filterItems();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                ),
                child: const Text('Apply Filters'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection(
    ThemeData theme,
    String title,
    IconData icon,
    List<Map<String, dynamic>> options,
    String? selectedValue,
    void Function(String) onChanged,
  ) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          Icon(icon, size: 20, color: theme.colorScheme.primary),
          const SizedBox(width: AppSpacing.sm),
          Text(
            title,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
      const SizedBox(height: AppSpacing.md),
      Wrap(
        spacing: AppSpacing.sm,
        runSpacing: AppSpacing.sm,
        children: options.map((option) {
          final isSelected = selectedValue == option['value'];
          return FilterChip(
            label: Text(option['label'] as String),
            selected: isSelected,
            onSelected: (selected) {
              onChanged(option['value'] as String);
            },
            backgroundColor: theme.colorScheme.surface,
            selectedColor: theme.colorScheme.primary.withOpacity(0.2),
            checkmarkColor: theme.colorScheme.primary,
            side: BorderSide(
              color: isSelected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.outline.withOpacity(0.3),
            ),
          );
        }).toList(),
      ),
    ],
  );

  Widget _buildPriceRangeSection(ThemeData theme, RangeValues priceRange) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.attach_money,
                size: 20,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Price Range',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          RangeSlider(
            values: priceRange,
            min: 0,
            max: 1000,
            divisions: 20,
            labels: RangeLabels(
              '\$${priceRange.start.round()}',
              '\$${priceRange.end.round()}',
            ),
            onChanged: (values) {
              // TODO: Update price range
            },
          ),
        ],
      );

  Widget _buildLocationSection(ThemeData theme) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          Icon(Icons.location_on, size: 20, color: theme.colorScheme.primary),
          const SizedBox(width: AppSpacing.sm),
          Text(
            'Location',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
      const SizedBox(height: AppSpacing.md),
      Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () {
                // TODO: Implement location picker
              },
              icon: const Icon(Icons.my_location),
              label: const Text('Use Current Location'),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () {
                // TODO: Implement location search
              },
              icon: const Icon(Icons.search),
              label: const Text('Search'),
            ),
          ),
        ],
      ),
    ],
  );

  void _filterItems() {
    // TODO: Implement actual filtering logic
    setState(_loadItems);
  }
}
