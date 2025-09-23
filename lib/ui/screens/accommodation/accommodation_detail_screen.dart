/// @Branch: Accommodation Detail Screen Implementation
///
/// Enhanced detailed view of accommodation with modern UI, image gallery, and improved interactions
/// Includes comprehensive property details, enhanced booking flow, and better user experience

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/services.dart';

import '../../../core/models/accommodation.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/glow_card.dart';
import '../../../core/repositories/firebase_repository.dart';
import '../../../core/config/firebase_config.dart';
import '../../../core/services/auth_service.dart';

enum ReportReason {
  inappropriateContent('Inappropriate Content'),
  fakeListing('Fake Listing'),
  spam('Spam'),
  harassment('Harassment'),
  other('Other');

  const ReportReason(this.displayName);
  final String displayName;
}

class AccommodationDetailScreen extends StatefulWidget {
  const AccommodationDetailScreen({required this.accommodationId, super.key});
  final String accommodationId;

  @override
  State<AccommodationDetailScreen> createState() =>
      _AccommodationDetailScreenState();
}

class _AccommodationDetailScreenState extends State<AccommodationDetailScreen>
    with TickerProviderStateMixin {
  Accommodation? accommodation;
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';
  bool _isFavorite = false;
  int _currentImageIndex = 0;
  late PageController _pageController;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  StreamSubscription<DocumentSnapshot>? _accommodationSubscription;

  // Booking state
  DateTime? _checkInDate;
  DateTime? _checkOutDate;
  bool _isBooking = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _loadAccommodation();
    _setupRealTimeUpdates();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _fadeController.dispose();
    _accommodationSubscription?.cancel();
    super.dispose();
  }

  Future<void> _loadAccommodation() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _hasError = false;
      _errorMessage = '';
    });

    try {
      // Try to load from Firebase first
      final accommodationData = await FirebaseRepository.getAccommodationById(
        widget.accommodationId,
      );

      if (!mounted) return; // Check if widget is still mounted

      if (accommodationData != null) {
        // Convert Firebase data to Accommodation model
        final accommodationJson = _convertFirebaseDataToAccommodation(
          accommodationData,
        );
        final loadedAccommodation = Accommodation.fromJson(accommodationJson);

        if (mounted) {
          setState(() {
            accommodation = loadedAccommodation;
            _isLoading = false;
            _hasError = false;
          });
          _fadeController.forward();
        }
      } else {
        // No accommodation found in Firebase
        if (mounted) {
          setState(() {
            _hasError = true;
            _errorMessage = 'Accommodation not found';
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      print('Error loading accommodation from Firebase: $e');
      if (!mounted) return; // Check if widget is still mounted

      setState(() {
        _hasError = true;
        _errorMessage = 'Failed to load accommodation details: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  void _setupRealTimeUpdates() {
    try {
      _accommodationSubscription = FirebaseConfig.firestore
          .collection('accommodations')
          .doc(widget.accommodationId)
          .snapshots()
          .listen(
            (DocumentSnapshot snapshot) {
              if (!mounted) return;

              if (snapshot.exists) {
                try {
                  final data = snapshot.data() as Map<String, dynamic>;
                  data['id'] = snapshot.id;

                  final accommodationJson = _convertFirebaseDataToAccommodation(
                    data,
                  );
                  final updatedAccommodation = Accommodation.fromJson(
                    accommodationJson,
                  );

                  if (mounted) {
                    setState(() {
                      accommodation = updatedAccommodation;
                      _hasError = false;
                      _errorMessage = '';
                    });
                  }
                } catch (e) {
                  print('Error parsing real-time accommodation update: $e');
                }
              }
            },
            onError: (Object error) {
              print('Real-time accommodation update error: $error');
              if (mounted) {
                setState(() {
                  _hasError = true;
                  _errorMessage =
                      'Failed to load real-time updates: ${error.toString()}';
                });
              }
            },
          );
    } catch (e) {
      print('Error setting up real-time updates: $e');
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
                'Loading property details...',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_hasError && accommodation == null) {
      return Scaffold(
        backgroundColor: theme.colorScheme.surface,
        appBar: AppBar(
          backgroundColor: theme.colorScheme.surface,
          elevation: 0,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: theme.colorScheme.error,
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  'Failed to load accommodation',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  _errorMessage.isNotEmpty
                      ? _errorMessage
                      : 'Something went wrong. Please try again.',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.xl),
                ElevatedButton.icon(
                  onPressed: () {
                    if (mounted) {
                      setState(() {
                        _hasError = false;
                        _errorMessage = '';
                        _isLoading = true;
                      });
                      _loadAccommodation();
                    }
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
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
        ),
      );
    }

    if (accommodation == null) {
      return Scaffold(
        backgroundColor: theme.colorScheme.surface,
        appBar: AppBar(
          backgroundColor: theme.colorScheme.surface,
          elevation: 0,
        ),
        body: const Center(child: Text('Accommodation not found')),
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
                  // Connection Status
                  _buildConnectionStatus(theme),

                  const SizedBox(height: AppSpacing.md),

                  // Title and Price Section
                  _buildTitleAndPriceSection(theme),

                  const SizedBox(height: AppSpacing.lg),

                  // Key Details Section
                  _buildKeyDetailsSection(theme),

                  const SizedBox(height: AppSpacing.lg),

                  // Description Section
                  _buildDescriptionSection(theme),

                  const SizedBox(height: AppSpacing.lg),

                  // Amenities Section
                  _buildAmenitiesSection(theme),

                  const SizedBox(height: AppSpacing.lg),

                  // Host Section
                  _buildEnhancedHostCard(theme),

                  const SizedBox(height: AppSpacing.lg),

                  // Enhanced Booking Section
                  _buildEnhancedBookingSection(theme),

                  const SizedBox(height: AppSpacing.xl),

                  // Similar Properties Section
                  _buildSimilarPropertiesSection(theme),

                  const SizedBox(height: AppSpacing.xl),
                ]),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _buildFloatingActionButton(theme),
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
            itemCount: accommodation?.imageUrls.length ?? 0,
            itemBuilder: (context, index) => Image.network(
              accommodation?.imageUrls[index] ?? '',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                color: theme.colorScheme.surface,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.home_outlined,
                        size: 64,
                        color: theme.colorScheme.onSurface.withOpacity(0.3),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        'Image not available',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
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
          if ((accommodation?.imageUrls.length ?? 0) > 1)
            Positioned(
              bottom: AppSpacing.lg,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  accommodation?.imageUrls.length ?? 0,
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
        onPressed: _toggleFavorite,
      ),
      IconButton(
        icon: const Icon(Icons.share, color: Colors.white),
        onPressed: _shareAccommodation,
      ),
      IconButton(
        icon: const Icon(Icons.more_vert, color: Colors.white),
        onPressed: _showMoreOptions,
      ),
    ],
  );

  Widget _buildTitleAndPriceSection(ThemeData theme) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      // Title
      Text(
        accommodation?.propertyTitle ?? 'Untitled Property',
        style: theme.textTheme.headlineMedium?.copyWith(
          fontWeight: FontWeight.bold,
          height: 1.2,
        ),
      ),

      const SizedBox(height: AppSpacing.sm),

      // Price and room info
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
              accommodation?.formattedPrice ?? '\$0/month',
              style: theme.textTheme.headlineLarge?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
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
              color: theme.colorScheme.secondary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.bed, size: 16, color: theme.colorScheme.secondary),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  accommodation?.roomInfo ?? 'Room info not available',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.secondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),

      const SizedBox(height: AppSpacing.sm),

      // Location
      Row(
        children: [
          Icon(Icons.location_on, size: 16, color: theme.colorScheme.primary),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: Text(
              accommodation?.propertyAddress ?? 'Address not available',
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
        _buildDetailRow(
          theme,
          Icons.home,
          'Property Type',
          accommodation?.type.toUpperCase() ?? 'UNKNOWN',
        ),
        const SizedBox(height: AppSpacing.sm),
        _buildDetailRow(
          theme,
          Icons.bed,
          'Bedrooms',
          accommodation?.bedrooms.toString() ?? '0',
        ),
        const SizedBox(height: AppSpacing.sm),
        _buildDetailRow(
          theme,
          Icons.bathroom,
          'Bathrooms',
          accommodation?.bathrooms.toString() ?? '0',
        ),
        if (accommodation?.area != null) ...[
          const SizedBox(height: AppSpacing.sm),
          _buildDetailRow(
            theme,
            Icons.square_foot,
            'Area',
            '${accommodation!.area!.toStringAsFixed(0)} ${accommodation!.areaUnit}',
          ),
        ],
        const SizedBox(height: AppSpacing.sm),
        _buildDetailRow(
          theme,
          Icons.access_time,
          'Listed',
          accommodation?.timeAgo ?? 'Unknown',
        ),
        const SizedBox(height: AppSpacing.sm),
        _buildDetailRow(
          theme,
          Icons.visibility,
          'Views',
          accommodation?.viewCount.toString() ?? '0',
        ),
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
          accommodation?.propertyDescription ?? 'No description available',
          style: theme.textTheme.bodyLarge?.copyWith(height: 1.6),
        ),
      ),
    ],
  );

  Widget _buildAmenitiesSection(ThemeData theme) {
    if ((accommodation?.amenities.length ?? 0) == 0)
      return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Amenities',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: (accommodation?.amenities ?? [])
              .map(
                (amenity) => Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                    border: Border.all(
                      color: theme.colorScheme.primary.withOpacity(0.2),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _getAmenityIcon(amenity),
                        size: 16,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        amenity,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  IconData _getAmenityIcon(String amenity) {
    switch (amenity.toLowerCase()) {
      case 'wifi':
        return Icons.wifi;
      case 'parking':
        return Icons.local_parking;
      case 'pet friendly':
        return Icons.pets;
      case 'furnished':
        return Icons.chair;
      case 'air conditioning':
        return Icons.ac_unit;
      case 'laundry':
        return Icons.local_laundry_service;
      case 'gym':
        return Icons.fitness_center;
      case 'pool':
        return Icons.pool;
      case 'balcony':
        return Icons.balcony;
      case 'garden':
        return Icons.yard;
      default:
        return Icons.star;
    }
  }

  Widget _buildEnhancedHostCard(ThemeData theme) => Container(
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
            radius: 30,
            backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
            backgroundImage: accommodation?.hostProfileImage != null
                ? NetworkImage(accommodation!.hostProfileImage!)
                : null,
            child: accommodation?.hostProfileImage == null
                ? Text(
                    (accommodation?.hostName.isNotEmpty ?? false)
                        ? accommodation!.hostName[0].toUpperCase()
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
              const SizedBox(height: AppSpacing.xs),
              Text(
                accommodation?.hostDisplayName ?? 'Unknown Host',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                '${accommodation?.memberSince ?? 'Member since 2024'} • ${accommodation?.rating ?? '4.8★'}',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ),

        // Contact button
        ElevatedButton.icon(
          onPressed: _contactHost,
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

  Widget _buildEnhancedBookingSection(ThemeData theme) => Container(
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Book this accommodation',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: AppSpacing.md),

        // Date picker
        Text(
          'Select dates',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),

        const SizedBox(height: AppSpacing.sm),

        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _selectCheckInDate(),
                icon: const Icon(Icons.calendar_today),
                label: Text(
                  _checkInDate != null
                      ? '${_checkInDate!.day}/${_checkInDate!.month}/${_checkInDate!.year}'
                      : 'Check-in',
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                ),
              ),
            ),

            const SizedBox(width: AppSpacing.sm),

            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _selectCheckOutDate(),
                icon: const Icon(Icons.calendar_today),
                label: Text(
                  _checkOutDate != null
                      ? '${_checkOutDate!.day}/${_checkOutDate!.month}/${_checkOutDate!.year}'
                      : 'Check-out',
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: AppSpacing.lg),

        // Book button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: (accommodation?.isAvailable ?? false)
                ? () {
                    _handleBooking();
                  }
                : null,
            icon: const Icon(Icons.calendar_today),
            label: Text(
              (accommodation?.isAvailable ?? false)
                  ? 'Book Now'
                  : 'Not Available',
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: (accommodation?.isAvailable ?? false)
                  ? theme.colorScheme.primary
                  : theme.colorScheme.outline,
              foregroundColor: (accommodation?.isAvailable ?? false)
                  ? theme.colorScheme.onPrimary
                  : theme.colorScheme.onSurface,
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
            ),
          ),
        ),
      ],
    ),
  );

  Widget _buildSimilarPropertiesSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Similar Properties',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            TextButton(
              onPressed: () => _navigateToSimilarProperties(),
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        SizedBox(
          height: 220,
          child: FutureBuilder<List<Accommodation>>(
            future: _loadSimilarAccommodations(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError ||
                  !snapshot.hasData ||
                  snapshot.data!.isEmpty) {
                return const Center(child: Text('No similar properties found'));
              }

              return ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  final similarAccommodation = snapshot.data![index];
                  return Container(
                    width: 160,
                    margin: const EdgeInsets.only(right: AppSpacing.md),
                    child: GlowCard(
                      onTap: () => context.go(
                        '/accommodation/${similarAccommodation.id}',
                      ),
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
                                similarAccommodation.primaryImage,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Icon(
                                    Icons.home,
                                    color: theme.colorScheme.onSurface
                                        .withOpacity(0.3),
                                  );
                                },
                              ),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            similarAccommodation.title,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            similarAccommodation.formattedPrice,
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
              );
            },
          ),
        ),
      ],
    );
  }

  void _handleBooking() {
    if (accommodation == null) return;

    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Book ${accommodation!.title}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Price: ${accommodation!.formattedPrice}'),
            const SizedBox(height: 8),
            Text('Location: ${accommodation!.address}'),
            const SizedBox(height: 8),
            Text('Host: ${accommodation!.hostName}'),
            const SizedBox(height: 16),
            const Text('Select your preferred dates:'),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      // TODO: Implement date picker
                    },
                    icon: const Icon(Icons.calendar_today),
                    label: const Text('Check-in'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      // TODO: Implement date picker
                    },
                    icon: const Icon(Icons.calendar_today),
                    label: const Text('Check-out'),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: _isBooking ? null : _processBooking,
            child: const Text('Confirm Booking'),
          ),
        ],
      ),
    );
  }

  void _contactHost() {
    if (accommodation == null) return;

    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Contact ${accommodation!.hostName}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Property: ${accommodation!.title}'),
            const SizedBox(height: 8),
            Text('Price: ${accommodation!.formattedPrice}'),
            const SizedBox(height: 16),
            const Text('Choose how you\'d like to contact:'),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.message),
              title: const Text('Send Message'),
              subtitle: const Text('Send a direct message'),
              onTap: () {
                Navigator.pop(context);
                _openMessaging();
              },
            ),
            ListTile(
              leading: const Icon(Icons.phone),
              title: const Text('Call Host'),
              subtitle: const Text('Make a phone call'),
              onTap: () {
                Navigator.pop(context);
                _makePhoneCall();
              },
            ),
            ListTile(
              leading: const Icon(Icons.email),
              title: const Text('Send Email'),
              subtitle: const Text('Send an email inquiry'),
              onTap: () {
                Navigator.pop(context);
                _sendEmail();
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  // Data conversion methods (similar to accommodation_list_screen.dart)
  Map<String, dynamic> _convertFirebaseDataToAccommodation(
    Map<String, dynamic> data,
  ) {
    return {
      'id': data['id'] ?? '',
      'title': data['title'] ?? 'Untitled Property',
      'description': data['description'] ?? '',
      'price': _parsePrice(data),
      'currency': data['currency'] ?? 'USD',
      'pricePeriod': data['pricePeriod'] ?? 'month',
      'imageUrls': _parseStringList(data['images'] ?? data['imageUrls']),
      'type': _parseAccommodationType(data),
      'bedrooms': _parseInt(data['bedrooms'], 1),
      'bathrooms': _parseInt(data['bathrooms'], 1),
      'area': data['area']?.toDouble(),
      'areaUnit': data['areaUnit'] ?? data['area_unit'] ?? 'sqft',
      'hostId': data['userId'] ?? data['user_id'] ?? data['hostId'] ?? '',
      'hostName': _parseHostName(data),
      'hostProfileImage': _parseHostProfileImage(data),
      'hostEmail': _parseHostEmail(data),
      'hostPhone': _parseHostPhone(data),
      'address': data['address'] ?? data['location'] ?? 'Address not provided',
      'latitude': data['latitude']?.toDouble(),
      'longitude': data['longitude']?.toDouble(),
      'amenities': _parseStringList(data['amenities']),
      'rules': _parseStringList(data['rules']),
      'isAvailable': data['isAvailable'] ?? data['is_available'] ?? true,
      'isFeatured': data['isFeatured'] ?? data['is_featured'] ?? false,
      'createdAt': _parseDateTime(
        data['createdAt'] ?? data['created_at'],
      ).toIso8601String(),
      'updatedAt': _parseDateTime(
        data['updatedAt'] ?? data['updated_at'],
      ).toIso8601String(),
      'viewCount': _parseInt(data['viewCount'] ?? data['view_count'], 0),
      'favoriteCount': _parseInt(
        data['favoriteCount'] ?? data['favorite_count'],
        0,
      ),
      'status': _parseAccommodationStatus(data),
      'availability': <Map<String, dynamic>>[],
      'roommatePreferences': <Map<String, dynamic>>[],
    };
  }

  double _parsePrice(Map<String, dynamic> data) {
    final priceValue =
        data['pricePerMonth'] ??
        data['price_per_month'] ??
        data['price'] ??
        data['monthlyPrice'] ??
        0;

    if (priceValue is num) {
      return priceValue.toDouble();
    } else if (priceValue is String) {
      return double.tryParse(priceValue) ?? 0.0;
    }
    return 0.0;
  }

  String _parseAccommodationType(Map<String, dynamic> data) {
    final type =
        data['propertyType'] ??
        data['property_type'] ??
        data['roomType'] ??
        data['room_type'] ??
        data['type'] ??
        'room';

    final typeString = type.toString();

    switch (typeString.toLowerCase()) {
      case 'full_room':
      case 'full room':
        return 'full_room';
      case '2_room':
      case '2 room':
      case 'two_room':
        return '2_room';
      case '3_room':
      case '3 room':
      case 'three_room':
        return '3_room';
      case 'shared_room':
      case 'shared room':
        return 'shared_room';
      case 'apartment':
        return 'apartment';
      case 'house':
        return 'house';
      case 'studio':
        return 'studio';
      default:
        return typeString;
    }
  }

  String _parseHostName(Map<String, dynamic> data) {
    final hostName =
        data['hostName'] ??
        data['host_name'] ??
        data['ownerName'] ??
        data['owner_name'];

    if (hostName != null) return hostName.toString();

    final userData = data['users'] as Map<String, dynamic>?;
    if (userData != null) {
      final firstName = userData['first_name'] ?? userData['firstName'];
      final lastName = userData['last_name'] ?? userData['lastName'];
      if (firstName != null && lastName != null) {
        return '${firstName.toString()} ${lastName.toString()}';
      } else if (firstName != null) {
        return firstName.toString();
      }
    }

    return 'Unknown Host';
  }

  String? _parseHostProfileImage(Map<String, dynamic> data) {
    final imageUrl =
        data['hostProfileImage'] ??
        data['host_profile_image'] ??
        data['hostImage'] ??
        data['ownerImage'];

    if (imageUrl != null) return imageUrl.toString();

    final userData = data['users'] as Map<String, dynamic>?;
    if (userData != null) {
      final profileImage =
          userData['profile_image_url'] ?? userData['profileImageUrl'];
      return profileImage?.toString();
    }

    return null;
  }

  String? _parseHostEmail(Map<String, dynamic> data) {
    final email =
        data['hostEmail'] ??
        data['host_email'] ??
        data['hostEmailAddress'] ??
        data['ownerEmail'];

    if (email != null) return email.toString();

    final userData = data['users'] as Map<String, dynamic>?;
    if (userData != null) {
      final userEmail = userData['email'] ?? userData['emailAddress'];
      return userEmail?.toString();
    }

    return null;
  }

  String? _parseHostPhone(Map<String, dynamic> data) {
    final phone =
        data['hostPhone'] ??
        data['host_phone'] ??
        data['hostPhoneNumber'] ??
        data['ownerPhone'];

    if (phone != null) return phone.toString();

    final userData = data['users'] as Map<String, dynamic>?;
    if (userData != null) {
      final userPhone = userData['phone'] ?? userData['phoneNumber'];
      return userPhone?.toString();
    }

    return null;
  }

  int _parseInt(dynamic value, int defaultValue) {
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? defaultValue;
    return defaultValue;
  }

  String _parseAccommodationStatus(Map<String, dynamic> data) {
    final status = data['status'] ?? 'active';
    if (status is String) {
      switch (status.toLowerCase()) {
        case 'draft':
          return 'draft';
        case 'pending':
          return 'pending';
        case 'active':
          return 'active';
        case 'rented':
          return 'rented';
        case 'rejected':
          return 'rejected';
        case 'archived':
          return 'archived';
        default:
          return 'active';
      }
    }
    return 'active';
  }

  DateTime _parseDateTime(dynamic dateValue) {
    if (dateValue == null) return DateTime.now();

    if (dateValue is String) {
      try {
        return DateTime.parse(dateValue);
      } catch (e) {
        print('Error parsing date string: $dateValue, error: $e');
        return DateTime.now();
      }
    }

    if (dateValue is DateTime) {
      return dateValue;
    }

    if (dateValue.runtimeType.toString().contains('Timestamp')) {
      try {
        return (dateValue as dynamic).toDate() as DateTime;
      } catch (e) {
        print('Error parsing Firestore timestamp: $e');
        return DateTime.now();
      }
    }

    if (dateValue is Map<String, dynamic>) {
      try {
        final seconds = dateValue['_seconds'] as int?;
        final nanoseconds = dateValue['_nanoseconds'] as int?;
        if (seconds != null) {
          return DateTime.fromMillisecondsSinceEpoch(
            seconds * 1000 + (nanoseconds ?? 0) ~/ 1000000,
          );
        }
      } catch (e) {
        print('Error parsing timestamp map: $e');
      }
    }

    print('Unknown date format: ${dateValue.runtimeType} - $dateValue');
    return DateTime.now();
  }

  List<String> _parseStringList(dynamic value) {
    if (value == null) return <String>[];

    if (value is List) {
      return value.map((item) => item.toString()).toList();
    }

    if (value is String) {
      return value
          .split(',')
          .map((item) => item.trim())
          .where((item) => item.isNotEmpty)
          .toList();
    }

    return <String>[];
  }

  void _toggleFavorite() {
    if (!mounted) return;

    setState(() {
      _isFavorite = !_isFavorite;
    });

    _toggleFavoriteInFirebase();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isFavorite ? 'Added to favorites' : 'Removed from favorites',
          ),
          backgroundColor: _isFavorite ? Colors.green : Colors.orange,
          duration: const Duration(seconds: 2),
          action: SnackBarAction(
            label: 'Undo',
            onPressed: () {
              if (mounted) {
                setState(() {
                  _isFavorite = !_isFavorite;
                });
              }
            },
          ),
        ),
      );
    }
  }

  void _shareAccommodation() {
    if (accommodation == null) return;

    final shareText =
        '''
🏠 ${accommodation!.title}
💰 ${accommodation!.currency} ${accommodation!.price}/${accommodation!.pricePeriod}
📍 ${accommodation!.address}
${accommodation!.description}

Check out this amazing accommodation on Campus Market!
''';

    Share.share(
      shareText,
      subject: 'Check out this accommodation: ${accommodation!.title}',
    );
  }

  void _showReportDialog() {
    if (accommodation == null) return;

    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Report Listing'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Please select a reason for reporting this listing:'),
            const SizedBox(height: AppSpacing.md),
            ...ReportReason.values.map(
              (reason) => RadioListTile<ReportReason>(
                title: Text(reason.displayName),
                value: reason,
                groupValue: null,
                onChanged: (value) {
                  Navigator.pop(context);
                  _submitReport(value!);
                },
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _submitReport(ReportReason reason) async {
    if (accommodation == null) return;

    try {
      // Show loading
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                SizedBox(width: 16),
                Text('Submitting report...'),
              ],
            ),
            duration: Duration(seconds: 2),
          ),
        );
      }

      // Submit report to Firebase
      await FirebaseConfig.firestore.collection('reports').add({
        'accommodationId': accommodation!.id,
        'accommodationTitle': accommodation!.title,
        'reason': reason.name,
        'reasonDisplayName': reason.displayName,
        'reporterId': AuthService.currentUserId ?? 'anonymous',
        'reporterEmail': AuthService.currentUserEmail ?? 'guest@example.com',
        'description': '',
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Report submitted successfully. Thank you for your feedback!',
            ),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      print('Error submitting report: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to submit report: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  void _saveToCollections() async {
    if (accommodation == null) return;

    try {
      // Show loading
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                SizedBox(width: 16),
                Text('Saving to collections...'),
              ],
            ),
            duration: Duration(seconds: 2),
          ),
        );
      }

      // Save to user's collections in Firebase
      await FirebaseConfig.firestore
          .collection('users')
          .doc(AuthService.currentUserId ?? 'anonymous')
          .collection('savedAccommodations')
          .doc(accommodation!.id)
          .set({
            'accommodationId': accommodation!.id,
            'savedAt': FieldValue.serverTimestamp(),
            'accommodationData': {
              'title': accommodation!.title,
              'price': accommodation!.price,
              'currency': accommodation!.currency,
              'pricePeriod': accommodation!.pricePeriod,
              'imageUrls': accommodation!.imageUrls,
              'address': accommodation!.address,
              'type': accommodation!.type,
            },
          });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Saved to your collections!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      print('Error saving to collections: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save to collections: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  void _viewOnMap() {
    if (accommodation == null) return;

    // TODO: Implement map view with location
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Map view for: ${accommodation!.address}'),
          duration: const Duration(seconds: 2),
          action: SnackBarAction(
            label: 'Open Maps',
            onPressed: () {
              // TODO: Open external maps app
              _openExternalMaps();
            },
          ),
        ),
      );
    }
  }

  void _openExternalMaps() {
    if (accommodation == null) return;

    // TODO: Implement external maps opening
    // For now, show coordinates
    if (mounted) {
      showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Location Details'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Address: ${accommodation!.address}'),
              const SizedBox(height: 8),
              Text(
                'Coordinates: ${accommodation!.latitude}, ${accommodation!.longitude}',
              ),
              const SizedBox(height: 16),
              const Text('Map integration coming soon!'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        ),
      );
    }
  }

  Future<void> _selectCheckInDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _checkInDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null && picked != _checkInDate) {
      setState(() {
        _checkInDate = picked;
        // If check-out is before check-in, clear it
        if (_checkOutDate != null && _checkOutDate!.isBefore(picked)) {
          _checkOutDate = null;
        }
      });
    }
  }

  Future<void> _selectCheckOutDate() async {
    if (_checkInDate == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select check-in date first'),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _checkOutDate ?? _checkInDate!.add(const Duration(days: 1)),
      firstDate: _checkInDate!.add(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null && picked != _checkOutDate) {
      setState(() {
        _checkOutDate = picked;
      });
    }
  }

  Future<void> _processBooking() async {
    if (accommodation == null) return;

    // Validate dates
    if (_checkInDate == null || _checkOutDate == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select both check-in and check-out dates'),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }

    if (_checkOutDate!.isBefore(_checkInDate!) ||
        _checkOutDate!.isAtSameMomentAs(_checkInDate!)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Check-out date must be after check-in date'),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }

    setState(() {
      _isBooking = true;
    });

    try {
      // Show loading
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                SizedBox(width: 16),
                Text('Processing booking...'),
              ],
            ),
            duration: Duration(seconds: 2),
          ),
        );
      }

      // Create booking in Firebase
      final bookingData = {
        'accommodationId': accommodation!.id,
        'accommodationTitle': accommodation!.title,
        'hostId': accommodation!.hostId,
        'hostName': accommodation!.hostName,
        'guestId': AuthService.currentUserId ?? 'anonymous',
        'guestEmail': AuthService.currentUserEmail ?? 'guest@example.com',
        'checkInDate': Timestamp.fromDate(_checkInDate!),
        'checkOutDate': Timestamp.fromDate(_checkOutDate!),
        'totalNights': _checkOutDate!.difference(_checkInDate!).inDays,
        'pricePerNight': accommodation!.price,
        'totalPrice':
            accommodation!.price *
            _checkOutDate!.difference(_checkInDate!).inDays,
        'currency': accommodation!.currency,
        'status': 'pending',
        'specialRequests': '',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      final bookingRef = await FirebaseConfig.firestore
          .collection('bookings')
          .add(bookingData);

      // Update accommodation availability
      await FirebaseConfig.firestore
          .collection('accommodations')
          .doc(accommodation!.id)
          .update({'updatedAt': FieldValue.serverTimestamp()});

      if (mounted) {
        Navigator.of(context).pop(); // Close booking dialog

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Booking request sent for ${accommodation!.title}'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
            action: SnackBarAction(
              label: 'View',
              onPressed: () => _navigateToBookingDetails(bookingRef.id),
            ),
          ),
        );
      }
    } catch (e) {
      print('Error processing booking: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to process booking: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isBooking = false;
        });
      }
    }
  }

  void _navigateToBookingDetails(String bookingId) {
    if (mounted) {
      context.go('/bookings/$bookingId');
    }
  }

  void _openMessaging() {
    if (accommodation == null) return;

    if (mounted) {
      final messageController = TextEditingController();
      showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Send Message'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Send a message to ${accommodation!.hostName}'),
              const SizedBox(height: 16),
              TextField(
                controller: messageController,
                decoration: const InputDecoration(
                  hintText: 'Type your message here...',
                  border: OutlineInputBorder(),
                ),
                maxLines: 4,
                maxLength: 500,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final message = messageController.text.trim();
                if (message.isEmpty) return;

                final scaffoldMessenger = ScaffoldMessenger.of(context);
                final navigator = Navigator.of(context);

                try {
                  // Save message to Firebase
                  await FirebaseConfig.firestore.collection('messages').add({
                    'senderId': AuthService.currentUserId ?? 'anonymous',
                    'senderEmail':
                        AuthService.currentUserEmail ?? 'guest@example.com',
                    'receiverId': accommodation!.hostId,
                    'receiverName': accommodation!.hostName,
                    'accommodationId': accommodation!.id,
                    'accommodationTitle': accommodation!.title,
                    'message': message,
                    'timestamp': FieldValue.serverTimestamp(),
                    'isRead': false,
                  });

                  if (mounted) {
                    navigator.pop();
                    scaffoldMessenger.showSnackBar(
                      const SnackBar(
                        content: Text('Message sent successfully!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    scaffoldMessenger.showSnackBar(
                      SnackBar(
                        content: Text(
                          'Failed to send message: ${e.toString()}',
                        ),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              child: const Text('Send'),
            ),
          ],
        ),
      );
    }
  }

  void _makePhoneCall() {
    if (accommodation == null) return;

    // Get phone number from accommodation data
    final phoneNumber = accommodation!.hostContactPhone;

    if (mounted) {
      showDialog<void>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Call Host'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Call ${accommodation!.hostName}'),
              const SizedBox(height: 8),
              Text('Phone: $phoneNumber'),
              const SizedBox(height: 16),
              const Text('This will open your phone app'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(dialogContext);
                try {
                  final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
                  if (await canLaunchUrl(phoneUri)) {
                    await launchUrl(phoneUri);
                  } else {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Could not open phone app'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error opening phone: ${e.toString()}'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              child: const Text('Call'),
            ),
          ],
        ),
      );
    }
  }

  void _sendEmail() {
    if (accommodation == null) return;

    // Get email from accommodation data
    final hostEmail = accommodation!.hostContactEmail;

    if (mounted) {
      final subjectController = TextEditingController();
      final messageController = TextEditingController();

      showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Send Email'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Send email to ${accommodation!.hostName}'),
              const SizedBox(height: 8),
              Text('Email: $hostEmail'),
              const SizedBox(height: 16),
              TextField(
                controller: subjectController,
                decoration: const InputDecoration(
                  hintText: 'Subject',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: messageController,
                decoration: const InputDecoration(
                  hintText: 'Message',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final subject = subjectController.text.trim();
                final message = messageController.text.trim();

                if (subject.isEmpty || message.isEmpty) return;

                final scaffoldMessenger = ScaffoldMessenger.of(context);
                final navigator = Navigator.of(context);
                navigator.pop();

                try {
                  final Uri emailUri = Uri(
                    scheme: 'mailto',
                    path: hostEmail,
                    query:
                        'subject=${Uri.encodeComponent(subject)}&body=${Uri.encodeComponent(message)}',
                  );

                  if (await canLaunchUrl(emailUri)) {
                    await launchUrl(emailUri);
                  } else {
                    if (mounted) {
                      scaffoldMessenger.showSnackBar(
                        const SnackBar(
                          content: Text('Could not open email app'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                } catch (e) {
                  if (mounted) {
                    scaffoldMessenger.showSnackBar(
                      SnackBar(
                        content: Text('Error opening email: ${e.toString()}'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              child: const Text('Send'),
            ),
          ],
        ),
      );
    }
  }

  Future<void> _toggleFavoriteInFirebase() async {
    if (accommodation == null) return;

    try {
      final userId = AuthService.currentUserId ?? 'anonymous';
      final favoriteRef = FirebaseConfig.firestore
          .collection('users')
          .doc(userId)
          .collection('favorites')
          .doc(accommodation!.id);

      if (_isFavorite) {
        // Add to favorites
        await favoriteRef.set({
          'accommodationId': accommodation!.id,
          'addedAt': FieldValue.serverTimestamp(),
          'accommodationData': {
            'title': accommodation!.title,
            'price': accommodation!.price,
            'currency': accommodation!.currency,
            'pricePeriod': accommodation!.pricePeriod,
            'imageUrls': accommodation!.imageUrls,
            'address': accommodation!.address,
            'type': accommodation!.type,
          },
        });

        // Update favorite count
        await FirebaseConfig.firestore
            .collection('accommodations')
            .doc(accommodation!.id)
            .update({
              'favoriteCount': FieldValue.increment(1),
              'updatedAt': FieldValue.serverTimestamp(),
            });
      } else {
        // Remove from favorites
        await favoriteRef.delete();

        // Update favorite count
        await FirebaseConfig.firestore
            .collection('accommodations')
            .doc(accommodation!.id)
            .update({
              'favoriteCount': FieldValue.increment(-1),
              'updatedAt': FieldValue.serverTimestamp(),
            });
      }
    } catch (e) {
      print('Error toggling favorite: $e');
      // Revert the UI state on error
      if (mounted) {
        setState(() {
          _isFavorite = !_isFavorite;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update favorite: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _navigateToSimilarProperties() {
    if (accommodation == null) return;

    if (mounted) {
      context.go('/accommodations?type=${accommodation!.type}');
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
              leading: const Icon(Icons.report, color: Colors.red),
              title: const Text('Report this listing'),
              onTap: () {
                Navigator.pop(context);
                _showReportDialog();
              },
            ),
            ListTile(
              leading: const Icon(Icons.bookmark_add, color: Colors.blue),
              title: const Text('Save to collections'),
              onTap: () {
                Navigator.pop(context);
                _saveToCollections();
              },
            ),
            ListTile(
              leading: const Icon(Icons.location_on, color: Colors.green),
              title: const Text('View on map'),
              onTap: () {
                Navigator.pop(context);
                _viewOnMap();
              },
            ),
            ListTile(
              leading: const Icon(Icons.share, color: Colors.orange),
              title: const Text('Share listing'),
              onTap: () {
                Navigator.pop(context);
                _shareAccommodation();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConnectionStatus(ThemeData theme) => Container(
    padding: const EdgeInsets.symmetric(
      horizontal: AppSpacing.md,
      vertical: AppSpacing.sm,
    ),
    decoration: BoxDecoration(
      color: _hasError
          ? theme.colorScheme.error.withOpacity(0.1)
          : theme.colorScheme.primary.withOpacity(0.1),
      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      border: Border.all(
        color: _hasError
            ? theme.colorScheme.error.withOpacity(0.3)
            : theme.colorScheme.primary.withOpacity(0.3),
      ),
    ),
    child: Row(
      children: [
        Icon(
          _hasError ? Icons.error : Icons.cloud_done,
          size: 16,
          color: _hasError ? theme.colorScheme.error : Colors.green,
        ),
        const SizedBox(width: AppSpacing.sm),
        Text(
          _hasError
              ? 'Connection Error - Using cached data'
              : 'Live data from Firebase',
          style: theme.textTheme.bodySmall?.copyWith(
            color: _hasError ? theme.colorScheme.error : Colors.green,
            fontWeight: FontWeight.w600,
          ),
        ),
        const Spacer(),
        if (_hasError)
          TextButton(
            onPressed: () {
              if (mounted) {
                setState(() {
                  _hasError = false;
                  _errorMessage = '';
                  _isLoading = true;
                });
                _loadAccommodation();
              }
            },
            child: const Text('Retry'),
          ),
      ],
    ),
  );

  Widget _buildFloatingActionButton(ThemeData theme) =>
      FloatingActionButton.extended(
        onPressed: () {
          if (accommodation != null) {
            _handleBooking();
          }
        },
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        icon: const Icon(Icons.calendar_today),
        label: Text(
          (accommodation?.isAvailable ?? false) ? 'Book Now' : 'Not Available',
        ),
      );

  Future<List<Accommodation>> _loadSimilarAccommodations() async {
    try {
      // Load similar accommodations from Firebase based on type and price range
      final accommodationData = await FirebaseRepository.getAccommodations();

      // Convert Firebase data to Accommodation objects
      final accommodations = <Accommodation>[];
      for (final data in accommodationData) {
        try {
          final accommodationJson = _convertFirebaseDataToAccommodation(data);
          final accommodation = Accommodation.fromJson(accommodationJson);
          accommodations.add(accommodation);
        } catch (e) {
          print('Error parsing accommodation for similar properties: $e');
        }
      }

      // Filter out current accommodation and find similar ones
      final similarAccommodations = accommodations
          .where((acc) => acc.id != widget.accommodationId)
          .where((acc) => acc.type == accommodation?.type)
          .take(5)
          .toList();

      // If not enough similar accommodations by type, add others
      if (similarAccommodations.length < 3) {
        final additionalAccommodations = accommodations
            .where((acc) => acc.id != widget.accommodationId)
            .where(
              (acc) =>
                  !similarAccommodations.any((similar) => similar.id == acc.id),
            )
            .take(5 - similarAccommodations.length)
            .toList();
        similarAccommodations.addAll(additionalAccommodations);
      }

      return similarAccommodations;
    } catch (e) {
      print('Error loading similar accommodations: $e');
      return [];
    }
  }
}
