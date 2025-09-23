import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'email_validation_service.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user
  static User? get currentUser => _auth.currentUser;

  // Get current user ID
  static String? get currentUserId => _auth.currentUser?.uid;

  // Get current user email
  static String? get currentUserEmail => _auth.currentUser?.email;

  // Get current user data
  static Future<Map<String, dynamic>?> getCurrentUserData() async {
    final user = currentUser;
    if (user == null) return null;

    try {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      return doc.data();
    } catch (e) {
      print('Error getting user data: $e');
      return null;
    }
  }

  // Check if user is authenticated
  static bool get isAuthenticated => _auth.currentUser != null;

  // Sign in with email and password
  static Future<UserCredential?> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      print('Error signing in: $e');
      return null;
    }
  }

  // Sign up with email and password
  static Future<Map<String, dynamic>?> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    String? university,
    String? studentId,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        final isStudentEmail = EmailValidationService.isValidStudentEmail(
          email,
        );
        final detectedUniversity =
            EmailValidationService.getUniversityFromEmail(email);
        final finalUniversity = university ?? detectedUniversity ?? '';

        // Determine user role and verification status
        String role = 'user';
        bool isVerified = false;

        if (isStudentEmail) {
          role = 'student';
          isVerified = true; // Student emails are auto-verified
        }

        // Create complete user document in Firestore with all fields
        final userData = {
          'id': credential.user!.uid,
          'email': email,
          'first_name': firstName,
          'last_name': lastName,
          'university': finalUniversity,
          'student_id': studentId,
          'role': role,
          'is_verified': isVerified,
          'is_active': true,
          'profile_image_url': null,
          'phone_number': null,
          'created_at': FieldValue.serverTimestamp(),
          'updated_at': FieldValue.serverTimestamp(),
          'last_login': FieldValue.serverTimestamp(),
          'signup_source': 'email',
          'preferences': {
            'notifications_enabled': true,
            'email_notifications': true,
            'push_notifications': true,
            'language': 'en',
            'theme': 'system',
            'privacy': {
              'profile_visible': true,
              'contact_info_visible': false,
              'listings_visible': true,
              'activity_visible': false,
            },
          },
          'stats': {
            'items_sold': 0,
            'items_bought': 0,
            'total_rating': 0.0,
            'rating_count': 0,
            'reviews_received': 0,
          },
        };

        await _firestore
            .collection('users')
            .doc(credential.user!.uid)
            .set(userData);

        // Send Firebase email verification for all users
        if (!isStudentEmail) {
          // Send Firebase email verification for non-student emails
          await credential.user!.sendEmailVerification();
          print('Firebase verification email sent to $email');
        }

        // Submit for verification based on email type
        if (isStudentEmail) {
          await EmailValidationService.submitForVerification(
            userId: credential.user!.uid,
            email: email,
            firstName: firstName,
            lastName: lastName,
            university: finalUniversity,
            studentId: studentId,
          );
        } else {
          // Submit non-university email for manual verification
          await EmailValidationService.submitNonUniversityEmailForVerification(
            userId: credential.user!.uid,
            email: email,
            firstName: firstName,
            lastName: lastName,
            university: finalUniversity,
            studentId: studentId,
          );
        }

        return {
          'credential': credential,
          'isStudentEmail': isStudentEmail,
          'needsVerification': !isStudentEmail,
          'university': finalUniversity,
        };
      }

      return null;
    } on FirebaseAuthException catch (e) {
      print('Firebase Auth Error: ${e.code} - ${e.message}');
      // Return error details for better user feedback
      return {
        'error': true,
        'code': e.code,
        'message': _getUserFriendlyErrorMessage(e),
      };
    } catch (e) {
      print('Error signing up: $e');
      return {
        'error': true,
        'code': 'unknown',
        'message': 'An unexpected error occurred. Please try again.',
      };
    }
  }

  // Sign out
  static Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      print('Error signing out: $e');
    }
  }

  // Get user phone number
  static String? get currentUserPhone => _auth.currentUser?.phoneNumber;

  // Get user display name
  static String? get currentUserDisplayName => _auth.currentUser?.displayName;

  // Check if current user can sell items
  static Future<bool> canCurrentUserSell() async {
    final userId = currentUserId;
    if (userId == null) return false;
    return await EmailValidationService.canUserSell(userId);
  }

  // Get current user status (verification, role, permissions)
  static Future<Map<String, dynamic>?> getCurrentUserStatus() async {
    final userId = currentUserId;
    if (userId == null) return null;
    return await EmailValidationService.getUserStatus(userId);
  }

  // Check if email is a valid student email
  static bool isValidStudentEmail(String email) {
    return EmailValidationService.isValidStudentEmail(email);
  }

  // Get university from email
  static String? getUniversityFromEmail(String email) {
    return EmailValidationService.getUniversityFromEmail(email);
  }

  // Convert Firebase Auth errors to user-friendly messages
  static String _getUserFriendlyErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'This email address is already registered. Please use a different email or try signing in.';
      case 'weak-password':
        return 'Password is too weak. Please choose a stronger password with at least 6 characters.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'operation-not-allowed':
        return 'Email/password accounts are not enabled. Please contact support.';
      case 'network-request-failed':
        return 'Network error. Please check your internet connection and try again.';
      case 'too-many-requests':
        return 'Too many attempts. Please wait a moment before trying again.';
      default:
        return 'Failed to create account. Please try again.';
    }
  }
}
