/// @Branch: Product Detail Screen Implementation
///
/// Enhanced detailed view of marketplace item with modern UI, image gallery, and interactions
/// Includes improved layout, animations, and better user experience
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/glow_card.dart';
import '../../../core/models/marketplace_item.dart';
import '../../../core/repositories/firebase_repository.dart';

class ProductDetailScreen extends StatefulWidget {
  const ProductDetailScreen({super.key, required this.itemId});
  final String itemId;

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen>
    with TickerProviderStateMixin {
  late MarketplaceItem item;
  bool _isLoading = true;
  bool _isFavorite = false;
  int _currentImageIndex = 0;
  late PageController _pageController;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _loadItem();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _loadItem() async {
    try {
      final productData = await FirebaseRepository.getProductById(
        widget.itemId,
      );

      if (productData != null) {
        // Map the database response to MarketplaceItem model
        final marketplaceItem = MarketplaceItem(
          id: productData['id']?.toString() ?? '',
          title: productData['title']?.toString() ?? '',
          description: productData['description']?.toString() ?? '',
          price: (productData['price'] as num? ?? 0.0).toDouble(),
          currency: productData['currency']?.toString() ?? 'USD',
          images: List<String>.from(productData['images'] as List? ?? []),
          category: productData['category']?.toString() ?? '',
          subcategory: productData['subcategory']?.toString(),
          condition: productData['condition']?.toString() ?? 'good',
          userId: productData['user_id']?.toString() ?? '',
          university: productData['university']?.toString(),
          location: productData['location']?.toString(),
          latitude: (productData['latitude'] as num?)?.toDouble(),
          longitude: (productData['longitude'] as num?)?.toDouble(),
          tags: List<String>.from(productData['tags'] as List? ?? []),
          isAvailable: productData['is_available'] as bool? ?? true,
          isFeatured: productData['is_featured'] as bool? ?? false,
          isNegotiable: productData['is_negotiable'] as bool? ?? true,
          createdAt: DateTime.parse(
            productData['created_at']?.toString() ??
                DateTime.now().toIso8601String(),
          ),
          updatedAt: DateTime.parse(
            productData['updated_at']?.toString() ??
                DateTime.now().toIso8601String(),
          ),
          viewCount: productData['view_count'] as int? ?? 0,
          favoriteCount: productData['favorite_count'] as int? ?? 0,
          status: productData['status']?.toString() ?? 'active',
          sellerName: productData['users'] != null
              ? '${productData['users']['first_name'] ?? ''} ${productData['users']['last_name'] ?? ''}'
                    .trim()
              : 'Unknown Seller',
          sellerProfileImage: productData['users']?['profile_image_url']
              ?.toString(),
        );

        setState(() {
          item = marketplaceItem;
          _isLoading = false;
        });
        _fadeController.forward();
      } else {
        setState(() {
          _isLoading = false;
        });
        // Handle case where product is not found
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Product not found')));
        }
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      // Handle error
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading product: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_isLoading) {
      return Scaffold(
        backgroundColor: theme.colorScheme.surface,
        appBar: AppBar(
          backgroundColor: theme.colorScheme.surface,
          elevation: 0,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: theme.colorScheme.primary),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Loading item details...',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: CustomScrollView(
          slivers: [
            // Enhanced App Bar with Image Gallery
            _buildImageGalleryAppBar(theme),

            // Content
            SliverPadding(
              padding: const EdgeInsets.all(AppSpacing.md),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // Title and Price Section
                  _buildTitleAndPriceSection(theme),

                  const SizedBox(height: AppSpacing.lg),

                  // Key Details Section
                  _buildKeyDetailsSection(theme),

                  const SizedBox(height: AppSpacing.lg),

                  // Description Section
                  _buildDescriptionSection(theme),

                  const SizedBox(height: AppSpacing.lg),

                  // Seller Section
                  _buildEnhancedSellerCard(theme),

                  const SizedBox(height: AppSpacing.lg),

                  // Action Buttons
                  _buildEnhancedActionButtons(theme),

                  const SizedBox(height: AppSpacing.xl),

                  // Similar Items Section
                  _buildSimilarItemsSection(theme),

                  const SizedBox(height: AppSpacing.xl),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageGalleryAppBar(ThemeData theme) => SliverAppBar(
    expandedHeight: 400,
    floating: false,
    pinned: true,
    backgroundColor: theme.colorScheme.surface,
    elevation: 0,
    leading: IconButton(
      icon: const Icon(Icons.arrow_back, color: Colors.white),
      onPressed: () => context.pop(),
    ),
    flexibleSpace: FlexibleSpaceBar(
      background: Stack(
        fit: StackFit.expand,
        children: [
          // Image Gallery
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentImageIndex = index;
              });
            },
            itemCount: item.images.length,
            itemBuilder: (context, index) {
              return Image.network(
                item.images[index],
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: theme.colorScheme.surface,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.image_outlined,
                            size: 64,
                            color: theme.colorScheme.onSurface.withOpacity(0.3),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            'Image not available',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: theme.colorScheme.onSurface.withOpacity(
                                0.6,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),

          // Gradient overlay
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.3),
                  Colors.transparent,
                  Colors.black.withOpacity(0.1),
                ],
                stops: const [0.0, 0.5, 1.0],
              ),
            ),
          ),

          // Image indicators
          if (item.images.length > 1)
            Positioned(
              bottom: AppSpacing.lg,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  item.images.length,
                  (index) => Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _currentImageIndex == index
                          ? Colors.white
                          : Colors.white.withOpacity(0.5),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    ),
    actions: [
      IconButton(
        icon: Icon(
          _isFavorite ? Icons.favorite : Icons.favorite_border,
          color: _isFavorite ? Colors.red : Colors.white,
        ),
        onPressed: () {
          setState(() {
            _isFavorite = !_isFavorite;
          });
        },
      ),
      IconButton(
        icon: const Icon(Icons.share, color: Colors.white),
        onPressed: () {
          // TODO: Implement share functionality
        },
      ),
      IconButton(
        icon: const Icon(Icons.more_vert, color: Colors.white),
        onPressed: () {
          // TODO: Implement more options
        },
      ),
    ],
  );

  Widget _buildTitleAndPriceSection(ThemeData theme) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      // Title
      Text(
        item.title,
        style: theme.textTheme.headlineMedium?.copyWith(
          fontWeight: FontWeight.bold,
          height: 1.2,
        ),
      ),

      const SizedBox(height: AppSpacing.sm),

      // Price and negotiable badge
      Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              border: Border.all(
                color: theme.colorScheme.primary.withOpacity(0.3),
              ),
            ),
            child: Text(
              item.formattedPrice,
              style: theme.textTheme.headlineLarge?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          if (item.isNegotiable) ...[
            const SizedBox(width: AppSpacing.sm),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: theme.colorScheme.secondary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.handshake,
                    size: 16,
                    color: theme.colorScheme.secondary,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    'Negotiable',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.secondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    ],
  );

  Widget _buildKeyDetailsSection(ThemeData theme) => Container(
    padding: const EdgeInsets.all(AppSpacing.md),
    decoration: BoxDecoration(
      color: theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
      border: Border.all(color: theme.colorScheme.outline.withOpacity(0.1)),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 10,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: Column(
      children: [
        _buildDetailRow(theme, Icons.category, 'Category', item.category),
        const SizedBox(height: AppSpacing.sm),
        _buildDetailRow(
          theme,
          Icons.verified,
          'Condition',
          _getConditionText(item.condition),
        ),
        const SizedBox(height: AppSpacing.sm),
        _buildDetailRow(theme, Icons.access_time, 'Listed', item.timeAgo),
        if (item.location != null) ...[
          const SizedBox(height: AppSpacing.sm),
          _buildDetailRow(theme, Icons.location_on, 'Location', item.location!),
        ],
      ],
    ),
  );

  Widget _buildDetailRow(
    ThemeData theme,
    IconData icon,
    String label,
    String value,
  ) => Row(
    children: [
      Icon(icon, size: 20, color: theme.colorScheme.primary),
      const SizedBox(width: AppSpacing.sm),
      Text(
        '$label:',
        style: theme.textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w600,
          color: theme.colorScheme.onSurface.withOpacity(0.7),
        ),
      ),
      const SizedBox(width: AppSpacing.sm),
      Expanded(
        child: Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    ],
  );

  Widget _buildDescriptionSection(ThemeData theme) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'Description',
        style: theme.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
      const SizedBox(height: AppSpacing.sm),
      Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface.withOpacity(0.5),
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          border: Border.all(color: theme.colorScheme.outline.withOpacity(0.1)),
        ),
        child: Text(
          item.description,
          style: theme.textTheme.bodyLarge?.copyWith(height: 1.6),
        ),
      ),
    ],
  );

  Widget _buildEnhancedSellerCard(ThemeData theme) => Container(
    padding: const EdgeInsets.all(AppSpacing.md),
    decoration: BoxDecoration(
      color: theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
      border: Border.all(color: theme.colorScheme.outline.withOpacity(0.1)),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 10,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: Row(
      children: [
        // Seller avatar
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: theme.colorScheme.primary.withOpacity(0.2),
              width: 2,
            ),
          ),
          child: CircleAvatar(
            radius: 30,
            backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
            backgroundImage: item.sellerProfileImage != null
                ? NetworkImage(item.sellerProfileImage!)
                : null,
            child: item.sellerProfileImage == null
                ? Text(
                    (item.sellerName?.isNotEmpty ?? false)
                        ? item.sellerName![0].toUpperCase()
                        : '?',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  )
                : null,
          ),
        ),

        const SizedBox(width: AppSpacing.md),

        // Seller info
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Sold by',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                item.sellerName ?? 'Unknown Seller',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Member since 2024 • 4.8★',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ),

        // Contact button
        ElevatedButton.icon(
          onPressed: () {
            // TODO: Implement contact seller
          },
          icon: const Icon(Icons.message),
          label: const Text('Contact'),
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.colorScheme.primary,
            foregroundColor: theme.colorScheme.onPrimary,
          ),
        ),
      ],
    ),
  );

  Widget _buildEnhancedActionButtons(ThemeData theme) => Column(
    children: [
      // Primary action button
      SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: () {
            // TODO: Implement buy now
          },
          icon: const Icon(Icons.shopping_cart),
          label: const Text('Buy Now'),
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.colorScheme.primary,
            foregroundColor: theme.colorScheme.onPrimary,
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
            ),
          ),
        ),
      ),

      const SizedBox(height: AppSpacing.sm),

      // Secondary action buttons
      Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () {
                // TODO: Implement make offer
              },
              icon: const Icon(Icons.attach_money),
              label: const Text('Make Offer'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () {
                // TODO: Implement add to favorites
              },
              icon: Icon(_isFavorite ? Icons.favorite : Icons.favorite_border),
              label: Text(_isFavorite ? 'Saved' : 'Save'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
                ),
              ),
            ),
          ),
        ],
      ),
    ],
  );

  Widget _buildSimilarItemsSection(ThemeData theme) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          Text(
            'Similar Items',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          TextButton(
            onPressed: () {
              // TODO: Navigate to similar items
            },
            child: const Text('View All'),
          ),
        ],
      ),
      const SizedBox(height: AppSpacing.md),
      SizedBox(
        height: 220,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: 0, // TODO: Load similar items from repository
          itemBuilder: (context, index) {
            final similarItem = item; // Placeholder
            return Container(
              width: 160,
              margin: const EdgeInsets.only(right: AppSpacing.md),
              child: GlowCard(
                onTap: () => context.go('/marketplace/${similarItem.id}'),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 120,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(
                          AppSpacing.radiusSm,
                        ),
                        color: theme.colorScheme.surface,
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(
                          AppSpacing.radiusSm,
                        ),
                        child: Image.network(
                          similarItem.primaryImage,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              Icons.image,
                              color: theme.colorScheme.onSurface.withOpacity(
                                0.3,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      similarItem.title,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      similarItem.formattedPrice,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    ],
  );

  String _getConditionText(String condition) {
    switch (condition) {
      case 'new':
        return 'New';
      case 'like_new':
        return 'Like New';
      case 'good':
        return 'Good';
      case 'fair':
        return 'Fair';
      case 'poor':
        return 'Poor';
      default:
        return 'Unknown';
    }
  }
}
