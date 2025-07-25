class HistoryStockOpname {
  final String id;
  final String trxNo;
  final String item;
  final String uscrt;
  final String crdt;
  final String? imageUrl;
  HistoryStockOpname({
    required this.id,
    required this.trxNo,
    required this.item,
    required this.uscrt,
    required this.crdt,
    this.imageUrl,
  });

  factory HistoryStockOpname.fromJson(Map<String, dynamic> json) {
    return HistoryStockOpname(
      id: json['id']?.toString() ?? '',
      trxNo: json['trx_no'] ?? '',
      item: json['item'] ?? '',
      uscrt: json['uscrt'] ?? '',
      crdt: json['crdt'] ?? '',
      imageUrl: json['image_url'],
    );
  }
}
