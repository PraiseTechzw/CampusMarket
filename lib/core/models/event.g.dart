// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'event.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Event _$EventFromJson(Map<String, dynamic> json) => Event(
  id: json['id'] as String,
  title: json['title'] as String,
  description: json['description'] as String,
  imageUrl: json['imageUrl'] as String?,
  startDate: DateTime.parse(json['startDate'] as String),
  endDate: DateTime.parse(json['endDate'] as String),
  location: json['location'] as String,
  address: json['address'] as String?,
  latitude: (json['latitude'] as num?)?.toDouble(),
  longitude: (json['longitude'] as num?)?.toDouble(),
  organizerId: json['organizerId'] as String,
  organizerName: json['organizerName'] as String,
  organizerProfileImage: json['organizerProfileImage'] as String?,
  type: $enumDecode(_$EventTypeEnumMap, json['type']),
  status:
      $enumDecodeNullable(_$EventStatusEnumMap, json['status']) ??
      EventStatus.active,
  isFree: json['isFree'] as bool? ?? true,
  price: (json['price'] as num?)?.toDouble(),
  currency: json['currency'] as String? ?? 'USD',
  maxAttendees: (json['maxAttendees'] as num?)?.toInt() ?? 0,
  currentAttendees: (json['currentAttendees'] as num?)?.toInt() ?? 0,
  tags:
      (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  requirements:
      (json['requirements'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  requiresApproval: json['requiresApproval'] as bool? ?? false,
  isFeatured: json['isFeatured'] as bool? ?? false,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
  viewCount: (json['viewCount'] as num?)?.toInt() ?? 0,
  favoriteCount: (json['favoriteCount'] as num?)?.toInt() ?? 0,
  tickets:
      (json['tickets'] as List<dynamic>?)
          ?.map((e) => EventTicket.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
);

Map<String, dynamic> _$EventToJson(Event instance) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'description': instance.description,
  'imageUrl': instance.imageUrl,
  'startDate': instance.startDate.toIso8601String(),
  'endDate': instance.endDate.toIso8601String(),
  'location': instance.location,
  'address': instance.address,
  'latitude': instance.latitude,
  'longitude': instance.longitude,
  'organizerId': instance.organizerId,
  'organizerName': instance.organizerName,
  'organizerProfileImage': instance.organizerProfileImage,
  'type': _$EventTypeEnumMap[instance.type]!,
  'status': _$EventStatusEnumMap[instance.status]!,
  'isFree': instance.isFree,
  'price': instance.price,
  'currency': instance.currency,
  'maxAttendees': instance.maxAttendees,
  'currentAttendees': instance.currentAttendees,
  'tags': instance.tags,
  'requirements': instance.requirements,
  'requiresApproval': instance.requiresApproval,
  'isFeatured': instance.isFeatured,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
  'viewCount': instance.viewCount,
  'favoriteCount': instance.favoriteCount,
  'tickets': instance.tickets,
};

const _$EventTypeEnumMap = {
  EventType.academic: 'academic',
  EventType.social: 'social',
  EventType.sports: 'sports',
  EventType.cultural: 'cultural',
  EventType.professional: 'professional',
  EventType.volunteer: 'volunteer',
  EventType.workshop: 'workshop',
  EventType.conference: 'conference',
};

const _$EventStatusEnumMap = {
  EventStatus.draft: 'draft',
  EventStatus.pending: 'pending',
  EventStatus.active: 'active',
  EventStatus.cancelled: 'cancelled',
  EventStatus.completed: 'completed',
  EventStatus.rejected: 'rejected',
};

EventTicket _$EventTicketFromJson(Map<String, dynamic> json) => EventTicket(
  id: json['id'] as String,
  name: json['name'] as String,
  description: json['description'] as String,
  price: (json['price'] as num?)?.toDouble() ?? 0.0,
  currency: json['currency'] as String? ?? 'USD',
  quantity: (json['quantity'] as num?)?.toInt() ?? 0,
  sold: (json['sold'] as num?)?.toInt() ?? 0,
  saleStartDate: json['saleStartDate'] == null
      ? null
      : DateTime.parse(json['saleStartDate'] as String),
  saleEndDate: json['saleEndDate'] == null
      ? null
      : DateTime.parse(json['saleEndDate'] as String),
  isActive: json['isActive'] as bool? ?? true,
);

Map<String, dynamic> _$EventTicketToJson(EventTicket instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'price': instance.price,
      'currency': instance.currency,
      'quantity': instance.quantity,
      'sold': instance.sold,
      'saleStartDate': instance.saleStartDate?.toIso8601String(),
      'saleEndDate': instance.saleEndDate?.toIso8601String(),
      'isActive': instance.isActive,
    };
