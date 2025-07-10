import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sufi_one/app/Auth/models/register_model.dart';
import 'package:sufi_one/src/constants/constants.dart';

class RegisterController extends GetxController {
  final GlobalKey<FormState> _registKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final telpNumberController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final isChecked = false.obs;

  GlobalKey<FormState> get registKey => _registKey;

  RegisterModel get registerData {
    return RegisterModel(
      name: nameController.text,
      email: emailController.text,
      no_telp: telpNumberController.text,
      password: passwordController.text,
    );
  }

  void toggleChecked(bool? value) {
    if (value != null) {
      isChecked.value = value;
    }
  }

  Future<void> register() async {
    if (_registKey.currentState!.validate()) {
      if (!isChecked.value) {
        Get.snackbar(
          'Error',
          'Harap setujui terms and conditions',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      final data = registerData;
      final url = Uri.parse(Url + 'register');
      try {
        final response = await http.post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(data.toJson()),
        );

        final responseData = jsonDecode(response.body);

        if (response.statusCode == 200 || response.statusCode == 201) {
          final token = responseData['token'];
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('token', token);

          Get.snackbar(
            'Success',
            'Registrasi Berhasil!',
            snackPosition: SnackPosition.BOTTOM,
          );
          Get.offAllNamed('/public/login');
          clearForm();
        } else {
          Get.snackbar(
            'Error',
            responseData['message'] ?? 'Registrasi gagal',
            snackPosition: SnackPosition.BOTTOM,
          );
        }
      } catch (e) {
        Get.snackbar(
          'Error',
          'Terjadi kesalahan koneksi',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } else {
      Get.snackbar(
        'Error',
        'Form tidak valid',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void clearForm() {
    nameController.clear();
    emailController.clear();
    telpNumberController.clear();
    passwordController.clear();
    confirmPasswordController.clear();
    isChecked.value = false;
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    telpNumberController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }

  // Validators
  String? validateFullName(String? value) {
    if (value == null || value.isEmpty) return 'Nama Lengkap harus diisi';
    return null;
  }

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'Email harus diisi';
    final regex = RegExp(r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$');
    if (!regex.hasMatch(value)) return 'Email tidak valid';
    return null;
  }

  String? validateTelpNumber(String? value) {
    if (value == null || value.isEmpty) return 'Nomor Telepon harus diisi';
    if (!RegExp(r'^[+0-9]+$').hasMatch(value))
      return 'Nomor Telepon tidak valid';
    if (value.length < 10) return 'Nomor Telepon minimal 10 angka';
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Password harus diisi';
    if (value.length < 8) return 'Password minimal 8 karakter';
    return null;
  }

  String? validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty)
      return 'Konfirmasi Password harus diisi';
    if (value != passwordController.text) return 'Password berbeda';
    return null;
  }
}
