/// @Branch: Email Validation Service Implementation
///
/// Service for validating student emails and managing verification
/// Handles email domain validation and admin verification workflow
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import '../config/firebase_config.dart';

class EmailValidationService {
  static final FirebaseFirestore _firestore = FirebaseConfig.firestore;

  // List of recognized university email domains
  static const List<String> _universityDomains = [
    'uz.ac.zw', // University of Zimbabwe
    'nust.ac.zw', // National University of Science and Technology
    'msu.ac.zw', // Midlands State University
    'gzu.ac.zw', // Great Zimbabwe University
    'lsu.ac.zw', // Lupane State University
    'buse.ac.zw', // Bindura University of Science Education
    'cut.ac.zw', // Chinhoyi University of Technology
    'zou.ac.zw', // Zimbabwe Open University
    'solusi.ac.zw', // Solusi University
    'au.ac.zw', // Africa University
    'cuz.ac.zw', // Catholic University of Zimbabwe
    'wua.ac.zw', // Women's University in Africa
    'zegu.ac.zw', // Zimbabwe Ezekiel Guti University
    'msuas.ac.zw', // Manicaland State University of Applied Sciences
    'muast.ac.zw', // Marondera University of Agricultural Sciences and Technology
  ];

  /// Check if an email is a valid student email
  static bool isValidStudentEmail(String email) {
    if (email.isEmpty) return false;

    final domain = email.split('@').last.toLowerCase();
    return _universityDomains.contains(domain);
  }

  /// Get university name from email domain
  static String? getUniversityFromEmail(String email) {
    if (email.isEmpty) return null;

    final domain = email.split('@').last.toLowerCase();

    switch (domain) {
      case 'uz.ac.zw':
        return 'University of Zimbabwe';
      case 'nust.ac.zw':
        return 'National University of Science and Technology';
      case 'msu.ac.zw':
        return 'Midlands State University';
      case 'gzu.ac.zw':
        return 'Great Zimbabwe University';
      case 'lsu.ac.zw':
        return 'Lupane State University';
      case 'buse.ac.zw':
        return 'Bindura University of Science Education';
      case 'cut.ac.zw':
        return 'Chinhoyi University of Technology';
      case 'zou.ac.zw':
        return 'Zimbabwe Open University';
      case 'solusi.ac.zw':
        return 'Solusi University';
      case 'au.ac.zw':
        return 'Africa University';
      case 'cuz.ac.zw':
        return 'Catholic University of Zimbabwe';
      case 'wua.ac.zw':
        return 'Women\'s University in Africa';
      case 'zegu.ac.zw':
        return 'Zimbabwe Ezekiel Guti University';
      case 'msuas.ac.zw':
        return 'Manicaland State University of Applied Sciences';
      case 'muast.ac.zw':
        return 'Marondera University of Agricultural Sciences and Technology';
      default:
        return null;
    }
  }

  /// Submit student email for admin verification
  static Future<bool> submitForVerification({
    required String userId,
    required String email,
    required String firstName,
    required String lastName,
    required String university,
    String? studentId,
  }) async {
    try {
      final verificationData = {
        'userId': userId,
        'email': email,
        'firstName': firstName,
        'lastName': lastName,
        'university': university,
        'studentId': studentId,
        'status': 'pending',
        'submittedAt': FieldValue.serverTimestamp(),
        'reviewedAt': null,
        'reviewedBy': null,
        'notes': null,
      };

      await _firestore
          .collection('email_verifications')
          .doc(userId)
          .set(verificationData);

      return true;
    } catch (e) {
      print('Error submitting for verification: $e');
      return false;
    }
  }

  /// Submit non-university email for admin verification
  static Future<bool> submitNonUniversityEmailForVerification({
    required String userId,
    required String email,
    required String firstName,
    required String lastName,
    required String university,
    String? studentId,
  }) async {
    try {
      final verificationData = {
        'userId': userId,
        'email': email,
        'firstName': firstName,
        'lastName': lastName,
        'university': university,
        'studentId': studentId,
        'status': 'pending',
        'emailType': 'non_university',
        'submittedAt': FieldValue.serverTimestamp(),
        'reviewedAt': null,
        'reviewedBy': null,
        'notes': 'Non-university email - requires manual verification',
      };

      await _firestore
          .collection('email_verifications')
          .doc(userId)
          .set(verificationData);

      return true;
    } catch (e) {
      print('Error submitting non-university email for verification: $e');
      return false;
    }
  }

  /// Check verification status for a user
  static Future<Map<String, dynamic>?> getVerificationStatus(
    String userId,
  ) async {
    try {
      final doc = await _firestore
          .collection('email_verifications')
          .doc(userId)
          .get();

      if (doc.exists) {
        return doc.data();
      }
      return null;
    } catch (e) {
      print('Error getting verification status: $e');
      return null;
    }
  }

  /// Get all pending verifications (for admin use)
  static Future<List<Map<String, dynamic>>> getPendingVerifications() async {
    try {
      final snapshot = await _firestore
          .collection('email_verifications')
          .where('status', isEqualTo: 'pending')
          .orderBy('submittedAt', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      print('Error getting pending verifications: $e');
      return [];
    }
  }

  /// Approve student verification (admin only)
  static Future<bool> approveVerification({
    required String userId,
    required String adminId,
    String? notes,
  }) async {
    try {
      await _firestore.collection('email_verifications').doc(userId).update({
        'status': 'approved',
        'reviewedAt': FieldValue.serverTimestamp(),
        'reviewedBy': adminId,
        'notes': notes,
      });

      // Update user role to student
      await _firestore.collection('users').doc(userId).update({
        'isVerified': true,
        'role': 'student',
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return true;
    } catch (e) {
      print('Error approving verification: $e');
      return false;
    }
  }

  /// Reject student verification (admin only)
  static Future<bool> rejectVerification({
    required String userId,
    required String adminId,
    required String reason,
  }) async {
    try {
      await _firestore.collection('email_verifications').doc(userId).update({
        'status': 'rejected',
        'reviewedAt': FieldValue.serverTimestamp(),
        'reviewedBy': adminId,
        'notes': reason,
      });

      return true;
    } catch (e) {
      print('Error rejecting verification: $e');
      return false;
    }
  }

  /// Check if user can sell items
  static Future<bool> canUserSell(String userId) async {
    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();

      if (userDoc.exists) {
        final userData = userDoc.data()!;
        return userData['isVerified'] == true &&
            (userData['role'] == 'student' || userData['role'] == 'admin');
      }
      return false;
    } catch (e) {
      print('Error checking sell permissions: $e');
      return false;
    }
  }

  /// Get user role and verification status
  static Future<Map<String, dynamic>?> getUserStatus(String userId) async {
    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();

      if (userDoc.exists) {
        final userData = userDoc.data()!;
        return {
          'isVerified': userData['isVerified'] ?? false,
          'role': userData['role'] ?? 'user',
          'canSell':
              userData['isVerified'] == true &&
              (userData['role'] == 'student' || userData['role'] == 'admin'),
        };
      }
      return null;
    } catch (e) {
      print('Error getting user status: $e');
      return null;
    }
  }
}
