import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:sufi_one/app/modules/public/about/controllers/about_controller.dart';
import 'package:sufi_one/app/modules/public/widgets/appbarWsidebar.dart';
import 'package:sufi_one/app/modules/public/widgets/appbarWOsidebar.dart';
import 'package:sufi_one/app/modules/public/widgets/bottomnavbar.dart';
import 'package:sufi_one/app/modules/public/widgets/sidebar.dart';
import 'package:sufi_one/app/theme/color_constant.dart';
import 'package:sufi_one/app/modules/smile/controllers/AuthController.dart';

class AboutView extends StatefulWidget {
  const AboutView({super.key});

  @override
  State<AboutView> createState() => _AboutViewState();
}

class _AboutViewState extends State<AboutView> {
  final AboutController controller = Get.find<AboutController>();
  final AuthController authController = Get.find<AuthController>();
  String? strVersion;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    initData();
  }

  Future<void> initData() async {
    await getPackageInfo();
    await authController.checkLoginStatus(); // ✅ Sync login status
    setState(() {
      isLoading = false;
    });
  }

  Future<void> getPackageInfo() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    strVersion = packageInfo.version;
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Obx(() => Scaffold(
      backgroundColor: AppColors.bg1,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: authController.isLoggedIn.value
            ? SuzukiFinanceAppBarWsidebar()
            : SuzukiFinanceAppBarWOsidebar(),
      ),
      drawer: authController.isLoggedIn.value
          ? const Drawer(child: AppSidebar())
          : null,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Image.asset('res/images/sufismart.png', height: 100, width: 100),
            const SizedBox(height: 10),
            const Text(
              'Sufi-One',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            Text(
              'Versi: ${strVersion ?? "-"}',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 20),

            // Sosial Media
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: controller.socialMediaItems
                  .map((item) => GestureDetector(
                onTap: () => controller.launchUrlExternal(item.url),
                child: Icon(item.icon, color: item.color, size: 30),
              ))
                  .toList(),
            ),
            const SizedBox(height: 30),

            // Kontak Info
            ...controller.contactInfos.map((item) =>
                _infoTile(item.title, item.value, item.onTap)),

            // Komunitas & FAQ
            ...controller.iconItems.map((item) =>
                _infoTileWithIcon(item.title, item.icon, item.onTap)),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavbar(selectedIndex: 1),
    ));
  }

  Widget _infoTile(String title, String value, VoidCallback onTap) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title,
                  style: TextStyle(fontSize: 16, color: AppColors.iconDefault)),
              Text(value,
                  style: TextStyle(fontSize: 16, color: AppColors.snack)),
            ],
          ),
        ),
        const Divider(),
      ],
    );
  }

  Widget _infoTileWithIcon(String title, IconData icon, VoidCallback onTap) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title,
                  style: TextStyle(fontSize: 16, color: AppColors.iconDefault)),
              Icon(icon, color: AppColors.snack),
            ],
          ),
        ),
        const Divider(),
      ],
    );
  }
}
