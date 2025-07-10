class JabatanSFI {
  final int id;
  final String name;
  final String kode;
  final String createdAt;
  final String updatedAt;

  JabatanSFI({
    required this.id,
    required this.name,
    required this.kode,
    required this.createdAt,
    required this.updatedAt,
  });

  factory JabatanSFI.fromJson(Map<String, dynamic> json) {
    return JabatanSFI(
      id: json['id'] as int,
      name: json['name'] as String,
      kode: json['kode'] as String,
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'kode': kode,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}
