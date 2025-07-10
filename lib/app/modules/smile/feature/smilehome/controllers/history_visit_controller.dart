import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class HistoryVisitController extends GetxController {
  RxList<Map<String, dynamic>> historyData = RxList<Map<String, dynamic>>([]);

  @override
  void onInit() {
    super.onInit();
    loadInitialHistoryData();
  }

  Future<void> loadInitialHistoryData() async {
    try {
      final String response = await rootBundle.loadString('res/dummyData/history/data.json');
      final data = jsonDecode(response) as List<dynamic>;
      historyData.value = data.cast<Map<String, dynamic>>();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load initial history data: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> reloadHistoryDataFromLocal() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/data.json');
      if (await file.exists()) {
        final String response = await file.readAsString();
        final data = jsonDecode(response) as List<dynamic>;
        historyData.value = data.cast<Map<String, dynamic>>();
        Get.snackbar(
          'Success',
          'Data reloaded from local storage',
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        Get.snackbar(
          'Info',
          'No local data found, using initial data',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to reload history data: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  @override
  void onClose() {
    super.onClose();
  }
}