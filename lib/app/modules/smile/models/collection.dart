// lib/src/models/collection.dart
class Collection {
  final int id;
  final String name;
  // final String kode; // Hapus baris ini karena API tidak mengembalikan 'kode'
  final String? createdAt;
  final String? updatedAt;

  Collection({
    required this.id,
    required this.name,
    // required this.kode, // Hapus ini
    this.createdAt,
    this.updatedAt,
  });

  factory Collection.fromJson(Map<String, dynamic> json) {
    return Collection(
      id: json['id'] as int,
      name: json['name'] as String,
      // kode: json['kode'] as String, // Hapus ini
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      // 'kode': kode, // Hapus ini
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  @override
  String toString() {
    return 'Collection{id: $id, name: $name}'; // Sesuaikan toString
  }
}