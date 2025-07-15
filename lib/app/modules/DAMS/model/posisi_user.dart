import 'dart:ffi';

class PosisiUser {
  final int id;
  final String? name;
  final String createdAt;
  final String updatedAt;

  PosisiUser({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PosisiUser.fromJson(Map<String, dynamic> json) {
    return PosisiUser(
      id: json['id'] ?? 0,
      name: json['name'] as String?,
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'name': name, 'created_at': createdAt, 'updated_at': updatedAt};
  }
}
