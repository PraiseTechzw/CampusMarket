/// @Branch: Booking Model Implementation
///
/// Booking data model for accommodations and events
/// Represents user bookings and reservations
library;

import 'package:json_annotation/json_annotation.dart';

part 'booking.g.dart';

@JsonSerializable()
class Booking {
  const Booking({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userEmail,
    required this.userPhone,
    required this.itemId,
    required this.itemType,
    required this.itemTitle,
    required this.itemImage,
    required this.hostId,
    required this.hostName,
    required this.hostEmail,
    required this.hostPhone,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.checkIn,
    this.checkOut,
    this.guests,
    this.totalAmount,
    this.currency = 'USD',
    this.paymentStatus = 'pending',
    this.paymentMethod,
    this.specialRequests,
    this.notes,
    this.cancellationReason,
    this.refundAmount,
  });

  factory Booking.fromJson(Map<String, dynamic> json) =>
      _$BookingFromJson(json);
  final String id;
  final String userId;
  final String userName;
  final String userEmail;
  final String userPhone;
  final String itemId;
  final BookingItemType itemType;
  final String itemTitle;
  final String itemImage;
  final String hostId;
  final String hostName;
  final String hostEmail;
  final String hostPhone;
  final BookingStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? checkIn;
  final DateTime? checkOut;
  final int? guests;
  final double? totalAmount;
  final String currency;
  final String paymentStatus;
  final String? paymentMethod;
  final String? specialRequests;
  final String? notes;
  final String? cancellationReason;
  final double? refundAmount;

  String get formattedTotalAmount => totalAmount != null
      ? '$currency ${totalAmount!.toStringAsFixed(2)}'
      : 'TBD';

  String get formattedCheckIn =>
      checkIn != null ? _formatDate(checkIn!) : 'Not specified';

  String get formattedCheckOut =>
      checkOut != null ? _formatDate(checkOut!) : 'Not specified';

  String get statusDisplayName {
    switch (status) {
      case BookingStatus.pending:
        return 'Pending';
      case BookingStatus.confirmed:
        return 'Confirmed';
      case BookingStatus.cancelled:
        return 'Cancelled';
      case BookingStatus.completed:
        return 'Completed';
      case BookingStatus.refunded:
        return 'Refunded';
    }
  }

  String get itemTypeDisplayName {
    switch (itemType) {
      case BookingItemType.accommodation:
        return 'Accommodation';
      case BookingItemType.event:
        return 'Event';
    }
  }

  Map<String, dynamic> toJson() => _$BookingToJson(this);

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

enum BookingItemType {
  @JsonValue('accommodation')
  accommodation,
  @JsonValue('event')
  event,
}

enum BookingStatus {
  @JsonValue('pending')
  pending,
  @JsonValue('confirmed')
  confirmed,
  @JsonValue('cancelled')
  cancelled,
  @JsonValue('completed')
  completed,
  @JsonValue('refunded')
  refunded,
}
