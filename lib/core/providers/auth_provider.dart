/// @Branch: Auth Provider Implementation
///
/// Authentication state management provider
/// Handles user authentication and session management
/// Updated to use Firebase for real authentication
library;

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart' as app_models;
import '../repositories/firebase_repository.dart';
import '../config/firebase_config.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider() {
    _initializeAuth();
    _listenToAuthChanges();
  }
  app_models.User? _currentUser;
  bool _isLoading = false;
  String? _error;
  bool _hasCompletedOnboarding = false;
  bool _isInErrorState = false;

  app_models.User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _currentUser != null;
  bool get hasCompletedOnboarding => _hasCompletedOnboarding;
  bool get isInErrorState => _isInErrorState;

  Future<void> _initializeAuth() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Small delay to ensure Firebase is fully initialized
      await Future<void>.delayed(const Duration(milliseconds: 100));

      // Check onboarding completion
      final prefs = await SharedPreferences.getInstance();
      _hasCompletedOnboarding = prefs.getBool('onboarding_completed') ?? false;

      // Check if user is already signed in
      final user = FirebaseConfig.currentUser;
      if (user != null) {
        print('Found existing Firebase user: ${user.uid}');
        try {
          _currentUser = await FirebaseRepository.getUserById(user.uid);
          print('Loaded user profile: ${_currentUser?.email}');
        } catch (e) {
          print('Error loading user profile: $e');
          // If we can't load the user profile, sign them out to prevent loops
          await FirebaseConfig.auth.signOut();
          _currentUser = null;
        }
      } else {
        print('No existing Firebase user found');
        _currentUser = null;
      }
    } catch (e) {
      print('Error initializing auth: $e');
      _currentUser = null;
    }

    _isLoading = false;
    print('Auth initialization complete. isAuthenticated: $isAuthenticated');
    notifyListeners();
  }

  void _listenToAuthChanges() {
    FirebaseConfig.auth.authStateChanges().listen((user) async {
      print('Auth state changed: ${user != null ? "signed in" : "signed out"}');

      // Ensure we're not stuck in loading state
      if (_isLoading) {
        _isLoading = false;
      }

      if (user != null) {
        print('User signed in: ${user.uid}');
        try {
          // User signed in - use retry logic
          _currentUser = await _getUserWithRetry(user.uid);
          print('Current user set: ${_currentUser?.email}');

          // If user doesn't exist, create them
          if (_currentUser == null) {
            print('Creating user profile from auth state change');

            // Get university from user metadata if available
            String university = '';
            if (user.displayName != null && user.displayName!.contains('|')) {
              // Extract university from display name if it was stored there
              final parts = user.displayName!.split('|');
              if (parts.length > 1) {
                university = parts[1].trim();
              }
            }

            final newUser = app_models.User(
              id: user.uid,
              email: user.email ?? '',
              firstName: user.displayName?.split(' ').first ?? '',
              lastName: user.displayName?.split(' ').last ?? '',
              university: university,
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
              preferences: const app_models.UserPreferences(
                privacy: app_models.PrivacySettings(),
              ),
            );
            _currentUser = await _createUserWithRetry(newUser);
            print('User created from auth state: ${_currentUser?.email}');
          }

          // Save session info for persistence
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('user_id', user.uid);
          await prefs.setString('user_email', user.email ?? '');
          await prefs.setBool('is_authenticated', true);
        } catch (e) {
          print('Error handling signed in user: $e');
          _currentUser = null;
        }
      } else {
        print('User signed out');
        // User signed out
        _currentUser = null;

        // Clear session info
        try {
          final prefs = await SharedPreferences.getInstance();
          await prefs.remove('user_id');
          await prefs.remove('user_email');
          await prefs.setBool('is_authenticated', false);
        } catch (e) {
          print('Error clearing session info: $e');
        }
      }

      print('Notifying listeners, isAuthenticated: $isAuthenticated');
      notifyListeners();
    });
  }

  Future<bool> signIn(String email, String password) async {
    print('SignIn called for email: $email');
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Sign in with Firebase Auth
      final credential = await FirebaseConfig.auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      print('Firebase response: ${credential.user != null}');
      if (credential.user != null) {
        print('User ID: ${credential.user!.uid}');

        // Wait a moment for the auth state to settle
        await Future<void>.delayed(const Duration(milliseconds: 500));

        // Try to get user from database with retry logic
        _currentUser = await _getUserWithRetry(credential.user!.uid);
        print('User from database: ${_currentUser?.email}');

        // If user doesn't exist in our users table, create a basic profile
        if (_currentUser == null) {
          print('Creating new user profile');

          // Get university from user metadata if available
          String university = '';
          if (credential.user!.displayName != null &&
              credential.user!.displayName!.contains('|')) {
            // Extract university from display name if it was stored there
            final parts = credential.user!.displayName!.split('|');
            if (parts.length > 1) {
              university = parts[1].trim();
            }
          }

          final newUser = app_models.User(
            id: credential.user!.uid,
            email: credential.user!.email ?? email,
            firstName: credential.user!.displayName?.split(' ').first ?? '',
            lastName: credential.user!.displayName?.split(' ').last ?? '',
            university: university,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            preferences: const app_models.UserPreferences(
              privacy: app_models.PrivacySettings(),
            ),
          );
          _currentUser = await _createUserWithRetry(newUser);
          print('New user created: ${_currentUser?.email}');
        }

        _isLoading = false;
        print('SignIn successful, isAuthenticated: $isAuthenticated');
        notifyListeners();
        return true;
      } else {
        print('SignIn failed: Invalid credentials');
        _error = 'Invalid email or password';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      print('SignIn error: $e');
      _error = _getUserFriendlyErrorMessage(e);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> signUp(
    String email,
    String password,
    String firstName,
    String lastName,
    String university,
  ) async {
    _isLoading = true;
    _error = null;
    _isInErrorState = false;
    notifyListeners();

    try {
      // Sign up with Firebase Auth
      final credential = await FirebaseConfig.auth
          .createUserWithEmailAndPassword(email: email, password: password);

      if (credential.user != null) {
        // Update display name
        await credential.user!.updateDisplayName('$firstName $lastName');

        // Check if this is a custom university and add it to the database
        String finalUniversity = university;
        if (university.isNotEmpty && !_isPredefinedUniversity(university)) {
          print('Adding custom university to database: $university');
          await FirebaseRepository.createUniversity(university);
        }

        // Create complete user profile in our users table with all fields
        final newUser = app_models.User(
          id: credential.user!.uid,
          email: email,
          firstName: firstName,
          lastName: lastName,
          university: finalUniversity,
          studentId: null, // Will be set later if provided
          profileImageUrl: null,
          phoneNumber: null,
          isVerified: false, // Will be verified via email
          isActive: true,
          role: app_models.UserRole.student,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          preferences: const app_models.UserPreferences(
            notificationsEnabled: true,
            emailNotifications: true,
            pushNotifications: true,
            language: 'en',
            theme: 'system',
            privacy: const app_models.PrivacySettings(
              profileVisible: true,
              contactInfoVisible: false,
              listingsVisible: true,
              activityVisible: false,
            ),
          ),
        );

        _currentUser = await FirebaseRepository.createUser(newUser);

        // Send email verification
        try {
          await credential.user!.sendEmailVerification();
          print('Verification email sent to $email');
        } catch (e) {
          print('Failed to send verification email: $e');
          // Don't fail the sign-up if email verification fails
        }

        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = 'Failed to create account';
        _isLoading = false;
        _isInErrorState = true;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = _getUserFriendlyErrorMessage(e);
      _isLoading = false;
      _isInErrorState = true;
      notifyListeners();
      return false;
    }
  }

  Future<void> signOut() async {
    _isLoading = true;
    notifyListeners();

    try {
      await FirebaseConfig.auth.signOut();
      _currentUser = null;
    } catch (e) {
      print('Error signing out: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> updateProfile(app_models.User updatedUser) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _currentUser = await FirebaseRepository.updateUser(updatedUser);
      _isLoading = false;
      notifyListeners();
      return _currentUser != null;
    } catch (e) {
      _error = 'Failed to update profile: ${e}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> forgotPassword(String email) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Send password reset email using Firebase Auth
      await FirebaseConfig.auth.sendPasswordResetEmail(email: email);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = _getUserFriendlyErrorMessage(e);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> resetPassword(String email, String newPassword) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Update password using Firebase Auth
      final user = FirebaseConfig.currentUser;
      if (user != null) {
        await user.updatePassword(newPassword);
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = 'No user signed in';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = _getUserFriendlyErrorMessage(e);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _error = null;
    _isInErrorState = false;
    notifyListeners();
  }

  Future<void> markOnboardingCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_completed', true);
    _hasCompletedOnboarding = true;
    notifyListeners();
  }

  /// Get user with retry logic to handle database policy issues
  Future<app_models.User?> _getUserWithRetry(
    String userId, {
    int maxRetries = 3,
  }) async {
    for (int i = 0; i < maxRetries; i++) {
      try {
        final user = await FirebaseRepository.getUserById(userId);
        if (user != null) return user;

        // Wait before retry
        if (i < maxRetries - 1) {
          await Future<void>.delayed(Duration(milliseconds: 1000 * (i + 1)));
        }
      } catch (e) {
        print('Error getting user (attempt ${i + 1}): $e');
        if (i == maxRetries - 1) rethrow;
        await Future<void>.delayed(Duration(milliseconds: 1000 * (i + 1)));
      }
    }
    return null;
  }

  /// Create user with retry logic to handle database policy issues
  Future<app_models.User?> _createUserWithRetry(
    app_models.User user, {
    int maxRetries = 3,
  }) async {
    for (int i = 0; i < maxRetries; i++) {
      try {
        final createdUser = await FirebaseRepository.createUser(user);
        if (createdUser != null) return createdUser;

        // Wait before retry
        if (i < maxRetries - 1) {
          await Future<void>.delayed(Duration(milliseconds: 1000 * (i + 1)));
        }
      } catch (e) {
        print('Error creating user (attempt ${i + 1}): $e');
        if (i == maxRetries - 1) rethrow;
        await Future<void>.delayed(Duration(milliseconds: 1000 * (i + 1)));
      }
    }
    return null;
  }

  /// Check if a university is in the predefined list
  bool _isPredefinedUniversity(String university) {
    const predefinedUniversities = [
      'University of Zimbabwe',
      'National University of Science and Technology',
      'Midlands State University',
      'Great Zimbabwe University',
      'Lupane State University',
      'Bindura University of Science Education',
      'Chinhoyi University of Technology',
      'Zimbabwe Open University',
      'Solusi University',
      'Africa University',
      'Catholic University of Zimbabwe',
      "Women's University in Africa",
      'Zimbabwe Ezekiel Guti University',
      'Manicaland State University of Applied Sciences',
      'Marondera University of Agricultural Sciences and Technology',
    ];

    return predefinedUniversities.contains(university);
  }

  /// Convert technical errors to user-friendly messages
  String _getUserFriendlyErrorMessage(dynamic error) {
    final errorString = error.toString().toLowerCase();

    // Network connectivity issues
    if (errorString.contains('network') ||
        errorString.contains('connection') ||
        errorString.contains('timeout') ||
        errorString.contains('unreachable')) {
      return 'Please check your internet connection and try again.';
    }

    // Authentication errors
    if (errorString.contains('invalid_credentials') ||
        errorString.contains('invalid email or password')) {
      return 'Invalid email or password. Please check your credentials and try again.';
    }

    if (errorString.contains('email_not_confirmed') ||
        errorString.contains('email not confirmed')) {
      return 'Please check your email and click the confirmation link before signing in.';
    }

    if (errorString.contains('too_many_requests') ||
        errorString.contains('rate limit')) {
      return 'Too many attempts. Please wait a few minutes before trying again.';
    }

    if (errorString.contains('user_not_found')) {
      return 'No account found with this email address. Please sign up first.';
    }

    if (errorString.contains('weak_password') ||
        errorString.contains('password is too weak')) {
      return 'Password is too weak. Please use at least 8 characters with letters and numbers.';
    }

    if (errorString.contains('email_address_invalid') ||
        errorString.contains('invalid email')) {
      return 'Please enter a valid email address.';
    }

    if (errorString.contains('user_already_registered') ||
        errorString.contains('email already registered')) {
      return 'An account with this email already exists. Please sign in instead.';
    }

    if (errorString.contains('password_reset_required')) {
      return 'Please reset your password before signing in.';
    }

    // Server errors
    if (errorString.contains('internal server error') ||
        errorString.contains('server error')) {
      return 'Our servers are temporarily unavailable. Please try again in a few minutes.';
    }

    // Default fallback
    return 'Something went wrong. Please try again or contact support if the problem persists.';
  }

  Future<void> sendEmailVerification() async {
    try {
      final user = FirebaseConfig.currentUser;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
        print('Verification email sent to ${user.email}');
      } else {
        throw Exception('No user found or email already verified');
      }
    } catch (e) {
      _error = 'Failed to send verification email: $e';
      notifyListeners();
      rethrow;
    }
  }

  Future<void> reloadUser() async {
    try {
      final user = FirebaseConfig.currentUser;
      if (user != null) {
        await user.reload();
        final updatedUser = FirebaseConfig.currentUser;
        if (updatedUser != null) {
          _currentUser = await FirebaseRepository.getUserById(updatedUser.uid);
          notifyListeners();
        }
      }
    } catch (e) {
      _error = 'Failed to reload user: $e';
      notifyListeners();
      rethrow;
    }
  }

  bool get isEmailVerified =>
      FirebaseConfig.currentUser?.emailVerified ?? false;
}
