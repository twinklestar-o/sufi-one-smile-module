import 'dart:ffi';

class LokasiUser {
  final int id;
  final String? name;
  final String createdAt;
  final String updatedAt;

  LokasiUser({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
  });

  factory LokasiUser.fromJson(Map<String, dynamic> json) {
    return LokasiUser(
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
