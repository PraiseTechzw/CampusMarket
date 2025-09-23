// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChatRoom _$ChatRoomFromJson(Map<String, dynamic> json) => ChatRoom(
  id: json['id'] as String,
  name: json['name'] as String,
  description: json['description'] as String?,
  imageUrl: json['imageUrl'] as String?,
  type: $enumDecode(_$ChatTypeEnumMap, json['type']),
  participantIds: (json['participantIds'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  participants: (json['participants'] as List<dynamic>)
      .map((e) => ChatParticipant.fromJson(e as Map<String, dynamic>))
      .toList(),
  lastMessage: json['lastMessage'] == null
      ? null
      : Message.fromJson(json['lastMessage'] as Map<String, dynamic>),
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
  isActive: json['isActive'] as bool? ?? true,
  unreadCounts:
      (json['unreadCounts'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, (e as num).toInt()),
      ) ??
      const {},
);

Map<String, dynamic> _$ChatRoomToJson(ChatRoom instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'description': instance.description,
  'imageUrl': instance.imageUrl,
  'type': _$ChatTypeEnumMap[instance.type]!,
  'participantIds': instance.participantIds,
  'participants': instance.participants,
  'lastMessage': instance.lastMessage,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
  'isActive': instance.isActive,
  'unreadCounts': instance.unreadCounts,
};

const _$ChatTypeEnumMap = {
  ChatType.direct: 'direct',
  ChatType.group: 'group',
  ChatType.marketplace: 'marketplace',
  ChatType.accommodation: 'accommodation',
  ChatType.event: 'event',
};

ChatParticipant _$ChatParticipantFromJson(Map<String, dynamic> json) =>
    ChatParticipant(
      userId: json['userId'] as String,
      name: json['name'] as String,
      profileImageUrl: json['profileImageUrl'] as String?,
      joinedAt: DateTime.parse(json['joinedAt'] as String),
      lastSeenAt: json['lastSeenAt'] == null
          ? null
          : DateTime.parse(json['lastSeenAt'] as String),
      isOnline: json['isOnline'] as bool? ?? false,
      role:
          $enumDecodeNullable(_$ParticipantRoleEnumMap, json['role']) ??
          ParticipantRole.member,
    );

Map<String, dynamic> _$ChatParticipantToJson(ChatParticipant instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'name': instance.name,
      'profileImageUrl': instance.profileImageUrl,
      'joinedAt': instance.joinedAt.toIso8601String(),
      'lastSeenAt': instance.lastSeenAt?.toIso8601String(),
      'isOnline': instance.isOnline,
      'role': _$ParticipantRoleEnumMap[instance.role]!,
    };

const _$ParticipantRoleEnumMap = {
  ParticipantRole.admin: 'admin',
  ParticipantRole.moderator: 'moderator',
  ParticipantRole.member: 'member',
};

Message _$MessageFromJson(Map<String, dynamic> json) => Message(
  id: json['id'] as String,
  chatRoomId: json['chatRoomId'] as String,
  senderId: json['senderId'] as String,
  senderName: json['senderName'] as String,
  senderProfileImage: json['senderProfileImage'] as String?,
  content: json['content'] as String,
  type:
      $enumDecodeNullable(_$MessageTypeEnumMap, json['type']) ??
      MessageType.text,
  attachments:
      (json['attachments'] as List<dynamic>?)
          ?.map((e) => MessageAttachment.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  timestamp: DateTime.parse(json['timestamp'] as String),
  status:
      $enumDecodeNullable(_$MessageStatusEnumMap, json['status']) ??
      MessageStatus.sent,
  replyToMessageId: json['replyToMessageId'] as String?,
  readBy:
      (json['readBy'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  reactions:
      (json['reactions'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
);

Map<String, dynamic> _$MessageToJson(Message instance) => <String, dynamic>{
  'id': instance.id,
  'chatRoomId': instance.chatRoomId,
  'senderId': instance.senderId,
  'senderName': instance.senderName,
  'senderProfileImage': instance.senderProfileImage,
  'content': instance.content,
  'type': _$MessageTypeEnumMap[instance.type]!,
  'attachments': instance.attachments,
  'timestamp': instance.timestamp.toIso8601String(),
  'status': _$MessageStatusEnumMap[instance.status]!,
  'replyToMessageId': instance.replyToMessageId,
  'readBy': instance.readBy,
  'reactions': instance.reactions,
};

const _$MessageTypeEnumMap = {
  MessageType.text: 'text',
  MessageType.image: 'image',
  MessageType.file: 'file',
  MessageType.system: 'system',
};

const _$MessageStatusEnumMap = {
  MessageStatus.sending: 'sending',
  MessageStatus.sent: 'sent',
  MessageStatus.delivered: 'delivered',
  MessageStatus.read: 'read',
  MessageStatus.failed: 'failed',
};

MessageAttachment _$MessageAttachmentFromJson(Map<String, dynamic> json) =>
    MessageAttachment(
      id: json['id'] as String,
      url: json['url'] as String,
      fileName: json['fileName'] as String,
      fileType: json['fileType'] as String,
      fileSize: (json['fileSize'] as num).toInt(),
      type: $enumDecode(_$AttachmentTypeEnumMap, json['type']),
    );

Map<String, dynamic> _$MessageAttachmentToJson(MessageAttachment instance) =>
    <String, dynamic>{
      'id': instance.id,
      'url': instance.url,
      'fileName': instance.fileName,
      'fileType': instance.fileType,
      'fileSize': instance.fileSize,
      'type': _$AttachmentTypeEnumMap[instance.type]!,
    };

const _$AttachmentTypeEnumMap = {
  AttachmentType.image: 'image',
  AttachmentType.document: 'document',
  AttachmentType.video: 'video',
  AttachmentType.audio: 'audio',
};
