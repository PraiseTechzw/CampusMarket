/// @Branch: Image Upload Service
///
/// Intelligent image upload service for Firebase Storage
/// Handles image compression, optimization, and upload with progress tracking
library;

import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as path;

import '../repositories/firebase_repository.dart';
import '../config/firebase_config.dart';

class ImageUploadService {
  // Bucket names based on Firebase Storage
  static const String _productsBucket = 'product_images';
  static const String _accommodationsBucket = 'accommodation_images';
  static const String _eventsBucket = 'event_images';
  static const String _avatarsBucket = 'profile_images';

  static const int _maxImageSize = 2 * 1024 * 1024; // 2MB
  static const int _maxWidth = 1920;
  static const int _maxHeight = 1080;
  static const int _quality = 85;

  /// Get the correct bucket name based on type
  static String _getBucketName(String bucketType) {
    switch (bucketType) {
      case 'products':
        return _productsBucket;
      case 'accommodations':
        return _accommodationsBucket;
      case 'events':
        return _eventsBucket;
      case 'avatars':
        return _avatarsBucket;
      default:
        return _productsBucket; // Default to products
    }
  }

  /// Upload multiple images to Firebase Storage with proper error handling
  static Future<List<String>> uploadImages({
    required List<XFile> images,
    required String userId,
    String? productId,
    String bucketType =
        'products', // 'products', 'accommodations', 'events', 'avatars'
    void Function(double)? onProgress,
  }) async {
    final List<String> uploadedUrls = [];
    final int totalImages = images.length;

    print('Starting upload of $totalImages images to Firebase Storage');

    for (int i = 0; i < images.length; i++) {
      try {
        onProgress?.call((i / totalImages) * 100);

        // Read image bytes
        final imageBytes = await images[i].readAsBytes();

        // Get file extension and validate
        String fileExtension = _getFileExtension(images[i].path);

        // If no extension found, try to detect from image bytes
        if (fileExtension.isEmpty) {
          fileExtension = _detectImageTypeFromBytes(imageBytes);
        }

        if (!_isValidImageExtension(fileExtension)) {
          print(
            'Warning: Invalid image extension "$fileExtension" for image ${i + 1}',
          );
          continue;
        }

        // Compress image if needed
        final processedBytes = await _processImage(imageBytes, fileExtension);

        // Generate unique filename
        final fileName = _generateFileName(userId, productId, i, fileExtension);

        // Upload to Firebase Storage
        final downloadUrl = await _uploadToFirebaseStorage(
          processedBytes,
          fileName,
          bucketType,
        );

        if (downloadUrl != null) {
          uploadedUrls.add(downloadUrl);
          print('Successfully uploaded image ${i + 1}: $downloadUrl');
        } else {
          print('Failed to upload image ${i + 1}');
        }
      } catch (e) {
        print('Error uploading image ${i + 1}: $e');
        // Continue with other images even if one fails
      }
    }

    onProgress?.call(100);
    print(
      'Upload completed. ${uploadedUrls.length}/$totalImages images uploaded successfully',
    );
    return uploadedUrls;
  }

  /// Upload image to Firebase Storage
  static Future<String?> _uploadToFirebaseStorage(
    Uint8List imageBytes,
    String fileName,
    String bucketType,
  ) async {
    try {
      final storage = FirebaseConfig.storage;

      // Create reference to the file
      final ref = storage
          .ref()
          .child(_getBucketName(bucketType))
          .child(fileName);

      // Get content type
      final contentType = _getContentType(_getFileExtension(fileName));

      // Upload the file
      final uploadTask = ref.putData(
        imageBytes,
        SettableMetadata(
          contentType: contentType,
          customMetadata: {
            'uploadedAt': DateTime.now().toIso8601String(),
            'bucketType': bucketType,
          },
        ),
      );

      // Wait for upload to complete
      final snapshot = await uploadTask;

      // Get download URL
      final downloadUrl = await snapshot.ref.getDownloadURL();

      print('File uploaded successfully: $downloadUrl');
      return downloadUrl;
    } catch (e) {
      print('Error uploading to Firebase Storage: $e');
      return null;
    }
  }

  /// Process image (compress if needed)
  static Future<Uint8List> _processImage(
    Uint8List imageBytes,
    String fileExtension,
  ) async {
    try {
      // If image is already small enough, return as is
      if (imageBytes.length <= _maxImageSize) {
        return imageBytes;
      }

      // Decode image
      final image = img.decodeImage(imageBytes);
      if (image == null) {
        print('Warning: Failed to decode image, using original bytes');
        return imageBytes;
      }

      // Calculate new dimensions while maintaining aspect ratio
      int newWidth = image.width;
      int newHeight = image.height;

      if (image.width > _maxWidth || image.height > _maxHeight) {
        final aspectRatio = image.width / image.height;

        if (image.width > image.height) {
          newWidth = _maxWidth;
          newHeight = (_maxWidth / aspectRatio).round();
        } else {
          newHeight = _maxHeight;
          newWidth = (_maxHeight * aspectRatio).round();
        }
      }

      // Resize image
      final resizedImage = img.copyResize(
        image,
        width: newWidth,
        height: newHeight,
        interpolation: img.Interpolation.linear,
      );

      // Encode with quality
      Uint8List compressedBytes;
      if (fileExtension == 'png') {
        compressedBytes = Uint8List.fromList(img.encodePng(resizedImage));
      } else {
        compressedBytes = Uint8List.fromList(
          img.encodeJpg(resizedImage, quality: _quality),
        );
      }

      print(
        'Image compressed: ${imageBytes.length} -> ${compressedBytes.length} bytes',
      );
      return compressedBytes;
    } catch (e) {
      print('Error processing image: $e');
      return imageBytes; // Return original if processing fails
    }
  }

  /// Get file extension from path
  static String _getFileExtension(String filePath) {
    return path.extension(filePath).toLowerCase().replaceAll('.', '');
  }

  /// Validate image extension
  static bool _isValidImageExtension(String extension) {
    const validExtensions = ['jpg', 'jpeg', 'png', 'gif', 'webp'];
    return validExtensions.contains(extension);
  }

  /// Detect image type from file bytes
  static String _detectImageTypeFromBytes(Uint8List bytes) {
    if (bytes.length < 4) return 'jpg'; // Default fallback

    // Check PNG signature
    if (bytes[0] == 0x89 &&
        bytes[1] == 0x50 &&
        bytes[2] == 0x4E &&
        bytes[3] == 0x47) {
      return 'png';
    }

    // Check JPEG signature
    if (bytes[0] == 0xFF && bytes[1] == 0xD8) {
      return 'jpg';
    }

    // Check GIF signature
    if (bytes.length >= 6) {
      final gif87a =
          bytes[0] == 0x47 &&
          bytes[1] == 0x49 &&
          bytes[2] == 0x46 &&
          bytes[3] == 0x38 &&
          bytes[4] == 0x37 &&
          bytes[5] == 0x61;
      final gif89a =
          bytes[0] == 0x47 &&
          bytes[1] == 0x49 &&
          bytes[2] == 0x46 &&
          bytes[3] == 0x38 &&
          bytes[4] == 0x39 &&
          bytes[5] == 0x61;
      if (gif87a || gif89a) {
        return 'gif';
      }
    }

    // Check WebP signature
    if (bytes.length >= 12) {
      if (bytes[0] == 0x52 &&
          bytes[1] == 0x49 &&
          bytes[2] == 0x46 &&
          bytes[3] == 0x46 &&
          bytes[8] == 0x57 &&
          bytes[9] == 0x45 &&
          bytes[10] == 0x42 &&
          bytes[11] == 0x50) {
        return 'webp';
      }
    }

    // Default to JPEG if we can't detect
    return 'jpg';
  }

  /// Generate unique filename
  static String _generateFileName(
    String userId,
    String? productId,
    int index,
    String extension,
  ) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final productPrefix = productId != null ? '${productId}_' : '';
    return '${productPrefix}${userId}_${timestamp}_$index.$extension';
  }

  /// Get content type based on file extension
  static String _getContentType(String extension) {
    switch (extension) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'webp':
        return 'image/webp';
      case 'bmp':
        return 'image/bmp';
      default:
        return 'image/jpeg'; // Default fallback
    }
  }

  /// Delete images from storage
  static Future<bool> deleteImages(
    List<String> imageUrls, {
    String bucketType = 'products',
  }) async {
    try {
      final String bucketName = _getBucketName(bucketType);
      for (final url in imageUrls) {
        final path = _extractPathFromUrl(url, bucketName);
        if (path != null) {
          await FirebaseRepository.deleteFile(bucketName, path);
        }
      }
      return true;
    } catch (e) {
      print('Error deleting images: $e');
      return false;
    }
  }

  /// Extract file path from public URL
  static String? _extractPathFromUrl(String url, String bucketName) {
    try {
      final uri = Uri.parse(url);
      final pathSegments = uri.pathSegments;

      // Find the bucket name and extract path after it
      final bucketIndex = pathSegments.indexOf(bucketName);
      if (bucketIndex != -1 && bucketIndex < pathSegments.length - 1) {
        return pathSegments.sublist(bucketIndex + 1).join('/');
      }

      return null;
    } catch (e) {
      print('Error extracting path from URL: $e');
      return null;
    }
  }

  /// Get image size in human readable format
  static String getImageSizeString(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    } else {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
  }

  /// Check if storage bucket exists and is accessible
  static Future<bool> checkBucketAccess(String bucketName) async {
    try {
      // Try to list files in the bucket to check if it's accessible
      final storage = FirebaseConfig.storage;
      final ref = storage.ref().child(bucketName);

      // Try to get metadata of the bucket reference
      // This will succeed if the bucket exists and we have access
      await ref.listAll();
      print('Firebase Storage bucket "$bucketName" is accessible');
      return true;
    } catch (e) {
      // Check if it's just a permission issue or bucket doesn't exist
      if (e.toString().contains('storage/unauthorized') ||
          e.toString().contains('storage/unauthenticated')) {
        print(
          'Firebase Storage access denied for "$bucketName". Check security rules.',
        );
        return false;
      } else if (e.toString().contains('storage/bucket-not-found')) {
        print(
          'Firebase Storage bucket "$bucketName" not found. Please create it in Firebase Console.',
        );
        return false;
      } else {
        print('Bucket access check for "$bucketName": $e');
        // For other errors, assume bucket is accessible and let upload attempts proceed
        return true;
      }
    }
  }

  /// Validate image file
  static Future<bool> validateImage(XFile image) async {
    try {
      final bytes = await image.readAsBytes();

      // Check file size
      if (bytes.length > ImageUploadService._maxImageSize * 2) {
        // Allow 4MB for validation
        print(
          'Image validation failed: File too large (${bytes.length} bytes)',
        );
        return false;
      }

      // Check file extension
      String fileExtension = _getFileExtension(image.path);

      // If no extension found, try to detect from image bytes
      if (fileExtension.isEmpty) {
        fileExtension = _detectImageTypeFromBytes(bytes);
        print('Detected image type from bytes: $fileExtension');
      }

      if (!_isValidImageExtension(fileExtension)) {
        print('Image validation failed: Invalid extension "$fileExtension"');
        return false;
      }

      // Check if it's a valid image with better error handling
      try {
        final decodedImage = img.decodeImage(bytes);
        if (decodedImage == null) {
          print('Image validation failed: Could not decode image');
          return false;
        }
        print(
          'Image validation passed: ${decodedImage.width}x${decodedImage.height}, $fileExtension',
        );
        return true;
      } catch (decodeError) {
        print('Image validation failed: $decodeError');
        return false;
      }
    } catch (e) {
      print('Error validating image: $e');
      return false;
    }
  }

  // Convenience methods for different upload types

  /// Upload product images
  static Future<List<String>> uploadProductImages({
    required List<XFile> images,
    required String userId,
    String? productId,
    void Function(double)? onProgress,
  }) => uploadImages(
    images: images,
    userId: userId,
    productId: productId,
    bucketType: 'products',
    onProgress: onProgress,
  );

  /// Upload accommodation images
  static Future<List<String>> uploadAccommodationImages({
    required List<XFile> images,
    required String userId,
    String? accommodationId,
    void Function(double)? onProgress,
  }) => uploadImages(
    images: images,
    userId: userId,
    productId: accommodationId,
    bucketType: 'accommodations',
    onProgress: onProgress,
  );

  /// Upload event images
  static Future<List<String>> uploadEventImages({
    required List<XFile> images,
    required String userId,
    String? eventId,
    void Function(double)? onProgress,
  }) => uploadImages(
    images: images,
    userId: userId,
    productId: eventId,
    bucketType: 'events',
    onProgress: onProgress,
  );

  /// Upload avatar image
  static Future<String?> uploadAvatar({
    required XFile image,
    required String userId,
    void Function(double)? onProgress,
  }) async {
    final results = await uploadImages(
      images: [image],
      userId: userId,
      bucketType: 'avatars',
      onProgress: onProgress,
    );
    return results.isNotEmpty ? results.first : null;
  }

  /// Upload single image (convenience method)
  static Future<String?> uploadSingleImage({
    required XFile image,
    required String userId,
    String? productId,
    String bucketType = 'products',
    void Function(double)? onProgress,
  }) async {
    final results = await uploadImages(
      images: [image],
      userId: userId,
      productId: productId,
      bucketType: bucketType,
      onProgress: onProgress,
    );
    return results.isNotEmpty ? results.first : null;
  }

  /// Delete image from Firebase Storage
  static Future<bool> deleteImage(String imageUrl) async {
    try {
      final storage = FirebaseConfig.storage;

      // Extract path from URL
      final ref = storage.refFromURL(imageUrl);
      await ref.delete();

      print('Image deleted successfully: $imageUrl');
      return true;
    } catch (e) {
      print('Error deleting image: $e');
      return false;
    }
  }

  /// Get image metadata
  static Future<Map<String, dynamic>?> getImageMetadata(String imageUrl) async {
    try {
      final storage = FirebaseConfig.storage;

      final ref = storage.refFromURL(imageUrl);
      final metadata = await ref.getMetadata();

      return {
        'name': metadata.name,
        'size': metadata.size,
        'contentType': metadata.contentType,
        'timeCreated': metadata.timeCreated,
        'updated': metadata.updated,
        'customMetadata': metadata.customMetadata,
      };
    } catch (e) {
      print('Error getting image metadata: $e');
      return null;
    }
  }
}
