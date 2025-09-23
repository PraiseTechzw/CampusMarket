/// @Branch: Accommodation Card Widget Implementation
///
/// Enhanced reusable card component for displaying accommodation listings
/// Includes modern UI, animations, better visual hierarchy, and improved interactions
library;

import 'package:flutter/material.dart';

import '../../core/models/accommodation.dart';
import '../../core/theme/app_spacing.dart';
// import '../../core/widgets/glow_card.dart';
// import '../../core/widgets/live_badge.dart';

class AccommodationCard extends StatefulWidget {
  const AccommodationCard({
    super.key,
    required this.accommodation,
    this.onTap,
    this.onBook,
    this.onFavorite,
    this.showHostInfo = true,
    this.isFavorite = false,
  });
  final Accommodation accommodation;
  final VoidCallback? onTap;
  final VoidCallback? onBook;
  final VoidCallback? onFavorite;
  final bool showHostInfo;
  final bool isFavorite;

  @override
  State<AccommodationCard> createState() => _AccommodationCardState();
}

class _AccommodationCardState extends State<AccommodationCard>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  // late Animation<double> _fadeAnimation;
  // bool _isHovered = false;

  @override
  void initState() {
    super.initState();
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

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    _animationController.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    _animationController.reverse();
  }

  void _handleTapCancel() {
    _animationController.reverse();
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
        animation: _animationController,
        builder: (context, child) => Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
              border: Border.all(
                color: theme.colorScheme.outline.withOpacity(0.1),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Enhanced Image section
                _buildEnhancedImageSection(context, theme),

                // Content section
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title and Price
                      _buildTitleAndPrice(theme),

                      const SizedBox(height: AppSpacing.sm),

                      // Location and Room Info
                      _buildLocationAndRoomInfo(theme),

                      const SizedBox(height: AppSpacing.sm),

                      // Amenities
                      _buildAmenities(theme),

                      if (widget.showHostInfo) ...[
                        const SizedBox(height: AppSpacing.md),
                        _buildEnhancedHostSection(theme),
                      ],

                      const SizedBox(height: AppSpacing.md),

                      // Enhanced Action buttons
                      _buildEnhancedActionButtons(theme),
                    ],
                  ),
                ),
              ],
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
    height: 200,
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
          child: widget.accommodation.primaryImage.isNotEmpty
              ? Image.network(
                  widget.accommodation.primaryImage,
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
              if (widget.accommodation.isFeatured)
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
              if (widget.accommodation.hasMultipleImages)
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
                        '+${widget.accommodation.imageUrls.length - 1}',
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

        // Availability badge
        Positioned(
          bottom: AppSpacing.sm,
          left: AppSpacing.sm,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: widget.accommodation.isAvailable
                  ? Colors.green
                  : Colors.red,
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              boxShadow: [
                BoxShadow(
                  color:
                      (widget.accommodation.isAvailable
                              ? Colors.green
                              : Colors.red)
                          .withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  widget.accommodation.isAvailable
                      ? Icons.check_circle
                      : Icons.cancel,
                  size: 12,
                  color: Colors.white,
                ),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  widget.accommodation.isAvailable
                      ? 'Available'
                      : 'Unavailable',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
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

  Widget _buildPlaceholderImage(ThemeData theme) => Container(
    color: theme.colorScheme.surface,
    child: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.home,
            color: theme.colorScheme.onSurface.withOpacity(0.3),
            size: 48,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'No Image',
            style: theme.textTheme.bodyMedium?.copyWith(
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
      // Title
      Text(
        widget.accommodation.title,
        style: theme.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
          height: 1.2,
        ),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),

      const SizedBox(height: AppSpacing.sm),

      // Price and room info
      Row(
        children: [
          Flexible(
            child: Container(
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
                widget.accommodation.formattedPrice,
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),

          const SizedBox(width: AppSpacing.sm),

          Flexible(
            child: Container(
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
                  Icon(Icons.bed, size: 14, color: theme.colorScheme.secondary),
                  const SizedBox(width: AppSpacing.xs),
                  Flexible(
                    child: Text(
                      widget.accommodation.roomInfo,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.secondary,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ],
  );

  Widget _buildLocationAndRoomInfo(ThemeData theme) => Row(
    children: [
      Icon(Icons.location_on, size: 16, color: theme.colorScheme.primary),
      const SizedBox(width: AppSpacing.xs),
      Expanded(
        child: Text(
          widget.accommodation.address,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.7),
            fontWeight: FontWeight.w500,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      if (widget.accommodation.area != null) ...[
        const SizedBox(width: AppSpacing.sm),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.xs,
          ),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            border: Border.all(
              color: theme.colorScheme.outline.withOpacity(0.2),
            ),
          ),
          child: Text(
            '${widget.accommodation.area!.toStringAsFixed(0)} ${widget.accommodation.areaUnit}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    ],
  );

  Widget _buildAmenities(ThemeData theme) {
    if (widget.accommodation.amenities.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Amenities',
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface.withOpacity(0.8),
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Wrap(
          spacing: AppSpacing.xs,
          runSpacing: AppSpacing.xs,
          children: widget.accommodation.amenities
              .take(4)
              .map(
                (amenity) => Container(
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
                    amenity,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              )
              .toList(),
        ),
        if (widget.accommodation.amenities.length > 4)
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.xs),
            child: Text(
              '+${widget.accommodation.amenities.length - 4} more',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.5),
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildEnhancedHostSection(ThemeData theme) => Container(
    padding: const EdgeInsets.all(AppSpacing.sm),
    decoration: BoxDecoration(
      color: theme.colorScheme.surface.withOpacity(0.5),
      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      border: Border.all(color: theme.colorScheme.outline.withOpacity(0.1)),
    ),
    child: Row(
      children: [
        // Host avatar
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: theme.colorScheme.primary.withOpacity(0.2),
              width: 2,
            ),
          ),
          child: CircleAvatar(
            radius: 16,
            backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
            backgroundImage: widget.accommodation.hostProfileImage != null
                ? NetworkImage(widget.accommodation.hostProfileImage!)
                : null,
            child: widget.accommodation.hostProfileImage == null
                ? Text(
                    widget.accommodation.hostName.isNotEmpty
                        ? widget.accommodation.hostName[0].toUpperCase()
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

        // Host info
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hosted by',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
              Text(
                widget.accommodation.hostName,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),

        // View count
        if (widget.accommodation.viewCount > 0)
          Row(
            children: [
              Icon(
                Icons.visibility,
                size: 14,
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                widget.accommodation.viewCount.toString(),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
      ],
    ),
  );

  Widget _buildEnhancedActionButtons(ThemeData theme) => Row(
    children: [
      // Book Now button
      Expanded(
        child: ElevatedButton.icon(
          onPressed: widget.accommodation.isAvailable ? widget.onBook : null,
          icon: const Icon(Icons.calendar_today),
          label: const Text('Book Now'),
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.colorScheme.primary,
            foregroundColor: theme.colorScheme.onPrimary,
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            ),
          ),
        ),
      ),

      const SizedBox(width: AppSpacing.sm),

      // Contact Host button
      Flexible(
        child: OutlinedButton.icon(
          onPressed: () {
            // TODO: Implement contact host functionality
          },
          icon: const Icon(Icons.message, size: 16),
          label: const Text('Contact'),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            ),
          ),
        ),
      ),
    ],
  );
}
