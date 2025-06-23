import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:provider/provider.dart';
import 'package:sufi_one/app/modules/public/home_routes.dart';
import 'package:sufi_one/app/modules/smile/repositories/area_repository.dart';
import 'package:sufi_one/app/routes/app_routes.dart';
import 'package:sufi_one/src/database/database_helper.dart';
import 'package:sufi_one/app/modules/smile/repositories/jabatan_repository.dart';
import 'package:sufi_one/src/services/api_services.dart';
import 'package:sufi_one/app/modules/smile/repositories/type_repository.dart';
import 'package:sufi_one/app/modules/smile/repositories/purpose_repository.dart'; //

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize dependencies
  final dbHelper = DatabaseHelper.instance;
  final apiService = ApiService(); // Tambahkan token di sini
  final jabatanRepository = JabatanRepository(
    dbHelper: dbHelper,
    apiService: apiService,
  );
  final typeRepository = TypeRepository(
    //
    dbHelper: dbHelper,
    apiService: apiService,
  );
  final areaRepository = AreaRepository(
    dbHelper: dbHelper,
    apiService: apiService,
  );
  final purposeRepository = PurposeRepository(
    dbHelper: dbHelper,
    apiService: apiService,
  );

  // Inisialisasi OneSignal
  OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
  OneSignal.initialize("INI KODE DARI ONESIGNAL");
  OneSignal.Notifications.requestPermission(true);

  runApp(
    MultiProvider(
      providers: [
        Provider<DatabaseHelper>(create: (_) => dbHelper),
        Provider<ApiService>(create: (_) => apiService),
        Provider<JabatanRepository>(create: (_) => jabatanRepository),
        Provider<AreaRepository>(create: (_) => areaRepository),
        Provider<TypeRepository>(create: (_) => typeRepository),
        Provider<PurposeRepository>(create: (_) => purposeRepository),
//
      ],
      child: const MyApp(),
    ),
  );
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
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      navigatorKey: Get.key,
      defaultTransition: Transition.fade,
    );
  }
}
