/// @Branch: Event Tickets Screen Implementation
///
/// User's event tickets and RSVPs management
/// Includes ticket details, QR codes, and event information
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/providers/auth_provider.dart';

class EventTicketsScreen extends StatefulWidget {
  const EventTicketsScreen({super.key});

  @override
  State<EventTicketsScreen> createState() => _EventTicketsScreenState();
}

class _EventTicketsScreenState extends State<EventTicketsScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  bool _isLoading = true;
  List<Map<String, dynamic>> _tickets = [];
  String _selectedFilter = 'all';
  String _selectedSort = 'upcoming';

  final List<String> _filters = ['all', 'upcoming', 'past', 'cancelled'];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadTickets();
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

  Future<void> _loadTickets() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = context.read<AuthProvider>();
      final user = authProvider.currentUser;

      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please sign in to view your tickets')),
        );
        return;
      }

      // TODO: Implement getTicketsByUserId in FirebaseRepository
      // For now, using mock data
      await Future<void>.delayed(const Duration(seconds: 1));

      setState(() {
        _tickets = [
          {
            'id': '1',
            'eventId': 'event_1',
            'eventTitle': 'Tech Conference 2024',
            'eventDate': '2024-03-15T09:00:00Z',
            'eventLocation': 'Harare International Conference Centre',
            'ticketType': 'General Admission',
            'price': 0.0,
            'status': 'confirmed',
            'qrCode': 'TECH2024-001',
            'purchaseDate': '2024-01-15T10:00:00Z',
            'attendeeName': 'John Doe',
            'attendeeEmail': 'john@example.com',
            'eventImage':
                'https://images.unsplash.com/photo-1540575467063-178a50c2df87?w=400',
          },
          {
            'id': '2',
            'eventId': 'event_2',
            'eventTitle': 'Campus Career Fair',
            'eventDate': '2024-02-20T14:00:00Z',
            'eventLocation': 'University Main Hall',
            'ticketType': 'Student Pass',
            'price': 5.0,
            'status': 'confirmed',
            'qrCode': 'CAREER2024-002',
            'purchaseDate': '2024-01-20T15:30:00Z',
            'attendeeName': 'John Doe',
            'attendeeEmail': 'john@example.com',
            'eventImage':
                'https://images.unsplash.com/photo-1511578314322-379afb476865?w=400',
          },
          {
            'id': '3',
            'eventId': 'event_3',
            'eventTitle': 'Music Festival 2024',
            'eventDate': '2024-01-10T18:00:00Z',
            'eventLocation': 'National Sports Stadium',
            'ticketType': 'VIP Pass',
            'price': 50.0,
            'status': 'past',
            'qrCode': 'MUSIC2024-003',
            'purchaseDate': '2023-12-15T12:00:00Z',
            'attendeeName': 'John Doe',
            'attendeeEmail': 'john@example.com',
            'eventImage':
                'https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=400',
          },
        ];
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading tickets: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _cancelTicket(String ticketId) async {
    try {
      // TODO: Implement cancelTicket in FirebaseRepository
      await Future<void>.delayed(const Duration(seconds: 1));

      setState(() {
        final ticketIndex = _tickets.indexWhere((t) => t['id'] == ticketId);
        if (ticketIndex != -1) {
          _tickets[ticketIndex]['status'] = 'cancelled';
        }
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ticket cancelled successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error cancelling ticket: $e')));
      }
    }
  }

  List<Map<String, dynamic>> get _filteredAndSortedTickets {
    List<Map<String, dynamic>> filtered = _tickets;

    // Filter by status
    if (_selectedFilter != 'all') {
      filtered = _tickets
          .where((ticket) => (ticket['status'] as String) == _selectedFilter)
          .toList();
    }

    // Sort tickets
    switch (_selectedSort) {
      case 'upcoming':
        filtered.sort(
          (a, b) =>
              (a['eventDate'] as String).compareTo(b['eventDate'] as String),
        );
        break;
      case 'recent':
        filtered.sort(
          (a, b) => (b['purchaseDate'] as String).compareTo(
            a['purchaseDate'] as String,
          ),
        );
        break;
      case 'price':
        filtered.sort(
          (a, b) => (b['price'] as num).compareTo(a['price'] as num),
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
      'Event Tickets',
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
          const PopupMenuItem(value: 'upcoming', child: Text('Upcoming First')),
          const PopupMenuItem(value: 'recent', child: Text('Most Recent')),
          const PopupMenuItem(value: 'price', child: Text('Price High-Low')),
        ],
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.sm),
          child: Icon(Icons.sort, color: theme.colorScheme.primary),
        ),
      ),
      IconButton(icon: const Icon(Icons.refresh), onPressed: _loadTickets),
    ],
  );

  Widget _buildBody(ThemeData theme) {
    if (_isLoading) {
      return _buildLoadingState(theme);
    }

    if (_tickets.isEmpty) {
      return _buildEmptyState(theme);
    }

    return Column(
      children: [
        _buildFilterChips(theme),
        Expanded(child: _buildTicketsList(theme)),
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
          'Loading your tickets...',
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
              Icons.event_available,
              size: 64,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(
            'No Event Tickets',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'You haven\'t purchased any event tickets yet. Explore upcoming events and get your tickets!',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.outline,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          ElevatedButton.icon(
            onPressed: () => context.go('/events'),
            icon: const Icon(Icons.event),
            label: const Text('Browse Events'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.xl,
                vertical: AppSpacing.md,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
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
      case 'upcoming':
        return 'Upcoming';
      case 'past':
        return 'Past';
      case 'cancelled':
        return 'Cancelled';
      case 'all':
      default:
        return 'All';
    }
  }

  Widget _buildTicketsList(ThemeData theme) {
    final filteredTickets = _filteredAndSortedTickets;

    if (filteredTickets.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.filter_list, size: 64, color: theme.colorScheme.outline),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'No tickets found',
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
          itemCount: filteredTickets.length,
          itemBuilder: (context, index) {
            return AnimatedBuilder(
              animation: _slideAnimation,
              builder: (context, child) {
                return SlideTransition(
                  position: _slideAnimation,
                  child: _buildTicketCard(theme, filteredTickets[index], index),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildTicketCard(
    ThemeData theme,
    Map<String, dynamic> ticket,
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
        _buildTicketHeader(theme, ticket),
        _buildTicketContent(theme, ticket),
        _buildTicketActions(theme, ticket),
      ],
    ),
  );

  Widget _buildTicketHeader(ThemeData theme, Map<String, dynamic> ticket) =>
      Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: _getStatusColor(
            theme,
            ticket['status'] as String,
          ).withOpacity(0.1),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: _getStatusColor(theme, ticket['status'] as String),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                _getStatusLabel(ticket['status'] as String).toUpperCase(),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const Spacer(),
            Text(
              _formatDate(ticket['eventDate'] as String),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
          ],
        ),
      );

  Widget _buildTicketContent(ThemeData theme, Map<String, dynamic> ticket) =>
      Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          children: [
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    ticket['eventImage'] as String,
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 80,
                        height: 80,
                        color: theme.colorScheme.surface,
                        child: Icon(
                          Icons.event,
                          color: theme.colorScheme.outline,
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ticket['eventTitle'] as String,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        ticket['eventLocation'] as String,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.outline,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 16,
                            color: theme.colorScheme.outline,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _formatEventTime(ticket['eventDate'] as String),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.outline,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            _buildTicketDetails(theme, ticket),
          ],
        ),
      );

  Widget _buildTicketDetails(ThemeData theme, Map<String, dynamic> ticket) =>
      Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: theme.colorScheme.outline.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Ticket Type:',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                ),
                Text(
                  ticket['ticketType'] as String,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Price:',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                ),
                Text(
                  (ticket['price'] as num) > 0
                      ? '\$${ticket['price'] as num}'
                      : 'FREE',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: (ticket['price'] as num) > 0
                        ? theme.colorScheme.primary
                        : Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'QR Code:',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                ),
                Text(
                  ticket['qrCode'] as String,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
          ],
        ),
      );

  Widget _buildTicketActions(ThemeData theme, Map<String, dynamic> ticket) =>
      Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _viewEventDetails(ticket),
                icon: const Icon(Icons.visibility),
                label: const Text('View Event'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            if (ticket['status'] == 'confirmed')
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _showCancelDialog(theme, ticket),
                  icon: const Icon(Icons.cancel),
                  label: const Text('Cancel'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.error,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.md,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
          ],
        ),
      );

  void _viewEventDetails(Map<String, dynamic> ticket) {
    context.go('/events/${ticket['eventId']}');
  }

  void _showCancelDialog(ThemeData theme, Map<String, dynamic> ticket) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Ticket'),
        content: Text(
          'Are you sure you want to cancel your ticket for "${ticket['eventTitle'] as String}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Keep Ticket'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _cancelTicket(ticket['id'] as String);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Cancel Ticket'),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(ThemeData theme, String status) {
    switch (status) {
      case 'confirmed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      case 'past':
        return Colors.grey;
      default:
        return theme.colorScheme.outline;
    }
  }

  String _getStatusLabel(String status) {
    switch (status) {
      case 'confirmed':
        return 'Confirmed';
      case 'cancelled':
        return 'Cancelled';
      case 'past':
        return 'Past Event';
      default:
        return status;
    }
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateString;
    }
  }

  String _formatEventTime(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final hour = date.hour.toString().padLeft(2, '0');
      final minute = date.minute.toString().padLeft(2, '0');
      return '$hour:$minute';
    } catch (e) {
      return dateString;
    }
  }
}
