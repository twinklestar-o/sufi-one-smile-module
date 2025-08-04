import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:sufi_one/app/modules/smile/models/area.dart';
import 'package:sufi_one/app/modules/smile/models/branch.dart';
import 'package:sufi_one/app/modules/smile/models/history.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sufi_one/app/modules/smile/models/product.dart';
import 'package:sufi_one/app/modules/smile/repositories/area_repository.dart';
import 'package:sufi_one/app/modules/smile/repositories/branch_repository.dart';
import 'package:sufi_one/app/modules/smile/repositories/product_repository.dart';
import 'package:sufi_one/src/constants/constants.dart';
import 'package:sufi_one/src/services/SMILE/api_services.dart';
import 'package:sufi_one/src/database/SMILE/database_helper.dart';

class HistoryViewController extends GetxController {
  // Data asli dari API
  final RxList<History> historyData = <History>[].obs;
  final RxList<Area> areaList = <Area>[].obs;
  final RxList<Branch> branchList = <Branch>[].obs;
  final RxList<Product> productList = <Product>[].obs;

  // Status pemuatan untuk menampilkan indikator loading
  final RxBool isLoading = false.obs;

  // Pesan kesalahan untuk ditampilkan di UI
  final RxString errorMessage = ''.obs;
  late final AreaRepository areaRepository;
  late final BranchRepository branchRepository;
  late final ProductRepository productRepository;

  @override
  void onInit() {
    super.onInit();
    loadHistoryData();
    areaRepository = AreaRepository(
      dbHelper: DatabaseHelperSmile.instance,
      apiService: ApiServiceSmile(),
    );
    loadLocalArea();

    branchRepository = BranchRepository(
      dbHelper: DatabaseHelperSmile.instance,
      apiService: ApiServiceSmile(),
    );
    loadLocalBranch();

    productRepository = ProductRepository(
      dbHelper: DatabaseHelperSmile.instance,
      apiService: ApiServiceSmile(),
    );
    loadLocalProduct();
  }

  Future<void> loadLocalArea() async {
    try {
      final result = await areaRepository.getAreas();
      areaList.assignAll(result);

      print('✅ Area list dimuat (${areaList.length} items)');
      for (var area in areaList) {
        print('-> ${area.code} - ${area.name}');
      }
    } catch (e) {
      print('❌ Gagal memuat area: $e');
    }
  }

  Future<void> loadLocalBranch() async {
    try {
      final result = await branchRepository.getBranches();
      branchList.assignAll(result);

      print('✅ Branch list dimuat (${branchList.length} items)');
      for (var branch in branchList) {
        print('-> ${branch.code} - ${branch.name}');
      }
    } catch (e) {
      print('❌ Gagal memuat branch: $e');
    }
  }

  Future<void> loadLocalProduct() async {
    try {
      final result = await productRepository.getProducts();
      productList.assignAll(result);

      print('✅ product list dimuat (${productList.length} items)');
      for (var product in productList) {
        print('-> ${product.code} - ${product.name}');
      }
    } catch (e) {
      print('❌ Gagal memuat product: $e');
    }
  }

  // Fungsi untuk memuat data dari API
  Future<void> loadHistoryData({bool isRefresh = false}) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      Get.snackbar('Error', 'User tidak login');
      return;
    }
    try {
      isLoading.value = true;
      errorMessage.value = '';
      historyData.clear(); // Bersihkan data sebelum memuat ulang

      final response = await http
          .get(
            Uri.parse(Url + 'direct-visit/history'),
            headers: {
              'Authorization': 'Bearer $token',
              'Accept': 'application/json',
            },
          )
          .timeout(
            const Duration(seconds: 15),
            onTimeout: () {
              throw Exception(
                'Permintaan ke API timeout setelah 15 detik. Periksa koneksi jaringan atau server.',
              );
            },
          );

      print(
        'Respons API: Status ${response.statusCode}, Body: ${response.body}',
      ); // Logging respons

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is List<dynamic>) {
          historyData.assignAll(
            data.map((json) => History.fromJson(json)).toList(),
          );
          if (historyData.isEmpty) {
            errorMessage.value = 'Data riwayat kunjungan kosong';
            print('Peringatan: Data riwayat kunjungan kosong'); // Logging
          }
        } else {
          throw Exception('Format respons API tidak valid: bukan daftar JSON');
        }
      } else {
        throw Exception(
          'Gagal memuat data: Status ${response.statusCode} - ${response.reasonPhrase}',
        );
      }
    } catch (e, stackTrace) {
      errorMessage.value = 'Gagal memuat data riwayat kunjungan: $e';
      historyData.clear();
      print('Error: $e\nStackTrace: $stackTrace'); // Logging untuk debugging
      Get.snackbar(
        'Error',
        errorMessage.value,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 5),
      );
    } finally {
      isLoading.value = false;
    }
  }

  String? getAreaNameFromKode(String? kode) {
    if (kode == null) {
      print('Kode area null');
      return null;
    }

    print('Mencari nama area untuk kode: $kode');
    for (var area in areaList) {
      print('Tersedia - Kode: ${area.code}, Nama: ${area.name}');
    }

    final area = areaList.firstWhereOrNull((a) => a.code == kode);
    if (area != null) {
      print('Area ditemukan: ${area.name}');
    } else {
      print('Tidak ditemukan area dengan kode: $kode');
    }
    return area?.name;
  }

  String? getBranchNameFromKode(String? kode) {
    if (kode == null) {
      print('Kode branch null');
      return null;
    }

    print('Mencari nama branch untuk kode: $kode');
    for (var branch in branchList) {
      print('Tersedia - Kode: ${branch.code}, Nama: ${branch.name}');
    }

    final branch = branchList.firstWhereOrNull((a) => a.code == kode);
    if (branch != null) {
      print('branch ditemukan: ${branch.name}');
    } else {
      print('Tidak ditemukan branch dengan kode: $kode');
    }
    return branch?.name;
  }

  String? getProductNameFromKode(String? kode) {
    if (kode == null) {
      print('Kode product null');
      return null;
    }

    print('Mencari nama product untuk kode: $kode');
    for (var product in productList) {
      print('Tersedia - Kode: ${product.code}, Nama: ${product.name}');
    }

    final product = productList.firstWhereOrNull((a) => a.code == kode);
    if (product != null) {
      print('product ditemukan: ${product.name}');
    } else {
      print('Tidak ditemukan product dengan kode: $kode');
    }
    return product?.name;
  }

  // Fungsi untuk refresh data dari API
  Future<void> refreshData() async {
    await loadHistoryData(isRefresh: true);
  }
}
