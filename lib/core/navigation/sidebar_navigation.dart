/// @Branch: Sidebar Navigation Component
///
/// Responsive sidebar navigation for web and desktop layouts
/// Includes logo, navigation items, and quick actions
/// Supports active state management and responsive design
library;

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../theme/app_spacing.dart';
import '../widgets/app_logo.dart';
import '../providers/auth_provider.dart';
import '../repositories/firebase_repository.dart';

class SidebarNavigation extends StatefulWidget {

  const SidebarNavigation({
    super.key,
    required this.currentRoute,
    this.onMenuToggle,
    this.isCollapsible = true,
    this.startCollapsed = false,
    this.autoHide = true,
    this.collapseBreakpoint = 1024.0,
  });
  final String currentRoute;
  final VoidCallback? onMenuToggle;
  final bool isCollapsible;
  final bool startCollapsed;
  final bool autoHide;
  final double collapseBreakpoint;

  @override
  State<SidebarNavigation> createState() => _SidebarNavigationState();
}

class _SidebarNavigationState extends State<SidebarNavigation>
    with SingleTickerProviderStateMixin {
  late bool _isCollapsed;
  late bool _isHidden;
  late AnimationController _animationController;
  late Animation<double> _widthAnimation;
  
  // Badge counts from database
  int _marketplaceCount = 0;
  int _accommodationCount = 0;
  int _eventsCount = 0;
  int _chatCount = 0;
  bool _isLoadingBadges = true;

  // Responsive breakpoints
  static const double tabletBreakpoint = 1024;
  static const double desktopBreakpoint = 1440;

  @override
  void initState() {
    super.initState();
    _isCollapsed = widget.startCollapsed;
    _isHidden = false;
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _widthAnimation = Tween<double>(begin: 280, end: 80).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    if (_isCollapsed) {
      _animationController.forward();
    }

    // Load badge counts from database
    _loadBadgeCounts();
  }

  Future<void> _loadBadgeCounts() async {
    try {
      setState(() {
        _isLoadingBadges = true;
      });

      // Load counts from database in parallel
      final results = await Future.wait([
        _getMarketplaceCount(),
        _getAccommodationCount(),
        _getEventsCount(),
        _getChatCount(),
      ]);

      if (mounted) {
        setState(() {
          _marketplaceCount = results[0];
          _accommodationCount = results[1];
          _eventsCount = results[2];
          _chatCount = results[3];
          _isLoadingBadges = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingBadges = false;
        });
        print('Error loading badge counts: $e');
      }
    }
  }

  Future<int> _getMarketplaceCount() async {
    try {
      final products = await FirebaseRepository.getProducts();
      return products.length;
    } catch (e) {
      print('Error loading marketplace count: $e');
      return 0;
    }
  }

  Future<int> _getAccommodationCount() async {
    try {
      final accommodations = await FirebaseRepository.getAccommodations();
      return accommodations.length;
    } catch (e) {
      print('Error loading accommodation count: $e');
      return 0;
    }
  }

  Future<int> _getEventsCount() async {
    try {
      final events = await FirebaseRepository.getEvents();
      return events.length;
    } catch (e) {
      print('Error loading events count: $e');
      return 0;
    }
  }

  Future<int> _getChatCount() async {
    try {
      // TODO: Implement getChatRooms method in FirebaseRepository
      final chatRooms = <Map<String, dynamic>>[];
      return chatRooms.length;
    } catch (e) {
      print('Error loading chat count: $e');
      return 0;
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Widget _buildBadge(ThemeData theme, String badgeText) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withOpacity(0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      constraints: const BoxConstraints(
        minWidth: 18,
        minHeight: 18,
      ),
      child: Text(
        badgeText,
        style: theme.textTheme.labelSmall?.copyWith(
          color: theme.colorScheme.onPrimary,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
        textAlign: TextAlign.center,
      ),
    );

  Widget _buildLoadingBadge(ThemeData theme) => Container(
      width: 18,
      height: 18,
      decoration: BoxDecoration(
        color: theme.colorScheme.outline.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: SizedBox(
          width: 8,
          height: 8,
          child: CircularProgressIndicator(
            strokeWidth: 1.5,
            color: theme.colorScheme.primary,
          ),
        ),
      ),
    );

  void _toggleCollapse() {
    setState(() {
      _isCollapsed = !_isCollapsed;
    });

    if (_isCollapsed) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  bool _shouldShowSidebar(BuildContext context) {
    if (!widget.autoHide) return true;

    final screenWidth = MediaQuery.of(context).size.width;
    final isWeb = kIsWeb;

    // Always show on web and desktop
    if (isWeb || screenWidth >= desktopBreakpoint) return true;

    // Show on tablet if wide enough
    if (screenWidth >= tabletBreakpoint) return true;

    // Hide on mobile
    return false;
  }

  bool _shouldCollapse(BuildContext context) {
    if (!widget.isCollapsible) return false;

    final screenWidth = MediaQuery.of(context).size.width;

    // Auto-collapse on smaller screens
    return screenWidth < widget.collapseBreakpoint;
  }

  void _updateResponsiveState(BuildContext context) {
    final shouldShow = _shouldShowSidebar(context);
    final shouldCollapse = _shouldCollapse(context);

    if (shouldShow != !_isHidden) {
      setState(() {
        _isHidden = !shouldShow;
      });
    }

    if (shouldCollapse != _isCollapsed) {
      _toggleCollapse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Update responsive state
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateResponsiveState(context);
    });

    // Hide sidebar if not needed
    if (_isHidden) {
      return const SizedBox.shrink();
    }

    return AnimatedBuilder(
      animation: _widthAnimation,
      builder: (context, child) => Container(
          width: _widthAnimation.value,
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            border: Border(
              right: BorderSide(
                color: theme.colorScheme.outline.withOpacity(0.2),
                width: 1,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(2, 0),
              ),
            ],
          ),
          child: Column(
            children: [
              // Logo/Header Section
              _buildHeader(theme, _isCollapsed),

              // Navigation Items
              Expanded(
                child: _buildNavigationItems(context, theme, _isCollapsed),
              ),

              // User Profile Section
              _buildUserProfile(context, theme, _isCollapsed),

              // Quick Actions
              _buildQuickActions(context, theme, _isCollapsed),
            ],
          ),
        ),
    );
  }

  Widget _buildHeader(ThemeData theme, bool isCollapsed) => Container(
      padding: EdgeInsets.all(isCollapsed ? AppSpacing.md : AppSpacing.lg),
      child: Column(
        children: [
          // Header with toggle button
          Row(
            children: [
              if (isCollapsed)
                Flexible(
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.school,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                )
              else
                Expanded(
                  child: Column(
                    children: [
                      const AppLogo.medium(),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        'Campus Market',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Zimbabwe',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),

              // Toggle button
              if (widget.isCollapsible)
                IconButton(
                  onPressed: _toggleCollapse,
                  icon: Icon(
                    isCollapsed ? Icons.menu : Icons.menu_open,
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                  tooltip: isCollapsed ? 'Expand sidebar' : 'Collapse sidebar',
                ),
            ],
          ),
        ],
      ),
    );

  Widget _buildNavigationItems(
    BuildContext context,
    ThemeData theme,
    bool isCollapsed,
  ) {
    final navigationItems = [
      NavigationItem(
        icon: Icons.home_outlined,
        activeIcon: Icons.home,
        label: 'Home',
        route: '/home',
      ),
      NavigationItem(
        icon: Icons.store_outlined,
        activeIcon: Icons.store,
        label: 'Marketplace',
        route: '/marketplace',
        badge: _isLoadingBadges ? 'loading' : _marketplaceCount > 0 ? _marketplaceCount.toString() : null,
      ),
      NavigationItem(
        icon: Icons.home_work_outlined,
        activeIcon: Icons.home_work,
        label: 'Housing',
        route: '/accommodation',
        badge: _isLoadingBadges ? 'loading' : _accommodationCount > 0 ? _accommodationCount.toString() : null,
      ),
      NavigationItem(
        icon: Icons.event_outlined,
        activeIcon: Icons.event,
        label: 'Events',
        route: '/events',
        badge: _isLoadingBadges ? 'loading' : _eventsCount > 0 ? _eventsCount.toString() : null,
      ),
      NavigationItem(
        icon: Icons.chat_outlined,
        activeIcon: Icons.chat,
        label: 'Chat',
        route: '/chat',
        badge: _isLoadingBadges ? 'loading' : _chatCount > 0 ? _chatCount.toString() : null,
      ),
    ];

    final secondaryItems = [
      NavigationItem(
        icon: Icons.person_outline,
        activeIcon: Icons.person,
        label: 'Profile',
        route: '/profile',
        isSecondary: true,
      ),
      NavigationItem(
        icon: Icons.settings_outlined,
        activeIcon: Icons.settings,
        label: 'Settings',
        route: '/settings',
        isSecondary: true,
      ),
    ];

    return ListView(
      padding: EdgeInsets.symmetric(
        horizontal: isCollapsed ? AppSpacing.sm : AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      children: [
        // Main navigation items
        ...navigationItems.map((item) {
          final isActive = widget.currentRoute.startsWith(item.route);
          return _buildNavigationItem(
            context,
            theme,
            item,
            isActive,
            isCollapsed,
          );
        }),

        // Divider
        if (!isCollapsed) ...[
          const SizedBox(height: AppSpacing.md),
          Divider(color: theme.colorScheme.outline.withOpacity(0.2), height: 1),
          const SizedBox(height: AppSpacing.md),
        ],

        // Secondary navigation items
        ...secondaryItems.map((item) {
          final isActive = widget.currentRoute.startsWith(item.route);
          return _buildNavigationItem(
            context,
            theme,
            item,
            isActive,
            isCollapsed,
          );
        }),
      ],
    );
  }

  Widget _buildNavigationItem(
    BuildContext context,
    ThemeData theme,
    NavigationItem item,
    bool isActive,
    bool isCollapsed,
  ) => Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: ListTile(
        leading: Stack(
          children: [
            Icon(
              isActive ? item.activeIcon : item.icon,
              color: isActive
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurface.withOpacity(0.7),
              size: isCollapsed ? 20 : 24,
            ),
            if (item.badge != null && !isCollapsed)
              Positioned(
                right: -2,
                top: -2,
                child: item.badge == 'loading' 
                    ? _buildLoadingBadge(theme)
                    : _buildBadge(theme, item.badge!),
              ),
          ],
        ),
        title: isCollapsed
            ? null
            : Row(
                children: [
                  Expanded(
                    child: Text(
                      item.label,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: isActive
                            ? theme.colorScheme.primary
                            : theme.colorScheme.onSurface,
                        fontWeight: isActive
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                    ),
                  ),
                  if (item.badge != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        item.badge!,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.primary,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
        selected: isActive,
        selectedTileColor: isActive
            ? theme.colorScheme.primary.withOpacity(0.1)
            : (item.isSecondary
                  ? theme.colorScheme.surface
                  : theme.colorScheme.surface),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        ),
        onTap: () => context.go(item.route),
        hoverColor: theme.colorScheme.primary.withOpacity(0.05),
      ),
    );

  Widget _buildQuickActions(
    BuildContext context,
    ThemeData theme,
    bool isCollapsed,
  ) => Container(
      padding: EdgeInsets.all(isCollapsed ? AppSpacing.sm : AppSpacing.md),
      child: Column(
        children: [
          if (!isCollapsed) ...[
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => context.go('/marketplace/create'),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Sell Item'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => context.go('/accommodation/create'),
                icon: const Icon(Icons.home_work_outlined, size: 18),
                label: const Text('List Room'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                ),
              ),
            ),
          ] else ...[
            // Collapsed quick actions
            _buildCollapsedAction(
              context,
              theme,
              Icons.add,
              'Sell Item',
              () => context.go('/marketplace/create'),
            ),
            const SizedBox(height: AppSpacing.sm),
            _buildCollapsedAction(
              context,
              theme,
              Icons.home_work_outlined,
              'List Room',
              () => context.go('/accommodation/create'),
            ),
          ],
        ],
      ),
    );

  Widget _buildUserProfile(
    BuildContext context,
    ThemeData theme,
    bool isCollapsed,
  ) => Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final user = authProvider.currentUser;
        final isAuthenticated = authProvider.isAuthenticated;

        if (!isAuthenticated || user == null) {
          return Container(
            padding: EdgeInsets.all(
              isCollapsed ? AppSpacing.sm : AppSpacing.md,
            ),
            child: Column(
              children: [
                if (!isCollapsed) ...[
                  // Sign in prompt
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: theme.colorScheme.outline.withOpacity(
                          0.1,
                        ),
                        child: Icon(
                          Icons.person_outline,
                          color: theme.colorScheme.outline,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Sign in to continue',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              'Access your account',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurface.withOpacity(
                                  0.7,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => context.go('/sign-in'),
                        icon: Icon(
                          Icons.login,
                          color: theme.colorScheme.primary,
                          size: 20,
                        ),
                        tooltip: 'Sign In',
                      ),
                    ],
                  ),
                ] else ...[
                  // Collapsed sign in
                  IconButton(
                    onPressed: () => context.go('/sign-in'),
                    icon: Icon(
                      Icons.login,
                      color: theme.colorScheme.primary,
                      size: 20,
                    ),
                    tooltip: 'Sign In',
                  ),
                ],
              ],
            ),
          );
        }

        // Get user's full name and university
        final fullName = '${user.firstName} ${user.lastName}'.trim();
        final displayName = fullName.isNotEmpty
            ? fullName
            : user.email.split('@').first;
        final university = user.university ?? 'No University Set';

        return Container(
          padding: EdgeInsets.all(isCollapsed ? AppSpacing.sm : AppSpacing.md),
          child: Column(
            children: [
              if (!isCollapsed) ...[
                // User info
                Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: theme.colorScheme.primary.withOpacity(
                        0.1,
                      ),
                      backgroundImage: user.profileImageUrl != null
                          ? NetworkImage(user.profileImageUrl!)
                          : null,
                      child: user.profileImageUrl == null
                          ? Icon(
                              Icons.person,
                              color: theme.colorScheme.primary,
                              size: 20,
                            )
                          : null,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            displayName,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            university,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface.withOpacity(
                                0.7,
                              ),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    PopupMenuButton<String>(
                      icon: Icon(
                        Icons.more_vert,
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                        size: 20,
                      ),
                      onSelected: (value) {
                        switch (value) {
                          case 'profile':
                            context.go('/profile');
                            break;
                          case 'settings':
                            context.go('/settings');
                            break;
                          case 'logout':
                            authProvider.signOut();
                            break;
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'profile',
                          child: Text('Profile'),
                        ),
                        const PopupMenuItem(
                          value: 'settings',
                          child: Text('Settings'),
                        ),
                        const PopupMenuDivider(),
                        const PopupMenuItem(
                          value: 'logout',
                          child: Text('Logout'),
                        ),
                      ],
                    ),
                  ],
                ),
              ] else ...[
                // Collapsed user profile
                PopupMenuButton<String>(
                  child: CircleAvatar(
                    radius: 20,
                    backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                    backgroundImage: user.profileImageUrl != null
                        ? NetworkImage(user.profileImageUrl!)
                        : null,
                    child: user.profileImageUrl == null
                        ? Icon(
                            Icons.person,
                            color: theme.colorScheme.primary,
                            size: 20,
                          )
                        : null,
                  ),
                  onSelected: (value) {
                    switch (value) {
                      case 'profile':
                        context.go('/profile');
                        break;
                      case 'settings':
                        context.go('/settings');
                        break;
                      case 'logout':
                        authProvider.signOut();
                        break;
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'info',
                      enabled: false,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            displayName,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            university,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface.withOpacity(
                                0.7,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const PopupMenuDivider(),
                    const PopupMenuItem(
                      value: 'profile',
                      child: Text('Profile'),
                    ),
                    const PopupMenuItem(
                      value: 'settings',
                      child: Text('Settings'),
                    ),
                    const PopupMenuDivider(),
                    const PopupMenuItem(value: 'logout', child: Text('Logout')),
                  ],
                ),
              ],
            ],
          ),
        );
      },
    );

  Widget _buildCollapsedAction(
    BuildContext context,
    ThemeData theme,
    IconData icon,
    String tooltip,
    VoidCallback onTap,
  ) => Tooltip(
      message: tooltip,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: theme.colorScheme.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        ),
        child: IconButton(
          onPressed: onTap,
          icon: Icon(icon, color: theme.colorScheme.primary, size: 20),
        ),
      ),
    );
}

class NavigationItem {

  NavigationItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.route,
    this.badge,
    this.isSecondary = false,
  });
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final String route;
  final String? badge;
  final bool isSecondary;
}
