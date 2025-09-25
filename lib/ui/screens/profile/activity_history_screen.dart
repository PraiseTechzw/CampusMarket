/// @Branch: Activity History Screen Implementation
///
/// User's activity history with timeline view
/// Includes marketplace activity, bookings, events, and account changes
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/providers/auth_provider.dart';

class ActivityHistoryScreen extends StatefulWidget {
  const ActivityHistoryScreen({super.key});

  @override
  State<ActivityHistoryScreen> createState() => _ActivityHistoryScreenState();
}

class _ActivityHistoryScreenState extends State<ActivityHistoryScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  bool _isLoading = true;
  List<Map<String, dynamic>> _activities = [];
  String _selectedFilter = 'all';
  String _selectedSort = 'recent';

  final List<String> _filters = [
    'all',
    'marketplace',
    'accommodation',
    'events',
    'account',
  ];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadActivities();
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
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
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

  Future<void> _loadActivities() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = context.read<AuthProvider>();
      final user = authProvider.currentUser;

      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please sign in to view your activity')),
        );
        return;
      }

      // TODO: Implement getActivitiesByUserId in FirebaseRepository
      // For now, using mock data
      await Future<void>.delayed(const Duration(seconds: 1));

      setState(() {
        _activities = [
          {
            'id': '1',
            'type': 'marketplace',
            'action': 'created_listing',
            'title': 'Created listing: MacBook Pro 13"',
            'description': 'You created a new marketplace listing',
            'timestamp': '2024-01-15T10:00:00Z',
            'status': 'success',
            'icon': Icons.store,
            'color': Colors.blue,
          },
          {
            'id': '2',
            'type': 'accommodation',
            'action': 'booked_room',
            'title': 'Booked accommodation: Modern Apartment',
            'description': 'You booked a room for 3 months',
            'timestamp': '2024-01-20T14:30:00Z',
            'status': 'success',
            'icon': Icons.hotel,
            'color': Colors.green,
          },
          {
            'id': '3',
            'type': 'events',
            'action': 'registered_event',
            'title': 'Registered for: Tech Conference 2024',
            'description': 'You registered for an upcoming event',
            'timestamp': '2024-01-25T09:15:00Z',
            'status': 'success',
            'icon': Icons.event,
            'color': Colors.orange,
          },
          {
            'id': '4',
            'type': 'marketplace',
            'action': 'sold_item',
            'title': 'Sold item: iPhone 12 Pro',
            'description': 'Your marketplace item was sold',
            'timestamp': '2024-01-28T16:45:00Z',
            'status': 'success',
            'icon': Icons.check_circle,
            'color': Colors.green,
          },
          {
            'id': '5',
            'type': 'account',
            'action': 'updated_profile',
            'title': 'Updated profile information',
            'description': 'You updated your profile details',
            'timestamp': '2024-02-01T11:20:00Z',
            'status': 'success',
            'icon': Icons.person,
            'color': Colors.purple,
          },
          {
            'id': '6',
            'type': 'events',
            'action': 'cancelled_ticket',
            'title': 'Cancelled ticket: Music Festival',
            'description': 'You cancelled your event ticket',
            'timestamp': '2024-02-05T13:10:00Z',
            'status': 'warning',
            'icon': Icons.cancel,
            'color': Colors.red,
          },
          {
            'id': '7',
            'type': 'marketplace',
            'action': 'received_review',
            'title': 'Received review: 5 stars',
            'description': 'You received a positive review',
            'timestamp': '2024-02-08T15:30:00Z',
            'status': 'success',
            'icon': Icons.star,
            'color': Colors.amber,
          },
          {
            'id': '8',
            'type': 'accommodation',
            'action': 'extended_booking',
            'title': 'Extended booking: Modern Apartment',
            'description': 'You extended your accommodation booking',
            'timestamp': '2024-02-10T10:15:00Z',
            'status': 'success',
            'icon': Icons.schedule,
            'color': Colors.blue,
          },
        ];
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading activities: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  List<Map<String, dynamic>> get _filteredAndSortedActivities {
    List<Map<String, dynamic>> filtered = _activities;

    // Filter by type
    if (_selectedFilter != 'all') {
      filtered = _activities
          .where((activity) => (activity['type'] as String) == _selectedFilter)
          .toList();
    }

    // Sort activities
    switch (_selectedSort) {
      case 'oldest':
        filtered.sort(
          (a, b) =>
              (a['timestamp'] as String).compareTo(b['timestamp'] as String),
        );
        break;
      case 'type':
        filtered.sort(
          (a, b) => (a['type'] as String).compareTo(b['type'] as String),
        );
        break;
      case 'recent':
      default:
        filtered.sort(
          (a, b) =>
              (b['timestamp'] as String).compareTo(a['timestamp'] as String),
        );
        break;
    }

    return filtered;
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
      'Activity History',
      style: theme.textTheme.headlineSmall?.copyWith(
        fontWeight: FontWeight.bold,
      ),
    ),
    actions: [
      PopupMenuButton<String>(
        onSelected: (value) {
          setState(() {
            _selectedSort = value;
          });
        },
        itemBuilder: (context) => [
          const PopupMenuItem(value: 'recent', child: Text('Most Recent')),
          const PopupMenuItem(value: 'oldest', child: Text('Oldest First')),
          const PopupMenuItem(value: 'type', child: Text('By Type')),
        ],
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.sm),
          child: Icon(Icons.sort, color: theme.colorScheme.primary),
        ),
      ),
      IconButton(icon: const Icon(Icons.refresh), onPressed: _loadActivities),
    ],
  );

  Widget _buildBody(ThemeData theme) {
    if (_isLoading) {
      return _buildLoadingState(theme);
    }

    if (_activities.isEmpty) {
      return _buildEmptyState(theme);
    }

    return Column(
      children: [
        _buildFilterChips(theme),
        Expanded(child: _buildActivitiesList(theme)),
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
          'Loading your activity...',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.outline,
          ),
        ),
      ],
    ),
  );

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
              Icons.history,
              size: 64,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(
            'No Activity Yet',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Your activity history will appear here as you use the app.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.outline,
            ),
          ),
        ],
      ),
    ),
  );

  Widget _buildFilterChips(ThemeData theme) => Container(
    height: 60,
    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
    child: ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: _filters.length,
      itemBuilder: (context, index) {
        final filter = _filters[index];
        final isSelected = _selectedFilter == filter;

        return Padding(
          padding: const EdgeInsets.only(right: AppSpacing.sm),
          child: FilterChip(
            label: Text(_getFilterLabel(filter)),
            selected: isSelected,
            onSelected: (selected) {
              setState(() {
                _selectedFilter = filter;
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
  );

  String _getFilterLabel(String filter) {
    switch (filter) {
      case 'marketplace':
        return 'Marketplace';
      case 'accommodation':
        return 'Housing';
      case 'events':
        return 'Events';
      case 'account':
        return 'Account';
      case 'all':
      default:
        return 'All';
    }
  }

  Widget _buildActivitiesList(ThemeData theme) {
    final filteredActivities = _filteredAndSortedActivities;

    if (filteredActivities.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.filter_list, size: 64, color: theme.colorScheme.outline),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'No activities found',
              style: theme.textTheme.titleLarge?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Try selecting a different filter',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
          ],
        ),
      );
    }

    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) => FadeTransition(
        opacity: _fadeAnimation,
        child: ListView.builder(
          padding: const EdgeInsets.all(AppSpacing.lg),
          itemCount: filteredActivities.length,
          itemBuilder: (context, index) {
            return AnimatedBuilder(
              animation: _slideAnimation,
              builder: (context, child) {
                return SlideTransition(
                  position: _slideAnimation,
                  child: _buildActivityCard(
                    theme,
                    filteredActivities[index],
                    index,
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildActivityCard(
    ThemeData theme,
    Map<String, dynamic> activity,
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
        _buildActivityHeader(theme, activity),
        _buildActivityContent(theme, activity),
      ],
    ),
  );

  Widget _buildActivityHeader(ThemeData theme, Map<String, dynamic> activity) =>
      Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: (activity['color'] as Color).withOpacity(0.1),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: activity['color'] as Color,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                activity['icon'] as IconData,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    activity['title'] as String,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    activity['description'] as String,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: _getStatusColor(theme, activity['status'] as String),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _getStatusLabel(activity['status'] as String).toUpperCase(),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      );

  Widget _buildActivityContent(
    ThemeData theme,
    Map<String, dynamic> activity,
  ) => Padding(
    padding: const EdgeInsets.all(AppSpacing.lg),
    child: Row(
      children: [
        Icon(Icons.access_time, size: 16, color: theme.colorScheme.outline),
        const SizedBox(width: AppSpacing.sm),
        Text(
          _formatTimestamp(activity['timestamp'] as String),
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.outline,
          ),
        ),
        const Spacer(),
        Text(
          _getTypeLabel(activity['type'] as String),
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.outline,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    ),
  );

  Color _getStatusColor(ThemeData theme, String status) {
    switch (status) {
      case 'success':
        return Colors.green;
      case 'warning':
        return Colors.orange;
      case 'error':
        return Colors.red;
      default:
        return theme.colorScheme.outline;
    }
  }

  String _getStatusLabel(String status) {
    switch (status) {
      case 'success':
        return 'Success';
      case 'warning':
        return 'Warning';
      case 'error':
        return 'Error';
      default:
        return status;
    }
  }

  String _getTypeLabel(String type) {
    switch (type) {
      case 'marketplace':
        return 'Marketplace';
      case 'accommodation':
        return 'Housing';
      case 'events':
        return 'Events';
      case 'account':
        return 'Account';
      default:
        return type;
    }
  }

  String _formatTimestamp(String timestamp) {
    try {
      final date = DateTime.parse(timestamp);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays == 0) {
        return 'Today at ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
      } else if (difference.inDays == 1) {
        return 'Yesterday at ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
      } else if (difference.inDays < 7) {
        return '${difference.inDays} days ago';
      } else {
        return '${date.day}/${date.month}/${date.year}';
      }
    } catch (e) {
      return timestamp;
    }
  }
}
