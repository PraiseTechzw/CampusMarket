/// @Branch: Marketplace Item Card Widget Implementation
///
/// Enhanced reusable card component for displaying marketplace items
/// Includes modern styling, animations, and improved visual hierarchy
library;

import 'package:flutter/material.dart';

import '../../core/models/marketplace_item.dart';
import '../../core/theme/app_spacing.dart';
// import '../../core/widgets/glow_card.dart';
// import '../../core/widgets/live_badge.dart';

class MarketplaceItemCard extends StatefulWidget {
  const MarketplaceItemCard({
    super.key,
    required this.item,
    this.onTap,
    this.onFavorite,
    this.showSellerInfo = true,
    this.isFavorite = false,
    this.enableAnimations = true,
    this.width,
    this.height,
  });
  final MarketplaceItem item;
  final VoidCallback? onTap;
  final VoidCallback? onFavorite;
  final bool showSellerInfo;
  final bool isFavorite;
  final bool enableAnimations;
  final double? width;
  final double? height;

  @override
  State<MarketplaceItemCard> createState() => _MarketplaceItemCardState();
}

class _MarketplaceItemCardState extends State<MarketplaceItemCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  // late Animation<double> _fadeAnimation;
  // bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    if (widget.enableAnimations) {
      _animationController = AnimationController(
        duration: const Duration(milliseconds: 200),
        vsync: this,
      );

      _scaleAnimation = Tween<double>(begin: 1, end: 0.95).animate(
        CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
      );

      // _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      //   CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
      // );
    }
  }

  @override
  void dispose() {
    if (widget.enableAnimations) {
      _animationController.dispose();
    }
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (widget.enableAnimations) {
      _animationController.forward();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    if (widget.enableAnimations) {
      _animationController.reverse();
    }
  }

  void _handleTapCancel() {
    if (widget.enableAnimations) {
      _animationController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: widget.enableAnimations
            ? _animationController
            : const AlwaysStoppedAnimation(0),
        builder: (context, child) => Transform.scale(
          scale: widget.enableAnimations ? _scaleAnimation.value : 1.0,
          child: Container(
            width: widget.width,
            height: widget.height,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
              child: Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  border: Border.all(
                    color: theme.colorScheme.outline.withOpacity(0.1),
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Enhanced Image section
                    _buildEnhancedImageSection(context, theme),

                    // Content section with better spacing
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Title and price
                            _buildTitleAndPrice(theme),

                            const SizedBox(height: AppSpacing.sm),

                            // Condition and time
                            _buildConditionAndTime(theme),

                            if (widget.showSellerInfo) ...[
                              const Spacer(),
                              _buildSellerSection(context, theme),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEnhancedImageSection(
    BuildContext context,
    ThemeData theme,
  ) => Container(
    height: 140,
    width: double.infinity,
    decoration: BoxDecoration(
      borderRadius: const BorderRadius.vertical(
        top: Radius.circular(AppSpacing.radiusXl),
      ),
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          theme.colorScheme.surface,
          theme.colorScheme.surface.withOpacity(0.8),
        ],
      ),
    ),
    child: Stack(
      children: [
        // Main image with enhanced styling
        ClipRRect(
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(AppSpacing.radiusXl),
          ),
          child: widget.item.primaryImage.isNotEmpty
              ? Image.network(
                  widget.item.primaryImage,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                  errorBuilder: (context, error, stackTrace) {
                    return _buildPlaceholderImage(theme);
                  },
                )
              : _buildPlaceholderImage(theme),
        ),

        // Gradient overlay for better text readability
        Container(
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(AppSpacing.radiusXl),
            ),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.transparent, Colors.black.withOpacity(0.1)],
              stops: const [0.0, 1.0],
            ),
          ),
        ),

        // Top badges row
        Positioned(
          top: AppSpacing.sm,
          left: AppSpacing.sm,
          right: AppSpacing.sm,
          child: Row(
            children: [
              // Featured badge
              if (widget.item.isFeatured)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                    boxShadow: [
                      BoxShadow(
                        color: theme.colorScheme.primary.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.star,
                        size: 12,
                        color: theme.colorScheme.onPrimary,
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        'FEATURED',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),

              const Spacer(),

              // Image count badge
              if (widget.item.hasMultipleImages)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.photo_library, size: 12, color: Colors.white),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        '+${widget.item.images.length - 1}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),

        // Bottom action buttons
        Positioned(
          bottom: AppSpacing.sm,
          right: AppSpacing.sm,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Favorite button
              GestureDetector(
                onTap: widget.onFavorite,
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                  ),
                  child: Icon(
                    widget.isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: widget.isFavorite ? Colors.red : Colors.white,
                    size: 18,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );

  Widget _buildPlaceholderImage(ThemeData theme) => Container(
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          theme.colorScheme.surface,
          theme.colorScheme.surface.withOpacity(0.7),
        ],
      ),
    ),
    child: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.image_outlined,
            color: theme.colorScheme.onSurface.withOpacity(0.3),
            size: 32,
          ),
          const SizedBox(height: AppSpacing.xs),
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

  Widget _buildTitleAndPrice(ThemeData theme) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      // Title with better typography
      Text(
        widget.item.title,
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
          height: 1.3,
        ),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),

      const SizedBox(height: AppSpacing.xs),

      // Price with enhanced styling
      Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              border: Border.all(
                color: theme.colorScheme.primary.withOpacity(0.2),
              ),
            ),
            child: Text(
              widget.item.formattedPrice,
              style: theme.textTheme.titleLarge?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          if (widget.item.isNegotiable) ...[
            const SizedBox(width: AppSpacing.sm),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.xs,
                vertical: 2,
              ),
              decoration: BoxDecoration(
                color: theme.colorScheme.secondary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppSpacing.radiusXs),
              ),
              child: Text(
                'Negotiable',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.secondary,
                  fontWeight: FontWeight.w600,
                  fontSize: 10,
                ),
              ),
            ),
          ],
        ],
      ),
    ],
  );

  Widget _buildConditionAndTime(ThemeData theme) => Row(
    children: [
      // Condition badge
      Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: _getConditionColor(widget.item.condition).withOpacity(0.1),
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          border: Border.all(
            color: _getConditionColor(widget.item.condition).withOpacity(0.3),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _getConditionIcon(widget.item.condition),
              size: 12,
              color: _getConditionColor(widget.item.condition),
            ),
            const SizedBox(width: AppSpacing.xs),
            Text(
              _getConditionText(widget.item.condition),
              style: theme.textTheme.bodySmall?.copyWith(
                color: _getConditionColor(widget.item.condition),
                fontWeight: FontWeight.w600,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),

      const Spacer(),

      // Time ago
      Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.access_time,
            size: 12,
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
          const SizedBox(width: AppSpacing.xs),
          Text(
            widget.item.timeAgo,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
              fontSize: 10,
            ),
          ),
        ],
      ),
    ],
  );

  Widget _buildSellerSection(BuildContext context, ThemeData theme) =>
      Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface.withOpacity(0.5),
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          border: Border.all(color: theme.colorScheme.outline.withOpacity(0.1)),
        ),
        child: Row(
          children: [
            // Seller avatar with enhanced styling
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: theme.colorScheme.primary.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: CircleAvatar(
                radius: 14,
                backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                backgroundImage: widget.item.sellerProfileImage != null
                    ? NetworkImage(widget.item.sellerProfileImage!)
                    : null,
                child: widget.item.sellerProfileImage == null
                    ? Text(
                        (widget.item.sellerName?.isNotEmpty ?? false)
                            ? widget.item.sellerName![0].toUpperCase()
                            : '?',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      )
                    : null,
              ),
            ),

            const SizedBox(width: AppSpacing.sm),

            // Seller info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Sold by',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                      fontSize: 9,
                    ),
                  ),
                  Text(
                    widget.item.sellerName ?? 'Unknown Seller',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 11,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // View count and location
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (widget.item.viewCount > 0)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.visibility,
                        size: 10,
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        widget.item.viewCount.toString(),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                          fontSize: 9,
                        ),
                      ),
                    ],
                  ),
                if (widget.item.location != null)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 10,
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        widget.item.location!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                          fontSize: 9,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
              ],
            ),
          ],
        ),
      );

  IconData _getConditionIcon(String condition) {
    switch (condition) {
      case 'new':
        return Icons.new_releases;
      case 'like_new':
        return Icons.verified;
      case 'good':
        return Icons.check_circle;
      case 'fair':
        return Icons.warning;
      case 'poor':
        return Icons.error;
      default:
        return Icons.help;
    }
  }

  Color _getConditionColor(String condition) {
    switch (condition) {
      case 'new':
        return Colors.green;
      case 'like_new':
        return Colors.blue;
      case 'good':
        return Colors.orange;
      case 'fair':
        return Colors.red;
      case 'poor':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

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
