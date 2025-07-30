import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sufi_one/app/Auth/views/login_view.dart';
import 'package:sufi_one/src/constants/constants.dart';

class ApiServiceDams {
  final String baseUrl;

  ApiServiceDams({this.baseUrl = Url});
  Future<String> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null || token.isEmpty) {
      Get.offAll(() => LoginPage());
      throw Exception('Token tidak tersedia. Sesi telah berakhir.');
    }
    return token;
  }

  Map<String, String> _getHeaders(String token) {
    return {
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };
  }

  Future<Map<String, dynamic>> _getJson(String endpoint) async {
    final token = await _getToken();
    final response = await http.get(
      Uri.parse(baseUrl + endpoint),
      headers: _getHeaders(token),
    );

    print('[$endpoint] Status: ${response.statusCode}');
    print('[$endpoint] Body: ${response.body}');

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else if (response.statusCode == 401) {
      Get.offAll(() => LoginPage());
      throw Exception('Sesi telah berakhir, silakan login kembali');
    } else {
      throw Exception(
        'Gagal memuat data dari $endpoint: ${response.statusCode}',
      );
    }
  }

  Future<Map<String, dynamic>> fetchStatusAsset() => _getJson('status-asset');
  Future<Map<String, dynamic>> fetchKondisiAsset() => _getJson('kondisi-asset');
  Future<Map<String, dynamic>> fetchStatusUserAsset() =>
      _getJson('status-user-asset');
  Future<Map<String, dynamic>> fetchPosisiUser() => _getJson('posisi-user');
  Future<Map<String, dynamic>> fetchDivisiUser() => _getJson('divisi-user');
  Future<Map<String, dynamic>> fetchLokasiUser() => _getJson('lokasi-user');
  Future<Map<String, dynamic>> fetchLantaiUser() => _getJson('lantai-user');

  Future<DateTime?> fetchLastUpdateTime() async {
    try {
      final token = await _getToken();
      final response = await http.get(
        Uri.parse(baseUrl + 'collection'),
        headers: _getHeaders(token),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data.containsKey('last_update') && data['last_update'] != null) {
          return DateTime.parse(data['last_update']);
        }
        return null;
      } else if (response.statusCode == 401) {
        Get.offAll(() => LoginPage());
        return null;
      }
      return null;
    } catch (e) {
      print('Error fetching last update time: $e');
      return null;
    }
  }
}
