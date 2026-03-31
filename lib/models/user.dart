import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

enum UserRole { admin, instructor, student }

@JsonSerializable()
class User {
  final String id;
  final String email;
  final String name;
  final String? phoneNumber;
  final UserRole role;
  final String? departmentId;
  final String? institutionId;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? profileImageUrl;
  final double? latitude;
  final double? longitude;

  User({
    required this.id,
    required this.email,
    required this.name,
    this.phoneNumber,
    required this.role,
    this.departmentId,
    this.institutionId,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
    this.profileImageUrl,
    this.latitude,
    this.longitude,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  Map<String, dynamic> toJson() => _$UserToJson(this);

  User copyWith({
    String? id,
    String? email,
    String? name,
    String? phoneNumber,
    UserRole? role,
    String? departmentId,
    String? institutionId,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? profileImageUrl,
    double? latitude,
    double? longitude,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      role: role ?? this.role,
      departmentId: departmentId ?? this.departmentId,
      institutionId: institutionId ?? this.institutionId,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }

  @override
  String toString() => 'User(id: $id, email: $email, name: $name, role: $role)';
}
