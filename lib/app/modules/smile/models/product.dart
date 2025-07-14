// lib/app/modules/smile/models/product.dart
class Product {
  final String name;
  final String code; // Ganti 'kode' menjadi 'code'
  final String createdAt;
  final String updatedAt;

  Product({
    required this.name,
    required this.code, // Ganti 'kode' menjadi 'code'
    required this.createdAt,
    required this.updatedAt,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    print('🔍 Product.fromJson input: $json');
    print('🔍 Available keys in JSON: ${json.keys.toList()}');

    // Pastikan membaca dari 'code' yang datang dari API Laravel
    final String productCode = json['code']?.toString() ?? 'N/A';

    print('🔍 Mapped "code" from JSON to "code" in Dart model: $productCode');

    final product = Product(
      name: json['name']?.toString() ?? 'Unknown',
      code: productCode, // Gunakan productCode yang sudah dipastikan
      createdAt: json['created_at']?.toString() ?? '',
      updatedAt: json['updated_at']?.toString() ?? '',
    );

    print('✅ Created product object: ${product.toString()}');
    return product;
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'code': code, // Saat menyimpan ke SQLite atau mengirim ke API, gunakan 'code'
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  @override
  String toString() {
    return 'Product{name: $name, code: $code, createdAt: $createdAt, updatedAt: $updatedAt}';
  }
}