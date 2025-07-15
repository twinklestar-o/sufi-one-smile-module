import 'dart:ffi';

class StatusUserAsset {
  final int id;
  final String? name;
  final String createdAt;
  final String updatedAt;

  StatusUserAsset({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
  });

  factory StatusUserAsset.fromJson(Map<String, dynamic> json) {
    return StatusUserAsset(
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
