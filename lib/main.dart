import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:provider/provider.dart';
import 'package:sufi_one/app/modules/DAMS/repository/divisi_user_repository.dart';
import 'package:sufi_one/app/modules/DAMS/repository/lantai_user_repository.dart';
import 'package:sufi_one/app/modules/DAMS/repository/lokasi_user_repository.dart';
import 'package:sufi_one/app/modules/DAMS/repository/posisi_user_repository.dart';
import 'package:sufi_one/app/modules/DAMS/repository/status_asset_repository.dart';
import 'package:sufi_one/app/modules/DAMS/repository/kondisi_asset_repository.dart';
import 'package:sufi_one/app/modules/DAMS/repository/status_user_asset_repository.dart';
import 'package:sufi_one/app/modules/public/home_routes.dart';
import 'package:sufi_one/app/modules/smile/controllers/AuthController.dart';
import 'package:sufi_one/app/modules/smile/repositories/area_repository.dart';
import 'package:sufi_one/app/modules/smile/repositories/product_repository.dart';
import 'package:sufi_one/app/routes/app_routes.dart';
import 'package:sufi_one/src/database/DAMS/database_helper.dart';
import 'package:sufi_one/src/database/SMILE/database_helper.dart';
import 'package:sufi_one/app/modules/smile/repositories/jabatan_repository.dart';
import 'package:sufi_one/app/modules/smile/repositories/dealer_repository.dart';
import 'package:sufi_one/app/modules/smile/feature/smilehome/controllers/task_visit_controller.dart';
import 'package:sufi_one/src/services/DAMS/api_services.dart';
import 'package:sufi_one/src/services/SMILE/api_services.dart';
import 'package:sufi_one/app/modules/smile/repositories/type_repository.dart';
import 'package:sufi_one/app/modules/smile/repositories/purpose_repository.dart';
import 'package:sufi_one/app/modules/smile/repositories/branch_repository.dart';
import 'package:sufi_one/app/modules/smile/repositories/jabatanSFI_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Get.put(AuthController());
  Get.put(TaskVisitController());

  // ✅ Pastikan shared_preferences siap
  final prefs = await SharedPreferences.getInstance();
  final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

  // Initialize dependencies
  final dbHelperSmile = DatabaseHelperSmile.instance;
  final apiServiceSmile = ApiServiceSmile();
  final dbHelperDams = DatabaseHelperDams.instance;
  final apiServiceDams = ApiServiceDams();

  final jabatanRepository = JabatanRepository(
    dbHelper: dbHelperSmile,
    apiService: apiServiceSmile,
  );
  final typeRepository = TypeRepository(
    //
    dbHelper: dbHelperSmile,
    apiService: apiServiceSmile,
  );
  final areaRepository = AreaRepository(
    dbHelper: dbHelperSmile,
    apiService: apiServiceSmile,
  );
  final purposeRepository = PurposeRepository(
    dbHelper: dbHelperSmile,
    apiService: apiServiceSmile,
  );
  final branchRepository = BranchRepository(
    dbHelper: dbHelperSmile,
    apiService: apiServiceSmile,
  );
  final productRepository = ProductRepository(
    dbHelper: dbHelperSmile,
    apiService: apiServiceSmile,
  );
  final dealerRepository = DealerRepository(
    dbHelper: dbHelperSmile,
    apiService: apiServiceSmile,
  );
  final jabatanSFIRepository = JabatanSFIRepository(
    dbHelper: dbHelperSmile,
    apiService: apiServiceSmile,
  );

  //List Master DAMS
  final statusAssetRepository = StatusAssetRepository(
    dbHelper: dbHelperDams,
    apiService: apiServiceDams,
  );
  final kondisiAssetRepository = KondisiAssetRepository(
    dbHelper: dbHelperDams,
    apiService: apiServiceDams,
  );
  final statusUserAssetRepository = StatusUserAssetRepository(
    dbHelper: dbHelperDams,
    apiService: apiServiceDams,
  );
  final posisiUserRepository = PosisiUserRepository(
    dbHelper: dbHelperDams,
    apiService: apiServiceDams,
  );
  final divisiUserRepository = DivisiUserRepository(
    dbHelper: dbHelperDams,
    apiService: apiServiceDams,
  );
  final lokasiUserRepository = LokasiUserRepository(
    dbHelper: dbHelperDams,
    apiService: apiServiceDams,
  );
  final lantaiUserRepository = LantaiUserRepository(
    dbHelper: dbHelperDams,
    apiService: apiServiceDams,
  );
  // Inisialisasi OneSignal
  OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
  OneSignal.initialize("INI KODE DARI ONESIGNAL");
  OneSignal.Notifications.requestPermission(true);

  runApp(
    MultiProvider(
      providers: [
        Provider<DatabaseHelperSmile>(create: (_) => dbHelperSmile),
        Provider<ApiServiceSmile>(create: (_) => apiServiceSmile),
        Provider<JabatanRepository>(create: (_) => jabatanRepository),
        Provider<AreaRepository>(create: (_) => areaRepository),
        Provider<TypeRepository>(create: (_) => typeRepository),
        Provider<PurposeRepository>(create: (_) => purposeRepository),
        Provider<BranchRepository>(create: (_) => branchRepository),
        Provider<ProductRepository>(create: (_) => productRepository),
        Provider<DealerRepository>(create: (_) => dealerRepository),
        Provider<JabatanSFIRepository>(create: (_) => jabatanSFIRepository),

        //DAMS
        Provider<DatabaseHelperDams>(create: (_) => dbHelperDams),
        Provider<ApiServiceDams>(create: (_) => apiServiceDams),
        Provider<StatusAssetRepository>(create: (_) => statusAssetRepository),
        Provider<KondisiAssetRepository>(create: (_) => kondisiAssetRepository),
        Provider<StatusUserAssetRepository>(
          create: (_) => statusUserAssetRepository,
        ),
        Provider<PosisiUserRepository>(create: (_) => posisiUserRepository),
        Provider<DivisiUserRepository>(create: (_) => divisiUserRepository),
        Provider<LokasiUserRepository>(create: (_) => lokasiUserRepository),
        Provider<LantaiUserRepository>(create: (_) => lantaiUserRepository),
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
