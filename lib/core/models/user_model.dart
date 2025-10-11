import 'package:json_annotation/json_annotation.dart';

part 'user_model.g.dart';

@JsonSerializable()
class UserModel {
  final String id;
  final String name;
  final String email;
  final String role; // 'student' or 'club_leader'
  final String course;
  final int points;
  final String? profileImageUrl;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;
  final Map<String, dynamic>? metadata;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.course,
    this.points = 0,
    this.profileImageUrl,
    required this.createdAt,
    required this.updatedAt,
    this.isActive = true,
    this.metadata,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => _$UserModelFromJson(json);
  Map<String, dynamic> toJson() => _$UserModelToJson(this);

  factory UserModel.fromMap(Map<String, dynamic> map, String id) {
    return UserModel(
      id: id,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      role: map['role'] ?? 'student',
      course: map['course'] ?? '',
      points: map['points'] ?? 0,
      profileImageUrl: map['profileImageUrl'] ?? map['profile_image_url'],
      createdAt: map['createdAt'] is DateTime
          ? map['createdAt']
          : (map['created_at'] is int
              ? DateTime.fromMillisecondsSinceEpoch(map['created_at'])
              : DateTime.now()),
      updatedAt: map['updatedAt'] is DateTime
          ? map['updatedAt']
          : (map['updated_at'] is int
              ? DateTime.fromMillisecondsSinceEpoch(map['updated_at'])
              : DateTime.now()),
      isActive: map['isActive'] ?? map['is_active'] ?? true,
      metadata: map['metadata'],
    );
  }

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? role,
    String? course,
    int? points,
    String? profileImageUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
    Map<String, dynamic>? metadata,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      course: course ?? this.course,
      points: points ?? this.points,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'UserModel(id: $id, name: $name, email: $email, role: $role)';
  }

  // Helper methods
  bool get isStudent => role == 'student';
  bool get isClubLeader => role == 'club_leader';
  
  String get displayName => name.isNotEmpty ? name : email.split('@').first;
  
  String get initials {
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : 'U';
  }
}
