import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sufi_one/app/modules/public/home_routes.dart';
import 'app/routes/app_routes.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized(); // penting untuk shared_preferences
  runApp(MyApp());
  OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
  OneSignal.initialize("INI KODE DARI ONESIGNAL");
  OneSignal.Notifications.requestPermission(true);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'SuperApp (Public)',
      debugShowCheckedModeBanner: false,
      initialRoute: HomeRoutes.splash,
      getPages: AppRoutes.pages,
    );
  }
}
