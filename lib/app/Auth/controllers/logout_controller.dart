import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sufi_one/app/Auth/views/login_view.dart';
import 'package:sufi_one/src/constants/constants.dart';
import 'package:sufi_one/app/modules/smile/smile_route.dart';

class LogoutController extends GetxController {
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
