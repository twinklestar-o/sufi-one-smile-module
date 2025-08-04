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
import 'package:sufi_one/app/modules/smile/repositories/jabatanSFI_repository.dart';
import 'package:sufi_one/app/modules/smile/repositories/area_repository.dart';
import 'package:sufi_one/app/modules/smile/repositories/branch_repository.dart';
import 'package:sufi_one/app/modules/smile/repositories/product_repository.dart';
import 'package:sufi_one/app/modules/smile/repositories/type_repository.dart';
import 'package:sufi_one/app/modules/smile/repositories/purpose_repository.dart';
import 'package:sufi_one/app/modules/smile/repositories/jabatan_repository.dart';
import 'package:sufi_one/src/constants/constants.dart';
import 'package:sufi_one/src/database/SMILE/database_helper.dart';
import 'package:sufi_one/src/services/SMILE/api_services.dart';

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
  late TextEditingController pelaksanaanController;

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
      jabatanSFIList.assignAll(data);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal memuat jabatanSFI lokal: $e',
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
      areaList.assignAll(data);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal memuat area lokal: $e',
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
      branchList.assignAll(data);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal memuat branch lokal: $e',
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
      productList.assignAll(data);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal memuat Product lokal: $e',
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
      typeList.assignAll(data);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal memuat Type lokal: $e',
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
      purposeList.assignAll(data);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal memuat Purpose lokal: $e',
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
      jabatanList.assignAll(data);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal memuat Jabatan lokal: $e',
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
    pelaksanaanController = TextEditingController(
      text: initialData.description ?? '',
    );

    // Konversi kode → nama jabatan
    final matchedJabatanSFI = jabatanSFIList.firstWhereOrNull(
      (j) => j.kode == initialData.jabatanSaya,
    );
    if (matchedJabatanSFI != null) {
      selectedJabatanSFIName.value =
          matchedJabatanSFI.kode; // Gunakan kode untuk dropdown
    }

    // Konversi kode → nama area
    final matchedArea = areaList.firstWhereOrNull(
      (a) => a.code == initialData.areaCode,
    );
    if (matchedArea != null) {
      selectedAreaName.value = matchedArea.code; // Gunakan code untuk dropdown
    }

    // Konversi kode → nama branch
    final matchedBranch = branchList.firstWhereOrNull(
      (b) => b.code == initialData.branchCode,
    );
    if (matchedBranch != null) {
      selectedBranchName.value =
          matchedBranch.code; // Gunakan code untuk dropdown
    }

    // Konversi kode → nama product
    final matchedProduct = productList.firstWhereOrNull(
      (p) => p.code == initialData.productCode,
    );
    if (matchedProduct != null) {
      selectedProductName.value =
          matchedProduct.code; // Gunakan kode untuk dropdown
    }

    // Konversi kode → nama type
    final matchedType = typeList.firstWhereOrNull(
      (t) => t.kode == initialData.tipeVisit,
    );
    if (matchedType != null) {
      selectedTypeName.value = matchedType.kode; // Gunakan kode untuk dropdown
    }

    // Konversi kode → nama purpose
    final matchedPurpose = purposeList.firstWhereOrNull(
      (p) => p.kode == initialData.tujuanVisit,
    );
    if (matchedPurpose != null) {
      selectedPurposeName.value =
          matchedPurpose.kode; // Gunakan kode untuk dropdown
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
      data['jabatan_saya'] = getSelectedJabatanCode();
      data['area_code'] = getSelectedAreaCode();
      data['branch_code'] =
          cabangController.text; // Pastikan sesuai dengan controller
      data['product_code'] =
          produkController.text; // Pastikan sesuai dengan controller
      data['tipe_visit'] =
          tipeVisitController.text; // Pastikan sesuai dengan controller
      data['tujuan_visit'] =
          tujuanVisitController.text; // Pastikan sesuai dengan controller
      data['dari_tanggal'] = dariTanggalController.text;
      data['sampai_tanggal'] = sampaiTanggalController.text;
      data['tanggal_selesai'] = tanggalSelesaiController.text;
      data['nama_pic'] = picController.text;
      data['theme_of_discussion'] = discussionController.text;
      data['problem'] = problemController.text;
      data['description'] = pelaksanaanController.text;

      final response = await http.post(
        Uri.parse(Url + 'direct-visit/{id}'),
        headers: {
          'Authorization': 'Bearer ${GetStorage().read('token')}',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        print('Data berhasil disimpan: ${response.body}');
      } else {
        throw Exception('Gagal menyimpan data: ${response.statusCode}');
      }
    } catch (e) {
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
