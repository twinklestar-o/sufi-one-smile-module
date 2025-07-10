import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:get_storage/get_storage.dart';
import '../../../models/visit.dart';

class TaskVisitController extends GetxController {
  var taskVisitData = <Visit>[].obs;
  var filteredTaskVisitData = <Visit>[].obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchTaskVisitData();
  }

  // Ambil data dari API Direct Visit Planning
  Future<void> fetchTaskVisitData() async {
    isLoading.value = true;
    final box = GetStorage();
    final token = box.read('token');
    final url = Uri.parse('http://192.168.0.105:8000/api/direct-visit/planning');

    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final List<dynamic> data = json is List ? json : json['data'];

        final List<Visit> visits = data.map((e) => Visit.fromJson(e)).toList();

        taskVisitData.assignAll(visits);
        filteredTaskVisitData.assignAll(visits);
      } else {
        Get.snackbar('Gagal', 'Gagal mengambil data (${response.statusCode})');
      }
    } catch (e) {
      Get.snackbar('Error', 'Terjadi kesalahan: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Search query
  void updateSearchQuery(String query) {
    filteredTaskVisitData.value = taskVisitData.where((visit) {
      return (visit.branchCode ?? '').toLowerCase().contains(query.toLowerCase()) ||
          (visit.namaPic ?? '').toLowerCase().contains(query.toLowerCase()) ||
          (visit.tipeVisit ?? '').toLowerCase().contains(query.toLowerCase()) ||
          (visit.tujuanVisit ?? '').toLowerCase().contains(query.toLowerCase());
    }).toList();
  }

  // Tambah Visit baru
  void addTaskVisit(Visit newVisit) {
    taskVisitData.add(newVisit);
    filteredTaskVisitData.assignAll(taskVisitData);
  }

  // Update Visit
  void updateTaskVisit(Visit updatedVisit) {
    final index = taskVisitData.indexWhere((e) => e.id == updatedVisit.id);
    if (index != -1) {
      taskVisitData[index] = updatedVisit;
      filteredTaskVisitData.assignAll(taskVisitData);
    }
  }
}
