import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sufi_one/app/modules/public/widgets/appbarWsidebar.dart';
import 'package:sufi_one/app/modules/public/widgets/appbarWOsidebar.dart';
import 'package:sufi_one/app/modules/public/widgets/sidebar.dart';
import 'package:sufi_one/app/modules/public/homepage/controllers/homepage_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sufi_one/app/theme/color_constant.dart';

class PromoView extends StatefulWidget {
  const PromoView({Key? key}) : super(key: key);

  @override
  State<PromoView> createState() => _PromoViewState();
}

class _PromoViewState extends State<PromoView> {
  final controller = Get.find<HomepageController>();

  bool isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    checkLoginStatus();
  }

  Future<void> checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    setState(() {
      isLoggedIn = token != null && token.isNotEmpty;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<String> promoImages = [
      'res/images/suzuki_iklan1.jpg',
      'res/images/suzuki_iklan2.jpg',
      'res/images/suzuki_iklan3.jpg',
      'res/images/suzuki_iklan4.jpg',
      'res/images/suzuki_iklan3.jpg',
      'res/images/suzuki_iklan2.jpg',
      'res/images/suzuki_ikl an1.jpg',
    ];

    return Scaffold(
      backgroundColor: AppColors.bg1,
      appBar: isLoggedIn
          ? SuzukiFinanceAppBarWsidebar()
          : SuzukiFinanceAppBarWOsidebar(),
      drawer: isLoggedIn ? const Drawer(child: AppSidebar()) : null,
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: promoImages.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: GestureDetector(
              onTap: controller.openPromoWebsite,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(promoImages[index]),
              ),
            ),
          );
        },
      ),
    );
  }
}
