// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) => User(
  id: json['id'] as String,
  email: json['email'] as String,
  firstName: json['first_name'] as String,
  lastName: json['last_name'] as String,
  profileImageUrl: json['profile_image_url'] as String?,
  phoneNumber: json['phone_number'] as String?,
  university: json['university'] as String?,
  studentId: json['student_id'] as String?,
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt: DateTime.parse(json['updated_at'] as String),
  isVerified: json['is_verified'] as bool? ?? false,
  isActive: json['is_active'] as bool? ?? true,
  role:
      $enumDecodeNullable(_$UserRoleEnumMap, json['role']) ?? UserRole.student,
  preferences: _preferencesFromJson(
    json['preferences'] as Map<String, dynamic>,
  ),
);

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
  'id': instance.id,
  'email': instance.email,
  'first_name': instance.firstName,
  'last_name': instance.lastName,
  'profile_image_url': instance.profileImageUrl,
  'phone_number': instance.phoneNumber,
  'university': instance.university,
  'student_id': instance.studentId,
  'created_at': instance.createdAt.toIso8601String(),
  'updated_at': instance.updatedAt.toIso8601String(),
  'is_verified': instance.isVerified,
  'is_active': instance.isActive,
  'role': _$UserRoleEnumMap[instance.role]!,
  'preferences': _preferencesToJson(instance.preferences),
};

const _$UserRoleEnumMap = {
  UserRole.student: 'student',
  UserRole.admin: 'admin',
  UserRole.moderator: 'moderator',
  UserRole.host: 'host',
};

UserPreferences _$UserPreferencesFromJson(Map<String, dynamic> json) =>
    UserPreferences(
      notificationsEnabled: json['notificationsEnabled'] as bool? ?? true,
      emailNotifications: json['emailNotifications'] as bool? ?? true,
      pushNotifications: json['pushNotifications'] as bool? ?? true,
      language: json['language'] as String? ?? 'en',
      theme: json['theme'] as String? ?? 'system',
      locationSharing: json['locationSharing'] as bool? ?? false,
      privacy: _privacyFromJson(json['privacy'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$UserPreferencesToJson(UserPreferences instance) =>
    <String, dynamic>{
      'notificationsEnabled': instance.notificationsEnabled,
      'emailNotifications': instance.emailNotifications,
      'pushNotifications': instance.pushNotifications,
      'language': instance.language,
      'theme': instance.theme,
      'locationSharing': instance.locationSharing,
      'privacy': _privacyToJson(instance.privacy),
    };

PrivacySettings _$PrivacySettingsFromJson(Map<String, dynamic> json) =>
    PrivacySettings(
      profileVisible: json['profileVisible'] as bool? ?? true,
      contactInfoVisible: json['contactInfoVisible'] as bool? ?? false,
      listingsVisible: json['listingsVisible'] as bool? ?? true,
      activityVisible: json['activityVisible'] as bool? ?? false,
    );

Map<String, dynamic> _$PrivacySettingsToJson(PrivacySettings instance) =>
    <String, dynamic>{
      'profileVisible': instance.profileVisible,
      'contactInfoVisible': instance.contactInfoVisible,
      'listingsVisible': instance.listingsVisible,
      'activityVisible': instance.activityVisible,
    };
