import 'dart:io';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/stockOpname.dart';
import '../../../../src/constants/constants.dart';

class HistoryController extends GetxController {
  var isLoading = true.obs;
  var historyList = <HistoryStockOpname>[].obs;
  var errorMessage = ''.obs;
  String? selectedId;

  Future<void> fetchHistoryStock() async {
    try {
      isLoading(true);
      errorMessage('');

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null || token.isEmpty) {
        throw Exception('Token tidak tersedia, silakan login kembali');
      }

      final response = await http.get(
        Uri.parse(Url + 'asset-branches'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> body = json.decode(response.body);
        historyList.assignAll(
          body.map((e) => HistoryStockOpname.fromJson(e)).toList(),
        );
      } else {
        throw Exception('Gagal memuat data: ${response.statusCode}');
      }
    } catch (e) {
      errorMessage(e.toString());
      rethrow;
    } finally {
      isLoading(false);
    }
  }

  Future<Map<String, dynamic>> getStockDetail(String id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null || token.isEmpty) {
        throw Exception('Token tidak tersedia');
      }

      final response = await http.get(
        Uri.parse('${Url}asset-branches/$id'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final body = json.decode(response.body);
        if (body['success'] == true && body['data'] != null) {
          return body;
        } else {
          throw Exception(body['message'] ?? 'Data tidak ditemukan');
        }
      } else {
        throw Exception('HTTP ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching detail: $e');
      return {}; // Jangan return null
    }
  }

  // Method to update data
  Future<bool> updateStockOpname({
    required String id,
    required Map<String, String> data,
    File? imageFile,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) throw Exception('Token not available');

      final uri = Uri.parse('${Url}asset-branches/update/$id');

      final request =
          http.MultipartRequest('POST', uri)
            ..headers.addAll({
              'Authorization': 'Bearer $token',
              'Accept': 'application/json',
            })
            ..fields['_method'] = 'PUT';

      // Filter dan tambahkan hanya field yang tidak kosong
      data.forEach((key, value) {
        if (value.trim().isNotEmpty) {
          request.fields[key] = value;
        }
      });

      // Tambahkan file jika ada
      if (imageFile != null && await imageFile.exists()) {
        final fileStream = await http.MultipartFile.fromPath(
          'IMG',
          imageFile.path,
        );
        request.files.add(fileStream);
      }

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      print('STATUS: ${response.statusCode}');
      print('RESPONSE BODY: $responseBody');

      if (response.statusCode == 200) {
        return true;
      } else {
        final error = json.decode(responseBody);
        throw Exception(error['message'] ?? 'Update failed');
      }
    } catch (e) {
      throw Exception('Error updating: ${e.toString()}');
    }
  }

  @override
  void onInit() {
    super.onInit();
    fetchHistoryStock();
  }
}
