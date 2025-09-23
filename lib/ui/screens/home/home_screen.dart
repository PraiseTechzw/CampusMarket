/// @Branch: Home Screen Implementation
///
/// Main dashboard with hero section, quick actions, and highlights
/// Provides overview of all Campus Market features
library;

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/glow_card.dart';
import '../../../core/widgets/live_badge.dart';
import '../../../core/widgets/app_logo.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/repositories/firebase_repository.dart';
import '../../../core/models/event.dart';
import '../../../core/models/accommodation.dart';
import '../../widgets/event_card.dart';
import '../../widgets/accommodation_card.dart';
import '../../widgets/product_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _showAppBar = false;
  String _selectedUniversity = 'All Universities';

  // Data state
  bool _isLoading = true;
  List<Map<String, dynamic>> _featuredProducts = [];
  List<Map<String, dynamic>> _liveEvents = [];
  List<Map<String, dynamic>> _accommodations = [];
  List<Map<String, dynamic>> _categories = [];
  List<Map<String, dynamic>> _hotDeals = [];

  // Responsive breakpoints
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 1024;
  static const double desktopBreakpoint = 1440;

  // Responsive helper methods
  bool get isMobile => MediaQuery.of(context).size.width < mobileBreakpoint;
  bool get isTablet =>
      MediaQuery.of(context).size.width >= mobileBreakpoint &&
      MediaQuery.of(context).size.width < tabletBreakpoint;
  bool get isDesktop => MediaQuery.of(context).size.width >= desktopBreakpoint;
  bool get isWeb => kIsWeb;

  double get screenWidth => MediaQuery.of(context).size.width;

  @override
  void initState() {
    super.initState();
    _loadData();
    _scrollController.addListener(_onScroll);
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      // Load data from database
      final products = await FirebaseRepository.getProducts(limit: 6);
      final events = await FirebaseRepository.getEvents(limit: 4);
      final accommodations = await FirebaseRepository.getAccommodations(
        limit: 2,
      );
      final categories = await FirebaseRepository.getCategories();

      setState(() {
        _featuredProducts = products.take(3).toList();
        _liveEvents = events.take(4).toList();
        _accommodations = accommodations.take(2).toList();
        _categories = categories.take(4).toList();
        _hotDeals = products
            .where(
              (item) =>
                  double.tryParse(item['price']?.toString() ?? '0') != null &&
                  double.parse(item['price'].toString()) < 50,
            )
            .take(3)
            .toList();
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading data: $e');
      setState(() => _isLoading = false);
    }
  }

  double get screenHeight => MediaQuery.of(context).size.height;

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.offset > 100 && !_showAppBar) {
      setState(() => _showAppBar = true);
    } else if (_scrollController.offset <= 100 && _showAppBar) {
      setState(() => _showAppBar = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: AppSpacing.lg),
              Text('Loading Campus Market...'),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: isWeb
          ? _buildWebLayout(theme, l10n)
          : _buildMobileLayout(theme, l10n),
      floatingActionButton: _buildFloatingActionButton(theme, l10n),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildWebLayout(ThemeData theme, AppLocalizations l10n) =>
      _buildMainContent(theme, l10n);

  Widget _buildMobileLayout(ThemeData theme, AppLocalizations l10n) =>
      _buildMainContent(theme, l10n);

  Widget _buildMainContent(ThemeData theme, AppLocalizations l10n) =>
      RefreshIndicator(
        onRefresh: () async {
          // Simulate refresh delay
          await Future<void>.delayed(const Duration(seconds: 1));
          setState(() {
            // Trigger rebuild to refresh data
          });
        },
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            // App Bar
            SliverAppBar(
              expandedHeight: 200,
              floating: true,
              pinned: true,
              backgroundColor: theme.colorScheme.surface,
              elevation: _showAppBar ? 4 : 0,
              flexibleSpace: FlexibleSpaceBar(
                title: _showAppBar ? Text(l10n.appName) : null,
                background: _buildHeroSection(),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () => context.go('/search'),
                ),
                IconButton(
                  icon: const Icon(Icons.notifications_outlined),
                  onPressed: () {
                    // TODO: Implement notifications
                  },
                ),
              ],
            ),

            // Content
            SliverPadding(
              padding: EdgeInsets.all(
                isMobile
                    ? AppSpacing.md
                    : (isWeb ? AppSpacing.xl : AppSpacing.lg),
              ),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // University Filter
                  _buildUniversityFilter(),

                  const SizedBox(height: AppSpacing.lg),

                  // Promotional Banners
                  _buildPromotionalBanners(),

                  const SizedBox(height: AppSpacing.lg),

                  // Hot Deals
                  _buildHotDealsSection(),

                  const SizedBox(height: AppSpacing.xl),

                  // Featured Items
                  _buildFeaturedSection(
                    'Popular Items This Week',
                    _featuredProducts,
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  // Live Events
                  _buildLiveEventsSection(),

                  const SizedBox(height: AppSpacing.xl),

                  // Recent Accommodations
                  _buildAccommodationSection(),

                  const SizedBox(height: AppSpacing.xl),

                  // Categories
                  _buildCategoriesSection(),

                  const SizedBox(height: AppSpacing.xxxl),
                ]),
              ),
            ),
          ],
        ),
      );

  Widget _buildHeroSection() {
    final theme = Theme.of(context);

    return Container(
      height: isWeb ? null : 320,
      constraints: isWeb ? const BoxConstraints(minHeight: 800) : null,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.primary.withOpacity(0.9),
            theme.colorScheme.secondary.withOpacity(0.1),
          ],
          stops: const [0.0, 0.7, 1.0],
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withOpacity(0.2),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Background decorative elements
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    theme.colorScheme.secondary.withOpacity(0.3),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -50,
            left: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    theme.appColors.accent.withOpacity(0.2),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          // Main content
          SafeArea(
            child: Padding(
              padding: EdgeInsets.all(
                isMobile
                    ? AppSpacing.lg
                    : (isWeb ? AppSpacing.xxxl : AppSpacing.xl),
              ),
              child: isWeb
                  ? _buildWebHero(theme)
                  : (isDesktop
                        ? _buildDesktopHero(theme)
                        : _buildMobileHero(theme)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWebHero(ThemeData theme) => _WebHeroSection(theme: theme);

  Widget _buildNavPill(String label, IconData icon, VoidCallback onTap) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: Colors.white.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 16),
            const SizedBox(width: 8),
            Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturedPreview(ThemeData theme) {
    final featuredItems = _featuredProducts;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Trending Now',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Expanded(
            child: ListView.builder(
              itemCount: featuredItems.length,
              itemBuilder: (context, index) {
                final item = featuredItems[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.secondary.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.shopping_bag,
                          color: theme.colorScheme.secondary,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              (item['title'] as String?) ?? '',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              '${item['currency'] ?? 'USD'} ${(item['price'] ?? 0).toStringAsFixed(0)}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.secondary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWebQuickStat(String value, String label, ThemeData theme) =>
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: theme.textTheme.headlineLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.white.withOpacity(0.8),
              ),
            ),
          ],
        ),
      );

  Widget _buildMobileHero(ThemeData theme) => SingleChildScrollView(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Top section with logo and quick actions
        Row(
          children: [
            const AppLogo.small(),
            const Spacer(),
            // Quick action buttons
            Row(
              children: [
                _buildMobileQuickAction(
                  Icons.store,
                  () => context.go('/marketplace'),
                ),
                const SizedBox(width: AppSpacing.sm),
                _buildMobileQuickAction(
                  Icons.home_work,
                  () => context.go('/accommodation'),
                ),
                const SizedBox(width: AppSpacing.sm),
                _buildMobileQuickAction(
                  Icons.event,
                  () => context.go('/events'),
                ),
              ],
            ),
          ],
        ),

        const SizedBox(height: AppSpacing.lg),

        // Welcome message
        Consumer<AuthProvider>(
          builder: (context, authProvider, child) {
            return RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: 'Welcome back, ',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  TextSpan(
                    text: authProvider.currentUser?.firstName ?? 'Student',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const TextSpan(text: '! 👋', style: TextStyle(fontSize: 24)),
                ],
              ),
            );
          },
        ),

        const SizedBox(height: AppSpacing.sm),

        // Main headline
        Text(
          'Zimbabwe\'s Premier Student Marketplace',
          style: theme.textTheme.displaySmall?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: AppSpacing.sm),

        // Subtitle
        Text(
          'Buy, sell, and discover amazing items while building lasting campus relationships',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: Colors.white.withOpacity(0.9),
          ),
        ),

        const SizedBox(height: AppSpacing.lg),

        // Enhanced search bar
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search items, housing, events...',
                    hintStyle: TextStyle(color: Colors.grey[500], fontSize: 16),
                    prefixIcon: Icon(
                      Icons.search,
                      color: theme.colorScheme.primary,
                      size: 20,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.md,
                    ),
                  ),
                  onSubmitted: (value) {
                    if (value.isNotEmpty) {
                      context.go('/search?q=$value');
                    }
                  },
                ),
              ),
              Container(
                margin: const EdgeInsets.only(right: 8),
                child: ElevatedButton(
                  onPressed: () {
                    // TODO: Implement search
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm,
                    ),
                  ),
                  child: const Text('Search'),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: AppSpacing.lg),

        // Quick stats for mobile
        Row(
          children: [
            Expanded(child: _buildMobileQuickStat('2.5K+', 'Students', theme)),
            const SizedBox(width: AppSpacing.sm),
            Expanded(child: _buildMobileQuickStat('8', 'Universities', theme)),
            const SizedBox(width: AppSpacing.sm),
            Expanded(child: _buildMobileQuickStat('500+', 'Items', theme)),
          ],
        ),
      ],
    ),
  );

  Widget _buildMobileQuickAction(IconData icon, VoidCallback onTap) =>
      GestureDetector(
        onTap: onTap,
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
      );

  Widget _buildMobileQuickStat(String value, String label, ThemeData theme) =>
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: theme.textTheme.titleLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.white.withOpacity(0.8),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );

  Widget _buildDesktopHero(ThemeData theme) => SingleChildScrollView(
    child: Column(
      children: [
        // Top section with logo and navigation
        Row(
          children: [
            const AppLogo.large(),
            const Spacer(),
            // Quick navigation pills
            Row(
              children: [
                _buildNavPill(
                  'Marketplace',
                  Icons.store,
                  () => context.go('/marketplace'),
                ),
                const SizedBox(width: AppSpacing.sm),
                _buildNavPill(
                  'Housing',
                  Icons.home_work,
                  () => context.go('/accommodation'),
                ),
                const SizedBox(width: AppSpacing.sm),
                _buildNavPill(
                  'Events',
                  Icons.event,
                  () => context.go('/events'),
                ),
              ],
            ),
          ],
        ),

        const SizedBox(height: AppSpacing.xl),

        // Main content row
        Row(
          children: [
            // Left content
            Expanded(
              flex: 2,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Welcome message
                    Consumer<AuthProvider>(
                      builder: (context, authProvider, child) {
                        return RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: 'Welcome back, ',
                                style: theme.textTheme.headlineLarge?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              TextSpan(
                                text:
                                    authProvider.currentUser?.firstName ??
                                    'Student',
                                style: theme.textTheme.headlineLarge?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const TextSpan(
                                text: '! 👋',
                                style: TextStyle(fontSize: 32),
                              ),
                            ],
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: AppSpacing.md),

                    // Main headline
                    Text(
                      'Zimbabwe\'s Premier Student Marketplace',
                      style: theme.textTheme.displayLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 42,
                      ),
                    ),

                    const SizedBox(height: AppSpacing.sm),

                    // Subtitle
                    Text(
                      'Buy, sell, and discover amazing items while building lasting campus relationships',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),

                    const SizedBox(height: AppSpacing.xl),

                    // Search bar
                    Container(
                      width: 500,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.15),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              decoration: InputDecoration(
                                hintText: 'Search items, events, housing...',
                                hintStyle: TextStyle(
                                  color: Colors.grey[500],
                                  fontSize: 16,
                                ),
                                prefixIcon: Icon(
                                  Icons.search,
                                  color: theme.colorScheme.primary,
                                  size: 24,
                                ),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.lg,
                                  vertical: AppSpacing.lg,
                                ),
                              ),
                              onSubmitted: (value) {
                                if (value.isNotEmpty) {
                                  context.go('/search?q=$value');
                                }
                              },
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.only(right: 8),
                            child: ElevatedButton(
                              onPressed: () {
                                // TODO: Implement search
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: theme.colorScheme.primary,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.lg,
                                  vertical: AppSpacing.md,
                                ),
                              ),
                              child: const Text('Search'),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: AppSpacing.xl),

                    // Quick stats
                    Row(
                      children: [
                        _buildWebQuickStat('2.5K+', 'Active Students', theme),
                        const SizedBox(width: AppSpacing.lg),
                        _buildWebQuickStat('8', 'Universities', theme),
                        const SizedBox(width: AppSpacing.lg),
                        _buildWebQuickStat('500+', 'Items Listed', theme),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Right side - Featured items preview
            const SizedBox(width: AppSpacing.xl),
            Expanded(flex: 1, child: _buildFeaturedPreview(theme)),
          ],
        ),
      ],
    ),
  );

  Widget _buildUniversityFilter() {
    final theme = Theme.of(context);

    final universities = [
      'All Universities',
      'University of Zimbabwe',
      'National University of Science and Technology',
      'Chinhoyi University of Technology',
      'Bindura University of Science Education',
      'Great Zimbabwe University',
      'Midlands State University',
      'Lupane State University',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
                  'Filter by University',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                )
                .animate()
                .fadeIn(delay: 200.ms, duration: 600.ms)
                .slideX(begin: -0.3, end: 0),

            // Clear filter button
            if (_selectedUniversity != 'All Universities')
              GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedUniversity = 'All Universities';
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: theme.colorScheme.outline.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.clear,
                            size: 16,
                            color: theme.colorScheme.onSurface.withOpacity(0.7),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Clear',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface.withOpacity(
                                0.7,
                              ),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  .animate()
                  .fadeIn(delay: 400.ms, duration: 600.ms)
                  .scale(
                    begin: const Offset(0.8, 0.8),
                    end: const Offset(1, 1),
                  ),
          ],
        ),

        const SizedBox(height: AppSpacing.md),

        SizedBox(
          height: 50,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: universities.length,
            itemBuilder: (context, index) {
              final university = universities[index];
              final isSelected = university == _selectedUniversity;

              return Padding(
                padding: const EdgeInsets.only(right: AppSpacing.md),
                child: _buildEnhancedFilterChip(
                  university,
                  isSelected,
                  theme,
                  index,
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildEnhancedFilterChip(
    String university,
    bool isSelected,
    ThemeData theme,
    int index,
  ) =>
      GestureDetector(
            onTap: () {
              setState(() {
                _selectedUniversity = university;
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                gradient: isSelected
                    ? LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          theme.colorScheme.primary,
                          theme.colorScheme.secondary,
                        ],
                      )
                    : null,
                color: isSelected ? null : theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(25),
                border: Border.all(
                  color: isSelected
                      ? Colors.transparent
                      : theme.colorScheme.outline.withOpacity(0.3),
                  width: 1.5,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: theme.colorScheme.primary.withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isSelected)
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.check,
                        size: 12,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  if (isSelected) const SizedBox(width: 8),
                  Text(
                    university,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.w500,
                      color: isSelected
                          ? Colors.white
                          : theme.colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
          )
          .animate()
          .fadeIn(
            delay: Duration(milliseconds: 600 + (index * 100)),
            duration: 600.ms,
          )
          .slideX(
            begin: 0.3,
            end: 0,
            delay: Duration(milliseconds: 600 + (index * 100)),
            duration: 600.ms,
          )
          .scale(
            begin: const Offset(0.9, 0.9),
            end: const Offset(1.0, 1.0),
            delay: Duration(milliseconds: 600 + (index * 100)),
            duration: 600.ms,
          );

  Widget _buildFeaturedSection(String title, List<dynamic> items) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
                  children: [
                    Container(
                      width: 4,
                      height: 24,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            theme.colorScheme.primary,
                            theme.colorScheme.secondary,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Row(
                      children: [
                        Text(
                          title,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'POPULAR',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 9,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                )
                .animate()
                .fadeIn(delay: 200.ms, duration: 600.ms)
                .slideX(begin: -0.3, end: 0),
            DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        theme.colorScheme.primary,
                        theme.colorScheme.secondary,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: theme.colorScheme.primary.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextButton(
                    onPressed: () => context.go('/marketplace'),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                        horizontal: isMobile ? 12 : 16,
                        vertical: isMobile ? 8 : 12,
                      ),
                    ),
                    child: Text(
                      isMobile ? 'All' : 'View All',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: isMobile ? 12 : 14,
                      ),
                    ),
                  ),
                )
                .animate()
                .fadeIn(delay: 400.ms, duration: 600.ms)
                .slideX(begin: 0.3, end: 0),
          ],
        ),

        const SizedBox(height: AppSpacing.lg),

        if (isWeb)
          _buildWebFeaturedGrid(items)
        else
          _buildMobileFeaturedList(items),
      ],
    );
  }

  Widget _buildWebFeaturedGrid(List<dynamic> items) => GridView.builder(
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 3,
      childAspectRatio: 0.7,
      crossAxisSpacing: AppSpacing.xl,
      mainAxisSpacing: AppSpacing.xl,
    ),
    itemCount: items.length,
    itemBuilder: (context, index) {
      final item = items[index];
      final theme = Theme.of(context);
      return ProductCard(
        item: item,
        index: index,
        badgeText: 'POPULAR',
        badgeColor: theme.colorScheme.primary,
        badgeIcon: Icons.trending_up,
        priceColor: theme.colorScheme.primary,
        actionText: '${item['view_count'] ?? 0}',
        actionIcon: Icons.visibility,
        actionColor: theme.colorScheme.primary,
        showViewCount: true,
        showFavoriteCount: false,
      );
    },
  );

  Widget _buildMobileFeaturedList(List<dynamic> items) => SizedBox(
    height: isMobile ? 460 : 480,
    child: ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final theme = Theme.of(context);
        return SizedBox(
          width: isMobile ? 340 : (isTablet ? 370 : 400),
          child: Padding(
            padding: EdgeInsets.only(
              right: index < items.length - 1 ? AppSpacing.lg : 0,
            ),
            child: ProductCard(
              item: item,
              index: index,
              badgeText: 'POPULAR',
              badgeColor: theme.colorScheme.primary,
              badgeIcon: Icons.trending_up,
              priceColor: theme.colorScheme.primary,
              actionText: '${item['view_count'] ?? 0}',
              actionIcon: Icons.visibility,
              actionColor: theme.colorScheme.primary,
              showViewCount: true,
              showFavoriteCount: false,
            ),
          ),
        );
      },
    ),
  );

  Widget _buildLiveEventsSection() {
    final theme = Theme.of(context);
    final liveEvents = _liveEvents
        .where((event) => event['is_active'] == true)
        .take(2)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Campus Events',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            const LiveBadge('LIVE'),
          ],
        ),

        const SizedBox(height: AppSpacing.md),

        if (liveEvents.isNotEmpty)
          ...liveEvents.map((eventMap) {
            final event = Event.fromJson(eventMap);
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: EventCard(
                event: event,
                onTap: () => context.go('/events/${event.id}'),
              ),
            );
          })
        else
          Container(
            height: 100,
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              border: Border.all(
                color: theme.colorScheme.outline.withOpacity(0.2),
              ),
            ),
            child: Center(
              child: Text(
                'No live events at the moment',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildAccommodationSection() {
    final theme = Theme.of(context);
    final accommodations = _accommodations;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Student Housing Near Campus',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () => context.go('/accommodation'),
              child: const Text('View All'),
            ),
          ],
        ),

        const SizedBox(height: AppSpacing.md),

        ...accommodations.map((accommodationMap) {
          try {
            final accommodationJson = _convertFirebaseDataToAccommodation(
              accommodationMap,
            );
            final accommodation = Accommodation.fromJson(accommodationJson);
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: AccommodationCard(
                accommodation: accommodation,
                onTap: () => context.go('/accommodation/${accommodation.id}'),
              ),
            );
          } catch (e) {
            print('Error parsing accommodation in HomeScreen: $e');
            return const SizedBox.shrink(); // Skip invalid accommodations
          }
        }),
      ],
    );
  }

  Widget _buildCategoriesSection() {
    final theme = Theme.of(context);
    final categories = _categories;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Browse Categories',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () => context.go('/marketplace'),
              child: const Text('View All'),
            ),
          ],
        ),

        const SizedBox(height: AppSpacing.md),

        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: isMobile ? 2 : (isTablet ? 3 : (isWeb ? 6 : 4)),
            childAspectRatio: isMobile
                ? 2.2
                : (isTablet ? 2.5 : (isWeb ? 3.0 : 2.8)),
            crossAxisSpacing: isWeb ? AppSpacing.lg : AppSpacing.sm,
            mainAxisSpacing: isWeb ? AppSpacing.lg : AppSpacing.sm,
          ),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final category = categories[index];
            return MouseRegion(
              cursor: isWeb ? SystemMouseCursors.click : MouseCursor.defer,
              child: GlowCard(
                onTap: () =>
                    context.go('/marketplace?category=${category['id']}'),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Color(
                          int.parse(
                            ((category['color'] as String?) ?? '#000000')
                                .replaceFirst('#', '0xFF'),
                          ),
                        ).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Icon(
                        _getCategoryIcon((category['id'] as String?) ?? ''),
                        color: Color(
                          int.parse(
                            ((category['color'] as String?) ?? '#000000')
                                .replaceFirst('#', '0xFF'),
                          ),
                        ),
                        size: 20,
                      ),
                    ),

                    const SizedBox(width: AppSpacing.sm),

                    Expanded(
                      child: Text(
                        (category['name'] as String?) ?? '',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  IconData _getCategoryIcon(String categoryId) {
    switch (categoryId) {
      case 'electronics':
        return Icons.devices;
      case 'books':
        return Icons.menu_book;
      case 'transportation':
        return Icons.directions_bike;
      case 'furniture':
        return Icons.chair;
      case 'clothing':
        return Icons.checkroom;
      default:
        return Icons.category;
    }
  }

  Widget _buildPromotionalBanners() {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
                  children: [
                    Container(
                      width: 4,
                      height: 24,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            theme.colorScheme.primary,
                            theme.colorScheme.secondary,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      'Special Offers',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'HOT',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 9,
                        ),
                      ),
                    ),
                  ],
                )
                .animate()
                .fadeIn(delay: 200.ms, duration: 600.ms)
                .slideX(begin: -0.3, end: 0),
            Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: theme.colorScheme.primary.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.timer,
                        size: 14,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Limited Time',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                )
                .animate()
                .fadeIn(delay: 400.ms, duration: 600.ms)
                .slideX(begin: 0.3, end: 0),
          ],
        ),

        const SizedBox(height: AppSpacing.lg),

        if (isWeb) _buildWebBanners() else _buildMobileBanners(),
      ],
    );
  }

  Widget _buildWebBanners() => _buildWebSpecialOffers();

  Widget _buildMobileBanners() => SizedBox(
    height: isMobile ? 200 : 180,
    child: _buildAutoScrollingBanners(),
  );

  Widget _buildWebSpecialOffers() {
    final theme = Theme.of(context);
    final offers = [
      {
        'title': 'New Student Welcome',
        'subtitle': 'Get 20% off your first purchase',
        'description':
            'Exclusive discount for new students joining our platform',
        'icon': Icons.celebration,
        'colors': [theme.colorScheme.primary, theme.colorScheme.secondary],
        'onTap': () => context.go('/marketplace?promo=welcome20'),
        'badge': '20% OFF',
        'badgeColor': Colors.red,
        'expiry': 'Limited Time',
        'category': 'Discount',
      },
      {
        'title': 'Textbook Exchange',
        'subtitle': 'Trade books with fellow students',
        'description':
            'Connect with students to exchange textbooks and study materials',
        'icon': Icons.swap_horiz,
        'colors': [theme.colorScheme.secondary, theme.colorScheme.primary],
        'onTap': () => context.go('/marketplace?category=books'),
        'badge': 'FREE',
        'badgeColor': Colors.green,
        'expiry': 'Always Available',
        'category': 'Service',
      },
      {
        'title': 'Campus Events',
        'subtitle': 'Join exciting university activities',
        'description':
            'Discover and participate in campus events and activities',
        'icon': Icons.event,
        'colors': [theme.appColors.accent, theme.colorScheme.primary],
        'onTap': () => context.go('/events'),
        'badge': 'LIVE',
        'badgeColor': Colors.orange,
        'expiry': 'Ongoing',
        'category': 'Events',
      },
      {
        'title': 'Student Housing',
        'subtitle': 'Find your perfect accommodation',
        'description':
            'Browse verified student accommodations near your university',
        'icon': Icons.home_work,
        'colors': [Colors.blue, Colors.purple],
        'onTap': () => context.go('/accommodation'),
        'badge': 'NEW',
        'badgeColor': Colors.blue,
        'expiry': 'Fresh Listings',
        'category': 'Housing',
      },
    ];

    return _WebSpecialOffers(offers: offers, theme: theme);
  }

  Widget _buildAutoScrollingBanners() {
    final theme = Theme.of(context);
    final banners = [
      {
        'title': 'New Student Welcome',
        'subtitle': 'Get 20% off your first purchase',
        'icon': Icons.celebration,
        'colors': [theme.colorScheme.primary, theme.colorScheme.secondary],
        'onTap': () => context.go('/marketplace?promo=welcome20'),
        'badge': '20% OFF',
        'badgeColor': Colors.red,
      },
      {
        'title': 'Textbook Exchange',
        'subtitle': 'Trade books with fellow students',
        'icon': Icons.swap_horiz,
        'colors': [theme.colorScheme.secondary, theme.colorScheme.primary],
        'onTap': () => context.go('/marketplace?category=books'),
        'badge': 'FREE',
        'badgeColor': Colors.green,
      },
      {
        'title': 'Campus Events',
        'subtitle': 'Join exciting university activities',
        'icon': Icons.event,
        'colors': [theme.appColors.accent, theme.colorScheme.primary],
        'onTap': () => context.go('/events'),
        'badge': 'LIVE',
        'badgeColor': Colors.orange,
      },
      {
        'title': 'Student Housing',
        'subtitle': 'Find your perfect accommodation',
        'icon': Icons.home_work,
        'colors': [Colors.blue, Colors.purple],
        'onTap': () => context.go('/accommodation'),
        'badge': 'NEW',
        'badgeColor': Colors.blue,
      },
    ];

    return _AutoScrollingBanners(
      banners: banners,
      isMobile: isMobile,
      isWeb: isWeb,
    );
  }

  Widget _buildHotDealsSection() {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
                  children: [
                    Container(
                      width: 4,
                      height: 24,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.orange, Colors.red],
                        ),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Row(
                      children: [
                        Text(
                          'Hot Deals',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '🔥',
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                )
                .animate()
                .fadeIn(delay: 200.ms, duration: 600.ms)
                .slideX(begin: -0.3, end: 0),
            DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Colors.orange, Colors.red],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.orange.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextButton(
                    onPressed: () =>
                        context.go('/marketplace?filter=hot_deals'),
                    child: const Text(
                      'View All Deals',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                )
                .animate()
                .fadeIn(delay: 400.ms, duration: 600.ms)
                .slideX(begin: 0.3, end: 0),
          ],
        ),

        const SizedBox(height: AppSpacing.lg),

        if (isWeb) _buildWebHotDeals() else _buildMobileHotDeals(),
      ],
    );
  }

  Widget _buildWebHotDeals() {
    final hotDeals = _hotDeals
        .where(
          (item) =>
              (double.tryParse(item['price']?.toString() ?? '0') ?? 0) < 50,
        ) // Example: items under $50
        .take(3)
        .toList();

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: isWeb ? 0.7 : 0.75,
        crossAxisSpacing: AppSpacing.lg,
        mainAxisSpacing: AppSpacing.lg,
      ),
      itemCount: hotDeals.length,
      itemBuilder: (context, index) {
        final item = hotDeals[index];
        final discountPercentage =
            (((item['price'] ?? 0) * 1.5 - (item['price'] ?? 0)) /
                    ((item['price'] ?? 0) * 1.5) *
                    100)
                .round();
        return ProductCard(
          item: item,
          index: index,
          badgeText: '$discountPercentage% OFF',
          badgeColor: Colors.red,
          priceColor: Colors.red,
          actionText: 'Limited Time',
          actionIcon: Icons.timer,
          actionColor: Colors.orange,
          showViewCount: false,
        );
      },
    );
  }

  Widget _buildMobileHotDeals() {
    final hotDeals = _hotDeals
        .where(
          (item) =>
              (double.tryParse(item['price']?.toString() ?? '0') ?? 0) < 50,
        )
        .take(3)
        .toList();

    return SizedBox(
      height: isMobile ? 400 : 420,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: hotDeals.length,
        itemBuilder: (context, index) {
          final item = hotDeals[index];
          final discountPercentage =
              (((item['price'] ?? 0) * 1.5 - (item['price'] ?? 0)) /
                      ((item['price'] ?? 0) * 1.5) *
                      100)
                  .round();
          return SizedBox(
            width: isMobile ? 340 : 320,
            child: Padding(
              padding: EdgeInsets.only(
                right: index < hotDeals.length - 1 ? AppSpacing.lg : 0,
              ),
              child: ProductCard(
                item: item,
                index: index,
                badgeText: '$discountPercentage% OFF',
                badgeColor: Colors.red,
                priceColor: Colors.red,
                actionText: 'Limited Time',
                actionIcon: Icons.timer,
                actionColor: Colors.orange,
                showViewCount: false,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFloatingActionButton(ThemeData theme, AppLocalizations l10n) =>
      FloatingActionButton(
        onPressed: () => _showQuickActionsMenu(context, theme, l10n),
        backgroundColor: theme.colorScheme.primary,
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      );

  void _showQuickActionsMenu(
    BuildContext context,
    ThemeData theme,
    AppLocalizations l10n,
  ) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _buildQuickActionsPopup(theme, l10n),
    );
  }

  Widget _buildQuickActionsPopup(ThemeData theme, AppLocalizations l10n) =>
      Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.onSurface.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              const SizedBox(height: 24),

              // Title
              Text(
                'Quick Actions',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 24),

              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: _buildQuickActionCard(
                      l10n.sellItem,
                      Icons.add_circle_outline,
                      theme.colorScheme.primary,
                      () {
                        Navigator.pop(context);
                        context.go('/marketplace/create');
                      },
                      theme,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildQuickActionCard(
                      l10n.listRoom,
                      Icons.home_work_outlined,
                      theme.colorScheme.secondary,
                      () {
                        Navigator.pop(context);
                        context.go('/accommodation');
                      },
                      theme,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildQuickActionCard(
                      l10n.createEvent,
                      Icons.event_outlined,
                      theme.colorScheme.tertiary,
                      () {
                        Navigator.pop(context);
                        context.go('/events/create');
                      },
                      theme,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      );

  Widget _buildQuickActionCard(
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
    ThemeData theme,
  ) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2), width: 1),
      ),
      child: Column(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [color, color.withOpacity(0.8)]),
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: color,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    ),
  );

  Map<String, dynamic> _convertFirebaseDataToAccommodation(
    Map<String, dynamic> data,
  ) {
    // Convert Firebase field names to match Accommodation model
    return {
      'id': data['id'] ?? '',
      'title': data['title'] ?? 'Untitled Property',
      'description': data['description'] ?? '',
      'price':
          (data['pricePerMonth'] ??
                  data['price_per_month'] ??
                  data['price'] ??
                  0)
              .toDouble(),
      'currency': data['currency'] ?? 'USD',
      'pricePeriod': 'month',
      'imageUrls': _parseStringList(data['images']),
      'type':
          data['propertyType'] ??
          data['property_type'] ??
          data['roomType'] ??
          data['room_type'] ??
          'room',
      'bedrooms': (data['bedrooms'] ?? 1).toInt(),
      'bathrooms': (data['bathrooms'] ?? 1).toDouble(),
      'area': data['area']?.toDouble(),
      'areaUnit': data['areaUnit'] ?? data['area_unit'] ?? 'sqft',
      'hostId': data['userId'] ?? data['user_id'] ?? '',
      'hostName': data['hostName'] ?? data['host_name'] ?? 'Unknown Host',
      'hostProfileImage':
          data['hostProfileImage'] ?? data['host_profile_image'],
      'address': data['address'] ?? 'Address not provided',
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
      'viewCount': (data['viewCount'] ?? data['view_count'] ?? 0).toInt(),
      'favoriteCount': (data['favoriteCount'] ?? data['favorite_count'] ?? 0)
          .toInt(),
      'status': data['status'] ?? 'active',
      'availability': <Map<String, dynamic>>[],
      'roommatePreferences': <Map<String, dynamic>>[],
    };
  }

  DateTime _parseDateTime(dynamic dateValue) {
    if (dateValue == null) return DateTime.now();

    if (dateValue is String) {
      try {
        return DateTime.parse(dateValue);
      } catch (e) {
        return DateTime.now();
      }
    }

    if (dateValue is DateTime) {
      return dateValue;
    }

    // Handle Firestore Timestamp if needed
    if (dateValue.runtimeType.toString().contains('Timestamp')) {
      try {
        return (dateValue as dynamic).toDate() as DateTime;
      } catch (e) {
        return DateTime.now();
      }
    }

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
}

class QuickAction {
  QuickAction({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
}

class _AutoScrollingBanners extends StatefulWidget {
  const _AutoScrollingBanners({
    required this.banners,
    required this.isMobile,
    required this.isWeb,
  });
  final List<Map<String, dynamic>> banners;
  final bool isMobile;
  final bool isWeb;

  @override
  State<_AutoScrollingBanners> createState() => _AutoScrollingBannersState();
}

class _AutoScrollingBannersState extends State<_AutoScrollingBanners> {
  late PageController _pageController;
  int _currentIndex = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _startAutoScroll();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _startAutoScroll() {
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (_pageController.hasClients) {
        _currentIndex = (_currentIndex + 1) % widget.banners.length;
        _pageController.animateToPage(
          _currentIndex,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) => Column(
    children: [
      // Banner carousel
      SizedBox(
        height: widget.isMobile ? 160 : 140,
        child: PageView.builder(
          controller: _pageController,
          onPageChanged: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          itemCount: widget.banners.length,
          itemBuilder: (context, index) {
            final banner = widget.banners[index];
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: widget.isWeb ? 0 : 16),
              child: _buildBannerCard(
                (banner['title'] as String?) ?? '',
                (banner['subtitle'] as String?) ?? '',
                banner['icon'] as IconData,
                banner['colors'] as List<Color>,
                banner['onTap'] as VoidCallback,
                badge: banner['badge'] as String?,
                badgeColor: banner['badgeColor'] as Color?,
              ),
            );
          },
        ),
      ),

      const SizedBox(height: 16),

      // Page indicators
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
          widget.banners.length,
          (index) => AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: _currentIndex == index ? 24 : 8,
            height: 8,
            decoration: BoxDecoration(
              color: _currentIndex == index
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.outline.withOpacity(0.3),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
      ),
    ],
  );

  Widget _buildBannerCard(
    String title,
    String subtitle,
    IconData icon,
    List<Color> colors,
    VoidCallback onTap, {
    String? badge,
    Color? badgeColor,
  }) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: widget.isMobile ? 160 : 140,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: colors,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: colors.first.withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Background pattern
            Positioned(
              top: -20,
              right: -20,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.1),
                ),
              ),
            ),
            Positioned(
              bottom: -20,
              left: -20,
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.05),
                ),
              ),
            ),

            // Badge
            if (badge != null)
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: badgeColor ?? Colors.red,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: (badgeColor ?? Colors.red).withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    badge,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                  ),
                ),
              ),

            // Content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          title,
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: widget.isMobile ? 16 : 18,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          subtitle,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: widget.isMobile ? 12 : 14,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Shop Now',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 11,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Icon(
                                Icons.arrow_forward,
                                size: 12,
                                color: Colors.white,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Icon(icon, size: 24, color: Colors.white),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WebSpecialOffers extends StatefulWidget {
  const _WebSpecialOffers({required this.offers, required this.theme});
  final List<Map<String, dynamic>> offers;
  final ThemeData theme;

  @override
  State<_WebSpecialOffers> createState() => _WebSpecialOffersState();
}

class _WebSpecialOffersState extends State<_WebSpecialOffers>
    with TickerProviderStateMixin {
  late PageController _pageController;
  int _currentIndex = 0;
  Timer? _timer;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _startAutoScroll();
    _animationController.forward();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _startAutoScroll() {
    _timer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_pageController.hasClients) {
        _currentIndex = (_currentIndex + 1) % widget.offers.length;
        _pageController.animateToPage(
          _currentIndex,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) => FadeTransition(
    opacity: _fadeAnimation,
    child: Column(
      children: [
        // Main offers grid
        SizedBox(
          height: 280,
          child: Row(
            children: [
              // Left side - Featured offer (larger)
              Expanded(flex: 2, child: _buildFeaturedOffer(widget.offers[0])),
              const SizedBox(width: 16),
              // Right side - Other offers
              Expanded(
                flex: 1,
                child: Column(
                  children: [
                    Expanded(child: _buildCompactOffer(widget.offers[1])),
                    const SizedBox(height: 16),
                    Expanded(child: _buildCompactOffer(widget.offers[2])),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              // Right side - Other offers
              Expanded(
                flex: 1,
                child: Column(
                  children: [
                    Expanded(child: _buildCompactOffer(widget.offers[3])),
                    const SizedBox(height: 16),
                    Expanded(
                      child: _buildOfferCard(
                        'View All Offers',
                        'See more special deals',
                        Icons.arrow_forward,
                        [
                          widget.theme.colorScheme.outline,
                          widget.theme.colorScheme.outline.withOpacity(0.7),
                        ],
                        () => context.go('/offers'),
                        isCompact: true,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Navigation dots
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            widget.offers.length,
            (index) => AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 6),
              width: _currentIndex == index ? 32 : 8,
              height: 8,
              decoration: BoxDecoration(
                color: _currentIndex == index
                    ? widget.theme.colorScheme.primary
                    : widget.theme.colorScheme.outline.withOpacity(0.3),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
      ],
    ),
  );

  Widget _buildFeaturedOffer(Map<String, dynamic> offer) => MouseRegion(
    cursor: SystemMouseCursors.click,
    child: GestureDetector(
      onTap: offer['onTap'] as GestureTapCallback?,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: offer['colors'] as List<Color>,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: (offer['colors'] as List<Color>)[0].withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Background pattern
            Positioned(
              top: -30,
              right: -30,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.1),
                ),
              ),
            ),
            Positioned(
              bottom: -20,
              left: -20,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.05),
                ),
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Badge and category
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: offer['badgeColor'] as Color?,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color:
                                  (offer['badgeColor'] as Color?)?.withOpacity(
                                    0.3,
                                  ) ??
                                  Colors.transparent,
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          (offer['badge'] as String?) ?? '',
                          style: widget.theme.textTheme.labelMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          (offer['category'] as String?) ?? '',
                          style: widget.theme.textTheme.labelSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const Spacer(),

                  // Title
                  Text(
                    (offer['title'] as String?) ?? '',
                    style: widget.theme.textTheme.headlineMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 28,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Subtitle
                  Text(
                    (offer['subtitle'] as String?) ?? '',
                    style: widget.theme.textTheme.titleLarge?.copyWith(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 18,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Description
                  Text(
                    (offer['description'] as String?) ?? '',
                    style: widget.theme.textTheme.bodyLarge?.copyWith(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 14,
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const Spacer(),

                  // Action button
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(25),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Explore Now',
                              style: widget.theme.textTheme.titleMedium
                                  ?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                            ),
                            const SizedBox(width: 8),
                            Icon(
                              Icons.arrow_forward,
                              size: 16,
                              color: Colors.white,
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      // Expiry info
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          (offer['expiry'] as String?) ?? '',
                          style: widget.theme.textTheme.bodySmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );

  Widget _buildCompactOffer(Map<String, dynamic> offer) => _buildOfferCard(
    (offer['title'] as String?) ?? '',
    (offer['subtitle'] as String?) ?? '',
    offer['icon'] as IconData,
    offer['colors'] as List<Color>,
    offer['onTap'] as VoidCallback,
    badge: offer['badge'] as String?,
    badgeColor: offer['badgeColor'] as Color?,
    isCompact: true,
  );

  Widget _buildOfferCard(
    String title,
    String subtitle,
    IconData icon,
    List<Color> colors,
    VoidCallback onTap, {
    String? badge,
    Color? badgeColor,
    bool isCompact = false,
  }) => MouseRegion(
    cursor: SystemMouseCursors.click,
    child: GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: colors,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: colors.first.withOpacity(0.2),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Background pattern
            Positioned(
              top: -15,
              right: -15,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.1),
                ),
              ),
            ),

            // Badge
            if (badge != null)
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: badgeColor ?? Colors.red,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    badge,
                    style: widget.theme.textTheme.labelSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 9,
                    ),
                  ),
                ),
              ),

            // Content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Icon
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Icon(icon, size: 20, color: Colors.white),
                  ),

                  const SizedBox(height: 12),

                  // Title
                  Text(
                    title,
                    style: widget.theme.textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: isCompact ? 14 : 16,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 4),

                  // Subtitle
                  Text(
                    subtitle,
                    style: widget.theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: isCompact ? 11 : 12,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  if (!isCompact) ...[
                    const Spacer(),
                    // Action button
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Learn More',
                            style: widget.theme.textTheme.bodySmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 10,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            Icons.arrow_forward,
                            size: 10,
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _WebHeroSection extends StatefulWidget {
  const _WebHeroSection({required this.theme});
  final ThemeData theme;

  @override
  State<_WebHeroSection> createState() => _WebHeroSectionState();
}

class _WebHeroSectionState extends State<_WebHeroSection>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _floatingController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _floatingAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _floatingController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
        );

    _floatingAnimation = Tween<double>(begin: -10, end: 10).animate(
      CurvedAnimation(parent: _floatingController, curve: Curves.easeInOut),
    );

    _animationController.forward();
    _floatingController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _floatingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth > 1400;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Column(
        children: [
          // Enhanced top navigation
          _buildEnhancedNavigation(),

          const SizedBox(height: 40),

          // Main hero content
          SlideTransition(
            position: _slideAnimation,
            child: Row(
              children: [
                // Left content - Enhanced
                Expanded(
                  flex: isLargeScreen ? 3 : 2,
                  child: _buildEnhancedLeftContent(screenWidth),
                ),

                const SizedBox(width: 40),

                // Right content - Enhanced featured preview
                Expanded(
                  flex: isLargeScreen ? 2 : 1,
                  child: _buildEnhancedFeaturedPreview(screenWidth),
                ),
              ],
            ),
          ),

          const SizedBox(height: 60),

          // Enhanced quick stats
          _buildEnhancedQuickStats(),
        ],
      ),
    );
  }

  Widget _buildEnhancedNavigation() => Row(
    children: [
      // Logo with enhanced animation
      MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: AnimatedScale(
          scale: _isHovered ? 1.05 : 1.0,
          duration: const Duration(milliseconds: 200),
          child: const AppLogo.large()
              .animate()
              .fadeIn(duration: 800.ms)
              .scale(
                begin: const Offset(0.8, 0.8),
                end: const Offset(1.0, 1.0),
              ),
        ),
      ),

      const Spacer(),

      // Enhanced navigation pills
      Row(
        children: [
          _buildEnhancedNavPill(
            'Marketplace',
            Icons.store,
            () => context.go('/marketplace'),
            isActive: true,
          ),
          const SizedBox(width: 12),
          _buildEnhancedNavPill(
            'Housing',
            Icons.home_work,
            () => context.go('/accommodation'),
          ),
          const SizedBox(width: 12),
          _buildEnhancedNavPill(
            'Events',
            Icons.event,
            () => context.go('/events'),
          ),
          const SizedBox(width: 12),
          _buildEnhancedNavPill(
            'Support',
            Icons.help_outline,
            () => context.go('/support'),
          ),
        ],
      ),
    ],
  );

  Widget _buildEnhancedNavPill(
    String label,
    IconData icon,
    VoidCallback onTap, {
    bool isActive = false,
  }) => MouseRegion(
    cursor: SystemMouseCursors.click,
    child: GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: isActive
              ? Colors.white.withOpacity(0.25)
              : Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: isActive
                ? Colors.white.withOpacity(0.5)
                : Colors.white.withOpacity(0.3),
            width: 1,
          ),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: Colors.white.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Text(
              label,
              style: widget.theme.textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    ),
  );

  Widget _buildEnhancedLeftContent(double screenWidth) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      // Welcome message with enhanced styling
      Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          return RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: 'Welcome back, ',
                      style: widget.theme.textTheme.displaySmall?.copyWith(
                        color: Colors.white.withOpacity(0.9),
                        fontWeight: FontWeight.w300,
                        fontSize: 32,
                      ),
                    ),
                    TextSpan(
                      text: authProvider.currentUser?.firstName ?? 'Student',
                      style: widget.theme.textTheme.displaySmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 32,
                      ),
                    ),
                    const TextSpan(
                      text: '! 👋',
                      style: TextStyle(fontSize: 32),
                    ),
                  ],
                ),
              )
              .animate()
              .fadeIn(delay: 200.ms, duration: 800.ms)
              .slideX(begin: -0.3, end: 0);
        },
      ),

      const SizedBox(height: 24),

      // Main headline with enhanced typography
      Text(
            'Zimbabwe\'s Premier Student Marketplace',
            style: widget.theme.textTheme.displayLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: screenWidth > 1400 ? 56 : 48,
              height: 1.1,
              letterSpacing: -0.5,
            ),
          )
          .animate()
          .fadeIn(delay: 400.ms, duration: 800.ms)
          .slideY(begin: 0.3, end: 0),

      const SizedBox(height: 20),

      // Enhanced subtitle
      Text(
            'Connect, trade, and thrive in Zimbabwe\'s vibrant university community. Buy, sell, and discover amazing items while building lasting campus relationships.',
            style: widget.theme.textTheme.headlineMedium?.copyWith(
              color: Colors.white.withOpacity(0.9),
              fontWeight: FontWeight.w400,
              fontSize: 20,
              height: 1.4,
            ),
          )
          .animate()
          .fadeIn(delay: 600.ms, duration: 800.ms)
          .slideY(begin: 0.3, end: 0),

      const SizedBox(height: 40),

      // Enhanced search bar
      _buildEnhancedSearchBar(screenWidth),

      const SizedBox(height: 40),

      // Call-to-action buttons
      Row(
        children: [
          _buildActionButton(
            'Start Selling',
            Icons.add_circle_outline,
            () => context.go('/marketplace?action=sell'),
            isPrimary: true,
          ),
          const SizedBox(width: 16),
          _buildActionButton(
            'Browse Items',
            Icons.explore_outlined,
            () => context.go('/marketplace'),
            isPrimary: false,
          ),
        ],
      ),
    ],
  );

  Widget _buildEnhancedSearchBar(double screenWidth) =>
      Container(
            width: screenWidth > 1400 ? 700 : 600,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(60),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
                BoxShadow(
                  color: widget.theme.colorScheme.primary.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search items, events, housing, textbooks...',
                      hintStyle: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                      ),
                      prefixIcon: Icon(
                        Icons.search,
                        color: widget.theme.colorScheme.primary,
                        size: 24,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 20,
                      ),
                    ),
                    onSubmitted: (value) {
                      if (value.isNotEmpty) {
                        context.go('/search?q=$value');
                      }
                    },
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(right: 8),
                  child: ElevatedButton(
                    onPressed: () {
                      // TODO: Implement search
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: widget.theme.colorScheme.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 20,
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Search',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          )
          .animate()
          .fadeIn(delay: 800.ms, duration: 800.ms)
          .slideY(begin: 0.3, end: 0);

  Widget _buildActionButton(
    String text,
    IconData icon,
    VoidCallback onTap, {
    bool isPrimary = false,
  }) =>
      MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: onTap,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  color: isPrimary
                      ? Colors.white
                      : Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 1,
                  ),
                  boxShadow: isPrimary
                      ? [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      icon,
                      color: isPrimary
                          ? widget.theme.colorScheme.primary
                          : Colors.white,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      text,
                      style: widget.theme.textTheme.titleMedium?.copyWith(
                        color: isPrimary
                            ? widget.theme.colorScheme.primary
                            : Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
          .animate()
          .fadeIn(delay: 1000.ms, duration: 600.ms)
          .slideX(begin: -0.3, end: 0);

  Widget _buildEnhancedFeaturedPreview(double screenWidth) =>
      AnimatedBuilder(
            animation: _floatingAnimation,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, _floatingAnimation.value),
                child: Container(
                  height: 400,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.2),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Header
                      Padding(
                        padding: const EdgeInsets.all(24),
                        child: Row(
                          children: [
                            Icon(
                              Icons.trending_up,
                              color: Colors.white,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Trending Now',
                              style: widget.theme.textTheme.titleLarge
                                  ?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'LIVE',
                                style: widget.theme.textTheme.labelSmall
                                    ?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 10,
                                    ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Featured items
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          itemCount: 3,
                          itemBuilder: (context, index) {
                            final items = [
                              {
                                'title': 'MacBook Pro 2023',
                                'price': 'Z\$2,500',
                                'category': 'Electronics',
                              },
                              {
                                'title': 'Textbook: Data Structures',
                                'price': 'Z\$150',
                                'category': 'Books',
                              },
                              {
                                'title': 'Room in Harare',
                                'price': 'Z\$300/mo',
                                'category': 'Housing',
                              },
                            ];

                            return Container(
                              margin: const EdgeInsets.only(bottom: 16),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.1),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 50,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      Icons.shopping_bag_outlined,
                                      color: Colors.white,
                                      size: 24,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          items[index]['title']!,
                                          style: widget
                                              .theme
                                              .textTheme
                                              .titleMedium
                                              ?.copyWith(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w600,
                                              ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          items[index]['category']!,
                                          style: widget
                                              .theme
                                              .textTheme
                                              .bodySmall
                                              ?.copyWith(
                                                color: Colors.white.withOpacity(
                                                  0.7,
                                                ),
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    items[index]['price']!,
                                    style: widget.theme.textTheme.titleMedium
                                        ?.copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),

                      // View all button
                      Padding(
                        padding: const EdgeInsets.all(24),
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () => context.go('/marketplace'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white.withOpacity(0.2),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: const Text('View All Items'),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          )
          .animate()
          .fadeIn(delay: 600.ms, duration: 800.ms)
          .slideX(begin: 0.3, end: 0);

  Widget _buildEnhancedQuickStats() =>
      Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildEnhancedQuickStat(
                '2.5K+',
                'Active Students',
                Icons.people,
                Colors.blue,
              ),
              const SizedBox(width: 40),
              _buildEnhancedQuickStat(
                '8',
                'Universities',
                Icons.school,
                Colors.green,
              ),
              const SizedBox(width: 40),
              _buildEnhancedQuickStat(
                '500+',
                'Items Listed',
                Icons.inventory,
                Colors.orange,
              ),
              const SizedBox(width: 40),
              _buildEnhancedQuickStat(
                '98%',
                'Success Rate',
                Icons.star,
                Colors.purple,
              ),
            ],
          )
          .animate()
          .fadeIn(delay: 1200.ms, duration: 800.ms)
          .slideY(begin: 0.3, end: 0);

  Widget _buildEnhancedQuickStat(
    String value,
    String label,
    IconData icon,
    Color color,
  ) => Container(
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.1),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 10,
          offset: const Offset(0, 5),
        ),
      ],
    ),
    child: Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(30),
          ),
          child: Icon(icon, color: color, size: 30),
        ),
        const SizedBox(height: 16),
        Text(
          value,
          style: widget.theme.textTheme.headlineLarge?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 32,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: widget.theme.textTheme.titleMedium?.copyWith(
            color: Colors.white.withOpacity(0.8),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    ),
  );
}
