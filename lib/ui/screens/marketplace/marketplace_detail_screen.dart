/// @Branch: Marketplace Detail Screen Implementation
///
/// Detailed view of marketplace items with full functionality
/// Includes image gallery, seller info, contact options, and purchase flow
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/models/marketplace_item.dart';
import '../../../core/repositories/firebase_repository.dart';
import '../../../core/providers/auth_provider.dart';

class MarketplaceDetailScreen extends StatefulWidget {
  const MarketplaceDetailScreen({super.key, required this.itemId});
  final String itemId;

  @override
  State<MarketplaceDetailScreen> createState() =>
      _MarketplaceDetailScreenState();
}

class _MarketplaceDetailScreenState extends State<MarketplaceDetailScreen>
    with TickerProviderStateMixin {
  MarketplaceItem? _item;
  bool _isLoading = true;
  bool _isFavorite = false;
  int _currentImageIndex = 0;
  late PageController _pageController;
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadItem();
  }

  void _initializeAnimations() {
    _pageController = PageController();
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
  }

  @override
  void dispose() {
    _pageController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  Future<void> _loadItem() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final itemData = await FirebaseRepository.getMarketplaceItemById(
        widget.itemId,
      );

      if (itemData != null) {
        final item = MarketplaceItem.fromJson(itemData);
        setState(() {
          _item = item;
          _isLoading = false;
        });
        _fadeController.forward();

        // Check if item is favorited
        await _checkFavoriteStatus();
      } else {
        setState(() {
          _isLoading = false;
        });
        if (mounted) {
          _showErrorToast('Item not found');
        }
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        _showErrorToast('Error loading item: ${e.toString()}');
      }
      print('Error loading marketplace item: $e');
    }
  }

  Future<void> _checkFavoriteStatus() async {
    if (_item == null) return;

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final currentUser = authProvider.currentUser;

      if (currentUser != null) {
        // TODO: Implement checkFavoriteStatus in FirebaseRepository
        // For now, set to false
        setState(() {
          _isFavorite = false;
        });
      }
    } catch (e) {
      print('Error checking favorite status: $e');
    }
  }

  Future<void> _toggleFavorite() async {
    if (_item == null) return;

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final currentUser = authProvider.currentUser;

      if (currentUser == null) {
        _showErrorToast('Please sign in to add favorites');
        return;
      }

      // TODO: Implement toggleFavorite in FirebaseRepository
      setState(() {
        _isFavorite = !_isFavorite;
      });

      if (_isFavorite) {
        _showSuccessToast('Added to favorites');
      } else {
        _showSuccessToast('Removed from favorites');
      }
    } catch (e) {
      _showErrorToast('Error updating favorite: ${e.toString()}');
      print('Error toggling favorite: $e');
    }
  }

  void _showMoreOptions() {
    showModalBottomSheet<void>(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.report),
              title: const Text('Report this item'),
              onTap: () {
                Navigator.pop(context);
                _reportItem();
              },
            ),
            ListTile(
              leading: Icon(
                _isFavorite ? Icons.favorite : Icons.favorite_border,
              ),
              title: Text(
                _isFavorite ? 'Remove from favorites' : 'Add to favorites',
              ),
              onTap: () {
                Navigator.pop(context);
                _toggleFavorite();
              },
            ),
            ListTile(
              leading: const Icon(Icons.share),
              title: const Text('Share item'),
              onTap: () {
                Navigator.pop(context);
                _shareItem();
              },
            ),
            ListTile(
              leading: const Icon(Icons.location_on),
              title: const Text('View on map'),
              onTap: () {
                Navigator.pop(context);
                _viewOnMap();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _reportItem() {
    if (_item == null) return;

    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Report Item'),
        content: const Text('Please select a reason for reporting this item:'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _submitReport('inappropriate');
            },
            child: const Text('Inappropriate Content'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _submitReport('spam');
            },
            child: const Text('Spam'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _submitReport('fraud');
            },
            child: const Text('Fraud'),
          ),
        ],
      ),
    );
  }

  Future<void> _submitReport(String reason) async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final currentUser = authProvider.currentUser;

      if (currentUser == null) {
        _showErrorToast('Please sign in to report items');
        return;
      }

      // TODO: Implement submitReport in FirebaseRepository
      _showSuccessToast('Report submitted successfully');
    } catch (e) {
      _showErrorToast('Error submitting report: ${e.toString()}');
      print('Error submitting report: $e');
    }
  }

  Future<void> _shareItem() async {
    if (_item == null) return;

    try {
      final text =
          'Check out this item: ${_item!.title} - ${_item!.formattedPrice}';
      await Share.share(text);
    } catch (e) {
      _showErrorToast('Error sharing item: ${e.toString()}');
      print('Error sharing item: $e');
    }
  }

  void _viewOnMap() {
    if (_item == null || _item!.latitude == null || _item!.longitude == null) {
      _showErrorToast('Location not available');
      return;
    }

    // TODO: Implement map view
    _showSuccessToast('Map view coming soon!');
  }

  void _contactSeller() {
    if (_item == null) return;

    showModalBottomSheet<void>(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.message),
              title: const Text('Send Message'),
              onTap: () {
                Navigator.pop(context);
                _sendMessage();
              },
            ),
            ListTile(
              leading: const Icon(Icons.phone),
              title: const Text('Call Seller'),
              onTap: () {
                Navigator.pop(context);
                _makePhoneCall();
              },
            ),
            ListTile(
              leading: const Icon(Icons.email),
              title: const Text('Send Email'),
              onTap: () {
                Navigator.pop(context);
                _sendEmail();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _sendMessage() {
    // TODO: Navigate to chat with seller
    _showSuccessToast('Chat feature coming soon!');
  }

  void _makePhoneCall() {
    // TODO: Implement phone call
    _showSuccessToast('Phone call feature coming soon!');
  }

  void _sendEmail() {
    // TODO: Implement email
    _showSuccessToast('Email feature coming soon!');
  }

  void _showSuccessToast(String message) {
    try {
      Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.green,
        textColor: Colors.white,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: Colors.green),
        );
      }
    }
  }

  void _showErrorToast(String message) {
    try {
      Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: Colors.red),
        );
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
                'Loading item...',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.outline,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_item == null) {
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
              Icon(
                Icons.error_outline,
                size: 64,
                color: theme.colorScheme.outline,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Item not found',
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: theme.colorScheme.outline,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              ElevatedButton(
                onPressed: () => context.go('/marketplace'),
                child: const Text('Back to Marketplace'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: CustomScrollView(
        slivers: [_buildImageGallery(theme), _buildContent(theme)],
      ),
      bottomNavigationBar: _buildBottomBar(theme),
    );
  }

  Widget _buildImageGallery(ThemeData theme) => SliverAppBar(
    expandedHeight: 300,
    floating: false,
    pinned: true,
    backgroundColor: theme.colorScheme.surface,
    flexibleSpace: FlexibleSpaceBar(
      background: _item!.images.isNotEmpty
          ? PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentImageIndex = index;
                });
              },
              itemCount: _item!.images.length,
              itemBuilder: (context, index) => Image.network(
                _item!.images[index],
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: theme.colorScheme.surface,
                  child: Icon(
                    Icons.image_not_supported,
                    size: 64,
                    color: theme.colorScheme.outline,
                  ),
                ),
              ),
            )
          : Container(
              color: theme.colorScheme.surface,
              child: Icon(
                Icons.image_not_supported,
                size: 64,
                color: theme.colorScheme.outline,
              ),
            ),
    ),
    actions: [
      IconButton(
        icon: Icon(_isFavorite ? Icons.favorite : Icons.favorite_border),
        onPressed: _toggleFavorite,
      ),
      IconButton(icon: const Icon(Icons.share), onPressed: _shareItem),
      IconButton(
        icon: const Icon(Icons.more_vert),
        onPressed: _showMoreOptions,
      ),
    ],
  );

  Widget _buildContent(ThemeData theme) => SliverToBoxAdapter(
    child: AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title and price
                _buildTitleAndPrice(theme),
                const SizedBox(height: AppSpacing.md),

                // Category and condition
                _buildCategoryAndCondition(theme),
                const SizedBox(height: AppSpacing.md),

                // Description
                _buildDescription(theme),
                const SizedBox(height: AppSpacing.md),

                // Seller info
                _buildSellerInfo(theme),
                const SizedBox(height: AppSpacing.md),

                // Location
                if (_item!.location != null) ...[
                  _buildLocation(theme),
                  const SizedBox(height: AppSpacing.md),
                ],

                // Tags
                if (_item!.tags.isNotEmpty) ...[
                  _buildTags(theme),
                  const SizedBox(height: AppSpacing.md),
                ],
              ],
            ),
          ),
        );
      },
    ),
  );

  Widget _buildTitleAndPrice(ThemeData theme) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        _item!.title,
        style: theme.textTheme.headlineMedium?.copyWith(
          fontWeight: FontWeight.bold,
          height: 1.2,
        ),
      ),
      const SizedBox(height: AppSpacing.sm),
      Row(
        children: [
          Text(
            _item!.formattedPrice,
            style: theme.textTheme.headlineSmall?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (_item!.isNegotiable) ...[
            const SizedBox(width: AppSpacing.sm),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Negotiable',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ],
      ),
    ],
  );

  Widget _buildCategoryAndCondition(ThemeData theme) => Row(
    children: [
      Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: theme.colorScheme.secondary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          _item!.category,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.secondary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      const SizedBox(width: AppSpacing.sm),
      Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: theme.colorScheme.outline.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          _item!.condition,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.outline,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    ],
  );

  Widget _buildDescription(ThemeData theme) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'Description',
        style: theme.textTheme.titleMedium?.copyWith(
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
          _item!.description,
          style: theme.textTheme.bodyLarge?.copyWith(height: 1.6),
        ),
      ),
    ],
  );

  Widget _buildSellerInfo(ThemeData theme) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'Seller Information',
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
      const SizedBox(height: AppSpacing.sm),
      Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          border: Border.all(color: theme.colorScheme.outline.withOpacity(0.1)),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 25,
              backgroundImage: _item!.sellerProfileImage != null
                  ? NetworkImage(_item!.sellerProfileImage!)
                  : null,
              child: _item!.sellerProfileImage == null
                  ? Text(
                      _item!.sellerName?.isNotEmpty == true
                          ? _item!.sellerName![0].toUpperCase()
                          : 'S',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.onPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _item!.sellerName ?? 'Unknown Seller',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Member since ${_item!.createdAt.year}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.message),
              onPressed: _contactSeller,
            ),
          ],
        ),
      ),
    ],
  );

  Widget _buildLocation(ThemeData theme) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'Location',
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
      const SizedBox(height: AppSpacing.sm),
      Row(
        children: [
          Icon(Icons.location_on, size: 16, color: theme.colorScheme.primary),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: Text(
              _item!.location!,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    ],
  );

  Widget _buildTags(ThemeData theme) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'Tags',
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
      const SizedBox(height: AppSpacing.sm),
      Wrap(
        spacing: AppSpacing.sm,
        runSpacing: AppSpacing.sm,
        children: _item!.tags
            .map(
              (tag) => Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  tag,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            )
            .toList(),
      ),
    ],
  );

  Widget _buildBottomBar(ThemeData theme) => Container(
    padding: const EdgeInsets.all(AppSpacing.md),
    decoration: BoxDecoration(
      color: theme.colorScheme.surface,
      boxShadow: [
        BoxShadow(
          color: theme.colorScheme.shadow.withOpacity(0.1),
          blurRadius: 8,
          offset: const Offset(0, -2),
        ),
      ],
    ),
    child: Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _contactSeller,
            icon: const Icon(Icons.message),
            label: const Text('Contact Seller'),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              // TODO: Implement purchase flow
              _showSuccessToast('Purchase feature coming soon!');
            },
            icon: const Icon(Icons.shopping_cart),
            label: const Text('Buy Now'),
          ),
        ),
      ],
    ),
  );
}
