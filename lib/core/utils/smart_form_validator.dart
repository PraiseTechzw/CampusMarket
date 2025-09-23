/// @Branch: Smart Form Validator
///
/// Intelligent form validation with real-time feedback
/// Provides smart suggestions and validation rules
library;

class SmartFormValidator {
  static const Map<String, List<String>> _categorySubcategories = {
    'electronics': [
      'smartphones',
      'laptops',
      'tablets',
      'headphones',
      'cameras',
      'gaming',
      'accessories',
      'other',
    ],
    'books': [
      'textbooks',
      'novels',
      'academic',
      'reference',
      'magazines',
      'comics',
      'other',
    ],
    'clothing': [
      'men',
      'women',
      'shoes',
      'accessories',
      'formal',
      'casual',
      'sports',
      'other',
    ],
    'furniture': [
      'chairs',
      'tables',
      'beds',
      'storage',
      'decor',
      'outdoor',
      'other',
    ],
    'sports': [
      'fitness',
      'outdoor',
      'team_sports',
      'equipment',
      'clothing',
      'shoes',
      'other',
    ],
    'accessories': ['jewelry', 'watches', 'bags', 'wallets', 'belts', 'other'],
    'home': [
      'kitchen',
      'bathroom',
      'bedroom',
      'living_room',
      'decor',
      'appliances',
      'other',
    ],
  };

  static const Map<String, List<String>> _priceSuggestions = {
    'electronics': ['50', '100', '200', '500', '1000'],
    'books': ['10', '20', '30', '50', '100'],
    'clothing': ['15', '25', '50', '75', '150'],
    'furniture': ['50', '100', '200', '500', '1000'],
    'sports': ['25', '50', '100', '200', '500'],
    'accessories': ['10', '20', '30', '50', '100'],
    'home': ['20', '40', '80', '150', '300'],
  };

  static const Map<String, String> _conditionDescriptions = {
    'excellent': 'Like new, barely used',
    'good': 'Minor wear, fully functional',
    'fair': 'Some wear, works well',
    'poor': 'Heavy wear, may need repair',
  };

  /// Validate title with smart suggestions
  static String? validateTitle(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Title is required';
    }

    final trimmed = value.trim();
    if (trimmed.length < 3) {
      return 'Title must be at least 3 characters';
    }

    if (trimmed.length > 100) {
      return 'Title must be less than 100 characters';
    }

    // Check for spam patterns
    if (_isSpamTitle(trimmed)) {
      return 'Title appears to be spam. Please use a descriptive title.';
    }

    return null;
  }

  /// Validate description with smart suggestions
  static String? validateDescription(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Description is required';
    }

    final trimmed = value.trim();
    if (trimmed.length < 10) {
      return 'Description must be at least 10 characters';
    }

    if (trimmed.length > 1000) {
      return 'Description must be less than 1000 characters';
    }

    // Check for spam patterns
    if (_isSpamDescription(trimmed)) {
      return 'Description appears to be spam. Please provide a genuine description.';
    }

    return null;
  }

  /// Validate price with smart suggestions
  static String? validatePrice(String? value, String category) {
    if (value == null || value.trim().isEmpty) {
      return 'Price is required';
    }

    final price = double.tryParse(value.trim());
    if (price == null) {
      return 'Please enter a valid price';
    }

    if (price <= 0) {
      return 'Price must be greater than 0';
    }

    if (price > 100000) {
      return 'Price seems too high. Please verify the amount.';
    }

    // Category-specific price validation
    final suggestions = _priceSuggestions[category] ?? [];
    if (suggestions.isNotEmpty) {
      final suggestedPrices = suggestions.map(double.parse).toList();
      final minSuggested = suggestedPrices.reduce((a, b) => a < b ? a : b);
      final maxSuggested = suggestedPrices.reduce((a, b) => a > b ? a : b);

      if (price < minSuggested * 0.1) {
        return 'Price seems too low for this category';
      }

      if (price > maxSuggested * 10) {
        return 'Price seems too high for this category';
      }
    }

    return null;
  }

  /// Validate location
  static String? validateLocation(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Location is required';
    }

    final trimmed = value.trim();
    if (trimmed.length < 2) {
      return 'Please enter a valid location';
    }

    return null;
  }

  /// Get subcategories for a category
  static List<String> getSubcategories(String category) => _categorySubcategories[category] ?? ['other'];

  /// Get price suggestions for a category
  static List<String> getPriceSuggestions(String category) => _priceSuggestions[category] ?? ['10', '25', '50', '100', '200'];

  /// Get condition description
  static String getConditionDescription(String condition) => _conditionDescriptions[condition] ?? 'Unknown condition';

  /// Generate smart title suggestions based on category
  static List<String> generateTitleSuggestions(
    String category,
    String subcategory,
  ) {
    final suggestions = <String>[];

    switch (category) {
      case 'electronics':
        switch (subcategory) {
          case 'smartphones':
            suggestions.addAll([
              'iPhone 13 Pro - Excellent Condition',
              'Samsung Galaxy S21 - Like New',
              'Google Pixel 6 - Unlocked',
            ]);
            break;
          case 'laptops':
            suggestions.addAll([
              'MacBook Pro 13" - M1 Chip',
              'Dell XPS 15 - Gaming Laptop',
              'HP Pavilion - Student Laptop',
            ]);
            break;
        }
        break;
      case 'books':
        suggestions.addAll([
          'Calculus Textbook - 3rd Edition',
          'Organic Chemistry - Used',
          'Introduction to Psychology',
        ]);
        break;
      case 'clothing':
        suggestions.addAll([
          'Nike Air Max - Size 10',
          "Levi's Jeans - 32x32",
          'Winter Jacket - Medium',
        ]);
        break;
    }

    return suggestions;
  }

  /// Check if title appears to be spam
  static bool _isSpamTitle(String title) {
    final spamPatterns = [
      RegExp(
        r'\b(click here|buy now|urgent|limited time)\b',
        caseSensitive: false,
      ),
      RegExp(r'\$\$\$|\b(cheap|free|deal)\b', caseSensitive: false),
      RegExp('[!]{2,}|[?]{2,}'), // Multiple exclamation or question marks
    ];

    return spamPatterns.any((pattern) => pattern.hasMatch(title));
  }

  /// Check if description appears to be spam
  static bool _isSpamDescription(String description) {
    final spamPatterns = [
      RegExp(
        r'\b(click here|buy now|urgent|limited time|act fast)\b',
        caseSensitive: false,
      ),
      RegExp(r'\$\$\$|\b(cheap|free|deal|discount)\b', caseSensitive: false),
      RegExp('[!]{3,}|[?]{3,}'), // Multiple exclamation or question marks
      RegExp('http[s]?://'), // URLs
    ];

    return spamPatterns.any((pattern) => pattern.hasMatch(description));
  }

  /// Get validation tips for a field
  static String getValidationTip(String fieldName) {
    switch (fieldName) {
      case 'title':
        return 'Use a clear, descriptive title that highlights the key features';
      case 'description':
        return 'Include details about condition, age, and any special features';
      case 'price':
        return 'Research similar items to set a competitive price';
      case 'location':
        return 'Be specific about pickup location or delivery area';
      default:
        return 'Please provide accurate information';
    }
  }

  /// Calculate listing quality score
  static int calculateListingQuality({
    required String title,
    required String description,
    required String category,
    required String condition,
    required List<String> images,
    required String location,
  }) {
    int score = 0;

    // Title quality (0-20 points)
    if (title.length >= 10 && title.length <= 80) {
      score += 20;
    } else if (title.length >= 5)
      score += 10;

    // Description quality (0-25 points)
    if (description.length >= 50) {
      score += 25;
    } else if (description.length >= 20)
      score += 15;
    else if (description.length >= 10)
      score += 10;

    // Category completeness (0-10 points)
    if (category.isNotEmpty) score += 10;

    // Condition specified (0-10 points)
    if (condition.isNotEmpty) score += 10;

    // Images (0-20 points)
    if (images.length >= 3) {
      score += 20;
    } else if (images.isNotEmpty)
      score += 10;

    // Location (0-15 points)
    if (location.length >= 5) {
      score += 15;
    } else if (location.isNotEmpty)
      score += 5;

    return score;
  }

  /// Get quality improvement suggestions
  static List<String> getQualitySuggestions({
    required String title,
    required String description,
    required List<String> images,
    required String location,
  }) {
    final suggestions = <String>[];

    if (title.length < 10) {
      suggestions.add(
        'Make your title more descriptive (at least 10 characters)',
      );
    }

    if (description.length < 50) {
      suggestions.add(
        'Add more details to your description (at least 50 characters)',
      );
    }

    if (images.length < 3) {
      suggestions.add('Add more photos to showcase your item (3+ recommended)');
    }

    if (location.length < 5) {
      suggestions.add('Provide a more specific location');
    }

    return suggestions;
  }
}
