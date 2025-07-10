import 'package:get/get.dart';
import 'package:sufi_one/app/modules/smile/feature/smilehome/controllers/task_edit_controller.dart';

class TaskEditBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TaskEditController>(() => TaskEditController());
  }
}
