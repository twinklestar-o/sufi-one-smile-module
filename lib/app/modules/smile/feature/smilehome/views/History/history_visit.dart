import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sufi_one/app/modules/smile/feature/smilehome/controllers/history_visit_controller.dart';
import 'package:sufi_one/app/modules/smile/models/visit.dart';

class HistoryVisit extends GetView<HistoryVisitController> {
  const HistoryVisit({super.key});

  @override
  Widget build(BuildContext context) {
    // Controller untuk input pencarian
    final TextEditingController searchController = TextEditingController();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A28C4), // Warna biru dari gambar
        title: const Text(
          'History Visit Dealer',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        actions: [],
      ),

      body: Column(
        children: [
          // Container untuk field pencarian di bawah header, diposisikan di tengah
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 1,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: searchController,
                style: const TextStyle(color: Colors.black87, fontSize: 14),
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  hintText: 'Cari...',
                  hintStyle: TextStyle(color: Colors.grey),
                  prefixIcon: Icon(Icons.search, size: 20, color: Colors.grey),
                  border: InputBorder.none,
                ),
                onChanged: (value) {
                  controller.filterData(value);
                },
              ),
            ),
          ),

          // Konten utama
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              if (controller.errorMessage.value.isNotEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        controller.errorMessage.value,
                        style: const TextStyle(color: Colors.red, fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () => controller.refreshData(),
                        child: const Text('Coba Lagi'),
                      ),
                    ],
                  ),
                );
              }
              if (controller.filteredHistoryData.isEmpty) {
                return const Center(child: Text('Tidak ada data riwayat kunjungan tersedia'));
              }
              return RefreshIndicator(
                onRefresh: controller.refreshData,
                child: ListView.builder(
                  padding: const EdgeInsets.all(8.0),
                  itemCount: controller.filteredHistoryData.length,
                  itemBuilder: (context, index) {
                    final data = controller.filteredHistoryData[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16.0),
                        title: Text(
                          data.branchCode ?? '-',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text('PIC: ${data.namaPic ?? '-'}'),
                            Text('Tipe Visit: ${data.tipeVisit ?? '-'}'),
                            Text('Tujuan: ${data.tujuanVisit ?? '-'}'),
                            Text(
                              'Tanggal: ${data.dariTanggal?.toIso8601String().split('T')[0] ?? '-'}',
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
                              onTap: () => Get.toNamed('/public/smile/history_view', arguments: data.toJson()),
                            ),
                            const SizedBox(width: 8),
                            _menuCard(
                              icon: Icons.edit,
                              label: 'Edit',
                              onTap: () => Get.toNamed('/public/smile/history_edit', arguments: data.toJson()),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _menuCard({required IconData icon, required String label, required VoidCallback onTap}) {
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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      ),
    );
  }
}