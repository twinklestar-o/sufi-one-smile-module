import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sufi_one/app/Auth/views/login_view.dart';
import 'package:sufi_one/app/modules/public/home_routes.dart';
import 'package:sufi_one/app/modules/public/profile_page/models/user_profile_model.dart';
import 'package:sufi_one/src/constants/constants.dart';
import 'package:sufi_one/app/modules/smile/models/user.dart';

class ProfilePageController extends GetxController {
  final user = Rx<UserProfile?>(null);
  RxString gender = ''.obs;
  RxString job = ''.obs;
  RxBool isPasswordVisible = false.obs;
  RxBool isPasswordChange = false.obs;

  final profileFormKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  final addressController = TextEditingController();
  final birthDateController = TextEditingController();
  final ktpController = TextEditingController();
  final kontrak1Controller = TextEditingController();
  final kontrak2Controller = TextEditingController();
  final kontrak3Controller = TextEditingController();

  final currentPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  // Add loading state for password change
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadUserFromJsonAsset();
  }

  @override
  void onClose() {
    nameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    addressController.dispose();
    birthDateController.dispose();
    ktpController.dispose();
    kontrak1Controller.dispose();
    kontrak2Controller.dispose();
    kontrak3Controller.dispose();
    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }

  void loadUserFromJsonAsset() async {
    final profile = await loadUserProfileFromJsonAsset();
    user.value = profile;

    nameController.text = profile.name;
    phoneController.text = profile.phone;
    emailController.text = profile.email;
    addressController.text = profile.address;

    birthDateController.clear();
    gender.value = '';
    job.value = '';
    ktpController.clear();
    kontrak1Controller.clear();
    kontrak2Controller.clear();
    kontrak3Controller.clear();
  }

  // ---------------------- UI Actions -----------------------
  void togglePasswordVisibility() {
    isPasswordVisible.toggle();
  }

  void togglePasswordChange() {
    isPasswordChange.toggle();
  }

  String? validateName(String? value) =>
      (value == null || value.isEmpty) ? 'Please enter your name' : null;

  String? validatePhone(String? value) =>
      (value == null || value.isEmpty)
          ? 'Please enter your phone number'
          : null;

  String? validateEmail(String? value) =>
      (value == null || value.isEmpty) ? 'Please enter your email' : null;

  String? validateAddress(String? value) =>
      (value == null || value.isEmpty) ? 'Please enter your address' : null;

  String? validateCurrentPassword(String? value) =>
      (value == null || value.isEmpty)
          ? 'Please enter your current password'
          : null;

  String? validateNewPassword(String? value) {
    if (value == null || value.isEmpty) return 'Please enter your new password';
    if (value.length < 8) return 'Password must be at least 8 characters';
    if (value == currentPasswordController.text) {
      return 'New password must be different from current password';
    }
    return null;
  }

  String? validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty)
      return 'Please confirm your new password';
    if (value != newPasswordController.text) return 'Passwords do not match';
    return null;
  }

  String? validateOptionalContract(String? value) {
    if (value != null &&
        value.isNotEmpty &&
        !RegExp(r'^[0-9]+$').hasMatch(value)) {
      return 'Nomor kontrak harus berupa angka';
    }
    return null;
  }

  void saveProfile() {
    if (profileFormKey.currentState?.validate() ?? false) {
      if (isPasswordChange.value) {
        changePassword();
      }
      updateProfileInfo();
    }
  }

  void updateProfileInfo() {
    user.update((u) {
      if (u != null) {
        u.name = nameController.text;
        u.phone = phoneController.text;
        u.email = emailController.text;
        u.address = addressController.text;
      }
    });

    Get.snackbar(
      'Success',
      'Profile updated successfully',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  Future<void> changePassword() async {
    if (newPasswordController.text != confirmPasswordController.text) {
      Get.snackbar(
        'Error',
        'New password and confirmation do not match',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (currentPasswordController.text == newPasswordController.text) {
      Get.snackbar(
        'Error',
        'New password must be different from current password',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      isLoading.value = true;

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null || token.isEmpty) {
        Get.offAll(() => LoginPage());
        return;
      }

      final response = await http.post(
        Uri.parse(Url + 'change-password'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'passwordLama': currentPasswordController.text,
          'passwordBaru': newPasswordController.text,
          'passwordBaru_confirmation': confirmPasswordController.text,
        }),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        // Update token baru jika ada
        if (responseData['token'] != null) {
          await prefs.setString('token', responseData['token']);
        }

        Get.snackbar(
          'Sukses',
          'Password berhasil diubah',
          snackPosition: SnackPosition.TOP,
        );

        // Clear fields
        currentPasswordController.clear();
        newPasswordController.clear();
        confirmPasswordController.clear();

        // Tidak perlu navigasi, biarkan user tetap di halaman
      } else {
        final errorMessage =
            responseData['message'] ??
            'Gagal mengubah password. Status code: ${response.statusCode}';
        throw Exception(errorMessage);
      }
    } catch (e) {
      String errorMessage = 'Terjadi kesalahan';

      if (e is SocketException) {
        errorMessage = 'Tidak ada koneksi internet';
      } else if (e.toString().contains('401')) {
        errorMessage = 'Sesi telah berakhir, silakan login kembali';
        Get.offAll(() => LoginPage());
      } else {
        errorMessage = e.toString().replaceAll('Exception: ', '');
      }

      Get.snackbar('Error', errorMessage, snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }
}
