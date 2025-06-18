import 'package:get/get.dart';
import 'package:sufi_one/app/modules/DAMS/view/scan_code_page.dart';

class DamsRoute {
  //Penamaan
  // variabel: pertamaKedua
  // route: pertama_kedua

  static const scanCode = '/public/scan_code';

  static final routes = [
    GetPage(
      name: scanCode,
      transition: Transition.zoom,
      page: () => ScanCodePage(),
    ),
  ];
}
