class History {
  final int id;
  final String cabang;
  final String pic;
  final String type;
  final String activity;
  final String? timestamp;
  final String? location;
  final String? jabatan;
  final String? area;
  final String? produk;
  final String? dateStart;
  final String? dateFinish;
  final String? discussion;
  final String? problem;
  final String? pelakasanaan;
  final String? image;

  History({
    required this.id,
    required this.cabang,
    required this.pic,
    required this.type,
    required this.activity,
    this.timestamp,
    this.location,
    this.jabatan,
    this.area,
    this.produk,
    this.dateStart,
    this.dateFinish,
    this.discussion,
    this.problem,
    this.pelakasanaan,
    this.image,
  });

  factory History.fromJson(Map<String, dynamic> json) {
    return History(
      id: json['id'] ?? 0,
      cabang: json['cabang'] ?? '',
      pic: json['pic'] ?? '',
      type: json['type'] ?? '',
      activity: json['activity'] ?? '',
      timestamp: json['timestamp'],
      location: json['location'],
      jabatan: json['jabatan'],
      area: json['area'],
      produk: json['produk'],
      dateStart: json['date_start'],
      dateFinish: json['date_finish'],
      discussion: json['discussion'],
      problem: json['problem'],
      pelakasanaan: json['pelakasanaan'],
      image: json['image'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'cabang': cabang,
      'pic': pic,
      'type': type,
      'activity': activity,
      'timestamp': timestamp,
      'location': location,
      'jabatan': jabatan,
      'area': area,
      'produk': produk,
      'date_start': dateStart,
      'date_finish': dateFinish,
      'discussion': discussion,
      'problem': problem,
      'pelakasanaan': pelakasanaan,
      'image': image,
    };
  }
}
