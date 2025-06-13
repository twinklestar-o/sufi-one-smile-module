import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:sufi_one/app/Auth/controllers/register_controller.dart';
import 'package:sufi_one/app/modules/public/widgets/appbarWObutton.dart';
import 'package:sufi_one/app/modules/public/widgets/buttonStyle.dart';
import 'package:sufi_one/app/theme/fontstyle.dart';

class RegisterPage extends StatelessWidget {
  final controller = Get.put(RegisterController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SuzukiFinanceAppBarWObutton(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(50.0),
          child: Form(
            key: controller.registKey,
            child: Container(
              padding: EdgeInsets.all(15),
              decoration: BoxDecoration(
                border: Border.all(width: 1),
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  _buildTextField(
                    controller.nameController,
                    'Nama Lengkap',
                    controller.validateFullName,
                  ),
                  _buildTextField(
                    controller.emailController,
                    'Email',
                    controller.validateEmail,
                    TextInputType.emailAddress,
                  ),
                  _buildTextField(
                    controller.telpNumberController,
                    'Nomor Telepon',
                    controller.validateTelpNumber,
                    TextInputType.phone,
                    [
                      FilteringTextInputFormatter.allow(RegExp(r'[+0-9]')),
                      LengthLimitingTextInputFormatter(15),
                    ],
                  ),
                  _buildTextField(
                    controller.passwordController,
                    'Password',
                    controller.validatePassword,
                    TextInputType.text,
                    [],
                    true,
                  ),
                  _buildTextField(
                    controller.confirmPasswordController,
                    'Konfirmasi Password',
                    controller.validateConfirmPassword,
                    TextInputType.text,
                    [],
                    true,
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Obx(
                        () => Checkbox(
                          value: controller.isChecked.value,
                          onChanged: (val) => controller.toggleChecked(val),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          "I agree to the terms and conditions",
                          style: AppTextStyles.smallBody,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Obx(
                    () => ElevatedButton(
                      style: AppButtonStyle.primaryButtonStyle(),
                      onPressed:
                          controller.isChecked.value
                              ? controller.register
                              : null,
                      child: Text('Register', style: AppTextStyles.buttonFont),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    String? Function(String?) validator, [
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    bool obscure = false,
  ]) {
    return SizedBox(
      height: 70,
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
        keyboardType: keyboardType,
        obscureText: obscure,
        inputFormatters: inputFormatters,
        validator: validator,
      ),
    );
  }
}
