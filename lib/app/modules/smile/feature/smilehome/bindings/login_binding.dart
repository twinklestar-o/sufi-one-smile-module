import 'package:get/get.dart';
import 'package:sufi_one/app/modules/smile/feature/smilehome/controllers/login_controller.dart';

class LoginBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LoginController>(() => LoginController());
  }
}
