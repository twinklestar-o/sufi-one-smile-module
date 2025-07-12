import 'package:get/get.dart';
import 'package:sufi_one/app/modules/DAMS/view/history_view.dart';
import 'package:sufi_one/app/modules/DAMS/view/scan_code_page.dart';
import 'package:sufi_one/app/modules/DAMS/view/dams_view.dart';

class DamsRoute {
  //Penamaan
  // variabel: pertamaKedua
  // route: pertama_kedua

  static const scanCode = '/public/dams/scan_code';
  static const homePage = '/public/dams/home_page';
  static const historyPage = '/public/dams/asset/history';
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
      name: historyPage,
      transition: Transition.zoom,
      page: () => HistoryStockPage(),
    ),
  ];
}
