import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'package:sufi_one/app/Auth/views/login_view.dart';
import 'package:sufi_one/app/modules/smile/constants/constants.dart';
import '../../app/modules/smile/models/jabatan.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  final String baseUrl;

  ApiService({this.baseUrl = Url});

  Future<String> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null || token.isEmpty) {
      Get.offAll(() => LoginPage());
      throw Exception('Token tidak tersedia');
    }
    return token;
  }

  Future<Map<String, dynamic>> fetchJabatan() async {
    final token = await _getToken();
    final response = await http.get(
      Uri.parse(Url + 'jabatan'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else if (response.statusCode == 401) {
      // Token expired, redirect to login
      Get.offAll(() => LoginPage());
      throw Exception('Sesi telah berakhir, silakan login kembali');
    } else {
      throw Exception('Gagal memuat data jabatan');
    }
  }

  Future<DateTime?> fetchLastUpdateTime() async {
    try {
      final token = await _getToken();
      final response = await http.get(
        Uri.parse(Url + 'collection'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return DateTime.parse(data['last_update']);
      } else if (response.statusCode == 401) {
        Get.offAll(() => LoginPage());
        return null;
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
