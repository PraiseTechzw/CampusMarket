/// @Branch: Event Model Implementation
///
/// Event data model for campus events and activities
/// Represents events in the Campus Market
library;

import 'package:json_annotation/json_annotation.dart';

part 'event.g.dart';

@JsonSerializable()
class Event {
  const Event({
    required this.id,
    required this.title,
    required this.description,
    this.imageUrl,
    required this.startDate,
    required this.endDate,
    required this.location,
    this.address,
    this.latitude,
    this.longitude,
    required this.organizerId,
    required this.organizerName,
    this.organizerProfileImage,
    required this.type,
    this.status = EventStatus.active,
    this.isFree = true,
    this.price,
    this.currency = 'USD',
    this.maxAttendees = 0,
    this.currentAttendees = 0,
    this.tags = const [],
    this.requirements = const [],
    this.requiresApproval = false,
    this.isFeatured = false,
    required this.createdAt,
    required this.updatedAt,
    this.viewCount = 0,
    this.favoriteCount = 0,
    this.tickets = const [],
  });

  factory Event.fromJson(Map<String, dynamic> json) => _$EventFromJson(json);
  final String id;
  final String title;
  final String description;
  final String? imageUrl;
  final DateTime startDate;
  final DateTime endDate;
  final String location;
  final String? address;
  final double? latitude;
  final double? longitude;
  final String organizerId;
  final String organizerName;
  final String? organizerProfileImage;
  final EventType type;
  final EventStatus status;
  final bool isFree;
  final double? price;
  final String? currency;
  final int maxAttendees;
  final int currentAttendees;
  final List<String> tags;
  final List<String> requirements;
  final bool requiresApproval;
  final bool isFeatured;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int viewCount;
  final int favoriteCount;
  final List<EventTicket> tickets;

  String get formattedPrice =>
      isFree ? 'Free' : '$currency ${price?.toStringAsFixed(2) ?? '0.00'}';
  String get timeAgo => _getTimeAgo(createdAt);
  bool get isLive =>
      DateTime.now().isAfter(startDate) && DateTime.now().isBefore(endDate);
  bool get isUpcoming => DateTime.now().isBefore(startDate);
  bool get isPast => DateTime.now().isAfter(endDate);
  bool get hasSpotsAvailable =>
      maxAttendees == 0 || currentAttendees < maxAttendees;
  int get spotsRemaining => maxAttendees - currentAttendees;
  String get duration => _getDuration(startDate, endDate);
  Map<String, dynamic> toJson() => _$EventToJson(this);

  Event copyWith({
    String? id,
    String? title,
    String? description,
    String? imageUrl,
    DateTime? startDate,
    DateTime? endDate,
    String? location,
    String? address,
    double? latitude,
    double? longitude,
    String? organizerId,
    String? organizerName,
    String? organizerProfileImage,
    EventType? type,
    EventStatus? status,
    bool? isFree,
    double? price,
    String? currency,
    int? maxAttendees,
    int? currentAttendees,
    List<String>? tags,
    List<String>? requirements,
    bool? requiresApproval,
    bool? isFeatured,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? viewCount,
    int? favoriteCount,
    List<EventTicket>? tickets,
  }) => Event(
    id: id ?? this.id,
    title: title ?? this.title,
    description: description ?? this.description,
    imageUrl: imageUrl ?? this.imageUrl,
    startDate: startDate ?? this.startDate,
    endDate: endDate ?? this.endDate,
    location: location ?? this.location,
    address: address ?? this.address,
    latitude: latitude ?? this.latitude,
    longitude: longitude ?? this.longitude,
    organizerId: organizerId ?? this.organizerId,
    organizerName: organizerName ?? this.organizerName,
    organizerProfileImage: organizerProfileImage ?? this.organizerProfileImage,
    type: type ?? this.type,
    status: status ?? this.status,
    isFree: isFree ?? this.isFree,
    price: price ?? this.price,
    currency: currency ?? this.currency,
    maxAttendees: maxAttendees ?? this.maxAttendees,
    currentAttendees: currentAttendees ?? this.currentAttendees,
    tags: tags ?? this.tags,
    requirements: requirements ?? this.requirements,
    requiresApproval: requiresApproval ?? this.requiresApproval,
    isFeatured: isFeatured ?? this.isFeatured,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    viewCount: viewCount ?? this.viewCount,
    favoriteCount: favoriteCount ?? this.favoriteCount,
    tickets: tickets ?? this.tickets,
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

  String _getDuration(DateTime start, DateTime end) {
    final difference = end.difference(start);
    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays != 1 ? 's' : ''}';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours != 1 ? 's' : ''}';
    } else {
      return '${difference.inMinutes} minute${difference.inMinutes != 1 ? 's' : ''}';
    }
  }
}

@JsonSerializable()
class EventTicket {
  const EventTicket({
    required this.id,
    required this.name,
    required this.description,
    this.price = 0.0,
    this.currency = 'USD',
    this.quantity = 0,
    this.sold = 0,
    this.saleStartDate,
    this.saleEndDate,
    this.isActive = true,
  });

  factory EventTicket.fromJson(Map<String, dynamic> json) =>
      _$EventTicketFromJson(json);
  final String id;
  final String name;
  final String description;
  final double price;
  final String currency;
  final int quantity;
  final int sold;
  final DateTime? saleStartDate;
  final DateTime? saleEndDate;
  final bool isActive;

  String get formattedPrice =>
      price == 0 ? 'Free' : '$currency ${price.toStringAsFixed(2)}';
  int get remaining => quantity - sold;
  bool get isAvailable => isActive && remaining > 0;
  Map<String, dynamic> toJson() => _$EventTicketToJson(this);
}

enum EventType {
  @JsonValue('academic')
  academic,
  @JsonValue('social')
  social,
  @JsonValue('sports')
  sports,
  @JsonValue('cultural')
  cultural,
  @JsonValue('professional')
  professional,
  @JsonValue('volunteer')
  volunteer,
  @JsonValue('workshop')
  workshop,
  @JsonValue('conference')
  conference,
}

enum EventStatus {
  @JsonValue('draft')
  draft,
  @JsonValue('pending')
  pending,
  @JsonValue('active')
  active,
  @JsonValue('cancelled')
  cancelled,
  @JsonValue('completed')
  completed,
  @JsonValue('rejected')
  rejected,
}
