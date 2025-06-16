import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/services.dart' show rootBundle;

class HistoryVisitController extends GetxController {
  RxList<Map<String, dynamic>> historyData = RxList<Map<String, dynamic>>([]);

  @override
  void onInit() {
    super.onInit();
    loadHistoryData();
  }

  Future<void> loadHistoryData() async {
    try {
      final String response = await rootBundle.loadString('res/dummyData/history/data.json');
      final data = jsonDecode(response) as List<dynamic>;
      historyData.value = data.cast<Map<String, dynamic>>();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load history data: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}



