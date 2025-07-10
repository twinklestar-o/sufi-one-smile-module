import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sufi_one/app/modules/public/home_routes.dart';
import 'package:sufi_one/app/theme/color_constant.dart';

class BottomNavbar extends StatelessWidget {
  final int selectedIndex;

  const BottomNavbar({super.key, required this.selectedIndex});

  void _onItemTapped(int index) {
    if (index == selectedIndex) return;

    switch (index) {
      case 0:
        Get.offAllNamed(HomeRoutes.homepage);
        break;
      case 1:
        Get.offAllNamed(HomeRoutes.about);
        break;
      case 2:
        Get.offAllNamed(HomeRoutes.contact);
        break;
      case 3:
        Get.offAllNamed(HomeRoutes.profilePage);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ConvexAppBar(
      style: TabStyle.reactCircle,
      height: 50, // Tinggi bottom bar (default 50)
      curveSize: 100, // Ukuran lengkungan bubble (default 80)
      backgroundColor: AppColors.splashStart,
      activeColor: AppColors.bg1,
      color: AppColors.bg2,
      elevation: 10,
      items: const [
        TabItem(icon: Icons.home, title: 'Home'),
        TabItem(icon: Icons.perm_device_information, title: 'About'),
        TabItem(icon: Icons.contact_support, title: 'Support'),
        TabItem(icon: Icons.person, title: 'Profile'),
      ],
      initialActiveIndex: selectedIndex,
      onTap: _onItemTapped,
    );
  }
}
