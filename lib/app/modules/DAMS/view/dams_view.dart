import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sufi_one/app/modules/DAMS/widgets/dams_appbarWsidebar.dart';
import 'package:sufi_one/app/modules/DAMS/widgets/dams_sidebar.dart';
import 'package:sufi_one/app/modules/DAMS/dams_route.dart';

class DamsHomePage extends StatelessWidget {
  const DamsHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: DamsAppbarwsidebar(),
      drawer: const Drawer(child: DamsSidebar()),
      body: Column(
        children: [
          Container(
            color: Colors.blue[900],
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.white,
                  radius: 30,
                  child: Icon(Icons.person, size: 35, color: Colors.blue[800]),
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
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                      Text(
                        "1000 HO",
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.logout, color: Colors.white),
                  onPressed: () => Get.offAllNamed('/login'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: GridView.count(
                crossAxisCount: 3,
                crossAxisSpacing: 20,
                mainAxisSpacing: 20,
                children: [
                  _menuCard(
                    icon: Icons.qr_code,
                    label: 'Scan QR',
                    onTap: () => Get.toNamed(DamsRoute.scanCode),
                  ),
                  _menuCard(
                    icon: Icons.history,
                    label: 'History',
                    onTap: () => Get.toNamed('/history'),
                  ),
                  _menuCard(
                    icon: Icons.table_chart,
                    label: 'Data Master',
                    onTap: () => Get.toNamed('/data-master'),
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
        elevation: 3,
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
