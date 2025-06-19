import 'dart:ffi';

class Area {
  final String code;
  final String name;
  final String createdAt;
  final String updatedAt;

  Area({
    required this.code,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Area.fromJson(Map<String, dynamic> json) {
    return Area(
      code: json['code'] as String,
      name: json['name'] as String,
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'name': name,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}
