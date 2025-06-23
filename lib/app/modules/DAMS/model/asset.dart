import 'package:intl/intl.dart';

class Asset {
  final int? msAssetBranchId;
  final String kodeAset;
  final String branchId;
  final String lokasi;
  final int isActive;
  final String userCreate;
  final DateTime createDate;
  final String? division;
  final String? personalLoc;
  final String? dept;
  final String? room;
  final String? floor;
  final String? latitude;
  final String? longitude;
  final String? location;
  final int? lelang;
  final int? writeoff;
  final int? mutation;
  final int? borrow;
  final int? return_;
  final int? move;
  final int? maintain;
  final String? klasifikasiWo;
  final String? remarkWo;
  final String? userUpdateWo;
  final DateTime? dateUpdateWo;
  final DateTime? lastUpdate;
  final String? userUpdate;
  final String? branchType;
  final String? branchName;

  Asset({
    this.msAssetBranchId,
    required this.kodeAset,
    required this.branchId,
    required this.lokasi,
    required this.isActive,
    required this.userCreate,
    required this.createDate,
    this.division,
    this.personalLoc,
    this.dept,
    this.room,
    this.floor,
    this.latitude,
    this.longitude,
    this.location,
    this.lelang,
    this.writeoff,
    this.mutation,
    this.borrow,
    this.return_,
    this.move,
    this.maintain,
    this.klasifikasiWo,
    this.remarkWo,
    this.userUpdateWo,
    this.dateUpdateWo,
    this.lastUpdate,
    this.userUpdate,
    this.branchType,
    this.branchName,
  });

  factory Asset.fromJson(Map<String, dynamic> json) {
    // Helper function untuk parsing tanggal dengan aman
    DateTime? parseDate(dynamic dateValue) {
      if (dateValue == null) return null;

      try {
        // Coba parse sebagai DateTime langsung (jika sudah dalam format Dart)
        if (dateValue is DateTime) return dateValue;

        // Coba parse sebagai String
        if (dateValue is String) {
          // Coba format ISO8601 dulu
          try {
            return DateTime.parse(dateValue);
          } catch (_) {
            // Coba format lain yang mungkin digunakan
            final formats = [
              DateFormat('yyyy-MM-dd HH:mm:ss'),
              DateFormat('yyyy-MM-dd'),
              DateFormat('dd/MM/yyyy HH:mm:ss'),
              DateFormat('dd/MM/yyyy'),
            ];

            for (final format in formats) {
              try {
                return format.parse(dateValue);
              } catch (_) {}
            }
          }
        }

        // Jika dalam format timestamp (int)
        if (dateValue is int) {
          return DateTime.fromMillisecondsSinceEpoch(dateValue);
        }

        return null;
      } catch (e) {
        print('Error parsing date: $dateValue');
        return null;
      }
    }

    // Tanggal wajib dengan fallback ke DateTime.now() jika parsing gagal
    final createDate = parseDate(json['CREATE_DATE']) ?? DateTime.now();

    return Asset(
      msAssetBranchId: json['MS_ASSET_BRANCH_ID'] as int? ?? 0,
      kodeAset: json['KODE_ASET'] as String? ?? '',
      branchId: json['BRANCH_ID'] as String? ?? '',
      lokasi: json['LOKASI'] as String? ?? '',
      isActive: json['IS_ACTIVE'] as int? ?? 0,
      userCreate: json['USER_CREATE'] as String? ?? '',
      createDate: createDate,
      division: json['DIVISION'] as String? ?? '',
      personalLoc: json['PERSONAL_LOC'] as String? ?? '',
      dept: json['DEPT'] as String? ?? '',
      room: json['ROOM'] as String? ?? '',
      floor: json['FLOOR'] as String? ?? '',
      latitude: json['LATITUDE'] as String? ?? '',
      longitude: json['LONGITUDE'] as String? ?? '',
      location: json['LOCATION'] as String? ?? '',
      lelang: int.tryParse(json['lelang']?.toString() ?? '0') ?? 0,
      writeoff: json['WRITEOFF'] as int? ?? 0,
      mutation: json['MUTATION'] as int? ?? 0,
      borrow: int.tryParse(json['borrow']?.toString() ?? '0') ?? 0,
      return_: int.tryParse(json['return']?.toString() ?? '0') ?? 0,
      move: json['MOVE'] as int? ?? 0,
      maintain: json['MANTAIN'] as int? ?? 0,
      klasifikasiWo: json['KLASIFIKASI_WO'] as String? ?? '',
      remarkWo: json['REMARK_WO'] as String? ?? '',
      userUpdateWo: json['USER_UPDATE_WO'] as String?,
      dateUpdateWo: parseDate(json['DATE_UPDATE_WO']),
      lastUpdate: parseDate(json['LAST_UPDATE']),
      userUpdate: json['USER_UPDATE'] as String? ?? '',
      branchType: json['BRANCH_TYPE'] as String? ?? '',
      branchName: json['BRANCH_NAME'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'MS_ASSET_BRANCH_ID': msAssetBranchId,
      'KODE_ASET': kodeAset,
      'BRANCH_ID': branchId,
      'LOKASI': lokasi,
      'IS_ACTIVE': isActive,
      'USER_CREATE': userCreate,
      'CREATE_DATE': createDate.toIso8601String(),
      'DIVISION': division,
      'PERSONAL_LOC': personalLoc,
      'DEPT': dept,
      'ROOM': room,
      'FLOOR': floor,
      'LATITUDE': latitude,
      'LONGITUDE': longitude,
      'LOCATION': location,
      'LELANG': lelang,
      'WRITEOFF': writeoff,
      'MUTATION': mutation,
      'BORROW': borrow,
      'RETURN': return_,
      'MOVE': move,
      'MANTAIN': maintain,
      'KLASIFIKASI_WO': klasifikasiWo,
      'REMARK_WO': remarkWo,
      'USER_UPDATE_WO': userUpdateWo,
      'DATE_UPDATE_WO': dateUpdateWo?.toIso8601String(),
      'LAST_UPDATE': lastUpdate?.toIso8601String(),
      'USER_UPDATE': userUpdate,
      'BRANCH_TYPE': branchType,
      'BRANCH_NAME': branchName,
    };
  }

  Asset copyWith({
    int? msAssetBranchId,
    String? kodeAset,
    String? branchId,
    String? lokasi,
    int? isActive,
    String? userCreate,
    DateTime? createDate,
    String? division,
    String? personalLoc,
    String? dept,
    String? room,
    String? floor,
    String? latitude,
    String? longitude,
    String? location,
    int? lelang,
    int? writeoff,
    int? mutation,
    int? borrow,
    int? return_,
    int? move,
    int? maintain,
    String? klasifikasiWo,
    String? remarkWo,
    String? userUpdateWo,
    DateTime? dateUpdateWo,
    DateTime? lastUpdate,
    String? userUpdate,
    String? branchType,
    String? branchName,
  }) {
    return Asset(
      msAssetBranchId: msAssetBranchId ?? this.msAssetBranchId,
      kodeAset: kodeAset ?? this.kodeAset,
      branchId: branchId ?? this.branchId,
      lokasi: lokasi ?? this.lokasi,
      isActive: isActive ?? this.isActive,
      userCreate: userCreate ?? this.userCreate,
      createDate: createDate ?? this.createDate,
      division: division ?? this.division,
      personalLoc: personalLoc ?? this.personalLoc,
      dept: dept ?? this.dept,
      room: room ?? this.room,
      floor: floor ?? this.floor,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      location: location ?? this.location,
      lelang: lelang ?? this.lelang,
      writeoff: writeoff ?? this.writeoff,
      mutation: mutation ?? this.mutation,
      borrow: borrow ?? this.borrow,
      return_: return_ ?? this.return_,
      move: move ?? this.move,
      maintain: maintain ?? this.maintain,
      klasifikasiWo: klasifikasiWo ?? this.klasifikasiWo,
      remarkWo: remarkWo ?? this.remarkWo,
      userUpdateWo: userUpdateWo ?? this.userUpdateWo,
      dateUpdateWo: dateUpdateWo ?? this.dateUpdateWo,
      lastUpdate: lastUpdate ?? this.lastUpdate,
      userUpdate: userUpdate ?? this.userUpdate,
      branchType: branchType ?? this.branchType,
      branchName: branchName ?? this.branchName,
    );
  }
}
