/// @Branch: App Router Implementation
///
/// GoRouter configuration for Campus Market navigation
/// Handles all app routes and navigation logic
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../ui/screens/accommodation/accommodation_detail_screen.dart';
import '../../ui/screens/accommodation/accommodation_list_screen.dart';
import '../../ui/screens/accommodation/create_accommodation_screen.dart';
import '../../ui/screens/accommodation/my_bookings_screen.dart';
import '../../ui/screens/admin/admin_dashboard_screen.dart';
import '../../ui/screens/admin/admin_login_screen.dart';
import '../../ui/screens/auth/email_verification_screen.dart';
import '../../ui/screens/auth/reset_password_screen.dart';
import '../../ui/screens/auth/sign_in_screen.dart';
import '../../ui/screens/auth/sign_up_screen.dart';
import '../../ui/screens/chat/chat_detail_screen.dart';
import '../../ui/screens/chat/chat_list_screen.dart';
import '../../ui/screens/chat/new_chat_screen.dart';
import '../../ui/screens/component_library/component_library_screen.dart';
import '../../ui/screens/events/create_event_screen.dart';
import '../../ui/screens/events/event_detail_screen.dart';
import '../../ui/screens/events/events_list_screen.dart';
import '../../ui/screens/home/home_screen.dart';
import '../../ui/screens/legal/privacy_policy_screen.dart';
import '../../ui/screens/legal/terms_of_service_screen.dart';
import '../../ui/screens/marketplace/create_marketplace_screen.dart';
import '../../ui/screens/marketplace/marketplace_list_screen.dart';
import '../../ui/screens/marketplace/product_detail_screen.dart';
import '../../ui/screens/onboarding/onboarding_screen.dart';
import '../../ui/screens/profile/edit_profile_screen.dart';
import '../../ui/screens/profile/my_listings_screen.dart';
import '../../ui/screens/profile/payment_methods_screen.dart';
import '../../ui/screens/profile/profile_screen.dart';
import '../../ui/screens/profile/saved_items_screen.dart';
import '../../ui/screens/search/search_screen.dart';
import '../../ui/screens/settings/settings_screen.dart';
import '../../ui/screens/splash/splash_screen.dart';
import '../../ui/screens/support/help_support_screen.dart';
import '../models/user.dart';
import '../navigation/main.dart';
import '../providers/auth_provider.dart';

class AppRouter {
  static int _redirectCount = 0;
  static String? _lastRedirectPath;

  static GoRouter createRouter(AuthProvider authProvider) => GoRouter(
    initialLocation: '/splash',
    debugLogDiagnostics: false,
    refreshListenable: authProvider,
    routes: [
      // Splash Screen
      GoRoute(
        path: '/splash',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),

      // Onboarding
      GoRoute(
        path: '/onboarding',
        name: 'onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),

      // Authentication
      GoRoute(
        path: '/sign-in',
        name: 'sign-in',
        builder: (context, state) => const SignInScreen(),
      ),
      GoRoute(
        path: '/sign-up',
        name: 'sign-up',
        builder: (context, state) => const SignUpScreen(),
      ),
      GoRoute(
        path: '/reset-password',
        name: 'reset-password',
        builder: (context, state) {
          final email = state.uri.queryParameters['email'] ?? '';
          final token = state.uri.queryParameters['token'];
          return ResetPasswordScreen(email: email, token: token);
        },
      ),
      GoRoute(
        path: '/email-verification',
        name: 'email-verification',
        builder: (context, state) {
          final email = state.uri.queryParameters['email'] ?? '';
          return EmailVerificationScreen(email: email);
        },
      ),

      // Main App
      ShellRoute(
        builder: (context, state, child) =>
            MainShell(currentRoute: state.uri.path, child: child),
        routes: [
          // Home
          GoRoute(
            path: '/home',
            name: 'home',
            builder: (context, state) => const HomeScreen(),
          ),

          // Marketplace
          GoRoute(
            path: '/marketplace',
            name: 'marketplace',
            builder: (context, state) => const MarketplaceListScreen(),
          ),
          GoRoute(
            path: '/marketplace/create',
            name: 'create-listing',
            builder: (context, state) {
              // TODO: Handle edit functionality by fetching item by ID from query parameters
              // final itemId = state.uri.queryParameters['id'];
              return const CreateMarketplaceScreen();
            },
          ),
          GoRoute(
            path: '/marketplace/:id',
            name: 'product-detail',
            builder: (context, state) {
              final id = state.pathParameters['id']!;
              return ProductDetailScreen(itemId: id);
            },
          ),

          // Accommodation
          GoRoute(
            path: '/accommodation',
            name: 'accommodation',
            builder: (context, state) => const AccommodationListScreen(),
          ),
          GoRoute(
            path: '/accommodation/create',
            name: 'create-accommodation',
            builder: (context, state) => const CreateAccommodationScreen(),
          ),
          GoRoute(
            path: '/accommodation/:id',
            name: 'accommodation-detail',
            builder: (context, state) {
              final id = state.pathParameters['id']!;
              return AccommodationDetailScreen(accommodationId: id);
            },
          ),

          // Events
          GoRoute(
            path: '/events',
            name: 'events',
            builder: (context, state) => const EventsListScreen(),
          ),
          GoRoute(
            path: '/events/create',
            name: 'create-event',
            builder: (context, state) => const CreateEventScreen(),
          ),
          GoRoute(
            path: '/events/:id',
            name: 'event-detail',
            builder: (context, state) {
              final id = state.pathParameters['id']!;
              return EventDetailScreen(eventId: id);
            },
          ),

          // Chat
          GoRoute(
            path: '/chat',
            name: 'chat',
            builder: (context, state) => const ChatListScreen(),
          ),
          GoRoute(
            path: '/chat/new',
            name: 'new-chat',
            builder: (context, state) => const NewChatScreen(),
          ),
          GoRoute(
            path: '/chat/:id',
            name: 'chat-detail',
            builder: (context, state) {
              final id = state.pathParameters['id']!;
              return ChatDetailScreen(chatRoomId: id);
            },
          ),

          // Profile
          GoRoute(
            path: '/profile',
            name: 'profile',
            builder: (context, state) => const ProfileScreen(),
          ),
          GoRoute(
            path: '/profile/edit',
            name: 'edit-profile',
            builder: (context, state) => const EditProfileScreen(),
          ),
          GoRoute(
            path: '/profile/my-listings',
            name: 'my-listings',
            builder: (context, state) => const MyListingsScreen(),
          ),
          GoRoute(
            path: '/profile/saved-items',
            name: 'saved-items',
            builder: (context, state) => const SavedItemsScreen(),
          ),
          GoRoute(
            path: '/profile/payment-methods',
            name: 'payment-methods',
            builder: (context, state) => const PaymentMethodsScreen(),
          ),
          GoRoute(
            path: '/profile/my-bookings',
            name: 'my-bookings',
            builder: (context, state) => const MyBookingsScreen(),
          ),
          GoRoute(
            path: '/profile/event-tickets',
            name: 'event-tickets',
            builder: (context, state) =>
                const EventsListScreen(), // Using events list for now
          ),

          // Settings
          GoRoute(
            path: '/settings',
            name: 'settings',
            builder: (context, state) => const SettingsScreen(),
          ),

          // Help & Support
          GoRoute(
            path: '/help',
            name: 'help-support',
            builder: (context, state) => const HelpSupportScreen(),
          ),

          // Search
          GoRoute(
            path: '/search',
            name: 'search',
            builder: (context, state) {
              final query = state.uri.queryParameters['q'] ?? '';
              return SearchScreen(
                initialQuery: query.isNotEmpty ? query : null,
              );
            },
          ),

          // Component Library
          GoRoute(
            path: '/components',
            name: 'component-library',
            builder: (context, state) => const ComponentLibraryScreen(),
          ),
        ],
      ),

      // Admin Routes
      GoRoute(
        path: '/admin/login',
        name: 'admin-login',
        builder: (context, state) => const AdminLoginScreen(),
      ),
      GoRoute(
        path: '/admin',
        name: 'admin-dashboard',
        builder: (context, state) => const AdminDashboardScreen(),
        redirect: (context, state) {
          // Check if user is admin
          final authProvider = context.read<AuthProvider>();
          if (authProvider.currentUser?.role != UserRole.admin) {
            return '/admin/login';
          }
          return null;
        },
      ),

      // Legal Pages
      GoRoute(
        path: '/terms-of-service',
        name: 'terms-of-service',
        builder: (context, state) => const TermsOfServiceScreen(),
      ),
      GoRoute(
        path: '/privacy-policy',
        name: 'privacy-policy',
        builder: (context, state) => const PrivacyPolicyScreen(),
      ),
    ],
    redirect: (context, state) {
      final authProvider = context.read<AuthProvider>();
      final isLoading = authProvider.isLoading;
      final isAuthenticated = authProvider.isAuthenticated;
      final hasCompletedOnboarding = authProvider.hasCompletedOnboarding;
      final isEmailVerified = authProvider.isEmailVerified;
      final isInErrorState = authProvider.isInErrorState;
      final currentPath = state.uri.path;
      final isSplash = currentPath == '/splash';
      final isOnboarding = currentPath == '/onboarding';
      final isEmailVerification = currentPath == '/email-verification';
      final isAuthRoute =
          currentPath.startsWith('/sign-') ||
          currentPath.startsWith('/reset-password') ||
          currentPath.startsWith('/admin/login');

      // Public routes that don't require authentication
      final isPublicRoute =
          currentPath == '/terms-of-service' ||
          currentPath == '/privacy-policy';

      // Prevent infinite redirect loops
      if (_lastRedirectPath == currentPath) {
        _redirectCount++;
        if (_redirectCount > 3) {
          print(
            '  -> Preventing infinite redirect loop, staying on $currentPath',
          );
          _redirectCount = 0;
          _lastRedirectPath = null;
          return null;
        }
      } else {
        _redirectCount = 0;
        _lastRedirectPath = currentPath;
      }

      print('Router redirect check:');
      print('  Path: $currentPath');
      print('  isLoading: $isLoading');
      print('  isAuthenticated: $isAuthenticated');
      print('  hasCompletedOnboarding: $hasCompletedOnboarding');
      print('  isInErrorState: $isInErrorState');

      // Always allow splash screen to load
      if (isSplash) {
        print('  -> Allowing splash screen');
        return null;
      }

      // If still loading auth state, prevent navigation loops by staying put
      if (isLoading) {
        print('  -> Auth still loading, staying on current route');
        return null;
      }

      // If in error state on auth route, stay put to show error
      if (isInErrorState && isAuthRoute) {
        print('  -> In error state on auth route, staying to show error');
        return null;
      }

      // Handle unauthenticated users
      if (!isAuthenticated) {
        // If on public route, allow it (this should be checked first)
        if (isPublicRoute) {
          print('  -> Allowing unauthenticated user on public route');
          return null;
        }

        // If on auth route, allow it (including sign-up with errors)
        if (isAuthRoute) {
          print('  -> Allowing unauthenticated user on auth route');
          return null;
        }

        // If onboarding not completed, go to onboarding
        if (!hasCompletedOnboarding && !isOnboarding) {
          print('  -> Redirecting to onboarding (not completed)');
          return '/onboarding';
        }

        // If onboarding completed but not on auth route, go to sign-in
        if (hasCompletedOnboarding && !isOnboarding) {
          print('  -> Redirecting to sign-in (onboarding completed)');
          return '/sign-in';
        }

        // Allow onboarding screen
        if (isOnboarding) {
          print('  -> Allowing onboarding screen');
          return null;
        }
      }

      // Handle authenticated users
      if (isAuthenticated) {
        // If on public route, allow it
        if (isPublicRoute) {
          print('  -> Allowing authenticated user on public route');
          return null;
        }

        // Check email verification - only redirect if explicitly on email verification route
        if (!isEmailVerified && isEmailVerification) {
          print('  -> Allowing email verification screen');
          return null;
        }

        // Only redirect to email verification if user is on a protected route and email is not verified
        if (!isEmailVerified &&
            !isEmailVerification &&
            !isAuthRoute &&
            !isOnboarding) {
          print('  -> Redirecting to email verification (email not verified)');
          return '/email-verification?email=${authProvider.currentUser?.email ?? ''}';
        }

        // If on auth route, redirect to home
        if (isAuthRoute) {
          print('  -> Redirecting authenticated user from auth route to home');
          return '/home';
        }

        // If on email verification, redirect to home
        if (isEmailVerification) {
          print(
            '  -> Redirecting verified user from email verification to home',
          );
          return '/home';
        }

        // If on onboarding, redirect to home
        if (isOnboarding) {
          print('  -> Redirecting authenticated user from onboarding to home');
          return '/home';
        }

        // Allow all other routes for authenticated users
        print('  -> Allowing authenticated user on protected route');
        return null;
      }

      print('  -> No redirect needed');
      return null;
    },
  );
}

class MainShell extends StatelessWidget {
  const MainShell({super.key, required this.child, required this.currentRoute});
  final Widget child;
  final String currentRoute;

  @override
  Widget build(BuildContext context) =>
      MainNavigation(currentRoute: currentRoute, child: child);
}
