import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sufi_one/app/modules/smile/constants/constants.dart';
import '../models/user.dart';

class ProfileController {
  Future<User> fetchUser() async {
    // Ambil token dari SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null || token.isEmpty) {
      throw Exception('Token tidak ditemukan. Silakan login kembali.');
    }

    // Lakukan request ke endpoint profile dengan token
    final response = await http.get(
      Uri.parse(Url + 'profile'),
      headers: {
        HttpHeaders.authorizationHeader: 'Bearer $token',
        HttpHeaders.acceptHeader: 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final responseJson = jsonDecode(response.body) as Map<String, dynamic>;
      return User.fromJson(responseJson);
    } else {
      throw Exception(
        'Gagal mengambil data profil. Status code: ${response.statusCode}',
      );
    }
  }
}
