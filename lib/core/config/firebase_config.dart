/// @Branch: Firebase Configuration
///
/// Firebase configuration and initialization for Campus Market
/// Handles Firebase setup and provides access to Firebase services
library;

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import '../../firebase_options.dart';

class FirebaseConfig {
  static FirebaseApp? _app;
  static FirebaseAuth? _auth;
  static FirebaseFirestore? _firestore;
  static FirebaseStorage? _storage;
  static FirebaseAnalytics? _analytics;
  static FirebaseCrashlytics? _crashlytics;

  /// Initialize Firebase
  static Future<void> initialize() async {
    try {
      // Check if Firebase is already initialized
      if (_app != null) {
        print('Firebase already initialized');
        return;
      }

      _app = await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );

      // Wait a bit to ensure Firebase is fully initialized
      await Future<void>.delayed(const Duration(milliseconds: 200));

      // Initialize Firebase services with error handling
      try {
        _auth = FirebaseAuth.instance;
        print('Firebase Auth initialized');
      } catch (e) {
        print('Warning: Firebase Auth initialization failed: $e');
      }

      try {
        _firestore = FirebaseFirestore.instance;
        print('Firestore initialized');
      } catch (e) {
        print('Warning: Firestore initialization failed: $e');
      }

      try {
        _storage = FirebaseStorage.instance;
        print('Firebase Storage initialized');
      } catch (e) {
        print('Warning: Firebase Storage initialization failed: $e');
      }

      try {
        _analytics = FirebaseAnalytics.instance;
        print('Firebase Analytics initialized');
      } catch (e) {
        print('Warning: Firebase Analytics initialization failed: $e');
      }

      // Initialize Crashlytics with proper error handling
      // Skip Crashlytics on web platform as it's not fully supported
      if (!kIsWeb) {
        try {
          _crashlytics = FirebaseCrashlytics.instance;

          // Only enable crashlytics collection in release mode
          if (!kDebugMode) {
            await _crashlytics?.setCrashlyticsCollectionEnabled(true);
          }
          print('Firebase Crashlytics initialized');
        } catch (crashlyticsError) {
          print(
            'Warning: Crashlytics initialization failed: $crashlyticsError',
          );
          // Continue without crashlytics if it fails
          _crashlytics = null;
        }
      } else {
        print('Crashlytics skipped on web platform');
        _crashlytics = null;
      }

      print('Firebase initialization completed');
    } catch (e) {
      print('Error initializing Firebase: $e');
      // Don't rethrow to allow app to continue without Firebase
      if (kDebugMode) {
        print('Continuing without Firebase services...');
      }
    }
  }

  /// Get Firebase Auth instance
  static FirebaseAuth get auth {
    if (_auth == null) {
      throw Exception('Firebase not initialized. Call initialize() first.');
    }
    return _auth!;
  }

  /// Get Firestore instance
  static FirebaseFirestore get firestore {
    if (_firestore == null) {
      throw Exception('Firebase not initialized. Call initialize() first.');
    }
    return _firestore!;
  }

  /// Get Firebase Storage instance
  static FirebaseStorage get storage {
    if (_storage == null) {
      throw Exception('Firebase not initialized. Call initialize() first.');
    }
    return _storage!;
  }

  /// Get Firebase Analytics instance
  static FirebaseAnalytics get analytics {
    if (_analytics == null) {
      throw Exception('Firebase not initialized. Call initialize() first.');
    }
    return _analytics!;
  }

  /// Get Firebase Crashlytics instance
  static FirebaseCrashlytics? get crashlytics => _crashlytics;

  /// Check if Firebase is initialized
  static bool get isInitialized => _app != null;

  /// Get current user
  static User? get currentUser => _auth?.currentUser;

  /// Get current user ID
  static String? get currentUserId => _auth?.currentUser?.uid;

  /// Check if user is authenticated
  static bool get isAuthenticated => _auth?.currentUser != null;

  /// Sign out current user
  static Future<void> signOut() async {
    await _auth?.signOut();
  }

  /// Delete current user account
  static Future<void> deleteAccount() async {
    final user = _auth?.currentUser;
    if (user != null) {
      await user.delete();
    }
  }

  /// Log a crash to Crashlytics (if available)
  static Future<void> logCrash(dynamic error, StackTrace? stackTrace) async {
    if (_crashlytics != null) {
      await _crashlytics!.recordError(error, stackTrace);
    }
  }

  /// Log a message to Crashlytics (if available)
  static Future<void> logMessage(String message) async {
    if (_crashlytics != null) {
      await _crashlytics!.log(message);
    }
  }

  /// Check if Crashlytics is available and working
  static bool get isCrashlyticsAvailable => _crashlytics != null;
}

/// Firebase Collections
class FirebaseCollections {
  static const String users = 'users';
  static const String products = 'products';
  static const String accommodations = 'accommodations';
  static const String events = 'events';
  static const String chats = 'chats';
  static const String chatRooms = 'chatRooms';
  static const String messages = 'messages';
  static const String categories = 'categories';
  static const String universities = 'universities';
  static const String reports = 'reports';
  static const String notifications = 'notifications';
  static const String bookings = 'bookings';
  static const String favorites = 'favorites';
  static const String rsvps = 'rsvps';
}

/// Firebase Storage Buckets
class FirebaseBuckets {
  static const String profileImages = 'profile_images';
  static const String productImages = 'product_images';
  static const String accommodationImages = 'accommodation_images';
  static const String eventImages = 'event_images';
  static const String chatImages = 'chat_images';
  static const String documents = 'documents';
}
