import 'package:get/get.dart';
import 'package:sufi_one/app/modules/smile/feature/smilehome/controllers/task_view_controller.dart';

class TaskViewBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TaskViewController>(() => TaskViewController());
  }
}
