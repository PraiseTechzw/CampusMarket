/// @Branch: Chat Model Implementation
///
/// Chat and messaging data models
/// Represents real-time-like chat functionality
library;

import 'package:json_annotation/json_annotation.dart';

part 'chat.g.dart';

@JsonSerializable()
class ChatRoom {

  const ChatRoom({
    required this.id,
    required this.name,
    this.description,
    this.imageUrl,
    required this.type,
    required this.participantIds,
    required this.participants,
    this.lastMessage,
    required this.createdAt,
    required this.updatedAt,
    this.isActive = true,
    this.unreadCounts = const {},
  });

  factory ChatRoom.fromJson(Map<String, dynamic> json) =>
      _$ChatRoomFromJson(json);
  final String id;
  final String name;
  final String? description;
  final String? imageUrl;
  final ChatType type;
  final List<String> participantIds;
  final List<ChatParticipant> participants;
  final Message? lastMessage;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;
  final Map<String, int> unreadCounts;

  String get displayName => name;
  int get unreadCount =>
      unreadCounts.values.fold(0, (sum, count) => sum + count);
  Map<String, dynamic> toJson() => _$ChatRoomToJson(this);
}

@JsonSerializable()
class ChatParticipant {

  const ChatParticipant({
    required this.userId,
    required this.name,
    this.profileImageUrl,
    required this.joinedAt,
    this.lastSeenAt,
    this.isOnline = false,
    this.role = ParticipantRole.member,
  });

  factory ChatParticipant.fromJson(Map<String, dynamic> json) =>
      _$ChatParticipantFromJson(json);
  final String userId;
  final String name;
  final String? profileImageUrl;
  final DateTime joinedAt;
  final DateTime? lastSeenAt;
  final bool isOnline;
  final ParticipantRole role;
  Map<String, dynamic> toJson() => _$ChatParticipantToJson(this);
}

@JsonSerializable()
class Message {

  const Message({
    required this.id,
    required this.chatRoomId,
    required this.senderId,
    required this.senderName,
    this.senderProfileImage,
    required this.content,
    this.type = MessageType.text,
    this.attachments = const [],
    required this.timestamp,
    this.status = MessageStatus.sent,
    this.replyToMessageId,
    this.readBy = const [],
    this.reactions = const [],
  });

  factory Message.fromJson(Map<String, dynamic> json) =>
      _$MessageFromJson(json);
  final String id;
  final String chatRoomId;
  final String senderId;
  final String senderName;
  final String? senderProfileImage;
  final String content;
  final MessageType type;
  final List<MessageAttachment> attachments;
  final DateTime timestamp;
  final MessageStatus status;
  final String? replyToMessageId;
  final List<String> readBy;
  final List<String> reactions;

  bool get isRead => readBy.isNotEmpty;
  String get timeAgo => _getTimeAgo(timestamp);
  Map<String, dynamic> toJson() => _$MessageToJson(this);

  Message copyWith({
    String? id,
    String? chatRoomId,
    String? senderId,
    String? senderName,
    String? senderProfileImage,
    String? content,
    MessageType? type,
    List<MessageAttachment>? attachments,
    DateTime? timestamp,
    MessageStatus? status,
    String? replyToMessageId,
    List<String>? readBy,
    List<String>? reactions,
  }) => Message(
      id: id ?? this.id,
      chatRoomId: chatRoomId ?? this.chatRoomId,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      senderProfileImage: senderProfileImage ?? this.senderProfileImage,
      content: content ?? this.content,
      type: type ?? this.type,
      attachments: attachments ?? this.attachments,
      timestamp: timestamp ?? this.timestamp,
      status: status ?? this.status,
      replyToMessageId: replyToMessageId ?? this.replyToMessageId,
      readBy: readBy ?? this.readBy,
      reactions: reactions ?? this.reactions,
    );

  String _getTimeAgo(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
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

@JsonSerializable()
class MessageAttachment {

  const MessageAttachment({
    required this.id,
    required this.url,
    required this.fileName,
    required this.fileType,
    required this.fileSize,
    required this.type,
  });

  factory MessageAttachment.fromJson(Map<String, dynamic> json) =>
      _$MessageAttachmentFromJson(json);
  final String id;
  final String url;
  final String fileName;
  final String fileType;
  final int fileSize;
  final AttachmentType type;

  String get formattedFileSize => _formatFileSize(fileSize);
  Map<String, dynamic> toJson() => _$MessageAttachmentToJson(this);

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
}

enum ChatType {
  @JsonValue('direct')
  direct,
  @JsonValue('group')
  group,
  @JsonValue('marketplace')
  marketplace,
  @JsonValue('accommodation')
  accommodation,
  @JsonValue('event')
  event,
}

enum MessageType {
  @JsonValue('text')
  text,
  @JsonValue('image')
  image,
  @JsonValue('file')
  file,
  @JsonValue('system')
  system,
}

enum MessageStatus {
  @JsonValue('sending')
  sending,
  @JsonValue('sent')
  sent,
  @JsonValue('delivered')
  delivered,
  @JsonValue('read')
  read,
  @JsonValue('failed')
  failed,
}

enum AttachmentType {
  @JsonValue('image')
  image,
  @JsonValue('document')
  document,
  @JsonValue('video')
  video,
  @JsonValue('audio')
  audio,
}

enum ParticipantRole {
  @JsonValue('admin')
  admin,
  @JsonValue('moderator')
  moderator,
  @JsonValue('member')
  member,
}
