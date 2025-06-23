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
    DateTime? parseDate(dynamic dateValue) {
      if (dateValue == null) return null;

      try {
        if (dateValue is DateTime) return dateValue;

        if (dateValue is String) {
          try {
            return DateTime.parse(dateValue);
          } catch (_) {
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

        if (dateValue is int) {
          return DateTime.fromMillisecondsSinceEpoch(dateValue);
        }

        return null;
      } catch (e) {
        print('Error parsing date: $dateValue');
        return null;
      }
    }

    final createDate =
        parseDate(json['CREATE_DATE'] ?? json['create_date']) ?? DateTime.now();

    return Asset(
      msAssetBranchId:
          json['MS_ASSET_BRANCH_ID'] ?? json['ms_asset_branch_id'] as int? ?? 0,
      kodeAset: json['KODE_ASET'] ?? json['kode_aset'] as String? ?? '',
      branchId: json['BRANCH_ID'] ?? json['branch_id'] as String? ?? '',
      lokasi: json['LOKASI'] ?? json['lokasi'] as String? ?? '',
      isActive: json['IS_ACTIVE'] ?? json['is_active'] as int? ?? 0,
      userCreate: json['USER_CREATE'] ?? json['user_create'] as String? ?? '',
      createDate: createDate,
      division: json['DIVISION'] ?? json['division'],
      personalLoc: json['PERSONAL_LOC'] ?? json['personal_loc'],
      dept: json['DEPT'] ?? json['dept'],
      room: json['ROOM'] ?? json['room'],
      floor: json['FLOOR'] ?? json['floor'],
      latitude: json['LATITUDE'] ?? json['latitude'],
      longitude: json['LONGITUDE'] ?? json['longitude'],
      location: json['LOCATION'] ?? json['location'],
      lelang: json['lelang'] as int? ?? 0,
      writeoff: json['WRITEOFF'] ?? json['writeoff'] as int? ?? 0,
      mutation: json['MUTATION'] ?? json['mutation'] as int? ?? 0,
      borrow: json['borrow'] as int? ?? 0,
      return_: json['return'] as int? ?? 0,
      move: json['MOVE'] ?? json['move'] as int? ?? 0,
      maintain: json['MANTAIN'] ?? json['maintan'] as int? ?? 0,
      klasifikasiWo: json['KLASIFIKASI_WO'] ?? json['klasifikasi_wo'],
      remarkWo: json['REMARK_WO'] ?? json['remark_wo'],
      userUpdateWo: json['USER_UPDATE_WO'] ?? json['user_update_wo'],
      dateUpdateWo: parseDate(json['DATE_UPDATE_WO'] ?? json['date_update_wo']),
      lastUpdate: parseDate(json['LAST_UPDATE'] ?? json['last_update']),
      userUpdate: json['USER_UPDATE'] ?? json['user_update'],
      branchType: json['BRANCH_TYPE'] ?? json['branch_type'],
      branchName: json['BRANCH_NAME'] ?? json['branch_name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ms_asset_branch_id': msAssetBranchId,
      'kode_aset': kodeAset,
      'branch_id': branchId,
      'lokasi': lokasi,
      'is_active': isActive,
      'user_create': userCreate,
      'create_date': createDate.toIso8601String(),
      'division': division,
      'personal_loc': personalLoc,
      'dept': dept,
      'room': room,
      'floor': floor,
      'latitude': latitude,
      'longitude': longitude,
      'location': location,
      'lelang': lelang,
      'writeoff': writeoff,
      'mutation': mutation,
      'borrow': borrow,
      'return': return_,
      'move': move,
      'maintan': maintain,
      'klasifikasi_wo': klasifikasiWo,
      'remark_wo': remarkWo,
      'user_update_wo': userUpdateWo,
      'date_update_wo': dateUpdateWo?.toIso8601String(),
      'last_update': lastUpdate?.toIso8601String(),
      'user_update': userUpdate,
      'branch_type': branchType,
      'branch_name': branchName,
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
