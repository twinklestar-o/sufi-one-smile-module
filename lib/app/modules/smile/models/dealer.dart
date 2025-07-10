class Dealer {
  final String name;
  final String code;
  final String createdAt;
  final String updatedAt;

  Dealer({
    required this.name,
    required this.code,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Dealer.fromJson(Map<String, dynamic> json) {
    return Dealer(
      name: json['name'] as String? ?? '',
      code: json['code'] as String? ?? '',
      createdAt: json['created_at'] as String? ?? '',
      updatedAt: json['updated_at'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'code': code,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}
