import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import 'package:sufi_one/app/modules/smile/models/jabatanSFI.dart';
import 'package:sufi_one/app/modules/smile/models/visit.dart';
import 'package:sufi_one/app/modules/smile/models/area.dart';
import 'package:sufi_one/app/modules/smile/models/branch.dart';
import 'package:sufi_one/app/modules/smile/models/product.dart';
import 'package:sufi_one/app/modules/smile/models/type.dart';
import 'package:sufi_one/app/modules/smile/models/purpose.dart';
import 'package:sufi_one/app/modules/smile/models/jabatan.dart';
import 'package:sufi_one/src/constants/constants.dart';
import 'package:sufi_one/src/services/SMILE/api_services.dart';
import 'package:sufi_one/app/modules/smile/repositories/jabatanSFI_repository.dart';
import 'package:sufi_one/app/modules/smile/repositories/area_repository.dart';
import 'package:sufi_one/app/modules/smile/repositories/branch_repository.dart';
import 'package:sufi_one/app/modules/smile/repositories/product_repository.dart';
import 'package:sufi_one/app/modules/smile/repositories/type_repository.dart';
import 'package:sufi_one/app/modules/smile/repositories/purpose_repository.dart';
import 'package:sufi_one/app/modules/smile/repositories/jabatan_repository.dart';
import 'package:sufi_one/src/database/SMILE/database_helper.dart';

class HistoryEditController extends GetxController {
  final formKey = GlobalKey<FormState>();

  final isLoading = false.obs;
  final isLoadingJabatanSFI = false.obs;
  final isLoadingArea = false.obs;
  final isLoadingBranch = false.obs;
  final isLoadingProduct = false.obs;
  final isLoadingType = false.obs;
  final isLoadingPurpose = false.obs;
  final isLoadingJabatan = false.obs;

  final RxList<JabatanSFI> jabatanSFIList = <JabatanSFI>[].obs;
  final RxString selectedJabatanSFIName = ''.obs;

  final RxList<Area> areaList = <Area>[].obs;
  final RxString selectedAreaName = ''.obs;

  final RxList<Branch> branchList = <Branch>[].obs;
  final RxString selectedBranchName = ''.obs;

  final RxList<Product> productList = <Product>[].obs;
  final RxString selectedProductName = ''.obs;

  final RxList<Type> typeList = <Type>[].obs;
  final RxString selectedTypeName = ''.obs;

  final RxList<Purpose> purposeList = <Purpose>[].obs;
  final RxString selectedPurposeName = ''.obs;

  final RxList<Jabatan> jabatanList = <Jabatan>[].obs;
  final RxString selectedJabatanName = ''.obs;

  final dbHelper = DatabaseHelperSmile.instance;
  final apiService = ApiServiceSmile();
  late final JabatanSFIRepository jabatanSFIRepository;
  late final AreaRepository areaRepository;
  late final BranchRepository branchRepository;
  late final ProductRepository productRepository;
  late final TypeRepository typeRepository;
  late final PurposeRepository purposeRepository;
  late final JabatanRepository jabatanRepository;

  // TextEditingController untuk semua field
  late TextEditingController areaController;
  late TextEditingController cabangController;
  late TextEditingController produkController;
  late TextEditingController tipeVisitController;
  late TextEditingController tujuanVisitController;
  late TextEditingController dariTanggalController;
  late TextEditingController sampaiTanggalController;
  late TextEditingController tanggalSelesaiController;
  late TextEditingController picController;
  late TextEditingController discussionController;
  late TextEditingController problemController;
  late TextEditingController followUpController;
  late TextEditingController pelaksanaanController;
  late TextEditingController dealerController;
  late TextEditingController mainPersonNameController;
  late TextEditingController mainPersonPhoneController;

  // Main Persons List
  final RxList<Map<String, String>> mainPersons = <Map<String, String>>[].obs;

  @override
  void onInit() {
    super.onInit();
    jabatanSFIRepository = JabatanSFIRepository(
      dbHelper: dbHelper,
      apiService: apiService,
    );
    areaRepository = AreaRepository(dbHelper: dbHelper, apiService: apiService);
    branchRepository = BranchRepository(
      dbHelper: dbHelper,
      apiService: apiService,
    );
    productRepository = ProductRepository(
      dbHelper: dbHelper,
      apiService: apiService,
    );
    typeRepository = TypeRepository(dbHelper: dbHelper, apiService: apiService);
    purposeRepository = PurposeRepository(
      dbHelper: dbHelper,
      apiService: apiService,
    );
    jabatanRepository = JabatanRepository(
      dbHelper: dbHelper,
      apiService: apiService,
    );
    loadLocalJabatanSFI();
    loadLocalArea();
    loadLocalBranch();
    loadLocalProduct();
    loadLocalType();
    loadLocalPurpose();
    loadLocalJabatan();
  }

  Future<void> loadLocalJabatanSFI() async {
    isLoadingJabatanSFI.value = true;
    try {
      final data = await jabatanSFIRepository.dbHelper.getAllJabatanSFI();
      if (data.isEmpty) {
        // Jika data lokal kosong, coba ambil dari API
        final apiData = await jabatanSFIRepository.getJabatanSFIs(
          forceRefresh: true,
        );
        jabatanSFIList.assignAll(apiData);
      } else {
        jabatanSFIList.assignAll(data);
      }
      print('JabatanSFI loaded: ${jabatanSFIList.length} items');
    } catch (e) {
      print('Error loading JabatanSFI: $e');
      Get.snackbar(
        'Error',
        'Gagal memuat jabatanSFI: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoadingJabatanSFI.value = false;
    }
  }

  Future<void> loadLocalArea() async {
    isLoadingArea.value = true;
    try {
      final data = await areaRepository.dbHelper.getAllArea();
      if (data.isEmpty) {
        // Jika data lokal kosong, coba ambil dari API
        final apiData = await areaRepository.getAreas(forceRefresh: true);
        areaList.assignAll(apiData);
      } else {
        areaList.assignAll(data);
      }
      print('Area loaded: ${areaList.length} items');
    } catch (e) {
      print('Error loading Area: $e');
      Get.snackbar(
        'Error',
        'Gagal memuat area: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoadingArea.value = false;
    }
  }

  Future<void> loadLocalBranch() async {
    isLoadingBranch.value = true;
    try {
      final data = await branchRepository.dbHelper.getAllBranch();
      if (data.isEmpty) {
        // Jika data lokal kosong, coba ambil dari API
        final apiData = await branchRepository.getBranches(forceRefresh: true);
        branchList.assignAll(apiData);
      } else {
        branchList.assignAll(data);
      }
      print('Branch loaded: ${branchList.length} items');
    } catch (e) {
      print('Error loading Branch: $e');
      Get.snackbar(
        'Error',
        'Gagal memuat branch: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoadingBranch.value = false;
    }
  }

  Future<void> loadLocalProduct() async {
    isLoadingProduct.value = true;
    try {
      final data = await productRepository.dbHelper.getAllProduct();
      if (data.isEmpty) {
        // Jika data lokal kosong, coba ambil dari API
        final apiData = await productRepository.getProducts(forceRefresh: true);
        productList.assignAll(apiData);
      } else {
        productList.assignAll(data);
      }
      print('Product loaded: ${productList.length} items');
    } catch (e) {
      print('Error loading Product: $e');
      Get.snackbar(
        'Error',
        'Gagal memuat Product: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoadingProduct.value = false;
    }
  }

  Future<void> loadLocalType() async {
    isLoadingType.value = true;
    try {
      final data = await typeRepository.dbHelper.getAllType();
      if (data.isEmpty) {
        // Jika data lokal kosong, coba ambil dari API
        final apiData = await typeRepository.getTypes(forceRefresh: true);
        typeList.assignAll(apiData);
      } else {
        typeList.assignAll(data);
      }
      print('Type loaded: ${typeList.length} items');
    } catch (e) {
      print('Error loading Type: $e');
      Get.snackbar(
        'Error',
        'Gagal memuat Type: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoadingType.value = false;
    }
  }

  Future<void> loadLocalPurpose() async {
    isLoadingPurpose.value = true;
    try {
      final data = await purposeRepository.dbHelper.getAllPurpose();
      if (data.isEmpty) {
        // Jika data lokal kosong, coba ambil dari API
        final apiData = await purposeRepository.getPurposes(forceRefresh: true);
        purposeList.assignAll(apiData);
      } else {
        purposeList.assignAll(data);
      }
      print('Purpose loaded: ${purposeList.length} items');
    } catch (e) {
      print('Error loading Purpose: $e');
      Get.snackbar(
        'Error',
        'Gagal memuat Purpose: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoadingPurpose.value = false;
    }
  }

  Future<void> loadLocalJabatan() async {
    isLoadingJabatan.value = true;
    try {
      final data = await jabatanRepository.dbHelper.getAllJabatan();
      if (data.isEmpty) {
        // Jika data lokal kosong, coba ambil dari API
        final apiData = await jabatanRepository.getJabatans(forceRefresh: true);
        jabatanList.assignAll(apiData);
      } else {
        jabatanList.assignAll(data);
      }
      print('Jabatan loaded: ${jabatanList.length} items');
    } catch (e) {
      print('Error loading Jabatan: $e');
      Get.snackbar(
        'Error',
        'Gagal memuat Jabatan: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoadingJabatan.value = false;
    }
  }

  void initializeControllers(Visit initialData) {
    areaController = TextEditingController(text: initialData.areaCode ?? '');
    cabangController = TextEditingController(
      text: initialData.branchCode ?? '',
    );
    produkController = TextEditingController(
      text: initialData.productCode ?? '',
    );
    tipeVisitController = TextEditingController(
      text: initialData.tipeVisit ?? '',
    );
    tujuanVisitController = TextEditingController(
      text: initialData.tujuanVisit ?? '',
    );
    dariTanggalController = TextEditingController(
      text:
          initialData.dariTanggal != null
              ? DateFormat('dd MMM yyyy').format(initialData.dariTanggal!)
              : '',
    );
    sampaiTanggalController = TextEditingController(
      text:
          initialData.sampaiTanggal != null
              ? DateFormat('dd MMM yyyy').format(initialData.sampaiTanggal!)
              : '',
    );
    tanggalSelesaiController = TextEditingController(
      text:
          initialData.tanggalSelesai != null
              ? DateFormat('dd MMM yyyy').format(initialData.tanggalSelesai!)
              : '',
    );
    picController = TextEditingController(text: initialData.namaPic ?? '');
    discussionController = TextEditingController(
      text: initialData.themeOfDiscussion ?? '',
    );
    problemController = TextEditingController(text: initialData.problem ?? '');
    followUpController = TextEditingController(
      text: initialData.followUp ?? '',
    );
    pelaksanaanController = TextEditingController(
      text: initialData.description ?? '',
    );
    dealerController = TextEditingController(
      text: initialData.dealerCode ?? '',
    );
    mainPersonNameController = TextEditingController();
    mainPersonPhoneController = TextEditingController();
  }

  // Fungsi untuk memuat semua data terlebih dahulu
  Future<void> loadAllData() async {
    await Future.wait([
      loadLocalJabatanSFI(),
      loadLocalArea(),
      loadLocalBranch(),
      loadLocalProduct(),
      loadLocalType(),
      loadLocalPurpose(),
      loadLocalJabatan(),
    ]);

    print('All data loaded. Initializing dropdowns...');
    print('JabatanSFI: ${jabatanSFIList.length} items');
    print('Area: ${areaList.length} items');
    print('Branch: ${branchList.length} items');
    print('Product: ${productList.length} items');
    print('Type: ${typeList.length} items');
    print('Purpose: ${purposeList.length} items');
    print('Jabatan: ${jabatanList.length} items');
  }

  // Fungsi untuk menginisialisasi dropdown setelah data dimuat
  void initializeDropdowns(Visit initialData) {
    print('Initializing dropdowns with data: ${initialData.toJson()}');
    print('Available jabatanSFI: ${jabatanSFIList.length} items');
    print('Available area: ${areaList.length} items');
    print('Available branch: ${branchList.length} items');
    print('Available product: ${productList.length} items');
    print('Available type: ${typeList.length} items');
    print('Available purpose: ${purposeList.length} items');

    // Konversi nama → kode jabatan
    final matchedJabatanSFI = jabatanSFIList.firstWhereOrNull(
      (j) => j.name == initialData.jabatanSaya,
    );
    if (matchedJabatanSFI != null) {
      selectedJabatanSFIName.value = matchedJabatanSFI.kode;
      print(
        'Initialized jabatan: ${matchedJabatanSFI.kode} - ${matchedJabatanSFI.name}',
      );
    } else {
      print('No matching jabatan for name: ${initialData.jabatanSaya}');
      // Reset jika tidak ada match
      selectedJabatanSFIName.value = '';
    }

    // Konversi kode → nama area (area menggunakan code)
    final matchedArea = areaList.firstWhereOrNull(
      (a) => a.code == initialData.areaCode,
    );
    if (matchedArea != null) {
      selectedAreaName.value = matchedArea.code;
      print('Initialized area: ${matchedArea.code} - ${matchedArea.name}');
    } else {
      print('No matching area for code: ${initialData.areaCode}');
      // Reset jika tidak ada match
      selectedAreaName.value = '';
    }

    // Konversi kode → nama branch (branch menggunakan code)
    final matchedBranch = branchList.firstWhereOrNull(
      (b) => b.code == initialData.branchCode,
    );
    if (matchedBranch != null) {
      selectedBranchName.value = matchedBranch.code;
      print(
        'Initialized branch: ${matchedBranch.code} - ${matchedBranch.name}',
      );
    } else {
      print('No matching branch for code: ${initialData.branchCode}');
      // Reset jika tidak ada match
      selectedBranchName.value = '';
    }

    // Konversi kode → nama product (product menggunakan kode)
    final matchedProduct = productList.firstWhereOrNull(
      (p) => p.code == initialData.productCode,
    );
    if (matchedProduct != null) {
      selectedProductName.value = matchedProduct.code;
      print(
        'Initialized product: ${matchedProduct.code} - ${matchedProduct.name}',
      );
    } else {
      print('No matching product for code: ${initialData.productCode}');
      // Reset jika tidak ada match
      selectedProductName.value = '';
    }

    // Konversi nama → kode type
    final matchedType = typeList.firstWhereOrNull(
      (t) => t.name == initialData.tipeVisit,
    );
    if (matchedType != null) {
      selectedTypeName.value = matchedType.kode;
      print('Initialized type: ${matchedType.kode} - ${matchedType.name}');
    } else {
      print('No matching type for name: ${initialData.tipeVisit}');
      // Reset jika tidak ada match
      selectedTypeName.value = '';
    }

    // Konversi nama → kode purpose
    final matchedPurpose = purposeList.firstWhereOrNull(
      (p) => p.name == initialData.tujuanVisit,
    );
    if (matchedPurpose != null) {
      selectedPurposeName.value = matchedPurpose.kode;
      print(
        'Initialized purpose: ${matchedPurpose.kode} - ${matchedPurpose.name}',
      );
    } else {
      print('No matching purpose for name: ${initialData.tujuanVisit}');
      // Reset jika tidak ada match
      selectedPurposeName.value = '';
    }

    // Load main persons jika ada
    if (initialData.mainPersons != null &&
        initialData.mainPersons!.isNotEmpty) {
      try {
        final List<Map<String, String>> persons = [];
        for (var person in initialData.mainPersons!) {
          if (person is Map<String, dynamic>) {
            persons.add({
              'jabatan': person['jabatan']?.toString() ?? '',
              'nama': person['nama']?.toString() ?? '',
              'telp': person['telp']?.toString() ?? '',
            });
          }
        }
        mainPersons.assignAll(persons);
        print('Loaded ${mainPersons.length} main persons');
      } catch (e) {
        print('Error loading main persons: $e');
      }
    }
  }

  String getSelectedJabatanCode() {
    final matched = jabatanSFIList.firstWhereOrNull(
      (j) => j.kode == selectedJabatanSFIName.value,
    );
    return matched?.kode ?? '';
  }

  String getSelectedAreaCode() {
    final matched = areaList.firstWhereOrNull(
      (a) => a.code == selectedAreaName.value,
    );
    return matched?.code ?? '';
  }

  Future<void> saveEditedData(Map<String, dynamic> data) async {
    isLoading.value = true;
    try {
      // Ambil ID dari data yang diterima
      final String? id = data['id'];
      if (id == null) {
        throw Exception('ID tidak ditemukan dalam data');
      }

      // Format tanggal untuk API
      String formatDate(dynamic date) {
        if (date == null) return '';
        if (date is String) {
          // Jika date adalah string, coba parse ke DateTime
          try {
            final parsedDate = DateTime.parse(date);
            return DateFormat('yyyy-MM-dd').format(parsedDate);
          } catch (e) {
            print('Error parsing date string: $date');
            return date; // Return string as-is jika gagal parse
          }
        } else if (date is DateTime) {
          return DateFormat('yyyy-MM-dd').format(date);
        }
        return '';
      }

      // Persiapkan data untuk update dengan semua field yang ada
      final updateData = {
        'jabatan_saya': getSelectedJabatanCode(),
        'area_code': getSelectedAreaCode(),
        'branch_code':
            selectedBranchName.value.isNotEmpty
                ? selectedBranchName.value
                : cabangController.text,
        'product_code':
            selectedProductName.value.isNotEmpty
                ? selectedProductName.value
                : produkController.text,
        'dealer_code': dealerController.text,
        'tipe_visit':
            selectedTypeName.value.isNotEmpty
                ? selectedTypeName.value
                : tipeVisitController.text,
        'tujuan_visit':
            selectedPurposeName.value.isNotEmpty
                ? selectedPurposeName.value
                : tujuanVisitController.text,
        'dari_tanggal': formatDate(data['dari_tanggal']),
        'sampai_tanggal': formatDate(data['sampai_tanggal']),
        'tanggal_selesai': formatDate(data['tanggal_selesai']),
        'nama_pic': picController.text,
        'theme_of_discussion': discussionController.text,
        'problem': problemController.text,
        'follow_up': followUpController.text,
        'description': pelaksanaanController.text,
        'photo1_path': data['photo1_path'] ?? '',
        'photo2_path': data['photo2_path'] ?? '',
        'latitude': data['latitude']?.toString() ?? '',
        'longitude': data['longitude']?.toString() ?? '',
        'main_persons': mainPersons.toList(),
      };

      print('Data yang akan diupdate: ${jsonEncode(updateData)}');

      final response = await http.put(
        Uri.parse('${Url}direct-visit/$id'),
        headers: {
          'Authorization': 'Bearer ${GetStorage().read('token')}',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(updateData),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('Data berhasil disimpan: ${response.body}');
      } else {
        throw Exception(
          'Gagal menyimpan data: ${response.statusCode} - ${response.reasonPhrase}',
        );
      }
    } catch (e) {
      print('Error dalam saveEditedData: $e');
      throw Exception('Error menyimpan data: $e');
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    areaController.dispose();
    cabangController.dispose();
    produkController.dispose();
    tipeVisitController.dispose();
    tujuanVisitController.dispose();
    dariTanggalController.dispose();
    sampaiTanggalController.dispose();
    tanggalSelesaiController.dispose();
    picController.dispose();
    discussionController.dispose();
    problemController.dispose();
    pelaksanaanController.dispose();
    super.onClose();
  }
}
