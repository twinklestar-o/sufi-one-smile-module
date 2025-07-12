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
        Uri.parse('${Url}asset-branches'),
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

      final response = await http.get(
        Uri.parse('${Url}asset-branches/$id'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load detail: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error: ${e.toString()}');
    }
  }

  // Method to update data
  Future<bool> updateStockOpname({
    required String id,
    required Map<String, dynamic> data,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) throw Exception('Token not available');

      final response = await http.put(
        Uri.parse('${Url}asset-branches/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        final error = json.decode(response.body);
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
