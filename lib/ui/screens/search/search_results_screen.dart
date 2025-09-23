/// @Branch: Search Results Screen Implementation
///
/// Unified search with type tabs for Items, Rooms, and Events
/// Displays search results across all content types
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/models/accommodation.dart';
import '../../../core/models/event.dart';
import '../../../core/models/marketplace_item.dart';
import '../../../core/repositories/firebase_repository.dart';
import '../../../core/theme/app_spacing.dart';
import '../../widgets/accommodation_card.dart';
import '../../widgets/event_card.dart';
import '../../widgets/marketplace_item_card.dart';

class SearchResultsScreen extends StatefulWidget {

  const SearchResultsScreen({super.key, required this.query});
  final String query;

  @override
  State<SearchResultsScreen> createState() => _SearchResultsScreenState();
}

class _SearchResultsScreenState extends State<SearchResultsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;

  List<MarketplaceItem> _items = [];
  List<Accommodation> _accommodations = [];
  List<Event> _events = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      setState(() {
        // Tab index changed
      });
    });
    _performSearch();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _performSearch() async {
    setState(() {
      _isLoading = true;
    });

    // Simulate search delay
    await Future<void>.delayed(const Duration(seconds: 1));

    try {
      final productData = await FirebaseRepository.getProducts();
      final accommodationData = await FirebaseRepository.getAccommodations();
      final eventData = await FirebaseRepository.getEvents();

      setState(() {
        _items = productData
            .map(MarketplaceItem.fromJson)
            .toList();
        _accommodations = accommodationData
            .map(Accommodation.fromJson)
            .toList();
        _events = eventData.map(Event.fromJson).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _items = <MarketplaceItem>[];
        _accommodations = <Accommodation>[];
        _events = <Event>[];
        _isLoading = false;
      });
      print('Error loading search results: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Search: ${widget.query}'),
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Items'),
            Tab(text: 'Rooms'),
            Tab(text: 'Events'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildItemsTab(),
                _buildAccommodationsTab(),
                _buildEventsTab(),
              ],
            ),
    );
  }

  Widget _buildItemsTab() {
    if (_items.isEmpty) {
      return _buildEmptyState('No items found');
    }

    return GridView.builder(
      padding: const EdgeInsets.all(AppSpacing.md),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: AppSpacing.sm,
        mainAxisSpacing: AppSpacing.sm,
      ),
      itemCount: _items.length,
      itemBuilder: (context, index) {
        final item = _items[index];
        return MarketplaceItemCard(
          item: item,
          onTap: () => context.go('/marketplace/${item.id}'),
        );
      },
    );
  }

  Widget _buildAccommodationsTab() {
    if (_accommodations.isEmpty) {
      return _buildEmptyState('No accommodations found');
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: _accommodations.length,
      itemBuilder: (context, index) {
        final accommodation = _accommodations[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.md),
          child: AccommodationCard(
            accommodation: accommodation,
            onTap: () => context.go('/accommodation/${accommodation.id}'),
          ),
        );
      },
    );
  }

  Widget _buildEventsTab() {
    if (_events.isEmpty) {
      return _buildEmptyState('No events found');
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: _events.length,
      itemBuilder: (context, index) {
        final event = _events[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.md),
          child: EventCard(
            event: event,
            onTap: () => context.go('/events/${event.id}'),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(String message) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: theme.colorScheme.onSurface.withOpacity(0.3),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            message,
            style: theme.textTheme.headlineSmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Try adjusting your search terms',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }
}
