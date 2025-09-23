import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';

class ProductCard extends StatefulWidget {

  const ProductCard({
    super.key,
    required this.item,
    required this.index,
    this.badgeText,
    this.badgeColor,
    this.badgeIcon,
    this.priceColor,
    this.actionIcon,
    this.actionText,
    this.actionColor,
    this.onTap,
    this.showViewCount = true,
    this.showFavoriteCount = false,
  });
  final dynamic item;
  final int index;
  final String? badgeText;
  final Color? badgeColor;
  final IconData? badgeIcon;
  final Color? priceColor;
  final IconData? actionIcon;
  final String? actionText;
  final Color? actionColor;
  final VoidCallback? onTap;
  final bool showViewCount;
  final bool showFavoriteCount;

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  bool _isFavorite = false;
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isMobile = MediaQuery.of(context).size.width < 600;
    const isWeb = kIsWeb;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap:
            widget.onTap ??
            () => context.go('/marketplace/${widget.item['id']}'),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _isHovered
                  ? theme.colorScheme.primary.withOpacity(0.3)
                  : theme.colorScheme.outline.withOpacity(0.1),
              width: _isHovered ? 1.5 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: _isHovered
                    ? theme.colorScheme.primary.withOpacity(0.1)
                    : Colors.black.withOpacity(0.05),
                blurRadius: _isHovered ? 20 : 8,
                offset: Offset(0, _isHovered ? 8 : 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image section - Alibaba/AliExpress style
              _buildImageSection(theme, isMobile, isWeb),

              // Content section
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      _buildTitle(theme, isMobile, isWeb),

                      const SizedBox(height: 6),

                      // Price and rating row
                      _buildPriceAndRating(theme, isMobile, isWeb),

                      const SizedBox(height: 8),

                      // Seller info and location
                      _buildSellerInfo(theme, isMobile, isWeb),

                      const Spacer(),

                      // Action buttons
                      _buildActionButtons(theme, isMobile, isWeb),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageSection(ThemeData theme, bool isMobile, bool isWeb) => Container(
      height: isWeb ? 200 : (isMobile ? 180 : 190),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
        color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
      ),
      child: Stack(
        children: [
          // Product image or placeholder
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
              color: theme.colorScheme.surfaceVariant.withOpacity(0.5),
            ),
            child:
                (widget.item['image_urls'] as List?)?.isNotEmpty == true &&
                    (widget.item['image_urls'] as List).first
                        .toString()
                        .isNotEmpty
                ? ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                    ),
                    child: Image.network(
                      (widget.item['image_urls'] as List).first.toString(),
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          _buildImagePlaceholder(theme),
                    ),
                  )
                : _buildImagePlaceholder(theme),
          ),

          // Badge
          if (widget.badgeText != null)
            Positioned(
              top: 8,
              left: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: widget.badgeColor ?? theme.colorScheme.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  widget.badgeText!,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 10,
                  ),
                ),
              ),
            ),

          // Wishlist button
          Positioned(
            top: 8,
            right: 8,
            child: GestureDetector(
              onTap: () => setState(() => _isFavorite = !_isFavorite),
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  _isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: _isFavorite
                      ? Colors.red
                      : theme.colorScheme.onSurface.withOpacity(0.6),
                  size: 16,
                ),
              ),
            ),
          ),

          // Quick view button (appears on hover for web)
          if (isWeb && _isHovered)
            Positioned(
              bottom: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.visibility, color: Colors.white, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      'Quick View',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );

  Widget _buildImagePlaceholder(ThemeData theme) => Container(
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
        color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _getCategoryIcon(widget.item['category_id']?.toString() ?? ''),
              size: 48,
              color: theme.colorScheme.primary.withOpacity(0.5),
            ),
            const SizedBox(height: 8),
            Text(
              'No Image',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.5),
              ),
            ),
          ],
        ),
      ),
    );

  Widget _buildTitle(ThemeData theme, bool isMobile, bool isWeb) => Text(
      widget.item['title']?.toString() ?? '',
      style: theme.textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w600,
        height: 1.3,
        fontSize: isMobile ? 14 : 15,
        color: theme.colorScheme.onSurface,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );

  Widget _buildPriceAndRating(ThemeData theme, bool isMobile, bool isWeb) => Row(
      children: [
        // Price
        Expanded(
          child: Text(
            '${widget.item['currency'] ?? 'USD'} ${(widget.item['price'] ?? 0).toStringAsFixed(0)}',
            style: theme.textTheme.titleLarge?.copyWith(
              color: widget.priceColor ?? theme.colorScheme.primary,
              fontWeight: FontWeight.w700,
              fontSize: isMobile ? 16 : 18,
            ),
          ),
        ),

        // Rating (mock data)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.star, color: Colors.orange, size: 12),
              const SizedBox(width: 2),
              Text(
                '4.8',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
      ],
    );

  Widget _buildSellerInfo(ThemeData theme, bool isMobile, bool isWeb) => Row(
      children: [
        // Seller avatar
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.person, size: 12, color: theme.colorScheme.primary),
        ),
        const SizedBox(width: 6),

        // Seller name
        Expanded(
          child: Text(
            widget.item['seller_name']?.toString() ?? 'Seller',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
              fontSize: 11,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),

        // Location
        Icon(
          Icons.location_on,
          size: 12,
          color: theme.colorScheme.onSurface.withOpacity(0.5),
        ),
        const SizedBox(width: 2),
        Text(
          widget.item['location']?.toString() ?? 'Zimbabwe',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.5),
            fontSize: 10,
          ),
        ),
      ],
    );

  Widget _buildActionButtons(ThemeData theme, bool isMobile, bool isWeb) => Row(
      children: [
        // Add to cart button
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              // TODO: Implement add to cart
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Add to Cart',
              style: theme.textTheme.labelMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
        ),

        const SizedBox(width: 8),

        // Chat button
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceVariant,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: theme.colorScheme.outline.withOpacity(0.2),
            ),
          ),
          child: IconButton(
            onPressed: () {
              // TODO: Implement chat
            },
            icon: Icon(
              Icons.chat_bubble_outline,
              size: 16,
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
            padding: EdgeInsets.zero,
          ),
        ),
      ],
    );

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'electronics':
        return Icons.devices;
      case 'books':
        return Icons.menu_book;
      case 'clothing':
        return Icons.checkroom;
      case 'furniture':
        return Icons.chair;
      case 'transportation':
        return Icons.directions_bike;
      default:
        return Icons.shopping_bag;
    }
  }
}
