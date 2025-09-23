/// @Branch: Unit Tests Implementation
///
/// Unit tests for Campus Market Flutter project
/// Tests utility functions, theme conversions, and business logic
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:campus_market/core/theme/app_theme.dart';
import 'package:campus_market/core/theme/app_colors.dart';
import 'package:campus_market/core/theme/app_spacing.dart';
import 'package:campus_market/core/theme/app_text_styles.dart';
import 'package:campus_market/core/providers/theme_provider.dart';
import 'package:campus_market/core/providers/auth_provider.dart';
import 'package:campus_market/core/models/user.dart';
import 'package:campus_market/core/models/marketplace_item.dart';
import 'package:campus_market/core/models/accommodation.dart';
import 'package:campus_market/core/models/event.dart';
import 'package:campus_market/core/models/chat.dart';

void main() {
  group('Theme Tests', () {
    test('AppTheme provides correct light theme', () {
      final theme = AppTheme.lightTheme;

      expect(theme.brightness, Brightness.light);
      expect(theme.colorScheme.primary, AppColors.primary);
      expect(theme.useMaterial3, true);
    });

    test('AppTheme provides correct dark theme', () {
      final theme = AppTheme.darkTheme;

      expect(theme.brightness, Brightness.dark);
      expect(theme.colorScheme.primary, AppColors.primaryDark);
      expect(theme.useMaterial3, true);
    });

    test('AppColors provides correct color values', () {
      expect(AppColors.primary, const Color(0xFF16A34A));
      expect(AppColors.primaryLight, const Color(0xFF22C55E));
      expect(AppColors.primaryDark, const Color(0xFF15803D));
      expect(AppColors.success, const Color(0xFF16A34A));
      expect(AppColors.warning, const Color(0xFFF59E0B));
      expect(AppColors.error, const Color(0xFFDC2626));
    });

    test('AppColors utility methods work correctly', () {
      final color = AppColors.primary;

      expect(AppColors.withOpacity(color, 0.5), color.withOpacity(0.5));
      expect(AppColors.darken(color), isA<Color>());
      expect(AppColors.lighten(color), isA<Color>());
    });

    test('AppSpacing provides correct values', () {
      expect(AppSpacing.xs, 4.0);
      expect(AppSpacing.sm, 8.0);
      expect(AppSpacing.md, 16.0);
      expect(AppSpacing.lg, 24.0);
      expect(AppSpacing.xl, 32.0);
      expect(AppSpacing.xxl, 48.0);
    });

    test('AppSpacing responsive method works correctly', () {
      expect(AppSpacing.responsive(10, 20, 30, 500), 10); // Mobile
      expect(AppSpacing.responsive(10, 20, 30, 800), 20); // Tablet
      expect(AppSpacing.responsive(10, 20, 30, 1200), 30); // Desktop
    });

    test('AppTextStyles provides correct text styles', () {
      expect(AppTextStyles.displayLarge.fontSize, 32);
      expect(AppTextStyles.displayMedium.fontSize, 28);
      expect(AppTextStyles.headlineLarge.fontSize, 22);
      expect(AppTextStyles.titleLarge.fontSize, 16);
      expect(AppTextStyles.bodyLarge.fontSize, 16);
      expect(AppTextStyles.bodySmall.fontSize, 12);
    });

    test('AppTextStyles utility methods work correctly', () {
      final style = AppTextStyles.bodyLarge;
      final color = Colors.red;

      expect(AppTextStyles.withColor(style, color).color, color);
      expect(
        AppTextStyles.withOpacity(style, 0.5).color,
        style.color?.withOpacity(0.5),
      );
      expect(
        AppTextStyles.withWeight(style, FontWeight.bold).fontWeight,
        FontWeight.bold,
      );
      expect(AppTextStyles.withSize(style, 20).fontSize, 20);
    });
  });

  group('Theme Provider Tests', () {
    test('ThemeProvider initializes with correct default values', () {
      final provider = ThemeProvider();

      expect(provider.themeMode, ThemeMode.system);
      expect(provider.locale.languageCode, 'en');
    });

    test('ThemeProvider toggles theme correctly', () {
      final provider = ThemeProvider();

      // Test toggle from system to light
      provider.toggleTheme();
      expect(provider.themeMode, ThemeMode.light);

      // Test toggle from light to dark
      provider.toggleTheme();
      expect(provider.themeMode, ThemeMode.dark);

      // Test toggle from dark to system
      provider.toggleTheme();
      expect(provider.themeMode, ThemeMode.system);
    });

    test('ThemeProvider sets theme mode correctly', () {
      final provider = ThemeProvider();

      provider.setThemeMode(ThemeMode.light);
      expect(provider.themeMode, ThemeMode.light);

      provider.setThemeMode(ThemeMode.dark);
      expect(provider.themeMode, ThemeMode.dark);
    });

    test('ThemeProvider sets locale correctly', () {
      final provider = ThemeProvider();

      provider.setLocale(const Locale('es'));
      expect(provider.locale.languageCode, 'es');

      provider.setLocale(const Locale('fr'));
      expect(provider.locale.languageCode, 'fr');
    });
  });

  group('Auth Provider Tests', () {
    test('AuthProvider initializes with correct default values', () {
      final provider = AuthProvider();

      expect(provider.currentUser, null);
      expect(provider.isLoading, false);
      expect(provider.error, null);
      expect(provider.isAuthenticated, false);
    });

    test('AuthProvider sign in works correctly', () async {
      final provider = AuthProvider();

      final result = await provider.signIn('test@example.com', 'password123');

      expect(result, true);
      expect(provider.isAuthenticated, true);
      expect(provider.currentUser, isNotNull);
    });

    test('AuthProvider sign up works correctly', () async {
      final provider = AuthProvider();

      final result = await provider.signUp(
        'newuser@example.com',
        'password123',
        'John',
        'Doe',
        'University of Zimbabwe',
      );

      expect(result, true);
      expect(provider.isAuthenticated, true);
      expect(provider.currentUser?.email, 'newuser@example.com');
      expect(provider.currentUser?.firstName, 'John');
      expect(provider.currentUser?.lastName, 'Doe');
    });

    test('AuthProvider sign out works correctly', () async {
      final provider = AuthProvider();

      // First sign in
      await provider.signIn('test@example.com', 'password123');
      expect(provider.isAuthenticated, true);

      // Then sign out
      await provider.signOut();
      expect(provider.isAuthenticated, false);
      expect(provider.currentUser, null);
    });
  });

  group('User Model Tests', () {
    test('User model creates correctly', () {
      final user = User(
        id: '1',
        email: 'test@example.com',
        firstName: 'John',
        lastName: 'Doe',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        preferences: const UserPreferences(privacy: PrivacySettings()),
      );

      expect(user.id, '1');
      expect(user.email, 'test@example.com');
      expect(user.fullName, 'John Doe');
      expect(user.initials, 'JD');
    });

    test('User model copyWith works correctly', () {
      final user = User(
        id: '1',
        email: 'test@example.com',
        firstName: 'John',
        lastName: 'Doe',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        preferences: const UserPreferences(privacy: PrivacySettings()),
      );

      final updatedUser = user.copyWith(firstName: 'Jane', lastName: 'Smith');

      expect(updatedUser.firstName, 'Jane');
      expect(updatedUser.lastName, 'Smith');
      expect(updatedUser.email, 'test@example.com'); // Unchanged
    });
  });

  group('Marketplace Item Model Tests', () {
    test('MarketplaceItem model creates correctly', () {
      final item = MarketplaceItem(
        id: '1',
        title: 'Test Item',
        description: 'Test Description',
        price: 100,
        images: ['image1.jpg', 'image2.jpg'],
        category: 'Electronics',
        subcategory: 'Laptops',
        condition: 'new',
        userId: 'seller1',
        sellerName: 'John Doe',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(item.id, '1');
      expect(item.title, 'Test Item');
      expect(item.formattedPrice, 'USD 100.00');
      expect(item.primaryImage, 'image1.jpg');
      expect(item.hasMultipleImages, true);
    });

    test('MarketplaceItem timeAgo works correctly', () {
      final now = DateTime.now();
      final item = MarketplaceItem(
        id: '1',
        title: 'Test Item',
        description: 'Test Description',
        price: 100,
        images: ['image1.jpg'],
        category: 'Electronics',
        subcategory: 'Laptops',
        condition: 'new',
        userId: 'seller1',
        sellerName: 'John Doe',
        createdAt: now.subtract(const Duration(minutes: 5)),
        updatedAt: now,
      );

      expect(item.timeAgo, '5m ago');
    });
  });

  group('Accommodation Model Tests', () {
    test('Accommodation model creates correctly', () {
      final accommodation = Accommodation(
        id: '1',
        title: 'Test Room',
        description: 'Test Description',
        price: 500,
        imageUrls: ['room1.jpg'],
        type: 'studio',
        bedrooms: 1,
        bathrooms: 1,
        hostId: 'host1',
        hostName: 'Jane Smith',
        address: '123 Main St',
        latitude: 37.7749,
        longitude: -122.4194,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(accommodation.id, '1');
      expect(accommodation.title, 'Test Room');
      expect(accommodation.formattedPrice, 'USD 500/month');
      expect(accommodation.roomInfo, '1 bed, 1 bath');
    });
  });

  group('Event Model Tests', () {
    test('Event model creates correctly', () {
      final event = Event(
        id: '1',
        title: 'Test Event',
        description: 'Test Description',
        startDate: DateTime.now().add(const Duration(days: 1)),
        endDate: DateTime.now().add(const Duration(days: 1, hours: 2)),
        location: 'Test Location',
        organizerId: 'org1',
        organizerName: 'Event Organizer',
        type: EventType.social,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(event.id, '1');
      expect(event.title, 'Test Event');
      expect(event.formattedPrice, 'Free');
      expect(event.isLive, false);
      expect(event.isUpcoming, true);
    });
  });

  group('Chat Model Tests', () {
    test('ChatRoom model creates correctly', () {
      final chatRoom = ChatRoom(
        id: '1',
        name: 'Test Chat',
        type: ChatType.direct,
        participantIds: ['user1', 'user2'],
        participants: [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(chatRoom.id, '1');
      expect(chatRoom.name, 'Test Chat');
      expect(chatRoom.displayName, 'Test Chat');
      expect(chatRoom.unreadCount, 0);
    });

    test('Message model creates correctly', () {
      final message = Message(
        id: '1',
        chatRoomId: 'chat1',
        senderId: 'user1',
        senderName: 'John Doe',
        content: 'Hello world',
        timestamp: DateTime.now(),
      );

      expect(message.id, '1');
      expect(message.content, 'Hello world');
      expect(message.isRead, false);
    });
  });
}








