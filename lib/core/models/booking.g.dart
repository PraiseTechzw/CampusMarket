// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'booking.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Booking _$BookingFromJson(Map<String, dynamic> json) => Booking(
  id: json['id'] as String,
  userId: json['userId'] as String,
  userName: json['userName'] as String,
  userEmail: json['userEmail'] as String,
  userPhone: json['userPhone'] as String,
  itemId: json['itemId'] as String,
  itemType: $enumDecode(_$BookingItemTypeEnumMap, json['itemType']),
  itemTitle: json['itemTitle'] as String,
  itemImage: json['itemImage'] as String,
  hostId: json['hostId'] as String,
  hostName: json['hostName'] as String,
  hostEmail: json['hostEmail'] as String,
  hostPhone: json['hostPhone'] as String,
  status: $enumDecode(_$BookingStatusEnumMap, json['status']),
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
  checkIn: json['checkIn'] == null
      ? null
      : DateTime.parse(json['checkIn'] as String),
  checkOut: json['checkOut'] == null
      ? null
      : DateTime.parse(json['checkOut'] as String),
  guests: (json['guests'] as num?)?.toInt(),
  totalAmount: (json['totalAmount'] as num?)?.toDouble(),
  currency: json['currency'] as String? ?? 'USD',
  paymentStatus: json['paymentStatus'] as String? ?? 'pending',
  paymentMethod: json['paymentMethod'] as String?,
  specialRequests: json['specialRequests'] as String?,
  notes: json['notes'] as String?,
  cancellationReason: json['cancellationReason'] as String?,
  refundAmount: (json['refundAmount'] as num?)?.toDouble(),
);

Map<String, dynamic> _$BookingToJson(Booking instance) => <String, dynamic>{
  'id': instance.id,
  'userId': instance.userId,
  'userName': instance.userName,
  'userEmail': instance.userEmail,
  'userPhone': instance.userPhone,
  'itemId': instance.itemId,
  'itemType': _$BookingItemTypeEnumMap[instance.itemType]!,
  'itemTitle': instance.itemTitle,
  'itemImage': instance.itemImage,
  'hostId': instance.hostId,
  'hostName': instance.hostName,
  'hostEmail': instance.hostEmail,
  'hostPhone': instance.hostPhone,
  'status': _$BookingStatusEnumMap[instance.status]!,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
  'checkIn': instance.checkIn?.toIso8601String(),
  'checkOut': instance.checkOut?.toIso8601String(),
  'guests': instance.guests,
  'totalAmount': instance.totalAmount,
  'currency': instance.currency,
  'paymentStatus': instance.paymentStatus,
  'paymentMethod': instance.paymentMethod,
  'specialRequests': instance.specialRequests,
  'notes': instance.notes,
  'cancellationReason': instance.cancellationReason,
  'refundAmount': instance.refundAmount,
};

const _$BookingItemTypeEnumMap = {
  BookingItemType.accommodation: 'accommodation',
  BookingItemType.event: 'event',
};

const _$BookingStatusEnumMap = {
  BookingStatus.pending: 'pending',
  BookingStatus.confirmed: 'confirmed',
  BookingStatus.cancelled: 'cancelled',
  BookingStatus.completed: 'completed',
  BookingStatus.refunded: 'refunded',
};
