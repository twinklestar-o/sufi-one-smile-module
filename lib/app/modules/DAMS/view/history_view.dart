import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:sufi_one/app/modules/DAMS/controller/history_controller.dart';
import 'package:sufi_one/app/modules/DAMS/model/stockOpname.dart';
import 'package:sufi_one/app/modules/DAMS/view/edit_screen.dart';
import 'package:sufi_one/app/modules/DAMS/view/view_screen.dart';

class HistoryStockPage extends StatelessWidget {
  final HistoryController controller = Get.put(HistoryController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("History Stock Opname"), centerTitle: true),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(child: CircularProgressIndicator());
        }

        if (controller.errorMessage.isNotEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Terjadi kesalahan"),
                Text(controller.errorMessage.value),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => controller.fetchHistoryStock(),
                  child: Text("Coba Lagi"),
                ),
              ],
            ),
          );
        }

        if (controller.historyList.isEmpty) {
          return Center(child: Text("Tidak ada data"));
        }

        return RefreshIndicator(
          onRefresh: () => controller.fetchHistoryStock(),
          child: ListView.builder(
            padding: EdgeInsets.all(10),
            itemCount: controller.historyList.length,
            itemBuilder: (context, index) {
              final item = controller.historyList[index];
              return _buildHistoryItem(item);
            },
          ),
        );
      }),
    );
  }

  Widget _buildHistoryItem(HistoryStockOpname item) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      margin: EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item.trxNo,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            SizedBox(height: 8),
            Text(item.item, style: TextStyle(fontSize: 14)),
            SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.person, size: 16, color: Colors.grey),
                SizedBox(width: 4),
                Text(item.uscrt, style: TextStyle(color: Colors.grey[600])),
                Spacer(),
                Icon(Icons.access_time, size: 16, color: Colors.grey),
                SizedBox(width: 4),
                Text(
                  DateFormat(
                    'dd/MM/yyyy HH:mm',
                  ).format(DateTime.parse(item.crdt)),
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
            SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.blue.withOpacity(0.1),
                  ),
                  onPressed: () => _onEditPressed(item),
                  child: Text('Edit', style: TextStyle(color: Colors.blue)),
                ),
                SizedBox(width: 8),
                TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.green.withOpacity(0.1),
                  ),
                  onPressed: () => _onViewPressed(item),
                  child: Text('View', style: TextStyle(color: Colors.green)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // In the _onViewPressed method:
  void _onViewPressed(HistoryStockOpname item) async {
    try {
      final detail = await controller.getStockDetail(item.id);
      Get.to(() => ViewScreen(data: detail));
    } catch (e) {
      Get.snackbar('Error', e.toString());
    }
  }

  // In the _onEditPressed method:
  void _onEditPressed(HistoryStockOpname item) async {
    try {
      // First get the detailed data
      final detail = await controller.getStockDetail(item.id);

      // Then navigate to edit screen with the data
      Get.to(() => EditScreen(assetId: item.id, initialData: detail));
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}
