/// @Branch: Firebase Repository Implementation
///
/// Firebase repository for Campus Market data operations
/// Handles all database operations using Firebase Firestore
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:typed_data';

import '../config/firebase_config.dart';
import '../models/user.dart' as app_models;

class FirebaseRepository {
  static final FirebaseFirestore _firestore = FirebaseConfig.firestore;
  static final FirebaseStorage _storage = FirebaseConfig.storage;

  // =============================================
  // USER OPERATIONS
  // =============================================

  static Future<app_models.User?> createUser(app_models.User user) async {
    try {
      await _firestore
          .collection(FirebaseCollections.users)
          .doc(user.id)
          .set(user.toJson());

      return user;
    } catch (e) {
      print('Error creating user: $e');
      return null;
    }
  }

  static Future<app_models.User?> getUserById(String id) async {
    try {
      // Validate input
      if (id.isEmpty) {
        print('Error: User ID is empty');
        return null;
      }

      final doc = await _firestore
          .collection(FirebaseCollections.users)
          .doc(id)
          .get();

      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        // Validate required fields before creating User object
        if (data['id'] != null &&
            data['email'] != null &&
            data['first_name'] != null &&
            data['last_name'] != null) {
          return app_models.User.fromJson(data);
        } else {
          print('Error: User document missing required fields');
          return null;
        }
      }
      return null;
    } catch (e) {
      print('Error getting user by ID: $e');
      return null;
    }
  }

  static Future<app_models.User?> updateUser(app_models.User user) async {
    try {
      await _firestore
          .collection(FirebaseCollections.users)
          .doc(user.id)
          .update(user.toJson());

      return user;
    } catch (e) {
      print('Error updating user: $e');
      return null;
    }
  }

  static Future<bool> deleteUser(String id) async {
    try {
      await _firestore.collection(FirebaseCollections.users).doc(id).delete();

      return true;
    } catch (e) {
      print('Error deleting user: $e');
      return false;
    }
  }

  static Future<List<app_models.User>> getUsers({
    int limit = 20,
    int offset = 0,
    String? university,
    String? role,
  }) async {
    try {
      Query query = _firestore
          .collection(FirebaseCollections.users)
          .orderBy('createdAt', descending: true)
          .limit(limit);

      if (university != null) {
        query = query.where('university', isEqualTo: university);
      }

      if (role != null) {
        query = query.where('role', isEqualTo: role);
      }

      final snapshot = await query.get();

      return snapshot.docs
          .map(
            (doc) =>
                app_models.User.fromJson(doc.data() as Map<String, dynamic>),
          )
          .toList();
    } catch (e) {
      print('Error getting users: $e');
      return [];
    }
  }

  // =============================================
  // UNIVERSITY OPERATIONS
  // =============================================

  static Future<List<Map<String, dynamic>>> getUniversities() async {
    try {
      final snapshot = await _firestore
          .collection(FirebaseCollections.universities)
          .where('isActive', isEqualTo: true)
          .orderBy('name')
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      print('Error getting universities: $e');
      return [];
    }
  }

  static Future<Map<String, dynamic>?> createUniversity(String name) async {
    try {
      // Check if university already exists
      final existingSnapshot = await _firestore
          .collection(FirebaseCollections.universities)
          .where('name', isEqualTo: name)
          .limit(1)
          .get();

      if (existingSnapshot.docs.isNotEmpty) {
        // University already exists, return it
        final existingDoc = existingSnapshot.docs.first;
        final data = existingDoc.data();
        data['id'] = existingDoc.id;
        return data;
      }

      // Create new university
      final universityData = {
        'name': name,
        'country': 'Zimbabwe',
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      final docRef = await _firestore
          .collection(FirebaseCollections.universities)
          .add(universityData);

      final doc = await docRef.get();
      final data = doc.data()!;
      data['id'] = doc.id;

      print('University created successfully: $data');
      return data;
    } catch (e) {
      print('Error creating university: $e');
      return null;
    }
  }

  // =============================================
  // PRODUCT OPERATIONS
  // =============================================

  static Future<List<Map<String, dynamic>>> getProducts({
    int limit = 20,
    int offset = 0,
    String? category,
    String? university,
    String? searchQuery,
    String? userId,
  }) async {
    try {
      Query query = _firestore
          .collection(FirebaseCollections.products)
          .where('isAvailable', isEqualTo: true)
          .where('status', isEqualTo: 'active')
          .orderBy('createdAt', descending: true)
          .limit(limit);

      if (category != null && category != 'all') {
        query = query.where('category', isEqualTo: category);
      }

      if (university != null) {
        query = query.where('university', isEqualTo: university);
      }

      if (userId != null) {
        query = query.where('userId', isEqualTo: userId);
      }

      final snapshot = await query.get();

      List<Map<String, dynamic>> products = [];

      for (var doc in snapshot.docs) {
        Map<String, dynamic> productData = doc.data() as Map<String, dynamic>;
        productData['id'] = doc.id;

        // Get user data
        if (productData['userId'] != null) {
          final userDoc = await _firestore
              .collection(FirebaseCollections.users)
              .doc(productData['userId'] as String)
              .get();

          if (userDoc.exists) {
            final userData = userDoc.data()!;
            productData['users'] = {
              'first_name': userData['firstName'],
              'last_name': userData['lastName'],
              'profile_image_url': userData['profileImageUrl'],
            };
          }
        }

        products.add(productData);
      }

      // Apply search filter if provided
      if (searchQuery != null && searchQuery.isNotEmpty) {
        products = products.where((product) {
          final title = product['title']?.toString().toLowerCase() ?? '';
          final description =
              product['description']?.toString().toLowerCase() ?? '';
          final query = searchQuery.toLowerCase();
          return title.contains(query) || description.contains(query);
        }).toList();
      }

      return products;
    } catch (e) {
      print('Error getting products: $e');
      return [];
    }
  }

  static Future<Map<String, dynamic>?> getProductById(String id) async {
    try {
      final doc = await _firestore
          .collection(FirebaseCollections.products)
          .doc(id)
          .get();

      if (doc.exists) {
        Map<String, dynamic> productData = doc.data()!;
        productData['id'] = doc.id;

        // Get user data
        if (productData['userId'] != null) {
          final userDoc = await _firestore
              .collection(FirebaseCollections.users)
              .doc(productData['userId'] as String)
              .get();

          if (userDoc.exists) {
            final userData = userDoc.data()!;
            productData['users'] = {
              'first_name': userData['firstName'],
              'last_name': userData['lastName'],
              'profile_image_url': userData['profileImageUrl'],
            };
          }
        }

        return productData;
      }
      return null;
    } catch (e) {
      print('Error getting product by ID: $e');
      return null;
    }
  }

  static Future<Map<String, dynamic>?> createProduct(
    Map<String, dynamic> product,
  ) async {
    try {
      print('=== FIREBASE REPOSITORY DEBUG ===');
      print('Product data being sent to database:');
      product.forEach((key, value) {
        print('  $key: $value (${value.runtimeType})');
      });
      print('==================================');

      // Check for duplicate products
      final duplicateCheck = await _checkForDuplicateProduct(product);
      if (duplicateCheck != null) {
        print('Duplicate product detected: ${duplicateCheck['id']}');
        return duplicateCheck;
      }

      // Ensure required fields are present
      final productData = {
        'userId': product['userId'],
        'title': product['title'],
        'description': product['description'],
        'price': product['price'],
        'currency': product['currency'] ?? 'USD',
        'category': product['category'],
        'condition': product['condition'],
        'images': List<String>.from(product['images'] as List? ?? []),
        'university': product['university'],
        'location': product['location'],
        'isAvailable': product['isAvailable'] ?? true,
        'isFeatured': product['isFeatured'] ?? false,
        'isNegotiable': product['isNegotiable'] ?? true,
        'status': 'active',
        'tags': List<String>.from(product['tags'] as List? ?? []),
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'viewCount': 0,
        'favoriteCount': 0,
        'reviewCount': 0,
        'averageRating': 0.0,
      };

      final docRef = await _firestore
          .collection(FirebaseCollections.products)
          .add(productData);

      // Get the created document
      final doc = await docRef.get();
      Map<String, dynamic> createdProduct = doc.data()!;
      createdProduct['id'] = doc.id;

      // Get user data
      if (createdProduct['userId'] != null) {
        final userDoc = await _firestore
            .collection(FirebaseCollections.users)
            .doc(createdProduct['userId'] as String)
            .get();

        if (userDoc.exists) {
          final userData = userDoc.data()!;
          createdProduct['users'] = {
            'first_name': userData['firstName'],
            'last_name': userData['lastName'],
            'profile_image_url': userData['profileImageUrl'],
          };
        }
      }

      print('Product created successfully: $createdProduct');
      return createdProduct;
    } catch (e) {
      print('Error creating product: $e');
      print('Error type: ${e.runtimeType}');
      return null;
    }
  }

  static Future<Map<String, dynamic>?> updateProduct(
    String id,
    Map<String, dynamic> product,
  ) async {
    try {
      product['updatedAt'] = FieldValue.serverTimestamp();

      await _firestore
          .collection(FirebaseCollections.products)
          .doc(id)
          .update(product);

      return await getProductById(id);
    } catch (e) {
      print('Error updating product: $e');
      return null;
    }
  }

  static Future<bool> deleteProduct(String id) async {
    try {
      await _firestore
          .collection(FirebaseCollections.products)
          .doc(id)
          .delete();

      return true;
    } catch (e) {
      print('Error deleting product: $e');
      return false;
    }
  }

  // Helper method to check for duplicate products
  static Future<Map<String, dynamic>?> _checkForDuplicateProduct(
    Map<String, dynamic> product,
  ) async {
    try {
      // Check for products with same title, user, and similar price (within 10% range)
      final title = product['title'] as String;
      final userId = product['userId'] as String;
      final price = product['price'] as double;
      final priceRange = price * 0.1; // 10% range

      final snapshot = await _firestore
          .collection(FirebaseCollections.products)
          .where('userId', isEqualTo: userId)
          .where('title', isEqualTo: title)
          .where('price', isGreaterThanOrEqualTo: price - priceRange)
          .where('price', isLessThanOrEqualTo: price + priceRange)
          .where('status', isEqualTo: 'active')
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        final doc = snapshot.docs.first;
        final data = doc.data();
        data['id'] = doc.id;

        // Get user data for the duplicate
        if (data['userId'] != null) {
          final userDoc = await _firestore
              .collection(FirebaseCollections.users)
              .doc(data['userId'] as String)
              .get();

          if (userDoc.exists) {
            final userData = userDoc.data()!;
            data['users'] = {
              'first_name': userData['firstName'],
              'last_name': userData['lastName'],
              'profile_image_url': userData['profileImageUrl'],
            };
          }
        }

        return data;
      }

      return null;
    } catch (e) {
      print('Error checking for duplicate product: $e');
      return null;
    }
  }

  // =============================================
  // PRODUCT REVIEW OPERATIONS
  // =============================================

  static Future<Map<String, dynamic>?> createProductReview(
    String productId,
    String userId,
    int rating,
    String comment,
  ) async {
    try {
      // Check if user already reviewed this product
      final existingReview = await _firestore
          .collection(FirebaseCollections.products)
          .doc(productId)
          .collection('reviews')
          .where('userId', isEqualTo: userId)
          .limit(1)
          .get();

      if (existingReview.docs.isNotEmpty) {
        // Update existing review
        final reviewDoc = existingReview.docs.first;
        await reviewDoc.reference.update({
          'rating': rating,
          'comment': comment,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      } else {
        // Create new review
        await _firestore
            .collection(FirebaseCollections.products)
            .doc(productId)
            .collection('reviews')
            .add({
              'userId': userId,
              'rating': rating,
              'comment': comment,
              'createdAt': FieldValue.serverTimestamp(),
              'updatedAt': FieldValue.serverTimestamp(),
            });
      }

      // Update product rating statistics
      await _updateProductRating(productId);

      return {'success': true, 'message': 'Review submitted successfully'};
    } catch (e) {
      print('Error creating product review: $e');
      return null;
    }
  }

  static Future<List<Map<String, dynamic>>> getProductReviews(
    String productId,
  ) async {
    try {
      final snapshot = await _firestore
          .collection(FirebaseCollections.products)
          .doc(productId)
          .collection('reviews')
          .orderBy('createdAt', descending: true)
          .get();

      List<Map<String, dynamic>> reviews = [];

      for (var doc in snapshot.docs) {
        final reviewData = doc.data();
        reviewData['id'] = doc.id;

        // Get user data for each review
        if (reviewData['userId'] != null) {
          final userDoc = await _firestore
              .collection(FirebaseCollections.users)
              .doc(reviewData['userId'] as String)
              .get();

          if (userDoc.exists) {
            final userData = userDoc.data()!;
            reviewData['user'] = {
              'firstName': userData['firstName'],
              'lastName': userData['lastName'],
              'profileImageUrl': userData['profileImageUrl'],
            };
          }
        }

        reviews.add(reviewData);
      }

      return reviews;
    } catch (e) {
      print('Error getting product reviews: $e');
      return [];
    }
  }

  static Future<void> _updateProductRating(String productId) async {
    try {
      final reviewsSnapshot = await _firestore
          .collection(FirebaseCollections.products)
          .doc(productId)
          .collection('reviews')
          .get();

      if (reviewsSnapshot.docs.isEmpty) return;

      double totalRating = 0;
      int reviewCount = reviewsSnapshot.docs.length;

      for (var doc in reviewsSnapshot.docs) {
        final reviewData = doc.data();
        totalRating += (reviewData['rating'] as int).toDouble();
      }

      final averageRating = totalRating / reviewCount;

      await _firestore
          .collection(FirebaseCollections.products)
          .doc(productId)
          .update({
            'averageRating': averageRating,
            'reviewCount': reviewCount,
            'updatedAt': FieldValue.serverTimestamp(),
          });
    } catch (e) {
      print('Error updating product rating: $e');
    }
  }

  // =============================================
  // ACCOMMODATION OPERATIONS
  // =============================================

  static Future<List<Map<String, dynamic>>> getAccommodations({
    int limit = 20,
    int offset = 0,
    String? university,
    String? searchQuery,
    String? userId,
  }) async {
    try {
      Query query = _firestore
          .collection(FirebaseCollections.accommodations)
          .orderBy('createdAt', descending: true)
          .limit(limit);

      if (university != null) {
        query = query.where('university', isEqualTo: university);
      }

      if (userId != null) {
        query = query.where('userId', isEqualTo: userId);
      }

      final snapshot = await query.get();

      List<Map<String, dynamic>> accommodations = [];

      for (var doc in snapshot.docs) {
        Map<String, dynamic> accommodationData =
            doc.data() as Map<String, dynamic>;
        accommodationData['id'] = doc.id;
        accommodations.add(accommodationData);
      }

      // Apply search filter if provided
      if (searchQuery != null && searchQuery.isNotEmpty) {
        accommodations = accommodations.where((accommodation) {
          final title = accommodation['title']?.toString().toLowerCase() ?? '';
          final description =
              accommodation['description']?.toString().toLowerCase() ?? '';
          final query = searchQuery.toLowerCase();
          return title.contains(query) || description.contains(query);
        }).toList();
      }

      return accommodations;
    } catch (e) {
      print('Error getting accommodations: $e');
      return [];
    }
  }

  static Future<Map<String, dynamic>?> getAccommodationById(String id) async {
    try {
      final doc = await _firestore
          .collection(FirebaseCollections.accommodations)
          .doc(id)
          .get();

      if (doc.exists) {
        Map<String, dynamic> accommodationData = doc.data()!;
        accommodationData['id'] = doc.id;
        return accommodationData;
      }
      return null;
    } catch (e) {
      print('Error getting accommodation by ID: $e');
      return null;
    }
  }

  static Future<Map<String, dynamic>?> createAccommodation(
    Map<String, dynamic> accommodation,
  ) async {
    try {
      accommodation['createdAt'] = FieldValue.serverTimestamp();
      accommodation['updatedAt'] = FieldValue.serverTimestamp();

      final docRef = await _firestore
          .collection(FirebaseCollections.accommodations)
          .add(accommodation);

      final doc = await docRef.get();
      Map<String, dynamic> createdAccommodation = doc.data()!;
      createdAccommodation['id'] = doc.id;

      return createdAccommodation;
    } catch (e) {
      print('Error creating accommodation: $e');
      return null;
    }
  }

  static Future<Map<String, dynamic>?> updateAccommodation(
    String id,
    Map<String, dynamic> accommodation,
  ) async {
    try {
      accommodation['updatedAt'] = FieldValue.serverTimestamp();

      await _firestore
          .collection(FirebaseCollections.accommodations)
          .doc(id)
          .update(accommodation);

      return await getAccommodationById(id);
    } catch (e) {
      print('Error updating accommodation: $e');
      return null;
    }
  }

  static Future<bool> deleteAccommodation(String id) async {
    try {
      await _firestore
          .collection(FirebaseCollections.accommodations)
          .doc(id)
          .delete();

      return true;
    } catch (e) {
      print('Error deleting accommodation: $e');
      return false;
    }
  }

  // =============================================
  // EVENT OPERATIONS
  // =============================================

  static Future<List<Map<String, dynamic>>> getEvents({
    int limit = 20,
    int offset = 0,
    String? university,
    String? searchQuery,
    String? userId,
  }) async {
    try {
      Query query = _firestore
          .collection(FirebaseCollections.events)
          .orderBy('createdAt', descending: true)
          .limit(limit);

      if (university != null) {
        query = query.where('university', isEqualTo: university);
      }

      if (userId != null) {
        query = query.where('userId', isEqualTo: userId);
      }

      final snapshot = await query.get();

      List<Map<String, dynamic>> events = [];

      for (var doc in snapshot.docs) {
        Map<String, dynamic> eventData = doc.data() as Map<String, dynamic>;
        eventData['id'] = doc.id;
        events.add(eventData);
      }

      // Apply search filter if provided
      if (searchQuery != null && searchQuery.isNotEmpty) {
        events = events.where((event) {
          final title = event['title']?.toString().toLowerCase() ?? '';
          final description =
              event['description']?.toString().toLowerCase() ?? '';
          final query = searchQuery.toLowerCase();
          return title.contains(query) || description.contains(query);
        }).toList();
      }

      return events;
    } catch (e) {
      print('Error getting events: $e');
      return [];
    }
  }

  static Future<Map<String, dynamic>?> getEventById(String id) async {
    try {
      final doc = await _firestore
          .collection(FirebaseCollections.events)
          .doc(id)
          .get();

      if (doc.exists) {
        Map<String, dynamic> eventData = doc.data()!;
        eventData['id'] = doc.id;
        return eventData;
      }
      return null;
    } catch (e) {
      print('Error getting event by ID: $e');
      return null;
    }
  }

  static Future<Map<String, dynamic>?> createEvent(
    Map<String, dynamic> event,
  ) async {
    try {
      event['createdAt'] = FieldValue.serverTimestamp();
      event['updatedAt'] = FieldValue.serverTimestamp();

      final docRef = await _firestore
          .collection(FirebaseCollections.events)
          .add(event);

      final doc = await docRef.get();
      Map<String, dynamic> createdEvent = doc.data()!;
      createdEvent['id'] = doc.id;

      return createdEvent;
    } catch (e) {
      print('Error creating event: $e');
      return null;
    }
  }

  static Future<Map<String, dynamic>?> updateEvent(
    String id,
    Map<String, dynamic> event,
  ) async {
    try {
      event['updatedAt'] = FieldValue.serverTimestamp();

      await _firestore
          .collection(FirebaseCollections.events)
          .doc(id)
          .update(event);

      return await getEventById(id);
    } catch (e) {
      print('Error updating event: $e');
      return null;
    }
  }

  static Future<bool> deleteEvent(String id) async {
    try {
      await _firestore.collection(FirebaseCollections.events).doc(id).delete();

      return true;
    } catch (e) {
      print('Error deleting event: $e');
      return false;
    }
  }

  // =============================================
  // CATEGORY OPERATIONS
  // =============================================

  static Future<List<Map<String, dynamic>>> getCategories() async {
    try {
      final snapshot = await _firestore
          .collection(FirebaseCollections.categories)
          .orderBy('name')
          .get();

      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      print('Error getting categories: $e');
      return [];
    }
  }

  // =============================================
  // MARKETPLACE OPERATIONS
  // =============================================

  static Future<List<Map<String, dynamic>>> getMarketplaceItems({
    int limit = 20,
    int offset = 0,
    String? category,
    String? university,
    String? searchQuery,
    String? userId,
  }) async {
    try {
      Query query = _firestore
          .collection(FirebaseCollections.products)
          .where('isAvailable', isEqualTo: true)
          .where('status', isEqualTo: 'active')
          .orderBy('createdAt', descending: true)
          .limit(limit);

      if (category != null && category != 'all') {
        query = query.where('category', isEqualTo: category);
      }

      if (university != null) {
        query = query.where('university', isEqualTo: university);
      }

      if (userId != null) {
        query = query.where('userId', isEqualTo: userId);
      }

      final snapshot = await query.get();

      List<Map<String, dynamic>> items = [];

      for (var doc in snapshot.docs) {
        Map<String, dynamic> item = doc.data() as Map<String, dynamic>;
        item['id'] = doc.id;

        // Convert timestamps
        if (item['createdAt'] != null) {
          item['createdAt'] = (item['createdAt'] as Timestamp)
              .toDate()
              .toIso8601String();
        }
        if (item['updatedAt'] != null) {
          item['updatedAt'] = (item['updatedAt'] as Timestamp)
              .toDate()
              .toIso8601String();
        }

        items.add(item);
      }

      return items;
    } catch (e) {
      print('Error getting marketplace items: $e');
      return [];
    }
  }

  static Future<Map<String, dynamic>?> getMarketplaceItemById(String id) async {
    try {
      final doc = await _firestore
          .collection(FirebaseCollections.products)
          .doc(id)
          .get();

      if (doc.exists) {
        Map<String, dynamic> item = doc.data()!;
        item['id'] = doc.id;

        // Convert timestamps
        if (item['createdAt'] != null) {
          item['createdAt'] = (item['createdAt'] as Timestamp)
              .toDate()
              .toIso8601String();
        }
        if (item['updatedAt'] != null) {
          item['updatedAt'] = (item['updatedAt'] as Timestamp)
              .toDate()
              .toIso8601String();
        }

        return item;
      }
      return null;
    } catch (e) {
      print('Error getting marketplace item by ID: $e');
      return null;
    }
  }

  static Future<Map<String, dynamic>?> createMarketplaceItem(
    Map<String, dynamic> item,
  ) async {
    try {
      item['createdAt'] = FieldValue.serverTimestamp();
      item['updatedAt'] = FieldValue.serverTimestamp();

      final docRef = await _firestore
          .collection(FirebaseCollections.products)
          .add(item);

      final doc = await docRef.get();
      Map<String, dynamic> createdItem = doc.data()!;
      createdItem['id'] = doc.id;

      return createdItem;
    } catch (e) {
      print('Error creating marketplace item: $e');
      return null;
    }
  }

  static Future<Map<String, dynamic>?> updateMarketplaceItem(
    String id,
    Map<String, dynamic> item,
  ) async {
    try {
      item['updatedAt'] = FieldValue.serverTimestamp();

      await _firestore
          .collection(FirebaseCollections.products)
          .doc(id)
          .update(item);

      return await getMarketplaceItemById(id);
    } catch (e) {
      print('Error updating marketplace item: $e');
      return null;
    }
  }

  static Future<bool> deleteMarketplaceItem(String id) async {
    try {
      await _firestore
          .collection(FirebaseCollections.products)
          .doc(id)
          .delete();

      return true;
    } catch (e) {
      print('Error deleting marketplace item: $e');
      return false;
    }
  }

  // =============================================
  // CHAT OPERATIONS
  // =============================================

  static Future<List<Map<String, dynamic>>> getChatRooms(String userId) async {
    try {
      final snapshot = await _firestore
          .collection(FirebaseCollections.chatRooms)
          .where('participantIds', arrayContains: userId)
          .orderBy('updatedAt', descending: true)
          .get();

      List<Map<String, dynamic>> chatRooms = [];

      for (var doc in snapshot.docs) {
        Map<String, dynamic> chatRoom = doc.data();
        chatRoom['id'] = doc.id;

        // Convert timestamps
        if (chatRoom['createdAt'] != null) {
          chatRoom['createdAt'] = (chatRoom['createdAt'] as Timestamp)
              .toDate()
              .toIso8601String();
        }
        if (chatRoom['updatedAt'] != null) {
          chatRoom['updatedAt'] = (chatRoom['updatedAt'] as Timestamp)
              .toDate()
              .toIso8601String();
        }

        // Get participant details
        if (chatRoom['participants'] != null) {
          List<Map<String, dynamic>> participants = [];
          for (var participant
              in (chatRoom['participants'] as List<dynamic>? ?? [])) {
            if (participant['userId'] != null) {
              final userDoc = await _firestore
                  .collection(FirebaseCollections.users)
                  .doc(participant['userId'] as String)
                  .get();

              if (userDoc.exists) {
                final userData = userDoc.data()!;
                participants.add({
                  'userId': participant['userId'],
                  'name': '${userData['firstName']} ${userData['lastName']}',
                  'profileImageUrl': userData['profileImageUrl'],
                  'joinedAt': participant['joinedAt'],
                  'lastSeenAt': participant['lastSeenAt'],
                  'isOnline': participant['isOnline'] ?? false,
                  'role': participant['role'] ?? 'member',
                });
              }
            }
          }
          chatRoom['participants'] = participants;
        }

        chatRooms.add(chatRoom);
      }

      return chatRooms;
    } catch (e) {
      print('Error getting chat rooms: $e');
      return [];
    }
  }

  static Future<Map<String, dynamic>?> getChatRoomById(String id) async {
    try {
      final doc = await _firestore
          .collection(FirebaseCollections.chatRooms)
          .doc(id)
          .get();

      if (doc.exists) {
        Map<String, dynamic> chatRoom = doc.data()!;
        chatRoom['id'] = doc.id;

        // Convert timestamps
        if (chatRoom['createdAt'] != null) {
          chatRoom['createdAt'] = (chatRoom['createdAt'] as Timestamp)
              .toDate()
              .toIso8601String();
        }
        if (chatRoom['updatedAt'] != null) {
          chatRoom['updatedAt'] = (chatRoom['updatedAt'] as Timestamp)
              .toDate()
              .toIso8601String();
        }

        return chatRoom;
      }
      return null;
    } catch (e) {
      print('Error getting chat room by ID: $e');
      return null;
    }
  }

  static Future<Map<String, dynamic>?> createChatRoom(
    Map<String, dynamic> chatRoom,
  ) async {
    try {
      chatRoom['createdAt'] = FieldValue.serverTimestamp();
      chatRoom['updatedAt'] = FieldValue.serverTimestamp();

      final docRef = await _firestore
          .collection(FirebaseCollections.chatRooms)
          .add(chatRoom);

      final doc = await docRef.get();
      Map<String, dynamic> createdChatRoom = doc.data()!;
      createdChatRoom['id'] = doc.id;

      return createdChatRoom;
    } catch (e) {
      print('Error creating chat room: $e');
      return null;
    }
  }

  static Future<Map<String, dynamic>?> createDirectChatRoom(
    String userId1,
    String userId2,
  ) async {
    try {
      // Check if chat room already exists
      final existingChat = await _firestore
          .collection(FirebaseCollections.chatRooms)
          .where('type', isEqualTo: 'direct')
          .where('participantIds', arrayContains: userId1)
          .get();

      for (var doc in existingChat.docs) {
        final data = doc.data();
        if ((data['participantIds'] as List<dynamic>?)?.contains(userId2) ==
            true) {
          // Chat room already exists
          final chatRoom = doc.data();
          chatRoom['id'] = doc.id;
          return chatRoom;
        }
      }

      // Get user details
      final user1Doc = await _firestore
          .collection(FirebaseCollections.users)
          .doc(userId1)
          .get();
      final user2Doc = await _firestore
          .collection(FirebaseCollections.users)
          .doc(userId2)
          .get();

      if (!user1Doc.exists || !user2Doc.exists) {
        print('One or both users not found');
        return null;
      }

      final user1Data = user1Doc.data()!;
      final user2Data = user2Doc.data()!;

      final chatRoomData = {
        'name': '${user2Data['firstName']} ${user2Data['lastName']}',
        'type': 'direct',
        'participantIds': [userId1, userId2],
        'participants': [
          {
            'userId': userId1,
            'name': '${user1Data['firstName']} ${user1Data['lastName']}',
            'profileImageUrl': user1Data['profileImageUrl'],
            'joinedAt': FieldValue.serverTimestamp(),
            'isOnline': false,
            'role': 'member',
          },
          {
            'userId': userId2,
            'name': '${user2Data['firstName']} ${user2Data['lastName']}',
            'profileImageUrl': user2Data['profileImageUrl'],
            'joinedAt': FieldValue.serverTimestamp(),
            'isOnline': false,
            'role': 'member',
          },
        ],
        'lastMessage': null,
        'unreadCounts': {userId1: 0, userId2: 0},
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'isActive': true,
      };

      return await createChatRoom(chatRoomData);
    } catch (e) {
      print('Error creating direct chat room: $e');
      return null;
    }
  }

  static Future<Map<String, dynamic>?> updateChatRoom(
    String id,
    Map<String, dynamic> updates,
  ) async {
    try {
      updates['updatedAt'] = FieldValue.serverTimestamp();

      await _firestore
          .collection(FirebaseCollections.chatRooms)
          .doc(id)
          .update(updates);

      return await getChatRoomById(id);
    } catch (e) {
      print('Error updating chat room: $e');
      return null;
    }
  }

  static Future<bool> deleteChatRoom(String id) async {
    try {
      // Delete all messages in the chat room
      final messagesSnapshot = await _firestore
          .collection(FirebaseCollections.messages)
          .where('chatRoomId', isEqualTo: id)
          .get();

      for (var doc in messagesSnapshot.docs) {
        await doc.reference.delete();
      }

      // Delete the chat room
      await _firestore
          .collection(FirebaseCollections.chatRooms)
          .doc(id)
          .delete();

      return true;
    } catch (e) {
      print('Error deleting chat room: $e');
      return false;
    }
  }

  static Future<List<Map<String, dynamic>>> getMessages(
    String chatRoomId,
  ) async {
    try {
      final snapshot = await _firestore
          .collection(FirebaseCollections.messages)
          .where('chatRoomId', isEqualTo: chatRoomId)
          .orderBy('timestamp', descending: false)
          .get();

      List<Map<String, dynamic>> messages = [];

      for (var doc in snapshot.docs) {
        Map<String, dynamic> message = doc.data();
        message['id'] = doc.id;

        // Convert timestamps
        if (message['timestamp'] != null) {
          message['timestamp'] = (message['timestamp'] as Timestamp)
              .toDate()
              .toIso8601String();
        }

        messages.add(message);
      }

      return messages;
    } catch (e) {
      print('Error getting messages: $e');
      return [];
    }
  }

  static Future<Map<String, dynamic>?> sendMessage(
    Map<String, dynamic> message,
  ) async {
    try {
      message['timestamp'] = FieldValue.serverTimestamp();

      final docRef = await _firestore
          .collection(FirebaseCollections.messages)
          .add(message);

      final doc = await docRef.get();
      Map<String, dynamic> sentMessage = doc.data()!;
      sentMessage['id'] = doc.id;

      // Update chat room's last message and timestamp
      await _firestore
          .collection(FirebaseCollections.chatRooms)
          .doc(message['chatRoomId'] as String)
          .update({
            'lastMessage': sentMessage,
            'updatedAt': FieldValue.serverTimestamp(),
          });

      return sentMessage;
    } catch (e) {
      print('Error sending message: $e');
      return null;
    }
  }

  static Future<Map<String, dynamic>?> updateMessage(
    String messageId,
    Map<String, dynamic> updates,
  ) async {
    try {
      await _firestore
          .collection(FirebaseCollections.messages)
          .doc(messageId)
          .update(updates);

      final doc = await _firestore
          .collection(FirebaseCollections.messages)
          .doc(messageId)
          .get();

      if (doc.exists) {
        Map<String, dynamic> message = doc.data()!;
        message['id'] = doc.id;
        return message;
      }
      return null;
    } catch (e) {
      print('Error updating message: $e');
      return null;
    }
  }

  static Future<bool> deleteMessage(String messageId) async {
    try {
      await _firestore
          .collection(FirebaseCollections.messages)
          .doc(messageId)
          .delete();

      return true;
    } catch (e) {
      print('Error deleting message: $e');
      return false;
    }
  }

  static Future<bool> markMessageAsRead(String messageId, String userId) async {
    try {
      await _firestore
          .collection(FirebaseCollections.messages)
          .doc(messageId)
          .update({
            'readBy': FieldValue.arrayUnion([userId]),
          });

      return true;
    } catch (e) {
      print('Error marking message as read: $e');
      return false;
    }
  }

  static Future<bool> markChatRoomAsRead(
    String chatRoomId,
    String userId,
  ) async {
    try {
      // Reset unread count for this user
      await _firestore
          .collection(FirebaseCollections.chatRooms)
          .doc(chatRoomId)
          .update({'unreadCounts.$userId': 0});

      return true;
    } catch (e) {
      print('Error marking chat room as read: $e');
      return false;
    }
  }

  static Future<bool> addReaction(
    String messageId,
    String userId,
    String emoji,
  ) async {
    try {
      await _firestore
          .collection(FirebaseCollections.messages)
          .doc(messageId)
          .update({
            'reactions': FieldValue.arrayUnion(['$userId:$emoji']),
          });

      return true;
    } catch (e) {
      print('Error adding reaction: $e');
      return false;
    }
  }

  static Future<bool> removeReaction(
    String messageId,
    String userId,
    String emoji,
  ) async {
    try {
      await _firestore
          .collection(FirebaseCollections.messages)
          .doc(messageId)
          .update({
            'reactions': FieldValue.arrayRemove(['$userId:$emoji']),
          });

      return true;
    } catch (e) {
      print('Error removing reaction: $e');
      return false;
    }
  }

  // =============================================
  // BOOKING OPERATIONS
  // =============================================

  static Future<Map<String, dynamic>?> createBooking(
    Map<String, dynamic> booking,
  ) async {
    try {
      booking['createdAt'] = FieldValue.serverTimestamp();
      booking['updatedAt'] = FieldValue.serverTimestamp();

      final docRef = await _firestore
          .collection(FirebaseCollections.bookings)
          .add(booking);

      final doc = await docRef.get();
      Map<String, dynamic> createdBooking = doc.data()!;
      createdBooking['id'] = doc.id;

      return createdBooking;
    } catch (e) {
      print('Error creating booking: $e');
      return null;
    }
  }

  static Future<List<Map<String, dynamic>>> getBookings(String userId) async {
    try {
      final snapshot = await _firestore
          .collection(FirebaseCollections.bookings)
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      List<Map<String, dynamic>> bookings = [];

      for (var doc in snapshot.docs) {
        Map<String, dynamic> booking = doc.data();
        booking['id'] = doc.id;

        // Convert timestamps
        if (booking['createdAt'] != null) {
          booking['createdAt'] = (booking['createdAt'] as Timestamp)
              .toDate()
              .toIso8601String();
        }
        if (booking['updatedAt'] != null) {
          booking['updatedAt'] = (booking['updatedAt'] as Timestamp)
              .toDate()
              .toIso8601String();
        }
        if (booking['checkIn'] != null) {
          booking['checkIn'] = (booking['checkIn'] as Timestamp)
              .toDate()
              .toIso8601String();
        }
        if (booking['checkOut'] != null) {
          booking['checkOut'] = (booking['checkOut'] as Timestamp)
              .toDate()
              .toIso8601String();
        }

        bookings.add(booking);
      }

      return bookings;
    } catch (e) {
      print('Error getting bookings: $e');
      return [];
    }
  }

  // =============================================
  // SEARCH OPERATIONS
  // =============================================

  static Future<Map<String, dynamic>> searchAll({
    required String query,
    int limit = 20,
  }) async {
    try {
      final products = await getProducts(searchQuery: query, limit: limit);
      final accommodations = await getAccommodations(
        searchQuery: query,
        limit: limit,
      );
      final events = await getEvents(searchQuery: query, limit: limit);

      return {
        'products': products,
        'accommodations': accommodations,
        'events': events,
      };
    } catch (e) {
      print('Error searching: $e');
      return {
        'products': <Map<String, dynamic>>[],
        'accommodations': <Map<String, dynamic>>[],
        'events': <Map<String, dynamic>>[],
      };
    }
  }

  // =============================================
  // STORAGE OPERATIONS
  // =============================================

  static Future<String?> uploadFile({
    required String bucket,
    required String path,
    required Uint8List fileBytes,
    String? contentType,
  }) async {
    try {
      final ref = _storage.ref().child(bucket).child(path);

      final uploadTask = ref.putData(
        fileBytes,
        SettableMetadata(contentType: contentType),
      );

      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      print('Error uploading file: $e');
      return null;
    }
  }

  static Future<String?> getPublicUrl(String bucket, String path) async {
    try {
      final ref = _storage.ref().child(bucket).child(path);
      return await ref.getDownloadURL();
    } catch (e) {
      print('Error getting public URL: $e');
      return null;
    }
  }

  static Future<bool> deleteFile(String bucket, String path) async {
    try {
      final ref = _storage.ref().child(bucket).child(path);
      await ref.delete();
      return true;
    } catch (e) {
      print('Error deleting file: $e');
      return false;
    }
  }
}
