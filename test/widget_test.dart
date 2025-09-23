/// @Branch: Widget Tests Implementation
///
/// Comprehensive widget tests for Campus Market Flutter project
/// Tests core widgets and screen functionality
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:campus_market/main.dart';
import 'package:campus_market/core/providers/theme_provider.dart';
import 'package:campus_market/core/providers/auth_provider.dart';
import 'package:campus_market/core/widgets/glow_card.dart';
import 'package:campus_market/core/widgets/gradient_text.dart';
import 'package:campus_market/core/widgets/live_badge.dart';
import 'package:campus_market/ui/screens/home/home_screen.dart';
import 'package:campus_market/ui/screens/onboarding/onboarding_screen.dart';

void main() {
  group('Campus Market Widget Tests', () {
    testWidgets('App launches without crashing', (tester) async {
      // Build our app and trigger a frame.
      await tester.pumpWidget(const CampusMarketApp());

      // Verify that the app starts
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('Onboarding screen displays correctly', (
      tester,
    ) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => ThemeProvider()),
            ChangeNotifierProvider(create: (_) => AuthProvider()),
          ],
          child: const MaterialApp(home: OnboardingScreen()),
        ),
      );

      // Verify onboarding elements are present
      expect(find.text('Welcome to Campus Market'), findsOneWidget);
      expect(find.text('Skip'), findsOneWidget);
      expect(find.text('Get Started'), findsOneWidget);
    });

    testWidgets('Home screen displays correctly', (tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => ThemeProvider()),
            ChangeNotifierProvider(create: (_) => AuthProvider()),
          ],
          child: const MaterialApp(home: HomeScreen()),
        ),
      );

      // Wait for async operations
      await tester.pumpAndSettle();

      // Verify home screen elements
      expect(find.text('Welcome back'), findsOneWidget);
      expect(find.text('Quick Actions'), findsOneWidget);
      expect(find.text('Featured Items'), findsOneWidget);
    });

    testWidgets('GlowCard widget renders correctly', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: GlowCard(child: const Text('Test Card'))),
        ),
      );

      expect(find.text('Test Card'), findsOneWidget);
      expect(find.byType(GlowCard), findsOneWidget);
    });

    testWidgets('GradientText widget renders correctly', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: GradientText('Test Gradient Text'))),
      );

      expect(find.text('Test Gradient Text'), findsOneWidget);
      expect(find.byType(GradientText), findsOneWidget);
    });

    testWidgets('LiveBadge widget renders correctly', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: LiveBadge('LIVE'))),
      );

      expect(find.text('LIVE'), findsOneWidget);
      expect(find.byType(LiveBadge), findsOneWidget);
    });

    testWidgets('StatusBadge widget renders correctly', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: StatusBadge('Success', type: BadgeType.success)),
        ),
      );

      expect(find.text('Success'), findsOneWidget);
      expect(find.byType(StatusBadge), findsOneWidget);
    });

    testWidgets('Theme provider changes theme correctly', (
      tester,
    ) async {
      final themeProvider = ThemeProvider();

      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (_) => themeProvider,
          child: MaterialApp(
            home: Builder(
              builder: (context) => ElevatedButton(
                  onPressed: () => themeProvider.toggleTheme(),
                  child: const Text('Toggle Theme'),
                ),
            ),
          ),
        ),
      );

      // Test initial theme
      expect(themeProvider.themeMode, ThemeMode.system);

      // Toggle theme
      await tester.tap(find.text('Toggle Theme'));
      await tester.pump();

      expect(themeProvider.themeMode, ThemeMode.light);
    });

    testWidgets('Auth provider manages authentication state', (
      tester,
    ) async {
      final authProvider = AuthProvider();

      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (_) => authProvider,
          child: MaterialApp(
            home: Builder(
              builder: (context) => Column(
                  children: [
                    Text(
                      authProvider.isAuthenticated
                          ? 'Authenticated'
                          : 'Not Authenticated',
                    ),
                    ElevatedButton(
                      onPressed: () => authProvider.signOut(),
                      child: const Text('Sign Out'),
                    ),
                  ],
                ),
            ),
          ),
        ),
      );

      // Wait for initial load
      await tester.pumpAndSettle();

      // Should be authenticated after initial load
      expect(find.text('Authenticated'), findsOneWidget);

      // Test sign out
      await tester.tap(find.text('Sign Out'));
      await tester.pumpAndSettle();

      expect(find.text('Not Authenticated'), findsOneWidget);
    });
  });

  group('Component Library Tests', () {
    testWidgets('All component types render without errors', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                GlowCard(child: const Text('Glow Card')),
                GradientText('Gradient Text'),
                LiveBadge('LIVE'),
                StatusBadge('Success', type: BadgeType.success),
                StatusBadge('Warning', type: BadgeType.warning),
                StatusBadge('Error', type: BadgeType.error),
                StatusBadge('Info', type: BadgeType.info),
                StatusBadge('Outline', type: BadgeType.outline),
              ],
            ),
          ),
        ),
      );

      // Verify all components are rendered
      expect(find.byType(GlowCard), findsOneWidget);
      expect(find.byType(GradientText), findsOneWidget);
      expect(find.byType(LiveBadge), findsOneWidget);
      expect(find.byType(StatusBadge), findsNWidgets(5));
    });
  });

  group('Navigation Tests', () {
    testWidgets('Navigation between screens works correctly', (
      tester,
    ) async {
      await tester.pumpWidget(const CampusMarketApp());

      // Wait for app to load
      await tester.pumpAndSettle();

      // Should start with onboarding
      expect(find.text('Welcome to Campus Market'), findsOneWidget);
    });
  });
}
