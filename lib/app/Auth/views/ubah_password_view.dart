import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sufi_one/app/modules/public/profile_page/controllers/profile_page_controller.dart';
import 'package:sufi_one/app/modules/public/widgets/appbarWObutton.dart';
import 'package:sufi_one/app/modules/public/widgets/bottomnavbar.dart';
import 'package:sufi_one/app/theme/color_constant.dart';
import 'package:sufi_one/app/theme/fontstyle.dart';

class UbahPasswordView extends StatefulWidget {
  const UbahPasswordView({super.key});

  @override
  State<UbahPasswordView> createState() => _UbahPasswordViewState();
}

class _UbahPasswordViewState extends State<UbahPasswordView> {
  final controller = Get.find<ProfilePageController>();
  final _formKey = GlobalKey<FormState>();
  bool isObscure1 = true;
  bool isObscure2 = true;
  bool isObscure3 = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg1,
      appBar: SuzukiFinanceAppBarWObutton(),
      bottomNavigationBar: const BottomNavbar(selectedIndex: 3),
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Atur Ulang Kata sandi',
                style: AppTextStyles.bigBody.copyWith(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppColors.bg3,
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: controller.currentPasswordController,
                obscureText: isObscure1,
                decoration: InputDecoration(
                  hintText: 'Password Lama',
                  suffixIcon: IconButton(
                    icon: Icon(
                      isObscure1 ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() => isObscure1 = !isObscure1);
                    },
                  ),
                ),
                validator: controller.validateCurrentPassword,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: controller.newPasswordController,
                obscureText: isObscure2,
                decoration: InputDecoration(
                  hintText: 'Password Baru',
                  suffixIcon: IconButton(
                    icon: Icon(
                      isObscure2 ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() => isObscure2 = !isObscure2);
                    },
                  ),
                ),
                validator: controller.validateNewPassword,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: controller.confirmPasswordController,
                obscureText: isObscure3,
                decoration: InputDecoration(
                  hintText: 'Password Konfirmasi',
                  suffixIcon: IconButton(
                    icon: Icon(
                      isObscure3 ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() => isObscure3 = !isObscure3);
                    },
                  ),
                ),
                validator: controller.validateConfirmPassword,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.button,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      controller.changePassword();
                    }
                  },
                  child: Text('Update', style: AppTextStyles.buttonFont),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
