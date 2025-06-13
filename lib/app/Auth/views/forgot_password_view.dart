import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sufi_one/app/Auth/controllers/forgot_password_controller.dart';
import 'package:sufi_one/app/modules/public/widgets/appbarWObutton.dart';
import 'package:sufi_one/app/modules/public/widgets/buttonStyle.dart';
import 'package:sufi_one/app/theme/fontstyle.dart';

class ForgotPasswordPage extends GetView<ForgotPasswordController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SuzukiFinanceAppBarWObutton(),
      body: Padding(
        padding: const EdgeInsets.all(35),
        child: Center(
          child: Form(
            key: controller.formKey,
            child: Container(
              padding: const EdgeInsets.all(25),
              height: 500,
              decoration: BoxDecoration(
                border: Border.all(width: 1),
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  SizedBox(height: 20),
                  Text(
                    'Enter your email address to receive a password reset link.',
                    style: AppTextStyles.bigBody,
                    textAlign: TextAlign.center,
                  ),
                  Expanded(child: SizedBox()),
                  TextFormField(
                    controller: controller.emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                    ),
                    validator: controller.validateEmail,
                  ),
                  SizedBox(height: 20),
                  Obx(
                    () => ElevatedButton(
                      style: AppButtonStyle.primaryButtonStyle(),
                      onPressed:
                          controller.isButtonEnabled.value
                              ? () {
                                controller.resetPassword();
                              }
                              : null, // disable kalo lago load
                      child:
                          controller.isButtonEnabled.value
                              ? Text(
                                'Reset Password',
                                style: AppTextStyles.buttonFont,
                              )
                              : CircularProgressIndicator(),
                    ),
                  ),
                  Expanded(child: SizedBox()),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
