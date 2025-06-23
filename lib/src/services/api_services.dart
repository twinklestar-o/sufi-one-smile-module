import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'package:sufi_one/app/Auth/views/login_view.dart';
import 'package:sufi_one/app/modules/smile/constants/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../app/modules/smile/models/type.dart';

class ApiService {
  final String baseUrl;

  ApiService({this.baseUrl = Url});

  Future<Map<String, dynamic>> fetchPurpose() async {
    final token = await _getToken();
    final response = await http.get(
      Uri.parse(Url + 'purpose'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else if (response.statusCode == 401) {
      // Token expired, redirect to login
      Get.offAll(() => LoginPage());
      throw Exception('Sesi telah berakhir, silakan login kembali');
    } else {
      throw Exception('Gagal memuat data purpose');
    }
  }

  Future<String> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null || token.isEmpty) {
      Get.offAll(() => LoginPage());
      throw Exception('Token tidak tersedia. Sesi telah berakhir.');
    }
    return token;
  }

  Future<Map<String, dynamic>> fetchType() async {
    final token = await _getToken();
    final response = await http.get(
      Uri.parse(Url + 'type'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else if (response.statusCode == 401) {
      // Token expired, redirect to login
      Get.offAll(() => LoginPage());
      throw Exception('Sesi telah berakhir, silakan login kembali');
    } else {
      throw Exception('Gagal memuat data Type: ${response.statusCode}');
    }
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

  Future<Map<String, dynamic>> fetchArea() async {
    final token = await _getToken();
    final response = await http.get(
      Uri.parse(Url + 'area'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else if (response.statusCode == 401) {
      // Token expired, redirect to login
      Get.offAll(() => LoginPage());
      throw Exception('Sesi telah berakhir, silakan login kembali');
    } else {
      throw Exception('Gagal memuat data area');
    }
  }

  Future<DateTime?> fetchLastUpdateTime() async {
    try {
      final token = await _getToken();
      final response = await http.get(
        Uri.parse(baseUrl + 'collection'),
        headers: {'Authorization': 'Bearer $token'},
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
