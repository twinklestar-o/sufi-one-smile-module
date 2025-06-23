import 'package:get/get.dart';
import 'package:sufi_one/app/modules/smile/feature/smilehome/controllers/history_edit_controller.dart';

class HistoryEditBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HistoryEditController>(() => HistoryEditController());
  }
}

