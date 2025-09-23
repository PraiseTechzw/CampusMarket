/// @Branch: Search Screen Implementation
///
/// Advanced search with filters, categories, and real-time results
/// Includes search history and suggestions
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/repositories/firebase_repository.dart';

class SearchScreen extends StatefulWidget {

  const SearchScreen({super.key, this.initialQuery});
  final String? initialQuery;

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  List<Map<String, dynamic>> _searchResults = [];
  List<String> _searchHistory = [];
  List<String> _searchSuggestions = [];

  bool _isLoading = false;
  bool _showSuggestions = true;
  bool _showAdvancedFilters = false;
  String _selectedCategory = 'all';
  String _selectedType = 'all';
  String _sortBy = 'relevance';
  double _minPrice = 0;
  double _maxPrice = 10000;
  String _selectedLocation = 'all';

  final List<String> _categories = [
    'all',
    'electronics',
    'books',
    'clothing',
    'furniture',
    'sports',
    'accessories',
    'home',
  ];

  final List<String> _types = ['all', 'marketplace', 'accommodation', 'events'];
  final List<String> _sortOptions = [
    'relevance',
    'price_low',
    'price_high',
    'date_new',
    'date_old',
    'rating',
  ];
  final List<String> _locations = [
    'all',
    'campus',
    'downtown',
    'suburbs',
    'nearby',
  ];

  final Map<String, String> _sortLabels = {
    'relevance': 'Most Relevant',
    'price_low': 'Price: Low to High',
    'price_high': 'Price: High to Low',
    'date_new': 'Newest First',
    'date_old': 'Oldest First',
    'rating': 'Highest Rated',
  };

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadSearchHistory();

    if (widget.initialQuery != null) {
      _searchController.text = widget.initialQuery!;
      _performSearch(widget.initialQuery!);
    }
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
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _loadSearchHistory() {
    // TODO: Load from local storage or database
    _searchHistory = [
      'iPhone 13',
      'Textbooks',
      'Room for rent',
      'Study group',
      'MacBook Pro',
      'Apartment near campus',
    ];
    _loadSearchSuggestions();
  }

  void _loadSearchSuggestions() {
    // TODO: Load from API or local storage
    _searchSuggestions = [
      'iPhone 15 Pro',
      'Textbooks for CS',
      'Room for rent near university',
      'Study group meetings',
      'MacBook Air M2',
      'Apartment downtown',
      'Gaming laptop',
      'Furniture for dorm',
      'Campus events',
      'Part-time jobs',
    ];
  }

  Future<void> _performSearch(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _searchResults = [];
        _showSuggestions = true;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _showSuggestions = false;
    });

    try {
      // Add to search history
      if (!_searchHistory.contains(query)) {
        setState(() {
          _searchHistory.insert(0, query);
          if (_searchHistory.length > 10) {
            _searchHistory = _searchHistory.take(10).toList();
          }
        });
      }

      // Perform search based on type
      List<Map<String, dynamic>> results = [];

      if (_selectedType == 'all' || _selectedType == 'marketplace') {
        final products = await FirebaseRepository.getProducts();
        final filteredProducts = products.where((product) {
          final title = product['title']?.toString().toLowerCase() ?? '';
          final description =
              product['description']?.toString().toLowerCase() ?? '';
          final category = product['category']?.toString() ?? '';
          final price = (product['price'] as num?)?.toDouble() ?? 0.0;

          final matchesQuery =
              title.contains(query.toLowerCase()) ||
              description.contains(query.toLowerCase()) ||
              category.contains(query.toLowerCase());

          final matchesCategory =
              _selectedCategory == 'all' || category == _selectedCategory;
          final matchesPrice = price >= _minPrice && price <= _maxPrice;

          return matchesQuery && matchesCategory && matchesPrice;
        }).toList();

        results.addAll(
          filteredProducts.map(
            (product) => {...product, 'type': 'marketplace'},
          ),
        );
      }

      if (_selectedType == 'all' || _selectedType == 'accommodation') {
        final accommodations = await FirebaseRepository.getAccommodations();
        final filteredAccommodations = accommodations.where((accommodation) {
          final title = accommodation['title']?.toString().toLowerCase() ?? '';
          final description =
              accommodation['description']?.toString().toLowerCase() ?? '';
          final location =
              accommodation['location']?.toString().toLowerCase() ?? '';
          final price = (accommodation['price'] as num?)?.toDouble() ?? 0.0;

          final matchesQuery =
              title.contains(query.toLowerCase()) ||
              description.contains(query.toLowerCase()) ||
              location.contains(query.toLowerCase());

          final matchesLocation =
              _selectedLocation == 'all' ||
              location.contains(_selectedLocation.toLowerCase());
          final matchesPrice = price >= _minPrice && price <= _maxPrice;

          return matchesQuery && matchesLocation && matchesPrice;
        }).toList();

        results.addAll(
          filteredAccommodations.map(
            (accommodation) => {...accommodation, 'type': 'accommodation'},
          ),
        );
      }

      if (_selectedType == 'all' || _selectedType == 'events') {
        final events = await FirebaseRepository.getEvents();
        final filteredEvents = events.where((event) {
          final title = event['title']?.toString().toLowerCase() ?? '';
          final description =
              event['description']?.toString().toLowerCase() ?? '';
          final location = event['location']?.toString().toLowerCase() ?? '';

          final matchesQuery =
              title.contains(query.toLowerCase()) ||
              description.contains(query.toLowerCase()) ||
              location.contains(query.toLowerCase());

          final matchesLocation =
              _selectedLocation == 'all' ||
              location.contains(_selectedLocation.toLowerCase());

          return matchesQuery && matchesLocation;
        }).toList();

        results.addAll(
          filteredEvents.map((event) => {...event, 'type': 'event'}),
        );
      }

      // Sort results
      _sortResults(results);

      setState(() {
        _searchResults = results;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Search error: $e')));
      }
    }
  }

  void _sortResults(List<Map<String, dynamic>> results) {
    switch (_sortBy) {
      case 'price_low':
        results.sort((a, b) {
          final priceA = (a['price'] as num?)?.toDouble() ?? 0.0;
          final priceB = (b['price'] as num?)?.toDouble() ?? 0.0;
          return priceA.compareTo(priceB);
        });
        break;
      case 'price_high':
        results.sort((a, b) {
          final priceA = (a['price'] as num?)?.toDouble() ?? 0.0;
          final priceB = (b['price'] as num?)?.toDouble() ?? 0.0;
          return priceB.compareTo(priceA);
        });
        break;
      case 'date_new':
        results.sort((a, b) {
          final dateA =
              DateTime.tryParse(a['created_at']?.toString() ?? '') ??
              DateTime(1970);
          final dateB =
              DateTime.tryParse(b['created_at']?.toString() ?? '') ??
              DateTime(1970);
          return dateB.compareTo(dateA);
        });
        break;
      case 'date_old':
        results.sort((a, b) {
          final dateA =
              DateTime.tryParse(a['created_at']?.toString() ?? '') ??
              DateTime(1970);
          final dateB =
              DateTime.tryParse(b['created_at']?.toString() ?? '') ??
              DateTime(1970);
          return dateA.compareTo(dateB);
        });
        break;
      case 'rating':
        results.sort((a, b) {
          final ratingA = (a['seller_rating'] as num?)?.toDouble() ?? 0.0;
          final ratingB = (b['seller_rating'] as num?)?.toDouble() ?? 0.0;
          return ratingB.compareTo(ratingA);
        });
        break;
      default: // relevance
        // Keep original order for relevance
        break;
    }
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _searchResults = [];
      _showSuggestions = true;
    });
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
      title: _buildSearchBar(theme),
      actions: [
        if (_searchController.text.isNotEmpty)
          IconButton(icon: const Icon(Icons.clear), onPressed: _clearSearch),
      ],
    );

  Widget _buildSearchBar(ThemeData theme) => Container(
      height: 50,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(
          color: _searchFocusNode.hasFocus
              ? theme.colorScheme.primary
              : theme.colorScheme.outline.withOpacity(0.3),
          width: _searchFocusNode.hasFocus ? 2 : 1,
        ),
        boxShadow: _searchFocusNode.hasFocus
            ? [
                BoxShadow(
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: TextField(
        controller: _searchController,
        focusNode: _searchFocusNode,
        decoration: InputDecoration(
          hintText: 'Search marketplace, housing, events...',
          hintStyle: TextStyle(
            color: theme.colorScheme.outline.withOpacity(0.7),
          ),
          prefixIcon: Icon(
            Icons.search,
            color: _searchFocusNode.hasFocus
                ? theme.colorScheme.primary
                : theme.colorScheme.outline,
          ),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.clear, color: theme.colorScheme.outline),
                  onPressed: _clearSearch,
                )
              : IconButton(
                  icon: Icon(Icons.mic, color: theme.colorScheme.outline),
                  onPressed: () {
                    // TODO: Implement voice search
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Voice search coming soon')),
                    );
                  },
                ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
        ),
        onChanged: (value) {
          if (value.isEmpty) {
            setState(() {
              _showSuggestions = true;
              _searchResults = [];
            });
          } else {
            _performSearch(value);
          }
        },
        onSubmitted: _performSearch,
        onTap: () {
          setState(() {
            _showSuggestions = true;
          });
        },
      ),
    );

  Widget _buildBody(ThemeData theme) => AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            children: [
              // Filters
              _buildFiltersSection(theme),

              // Content
              Expanded(
                child: _showSuggestions
                    ? _buildSuggestionsSection(theme)
                    : _buildResultsSection(theme),
              ),
            ],
          ),
        );
      },
    );

  Widget _buildFiltersSection(ThemeData theme) => Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        children: [
          // Basic Filters Row
          Row(
            children: [
              // Type filter
              Expanded(
                child: _buildFilterDropdown(
                  theme,
                  value: _selectedType,
                  items: _types,
                  label: 'Type',
                  icon: Icons.category,
                  onChanged: (value) {
                    setState(() {
                      _selectedType = value!;
                    });
                    if (_searchController.text.isNotEmpty) {
                      _performSearch(_searchController.text);
                    }
                  },
                ),
              ),

              const SizedBox(width: AppSpacing.md),

              // Category filter
              Expanded(
                child: _buildFilterDropdown(
                  theme,
                  value: _selectedCategory,
                  items: _categories,
                  label: 'Category',
                  icon: Icons.filter_list,
                  onChanged: (value) {
                    setState(() {
                      _selectedCategory = value!;
                    });
                    if (_searchController.text.isNotEmpty) {
                      _performSearch(_searchController.text);
                    }
                  },
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.sm),

          // Advanced Filters Toggle and Sort
          Row(
            children: [
              // Advanced Filters Toggle
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    setState(() {
                      _showAdvancedFilters = !_showAdvancedFilters;
                    });
                  },
                  icon: Icon(
                    _showAdvancedFilters ? Icons.keyboard_arrow_up : Icons.tune,
                    size: 18,
                  ),
                  label: Text(
                    _showAdvancedFilters ? 'Hide Filters' : 'Advanced Filters',
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: theme.colorScheme.primary,
                    side: BorderSide(color: theme.colorScheme.primary),
                  ),
                ),
              ),

              const SizedBox(width: AppSpacing.md),

              // Sort Dropdown
              Expanded(
                child: _buildFilterDropdown(
                  theme,
                  value: _sortBy,
                  items: _sortOptions,
                  label: 'Sort by',
                  icon: Icons.sort,
                  onChanged: (value) {
                    setState(() {
                      _sortBy = value!;
                    });
                    if (_searchController.text.isNotEmpty) {
                      _performSearch(_searchController.text);
                    }
                  },
                ),
              ),
            ],
          ),

          // Advanced Filters Panel
          if (_showAdvancedFilters) ...[
            const SizedBox(height: AppSpacing.md),
            _buildAdvancedFilters(theme),
          ],
        ],
      ),
    );

  Widget _buildFilterDropdown(
    ThemeData theme, {
    required String value,
    required List<String> items,
    required String label,
    required IconData icon,
    required ValueChanged<String?> onChanged,
  }) => DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 18),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
      ),
      items: items
          .map(
            (item) => DropdownMenuItem(
              value: item,
              child: Text(
                item == 'relevance' ? _sortLabels[item]! : item.toUpperCase(),
                style: theme.textTheme.bodyMedium,
              ),
            ),
          )
          .toList(),
      onChanged: onChanged,
    );

  Widget _buildAdvancedFilters(ThemeData theme) => Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outline.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Price Range',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  initialValue: _minPrice.toString(),
                  decoration: InputDecoration(
                    labelText: 'Min Price',
                    prefixText: '\$',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    _minPrice = double.tryParse(value) ?? 0;
                  },
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: TextFormField(
                  initialValue: _maxPrice.toString(),
                  decoration: InputDecoration(
                    labelText: 'Max Price',
                    prefixText: '\$',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    _maxPrice = double.tryParse(value) ?? 10000;
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Location',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            children: _locations.map((location) {
              final isSelected = _selectedLocation == location;
              return FilterChip(
                label: Text(location.toUpperCase()),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    _selectedLocation = location;
                  });
                  if (_searchController.text.isNotEmpty) {
                    _performSearch(_searchController.text);
                  }
                },
                selectedColor: theme.colorScheme.primary.withOpacity(0.2),
                checkmarkColor: theme.colorScheme.primary,
              );
            }).toList(),
          ),
        ],
      ),
    );

  Widget _buildSuggestionsSection(ThemeData theme) => AnimatedBuilder(
      animation: _slideAnimation,
      builder: (context, child) {
        return SlideTransition(
          position: _slideAnimation,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Search Suggestions
                if (_searchController.text.isNotEmpty) ...[
                  _buildSearchSuggestions(theme),
                  const SizedBox(height: AppSpacing.xl),
                ],

                // Search History
                if (_searchHistory.isNotEmpty) ...[
                  Row(
                    children: [
                      Text(
                        'Recent Searches',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _searchHistory.clear();
                          });
                        },
                        child: Text(
                          'Clear',
                          style: TextStyle(
                            color: theme.colorScheme.primary,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AnimationLimiter(
                    child: Wrap(
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.sm,
                      children: List.generate(
                        _searchHistory.length,
                        (index) => AnimationConfiguration.staggeredList(
                          position: index,
                          duration: const Duration(milliseconds: 375),
                          child: SlideAnimation(
                            verticalOffset: 50.0,
                            child: FadeInAnimation(
                              child: _buildHistoryChip(
                                theme,
                                _searchHistory[index],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                ],

                // Quick Categories
                Text(
                  'Quick Categories',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                _buildQuickCategories(theme),

                const SizedBox(height: AppSpacing.xl),

                // Popular Searches
                Text(
                  'Popular Searches',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                _buildPopularSearches(theme),
              ],
            ),
          ),
        );
      },
    );

  Widget _buildSearchSuggestions(ThemeData theme) {
    final filteredSuggestions = _searchSuggestions
        .where(
          (suggestion) => suggestion.toLowerCase().contains(
            _searchController.text.toLowerCase(),
          ),
        )
        .take(5)
        .toList();

    if (filteredSuggestions.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Suggestions',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        ...filteredSuggestions.map(
          (suggestion) => _buildSuggestionTile(theme, suggestion),
        ),
      ],
    );
  }

  Widget _buildSuggestionTile(ThemeData theme, String suggestion) => Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: ListTile(
        leading: Icon(Icons.search, color: theme.colorScheme.outline, size: 20),
        title: Text(suggestion, style: theme.textTheme.bodyMedium),
        onTap: () {
          _searchController.text = suggestion;
          _performSearch(suggestion);
        },
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        tileColor: theme.colorScheme.surface,
      ),
    );

  Widget _buildPopularSearches(ThemeData theme) {
    final popularSearches = [
      'iPhone 15',
      'MacBook Pro',
      'Textbooks',
      'Room for rent',
      'Study groups',
      'Campus events',
    ];

    return AnimationLimiter(
      child: Wrap(
        spacing: AppSpacing.sm,
        runSpacing: AppSpacing.sm,
        children: List.generate(
          popularSearches.length,
          (index) => AnimationConfiguration.staggeredList(
            position: index,
            duration: const Duration(milliseconds: 375),
            child: SlideAnimation(
              verticalOffset: 50,
              child: FadeInAnimation(
                child: _buildPopularChip(theme, popularSearches[index]),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPopularChip(ThemeData theme, String query) => GestureDetector(
      onTap: () {
        _searchController.text = query;
        _performSearch(query);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              theme.colorScheme.primary.withOpacity(0.1),
              theme.colorScheme.primary.withOpacity(0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: theme.colorScheme.primary.withOpacity(0.2)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.trending_up, size: 16, color: theme.colorScheme.primary),
            const SizedBox(width: AppSpacing.xs),
            Text(
              query,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );

  Widget _buildHistoryChip(ThemeData theme, String query) => GestureDetector(
      onTap: () {
        _searchController.text = query;
        _performSearch(query);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: theme.colorScheme.outline.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.history, size: 16, color: theme.colorScheme.outline),
            const SizedBox(width: AppSpacing.xs),
            Text(query, style: theme.textTheme.bodySmall),
          ],
        ),
      ),
    );

  Widget _buildQuickCategories(ThemeData theme) {
    final categories = [
      {'name': 'Electronics', 'icon': Icons.devices, 'query': 'electronics'},
      {'name': 'Books', 'icon': Icons.book, 'query': 'books'},
      {'name': 'Furniture', 'icon': Icons.chair, 'query': 'furniture'},
      {'name': 'Clothing', 'icon': Icons.checkroom, 'query': 'clothing'},
      {'name': 'Room Rent', 'icon': Icons.home, 'query': 'room rent'},
      {'name': 'Events', 'icon': Icons.event, 'query': 'events'},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: AppSpacing.md,
        mainAxisSpacing: AppSpacing.md,
        childAspectRatio: 2.5,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index] as Map<String, dynamic>;
        return _buildCategoryCard(theme, category);
      },
    );
  }

  Widget _buildCategoryCard(ThemeData theme, Map<String, dynamic> category) => GestureDetector(
      onTap: () {
        _searchController.text = category['query'] as String;
        _performSearch(category['query'] as String);
      },
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.shadow.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              Icon(
                category['icon'] as IconData,
                color: theme.colorScheme.primary,
                size: 24,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  category['name'] as String,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

  Widget _buildResultsSection(ThemeData theme) {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: theme.colorScheme.primary),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Searching...',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
          ],
        ),
      );
    }

    if (_searchResults.isEmpty) {
      return Center(
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
                  Icons.search_off,
                  size: 64,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'No results found',
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: theme.colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Try different keywords or adjust your filters',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.outline,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xl),
              // Search Tips
              Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: theme.colorScheme.outline.withOpacity(0.2),
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      'Search Tips',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _buildSearchTip(theme, 'Try broader keywords'),
                    _buildSearchTip(theme, 'Check your spelling'),
                    _buildSearchTip(theme, 'Use fewer filters'),
                    _buildSearchTip(theme, 'Try different categories'),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return AnimatedBuilder(
      animation: _slideAnimation,
      builder: (context, child) => SlideTransition(
          position: _slideAnimation,
          child: Column(
            children: [
              // Results Header
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                child: Row(
                  children: [
                    Text(
                      '${_searchResults.length} results found',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const Spacer(),
                    if (_searchResults.isNotEmpty)
                      TextButton.icon(
                        onPressed: () {
                          // TODO: Implement save search
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Save search feature coming soon'),
                            ),
                          );
                        },
                        icon: const Icon(Icons.bookmark_border, size: 16),
                        label: const Text('Save Search'),
                        style: TextButton.styleFrom(
                          foregroundColor: theme.colorScheme.primary,
                        ),
                      ),
                  ],
                ),
              ),

              // Results List
              Expanded(
                child: AnimationLimiter(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    itemCount: _searchResults.length,
                    itemBuilder: (context, index) {
                      final result = _searchResults[index];
                      return AnimationConfiguration.staggeredList(
                        position: index,
                        duration: const Duration(milliseconds: 375),
                        child: SlideAnimation(
                          verticalOffset: 50.0,
                          child: FadeInAnimation(
                            child: _buildResultCard(theme, result, index),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
    );
  }

  Widget _buildResultCard(
    ThemeData theme,
    Map<String, dynamic> result,
    int index,
  ) {
    final type = result['type'] ?? 'marketplace';
    final price = (result['price'] as num?)?.toDouble() ?? 0.0;
    final rating = (result['seller_rating'] as num?)?.toDouble() ?? 0.0;
    final createdAt = DateTime.tryParse(result['created_at']?.toString() ?? '');
    final isNew =
        createdAt != null && DateTime.now().difference(createdAt).inDays <= 7;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            switch (type) {
              case 'marketplace':
                context.go('/marketplace/${result['id']}');
                break;
              case 'accommodation':
                context.go('/accommodation/${result['id']}');
                break;
              case 'event':
                context.go('/events/${result['id']}');
                break;
            }
          },
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Row
                Row(
                  children: [
                    // Type Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: AppSpacing.xs,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            _getTypeColor(type as String),
                            _getTypeColor(type).withOpacity(0.8),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        (type).toUpperCase(),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    // New Badge
                    if (isNew)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: AppSpacing.xs,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'NEW',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    const Spacer(),
                    // Price
                    if (price > 0)
                      Text(
                        '\$${price.toStringAsFixed(0)}',
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: AppSpacing.md),

                // Content Row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Image
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: theme.colorScheme.surface,
                      ),
                      child:
                          result['image_urls'] != null &&
                              (result['image_urls'] as List).isNotEmpty
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Image.network(
                                (result['image_urls'] as List).first as String,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    DecoratedBox(
                                      decoration: BoxDecoration(
                                        color: _getTypeColor(
                                          type,
                                        ).withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: Icon(
                                        _getTypeIcon(type),
                                        color: _getTypeColor(type),
                                        size: 32,
                                      ),
                                    ),
                              ),
                            )
                          : DecoratedBox(
                              decoration: BoxDecoration(
                                color: _getTypeColor(
                                  type,
                                ).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Icon(
                                _getTypeIcon(type),
                                color: _getTypeColor(type),
                                size: 32,
                              ),
                            ),
                    ),

                    const SizedBox(width: AppSpacing.md),

                    // Details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Title
                          Text(
                            (result['title'] as String?) ?? 'Untitled',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),

                          const SizedBox(height: AppSpacing.xs),

                          // Description
                          Text(
                            (result['description'] as String?) ?? '',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.outline,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),

                          const SizedBox(height: AppSpacing.sm),

                          // Metadata Row
                          Row(
                            children: [
                              // Rating
                              if (rating > 0) ...[
                                Icon(Icons.star, color: Colors.amber, size: 16),
                                const SizedBox(width: 4),
                                Text(
                                  rating.toStringAsFixed(1),
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.md),
                              ],

                              // Location
                              if (result['location'] != null) ...[
                                Icon(
                                  Icons.location_on,
                                  color: theme.colorScheme.outline,
                                  size: 16,
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    result['location'] as String,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.colorScheme.outline,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ],
                          ),

                          const SizedBox(height: AppSpacing.sm),

                          // Date
                          if (createdAt != null)
                            Text(
                              _formatDate(createdAt),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.outline,
                                fontSize: 11,
                              ),
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

  String _formatDate(DateTime date) {
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
  }

  Widget _buildSearchTip(ThemeData theme, String tip) => Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        children: [
          Icon(
            Icons.lightbulb_outline,
            color: theme.colorScheme.primary,
            size: 16,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              tip,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
          ),
        ],
      ),
    );

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'marketplace':
        return Icons.store;
      case 'accommodation':
        return Icons.home;
      case 'event':
        return Icons.event;
      default:
        return Icons.search;
    }
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'marketplace':
        return Colors.blue;
      case 'accommodation':
        return Colors.green;
      case 'event':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
}
