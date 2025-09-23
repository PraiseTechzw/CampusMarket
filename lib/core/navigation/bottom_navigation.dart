/// @Branch: Bottom Navigation Component
///
/// Mobile-first bottom navigation bar
/// Provides quick access to main app sections
/// Supports active state management and navigation
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../theme/app_spacing.dart';

class BottomNavigation extends StatelessWidget {

  const BottomNavigation({super.key, required this.currentRoute});
  final String currentRoute;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: theme.colorScheme.outline.withOpacity(0.2),
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // User info section (only show if authenticated)
            Consumer<AuthProvider>(
              builder: (context, authProvider, child) {
                if (!authProvider.isAuthenticated ||
                    authProvider.currentUser == null) {
                  return const SizedBox.shrink();
                }

                final user = authProvider.currentUser!;
                final fullName = '${user.firstName} ${user.lastName}'.trim();
                final displayName = fullName.isNotEmpty
                    ? fullName
                    : user.email.split('@').first;
                final university = user.university ?? 'No University Set';

                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.05),
                    border: Border(
                      bottom: BorderSide(
                        color: theme.colorScheme.outline.withOpacity(0.1),
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 16,
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
                                size: 16,
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
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: theme.colorScheme.onSurface,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              university,
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.colorScheme.onSurface.withOpacity(
                                  0.7,
                                ),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => context.go('/profile'),
                        icon: Icon(
                          Icons.person_outline,
                          color: theme.colorScheme.primary,
                          size: 20,
                        ),
                        tooltip: 'Profile',
                      ),
                    ],
                  ),
                );
              },
            ),
            // Bottom navigation bar
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xs,
              ),
              child: BottomNavigationBar(
                type: BottomNavigationBarType.fixed,
                currentIndex: _getCurrentIndex(currentRoute),
                onTap: (index) => _onTap(context, index),
                backgroundColor: Colors.transparent,
                elevation: 0,
                selectedItemColor: theme.colorScheme.primary,
                unselectedItemColor: theme.colorScheme.onSurface.withOpacity(
                  0.6,
                ),
                selectedLabelStyle: theme.textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                unselectedLabelStyle: theme.textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.normal,
                ),
                items: const [
                  BottomNavigationBarItem(
                    icon: Icon(Icons.home_outlined),
                    activeIcon: Icon(Icons.home),
                    label: 'Home',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.store_outlined),
                    activeIcon: Icon(Icons.store),
                    label: 'Marketplace',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.home_work_outlined),
                    activeIcon: Icon(Icons.home_work),
                    label: 'Housing',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.event_outlined),
                    activeIcon: Icon(Icons.event),
                    label: 'Events',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.chat_outlined),
                    activeIcon: Icon(Icons.chat),
                    label: 'Chat',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  int _getCurrentIndex(String location) {
    if (location.startsWith('/home')) return 0;
    if (location.startsWith('/marketplace')) return 1;
    if (location.startsWith('/accommodation')) return 2;
    if (location.startsWith('/events')) return 3;
    if (location.startsWith('/chat')) return 4;
    return 0;
  }

  void _onTap(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go('/home');
        break;
      case 1:
        context.go('/marketplace');
        break;
      case 2:
        context.go('/accommodation');
        break;
      case 3:
        context.go('/events');
        break;
      case 4:
        context.go('/chat');
        break;
    }
  }
}

/// Extended bottom navigation with additional features
class ExtendedBottomNavigation extends StatelessWidget {

  const ExtendedBottomNavigation({
    super.key,
    required this.currentRoute,
    this.showFloatingActionButton = true,
  });
  final String currentRoute;
  final bool showFloatingActionButton;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Stack(
      children: [
        // Main bottom navigation
        BottomNavigation(currentRoute: currentRoute),

        // Floating Action Button
        if (showFloatingActionButton)
          Positioned(
            top: -20,
            left: 0,
            right: 0,
            child: Center(
              child: FloatingActionButton(
                onPressed: () => context.go('/marketplace/create'),
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: Colors.white,
                elevation: 4,
                child: const Icon(Icons.add),
              ),
            ),
          ),
      ],
    );
  }
}

/// Bottom navigation with custom styling
class CustomBottomNavigation extends StatelessWidget {

  const CustomBottomNavigation({
    super.key,
    required this.currentRoute,
    required this.items,
    this.backgroundColor,
    this.selectedColor,
    this.unselectedColor,
  });
  final String currentRoute;
  final List<BottomNavigationItem> items;
  final Color? backgroundColor;
  final Color? selectedColor;
  final Color? unselectedColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: backgroundColor ?? theme.colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: theme.colorScheme.outline.withOpacity(0.2),
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.xs,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: items.asMap().entries.map((entry) {
              final item = entry.value;
              final isSelected = _isSelected(item.route);

              return Expanded(
                child: GestureDetector(
                  onTap: () => context.go(item.route),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.sm,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isSelected ? item.activeIcon : item.icon,
                          color: isSelected
                              ? (selectedColor ?? theme.colorScheme.primary)
                              : (unselectedColor ??
                                    theme.colorScheme.onSurface.withOpacity(
                                      0.6,
                                    )),
                          size: 24,
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          item.label,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: isSelected
                                ? (selectedColor ?? theme.colorScheme.primary)
                                : (unselectedColor ??
                                      theme.colorScheme.onSurface.withOpacity(
                                        0.6,
                                      )),
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  bool _isSelected(String route) => currentRoute.startsWith(route);
}

class BottomNavigationItem {

  BottomNavigationItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.route,
  });
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final String route;
}
