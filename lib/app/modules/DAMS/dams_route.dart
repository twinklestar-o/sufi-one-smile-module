import 'package:get/get.dart';
import 'package:sufi_one/app/modules/DAMS/view/scan_code_page.dart';
import 'package:sufi_one/app/modules/DAMS/view/dams_view.dart';

class DamsRoute {
  //Penamaan
  // variabel: pertamaKedua
  // route: pertama_kedua

  static const scanCode = '/public/scan_code';
  static const homePage = '/public/home_page';

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
  ];
}
