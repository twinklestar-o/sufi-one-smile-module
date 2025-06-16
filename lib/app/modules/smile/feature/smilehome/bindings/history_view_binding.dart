import 'package:get/get.dart';
import 'package:sufi_one/app/modules/smile/feature/smilehome/controllers/history_view_controller.dart';

class HistoryViewBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HistoryViewController>(() => HistoryViewController());
  }
}