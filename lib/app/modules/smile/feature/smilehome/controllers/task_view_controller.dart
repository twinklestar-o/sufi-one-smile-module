import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/services.dart' show rootBundle;

class TaskViewController extends GetxController {
  RxList<Map<String, dynamic>> taskData = RxList<Map<String, dynamic>>([]);

  @override
  void onInit() {
    super.onInit();
    loadTaskData();
  }

  Future<void> loadTaskData() async {
    try {
      // Memuat file JSON yang berisi data untuk task view
      final String response = await rootBundle.loadString('res/dummyData/task/dataa.json');
      final data = jsonDecode(response) as List<dynamic>;
      taskData.value = data.cast<Map<String, dynamic>>();
    } catch (e) {
      // Menampilkan pesan error jika gagal memuat data
      Get.snackbar(
        'Error',
        'Failed to load task data: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  @override
  void onClose() {
    super.onClose();
  }
}
