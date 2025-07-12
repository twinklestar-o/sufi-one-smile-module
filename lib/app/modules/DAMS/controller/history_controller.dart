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

  @override
  void onInit() {
    super.onInit();
    fetchHistoryStock();
  }
}
