import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:sufi_one/app/modules/smile/constants/constants.dart';

class AuthController {
  Future<void> login(String email, String password) async {
    final response = await http.post(
      Uri.parse(Url + 'login'),
      body: {'email': email, 'password': password},
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final token = json['token'];

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', token);
    } else {
      throw Exception('Login gagal');
    }
  }
}
