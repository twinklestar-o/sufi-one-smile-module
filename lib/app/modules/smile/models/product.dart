class Product {
  final String name;
  final String kode;
  final String createdAt;
  final String updatedAt;

  Product({
    required this.name,
    required this.kode,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      name: json['name'] as String,
      kode: json['kode'] as String,
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {

      'name': name,
      'kode': kode,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}
