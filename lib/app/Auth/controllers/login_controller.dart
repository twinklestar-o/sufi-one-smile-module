import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sufi_one/src/constants/constants.dart';

class LoginController extends GetxController {
  final _loginKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  GlobalKey<FormState> get loginKey => _loginKey;

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email';
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your password';
    }
    return null;
  }

  void login() async {
    if (_loginKey.currentState!.validate()) {
      final email = emailController.text.trim();
      final password = passwordController.text;

      final url = Uri.parse(Url + 'login');

      try {
        final response = await http.post(
          url,
          headers: {'Accept': 'application/json'},
          body: {'email': email, 'password': password},
        );

        final data = jsonDecode(response.body);

        if (response.statusCode == 200 && data['status'] == true) {
          final token = data['token'];

          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('token', token);
          await prefs.setBool('isLoggedIn', true);

          Get.snackbar(
            'Success',
            'Login successful',
            snackPosition: SnackPosition.BOTTOM,
          );
          Get.offNamed('/public/home');
        } else {
          Get.snackbar(
            'Error',
            data['message'] ?? 'Login failed',
            snackPosition: SnackPosition.BOTTOM,
          );
        }
      } catch (e) {
        Get.snackbar(
          'Error',
          'Something went wrong: $e',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    }
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
