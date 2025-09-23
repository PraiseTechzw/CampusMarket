/// @Branch: Accommodation List Screen Implementation
///
/// Enhanced housing listings with modern UI, advanced search, filtering, and improved layout
/// Displays accommodation options with comprehensive filtering capabilities and smooth animations
library;

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';

import '../../../core/config/firebase_config.dart';
import '../../../core/models/accommodation.dart';
import '../../../core/repositories/firebase_repository.dart';
import '../../../core/theme/app_spacing.dart';
import '../../widgets/accommodation_card.dart';

class AccommodationListScreen extends StatefulWidget {
  const AccommodationListScreen({super.key});

  @override
  State<AccommodationListScreen> createState() =>
      _AccommodationListScreenState();
}

class _AccommodationListScreenState extends State<AccommodationListScreen>
    with TickerProviderStateMixin {
  bool _isGridView = true;
  bool _isLoading = false;
  bool _isSearchFocused = false;
  String _searchQuery = '';
  String _selectedCategory = 'all';
  String _sortBy = 'newest';
  RangeValues _priceRange = const RangeValues(0, 2000);
  final List<String> _selectedAmenities = [];
  List<Accommodation> _accommodations = [];
  List<Accommodation> _filteredAccommodations = [];

  late AnimationController _searchAnimationController;
  late AnimationController _filterAnimationController;

  StreamSubscription<QuerySnapshot>? _accommodationsSubscription;
  bool _hasError = false;
  String _errorMessage = '';

  // Toast helper methods with fallback to SnackBar
  void _showToast(String message, {bool isError = false}) {
    try {
      Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: isError ? Colors.red : Colors.green,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    } catch (e) {
      // Fallback to SnackBar if toast fails
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: isError ? Colors.red : Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  void _showSuccessToast(String message) {
    _showToast(message, isError: false);
  }

  void _showErrorToast(String message) {
    _showToast(message, isError: true);
  }

  @override
  void initState() {
    super.initState();
    _searchAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _filterAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _loadAccommodations();
    _setupRealTimeUpdates();
  }

  void _setupRealTimeUpdates() {
    try {
      _accommodationsSubscription = FirebaseConfig.firestore
          .collection('accommodations')
          .orderBy('createdAt', descending: true)
          .snapshots()
          .listen(
            (QuerySnapshot snapshot) {
              if (!mounted) return;

              print('Real-time update: ${snapshot.docs.length} accommodations');

              final accommodations = <Accommodation>[];

              for (final doc in snapshot.docs) {
                try {
                  final data = doc.data() as Map<String, dynamic>;
                  data['id'] = doc.id;

                  // Convert Firebase data to match Accommodation model
                  final accommodationJson = _convertFirebaseDataToAccommodation(
                    data,
                  );
                  final accommodation = Accommodation.fromJson(
                    accommodationJson,
                  );
                  accommodations.add(accommodation);
                } catch (e) {
                  print('Error parsing accommodation in real-time update: $e');
                }
              }

              if (mounted) {
                setState(() {
                  _accommodations = accommodations;
                  _filteredAccommodations = List<Accommodation>.from(
                    accommodations,
                  );
                  _isLoading = false;
                  _hasError = false;
                  _errorMessage = '';
                });

                // Apply current filters
                _filterAccommodations();
              }
            },
            onError: (Object error) {
              print('Real-time update error: $error');
              if (mounted) {
                setState(() {
                  _hasError = true;
                  _errorMessage =
                      'Failed to load real-time updates: ${error.toString()}';
                  _isLoading = false;
                });
              }
            },
          );
    } catch (e) {
      print('Error setting up real-time updates: $e');
      // Fallback to regular loading
      _loadAccommodations();
    }
  }

  @override
  void dispose() {
    _searchAnimationController.dispose();
    _filterAnimationController.dispose();
    _accommodationsSubscription?.cancel();
    super.dispose();
  }

  Future<void> _loadAccommodations() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _hasError = false;
      _errorMessage = '';
    });

    try {
      print('Loading accommodations from Firebase...');
      final accommodationData = await FirebaseRepository.getAccommodations();
      print(
        'Received ${accommodationData.length} accommodations from Firebase',
      );

      final accommodations = <Accommodation>[];
      int parseErrors = 0;

      for (final data in accommodationData) {
        try {
          // Convert Firebase data to match Accommodation model
          final accommodationJson = _convertFirebaseDataToAccommodation(data);
          final accommodation = Accommodation.fromJson(accommodationJson);
          accommodations.add(accommodation);
        } catch (e) {
          parseErrors++;
          print('Error parsing accommodation: $e');
          print('Data: $data');
          // Continue with other accommodations even if one fails
        }
      }

      print('Successfully parsed ${accommodations.length} accommodations');
      if (parseErrors > 0) {
        print('Failed to parse $parseErrors accommodations');
      }

      // If no accommodations found, show empty state
      if (accommodations.isEmpty) {
        print('No accommodations found in Firebase');
      }

      if (mounted) {
        setState(() {
          _accommodations = accommodations;
          _filteredAccommodations = List<Accommodation>.from(accommodations);
          _isLoading = false;
          _hasError = false;
        });

        // Apply initial filtering
        _filterAccommodations();

        // Show success message if we loaded data from Firebase
        if (accommodationData.isNotEmpty && parseErrors == 0) {
          _showSuccessToast('Loaded ${accommodations.length} accommodations');
        } else if (parseErrors > 0) {
          _showToast(
            'Loaded ${accommodations.length} accommodations (${parseErrors} failed to parse)',
            isError: false,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _accommodations = <Accommodation>[];
          _filteredAccommodations = <Accommodation>[];
          _isLoading = false;
          _hasError = true;
        });

        print('Error loading accommodations: $e');

        // Show error message to user with more details
        String errorMessage = 'Failed to load accommodations';
        if (e.toString().contains('permission')) {
          errorMessage = 'Permission denied. Please check your authentication.';
        } else if (e.toString().contains('network')) {
          errorMessage = 'Network error. Please check your connection.';
        } else if (e.toString().contains('timeout')) {
          errorMessage = 'Request timeout. Please try again.';
        } else {
          errorMessage = 'Error: ${e.toString()}';
        }

        if (mounted) {
          setState(() {
            _errorMessage = errorMessage;
          });
          _showErrorToast(errorMessage);
        }
      }
    }
  }

  Map<String, dynamic> _convertFirebaseDataToAccommodation(
    Map<String, dynamic> data,
  ) {
    // Convert Firebase field names to match Accommodation model
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

    // Ensure type is a string
    final typeString = type.toString();

    // Map common variations to standard types
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

    // Try to get from user data if available
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

    // Try to get from user data if available
    final userData = data['users'] as Map<String, dynamic>?;
    if (userData != null) {
      final profileImage =
          userData['profile_image_url'] ?? userData['profileImageUrl'];
      return profileImage?.toString();
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

    // Handle Firestore Timestamp
    if (dateValue.runtimeType.toString().contains('Timestamp')) {
      try {
        return (dateValue as dynamic).toDate() as DateTime;
      } catch (e) {
        print('Error parsing Firestore timestamp: $e');
        return DateTime.now();
      }
    }

    // Handle Map with seconds and nanoseconds (Firestore timestamp format)
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
      // Handle comma-separated strings
      return value
          .split(',')
          .map((item) => item.trim())
          .where((item) => item.isNotEmpty)
          .toList();
    }

    return <String>[];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        child: CustomScrollView(
          slivers: [
            // Enhanced App Bar
            _buildSliverAppBar(theme),

            // Search and Filter Section
            _buildSearchAndFilterSection(theme),

            // Category Chips
            _buildCategoryChips(theme),

            // Content
            if (_isLoading)
              _buildLoadingGrid()
            else if (_hasError)
              _buildErrorState(theme)
            else
              _filteredAccommodations.isEmpty
                  ? _buildEmptyState(theme)
                  : _isGridView
                  ? _buildAccommodationsGrid(theme)
                  : _buildMapView(theme),
          ],
        ),
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
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.xl,
            AppSpacing.md,
            AppSpacing.md,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Find Your Perfect Home',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      _isGridView ? Icons.map : Icons.grid_view,
                      color: theme.colorScheme.primary,
                    ),
                    onPressed: () {
                      if (mounted) {
                        setState(() {
                          _isGridView = !_isGridView;
                        });
                      }
                    },
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.filter_list,
                      color: theme.colorScheme.primary,
                    ),
                    onPressed: _showFilterBottomSheet,
                  ),
                ],
              ),
              Row(
                children: [
              Text(
                '${_filteredAccommodations.length} properties available',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
                  const SizedBox(width: AppSpacing.sm),
                  _buildConnectionStatus(theme),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
  );

  Widget _buildSearchAndFilterSection(ThemeData theme) => SliverToBoxAdapter(
    child: Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        children: [
          // Search Bar
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
              border: Border.all(
                color: _isSearchFocused
                    ? theme.colorScheme.primary
                    : theme.colorScheme.outline.withOpacity(0.2),
              ),
              boxShadow: _isSearchFocused
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
              onChanged: (value) {
                if (mounted) {
                  setState(() {
                    _searchQuery = value;
                    _filterAccommodations();
                  });
                }
              },
              onTap: () {
                if (mounted) {
                  setState(() {
                    _isSearchFocused = true;
                  });
                  _searchAnimationController.forward();
                }
              },
              onTapOutside: (event) {
                if (mounted) {
                  setState(() {
                    _isSearchFocused = false;
                  });
                  _searchAnimationController.reverse();
                }
              },
              decoration: InputDecoration(
                hintText: 'Search by location, amenities, or property type...',
                hintStyle: TextStyle(
                  color: theme.colorScheme.onSurface.withOpacity(0.5),
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: theme.colorScheme.primary,
                ),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: Icon(
                          Icons.clear,
                          color: theme.colorScheme.onSurface.withOpacity(0.5),
                        ),
                        onPressed: () {
                          if (mounted) {
                            setState(() {
                              _searchQuery = '';
                              _filterAccommodations();
                            });
                          }
                        },
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.md,
                ),
              ),
            ),
          ),

          const SizedBox(height: AppSpacing.md),

          // Quick Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildQuickFilterChip(
                  theme,
                  'Under \$500',
                  Icons.attach_money,
                  () {
                    if (mounted) {
                      setState(() {
                        _priceRange = const RangeValues(0, 500);
                        _filterAccommodations();
                      });
                    }
                  },
                ),
                const SizedBox(width: AppSpacing.sm),
                _buildQuickFilterChip(
                  theme,
                  'Pet Friendly',
                  Icons.pets,
                  () {
                    if (mounted) {
                      setState(() {
                        if (_selectedAmenities.contains('Pet Friendly')) {
                          _selectedAmenities.remove('Pet Friendly');
                        } else {
                          _selectedAmenities.add('Pet Friendly');
                        }
                        _filterAccommodations();
                      });
                    }
                  },
                  isSelected: _selectedAmenities.contains('Pet Friendly'),
                ),
                const SizedBox(width: AppSpacing.sm),
                _buildQuickFilterChip(
                  theme,
                  'Furnished',
                  Icons.chair,
                  () {
                    if (mounted) {
                      setState(() {
                        if (_selectedAmenities.contains('Furnished')) {
                          _selectedAmenities.remove('Furnished');
                        } else {
                          _selectedAmenities.add('Furnished');
                        }
                        _filterAccommodations();
                      });
                    }
                  },
                  isSelected: _selectedAmenities.contains('Furnished'),
                ),
                const SizedBox(width: AppSpacing.sm),
                _buildQuickFilterChip(
                  theme,
                  'Near Campus',
                  Icons.school,
                  () {
                    if (mounted) {
                      setState(() {
                        _selectedCategory = _selectedCategory == 'near_campus'
                            ? 'all'
                            : 'near_campus';
                        _filterAccommodations();
                      });
                    }
                  },
                  isSelected: _selectedCategory == 'near_campus',
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );

  Widget _buildQuickFilterChip(
    ThemeData theme,
    String label,
    IconData icon,
    VoidCallback onTap, {
    bool isSelected = false,
  }) => GestureDetector(
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: isSelected
            ? theme.colorScheme.primary
            : theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        border: Border.all(
          color: isSelected
              ? theme.colorScheme.primary
              : theme.colorScheme.outline.withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: isSelected
                ? theme.colorScheme.onPrimary
                : theme.colorScheme.primary,
          ),
          const SizedBox(width: AppSpacing.xs),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: isSelected
                  ? theme.colorScheme.onPrimary
                  : theme.colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    ),
  );

  Widget _buildCategoryChips(ThemeData theme) {
    final categories = [
      {'label': 'All', 'value': 'all', 'icon': Icons.home},
      {'label': 'Full Room', 'value': 'full_room', 'icon': Icons.bed},
      {'label': '2 Room', 'value': '2_room', 'icon': Icons.bedroom_parent},
      {'label': '3 Room', 'value': '3_room', 'icon': Icons.bedroom_baby},
      {'label': 'Share', 'value': 'shared_room', 'icon': Icons.people},
    ];

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: categories.map((category) {
              final isSelected = _selectedCategory == category['value'];
              return Padding(
                padding: const EdgeInsets.only(right: AppSpacing.sm),
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
                    if (mounted) {
                      setState(() {
                        _selectedCategory = category['value'] as String;
                        _filterAccommodations();
                      });
                    }
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
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildAccommodationsGrid(ThemeData theme) => SliverPadding(
    padding: const EdgeInsets.all(AppSpacing.md),
    sliver: SliverGrid(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 1,
        childAspectRatio: 1.2,
        crossAxisSpacing: AppSpacing.md,
        mainAxisSpacing: AppSpacing.md,
      ),
      delegate: SliverChildBuilderDelegate((context, index) {
        final accommodation = _filteredAccommodations[index];
        return AnimatedContainer(
          duration: Duration(milliseconds: 300 + (index * 100)),
          curve: Curves.easeOutCubic,
          child: AccommodationCard(
            accommodation: accommodation,
            onTap: () => context.go('/accommodation/${accommodation.id}'),
            onBook: () => _handleBookAccommodation(accommodation),
            onFavorite: () => _handleFavoriteAccommodation(accommodation),
          ),
        );
      }, childCount: _filteredAccommodations.length),
    ),
  );

  Widget _buildLoadingGrid() => SliverPadding(
    padding: const EdgeInsets.all(AppSpacing.md),
    sliver: SliverGrid(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 1,
        childAspectRatio: 1.2,
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

  Widget _buildErrorState(ThemeData theme) => SliverFillRemaining(
    child: Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.xl),
              decoration: BoxDecoration(
                color: theme.colorScheme.error.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline,
                size: 64,
                color: theme.colorScheme.error,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Failed to load accommodations',
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
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _hasError = false;
                      _errorMessage = '';
                      _isLoading = true;
                    });
                    _loadAccommodations();
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
                const SizedBox(width: AppSpacing.md),
                OutlinedButton.icon(
                  onPressed: () => context.go('/accommodation/create'),
                  icon: const Icon(Icons.add),
                  label: const Text('List Property'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xl,
                      vertical: AppSpacing.md,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );

  Widget _buildEmptyState(ThemeData theme) => SliverFillRemaining(
    child: Center(
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
                Icons.home_work_outlined,
                size: 64,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'No accommodations found',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Try adjusting your filters or create a new listing',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xl),
            ElevatedButton.icon(
              onPressed: () => context.go('/accommodation/create'),
              icon: const Icon(Icons.add),
              label: const Text('List Your Property'),
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

  Widget _buildMapView(ThemeData theme) => SliverFillRemaining(
    child: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.map_outlined,
            size: 64,
            color: theme.colorScheme.primary.withOpacity(0.3),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Map view coming soon!',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Switch to grid view to see available properties',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.5),
            ),
          ),
        ],
      ),
    ),
  );

  Widget _buildConnectionStatus(ThemeData theme) {
    if (_isLoading) {
      return SizedBox(
        width: 12,
        height: 12,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: theme.colorScheme.primary,
        ),
      );
    } else if (_hasError) {
      return Icon(Icons.error, size: 16, color: theme.colorScheme.error);
    } else {
      return Icon(Icons.cloud_done, size: 16, color: Colors.green);
    }
  }

  Widget _buildFloatingActionButton(ThemeData theme) =>
      FloatingActionButton.extended(
        onPressed: () => context.go('/accommodation/create'),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        icon: const Icon(Icons.add),
        label: const Text('List Property'),
      );

  Future<void> _handleRefresh() async {
    // Cancel existing subscription to avoid conflicts
    await _accommodationsSubscription?.cancel();

    // Reset state
    setState(() {
      _isLoading = true;
      _hasError = false;
      _errorMessage = '';
    });

    // Reload data
    await _loadAccommodations();

    // Restart real-time updates
    _setupRealTimeUpdates();
  }

  void _filterAccommodations() {
    if (!mounted) return;

    setState(() {
      _filteredAccommodations = _accommodations.where((accommodation) {
        // Search filter
        if (_searchQuery.isNotEmpty) {
          final searchLower = _searchQuery.toLowerCase();
          final matchesSearch =
              accommodation.title.toLowerCase().contains(searchLower) ||
              accommodation.description.toLowerCase().contains(searchLower) ||
              accommodation.address.toLowerCase().contains(searchLower) ||
              accommodation.hostName.toLowerCase().contains(searchLower) ||
              accommodation.amenities.any(
                (amenity) => amenity.toLowerCase().contains(searchLower),
              ) ||
              accommodation.type.toLowerCase().contains(searchLower);
          if (!matchesSearch) return false;
        }

        // Category filter
        if (_selectedCategory != 'all') {
          if (_selectedCategory == 'near_campus') {
            // Simple distance check (in real app, use actual distance calculation)
            if (accommodation.address.toLowerCase().contains('campus') ||
                accommodation.address.toLowerCase().contains('university') ||
                accommodation.address.toLowerCase().contains('college')) {
              // This is near campus
            } else {
              return false;
            }
          } else if (accommodation.type != _selectedCategory) {
            return false;
          }
        }

        // Price range filter
        if (accommodation.price < _priceRange.start ||
            accommodation.price > _priceRange.end) {
          return false;
        }

        // Amenities filter
        if (_selectedAmenities.isNotEmpty) {
          final hasAllAmenities = _selectedAmenities.every(
            (amenity) => accommodation.amenities.any(
              (accAmenity) =>
                  accAmenity.toLowerCase().contains(amenity.toLowerCase()),
            ),
          );
          if (!hasAllAmenities) return false;
        }

        // Availability filter
        if (!accommodation.isAvailable) {
          return false;
        }

        return true;
      }).toList();

      // Sort accommodations
      _sortAccommodations();
    });
  }

  void _sortAccommodations() {
    switch (_sortBy) {
      case 'newest':
        _filteredAccommodations.sort(
          (a, b) => b.createdAt.compareTo(a.createdAt),
        );
        break;
      case 'oldest':
        _filteredAccommodations.sort(
          (a, b) => a.createdAt.compareTo(b.createdAt),
        );
        break;
      case 'price_low':
        _filteredAccommodations.sort((a, b) => a.price.compareTo(b.price));
        break;
      case 'price_high':
        _filteredAccommodations.sort((a, b) => b.price.compareTo(a.price));
        break;
      case 'popular':
        _filteredAccommodations.sort(
          (a, b) => b.favoriteCount.compareTo(a.favoriteCount),
        );
        break;
    }
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
                    if (mounted) {
                      setState(() {
                        _selectedCategory = 'all';
                        _sortBy = 'newest';
                        _priceRange = const RangeValues(0, 2000);
                        _selectedAmenities.clear();
                        _filterAccommodations();
                      });
                    }
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
                      if (mounted) {
                        setState(() {
                          _sortBy = value;
                        });
                      }
                    },
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  // Price Range Section
                  _buildPriceRangeSection(theme),

                  const SizedBox(height: AppSpacing.xl),

                  // Property Type Section
                  _buildFilterSection(
                    theme,
                    'Room Type',
                    Icons.home,
                    [
                      {'label': 'All', 'value': 'all', 'icon': Icons.home},
                      {
                        'label': 'Full Room',
                        'value': 'full_room',
                        'icon': Icons.bed,
                      },
                      {
                        'label': '2 Room',
                        'value': '2_room',
                        'icon': Icons.bedroom_parent,
                      },
                      {
                        'label': '3 Room',
                        'value': '3_room',
                        'icon': Icons.bedroom_baby,
                      },
                      {
                        'label': 'Share',
                        'value': 'shared_room',
                        'icon': Icons.people,
                      },
                    ],
                    _selectedCategory,
                    (value) {
                      if (mounted) {
                        setState(() {
                          _selectedCategory = value;
                        });
                      }
                    },
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  // Amenities Section
                  _buildAmenitiesSection(theme),

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
                  _filterAccommodations();
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
    String selectedValue,
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
              fontWeight: FontWeight.bold,
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
            label: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  option['icon'] as IconData,
                  size: 16,
                  color: isSelected
                      ? theme.colorScheme.onPrimary
                      : theme.colorScheme.primary,
                ),
                const SizedBox(width: AppSpacing.xs),
                Text(option['label'] as String),
              ],
            ),
            selected: isSelected,
            onSelected: (selected) {
              onChanged(option['value'] as String);
            },
            backgroundColor: theme.colorScheme.surface,
            selectedColor: theme.colorScheme.primary,
            checkmarkColor: theme.colorScheme.onPrimary,
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

  Widget _buildPriceRangeSection(ThemeData theme) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          Icon(Icons.attach_money, size: 20, color: theme.colorScheme.primary),
          const SizedBox(width: AppSpacing.sm),
          Text(
            'Price Range',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      const SizedBox(height: AppSpacing.md),
      RangeSlider(
        values: _priceRange,
        min: 0,
        max: 2000,
        divisions: 20,
        labels: RangeLabels(
          '\$${_priceRange.start.round()}',
          '\$${_priceRange.end.round()}',
        ),
        onChanged: (values) {
          if (mounted) {
            setState(() {
              _priceRange = values;
            });
          }
        },
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '\$${_priceRange.start.round()}',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            '\$${_priceRange.end.round()}',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    ],
  );

  Widget _buildAmenitiesSection(ThemeData theme) {
    final amenities = [
      'WiFi',
      'Parking',
      'Pet Friendly',
      'Furnished',
      'Air Conditioning',
      'Laundry',
      'Gym',
      'Pool',
      'Balcony',
      'Garden',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.star, size: 20, color: theme.colorScheme.primary),
            const SizedBox(width: AppSpacing.sm),
            Text(
              'Amenities',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: amenities.map((amenity) {
            final isSelected = _selectedAmenities.contains(amenity);
            return FilterChip(
              label: Text(amenity),
              selected: isSelected,
              onSelected: (selected) {
                if (mounted) {
                  setState(() {
                    if (selected) {
                      _selectedAmenities.add(amenity);
                    } else {
                      _selectedAmenities.remove(amenity);
                    }
                  });
                }
              },
              backgroundColor: theme.colorScheme.surface,
              selectedColor: theme.colorScheme.primary,
              checkmarkColor: theme.colorScheme.onPrimary,
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
  }

  void _handleBookAccommodation(Accommodation accommodation) {
    if (!accommodation.isAvailable) {
      _showErrorToast('This accommodation is not available for booking');
      return;
    }

    // Show booking dialog or navigate to booking screen
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Book ${accommodation.title}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Price: ${accommodation.formattedPrice}'),
            const SizedBox(height: 8),
            Text('Location: ${accommodation.address}'),
            const SizedBox(height: 8),
            Text('Host: ${accommodation.hostName}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // TODO: Implement actual booking logic
              _showToast('Booking functionality coming soon!', isError: false);
            },
            child: const Text('Book Now'),
          ),
        ],
      ),
    );
  }

  void _handleFavoriteAccommodation(Accommodation accommodation) {
    // TODO: Implement favorite functionality with Firebase
    // This would add/remove the accommodation from user's favorites collection
    // and update the favorite count in the accommodation document

    // For now, show a placeholder message
    _showSuccessToast('Added ${accommodation.title} to favorites');
  }
}
