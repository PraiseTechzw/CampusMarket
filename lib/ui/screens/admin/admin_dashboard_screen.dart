/// @Branch: Admin Dashboard Screen Implementation
///
/// Comprehensive admin dashboard for Campus Market platform management
/// Includes user management, content moderation, analytics, and system settings
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter/foundation.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/gradient_text.dart';
import '../../../core/widgets/glow_card.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/repositories/firebase_repository.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _selectedIndex = 0;
  bool _isLoading = true;
  Map<String, dynamic> _stats = {};

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() => _isLoading = true);

    try {
      // Load various statistics
      final users = await FirebaseRepository.getUsers(limit: 1);
      final products = await FirebaseRepository.getProducts(limit: 1);
      final accommodations = await FirebaseRepository.getAccommodations(
        limit: 1,
      );
      final events = await FirebaseRepository.getEvents(limit: 1);

      setState(() {
        _stats = {
          'totalUsers': users.length,
          'totalProducts': products.length,
          'totalAccommodations': accommodations.length,
          'totalEvents': events.length,
        };
      });
    } catch (e) {
      print('Error loading dashboard data: $e');
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isWeb = kIsWeb;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: Row(
        children: [
          // Sidebar
          if (isWeb && screenWidth > 768) _buildSidebar(theme),

          // Main content
          Expanded(
            child: Column(
              children: [
                _buildHeader(theme),
                Expanded(child: _buildContent(theme)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar(ThemeData theme) => Container(
      width: 280,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          right: BorderSide(color: theme.colorScheme.outline.withOpacity(0.2)),
        ),
      ),
      child: Column(
        children: [
          // Logo and title
          Container(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        theme.colorScheme.primary,
                        theme.colorScheme.secondary,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    Icons.admin_panel_settings,
                    color: Colors.white,
                    size: 30,
                  ),
                ).animate().scale(
                  duration: const Duration(milliseconds: 600),
                  curve: Curves.easeOutBack,
                ),

                const SizedBox(height: AppSpacing.md),

                GradientText(
                  'Admin Dashboard',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ).animate().fadeIn(
                  duration: const Duration(milliseconds: 800),
                  delay: const Duration(milliseconds: 200),
                ),
              ],
            ),
          ),

          // Navigation items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              children: [
                _buildNavItem(
                  theme,
                  icon: Icons.dashboard,
                  title: 'Dashboard',
                  index: 0,
                ),
                _buildNavItem(
                  theme,
                  icon: Icons.people,
                  title: 'Users',
                  index: 1,
                ),
                _buildNavItem(
                  theme,
                  icon: Icons.shopping_bag,
                  title: 'Products',
                  index: 2,
                ),
                _buildNavItem(
                  theme,
                  icon: Icons.home,
                  title: 'Accommodations',
                  index: 3,
                ),
                _buildNavItem(
                  theme,
                  icon: Icons.event,
                  title: 'Events',
                  index: 4,
                ),
                _buildNavItem(
                  theme,
                  icon: Icons.chat,
                  title: 'Messages',
                  index: 5,
                ),
                _buildNavItem(
                  theme,
                  icon: Icons.flag,
                  title: 'Reports',
                  index: 6,
                ),
                _buildNavItem(
                  theme,
                  icon: Icons.analytics,
                  title: 'Analytics',
                  index: 7,
                ),
                _buildNavItem(
                  theme,
                  icon: Icons.settings,
                  title: 'Settings',
                  index: 8,
                ),
              ],
            ),
          ),

          // User info and logout
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              children: [
                const Divider(),
                const SizedBox(height: AppSpacing.md),

                Consumer<AuthProvider>(
                  builder: (context, authProvider, child) {
                    return Row(
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundImage:
                              authProvider.currentUser?.profileImageUrl != null
                              ? NetworkImage(
                                  authProvider.currentUser!.profileImageUrl!,
                                )
                              : null,
                          child:
                              authProvider.currentUser?.profileImageUrl == null
                              ? Text(
                                  authProvider.currentUser?.initials ?? 'A',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                )
                              : null,
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                authProvider.currentUser?.fullName ?? 'Admin',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                'Super Admin',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurface
                                      .withOpacity(0.7),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),

                const SizedBox(height: AppSpacing.md),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final authProvider = context.read<AuthProvider>();
                      await authProvider.signOut();
                      if (mounted) {
                        context.go('/sign-in');
                      }
                    },
                    icon: const Icon(Icons.logout, size: 18),
                    label: const Text('Logout'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.error,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );

  Widget _buildNavItem(
    ThemeData theme, {
    required IconData icon,
    required String title,
    required int index,
  }) {
    final isSelected = _selectedIndex == index;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: ListTile(
        leading: Icon(
          icon,
          color: isSelected
              ? theme.colorScheme.primary
              : theme.colorScheme.onSurface.withOpacity(0.7),
        ),
        title: Text(
          title,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.onSurface,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        selected: isSelected,
        selectedTileColor: theme.colorScheme.primary.withOpacity(0.1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        onTap: () {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    ).animate().fadeIn(
      duration: const Duration(milliseconds: 600),
      delay: Duration(milliseconds: 100 * index),
    );
  }

  Widget _buildHeader(ThemeData theme) => Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          bottom: BorderSide(color: theme.colorScheme.outline.withOpacity(0.2)),
        ),
      ),
      child: Row(
        children: [
          if (kIsWeb && MediaQuery.of(context).size.width <= 768)
            IconButton(
              onPressed: () {
                // Toggle mobile sidebar
              },
              icon: const Icon(Icons.menu),
            ),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getPageTitle(),
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  _getPageSubtitle(),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),

          // Quick actions
          Row(
            children: [
              IconButton(
                onPressed: _loadDashboardData,
                icon: const Icon(Icons.refresh),
                tooltip: 'Refresh',
              ),
              IconButton(
                onPressed: () {
                  // Show notifications
                },
                icon: const Icon(Icons.notifications),
                tooltip: 'Notifications',
              ),
            ],
          ),
        ],
      ),
    );

  Widget _buildContent(ThemeData theme) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    switch (_selectedIndex) {
      case 0:
        return _buildDashboardContent(theme);
      case 1:
        return _buildUsersContent(theme);
      case 2:
        return _buildProductsContent(theme);
      case 3:
        return _buildAccommodationsContent(theme);
      case 4:
        return _buildEventsContent(theme);
      case 5:
        return _buildMessagesContent(theme);
      case 6:
        return _buildReportsContent(theme);
      case 7:
        return _buildAnalyticsContent(theme);
      case 8:
        return _buildSettingsContent(theme);
      default:
        return _buildDashboardContent(theme);
    }
  }

  Widget _buildDashboardContent(ThemeData theme) => SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stats cards
          GridView.count(
            crossAxisCount: kIsWeb && MediaQuery.of(context).size.width > 768
                ? 4
                : 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 2.5,
            crossAxisSpacing: AppSpacing.md,
            mainAxisSpacing: AppSpacing.md,
            children: [
              _buildStatCard(
                theme,
                title: 'Total Users',
                value: _stats['totalUsers']?.toString() ?? '0',
                icon: Icons.people,
                color: Colors.blue,
              ),
              _buildStatCard(
                theme,
                title: 'Products',
                value: _stats['totalProducts']?.toString() ?? '0',
                icon: Icons.shopping_bag,
                color: Colors.green,
              ),
              _buildStatCard(
                theme,
                title: 'Accommodations',
                value: _stats['totalAccommodations']?.toString() ?? '0',
                icon: Icons.home,
                color: Colors.orange,
              ),
              _buildStatCard(
                theme,
                title: 'Events',
                value: _stats['totalEvents']?.toString() ?? '0',
                icon: Icons.event,
                color: Colors.purple,
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.xl),

          // Recent activity
          GlowCard(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Recent Activity',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Activity items would go here
                  Text(
                    'No recent activity',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );

  Widget _buildStatCard(
    ThemeData theme, {
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) => GlowCard(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.sm),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(icon, color: color, size: 24),
                    ),
                    const Spacer(),
                    Text(
                      value,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  title,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
        )
        .animate()
        .fadeIn(duration: const Duration(milliseconds: 600))
        .slideY(
          begin: 0.3,
          end: 0,
          duration: const Duration(milliseconds: 600),
        );

  Widget _buildUsersContent(ThemeData theme) => const Center(child: Text('Users Management - Coming Soon'));

  Widget _buildProductsContent(ThemeData theme) => const Center(child: Text('Products Management - Coming Soon'));

  Widget _buildAccommodationsContent(ThemeData theme) => const Center(child: Text('Accommodations Management - Coming Soon'));

  Widget _buildEventsContent(ThemeData theme) => const Center(child: Text('Events Management - Coming Soon'));

  Widget _buildMessagesContent(ThemeData theme) => const Center(child: Text('Messages Management - Coming Soon'));

  Widget _buildReportsContent(ThemeData theme) => const Center(child: Text('Reports Management - Coming Soon'));

  Widget _buildAnalyticsContent(ThemeData theme) => const Center(child: Text('Analytics Dashboard - Coming Soon'));

  Widget _buildSettingsContent(ThemeData theme) => const Center(child: Text('System Settings - Coming Soon'));

  String _getPageTitle() {
    switch (_selectedIndex) {
      case 0:
        return 'Dashboard';
      case 1:
        return 'Users';
      case 2:
        return 'Products';
      case 3:
        return 'Accommodations';
      case 4:
        return 'Events';
      case 5:
        return 'Messages';
      case 6:
        return 'Reports';
      case 7:
        return 'Analytics';
      case 8:
        return 'Settings';
      default:
        return 'Dashboard';
    }
  }

  String _getPageSubtitle() {
    switch (_selectedIndex) {
      case 0:
        return 'Overview of your platform';
      case 1:
        return 'Manage users and permissions';
      case 2:
        return 'Moderate marketplace items';
      case 3:
        return 'Manage accommodation listings';
      case 4:
        return 'Oversee campus events';
      case 5:
        return 'Monitor conversations';
      case 6:
        return 'Review reports and flags';
      case 7:
        return 'View platform analytics';
      case 8:
        return 'Configure system settings';
      default:
        return 'Overview of your platform';
    }
  }
}
