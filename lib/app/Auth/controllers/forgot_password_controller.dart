import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sufi_one/app/Auth/models/forgot_password_model.dart';

class ForgotPasswordController extends GetxController {
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final isButtonEnabled = true.obs;

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }

    if (!GetUtils.isEmail(value)) {
      return 'Invalid email format';
    }
    return null;
  }

  void resetPassword() {
    if (formKey.currentState!.validate()) {
      final model = ForgotPasswordModel(email: emailController.text);

      print("Email to reset: ${model.toJson()}");

      isButtonEnabled.value = false;

      Future.delayed(Duration(seconds: 3), () {
        isButtonEnabled.value = true;
      });

      Get.back();

      Get.snackbar(
        'Reset Link Sent',
        'A password reset link has been sent to your email address.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  @override
  void onClose() {
    emailController.dispose();
    super.onClose();
  }
}
