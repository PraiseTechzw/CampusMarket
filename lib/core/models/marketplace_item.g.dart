// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'marketplace_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MarketplaceItem _$MarketplaceItemFromJson(Map<String, dynamic> json) =>
    MarketplaceItem(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      currency: json['currency'] as String? ?? 'USD',
      images:
          (json['images'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      category: json['category'] as String,
      subcategory: json['subcategory'] as String?,
      condition: json['condition'] as String? ?? 'good',
      userId: json['userId'] as String,
      university: json['university'] as String?,
      location: json['location'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      tags:
          (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
          const [],
      isAvailable: json['isAvailable'] as bool? ?? true,
      isFeatured: json['isFeatured'] as bool? ?? false,
      isNegotiable: json['isNegotiable'] as bool? ?? true,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      viewCount: (json['viewCount'] as num?)?.toInt() ?? 0,
      favoriteCount: (json['favoriteCount'] as num?)?.toInt() ?? 0,
      status: json['status'] as String? ?? 'active',
      sellerName: json['sellerName'] as String?,
      sellerProfileImage: json['sellerProfileImage'] as String?,
    );

Map<String, dynamic> _$MarketplaceItemToJson(MarketplaceItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'price': instance.price,
      'currency': instance.currency,
      'images': instance.images,
      'category': instance.category,
      'subcategory': instance.subcategory,
      'condition': instance.condition,
      'userId': instance.userId,
      'university': instance.university,
      'location': instance.location,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'tags': instance.tags,
      'isAvailable': instance.isAvailable,
      'isFeatured': instance.isFeatured,
      'isNegotiable': instance.isNegotiable,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'viewCount': instance.viewCount,
      'favoriteCount': instance.favoriteCount,
      'status': instance.status,
      'sellerName': instance.sellerName,
      'sellerProfileImage': instance.sellerProfileImage,
    };

ItemCategory _$ItemCategoryFromJson(Map<String, dynamic> json) => ItemCategory(
  id: json['id'] as String,
  name: json['name'] as String,
  icon: json['icon'] as String,
  subcategories: (json['subcategories'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  color: json['color'] as String,
);

Map<String, dynamic> _$ItemCategoryToJson(ItemCategory instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'icon': instance.icon,
      'subcategories': instance.subcategories,
      'color': instance.color,
    };
