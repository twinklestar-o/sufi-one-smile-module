class DirectVisit {
  final String jabatanSaya;
  final String areaCode;
  final String branchCode;
  final String productCode;
  final String dealerCode;
  final String tipeVisit;
  final String tujuanVisit;
  final String dariTanggal;
  final String sampaiTanggal;
  final String tanggalSelesai;
  final String namaPic;
  final String? themeOfDiscussion;
  final String? problem;
  final String? followUp;
  final String? description;
  final String photo1Path;
  final String photo2Path;
  final double? latitude;
  final double? longitude;
  final int status;

  DirectVisit({
    required this.jabatanSaya,
    required this.areaCode,
    required this.branchCode,
    required this.productCode,
    required this.dealerCode,
    required this.tipeVisit,
    required this.tujuanVisit,
    required this.dariTanggal,
    required this.sampaiTanggal,
    required this.tanggalSelesai,
    required this.namaPic,
    this.themeOfDiscussion,
    this.problem,
    this.followUp,
    this.description,
    required this.photo1Path,
    required this.photo2Path,
    this.latitude,
    this.longitude,
    required this.status,
  });

  factory DirectVisit.fromJson(Map<String, dynamic> json) {
    return DirectVisit(
      jabatanSaya: json['jabatan_saya'] ?? '',
      areaCode: json['area_code'] ?? '',
      branchCode: json['branch_code'] ?? '',
      productCode: json['product_code'] ?? '',
      dealerCode: json['dealer_code'] ?? '',
      tipeVisit: json['tipe_visit'] ?? '',
      tujuanVisit: json['tujuan_visit'] ?? '',
      dariTanggal: json['dari_tanggal'] ?? '',
      sampaiTanggal: json['sampai_tanggal'] ?? '',
      tanggalSelesai: json['tanggal_selesai'] ?? '',
      namaPic: json['nama_pic'] ?? '',
      themeOfDiscussion: json['theme_of_discussion'],
      problem: json['problem'],
      followUp: json['follow_up'],
      description: json['description'],
      photo1Path: json['photo1_path'] ?? '',
      photo2Path: json['photo2_path'] ?? '',
      latitude: (json['latitude'] != null) ? json['latitude'].toDouble() : null,
      longitude: (json['longitude'] != null) ? json['longitude'].toDouble() : null,
      status: json['status'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'jabatan_saya': jabatanSaya,
      'area_code': areaCode,
      'branch_code': branchCode,
      'product_code': productCode,
      'dealer_code': dealerCode,
      'tipe_visit': tipeVisit,
      'tujuan_visit': tujuanVisit,
      'dari_tanggal': dariTanggal,
      'sampai_tanggal': sampaiTanggal,
      'tanggal_selesai': tanggalSelesai,
      'nama_pic': namaPic,
      'theme_of_discussion': themeOfDiscussion,
      'problem': problem,
      'follow_up': followUp,
      'description': description,
      'photo1_path': photo1Path,
      'photo2_path': photo2Path,
      'latitude': latitude,
      'longitude': longitude,
      'status': status,
    };
  }
}
