import 'package:get/get.dart';
import 'package:sufi_one/app/modules/smile/feature/smilehome/controllers/task_visit_controller.dart';

class TaskVisitBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TaskVisitController>(() => TaskVisitController());
  }
}
