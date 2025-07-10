import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sufi_one/app/Auth/controllers/logout_controller.dart';
import 'package:sufi_one/app/modules/smile/controllers/ProfileController.dart';
import 'package:sufi_one/app/modules/smile/models/user.dart';
import 'package:sufi_one/app/modules/smile/smile_route.dart';
import 'package:sufi_one/app/modules/smile/widgets/smile_appbarWsidebar.dart';
import 'package:sufi_one/app/modules/smile/widgets/smile_sidebar.dart';

class SmileHomePage extends StatefulWidget {
  const SmileHomePage({super.key});

  @override
  State<SmileHomePage> createState() => _SmileHomePageState();
}

class _SmileHomePageState extends State<SmileHomePage> {
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
      appBar: SmileAppBarWsidebar(),
      drawer: const Drawer(child: SmileSidebar()),
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
                  padding: const EdgeInsets.only(
                    left: 20,
                    right: 20,
                    bottom: 20,
                  ),
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
