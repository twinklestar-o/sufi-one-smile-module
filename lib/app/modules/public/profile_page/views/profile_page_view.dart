import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sufi_one/app/Auth/controllers/logout_controller.dart';
import 'package:sufi_one/app/modules/smile/controllers/AuthController.dart';
import 'package:sufi_one/app/modules/smile/controllers/ProfileController.dart';
import 'package:sufi_one/app/modules/smile/models/user.dart';
import 'package:sufi_one/app/modules/public/home_routes.dart';
import 'package:sufi_one/app/modules/public/widgets/appbarWsidebar.dart';
import 'package:sufi_one/app/modules/public/widgets/sidebar.dart';
import 'package:sufi_one/app/modules/public/widgets/bottomnavbar.dart';
import 'package:sufi_one/app/theme/color_constant.dart';
import 'package:sufi_one/app/theme/fontstyle.dart';

class ProfilePageView extends StatefulWidget {
  const ProfilePageView({Key? key}) : super(key: key);

  @override
  State<ProfilePageView> createState() => _ProfilePageViewState();
}

class _ProfilePageViewState extends State<ProfilePageView> {
  final ProfileController _controller = ProfileController();
  final AuthController _logoutController = Get.find<AuthController>();
  late Future<User> futureUser;

  @override
  void initState() {
    super.initState();
    futureUser = _controller.fetchUser();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg1,
      appBar: const SuzukiFinanceAppBarWsidebar(),
      drawer: const Drawer(child: AppSidebar()),
      body: SingleChildScrollView(
        child: FutureBuilder<User>(
          future: futureUser,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (snapshot.hasData) {
              final userData = snapshot.data!.data;
              return Column(
                children: [
                  const SizedBox(height: 16),
                  _buildHeader(userData.name, userData.email),
                  const SizedBox(height: 16),
                  _buildMenuSection(),
                  const SizedBox(height: 32),
                ],
              );
            } else {
              return const Center(child: Text('No user data available'));
            }
          },
        ),
      ),
      bottomNavigationBar: const BottomNavbar(selectedIndex: 3),
    );
  }

  Widget _buildHeader(String name, String email) {
    return Column(
      children: [
        const CircleAvatar(
          radius: 40,
          backgroundColor: Colors.blueGrey,
          child: Icon(Icons.person, size: 48, color: Colors.white),
        ),
        const SizedBox(height: 8),
        Text(name, style: AppTextStyles.bigBody),
        Text(email, style: AppTextStyles.smallBody),
        const SizedBox(height: 12),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 6,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildInfoTile('Points', '5.000', Icons.monetization_on),
              Container(height: 32, width: 1, color: Colors.grey[300]),
              _buildInfoTile('Sobat Sufi', 'DF9A549', Icons.card_membership),
              Container(height: 32, width: 1, color: Colors.grey[300]),
              _buildInfoTile('Level', 'Silver', Icons.military_tech),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoTile(String label, String value, IconData icon) {
    return Column(
      children: [
        Row(
          children: [
            Icon(icon, color: Colors.orange, size: 18),
            const SizedBox(width: 4),
            Text(
              value,
              style: AppTextStyles.medBody.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        Text(label, style: AppTextStyles.smallBody),
      ],
    );
  }

  Widget _buildMenuSection() {
    return Column(
      children: [
        _buildMenuItem('Pengajuan kendaraan saya', Icons.directions_car, () {}),
        _buildMenuItem('Riwayat Transaksi Point', Icons.history, () {
          Get.toNamed(HomeRoutes.transaksiPoint);
        }),
        _buildMenuItem('Ubah Profil', Icons.person, () {
          Get.toNamed(HomeRoutes.profileEdit);
        }),
        _buildMenuItem('Atur Ulang Kata Sandi', Icons.lock_reset, () {
          Get.toNamed(HomeRoutes.ubahPassword);
        }),
        _buildMenuItem('Keluar', Icons.logout, () {
          _logoutController.logout();
        }),
      ],
    );
  }

  Widget _buildMenuItem(String title, IconData icon, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.blue),
      title: Text(title, style: AppTextStyles.medBody),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: Colors.grey,
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
    );
  }
}
