import 'package:get/get.dart';
import 'package:sufi_one/app/modules/DAMS/view/history_view.dart';
import 'package:sufi_one/app/modules/DAMS/view/list_master/data_master.dart';
import 'package:sufi_one/app/modules/DAMS/view/list_master/status_asset_screen.dart';
import 'package:sufi_one/app/modules/DAMS/view/list_master/kondisi_asset_screen.dart';
import 'package:sufi_one/app/modules/DAMS/view/list_master/status_user_asset_screen.dart';
import 'package:sufi_one/app/modules/DAMS/view/list_master/posisi_user_screen.dart';
import 'package:sufi_one/app/modules/DAMS/view/list_master/lokasi_user_screen.dart';
import 'package:sufi_one/app/modules/DAMS/view/list_master/divisi_user_screen.dart';
import 'package:sufi_one/app/modules/DAMS/view/list_master/lantai_user_screen.dart';
import 'package:sufi_one/app/modules/DAMS/view/scan_code_page.dart';
import 'package:sufi_one/app/modules/DAMS/view/dams_view.dart';

class DamsRoute {
  //Penamaan
  // variabel: pertamaKedua
  // route: pertama_kedua

  static const scanCode = '/public/dams/scan_code';
  static const homePage = '/public/dams/home_page';
  static const historyPage = '/public/dams/asset/history';
  static const listMaster = '/public/dams/list-master';

  // List Master
  static const statusAsset = '/public/dams/list-master/status-asset';
  static const kondisiAsset = '/public/dams/list-master/kondisi-asset';
  static const statusUserAsset = '/public/dams/list-master/status-user-asset';
  static const posisiUser = '/public/dams/list-master/posisi-user';
  static const divisiUser = '/public/dams/list-master/divisi-user';
  static const lokasiUser = '/public/dams/list-master/lokasi-user';
  static const lantaiUser = '/public/dams/list-master/lantai-user';

  static final routes = [
    GetPage(
      name: scanCode,
      transition: Transition.zoom,
      page: () => ScanCodePage(),
    ),
    GetPage(
      name: homePage,
      transition: Transition.zoom,
      page: () => DamsHomePage(),
    ),
    GetPage(
      name: listMaster,
      transition: Transition.zoom,
      page: () => DataMaster(),
    ),
    GetPage(
      name: historyPage,
      transition: Transition.zoom,
      page: () => HistoryStockPage(),
    ),
    GetPage(
      name: statusAsset,
      transition: Transition.zoom,
      page: () => StatusAssetPage(),
    ),
    GetPage(
      name: kondisiAsset,
      transition: Transition.zoom,
      page: () => KondisiAssetPage(),
    ),
    GetPage(
      name: statusUserAsset,
      transition: Transition.zoom,
      page: () => StatusUserAssetPage(),
    ),
    GetPage(
      name: posisiUser,
      transition: Transition.zoom,
      page: () => PosisiUserPage(),
    ),
    GetPage(
      name: lokasiUser,
      transition: Transition.zoom,
      page: () => LokasiUserPage(),
    ),
    GetPage(
      name: divisiUser,
      transition: Transition.zoom,
      page: () => DivisiUserPage(),
    ),
    GetPage(
      name: lantaiUser,
      transition: Transition.zoom,
      page: () => LantaiUserPage(),
    ),
  ];
}
