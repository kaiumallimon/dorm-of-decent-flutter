import 'package:equatable/equatable.dart';

class ProfileResponse extends Equatable {
  final bool success;
  final ProfileData data;

  const ProfileResponse({
    required this.success,
    required this.data,
  });

  factory ProfileResponse.fromJson(Map<String, dynamic> json) {
    return ProfileResponse(
      success: json['success'],
      data: ProfileData.fromJson(json['data']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'data': data.toJson(),
    };
  }

  @override
  List<Object?> get props => [success, data];
}

class ProfileData extends Equatable {
  final String id;
  final String email;
  final String name;
  final String role;
  final String createdAt;

  const ProfileData({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    required this.createdAt,
  });

  factory ProfileData.fromJson(Map<String, dynamic> json) {
    return ProfileData(
      id: json['id'],
      email: json['email'],
      name: json['name'],
      role: json['role'],
      createdAt: json['created_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'role': role,
      'created_at': createdAt,
    };
  }

  @override
  List<Object?> get props => [id, email, name, role, createdAt];
}