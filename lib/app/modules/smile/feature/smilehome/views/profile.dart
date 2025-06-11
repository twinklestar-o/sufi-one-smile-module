import 'package:flutter/material.dart';
import 'package:sufi_one/app/modules/smile/controllers/ProfileController.dart';
import 'package:sufi_one/app/modules/smile/models/user.dart';
import 'package:get/get.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late Future<User> futureUser;
  final ProfileController _controller = ProfileController();

  static const Color headerBlue = Color(0xFF1521A4);

  @override
  void initState() {
    super.initState();
    futureUser = _controller.fetchUser();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'User Profile',
      home: Scaffold(
        backgroundColor: const Color(0xFFFDFDFF),
        appBar: AppBar(
          backgroundColor: headerBlue,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Get.back(),
          ),
          title: const Text('Profile', style: TextStyle(color: Colors.white)),
          centerTitle: true,
        ),
        body: Center(
          child: FutureBuilder<User>(
            future: futureUser,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                final userData = snapshot.data!.data;
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Name: ${userData.name}'),
                    Text('Email: ${userData.email}'),
                    Text('Created At: ${userData.createdAt}'),
                  ],
                );
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              }

              return const CircularProgressIndicator();
            },
          ),
        ),
      ),
    );
  }
}
