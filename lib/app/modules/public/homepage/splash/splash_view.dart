import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sufi_one/app/modules/public/home_routes.dart';
import 'package:sufi_one/app/theme/color_constant.dart';
import 'dart:async';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  _SplashPageState createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    Timer(Duration(seconds: 2), () {
      Get.offNamed(HomeRoutes.homepage);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.splashStart, AppColors.splashEnd],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(child: SizedBox()),
              FractionallySizedBox(
                child: Image.asset('res/images/splashscreen.png'),
                widthFactor: 0.8,
              ),
              SizedBox(height: 50),
              CircularProgressIndicator(color: Colors.white),
              Expanded(child: SizedBox()),
              FractionallySizedBox(
                child: Image.asset('res/images/ojk1.png'),
                widthFactor: 0.6,
              ),
              SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
