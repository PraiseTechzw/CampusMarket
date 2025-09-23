// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'accommodation.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Accommodation _$AccommodationFromJson(
  Map<String, dynamic> json,
) => Accommodation(
  id: json['id'] as String,
  title: json['title'] as String,
  description: json['description'] as String,
  price: (json['price'] as num?)?.toDouble() ?? 0.0,
  currency: json['currency'] as String? ?? 'USD',
  pricePeriod: json['pricePeriod'] as String? ?? 'month',
  imageUrls:
      (json['imageUrls'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  type: json['type'] as String,
  bedrooms: (json['bedrooms'] as num?)?.toInt() ?? 0,
  bathrooms: (json['bathrooms'] as num?)?.toInt() ?? 0,
  area: (json['area'] as num?)?.toDouble(),
  areaUnit: json['areaUnit'] as String? ?? 'sqft',
  hostId: json['hostId'] as String,
  hostName: json['hostName'] as String,
  hostProfileImage: json['hostProfileImage'] as String?,
  hostEmail: json['hostEmail'] as String?,
  hostPhone: json['hostPhone'] as String?,
  address: json['address'] as String,
  latitude: (json['latitude'] as num?)?.toDouble(),
  longitude: (json['longitude'] as num?)?.toDouble(),
  amenities:
      (json['amenities'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  rules:
      (json['rules'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  isAvailable: json['isAvailable'] as bool? ?? true,
  isFeatured: json['isFeatured'] as bool? ?? false,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
  viewCount: (json['viewCount'] as num?)?.toInt() ?? 0,
  favoriteCount: (json['favoriteCount'] as num?)?.toInt() ?? 0,
  status:
      $enumDecodeNullable(_$AccommodationStatusEnumMap, json['status']) ??
      AccommodationStatus.active,
  availability:
      (json['availability'] as List<dynamic>?)
          ?.map((e) => AvailabilityPeriod.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  roommatePreferences:
      (json['roommatePreferences'] as List<dynamic>?)
          ?.map((e) => RoommatePreference.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
);

Map<String, dynamic> _$AccommodationToJson(Accommodation instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'price': instance.price,
      'currency': instance.currency,
      'pricePeriod': instance.pricePeriod,
      'imageUrls': instance.imageUrls,
      'type': instance.type,
      'bedrooms': instance.bedrooms,
      'bathrooms': instance.bathrooms,
      'area': instance.area,
      'areaUnit': instance.areaUnit,
      'hostId': instance.hostId,
      'hostName': instance.hostName,
      'hostProfileImage': instance.hostProfileImage,
      'hostEmail': instance.hostEmail,
      'hostPhone': instance.hostPhone,
      'address': instance.address,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'amenities': instance.amenities,
      'rules': instance.rules,
      'isAvailable': instance.isAvailable,
      'isFeatured': instance.isFeatured,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'viewCount': instance.viewCount,
      'favoriteCount': instance.favoriteCount,
      'status': _$AccommodationStatusEnumMap[instance.status]!,
      'availability': instance.availability,
      'roommatePreferences': instance.roommatePreferences,
    };

const _$AccommodationStatusEnumMap = {
  AccommodationStatus.draft: 'draft',
  AccommodationStatus.pending: 'pending',
  AccommodationStatus.active: 'active',
  AccommodationStatus.rented: 'rented',
  AccommodationStatus.rejected: 'rejected',
  AccommodationStatus.archived: 'archived',
};

AvailabilityPeriod _$AvailabilityPeriodFromJson(Map<String, dynamic> json) =>
    AvailabilityPeriod(
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      isAvailable: json['isAvailable'] as bool? ?? true,
      notes: json['notes'] as String?,
    );

Map<String, dynamic> _$AvailabilityPeriodToJson(AvailabilityPeriod instance) =>
    <String, dynamic>{
      'startDate': instance.startDate.toIso8601String(),
      'endDate': instance.endDate.toIso8601String(),
      'isAvailable': instance.isAvailable,
      'notes': instance.notes,
    };

RoommatePreference _$RoommatePreferenceFromJson(Map<String, dynamic> json) =>
    RoommatePreference(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      isRequired: json['isRequired'] as bool? ?? false,
      options:
          (json['options'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
    );

Map<String, dynamic> _$RoommatePreferenceToJson(RoommatePreference instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'isRequired': instance.isRequired,
      'options': instance.options,
    };
