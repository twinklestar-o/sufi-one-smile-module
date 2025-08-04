import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:sufi_one/app/modules/smile/models/visit.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sufi_one/src/constants/constants.dart';

class HistoryVisitController extends GetxController {
  // Data asli dari API
  final RxList<Visit> historyData = <Visit>[].obs;

  // Data yang difilter untuk pencarian
  final RxList<Visit> filteredHistoryData = <Visit>[].obs;

  // Kontroller untuk input pencarian
  final TextEditingController searchController = TextEditingController();

  // Nilai teks pencarian sebagai RxString untuk debounce
  final RxString searchText = ''.obs;

  // Status pemuatan untuk menampilkan indikator loading
  final RxBool isLoading = false.obs;

  // Pesan kesalahan untuk ditampilkan di UI
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadHistoryData();
    // Sinkronisasi pencarian saat data dimuat
    ever(historyData, (_) => filterData(searchText.value));
    // Perbarui searchText saat teks berubah
    searchController.addListener(() {
      searchText.value = searchController.text;
    });
    // Terapkan debounce pada searchText
    debounce(
      searchText,
      (value) => filterData(value),
      time: const Duration(milliseconds: 300),
    );
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  // Fungsi untuk memuat data dari API
  Future<void> loadHistoryData({bool isRefresh = false}) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      Get.snackbar('Error', 'User tidak login');
      return;
    }
    try {
      isLoading.value = true;
      errorMessage.value = '';
      historyData.clear(); // Bersihkan data sebelum memuat ulang

      final response = await http
          .get(
            Uri.parse(Url + 'direct-visit/history'),
            headers: {
              'Authorization': 'Bearer $token',
              'Accept': 'application/json',
            },
          )
          .timeout(
            const Duration(seconds: 15),
            onTimeout: () {
              throw Exception(
                'Permintaan ke API timeout setelah 15 detik. Periksa koneksi jaringan atau server.',
              );
            },
          );

      print(
        'Respons API: Status ${response.statusCode}, Body: ${response.body}',
      ); // Logging respons

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is List<dynamic>) {
          historyData.assignAll(
            data.map((json) => Visit.fromJson(json)).toList(),
          );
          if (historyData.isEmpty) {
            errorMessage.value = 'Data riwayat kunjungan kosong';
            print('Peringatan: Data riwayat kunjungan kosong'); // Logging
          }
        } else {
          throw Exception('Format respons API tidak valid: bukan daftar JSON');
        }
      } else {
        throw Exception(
          'Gagal memuat data: Status ${response.statusCode} - ${response.reasonPhrase}',
        );
      }
    } catch (e, stackTrace) {
      errorMessage.value = 'Gagal memuat data riwayat kunjungan: $e';
      historyData.clear();
      print('Error: $e\nStackTrace: $stackTrace'); // Logging untuk debugging
      Get.snackbar(
        'Error',
        errorMessage.value,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 5),
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Fungsi untuk filter data berdasarkan teks pencarian
  void filterData(String query) {
    if (query.isEmpty) {
      filteredHistoryData.assignAll(historyData);
    } else {
      filteredHistoryData.assignAll(
        historyData.where((visit) {
          final queryLower = query.toLowerCase();
          return (visit.branchCode?.toLowerCase().contains(queryLower) ??
                  false) ||
              (visit.namaPic?.toLowerCase().contains(queryLower) ?? false) ||
              (visit.tipeVisit?.toLowerCase().contains(queryLower) ?? false) ||
              (visit.tujuanVisit?.toLowerCase().contains(queryLower) ?? false);
        }).toList(),
      );
    }
  }

  // Fungsi untuk refresh data dari API
  Future<void> refreshData() async {
    await loadHistoryData(isRefresh: true);
  }
}
