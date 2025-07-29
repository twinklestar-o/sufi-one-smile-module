import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sufi_one/app/modules/DAMS/widgets/dams_appbarWsidebar.dart';
import 'package:sufi_one/app/modules/DAMS/widgets/dams_sidebar.dart';
import 'package:sufi_one/app/modules/DAMS/dams_route.dart';
import 'package:sufi_one/app/modules/smile/controllers/ProfileController.dart';
import 'package:sufi_one/app/Auth/controllers/logout_controller.dart';
import 'package:sufi_one/app/modules/smile/models/user.dart';

class DamsHomePage extends StatefulWidget {
  const DamsHomePage({super.key});

  @override
  State<DamsHomePage> createState() => _DamsHomePageState();
}

class _DamsHomePageState extends State<DamsHomePage> {
  final ProfileController _controller = ProfileController();
  final LogoutController _logoutController = LogoutController();
  late Future<User> futureUser;

  @override
  void initState() {
    super.initState();
    futureUser = _controller.fetchUser();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: DamsAppbarwsidebar(),
      drawer: const Drawer(child: DamsSidebar()),
      body: FutureBuilder<User>(
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
                Container(
                  color: Colors.blue[900],
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.white,
                        radius: 30,
                        child: Icon(
                          Icons.person,
                          size: 35,
                          color: Colors.blue[800],
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Hallo, ${userData.name}",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              userData.email,
                              style: const TextStyle(
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
                          _logoutController.logout();
                        },
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
                          onTap: () => Get.toNamed(DamsRoute.historyPage),
                        ),
                        _menuCard(
                          icon: Icons.table_chart,
                          label: 'Data Master',
                          onTap: () => Get.toNamed(DamsRoute.listMaster),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          } else {
            return const Center(child: Text('No user data available'));
          }
        },
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
