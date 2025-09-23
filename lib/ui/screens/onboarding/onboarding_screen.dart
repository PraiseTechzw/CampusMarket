/// @Branch: Onboarding Screen Implementation
///
/// Welcome and student verification onboarding flow
/// Provides skip option and modern onboarding experience
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/gradient_text.dart';
import '../../../core/providers/auth_provider.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingPage> _pages = [
    OnboardingPage(
      title: 'Welcome to Campus Market',
      subtitle: "Zimbabwe's Premier Student Marketplace",
      description:
          "Connect with fellow students across Zimbabwe's universities. Buy, sell, and discover amazing items while building lasting campus relationships.",
      imagePath:
          'assets/onboarding/Campus Connect Logo - Yellow Accent (1).png',
      icon: Icons.store,
      color: const Color(0xFF4CAF50),
    ),
    OnboardingPage(
      title: 'Find Your Perfect Home',
      subtitle: 'Student Accommodation Made Easy',
      description:
          'Browse verified accommodation listings near your university. Find roommates, check availability, and secure your ideal student housing in Zimbabwe.',
      imagePath: 'assets/onboarding/Welcoming Accommodation App Icons.png',
      icon: Icons.home_work,
      color: const Color(0xFF2196F3),
    ),
    OnboardingPage(
      title: 'Join Campus Events',
      subtitle: 'Never Miss Campus Life',
      description:
          "Discover exciting events happening across Zimbabwe's campuses. From study groups to cultural festivals, stay connected with your university community.",
      imagePath: 'assets/onboarding/Onboarding Icon Discover Campus Events.png',
      icon: Icons.event,
      color: const Color(0xFFFF9800),
    ),
    OnboardingPage(
      title: 'Connect & Chat',
      subtitle: 'Build Meaningful Relationships',
      description:
          'Chat with sellers, hosts, and event organizers. Build lasting friendships and make your university experience in Zimbabwe truly unforgettable.',
      imagePath:
          'assets/onboarding/Onboarding Icon for Campus Engagement App.png',
      icon: Icons.chat,
      color: const Color(0xFF9C27B0),
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isWeb = kIsWeb;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: SafeArea(
        child: isWeb && screenWidth > 768
            ? _buildWebLayout(theme, screenWidth)
            : _buildMobileLayout(theme),
      ),
    );
  }

  Widget _buildWebLayout(ThemeData theme, double screenWidth) => Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.primary.withOpacity(0.05),
            theme.colorScheme.secondary.withOpacity(0.03),
          ],
        ),
      ),
      child: Row(
        children: [
          // Left side - Content
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.xxxl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Skip button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () async {
                          final authProvider = context.read<AuthProvider>();
                          await authProvider.markOnboardingCompleted();
                          if (mounted) {
                            context.go('/sign-in');
                          }
                        },
                        child: Text(
                          'Skip',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  // Page content
                  Expanded(
                    child: SingleChildScrollView(
                      child: _buildWebPageContent(theme),
                    ),
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  // Navigation - Fixed height
                  SizedBox(height: 80, child: _buildWebNavigation(theme)),
                ],
              ),
            ),
          ),

          // Right side - Image
          Expanded(
            flex: 1,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    _pages[_currentPage].color.withOpacity(0.1),
                    _pages[_currentPage].color.withOpacity(0.05),
                  ],
                ),
              ),
              child: Center(child: _buildWebImage(theme)),
            ),
          ),
        ],
      ),
    );

  Widget _buildMobileLayout(ThemeData theme) => Column(
      children: [
        // Skip button
        Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () async {
                  final authProvider = context.read<AuthProvider>();
                  await authProvider.markOnboardingCompleted();
                  if (mounted) {
                    context.go('/sign-in');
                  }
                },
                child: Text(
                  'Skip',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Page view
        Expanded(
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemCount: _pages.length,
            itemBuilder: (context, index) {
              return _buildPage(_pages[index]);
            },
          ),
        ),

        // Page indicators and navigation
        Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            children: [
              // Enhanced page indicators
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _pages.length,
                  (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    margin: const EdgeInsets.symmetric(horizontal: 6),
                    width: _currentPage == index ? 32 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      gradient: _currentPage == index
                          ? LinearGradient(
                              colors: [
                                _pages[index].color,
                                _pages[index].color.withOpacity(0.7),
                              ],
                            )
                          : null,
                      color: _currentPage == index
                          ? null
                          : theme.colorScheme.outline.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(4),
                      boxShadow: _currentPage == index
                          ? [
                              BoxShadow(
                                color: _pages[index].color.withOpacity(0.4),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : null,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.xl),

              // Enhanced navigation buttons
              Row(
                children: [
                  if (_currentPage > 0)
                    Expanded(
                      child: Container(
                        height: 56,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(28),
                          border: Border.all(
                            color: theme.colorScheme.outline.withOpacity(0.3),
                            width: 1.5,
                          ),
                        ),
                        child: OutlinedButton(
                          onPressed: () {
                            _pageController.previousPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          },
                          style: OutlinedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(28),
                            ),
                            side: BorderSide.none,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.arrow_back_ios,
                                size: 16,
                                color: theme.colorScheme.onSurface,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Previous',
                                style: theme.textTheme.labelLarge?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                  if (_currentPage > 0) const SizedBox(width: AppSpacing.md),

                  Expanded(
                    child: Container(
                      height: 56,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            _pages[_currentPage].color,
                            _pages[_currentPage].color.withOpacity(0.8),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: [
                          BoxShadow(
                            color: _pages[_currentPage].color.withOpacity(0.4),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: () async {
                          if (_currentPage < _pages.length - 1) {
                            _pageController.nextPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          } else {
                            final authProvider = context.read<AuthProvider>();
                            await authProvider.markOnboardingCompleted();
                            if (mounted) {
                              context.go('/sign-in');
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _currentPage < _pages.length - 1
                                  ? 'Next'
                                  : 'Get Started',
                              style: theme.textTheme.labelLarge?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(
                              _currentPage < _pages.length - 1
                                  ? Icons.arrow_forward_ios
                                  : Icons.rocket_launch,
                              size: 16,
                              color: Colors.white,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );

  Widget _buildPage(OnboardingPage page) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight:
                MediaQuery.of(context).size.height -
                MediaQuery.of(context).padding.top -
                MediaQuery.of(context).padding.bottom -
                (AppSpacing.xl * 2) - // Top and bottom padding
                200, // Space for navigation buttons
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Image with enhanced styling
              Container(
                    width: MediaQuery.of(context).size.width < 400 ? 180 : 220,
                    height: MediaQuery.of(context).size.width < 400 ? 180 : 220,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          page.color.withOpacity(0.1),
                          page.color.withOpacity(0.05),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(110),
                      boxShadow: [
                        BoxShadow(
                          color: page.color.withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(110),
                      child: Image.asset(
                        page.imagePath,
                        width: 220,
                        height: 220,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          // Fallback to icon if image fails to load
                          return DecoratedBox(
                            decoration: BoxDecoration(
                              color: page.color.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(110),
                            ),
                            child: Icon(
                              page.icon,
                              size: 100,
                              color: page.color,
                            ),
                          );
                        },
                      ),
                    ),
                  )
                  .animate()
                  .scale(
                    duration: const Duration(milliseconds: 800),
                    curve: Curves.elasticOut,
                  )
                  .fadeIn(duration: const Duration(milliseconds: 600)),

              SizedBox(
                height: MediaQuery.of(context).size.height < 700
                    ? AppSpacing.xl
                    : AppSpacing.xxxl,
              ),

              // Title
              GradientText(
                    page.title,
                    style: theme.textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  )
                  .animate()
                  .fadeIn(
                    duration: const Duration(milliseconds: 800),
                    delay: const Duration(milliseconds: 200),
                  )
                  .slideY(
                    begin: 0.3,
                    end: 0,
                    duration: const Duration(milliseconds: 800),
                    delay: const Duration(milliseconds: 200),
                  ),

              SizedBox(
                height: MediaQuery.of(context).size.height < 700
                    ? AppSpacing.sm
                    : AppSpacing.md,
              ),

              // Subtitle
              Text(
                    page.subtitle,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  )
                  .animate()
                  .fadeIn(
                    duration: const Duration(milliseconds: 800),
                    delay: const Duration(milliseconds: 400),
                  )
                  .slideY(
                    begin: 0.3,
                    end: 0,
                    duration: const Duration(milliseconds: 800),
                    delay: const Duration(milliseconds: 400),
                  ),

              SizedBox(
                height: MediaQuery.of(context).size.height < 700
                    ? AppSpacing.md
                    : AppSpacing.lg,
              ),

              // Description
              Text(
                    page.description,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                      height: 1.6,
                    ),
                    textAlign: TextAlign.center,
                  )
                  .animate()
                  .fadeIn(
                    duration: const Duration(milliseconds: 800),
                    delay: const Duration(milliseconds: 600),
                  )
                  .slideY(
                    begin: 0.3,
                    end: 0,
                    duration: const Duration(milliseconds: 800),
                    delay: const Duration(milliseconds: 600),
                  ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWebPageContent(ThemeData theme) {
    final page = _pages[_currentPage];
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenHeight < 800;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 500),
      child: Column(
        key: ValueKey(_currentPage),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Page indicator
          Row(
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [page.color, page.color.withOpacity(0.7)],
                  ),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${_currentPage + 1} of ${_pages.length}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ],
          ),

          SizedBox(height: isSmallScreen ? AppSpacing.xl : AppSpacing.xxxl),

          // Title
          GradientText(
                page.title,
                style: theme.textTheme.displayLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: isSmallScreen ? 36 : 48,
                ),
              )
              .animate()
              .fadeIn(
                duration: const Duration(milliseconds: 800),
                delay: const Duration(milliseconds: 200),
              )
              .slideX(
                begin: -0.3,
                end: 0,
                duration: const Duration(milliseconds: 800),
                delay: const Duration(milliseconds: 200),
              ),

          SizedBox(height: isSmallScreen ? AppSpacing.md : AppSpacing.lg),

          // Subtitle
          Text(
                page.subtitle,
                style: theme.textTheme.headlineMedium?.copyWith(
                  color: page.color,
                  fontWeight: FontWeight.w600,
                  fontSize: isSmallScreen ? 20 : 24,
                ),
              )
              .animate()
              .fadeIn(
                duration: const Duration(milliseconds: 800),
                delay: const Duration(milliseconds: 400),
              )
              .slideX(
                begin: -0.3,
                end: 0,
                duration: const Duration(milliseconds: 800),
                delay: const Duration(milliseconds: 400),
              ),

          SizedBox(height: isSmallScreen ? AppSpacing.lg : AppSpacing.xl),

          // Description
          Text(
                page.description,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.8),
                  height: 1.8,
                  fontSize: isSmallScreen ? 16 : 18,
                ),
              )
              .animate()
              .fadeIn(
                duration: const Duration(milliseconds: 800),
                delay: const Duration(milliseconds: 600),
              )
              .slideX(
                begin: -0.3,
                end: 0,
                duration: const Duration(milliseconds: 800),
                delay: const Duration(milliseconds: 600),
              ),
        ],
      ),
    );
  }

  Widget _buildWebImage(ThemeData theme) {
    final page = _pages[_currentPage];

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 500),
      child:
          Container(
                key: ValueKey(_currentPage),
                width: 400,
                height: 400,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      page.color.withOpacity(0.1),
                      page.color.withOpacity(0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(200),
                  boxShadow: [
                    BoxShadow(
                      color: page.color.withOpacity(0.2),
                      blurRadius: 40,
                      offset: const Offset(0, 20),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(200),
                  child: Image.asset(
                    page.imagePath,
                    width: 400,
                    height: 400,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                        decoration: BoxDecoration(
                          color: page.color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(200),
                        ),
                        child: Icon(page.icon, size: 200, color: page.color),
                      ),
                  ),
                ),
              )
              .animate()
              .scale(
                duration: const Duration(milliseconds: 800),
                curve: Curves.elasticOut,
              )
              .fadeIn(duration: const Duration(milliseconds: 600)),
    );
  }

  Widget _buildWebNavigation(ThemeData theme) => Row(
      children: [
        // Page indicators
        Row(
          children: List.generate(
            _pages.length,
            (index) => AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              margin: const EdgeInsets.only(right: 12),
              width: _currentPage == index ? 40 : 8,
              height: 8,
              decoration: BoxDecoration(
                gradient: _currentPage == index
                    ? LinearGradient(
                        colors: [
                          _pages[index].color,
                          _pages[index].color.withOpacity(0.7),
                        ],
                      )
                    : null,
                color: _currentPage == index
                    ? null
                    : theme.colorScheme.outline.withOpacity(0.3),
                borderRadius: BorderRadius.circular(4),
                boxShadow: _currentPage == index
                    ? [
                        BoxShadow(
                          color: _pages[index].color.withOpacity(0.4),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
            ),
          ),
        ),

        const Spacer(),

        // Navigation buttons
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_currentPage > 0)
              Container(
                height: 56,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                    color: theme.colorScheme.outline.withOpacity(0.3),
                    width: 1.5,
                  ),
                ),
                child: OutlinedButton(
                  onPressed: () {
                    print(
                      'Web Previous button pressed - Current page: $_currentPage',
                    );
                    if (_currentPage > 0) {
                      setState(() {
                        _currentPage--;
                      });
                    }
                  },
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                    side: BorderSide.none,
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.arrow_back_ios,
                        size: 16,
                        color: theme.colorScheme.onSurface,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Previous',
                        style: theme.textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            if (_currentPage > 0) const SizedBox(width: AppSpacing.md),

            Container(
              height: 56,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    _pages[_currentPage].color,
                    _pages[_currentPage].color.withOpacity(0.8),
                  ],
                ),
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: _pages[_currentPage].color.withOpacity(0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: () async {
                  print(
                    'Web Next button pressed - Current page: $_currentPage',
                  );
                  if (_currentPage < _pages.length - 1) {
                    setState(() {
                      _currentPage++;
                    });
                  } else {
                    print('Web: Navigating to sign-in');
                    final authProvider = context.read<AuthProvider>();
                    await authProvider.markOnboardingCompleted();
                    if (mounted) {
                      context.go('/sign-in');
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _currentPage < _pages.length - 1 ? 'Next' : 'Get Started',
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      _currentPage < _pages.length - 1
                          ? Icons.arrow_forward_ios
                          : Icons.rocket_launch,
                      size: 16,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
}

class OnboardingPage {

  OnboardingPage({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.imagePath,
    required this.icon,
    required this.color,
  });
  final String title;
  final String subtitle;
  final String description;
  final String imagePath;
  final IconData icon;
  final Color color;
}
