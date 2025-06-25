class Branch {
  final String code;
  final String name;
  final String? areaCode;
  final String? createdAt;
  final String? updatedAt;

  Branch({
    required this.code,
    required this.name,
    this.areaCode,
    this.createdAt,
    this.updatedAt,
  });

  // Factory method untuk membuat objek Branch dari JSON
  factory Branch.fromJson(Map<String, dynamic> json) {
    return Branch(
      code: json['code'] as String,
      name: json['name'] as String,
      // Gunakan 'as String?' untuk mengizinkan nilai null.
      // Jika Anda ingin nilai default (misalnya string kosong) ketika null, gunakan `?? ''`
      areaCode: json['area_code'] as String?,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );
  }

  // Method untuk mengubah objek Branch menjadi JSON
  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'name': name,
      'area_code': areaCode,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}
