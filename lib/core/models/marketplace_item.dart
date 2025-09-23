/// @Branch: Marketplace Item Model Implementation
///
/// Marketplace item data model for buy/sell functionality
/// Represents products and services in the Campus Market
library;

import 'package:json_annotation/json_annotation.dart';

part 'marketplace_item.g.dart';

@JsonSerializable()
class MarketplaceItem {
  const MarketplaceItem({
    required this.id,
    required this.title,
    required this.description,
    this.price = 0.0,
    this.currency = 'USD',
    this.images = const [],
    required this.category,
    this.subcategory,
    this.condition = 'good',
    required this.userId,
    this.university,
    this.location,
    this.latitude,
    this.longitude,
    this.tags = const [],
    this.isAvailable = true,
    this.isFeatured = false,
    this.isNegotiable = true,
    required this.createdAt,
    required this.updatedAt,
    this.viewCount = 0,
    this.favoriteCount = 0,
    this.status = 'active',
    this.sellerName,
    this.sellerProfileImage,
  });

  factory MarketplaceItem.fromJson(Map<String, dynamic> json) =>
      _$MarketplaceItemFromJson(json);
  final String id;
  final String title;
  final String description;
  final double price;
  final String currency;
  final List<String> images;
  final String category;
  final String? subcategory;
  final String condition;
  final String userId;
  final String? university;
  final String? location;
  final double? latitude;
  final double? longitude;
  final List<String> tags;
  final bool isAvailable;
  final bool isFeatured;
  final bool isNegotiable;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int viewCount;
  final int favoriteCount;
  final String status;
  final String? sellerName;
  final String? sellerProfileImage;

  String get formattedPrice => '$currency ${price.toStringAsFixed(2)}';
  String get primaryImage => images.isNotEmpty ? images.first : '';
  bool get hasMultipleImages => images.length > 1;
  String get timeAgo => _getTimeAgo(createdAt);
  Map<String, dynamic> toJson() => _$MarketplaceItemToJson(this);

  MarketplaceItem copyWith({
    String? id,
    String? title,
    String? description,
    double? price,
    String? currency,
    List<String>? images,
    String? category,
    String? subcategory,
    String? condition,
    String? userId,
    String? university,
    String? location,
    double? latitude,
    double? longitude,
    List<String>? tags,
    bool? isAvailable,
    bool? isFeatured,
    bool? isNegotiable,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? viewCount,
    int? favoriteCount,
    String? status,
    String? sellerName,
    String? sellerProfileImage,
  }) => MarketplaceItem(
    id: id ?? this.id,
    title: title ?? this.title,
    description: description ?? this.description,
    price: price ?? this.price,
    currency: currency ?? this.currency,
    images: images ?? this.images,
    category: category ?? this.category,
    subcategory: subcategory ?? this.subcategory,
    condition: condition ?? this.condition,
    userId: userId ?? this.userId,
    university: university ?? this.university,
    location: location ?? this.location,
    latitude: latitude ?? this.latitude,
    longitude: longitude ?? this.longitude,
    tags: tags ?? this.tags,
    isAvailable: isAvailable ?? this.isAvailable,
    isFeatured: isFeatured ?? this.isFeatured,
    isNegotiable: isNegotiable ?? this.isNegotiable,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    viewCount: viewCount ?? this.viewCount,
    favoriteCount: favoriteCount ?? this.favoriteCount,
    status: status ?? this.status,
    sellerName: sellerName ?? this.sellerName,
    sellerProfileImage: sellerProfileImage ?? this.sellerProfileImage,
  );

  String _getTimeAgo(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 7) {
      return '${(difference.inDays / 7).floor()}w ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}

// Item condition and status are now handled as strings to match database schema

@JsonSerializable()
class ItemCategory {
  const ItemCategory({
    required this.id,
    required this.name,
    required this.icon,
    required this.subcategories,
    required this.color,
  });

  factory ItemCategory.fromJson(Map<String, dynamic> json) =>
      _$ItemCategoryFromJson(json);
  final String id;
  final String name;
  final String icon;
  final List<String> subcategories;
  final String color;
  Map<String, dynamic> toJson() => _$ItemCategoryToJson(this);
}
