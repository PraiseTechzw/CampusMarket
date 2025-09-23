/// @Branch: Help & Support Screen Implementation
///
/// Comprehensive help system with FAQ, contact options, and support tickets
/// Includes search functionality and categorized help topics
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_spacing.dart';

class HelpSupportScreen extends StatefulWidget {
  const HelpSupportScreen({super.key});

  @override
  State<HelpSupportScreen> createState() => _HelpSupportScreenState();
}

class _HelpSupportScreenState extends State<HelpSupportScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedCategory = 'all';

  final List<Map<String, dynamic>> _categories = [
    {'id': 'all', 'name': 'All Topics', 'icon': Icons.all_inclusive},
    {
      'id': 'getting_started',
      'name': 'Getting Started',
      'icon': Icons.play_circle,
    },
    {'id': 'marketplace', 'name': 'Marketplace', 'icon': Icons.store},
    {'id': 'accommodation', 'name': 'Housing', 'icon': Icons.home},
    {'id': 'events', 'name': 'Events', 'icon': Icons.event},
    {'id': 'account', 'name': 'Account', 'icon': Icons.person},
    {'id': 'payment', 'name': 'Payment', 'icon': Icons.payment},
    {'id': 'technical', 'name': 'Technical', 'icon': Icons.build},
  ];

  final List<Map<String, dynamic>> _faqs = [
    {
      'id': '1',
      'category': 'getting_started',
      'question': 'How do I create an account?',
      'answer':
          'To create an account, tap the "Sign Up" button on the welcome screen. You can sign up using your email address or social media accounts. Make sure to verify your email address to complete the registration process.',
    },
    {
      'id': '2',
      'category': 'marketplace',
      'question': 'How do I list an item for sale?',
      'answer':
          'To list an item, go to the Marketplace tab and tap the "+" button. Fill in the item details including title, description, price, and photos. Choose the appropriate category and condition, then publish your listing.',
    },
    {
      'id': '3',
      'category': 'marketplace',
      'question': 'How do I contact a seller?',
      'answer':
          'You can contact a seller by tapping the "Contact Seller" button on any product page. This will open a chat where you can ask questions about the item.',
    },
    {
      'id': '4',
      'category': 'accommodation',
      'question': 'How do I find accommodation?',
      'answer':
          'Go to the Housing tab and use the search filters to find accommodation that matches your needs. You can filter by location, price range, room type, and amenities.',
    },
    {
      'id': '5',
      'category': 'accommodation',
      'question': 'How do I book a room?',
      'answer':
          'Once you find a suitable accommodation, tap "Book Now" and select your check-in and check-out dates. Review the booking details and confirm your reservation.',
    },
    {
      'id': '6',
      'category': 'events',
      'question': 'How do I create an event?',
      'answer':
          'Go to the Events tab and tap the "+" button to create a new event. Fill in the event details including title, description, date, time, location, and ticket information.',
    },
    {
      'id': '7',
      'category': 'events',
      'question': 'How do I RSVP to an event?',
      'answer':
          'On any event page, tap the "RSVP" button and select the number of tickets you need. Complete the RSVP process and you\'ll receive a confirmation.',
    },
    {
      'id': '8',
      'category': 'account',
      'question': 'How do I update my profile?',
      'answer':
          'Go to your Profile tab and tap "Edit Profile". You can update your personal information, university details, and profile picture.',
    },
    {
      'id': '9',
      'category': 'payment',
      'question': 'What payment methods are accepted?',
      'answer':
          'We accept all major credit cards, debit cards, and digital wallets. Payment is processed securely through our payment partners.',
    },
    {
      'id': '10',
      'category': 'technical',
      'question': 'The app is not loading properly. What should I do?',
      'answer':
          'Try closing and reopening the app. If the problem persists, check your internet connection and make sure you have the latest version of the app installed.',
    },
  ];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
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
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> _getFilteredFAQs() {
    List<Map<String, dynamic>> filtered = _faqs;

    // Filter by category
    if (_selectedCategory != 'all') {
      filtered = filtered
          .where((faq) => faq['category'] == _selectedCategory)
          .toList();
    }

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((faq) {
        final question = faq['question'].toString().toLowerCase();
        final answer = faq['answer'].toString().toLowerCase();
        final query = _searchQuery.toLowerCase();
        return question.contains(query) || answer.contains(query);
      }).toList();
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
        'Help & Support',
        style: theme.textTheme.headlineSmall?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
    );

  Widget _buildBody(ThemeData theme) => AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Search Bar
                _buildSearchBar(theme),

                const SizedBox(height: AppSpacing.xl),

                // Quick Actions
                _buildQuickActions(theme),

                const SizedBox(height: AppSpacing.xl),

                // Categories
                _buildCategoriesSection(theme),

                const SizedBox(height: AppSpacing.xl),

                // FAQ Section
                _buildFAQSection(theme),

                const SizedBox(height: AppSpacing.xl),

                // Contact Support
                _buildContactSection(theme),
              ],
            ),
          ),
        );
      },
    );

  Widget _buildSearchBar(ThemeData theme) => Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search help topics...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _searchQuery = '';
                    });
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
        ),
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
      ),
    );

  Widget _buildQuickActions(ThemeData theme) {
    final actions = [
      {
        'title': 'Contact Support',
        'subtitle': 'Get help from our team',
        'icon': Icons.support_agent,
        'color': Colors.blue,
        'onTap': () => _showContactOptions(theme),
      },
      {
        'title': 'Report a Bug',
        'subtitle': 'Help us improve the app',
        'icon': Icons.bug_report,
        'color': Colors.red,
        'onTap': () => _showBugReport(theme),
      },
      {
        'title': 'Feature Request',
        'subtitle': 'Suggest new features',
        'icon': Icons.lightbulb,
        'color': Colors.orange,
        'onTap': () => _showFeatureRequest(theme),
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: actions
              .map(
                (action) => Expanded(
                  child: _buildQuickActionCard(
                    theme,
                    action as Map<String, dynamic>,
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  Widget _buildQuickActionCard(ThemeData theme, Map<String, dynamic> action) =>
      Container(
        margin: const EdgeInsets.only(right: AppSpacing.sm),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.shadow.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: action['onTap'] as VoidCallback?,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: (action['color'] as Color).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      action['icon'] as IconData,
                      color: action['color'] as Color,
                      size: 24,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    action['title'] as String,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    action['subtitle'] as String,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      );

  Widget _buildCategoriesSection(ThemeData theme) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'Help Categories',
        style: theme.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
      const SizedBox(height: AppSpacing.md),
      Wrap(
        spacing: AppSpacing.sm,
        runSpacing: AppSpacing.sm,
        children: _categories
            .map((category) => _buildCategoryChip(theme, category))
            .toList(),
      ),
    ],
  );

  Widget _buildCategoryChip(ThemeData theme, Map<String, dynamic> category) {
    final isSelected = _selectedCategory == (category['id'] as String);

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCategory = category['id'] as String;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary
              : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
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
              category['icon'] as IconData,
              size: 16,
              color: isSelected
                  ? theme.colorScheme.onPrimary
                  : theme.colorScheme.outline,
            ),
            const SizedBox(width: AppSpacing.xs),
            Text(
              category['name'] as String,
              style: theme.textTheme.bodySmall?.copyWith(
                color: isSelected
                    ? theme.colorScheme.onPrimary
                    : theme.colorScheme.onSurface,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFAQSection(ThemeData theme) {
    final filteredFAQs = _getFilteredFAQs();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Frequently Asked Questions',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        if (filteredFAQs.isEmpty)
          _buildEmptyState(theme)
        else
          ...filteredFAQs.map((faq) => _buildFAQItem(theme, faq)),
      ],
    );
  }

  Widget _buildEmptyState(ThemeData theme) => Container(
    padding: const EdgeInsets.all(AppSpacing.xl),
    decoration: BoxDecoration(
      color: theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: theme.colorScheme.outline.withOpacity(0.2)),
    ),
    child: Column(
      children: [
        Icon(Icons.search_off, size: 48, color: theme.colorScheme.outline),
        const SizedBox(height: AppSpacing.md),
        Text(
          'No FAQs found',
          style: theme.textTheme.titleMedium?.copyWith(
            color: theme.colorScheme.outline,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Try adjusting your search or category filter',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.outline,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    ),
  );

  Widget _buildFAQItem(ThemeData theme, Map<String, dynamic> faq) => Container(
    margin: const EdgeInsets.only(bottom: AppSpacing.sm),
    decoration: BoxDecoration(
      color: theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: theme.colorScheme.shadow.withOpacity(0.1),
          blurRadius: 8,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: ExpansionTile(
      title: Text(
        faq['question'] as String,
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            0,
            AppSpacing.lg,
            AppSpacing.lg,
          ),
          child: Text(
            faq['answer'] as String,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.outline,
              height: 1.5,
            ),
          ),
        ),
      ],
    ),
  );

  Widget _buildContactSection(ThemeData theme) => Container(
    padding: const EdgeInsets.all(AppSpacing.lg),
    decoration: BoxDecoration(
      color: theme.colorScheme.primary.withOpacity(0.1),
      borderRadius: BorderRadius.circular(16),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.support_agent,
              color: theme.colorScheme.primary,
              size: 24,
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              'Still need help?',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Our support team is here to help you with any questions or issues you might have.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.8),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _showContactOptions(theme),
                icon: const Icon(Icons.email),
                label: const Text('Email Support'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: theme.colorScheme.primary,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _showContactOptions(theme),
                icon: const Icon(Icons.chat),
                label: const Text('Live Chat'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                ),
              ),
            ),
          ],
        ),
      ],
    ),
  );

  void _showContactOptions(ThemeData theme) {
    showModalBottomSheet<void>(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Contact Support',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            _buildContactOption(
              theme,
              'Email Support',
              'support@campusmarket.com',
              Icons.email,
              () => Navigator.pop(context),
            ),
            _buildContactOption(
              theme,
              'Live Chat',
              'Available 24/7',
              Icons.chat,
              () => Navigator.pop(context),
            ),
            _buildContactOption(
              theme,
              'Phone Support',
              '+1 (555) 123-4567',
              Icons.phone,
              () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactOption(
    ThemeData theme,
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
  ) => ListTile(
    leading: Icon(icon, color: theme.colorScheme.primary),
    title: Text(title),
    subtitle: Text(subtitle),
    onTap: onTap,
  );

  void _showBugReport(ThemeData theme) {
    // TODO: Implement bug report functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Bug report feature coming soon')),
    );
  }

  void _showFeatureRequest(ThemeData theme) {
    // TODO: Implement feature request functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Feature request feature coming soon')),
    );
  }
}
