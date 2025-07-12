class HistoryStockOpname {
  final String trxNo;
  final String item;
  final String uscrt;
  final String crdt;

  HistoryStockOpname({
    required this.trxNo,
    required this.item,
    required this.uscrt,
    required this.crdt,
  });

  factory HistoryStockOpname.fromJson(Map<String, dynamic> json) {
    return HistoryStockOpname(
      trxNo: json['trx_no'] ?? '',
      item: json['item'] ?? '',
      uscrt: json['uscrt'] ?? '',
      crdt: json['crdt'] ?? '',
    );
  }
}
