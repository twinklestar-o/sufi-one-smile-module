import 'dart:convert';
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:sufi_one/src/constants/constants.dart';
import 'package:sufi_one/app/modules/smile/constants/constants.dart';
import 'package:sufi_one/app/modules/smile/smile_route.dart';

class AuthController extends GetxController {
  var isLoggedIn = false.obs;

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
      isLoggedIn.value = true;
    } else {
      throw Exception('Login gagal');
    }
  }

  Future<void> checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    isLoggedIn.value = token != null && token.isNotEmpty;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      Get.snackbar('Error', 'User tidak login');
      return;
    }

    try {
      final response = await http.get(
        Uri.parse(Url + 'logout'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        await prefs.remove('token');
        isLoggedIn.value = false;
        Get.offAllNamed(SmileRoutes.login);
      } else {
        final data = jsonDecode(response.body);
        Get.snackbar('Logout gagal', data['message'] ?? 'Terjadi kesalahan');
      }
    } catch (e) {
      Get.snackbar('Error', 'Gagal logout: $e');
    }
  }
}
