/// @Branch: Main Application Entry Point
///
/// Campus Market Flutter Application
/// Modern student marketplace with comprehensive UI implementation
library;

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'core/config/firebase_config.dart';
import 'core/localization/app_localizations.dart';
import 'core/providers/auth_provider.dart';
import 'core/providers/theme_provider.dart';
import 'core/providers/chat_provider.dart';
import 'core/routing/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/services/logging_service.dart';
import 'core/services/performance_service.dart';
import 'core/services/security_service.dart';
import 'core/services/network_service.dart';
import 'ui/widgets/network_aware_app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Production error handling
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);

    // Log to Firebase Crashlytics in production
    if (!kDebugMode) {
      FirebaseConfig.logCrash(details.exception, details.stack);
    } else {
      // Debug logging
      print('Flutter Error: ${details.exception}');
      print('Stack trace: ${details.stack}');
    }
  };

  // Handle platform-specific errors
  PlatformDispatcher.instance.onError = (error, stack) {
    // Log to Firebase Crashlytics in production
    if (!kDebugMode) {
      FirebaseConfig.logCrash(error, stack);
    } else {
      // Debug logging
      print('Platform Error: $error');
      print('Stack trace: $stack');
    }
    return true;
  };

  try {
    // Initialize production services
    LoggingService.logStartup();
    PerformanceService.initialize();
    SecurityService.initialize();
    await NetworkService().initialize();

    // Initialize Firebase
    await FirebaseConfig.initialize();

    // Log app start in production
    if (!kDebugMode) {
      FirebaseConfig.logMessage('Campus Market app started');
    }
  } catch (e) {
    LoggingService.error('App initialization error', error: e);
    if (kDebugMode) {
      print('Firebase initialization error: $e');
    } else {
      // Log Firebase initialization error
      FirebaseConfig.logCrash(e, StackTrace.current);
    }
    // Continue app initialization even if Firebase fails
  }

  runApp(const CampusMarketApp());
}

class CampusMarketApp extends StatelessWidget {
  const CampusMarketApp({super.key});

  @override
  Widget build(BuildContext context) => MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ChangeNotifierProvider(create: (_) => AuthProvider()),
      ChangeNotifierProvider(create: (_) => ChatProvider()),
      ChangeNotifierProvider(create: (_) => NetworkService()),
    ],
    child: Consumer2<ThemeProvider, AuthProvider>(
      builder: (context, themeProvider, authProvider, child) => NetworkAwareApp(
        showNetworkStatus: true,
        child: MaterialApp.router(
          title: 'Campus Market',
          debugShowCheckedModeBanner: false,

          // Theme Configuration
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeProvider.themeMode,

          // Localization Configuration
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en', ''), // English
            Locale('sn', ''), // Placeholder for additional language
          ],
          locale: themeProvider.locale,

          // Router Configuration
          routerConfig: AppRouter.createRouter(authProvider),

          // Builder for responsive design and network status overlay
          builder: (context, child) {
            return MediaQuery(
              data: MediaQuery.of(
                context,
              ).copyWith(textScaler: const TextScaler.linear(1.0)),
              child: Stack(
                children: [
                  child!,
                  // Network status overlay - only show when disconnected
                  Consumer<NetworkService>(
                    builder: (context, networkService, _) {
                      if (networkService.isDisconnected) {
                        return AnimatedPositioned(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          top: 0,
                          left: 0,
                          right: 0,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.red.shade600,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.wifi_off,
                                  color: Colors.white,
                                  size: 20,
                                ),
                                const SizedBox(width: 12),
                                const Expanded(
                                  child: Text(
                                    'No Internet Connection',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      decoration: TextDecoration.none,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                ElevatedButton(
                                  onPressed: () =>
                                      networkService.checkConnection(),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    foregroundColor: Colors.red.shade600,
                                    elevation: 0,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 8,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                  ),
                                  child: const Text(
                                    'Retry',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }
                      // Don't show anything when connected - this is how most apps work
                      return const SizedBox.shrink();
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ),
    ),
  );
}
