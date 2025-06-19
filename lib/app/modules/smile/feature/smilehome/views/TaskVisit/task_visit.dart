import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sufi_one/app/modules/smile/feature/smilehome/controllers/task_visit_controller.dart';
import 'package:sufi_one/app/modules/smile/feature/smilehome/views/TaskVisit/visit_search_delegate.dart';

class TaskVisit extends GetView<TaskVisitController> {
  const TaskVisit({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0048A7), // Gunakan kode warna hex
        title: const Text(
          'Task Visit Dealer',
          style: TextStyle(color: Colors.white), // Warna teks putih
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () {
              // Menampilkan pencarian
              showSearch(
                context: context,
                delegate: VisitSearchDelegate(
                  controller,
                ), // Memanggil VisitSearchDelegate
              );
            },
          ),
        ],
      ),
      body: Obx(() {
        if (controller.filteredTaskVisitData.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        return ListView.builder(
          padding: const EdgeInsets.all(8.0),
          itemCount:
              controller.filteredTaskVisitData.length, // Gunakan filtered data
          itemBuilder: (context, index) {
            final data =
                controller
                    .filteredTaskVisitData[index]; // Ambil data dari filtered
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              child: ListTile(
                contentPadding: const EdgeInsets.all(16.0),
                title: Text(
                  data['cabang'] ?? '',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Text('PIC: ${data['pic'] ?? ''}'),
                    Text(data['type'] ?? ''),
                    Text(data['activity'] ?? ''),
                    Text(
                      data['timestamp'] ?? '',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _menuCard(
                      icon: Icons.visibility,
                      label: 'View',
                      onTap:
                          () => Get.toNamed(
                            '/public/smile/task_view',
                            arguments: data,
                          ),
                    ),
                    const SizedBox(width: 8),
                    _menuCard(
                      icon: Icons.edit,
                      label: 'Edit',
                      onTap:
                          () => Get.toNamed(
                            '/public/smile/task_edit',
                            arguments: data,
                          ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }),
    );
  }

  Widget _menuCard({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return OutlinedButton(
      onPressed: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.blue),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(color: Colors.blue)),
        ],
      ),
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: Colors.blue),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      ),
    );
  }
}
