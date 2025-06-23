class Branch {
  final String code;
  final String areaCode;
  final String name;
  final String createdAt;
  final String updatedAt;

  Branch({
    required this.code,
    required this.areaCode,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
  });

  // Factory method untuk membuat objek Branch dari JSON
  factory Branch.fromJson(Map<String, dynamic> json) {
    return Branch(
      code: json['code'] as String,
      areaCode: json['area_code'] as String,
      name: json['name'] as String,
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String,
    );
  }

  // Method untuk mengubah objek Branch menjadi JSON
  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'area_code': areaCode,
      'name': name,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}
