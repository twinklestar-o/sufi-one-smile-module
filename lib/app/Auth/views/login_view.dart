import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sufi_one/app/Auth/controllers/login_controller.dart';
import 'package:sufi_one/app/modules/public/widgets/appbarWObutton.dart';
import 'package:sufi_one/app/modules/public/widgets/buttonStyle.dart';
import 'package:sufi_one/app/theme/fontstyle.dart';

class LoginPage extends GetView<LoginController> {
  final controller = Get.put(LoginController());

  // Use GetView<LoginController>
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SuzukiFinanceAppBarWObutton(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(50, 100, 50, 50),
          child: Form(
            key: controller.loginKey,
            child: Container(
              padding: EdgeInsets.fromLTRB(15, 30, 15, 10),
              height: 400,
              decoration: BoxDecoration(
                border: Border.all(width: 1),
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 350,
                    height: 70,
                    child: TextFormField(
                      controller: controller.emailController,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(),
                      ),
                      validator: controller.validateEmail,
                    ),
                  ),
                  //SizedBox(height: 10),
                  SizedBox(
                    width: 350,
                    height: 70,
                    child: TextFormField(
                      controller: controller.passwordController,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        border: OutlineInputBorder(),
                      ),
                      obscureText: true,
                      validator: controller.validatePassword,
                    ),
                  ),
                  Expanded(child: SizedBox(height: 20)),
                  FractionallySizedBox(
                    widthFactor: 1,
                    child: ElevatedButton(
                      style: AppButtonStyle.primaryButtonStyle(),
                      onPressed: () {
                        controller.login();
                      },
                      child: Text("Login", style: AppTextStyles.buttonFont),
                    ),
                  ),
                  Align(
                    alignment: Alignment.topLeft,
                    child: SizedBox(
                      height: 30,
                      child: TextButton(
                        onPressed: () {
                          Get.toNamed('public/forgot_password');
                        },
                        child: Text(
                          'Forget Password?',
                          style: AppTextStyles.smallBody,
                        ),
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.topLeft,
                    child: SizedBox(
                      height: 30,
                      child: TextButton(
                        onPressed: () {
                          Get.toNamed('/public/register');
                        },
                        child: RichText(
                          text: TextSpan(
                            children: <TextSpan>[
                              TextSpan(
                                text: 'Belum punya akun? ',
                                style: AppTextStyles.smallBody,
                              ),
                              TextSpan(
                                text: 'Daftar sekarang',
                                style: AppTextStyles.smallBodyBold,
                              ),
                            ],
                          ),
                        ),
                      ),
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
}
