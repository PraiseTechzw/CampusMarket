/// @Branch: Booking List Screen Implementation
///
/// User's booking history and management
/// Displays all bookings with status and actions
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/models/booking.dart';
import '../../../core/repositories/firebase_repository.dart';
import '../../../core/providers/auth_provider.dart';

class BookingListScreen extends StatefulWidget {
  const BookingListScreen({super.key});

  @override
  State<BookingListScreen> createState() => _BookingListScreenState();
}

class _BookingListScreenState extends State<BookingListScreen>
    with TickerProviderStateMixin {
  bool _isLoading = false;
  List<Booking> _bookings = [];
  String _selectedFilter = 'all';
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadBookings();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _loadBookings() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final currentUser = authProvider.currentUser;
      
      if (currentUser == null) {
        setState(() {
          _bookings = [];
          _isLoading = false;
        });
        return;
      }

      final bookingData = await FirebaseRepository.getBookings(currentUser.id);
      final bookings = bookingData.map(Booking.fromJson).toList();

      setState(() {
        _bookings = bookings;
        _isLoading = false;
      });
      _fadeController.forward();
    } catch (e) {
      setState(() {
        _bookings = [];
        _isLoading = false;
      });
      print('Error loading bookings: $e');
    }
  }

  List<Booking> get _filteredBookings {
    if (_selectedFilter == 'all') return _bookings;
    return _bookings.where((booking) {
      switch (_selectedFilter) {
        case 'pending':
          return booking.status == BookingStatus.pending;
        case 'confirmed':
          return booking.status == BookingStatus.confirmed;
        case 'cancelled':
          return booking.status == BookingStatus.cancelled;
        case 'completed':
          return booking.status == BookingStatus.completed;
        default:
          return true;
      }
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(theme),
          _buildFilterChips(theme),
          _buildBookingsList(theme),
        ],
      ),
    );
  }

  Widget _buildAppBar(ThemeData theme) => SliverAppBar(
    expandedHeight: 120,
    floating: false,
    pinned: true,
    backgroundColor: theme.colorScheme.primary,
    foregroundColor: theme.colorScheme.onPrimary,
    flexibleSpace: FlexibleSpaceBar(
      title: Text(
        'My Bookings',
        style: theme.textTheme.headlineSmall?.copyWith(
          color: theme.colorScheme.onPrimary,
          fontWeight: FontWeight.bold,
        ),
      ),
      background: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.colorScheme.primary,
              theme.colorScheme.primary.withOpacity(0.8),
            ],
          ),
        ),
      ),
    ),
  );

  Widget _buildFilterChips(ThemeData theme) => SliverToBoxAdapter(
    child: Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildFilterChip('all', 'All', theme),
            const SizedBox(width: AppSpacing.sm),
            _buildFilterChip('pending', 'Pending', theme),
            const SizedBox(width: AppSpacing.sm),
            _buildFilterChip('confirmed', 'Confirmed', theme),
            const SizedBox(width: AppSpacing.sm),
            _buildFilterChip('cancelled', 'Cancelled', theme),
            const SizedBox(width: AppSpacing.sm),
            _buildFilterChip('completed', 'Completed', theme),
          ],
        ),
      ),
    ),
  );

  Widget _buildFilterChip(String value, String label, ThemeData theme) =>
      FilterChip(
        label: Text(label),
        selected: _selectedFilter == value,
        onSelected: (selected) {
          setState(() {
            _selectedFilter = value;
          });
        },
        selectedColor: theme.colorScheme.primary.withOpacity(0.2),
        checkmarkColor: theme.colorScheme.primary,
      );

  Widget _buildBookingsList(ThemeData theme) {
    if (_isLoading) {
      return const SliverToBoxAdapter(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(AppSpacing.xl),
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    if (_filteredBookings.isEmpty) {
      return SliverToBoxAdapter(
        child: _buildEmptyState(theme),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.all(AppSpacing.md),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final booking = _filteredBookings[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: _buildBookingCard(booking, theme),
            );
          },
          childCount: _filteredBookings.length,
        ),
      ),
    );
  }

  Widget _buildBookingCard(Booking booking, ThemeData theme) =>
      AnimatedBuilder(
        animation: _fadeAnimation,
        builder: (context, child) {
          return FadeTransition(
            opacity: _fadeAnimation,
            child: Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.shadow.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => context.go('/bookings/${booking.id}'),
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header with status
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.sm,
                                vertical: AppSpacing.xs,
                              ),
                              decoration: BoxDecoration(
                                color: _getStatusColor(booking.status).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                booking.statusDisplayName,
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: _getStatusColor(booking.status),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            Text(
                              booking.formattedTotalAmount,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        
                        // Item info
                        Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                booking.itemImage,
                                width: 60,
                                height: 60,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    Container(
                                  width: 60,
                                  height: 60,
                                  color: theme.colorScheme.surface,
                                  child: Icon(
                                    Icons.image_not_supported,
                                    color: theme.colorScheme.outline,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    booking.itemTitle,
                                    style: theme.textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: AppSpacing.xs),
                                  Text(
                                    booking.itemTypeDisplayName,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.colorScheme.outline,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        
                        // Dates and details
                        Row(
                          children: [
                            if (booking.checkIn != null) ...[
                              Icon(
                                Icons.calendar_today,
                                size: 16,
                                color: theme.colorScheme.outline,
                              ),
                              const SizedBox(width: AppSpacing.xs),
                              Text(
                                booking.formattedCheckIn,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.outline,
                                ),
                              ),
                            ],
                            if (booking.checkOut != null) ...[
                              const SizedBox(width: AppSpacing.md),
                              Icon(
                                Icons.calendar_today,
                                size: 16,
                                color: theme.colorScheme.outline,
                              ),
                              const SizedBox(width: AppSpacing.xs),
                              Text(
                                booking.formattedCheckOut,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.outline,
                                ),
                              ),
                            ],
                          ],
                        ),
                        if (booking.guests != null) ...[
                          const SizedBox(height: AppSpacing.xs),
                          Row(
                            children: [
                              Icon(
                                Icons.people,
                                size: 16,
                                color: theme.colorScheme.outline,
                              ),
                              const SizedBox(width: AppSpacing.xs),
                              Text(
                                '${booking.guests} guest${booking.guests != 1 ? 's' : ''}',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.outline,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      );

  Color _getStatusColor(BookingStatus status) {
    switch (status) {
      case BookingStatus.pending:
        return Colors.orange;
      case BookingStatus.confirmed:
        return Colors.green;
      case BookingStatus.cancelled:
        return Colors.red;
      case BookingStatus.completed:
        return Colors.blue;
      case BookingStatus.refunded:
        return Colors.purple;
    }
  }

  Widget _buildEmptyState(ThemeData theme) => Center(
    child: Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.book_online,
            size: 64,
            color: theme.colorScheme.outline,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'No bookings found',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: theme.colorScheme.outline,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Your bookings will appear here once you make a reservation',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.outline,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.lg),
          ElevatedButton.icon(
            onPressed: () => context.go('/accommodations'),
            icon: const Icon(Icons.search),
            label: const Text('Browse Accommodations'),
          ),
        ],
      ),
    ),
  );
}



