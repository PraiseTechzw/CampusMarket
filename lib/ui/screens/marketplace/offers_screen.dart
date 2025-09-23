/// @Branch: Offers/Promotions Screen Implementation
///
/// Display current offers, promotions, and discounts
/// Includes featured offers, categories, and promotional campaigns
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/providers/auth_provider.dart';
import '../../../core/theme/app_spacing.dart';

class OffersScreen extends StatefulWidget {
  const OffersScreen({super.key});

  @override
  State<OffersScreen> createState() => _OffersScreenState();
}

class _OffersScreenState extends State<OffersScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;

  bool _isLoading = true;
  List<Map<String, dynamic>> _offers = [];
  List<Map<String, dynamic>> _featuredOffers = [];
  String _selectedCategory = 'all';

  final List<String> _categories = [
    'all',
    'marketplace',
    'accommodation',
    'events',
    'services',
  ];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadOffers();
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

  Future<void> _loadOffers() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = context.read<AuthProvider>();
      final user = authProvider.currentUser;

      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please sign in to view offers')),
        );
        return;
      }

      // TODO: Implement getOffers in SupabaseRepository
      // For now, using mock data
      await Future<void>.delayed(const Duration(seconds: 1));

      setState(() {
        _featuredOffers = [
          {
            'id': '1',
            'title': 'Back to School Sale',
            'description': 'Up to 50% off on textbooks and study materials',
            'discount': 50,
            'originalPrice': 200.0,
            'discountedPrice': 100.0,
            'image':
                'https://images.unsplash.com/photo-1481627834876-b7833e8f5570?w=400',
            'category': 'marketplace',
            'validUntil': '2024-03-31',
            'isActive': true,
            'isFeatured': true,
            'terms':
                'Valid on selected items only. Cannot be combined with other offers.',
          },
          {
            'id': '2',
            'title': 'Student Housing Special',
            'description': 'First month free on all accommodation bookings',
            'discount': 100,
            'originalPrice': 500.0,
            'discountedPrice': 0.0,
            'image':
                'https://images.unsplash.com/photo-1560448204-e02f11c3d0e2?w=400',
            'category': 'accommodation',
            'validUntil': '2024-02-29',
            'isActive': true,
            'isFeatured': true,
            'terms':
                'Valid for new bookings only. Minimum 3-month stay required.',
          },
        ];

        _offers = [
          {
            'id': '3',
            'title': 'Electronics Clearance',
            'description': 'Clearance sale on laptops, phones, and gadgets',
            'discount': 30,
            'originalPrice': 1000.0,
            'discountedPrice': 700.0,
            'image':
                'https://images.unsplash.com/photo-1517336714731-489689fd1ca8?w=400',
            'category': 'marketplace',
            'validUntil': '2024-02-15',
            'isActive': true,
            'isFeatured': false,
            'terms': 'While supplies last. No returns on clearance items.',
          },
          {
            'id': '4',
            'title': 'Event Tickets Early Bird',
            'description': '20% off on all event tickets booked in advance',
            'discount': 20,
            'originalPrice': 50.0,
            'discountedPrice': 40.0,
            'image':
                'https://images.unsplash.com/photo-1540575467063-178a50c2df87?w=400',
            'category': 'events',
            'validUntil': '2024-02-20',
            'isActive': true,
            'isFeatured': false,
            'terms': 'Valid for events happening after March 1st, 2024.',
          },
          {
            'id': '5',
            'title': 'Study Group Discount',
            'description': 'Group bookings get 15% off on study materials',
            'discount': 15,
            'originalPrice': 100.0,
            'discountedPrice': 85.0,
            'image':
                'https://images.unsplash.com/photo-1522202176988-66273c2fd55f?w=400',
            'category': 'services',
            'validUntil': '2024-03-15',
            'isActive': true,
            'isFeatured': false,
            'terms': 'Minimum 3 people required for group discount.',
          },
        ];
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading offers: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _claimOffer(Map<String, dynamic> offer) async {
    try {
      // TODO: Implement claimOffer in SupabaseRepository
      await Future<void>.delayed(const Duration(seconds: 1));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Offer "${offer['title'] as String}" claimed successfully!',
            ),
            action: SnackBarAction(
              label: 'View',
              onPressed: () => _viewOffer(offer),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error claiming offer: $e')));
      }
    }
  }

  void _viewOffer(Map<String, dynamic> offer) {
    // TODO: Navigate to specific offer details or related items
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Viewing offer: ${offer['title'] as String}')),
    );
  }

  void _shareOffer(Map<String, dynamic> offer) {
    // TODO: Implement share functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Sharing offer: ${offer['title'] as String}')),
    );
  }

  List<Map<String, dynamic>> get _filteredOffers {
    if (_selectedCategory == 'all') return _offers;
    return _offers
        .where((offer) => (offer['category'] as String) == _selectedCategory)
        .toList();
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
        'Offers & Promotions',
        style: theme.textTheme.headlineSmall?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: [
        IconButton(icon: const Icon(Icons.refresh), onPressed: _loadOffers),
      ],
    );

  Widget _buildBody(ThemeData theme) {
    if (_isLoading) {
      return _buildLoadingState(theme);
    }

    return CustomScrollView(
      slivers: [
        _buildFeaturedOffers(theme),
        _buildCategoryFilter(theme),
        _buildOffersList(theme),
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
            'Loading offers...',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.outline,
            ),
          ),
        ],
      ),
    );

  Widget _buildFeaturedOffers(ThemeData theme) {
    if (_featuredOffers.isEmpty) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Row(
              children: [
                Icon(Icons.star, color: Colors.amber, size: 24),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  'Featured Offers',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 200,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              itemCount: _featuredOffers.length,
              itemBuilder: (context, index) => _buildFeaturedOfferCard(
                  theme,
                  _featuredOffers[index],
                  index,
                ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }

  Widget _buildFeaturedOfferCard(
    ThemeData theme,
    Map<String, dynamic> offer,
    int index,
  ) => Container(
      width: 300,
      margin: const EdgeInsets.only(right: AppSpacing.md),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            Image.network(
              offer['image'] as String,
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: theme.colorScheme.surface,
                  child: Icon(
                    Icons.local_offer,
                    size: 64,
                    color: theme.colorScheme.outline,
                  ),
                );
              },
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
                ),
              ),
            ),
            Positioned(
              top: AppSpacing.md,
              left: AppSpacing.md,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${offer['discount'] as int}% OFF',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      offer['title'] as String,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      offer['description'] as String,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.white70,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Row(
                      children: [
                        Text(
                          'Valid until ${offer['validUntil'] as String}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.white70,
                            fontSize: 10,
                          ),
                        ),
                        const Spacer(),
                        GestureDetector(
                          onTap: () => _claimOffer(offer),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.md,
                              vertical: AppSpacing.sm,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              'Claim Now',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );

  Widget _buildCategoryFilter(ThemeData theme) => SliverToBoxAdapter(
      child: Container(
        height: 60,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: _categories.length,
          itemBuilder: (context, index) {
            final category = _categories[index];
            final isSelected = _selectedCategory == category;

            return Padding(
              padding: const EdgeInsets.only(right: AppSpacing.sm),
              child: FilterChip(
                label: Text(_getCategoryLabel(category)),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    _selectedCategory = category;
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
      ),
    );

  String _getCategoryLabel(String category) {
    switch (category) {
      case 'marketplace':
        return 'Products';
      case 'accommodation':
        return 'Housing';
      case 'events':
        return 'Events';
      case 'services':
        return 'Services';
      case 'all':
      default:
        return 'All';
    }
  }

  Widget _buildOffersList(ThemeData theme) {
    final filteredOffers = _filteredOffers;

    if (filteredOffers.isEmpty) {
      return SliverToBoxAdapter(child: _buildEmptyState(theme));
    }

    return SliverPadding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate((context, index) => AnimatedBuilder(
            animation: _fadeAnimation,
            builder: (context, child) {
              return FadeTransition(
                opacity: _fadeAnimation,
                child: _buildOfferCard(theme, filteredOffers[index], index),
              );
            },
          ), childCount: filteredOffers.length),
      ),
    );
  }

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
                Icons.local_offer,
                size: 64,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(
              'No Offers Available',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Check back later for new offers and promotions!',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
          ],
        ),
      ),
    );

  Widget _buildOfferCard(
    ThemeData theme,
    Map<String, dynamic> offer,
    int index,
  ) => Container(
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
          _buildOfferImage(theme, offer),
          _buildOfferContent(theme, offer),
          _buildOfferActions(theme, offer),
        ],
      ),
    );

  Widget _buildOfferImage(ThemeData theme, Map<String, dynamic> offer) => Stack(
      children: [
        ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          child: Image.network(
            offer['image'] as String,
            width: double.infinity,
            height: 150,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                height: 150,
                color: theme.colorScheme.surface,
                child: Icon(
                  Icons.local_offer,
                  size: 64,
                  color: theme.colorScheme.outline,
                ),
              );
            },
          ),
        ),
        Positioned(
          top: AppSpacing.md,
          right: AppSpacing.md,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${offer['discount'] as int}% OFF',
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );

  Widget _buildOfferContent(ThemeData theme, Map<String, dynamic> offer) => Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  offer['title'] as String,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: _getCategoryColor(
                    theme,
                    offer['category'] as String,
                  ).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _getCategoryLabel(offer['category'] as String),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: _getCategoryColor(
                      theme,
                      offer['category'] as String,
                    ),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            offer['description'] as String,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.outline,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              if ((offer['originalPrice'] as num) > 0) ...[
                Text(
                  '\$${offer['originalPrice'] as num}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    decoration: TextDecoration.lineThrough,
                    color: theme.colorScheme.outline,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
              ],
              Text(
                '\$${offer['discountedPrice'] as num}',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
              const Spacer(),
              Text(
                'Valid until ${offer['validUntil'] as String}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.outline,
                ),
              ),
            ],
          ),
        ],
      ),
    );

  Widget _buildOfferActions(ThemeData theme, Map<String, dynamic> offer) => Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => _viewOffer(offer),
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
              onPressed: () => _claimOffer(offer),
              icon: const Icon(Icons.local_offer),
              label: const Text('Claim Offer'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          IconButton(
            onPressed: () => _shareOffer(offer),
            icon: const Icon(Icons.share),
            style: IconButton.styleFrom(
              backgroundColor: theme.colorScheme.surface,
              foregroundColor: theme.colorScheme.outline,
            ),
          ),
        ],
      ),
    );

  Color _getCategoryColor(ThemeData theme, String category) {
    switch (category) {
      case 'marketplace':
        return Colors.blue;
      case 'accommodation':
        return Colors.green;
      case 'events':
        return Colors.purple;
      case 'services':
        return Colors.orange;
      default:
        return theme.colorScheme.outline;
    }
  }
}
