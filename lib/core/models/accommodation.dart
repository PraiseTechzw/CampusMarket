/// @Branch: Accommodation Model Implementation
///
/// Accommodation data model for room/housing listings
/// Represents housing options in the Campus Market
library;

import 'package:json_annotation/json_annotation.dart';

part 'accommodation.g.dart';

@JsonSerializable()
class Accommodation {
  const Accommodation({
    required this.id,
    required this.title,
    required this.description,
    this.price = 0.0,
    this.currency = 'USD',
    this.pricePeriod = 'month',
    this.imageUrls = const [],
    required this.type,
    this.bedrooms = 0,
    this.bathrooms = 0,
    this.area,
    this.areaUnit = 'sqft',
    required this.hostId,
    required this.hostName,
    this.hostProfileImage,
    this.hostEmail,
    this.hostPhone,
    required this.address,
    this.latitude,
    this.longitude,
    this.amenities = const [],
    this.rules = const [],
    this.isAvailable = true,
    this.isFeatured = false,
    required this.createdAt,
    required this.updatedAt,
    this.viewCount = 0,
    this.favoriteCount = 0,
    this.status = AccommodationStatus.active,
    this.availability = const [],
    this.roommatePreferences = const [],
  });

  factory Accommodation.fromJson(Map<String, dynamic> json) =>
      _$AccommodationFromJson(json);
  final String id;
  final String title;
  final String description;
  final double price;
  final String currency;
  final String pricePeriod; // per month, per week, etc.
  final List<String> imageUrls;
  final String type;
  final int bedrooms;
  final int bathrooms;
  final double? area;
  final String areaUnit;
  final String hostId;
  final String hostName;
  final String? hostProfileImage;
  final String? hostEmail;
  final String? hostPhone;
  final String address;
  final double? latitude;
  final double? longitude;
  final List<String> amenities;
  final List<String> rules;
  final bool isAvailable;
  final bool isFeatured;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int viewCount;
  final int favoriteCount;
  final AccommodationStatus status;
  final List<AvailabilityPeriod> availability;
  final List<RoommatePreference> roommatePreferences;

  String get formattedPrice =>
      '$currency ${price.toStringAsFixed(0)}/$pricePeriod';
  String get primaryImage => imageUrls.isNotEmpty ? imageUrls.first : '';
  bool get hasMultipleImages => imageUrls.length > 1;
  String get timeAgo => _getTimeAgo(createdAt);
  String get roomInfo =>
      '$bedrooms bed${bedrooms != 1 ? 's' : ''}, $bathrooms bath${bathrooms != 1 ? 's' : ''}';
  String get memberSince => _getMemberSince(createdAt);
  String get rating => _getRating(favoriteCount, viewCount);
  String get hostDisplayName => hostName.isNotEmpty ? hostName : 'Unknown Host';
  String get propertyTitle => title.isNotEmpty ? title : 'Untitled Property';
  String get propertyAddress =>
      address.isNotEmpty ? address : 'Address not available';
  String get propertyDescription =>
      description.isNotEmpty ? description : 'No description available';
  String get hostContactPhone => hostPhone?.isNotEmpty == true
      ? hostPhone!
      : 'Contact host for phone number';
  String get hostContactEmail =>
      hostEmail?.isNotEmpty == true ? hostEmail! : 'Contact host for email';

  String get roomTypeDisplayName {
    switch (type.toLowerCase()) {
      case 'full_room':
        return 'Full Room';
      case '2_room_share':
        return '2 Room Share';
      case '3_room_share':
        return '3 Room Share';
      case 'apartment':
        return 'Apartment';
      case 'house':
        return 'House';
      case 'room':
        return 'Room';
      case 'studio':
        return 'Studio';
      case 'shared_room':
        return 'Shared Room';
      default:
        return type;
    }
  }

  Map<String, dynamic> toJson() => _$AccommodationToJson(this);

  Accommodation copyWith({
    String? id,
    String? title,
    String? description,
    double? price,
    String? currency,
    String? pricePeriod,
    List<String>? imageUrls,
    String? type,
    int? bedrooms,
    int? bathrooms,
    double? area,
    String? areaUnit,
    String? hostId,
    String? hostName,
    String? hostProfileImage,
    String? address,
    double? latitude,
    double? longitude,
    List<String>? amenities,
    List<String>? rules,
    bool? isAvailable,
    bool? isFeatured,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? viewCount,
    int? favoriteCount,
    AccommodationStatus? status,
    List<AvailabilityPeriod>? availability,
    List<RoommatePreference>? roommatePreferences,
  }) => Accommodation(
    id: id ?? this.id,
    title: title ?? this.title,
    description: description ?? this.description,
    price: price ?? this.price,
    currency: currency ?? this.currency,
    pricePeriod: pricePeriod ?? this.pricePeriod,
    imageUrls: imageUrls ?? this.imageUrls,
    type: type ?? this.type,
    bedrooms: bedrooms ?? this.bedrooms,
    bathrooms: bathrooms ?? this.bathrooms,
    area: area ?? this.area,
    areaUnit: areaUnit ?? this.areaUnit,
    hostId: hostId ?? this.hostId,
    hostName: hostName ?? this.hostName,
    hostProfileImage: hostProfileImage ?? this.hostProfileImage,
    address: address ?? this.address,
    latitude: latitude ?? this.latitude,
    longitude: longitude ?? this.longitude,
    amenities: amenities ?? this.amenities,
    rules: rules ?? this.rules,
    isAvailable: isAvailable ?? this.isAvailable,
    isFeatured: isFeatured ?? this.isFeatured,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    viewCount: viewCount ?? this.viewCount,
    favoriteCount: favoriteCount ?? this.favoriteCount,
    status: status ?? this.status,
    availability: availability ?? this.availability,
    roommatePreferences: roommatePreferences ?? this.roommatePreferences,
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

  String _getMemberSince(DateTime createdAt) {
    final now = DateTime.now();
    final year = createdAt.year;
    final currentYear = now.year;

    if (year == currentYear) {
      return 'Member since ${createdAt.month}/${year}';
    } else {
      return 'Member since $year';
    }
  }

  String _getRating(int favoriteCount, int viewCount) {
    if (viewCount == 0) return 'New';

    // Calculate a simple rating based on favorites and views
    final ratio = favoriteCount / viewCount;
    double rating;

    if (ratio > 0.1) {
      rating = 4.5 + (ratio * 0.5); // 4.5-5.0 range
    } else if (ratio > 0.05) {
      rating = 4.0 + (ratio * 10); // 4.0-4.5 range
    } else if (ratio > 0.02) {
      rating = 3.5 + (ratio * 25); // 3.5-4.0 range
    } else {
      rating = 3.0 + (ratio * 25); // 3.0-3.5 range
    }

    return '${rating.toStringAsFixed(1)}★';
  }
}

@JsonSerializable()
class AvailabilityPeriod {
  const AvailabilityPeriod({
    required this.startDate,
    required this.endDate,
    this.isAvailable = true,
    this.notes,
  });

  factory AvailabilityPeriod.fromJson(Map<String, dynamic> json) =>
      _$AvailabilityPeriodFromJson(json);
  final DateTime startDate;
  final DateTime endDate;
  final bool isAvailable;
  final String? notes;
  Map<String, dynamic> toJson() => _$AvailabilityPeriodToJson(this);
}

@JsonSerializable()
class RoommatePreference {
  const RoommatePreference({
    required this.id,
    required this.title,
    required this.description,
    this.isRequired = false,
    this.options = const [],
  });

  factory RoommatePreference.fromJson(Map<String, dynamic> json) =>
      _$RoommatePreferenceFromJson(json);
  final String id;
  final String title;
  final String description;
  final bool isRequired;
  final List<String> options;
  Map<String, dynamic> toJson() => _$RoommatePreferenceToJson(this);
}

enum AccommodationType {
  @JsonValue('apartment')
  apartment,
  @JsonValue('house')
  house,
  @JsonValue('room')
  room,
  @JsonValue('studio')
  studio,
  @JsonValue('shared_room')
  sharedRoom,
  @JsonValue('full_room')
  fullRoom,
  @JsonValue('2_room_share')
  twoRoomShare,
  @JsonValue('3_room_share')
  threeRoomShare,
}

enum AccommodationStatus {
  @JsonValue('draft')
  draft,
  @JsonValue('pending')
  pending,
  @JsonValue('active')
  active,
  @JsonValue('rented')
  rented,
  @JsonValue('rejected')
  rejected,
  @JsonValue('archived')
  archived,
}
