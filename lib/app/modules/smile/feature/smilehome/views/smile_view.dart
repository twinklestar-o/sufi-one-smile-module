import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sufi_one/app/routes/app_routes.dart';

class SmileHomePage extends StatelessWidget {
  const SmileHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F5F5),
      body: Column(
        children: [
          Container(
            color: Colors.blue[900],
            padding: const EdgeInsets.only(
              top: 40,
              left: 20,
              right: 20,
              bottom: 20,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Mobile Smile",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
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
                    onTap: () => Get.toNamed('/public/smile/direct_visit'),
                  ),
                  _menuCard(
                    icon: Icons.assignment,
                    label: 'Task Visit',
                    onTap: () => Get.toNamed('/public/smile/task_visit'),
                  ),
                  _menuCard(
                    icon: Icons.history,
                    label: 'History Visit',
                    onTap: () => Get.toNamed('/public/smile/history_visit'),
                  ),
                  _menuCard(
                    icon: Icons.storage,
                    label: 'Data Master',
                    onTap: () => Get.toNamed('/public/smile/data_master'),
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
