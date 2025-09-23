/// @Branch: Events List Screen Implementation
///
/// Events listing with live badges, date/time, and RSVP functionality
/// Displays campus events with filtering and search
library;

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/models/event.dart';
import '../../../core/config/firebase_config.dart';
import '../../widgets/event_card.dart';

class EventsListScreen extends StatefulWidget {
  const EventsListScreen({super.key});

  @override
  State<EventsListScreen> createState() => _EventsListScreenState();
}

class _EventsListScreenState extends State<EventsListScreen>
    with TickerProviderStateMixin {
  bool _isLoading = false;
  bool _hasError = false;
  List<Event> _events = [];
  List<Event> _filteredEvents = [];
  String _selectedFilter = 'all';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  late AnimationController _searchAnimationController;
  late AnimationController _filterAnimationController;
  late Animation<double> _searchAnimation;
  late Animation<double> _filterAnimation;
  StreamSubscription<QuerySnapshot>? _eventsSubscription;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _setupRealTimeUpdates();
  }

  void _initializeAnimations() {
    _searchAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _filterAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _searchAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _searchAnimationController,
        curve: Curves.easeInOut,
      ),
    );
    _filterAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _filterAnimationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchAnimationController.dispose();
    _filterAnimationController.dispose();
    _eventsSubscription?.cancel();
    super.dispose();
  }

  void _setupRealTimeUpdates() {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      _eventsSubscription = FirebaseConfig.firestore
          .collection('events')
          .orderBy('createdAt', descending: true)
          .snapshots()
          .listen(
            (QuerySnapshot snapshot) {
              if (!mounted) return;

              try {
                final events = <Event>[];
                for (var doc in snapshot.docs) {
                  try {
                    final data = doc.data() as Map<String, dynamic>;
                    data['id'] = doc.id;
                    final event = Event.fromJson(data);
                    events.add(event);
                  } catch (e) {
                    print('Error parsing event ${doc.id}: $e');
                  }
                }

                if (mounted) {
      setState(() {
        _events = events;
                    _isLoading = false;
                    _hasError = false;
                  });
                  _filterEvents();
                }
              } catch (e) {
                print('Error processing events snapshot: $e');
                if (mounted) {
                  setState(() {
                    _hasError = true;
                    _isLoading = false;
                  });
                }
              }
            },
            onError: (Object error) {
              print('Real-time events update error: $error');
              if (mounted) {
                setState(() {
                  _hasError = true;
        _isLoading = false;
      });
              }
            },
          );
    } catch (e) {
      print('Error setting up real-time updates: $e');
      if (mounted) {
      setState(() {
          _hasError = true;
        _isLoading = false;
      });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: CustomScrollView(
        slivers: [
          // Enhanced App Bar with search
          _buildEnhancedAppBar(theme),

          // Search Bar
          _buildSearchBar(theme),

          // Filter chips with animation
          _buildFilterChips(theme),

          // Connection status
          if (_hasError) _buildConnectionStatus(theme),

          // Events list
          _buildEventsList(theme),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go('/events/create'),
        icon: const Icon(Icons.add),
        label: const Text('Create Event'),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
      ),
    );
  }

  Widget _buildEnhancedAppBar(ThemeData theme) => SliverAppBar(
      expandedHeight: 120,
      floating: false,
      pinned: true,
      backgroundColor: theme.colorScheme.primary,
      foregroundColor: theme.colorScheme.onPrimary,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          'Events',
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
      actions: [
        IconButton(
          icon: const Icon(Icons.search),
          onPressed: () {
            _searchAnimationController.forward();
          },
        ),
        IconButton(
          icon: const Icon(Icons.filter_list),
          onPressed: _showFilterBottomSheet,
        ),
      ],
    );

  Widget _buildSearchBar(ThemeData theme) => SliverToBoxAdapter(
      child: AnimatedBuilder(
        animation: _searchAnimation,
        builder: (context, child) {
          return SizeTransition(
            sizeFactor: _searchAnimation,
            child: Container(
              margin: const EdgeInsets.all(AppSpacing.md),
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
              child: TextField(
                controller: _searchController,
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                  _filterEvents();
                },
                decoration: InputDecoration(
                  hintText: 'Search events...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {
                              _searchQuery = '';
                            });
                            _filterEvents();
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );

  Widget _buildFilterChips(ThemeData theme) => SliverToBoxAdapter(
      child: AnimatedBuilder(
        animation: _filterAnimation,
        builder: (context, child) {
          return FadeTransition(
            opacity: _filterAnimation,
            child: Container(
              height: 50,
              margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _buildFilterChip('All', 'all', theme),
                  const SizedBox(width: AppSpacing.sm),
                  _buildFilterChip('Live', 'live', theme),
                  const SizedBox(width: AppSpacing.sm),
                  _buildFilterChip('Upcoming', 'upcoming', theme),
                  const SizedBox(width: AppSpacing.sm),
                  _buildFilterChip('Free', 'free', theme),
                  const SizedBox(width: AppSpacing.sm),
                  _buildFilterChip('Academic', 'academic', theme),
                  const SizedBox(width: AppSpacing.sm),
                  _buildFilterChip('Social', 'social', theme),
                  const SizedBox(width: AppSpacing.sm),
                  _buildFilterChip('Sports', 'sports', theme),
                ],
              ),
            ),
          );
        },
      ),
    );

  Widget _buildEventsList(ThemeData theme) {
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

    if (_filteredEvents.isEmpty) {
      return SliverToBoxAdapter(child: _buildEmptyState(theme));
    }

    return SliverPadding(
      padding: const EdgeInsets.all(AppSpacing.md),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
          final event = _filteredEvents[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: EventCard(
              event: event,
              onTap: () => context.go('/events/${event.id}'),
              onRSVP: () => _handleRSVP(event),
              onShare: () => _handleShare(event),
            ),
          );
        }, childCount: _filteredEvents.length),
      ),
    );
  }

  Widget _buildFilterChip(String label, String value, ThemeData theme) {
    final isSelected = _selectedFilter == value;

    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedFilter = value;
        });
        _filterEvents();
      },
      selectedColor: theme.colorScheme.primary.withOpacity(0.2),
      checkmarkColor: theme.colorScheme.primary,
      backgroundColor: theme.colorScheme.surface,
      side: BorderSide(
        color: isSelected
            ? theme.colorScheme.primary
            : theme.colorScheme.outline.withOpacity(0.3),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) => Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_busy, size: 64, color: theme.colorScheme.outline),
            const SizedBox(height: AppSpacing.md),
            Text(
              'No events found',
              style: theme.textTheme.headlineSmall?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Check back later for new events',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            ElevatedButton.icon(
            onPressed: () => context.go('/events/create'),
              icon: const Icon(Icons.add),
              label: const Text('Create Event'),
            ),
          ],
        ),
      ),
    );

  void _handleRSVP(Event event) {
    // TODO: Implement RSVP functionality
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('RSVP to ${event.title}')));
  }

  void _handleShare(Event event) {
    // TODO: Implement share functionality
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Share ${event.title}')));
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) => _buildFilterBottomSheet(),
    );
  }

  Widget _buildFilterBottomSheet() {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Filter Events',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: AppSpacing.lg),

          // Event type
          Text(
            'Event Type',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: AppSpacing.sm),

          Wrap(
            spacing: AppSpacing.sm,
            children: [
              FilterChip(
                label: const Text('Academic'),
                onSelected: (selected) {},
              ),
              FilterChip(
                label: const Text('Social'),
                onSelected: (selected) {},
              ),
              FilterChip(
                label: const Text('Sports'),
                onSelected: (selected) {},
              ),
              FilterChip(
                label: const Text('Cultural'),
                onSelected: (selected) {},
              ),
              FilterChip(
                label: const Text('Professional'),
                onSelected: (selected) {},
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.lg),

          // Date range
          Text(
            'Date Range',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: AppSpacing.sm),

          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    // TODO: Implement date picker
                  },
                  icon: const Icon(Icons.calendar_today),
                  label: const Text('Start Date'),
                ),
              ),

              const SizedBox(width: AppSpacing.sm),

              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    // TODO: Implement date picker
                  },
                  icon: const Icon(Icons.calendar_today),
                  label: const Text('End Date'),
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.xl),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Apply Filters'),
            ),
          ),
        ],
      ),
    );
  }

  void _filterEvents() {
    if (!mounted) return;

    setState(() {
      _filteredEvents = List.from(_events);

      // Apply search filter
      if (_searchQuery.isNotEmpty) {
        _filteredEvents = _filteredEvents
            .where(
              (event) =>
                  event.title.toLowerCase().contains(
                    _searchQuery.toLowerCase(),
                  ) ||
                  event.description.toLowerCase().contains(
                    _searchQuery.toLowerCase(),
                  ) ||
                  event.location.toLowerCase().contains(
                    _searchQuery.toLowerCase(),
                  ),
            )
            .toList();
      }

      // Apply category filter
      switch (_selectedFilter) {
        case 'live':
          _filteredEvents = _filteredEvents
              .where(
                (event) =>
                    event.startDate.isBefore(DateTime.now()) &&
                    event.endDate.isAfter(DateTime.now()),
              )
              .toList();
          break;
        case 'upcoming':
          _filteredEvents = _filteredEvents
              .where((event) => event.startDate.isAfter(DateTime.now()))
              .toList();
          break;
        case 'free':
          _filteredEvents = _filteredEvents
              .where((event) => event.isFree)
              .toList();
          break;
        case 'academic':
          _filteredEvents = _filteredEvents
              .where((event) => event.type == EventType.academic)
              .toList();
          break;
        case 'social':
          _filteredEvents = _filteredEvents
              .where((event) => event.type == EventType.social)
              .toList();
          break;
        case 'sports':
          _filteredEvents = _filteredEvents
              .where((event) => event.type == EventType.sports)
              .toList();
          break;
        default:
          // 'all' - no additional filtering
          break;
      }
    });
  }

  Widget _buildConnectionStatus(ThemeData theme) => SliverToBoxAdapter(
    child: Container(
      margin: const EdgeInsets.all(AppSpacing.md),
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
                    _isLoading = true;
                  });
                  _setupRealTimeUpdates();
                }
              },
              child: const Text('Retry'),
            ),
        ],
      ),
    ),
  );
}