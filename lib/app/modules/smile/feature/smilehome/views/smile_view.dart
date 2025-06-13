import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sufi_one/app/modules/smile/smile_route.dart';
import 'package:sufi_one/app/modules/smile/widgets/smile_appbarWsidebar.dart';
import 'package:sufi_one/app/modules/smile/widgets/smile_sidebar.dart';
import 'package:sufi_one/app/routes/app_routes.dart';
import 'package:sufi_one/app/modules/public/widgets/appbarWObutton.dart';

class SmileHomePage extends StatelessWidget {
  const SmileHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //backgroundColor: Color(0xFFF5F5F5),
      appBar: SmileAppBarWsidebar(),
      drawer: const Drawer(child: SmileSidebar()),
      body: Column(
        children: [
          Container(
            color: Colors.blue[900],
            padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.white,
                      radius: 30,
                      child: Icon(
                        Icons.person,
                        color: Colors.blue[900],
                        size: 40,
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            "Hallo, AHMAD.MARJUKI",
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                          Text(
                            "SFIBH",
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.logout, color: Colors.white),
                      onPressed: () {
                        // Tambahkan logika logout di sini
                        Get.offAllNamed('/public/login');
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 20,
                mainAxisSpacing: 20,
                children: [
                  _menuCard(
                    icon: Icons.directions_walk,
                    label: 'Direct Visit',
                    onTap: () => Get.toNamed(SmileRoutes.directVisit),
                  ),
                  _menuCard(
                    icon: Icons.assignment,
                    label: 'Task Visit',
                    onTap: () => Get.toNamed(SmileRoutes.taskVisit),
                  ),
                  _menuCard(
                    icon: Icons.history,
                    label: 'History Visit',
                    onTap: () => Get.toNamed(SmileRoutes.historyVisit),
                  ),
                  _menuCard(
                    icon: Icons.storage,
                    label: 'Data Master',
                    onTap: () => Get.toNamed(SmileRoutes.dataMaster),
                  ),
                  _menuCard(
                    icon: Icons.person,
                    label: 'Test Tampilan User',
                    onTap: () => Get.toNamed(SmileRoutes.profile),
                  ),
                  _menuCard(
                    icon: Icons.login,
                    label: 'Test Login',
                    onTap: () => Get.toNamed(SmileRoutes.login),
                  ),
                  _menuCard(
                    icon: Icons.login,
                    label: 'Test Register',
                    onTap: () => Get.toNamed(SmileRoutes.register),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _menuCard({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 40, color: Colors.blue[800]),
              const SizedBox(height: 10),
              Text(label, style: const TextStyle(fontSize: 14)),
            ],
          ),
        ),
      ),
    );
  }
}
