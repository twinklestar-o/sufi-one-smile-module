class Visit {
  final String? id;
  final String? jabatanSaya;
  final String? areaCode;
  final String? branchCode;
  final String? productCode;
  final String? dealerCode;
  final String? tipeVisit;
  final String? tujuanVisit;
  final DateTime? dariTanggal;
  final DateTime? sampaiTanggal;
  final DateTime? tanggalSelesai;
  final String? namaPic;
  final String? themeOfDiscussion;
  final String? problem;
  final String? followUp;
  final String? description;
  final String? photo1;
  final String? photo2;
  final double? latitude;
  final double? longitude;
  final List<dynamic>? mainPersons;

  Visit({
    this.id,
    this.jabatanSaya,
    this.areaCode,
    this.branchCode,
    this.productCode,
    this.dealerCode,
    this.tipeVisit,
    this.tujuanVisit,
    this.dariTanggal,
    this.sampaiTanggal,
    this.tanggalSelesai,
    this.namaPic,
    this.themeOfDiscussion,
    this.problem,
    this.followUp,
    this.description,
    this.photo1,
    this.photo2,
    this.latitude,
    this.longitude,
    this.mainPersons,
  });

  factory Visit.fromJson(Map<String, dynamic> json) {
    return Visit(
      id: json['id']?.toString(),
      jabatanSaya: json['jabatan_saya'],
      areaCode: json['area_code'],
      branchCode: json['branch_code'],
      productCode: json['product_code'],
      dealerCode: json['dealer_code'],
      tipeVisit: json['tipe_visit'],
      tujuanVisit: json['tujuan_visit'],
      dariTanggal: json['dari_tanggal'] != null
          ? DateTime.tryParse(json['dari_tanggal'])
          : null,
      sampaiTanggal: json['sampai_tanggal'] != null
          ? DateTime.tryParse(json['sampai_tanggal'])
          : null,
      tanggalSelesai: json['tanggal_selesai'] != null
          ? DateTime.tryParse(json['tanggal_selesai'])
          : null,
      namaPic: json['nama_pic'],
      themeOfDiscussion: json['theme_of_discussion'],
      problem: json['problem'],
      followUp: json['follow_up'],
      description: json['description'],
      photo1: json['photo1_path'],
      photo2: json['photo2_path'],
      latitude: json['latitude'] != null
          ? double.tryParse(json['latitude'].toString())
          : null,
      longitude: json['longitude'] != null
          ? double.tryParse(json['longitude'].toString())
          : null,
      mainPersons: json['main_persons'],
    );
  }
}
