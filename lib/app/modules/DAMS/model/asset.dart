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
  final AssetDetail? detail; // Tambahan field untuk detail asset

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
    this.detail, // Tambahkan parameter detail
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

    // Handle nested ms_asset_branch jika ada
    final branchData = json['ms_asset_branch'] ?? json;

    return Asset(
      msAssetBranchId:
          branchData['MS_ASSET_BRANCH_ID'] ??
          branchData['ms_asset_branch_id'] as int? ??
          0,
      kodeAset:
          branchData['KODE_ASET'] ?? branchData['kode_aset'] as String? ?? '',
      branchId:
          branchData['BRANCH_ID'] ?? branchData['branch_id'] as String? ?? '',
      lokasi: branchData['LOKASI'] ?? branchData['lokasi'] as String? ?? '',
      isActive: branchData['IS_ACTIVE'] ?? branchData['is_active'] as int? ?? 0,
      userCreate:
          branchData['USER_CREATE'] ??
          branchData['user_create'] as String? ??
          '',
      createDate: createDate,
      division: branchData['DIVISION'] ?? branchData['division'],
      personalLoc: branchData['PERSONAL_LOC'] ?? branchData['personal_loc'],
      dept: branchData['DEPT'] ?? branchData['dept'],
      room: branchData['ROOM'] ?? branchData['room'],
      floor: branchData['FLOOR'] ?? branchData['floor'],
      latitude: branchData['LATITUDE'] ?? branchData['latitude'],
      longitude: branchData['LONGITUDE'] ?? branchData['longitude'],
      location: branchData['LOCATION'] ?? branchData['location'],
      lelang: branchData['lelang'] as int? ?? 0,
      writeoff: branchData['WRITEOFF'] ?? branchData['writeoff'] as int? ?? 0,
      mutation: branchData['MUTATION'] ?? branchData['mutation'] as int? ?? 0,
      borrow: branchData['borrow'] as int? ?? 0,
      return_: branchData['return'] as int? ?? 0,
      move: branchData['MOVE'] ?? branchData['move'] as int? ?? 0,
      maintain: branchData['MANTAIN'] ?? branchData['maintan'] as int? ?? 0,
      klasifikasiWo:
          branchData['KLASIFIKASI_WO'] ?? branchData['klasifikasi_wo'],
      remarkWo: branchData['REMARK_WO'] ?? branchData['remark_wo'],
      userUpdateWo:
          branchData['USER_UPDATE_WO'] ?? branchData['user_update_wo'],
      dateUpdateWo: parseDate(
        branchData['DATE_UPDATE_WO'] ?? branchData['date_update_wo'],
      ),
      lastUpdate: parseDate(
        branchData['LAST_UPDATE'] ?? branchData['last_update'],
      ),
      userUpdate: branchData['USER_UPDATE'] ?? branchData['user_update'],
      branchType: branchData['BRANCH_TYPE'] ?? branchData['branch_type'],
      branchName: branchData['BRANCH_NAME'] ?? branchData['branch_name'],
      // Tambahkan parsing untuk detail asset jika ada
      detail:
          json['asset_detail'] != null
              ? AssetDetail.fromJson(json['asset_detail'])
              : null,
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
      'asset_detail': detail?.toJson(), // Tambahkan detail ke JSON
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
    AssetDetail? detail, // Tambahkan parameter detail
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
      detail: detail ?? this.detail, // Tambahkan detail
    );
  }
}

// Model baru untuk Asset Detail
class AssetDetail {
  final int? msAssetDetailId;
  final String? noReceive;
  final String kodeAset;
  final String? group;
  final String? subgroup;
  final String? item;
  final String? merk;
  final String? type;
  final String? noRangka;
  final String? noMesin;
  final String? noBpkb;
  final String? noFaktur;
  final String? nopol;
  final String? noStnk;
  final String? crdt;
  final String? userCreate;
  final String? status;
  final String? description;
  final String? costAc;
  final String? bokVal;
  final String? condition;
  final String? locRoom;
  final String? detInfUpd;
  final String? addRemark;
  final String? bpkbStatus;
  final String? asetDesc;
  final String? tahun;
  final String? color;
  final String? username;
  final String? noRegisterBpkb;
  final DateTime? tglTempoStnk;
  final DateTime? tglTempoStnkPajak;
  final String? noInventaris;
  final String? noAccounting;
  final DateTime? tahunPembelian;
  final String? serialNumberSoftware;
  final String? serialNumberHardware;
  final DateTime? tanggalPembelian;
  final String? position;
  final DateTime? acquisitionDate;
  final String? assetUse;
  final String? employeeJob;
  final String? bpkbOwner;
  final String? trx;
  final DateTime? insuranceStart;
  final DateTime? insuranceEnd;
  final String? basicRateOjkForTlo;
  final String? sumInsuredTotal;
  final String? grossPremiumTotal;
  final String? additionalDiscountInsuranceCompany;
  final String? premiumAfterAdditionalDiscount;
  final String? ojkDiscount;
  final String? netPremiumGrandTotal;
  final String? numberOfInsurancePolis;
  final String? periodOfPolis;
  final String? insuranceCompany;
  final String? certificateNumber;
  final DateTime? lastUpdate;
  final String? userUpdate;
  final String? validation;
  final DateTime? tglTerima;
  final String? dailyUser;
  final String? noTiket;
  final String? imageUrl;
  final String? usernameStatus;

  AssetDetail({
    this.msAssetDetailId,
    this.noReceive,
    required this.kodeAset,
    this.group,
    this.subgroup,
    this.item,
    this.merk,
    this.type,
    this.noRangka,
    this.noMesin,

    this.noBpkb,
    this.noFaktur,
    this.nopol,
    this.noStnk,
    this.crdt,

    this.userCreate,
    this.status,
    this.description,
    this.costAc,
    this.bokVal,

    this.condition,
    this.locRoom,
    this.detInfUpd,
    this.addRemark,
    this.bpkbStatus,

    this.asetDesc,
    this.tahun,
    this.color,
    this.username,
    this.noRegisterBpkb,

    this.tglTempoStnk,
    this.tglTempoStnkPajak,
    this.noInventaris,
    this.noAccounting,
    this.tahunPembelian,

    this.serialNumberSoftware,
    this.serialNumberHardware,
    this.tanggalPembelian,
    this.position,
    this.acquisitionDate,

    this.assetUse,
    this.employeeJob,
    this.bpkbOwner,
    this.trx,
    this.insuranceStart,

    this.insuranceEnd,
    this.basicRateOjkForTlo,
    this.sumInsuredTotal,
    this.grossPremiumTotal,
    this.additionalDiscountInsuranceCompany,

    this.premiumAfterAdditionalDiscount,
    this.ojkDiscount,
    this.netPremiumGrandTotal,
    this.numberOfInsurancePolis,
    this.periodOfPolis,

    this.insuranceCompany,
    this.certificateNumber,
    this.lastUpdate,
    this.userUpdate,
    this.validation,

    this.tglTerima,
    this.dailyUser,
    this.noTiket,
    this.usernameStatus,
    this.imageUrl,
  });

  factory AssetDetail.fromJson(Map<String, dynamic> json) {
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
        print('Error parsing date in AssetDetail: $dateValue');
        return null;
      }
    }

    return AssetDetail(
      msAssetDetailId:
          json['MS_ASSET_DETAIL_ID'] ?? json['ms_asset_detail_id'] as int?,
      noReceive: json['NO_RECEIVE'] ?? json['no_receive'],
      kodeAset: json['KODE_ASET'] ?? json['kode_aset'] as String? ?? '',
      group: json['GROUP'] ?? json['group'],
      subgroup: json['SUBGROUP'] ?? json['subgroup'],
      item: json['ITEM'] ?? json['item'],
      merk: json['MERK'] ?? json['merk'],
      type: json['TYPE'] ?? json['type'],
      noRangka: json['NO_RANGKA'] ?? json['no_rangka'],
      noMesin: json['NO_MESIN'] ?? json['no_mesin'],
      noBpkb: json['NO_BPKB'] ?? json['no_bpkb'],
      noFaktur: json['NO_FAKTUR'] ?? json['no_faktur'],
      nopol: json['NOPOL'] ?? json['nopol'],
      noStnk: json['NO_STNK'] ?? json['no_stnk'],
      crdt: json['CRDT'] ?? json['crdt'],
      userCreate: json['USER_CREATE'] ?? json['user_create'],
      status: json['STATUS'] ?? json['status'],
      description: json['DESCRIPTION'] ?? json['description'],
      costAc: json['COST_AC'] ?? json['cost_ac'],
      bokVal: json['BOK_VAL'] ?? json['bok_val'],
      condition: json['CONDITION'] ?? json['condition'],
      locRoom: json['LOC_ROOM'] ?? json['loc_room'],
      detInfUpd: json['DET_INF_UPD'] ?? json['det_inf_upd'],
      addRemark: json['ADD_REMARK'] ?? json['add_remark'],
      bpkbStatus: json['BPKB_STATUS'] ?? json['bpkb_status'],
      asetDesc: json['ASET_DESC'] ?? json['aset_desc'],
      tahun: json['TAHUN'] ?? json['tahun'],
      color: json['COLOR'] ?? json['color'],
      username: json['USERNAME'] ?? json['username'],
      noRegisterBpkb: json['NO_REGISTER_BPKB'] ?? json['no_register_bpkb'],
      tglTempoStnk: parseDate(json['TGL_TEMPO_STNK'] ?? json['tgl_tempo_stnk']),
      tglTempoStnkPajak: parseDate(
        json['TGL_TEMPO_STNK_PAJAK'] ?? json['tgl_tempo_stnk_pajak'],
      ),
      noInventaris: json['NO_INVENTARIS'] ?? json['no_inventaris'],
      noAccounting: json['NO_ACCOUNTING'] ?? json['no_accounting'],
      tahunPembelian: parseDate(
        json['TAHUN_PEMBELIAN'] ?? json['tahun_pembelian'],
      ),
      serialNumberSoftware:
          json['SERIAL_NUMBER_SOFTWARE'] ?? json['serial_number_software'],
      serialNumberHardware:
          json['SERIAL_NUMBER_HARDWARE'] ?? json['serial_number_hardware'],
      tanggalPembelian: parseDate(
        json['TANGGAL_PEMBELIAN'] ?? json['tanggal_pembelian'],
      ),
      position: json['POSITION'] ?? json['position'],
      acquisitionDate: parseDate(
        json['ACQUISITION_DATE'] ?? json['acquisition_date'],
      ),
      assetUse: json['ASSET_USE'] ?? json['asset_use'],
      employeeJob: json['EMPLOYEE_JOB'] ?? json['employee_job'],
      bpkbOwner: json['BPKB_OWNER'] ?? json['bpkb_owner'],
      trx: json['TRX'] ?? json['trx'],
      insuranceStart: parseDate(
        json['INSURANCE_START'] ?? json['insurance_start'],
      ),
      insuranceEnd: parseDate(json['INSURANCE_END'] ?? json['insurance_end']),
      basicRateOjkForTlo:
          json['BASIC_RATE_OJK_FOR_TLO'] ?? json['basic_rate_ojk_for_tlo'],
      sumInsuredTotal: json['SUM_INSURED_TOTAL'] ?? json['sum_insured_total'],
      grossPremiumTotal:
          json['GROSS_PREMIUM_TOTAL'] ?? json['gross_premium_total'],
      additionalDiscountInsuranceCompany:
          json['ADDITIONAL_DISCOUNT_INSURANCE_COMPANY'] ??
          json['additional_discount_insurance_company'],
      premiumAfterAdditionalDiscount:
          json['PREMIUM_AFTER_ADDITIONAL_DISCOUNT'] ??
          json['premium_after_additional_discount'],
      ojkDiscount: json['OJK_DISCOUNT'] ?? json['ojk_discount'],
      netPremiumGrandTotal:
          json['NET_PREMIUM_GRAND_TOTAL'] ?? json['net_premium_grand_total'],
      numberOfInsurancePolis:
          json['NUMBER_OF_INSURANCE_POLIS'] ??
          json['number_of_insurance_polis'],
      periodOfPolis: json['PERIOD_OF_POLIS'] ?? json['period_of_polis'],
      insuranceCompany: json['INSURANCE_COMPANY'] ?? json['insurance_company'],
      certificateNumber:
          json['CERTIFICATE_NUMBER'] ?? json['certificate_number'],
      lastUpdate: parseDate(json['LAST_UPDATE'] ?? json['last_update']),
      userUpdate: json['USER_UPDATE'] ?? json['user_update'],
      validation: json['VALIDATION'] ?? json['validation'],
      tglTerima: parseDate(json['TGL_TERIMA'] ?? json['tgl_terima']),
      dailyUser: json['DAILY_USER'] ?? json['daily_user'],
      noTiket: json['NO_TIKET'] ?? json['no_tiket'],
      usernameStatus: json['USERNAME_STATUS'] ?? json['username_status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ms_asset_detail_id': msAssetDetailId,
      'no_receive': noReceive,
      'kode_aset': kodeAset,
      'group': group,
      'subgroup': subgroup,
      'item': item,
      'merk': merk,
      'type': type,
      'no_rangka': noRangka,
      'no_mesin': noMesin,
      'no_bpkb': noBpkb,
      'no_faktur': noFaktur,
      'nopol': nopol,
      'no_stnk': noStnk,
      'crdt': crdt,
      'user_create': userCreate,
      'status': status,
      'description': description,
      'cost_ac': costAc,
      'bok_val': bokVal,
      'condition': condition,
      'loc_room': locRoom,
      'det_inf_upd': detInfUpd,
      'add_remark': addRemark,
      'bpkb_status': bpkbStatus,
      'aset_desc': asetDesc,
      'tahun': tahun,
      'color': color,
      'username': username,
      'no_register_bpkb': noRegisterBpkb,
      'tgl_tempo_stnk': tglTempoStnk?.toIso8601String(),
      'tgl_tempo_stnk_pajak': tglTempoStnkPajak?.toIso8601String(),
      'no_inventaris': noInventaris,
      'no_accounting': noAccounting,
      'tahun_pembelian': tahunPembelian?.toIso8601String(),
      'serial_number_software': serialNumberSoftware,
      'serial_number_hardware': serialNumberHardware,
      'tanggal_pembelian': tanggalPembelian?.toIso8601String(),
      'position': position,
      'acquisition_date': acquisitionDate?.toIso8601String(),
      'asset_use': assetUse,
      'employee_job': employeeJob,
      'bpkb_owner': bpkbOwner,
      'trx': trx,
      'insurance_start': insuranceStart?.toIso8601String(),
      'insurance_end': insuranceEnd?.toIso8601String(),
      'basic_rate_ojk_for_tlo': basicRateOjkForTlo,
      'sum_insured_total': sumInsuredTotal,
      'gross_premium_total': grossPremiumTotal,
      'additional_discount_insurance_company':
          additionalDiscountInsuranceCompany,
      'premium_after_additional_discount': premiumAfterAdditionalDiscount,
      'ojk_discount': ojkDiscount,
      'net_premium_grand_total': netPremiumGrandTotal,
      'number_of_insurance_polis': numberOfInsurancePolis,
      'period_of_polis': periodOfPolis,
      'insurance_company': insuranceCompany,
      'certificate_number': certificateNumber,
      'last_update': lastUpdate?.toIso8601String(),
      'user_update': userUpdate,
      'validation': validation,
      'tgl_terima': tglTerima?.toIso8601String(),
      'daily_user': dailyUser,
      'no_tiket': noTiket,
      'username_status': usernameStatus,
    };
  }

  AssetDetail copyWith({
    int? msAssetDetailId,
    String? noReceive,
    String? kodeAset,
    String? group,
    String? subgroup,
    String? item,
    String? merk,
    String? type,
    String? noRangka,
    String? noMesin,
    String? noBpkb,
    String? noFaktur,
    String? nopol,
    String? noStnk,
    String? crdt,
    String? userCreate,
    String? status,
    String? description,
    String? costAc,
    String? bokVal,
    String? condition,
    String? locRoom,
    String? detInfUpd,
    String? addRemark,
    String? bpkbStatus,
    String? asetDesc,
    String? tahun,
    String? color,
    String? username,
    String? noRegisterBpkb,
    DateTime? tglTempoStnk,
    DateTime? tglTempoStnkPajak,
    String? noInventaris,
    String? noAccounting,
    DateTime? tahunPembelian,
    String? serialNumberSoftware,
    String? serialNumberHardware,
    DateTime? tanggalPembelian,
    String? position,
    DateTime? acquisitionDate,
    String? assetUse,
    String? employeeJob,
    String? bpkbOwner,
    String? trx,
    DateTime? insuranceStart,
    DateTime? insuranceEnd,
    String? basicRateOjkForTlo,
    String? sumInsuredTotal,
    String? grossPremiumTotal,
    String? additionalDiscountInsuranceCompany,
    String? premiumAfterAdditionalDiscount,
    String? ojkDiscount,
    String? netPremiumGrandTotal,
    String? numberOfInsurancePolis,
    String? periodOfPolis,
    String? insuranceCompany,
    String? certificateNumber,
    DateTime? lastUpdate,
    String? userUpdate,
    String? validation,
    DateTime? tglTerima,
    String? dailyUser,
    String? noTiket,
    String? usernameStatus,
  }) {
    return AssetDetail(
      msAssetDetailId: msAssetDetailId ?? this.msAssetDetailId,
      noReceive: noReceive ?? this.noReceive,
      kodeAset: kodeAset ?? this.kodeAset,
      group: group ?? this.group,
      subgroup: subgroup ?? this.subgroup,
      item: item ?? this.item,
      merk: merk ?? this.merk,
      type: type ?? this.type,
      noRangka: noRangka ?? this.noRangka,
      noMesin: noMesin ?? this.noMesin,
      noBpkb: noBpkb ?? this.noBpkb,
      noFaktur: noFaktur ?? this.noFaktur,
      nopol: nopol ?? this.nopol,
      noStnk: noStnk ?? this.noStnk,
      crdt: crdt ?? this.crdt,
      userCreate: userCreate ?? this.userCreate,
      status: status ?? this.status,
      description: description ?? this.description,
      costAc: costAc ?? this.costAc,
      bokVal: bokVal ?? this.bokVal,
      condition: condition ?? this.condition,
      locRoom: locRoom ?? this.locRoom,
      detInfUpd: detInfUpd ?? this.detInfUpd,
      addRemark: addRemark ?? this.addRemark,
      bpkbStatus: bpkbStatus ?? this.bpkbStatus,
      asetDesc: asetDesc ?? this.asetDesc,
      tahun: tahun ?? this.tahun,
      color: color ?? this.color,
      username: username ?? this.username,
      noRegisterBpkb: noRegisterBpkb ?? this.noRegisterBpkb,
      tglTempoStnk: tglTempoStnk ?? this.tglTempoStnk,
      tglTempoStnkPajak: tglTempoStnkPajak ?? this.tglTempoStnkPajak,
      noInventaris: noInventaris ?? this.noInventaris,
      noAccounting: noAccounting ?? this.noAccounting,
      tahunPembelian: tahunPembelian ?? this.tahunPembelian,
      serialNumberSoftware: serialNumberSoftware ?? this.serialNumberSoftware,
      serialNumberHardware: serialNumberHardware ?? this.serialNumberHardware,
      tanggalPembelian: tanggalPembelian ?? this.tanggalPembelian,
      position: position ?? this.position,
      acquisitionDate: acquisitionDate ?? this.acquisitionDate,
      assetUse: assetUse ?? this.assetUse,
      employeeJob: employeeJob ?? this.employeeJob,
      bpkbOwner: bpkbOwner ?? this.bpkbOwner,
      trx: trx ?? this.trx,
      insuranceStart: insuranceStart ?? this.insuranceStart,
      insuranceEnd: insuranceEnd ?? this.insuranceEnd,
      basicRateOjkForTlo: basicRateOjkForTlo ?? this.basicRateOjkForTlo,
      sumInsuredTotal: sumInsuredTotal ?? this.sumInsuredTotal,
      grossPremiumTotal: grossPremiumTotal ?? this.grossPremiumTotal,
      additionalDiscountInsuranceCompany:
          additionalDiscountInsuranceCompany ??
          this.additionalDiscountInsuranceCompany,
      premiumAfterAdditionalDiscount:
          premiumAfterAdditionalDiscount ?? this.premiumAfterAdditionalDiscount,
      ojkDiscount: ojkDiscount ?? this.ojkDiscount,
      netPremiumGrandTotal: netPremiumGrandTotal ?? this.netPremiumGrandTotal,
      numberOfInsurancePolis:
          numberOfInsurancePolis ?? this.numberOfInsurancePolis,
      periodOfPolis: periodOfPolis ?? this.periodOfPolis,
      insuranceCompany: insuranceCompany ?? this.insuranceCompany,
      certificateNumber: certificateNumber ?? this.certificateNumber,
      lastUpdate: lastUpdate ?? this.lastUpdate,
      userUpdate: userUpdate ?? this.userUpdate,
      validation: validation ?? this.validation,
      tglTerima: tglTerima ?? this.tglTerima,
      dailyUser: dailyUser ?? this.dailyUser,
      noTiket: noTiket ?? this.noTiket,
      usernameStatus: usernameStatus ?? this.usernameStatus,
    );
  }
}
