import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'package:sufi_one/app/Auth/views/login_view.dart';
import 'package:sufi_one/src/constants/constants.dart';

import 'package:shared_preferences/shared_preferences.dart';

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

  // Enhanced headers for better API compatibility
  Map<String, String> _getHeaders(String token) {
    return {
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };
  }

  // Type endpoint - returns Map with 'data' key
  Future<Map<String, dynamic>> fetchStatusAsset() async {
    final token = await _getToken();
    final response = await http.get(
      Uri.parse(Url + 'status-asset'),
      headers: _getHeaders(token),
    );

    print('Type API Response Status: ${response.statusCode}');
    print('Type API Response Body: ${response.body}');

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else if (response.statusCode == 401) {
      Get.offAll(() => LoginPage());
      throw Exception('Sesi telah berakhir, silakan login kembali');
    } else {
      throw Exception('Gagal memuat data Type: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> fetchKondisiAsset() async {
    final token = await _getToken();
    final response = await http.get(
      Uri.parse(Url + 'kondisi-asset'),
      headers: _getHeaders(token),
    );

    print('Type API Response Status: ${response.statusCode}');
    print('Type API Response Body: ${response.body}');

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else if (response.statusCode == 401) {
      Get.offAll(() => LoginPage());
      throw Exception('Sesi telah berakhir, silakan login kembali');
    } else {
      throw Exception('Gagal memuat data Type: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> fetchStatusUserAsset() async {
    final token = await _getToken();
    final response = await http.get(
      Uri.parse(Url + 'status-user-asset'),
      headers: _getHeaders(token),
    );

    print('Type API Response Status: ${response.statusCode}');
    print('Type API Response Body: ${response.body}');

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else if (response.statusCode == 401) {
      Get.offAll(() => LoginPage());
      throw Exception('Sesi telah berakhir, silakan login kembali');
    } else {
      throw Exception('Gagal memuat data Type: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> fetchPosisiUser() async {
    final token = await _getToken();
    final response = await http.get(
      Uri.parse(Url + 'posisi-user'),
      headers: _getHeaders(token),
    );

    print('Type API Response Status: ${response.statusCode}');
    print('Type API Response Body: ${response.body}');

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else if (response.statusCode == 401) {
      Get.offAll(() => LoginPage());
      throw Exception('Sesi telah berakhir, silakan login kembali');
    } else {
      throw Exception('Gagal memuat data Type: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> fetchDivisiUser() async {
    final token = await _getToken();
    final response = await http.get(
      Uri.parse(Url + 'divisi-user'),
      headers: _getHeaders(token),
    );

    print('Type API Response Status: ${response.statusCode}');
    print('Type API Response Body: ${response.body}');

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else if (response.statusCode == 401) {
      Get.offAll(() => LoginPage());
      throw Exception('Sesi telah berakhir, silakan login kembali');
    } else {
      throw Exception('Gagal memuat data Type: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> fetchLokasiUser() async {
    final token = await _getToken();
    final response = await http.get(
      Uri.parse(Url + 'lokasi-user'),
      headers: _getHeaders(token),
    );

    print('Type API Response Status: ${response.statusCode}');
    print('Type API Response Body: ${response.body}');

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else if (response.statusCode == 401) {
      Get.offAll(() => LoginPage());
      throw Exception('Sesi telah berakhir, silakan login kembali');
    } else {
      throw Exception('Gagal memuat data Type: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> fetchLantaiUser() async {
    final token = await _getToken();
    final response = await http.get(
      Uri.parse(Url + 'lantai-user'),
      headers: _getHeaders(token),
    );

    print('Type API Response Status: ${response.statusCode}');
    print('Type API Response Body: ${response.body}');

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else if (response.statusCode == 401) {
      Get.offAll(() => LoginPage());
      throw Exception('Sesi telah berakhir, silakan login kembali');
    } else {
      throw Exception('Gagal memuat data Type: ${response.statusCode}');
    }
  }

  // Last update time for collection sync
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
