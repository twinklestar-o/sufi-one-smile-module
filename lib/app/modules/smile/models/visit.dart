class Visit {
  final String kodeCabang;
  final String noPlan;
  final String jenisVisit;
  final String subJenis;
  final DateTime tanggal;

  Visit({
    required this.kodeCabang,
    required this.noPlan,
    required this.jenisVisit,
    required this.subJenis,
    required this.tanggal,
  });

  Visit copyWith({
    String? kodeCabang,
    String? noPlan,
    String? jenisVisit,
    String? subJenis,
    DateTime? tanggal,
  }) {
    return Visit(
      kodeCabang: kodeCabang ?? this.kodeCabang,
      noPlan: noPlan ?? this.noPlan,
      jenisVisit: jenisVisit ?? this.jenisVisit,
      subJenis: subJenis ?? this.subJenis,
      tanggal: tanggal ?? this.tanggal,
    );
  }
}
