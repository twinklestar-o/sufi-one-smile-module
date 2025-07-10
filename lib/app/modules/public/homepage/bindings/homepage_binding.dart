import 'package:get/get.dart';
import 'package:sufi_one/app/modules/public/homepage/controllers/homepage_controller.dart';

class HomepageBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomepageController>(() => HomepageController());
  }
}
