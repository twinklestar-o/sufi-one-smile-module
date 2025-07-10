import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sufi_one/app/modules/smile/feature/smilehome/controllers/task_visit_controller.dart';
import '../../../../models/visit.dart';
import 'package:sufi_one/app/modules/smile/feature/smilehome/views/TaskVisit/visit_search_delegate.dart';
import 'package:sufi_one/app/modules/smile/smile_route.dart';

class TaskVisit extends GetView<TaskVisitController> {
  const TaskVisit({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0048A7),
        title: const Text(
          'Task Visit Dealer',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () {
              showSearch(
                context: context,
                delegate: VisitSearchDelegate(controller),
              );
            },
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF0048A7),
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () async {
          final result = await Get.toNamed('/public/smile/direct_visit');
          if (result != null && result is Visit) {
            controller.taskVisitData.add(result);
            controller.filteredTaskVisitData.assignAll(controller.taskVisitData);
          }
        },
      ),

      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.filteredTaskVisitData.isEmpty) {
          return const Center(child: Text('Tidak ada data Task Visit.'));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(8.0),
          itemCount: controller.filteredTaskVisitData.length,
          itemBuilder: (context, index) {
            final visit = controller.filteredTaskVisitData[index];
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      visit.branchCode ?? '',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 4),
                    Text('PIC: ${visit.namaPic ?? ''}'),
                    Text('Tipe Visit: ${visit.tipeVisit ?? ''}'),
                    Text('Tujuan: ${visit.tujuanVisit ?? ''}'),
                    Text(
                      _formatTanggal(visit.dariTanggal),
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        OutlinedButton.icon(
                          icon: const Icon(Icons.remove_red_eye),
                          label: const Text("View"),
                          onPressed: () => Get.toNamed(SmileRoutes.taskView, arguments: visit),
                        ),
                        const SizedBox(width: 8),
                        OutlinedButton.icon(
                          icon: const Icon(Icons.edit),
                          label: const Text("Edit"),
                          onPressed: () async {
                            final result = await Get.toNamed(SmileRoutes.taskEdit, arguments: visit);
                            if (result != null && result is Visit) {
                              controller.updateTaskVisit(result);
                            }
                          },
                        ),
                      ],
                    )
                  ],
                ),
              ),
            );
          },
        );
      }),
    );
  }

  String _formatTanggal(DateTime? date) {
    if (date == null) return '';
    return '${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}';
  }
}
