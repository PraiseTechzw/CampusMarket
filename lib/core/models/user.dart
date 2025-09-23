/// @Branch: User Model Implementation
///
/// User data model with serialization support
/// Represents user information in the Campus Market application
library;

import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

@JsonSerializable()
class User {
  const User({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    this.profileImageUrl,
    this.phoneNumber,
    this.university,
    this.studentId,
    required this.createdAt,
    required this.updatedAt,
    this.isVerified = false,
    this.isActive = true,
    this.role = UserRole.student,
    required this.preferences,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  final String id;
  final String email;
  @JsonKey(name: 'first_name')
  final String firstName;
  @JsonKey(name: 'last_name')
  final String lastName;
  @JsonKey(name: 'profile_image_url')
  final String? profileImageUrl;
  @JsonKey(name: 'phone_number')
  final String? phoneNumber;
  final String? university;
  @JsonKey(name: 'student_id')
  final String? studentId;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;
  @JsonKey(name: 'is_verified')
  final bool isVerified;
  @JsonKey(name: 'is_active')
  final bool isActive;
  final UserRole role;
  @JsonKey(toJson: _preferencesToJson, fromJson: _preferencesFromJson)
  final UserPreferences preferences;

  String get fullName => '$firstName $lastName';
  String get initials {
    final firstInitial = firstName.isNotEmpty ? firstName[0] : '?';
    final lastInitial = lastName.isNotEmpty ? lastName[0] : '?';
    return '$firstInitial$lastInitial'.toUpperCase();
  }

  Map<String, dynamic> toJson() => _$UserToJson(this);

  User copyWith({
    String? id,
    String? email,
    String? firstName,
    String? lastName,
    String? profileImageUrl,
    String? phoneNumber,
    String? university,
    String? studentId,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isVerified,
    bool? isActive,
    UserRole? role,
    UserPreferences? preferences,
  }) => User(
    id: id ?? this.id,
    email: email ?? this.email,
    firstName: firstName ?? this.firstName,
    lastName: lastName ?? this.lastName,
    profileImageUrl: profileImageUrl ?? this.profileImageUrl,
    phoneNumber: phoneNumber ?? this.phoneNumber,
    university: university ?? this.university,
    studentId: studentId ?? this.studentId,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    isVerified: isVerified ?? this.isVerified,
    isActive: isActive ?? this.isActive,
    role: role ?? this.role,
    preferences: preferences ?? this.preferences,
  );
}

@JsonSerializable()
class UserPreferences {
  const UserPreferences({
    this.notificationsEnabled = true,
    this.emailNotifications = true,
    this.pushNotifications = true,
    this.language = 'en',
    this.theme = 'system',
    this.locationSharing = false,
    required this.privacy,
  });

  factory UserPreferences.fromJson(Map<String, dynamic> json) =>
      _$UserPreferencesFromJson(json);
  final bool notificationsEnabled;
  final bool emailNotifications;
  final bool pushNotifications;
  final String language;
  final String theme;
  final bool locationSharing;
  @JsonKey(toJson: _privacyToJson, fromJson: _privacyFromJson)
  final PrivacySettings privacy;
  Map<String, dynamic> toJson() => _$UserPreferencesToJson(this);
}

@JsonSerializable()
class PrivacySettings {
  const PrivacySettings({
    this.profileVisible = true,
    this.contactInfoVisible = false,
    this.listingsVisible = true,
    this.activityVisible = false,
  });

  factory PrivacySettings.fromJson(Map<String, dynamic> json) =>
      _$PrivacySettingsFromJson(json);
  final bool profileVisible;
  final bool contactInfoVisible;
  final bool listingsVisible;
  final bool activityVisible;
  Map<String, dynamic> toJson() => _$PrivacySettingsToJson(this);
}

enum UserRole {
  @JsonValue('student')
  student,
  @JsonValue('admin')
  admin,
  @JsonValue('moderator')
  moderator,
  @JsonValue('host')
  host,
}

// Helper functions for UserPreferences serialization
Map<String, dynamic> _preferencesToJson(UserPreferences preferences) =>
    preferences.toJson();

UserPreferences _preferencesFromJson(Map<String, dynamic> json) =>
    UserPreferences.fromJson(json);

// Helper functions for PrivacySettings serialization
Map<String, dynamic> _privacyToJson(PrivacySettings privacy) =>
    privacy.toJson();

PrivacySettings _privacyFromJson(Map<String, dynamic> json) =>
    PrivacySettings.fromJson(json);
