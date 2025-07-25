class StokopnameImage {
  final String noStokopname;
  final String img;
  final int seq;
  final String name;

  StokopnameImage({
    required this.noStokopname,
    required this.img,
    required this.seq,
    required this.name,
  });

  factory StokopnameImage.fromJson(Map<String, dynamic> json) {
    return StokopnameImage(
      noStokopname: json['no_stokopname'] as String,
      img: json['img'] as String,
      seq: json['seq'] as int,
      name: json['name'] as String,
    );
  }

  get imageUrl => null;

  Map<String, dynamic> toJson() {
    return {
      'no_stokopname': noStokopname,
      'img': img,
      'seq': seq,
      'name': name,
    };
  }
}
