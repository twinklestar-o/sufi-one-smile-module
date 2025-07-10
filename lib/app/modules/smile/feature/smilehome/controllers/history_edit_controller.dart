import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class HistoryEditController extends GetxController {
  RxMap<String, dynamic> editedData = RxMap<String, dynamic>({});
  final formKey = GlobalKey<FormState>();

  @override
  void onInit() {
    super.onInit();
    editedData.value = Get.arguments ?? {};
  }

  Future<void> saveEditedData() async {
    if (formKey.currentState?.validate() ?? false) {
      try {
        final directory = await getApplicationDocumentsDirectory();
        final file = File('${directory.path}/data.json');
        final existingData = await _loadLocalData();
        existingData[Get.arguments?['cabang'] ?? editedData['cabang']] = editedData.value;
        await file.writeAsString(jsonEncode(existingData.values.toList()), flush: true);
        Get.snackbar(
          'Success',
          'Data saved successfully',
          snackPosition: SnackPosition.BOTTOM,
        );
        // Navigasi langsung ke HistoryVisit
        Get.offNamed('/public/smile/history_visit');
      } catch (e) {
        Get.snackbar(
          'Error',
          'Failed to save data: $e',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    }
  }

  Future<Map<String, Map<String, dynamic>>> _loadLocalData() async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/data.json');
    if (await file.exists()) {
      final String response = await file.readAsString();
      final data = jsonDecode(response) as List<dynamic>;
      return {for (var item in data) item['cabang']: item.cast<String, dynamic>()};
    }
    return {};
  }

  @override
  void onClose() {
    super.onClose();
  }
}