import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:get/get.dart';

class TaskVisitController extends GetxController {
  // Data asli dari JSON
  final RxList<Map<String, dynamic>> taskVisitData =
      <Map<String, dynamic>>[].obs;

  // Data yang sudah difilter (yang akan ditampilkan di UI)
  final RxList<Map<String, dynamic>> filteredTaskVisitData =
      <Map<String, dynamic>>[].obs;

  // Query pencarian yang dimasukkan pengguna
  final RxString searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadTaskVisitData();

    // Debounce: filter data setelah pengguna berhenti mengetik selama 300ms.
    // Ini mencegah error "called during build" dan membuat pencarian lebih efisien.
    debounce(
      searchQuery,
      (_) => _filterData(),
      time: const Duration(milliseconds: 300),
    );

    // Ketika data asli (taskVisitData) pertama kali dimuat, langsung filter (tampilkan semua jika searchQuery kosong)
    ever(taskVisitData, (_) => _filterData());
  }

  // Fungsi untuk memuat data dari file JSON
  Future<void> loadTaskVisitData() async {
    try {
      final String response = await rootBundle.loadString(
        'res/dummyData/task/dataa.json',
      );
      final data = jsonDecode(response) as List<dynamic>;
      taskVisitData.assignAll(
        data.cast<Map<String, dynamic>>(),
      ); // Gunakan assignAll
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal memuat data kunjungan tugas: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
      // Jika gagal, pastikan filtered data juga kosong atau tampilkan pesan error
      filteredTaskVisitData.clear();
    }
  }

  // Fungsi internal untuk memfilter data berdasarkan searchQuery saat ini
  void _filterData() {
    final keyword = searchQuery.value.toLowerCase();
    if (keyword.isEmpty) {
      // Jika query kosong, tampilkan semua data
      filteredTaskVisitData.assignAll(taskVisitData);
    } else {
      // Jika ada query, filter data
      filteredTaskVisitData.assignAll(
        taskVisitData.where((item) {
          final cabang = item['cabang']?.toLowerCase() ?? '';
          final pic = item['pic']?.toLowerCase() ?? '';
          final type = item['type']?.toLowerCase() ?? '';
          final activity = item['activity']?.toLowerCase() ?? '';

          return cabang.contains(keyword) ||
              pic.contains(keyword) ||
              type.contains(keyword) ||
              activity.contains(keyword);
        }).toList(),
      );
    }
  }

  // Fungsi publik yang dipanggil dari UI untuk memperbarui query pencarian.
  // Perubahan ini akan memicu `debounce` yang kemudian akan memanggil `_filterData`.
  void updateSearchQuery(String query) {
    searchQuery.value = query;
  }
}
