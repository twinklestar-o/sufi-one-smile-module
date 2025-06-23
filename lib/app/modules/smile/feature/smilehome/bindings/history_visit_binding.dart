import 'package:get/get.dart';
import 'package:sufi_one/app/modules/smile/feature/smilehome/controllers/history_visit_controller.dart';

class HistoryVisitBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HistoryVisitController>(() => HistoryVisitController());
  }
}
