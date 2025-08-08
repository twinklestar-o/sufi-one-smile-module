import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
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
  final mainPersonFormKey = GlobalKey<FormState>(); // Moved from HistoryEdit

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

  // Tambahkan variabel untuk file gambar
  final Rx<File?> selectedPhoto1 = Rx<File?>(null);
  final Rx<File?> selectedPhoto2 = Rx<File?>(null);

  // Rx variables for dates (moved from HistoryEdit)
  final Rx<DateTime?> selectedDariTanggal = Rx<DateTime?>(null);
  final Rx<DateTime?> selectedSampaiTanggal = Rx<DateTime?>(null);
  final Rx<DateTime?> selectedTanggalSelesai = Rx<DateTime?>(null);

  // Main Persons List
  final RxList<Map<String, String>> mainPersons = <Map<String, String>>[].obs;

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
    loadAllData();
  }

  Future<void> loadLocalJabatanSFI() async {
    isLoadingJabatanSFI.value = true;
    try {
      final data = await jabatanSFIRepository.dbHelper.getAllJabatanSFI();
      if (data.isEmpty) {
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

  Future<void> loadAllData() async {
    try {
      await Future.wait([
        loadLocalJabatanSFI(),
        loadLocalArea(),
        loadLocalBranch(),
        loadLocalProduct(),
        loadLocalType(),
        loadLocalPurpose(),
        loadLocalJabatan(),
      ]);
      print('All data loaded. Ready to initialize dropdowns.');
      print('JabatanSFI: ${jabatanSFIList.length} items');
      print('Area: ${areaList.length} items');
      print('Branch: ${branchList.length} items');
      print('Product: ${productList.length} items');
      print('Type: ${typeList.length} items');
      print('Purpose: ${purposeList.length} items');
      print('Jabatan: ${jabatanList.length} items');
    } catch (e) {
      print('Error loading all data: $e');
      Get.snackbar(
        'Error',
        'Gagal memuat semua data: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void initializeControllers(Visit initialData) {
    print('--- Initializing Controllers with Visit Data ---');
    print('Raw initialData: ${initialData.toJson()}'); // Print full raw data

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
      text: initialData.dariTanggal != null
          ? DateFormat('dd MMM yyyy').format(initialData.dariTanggal!)
          : '',
    );
    sampaiTanggalController = TextEditingController(
      text: initialData.sampaiTanggal != null
          ? DateFormat('dd MMM yyyy').format(initialData.sampaiTanggal!)
          : '',
    );
    tanggalSelesaiController = TextEditingController(
      text: initialData.tanggalSelesai != null
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

    // Initialize Rx date variables
    selectedDariTanggal.value = initialData.dariTanggal;
    selectedSampaiTanggal.value = initialData.sampaiTanggal;
    selectedTanggalSelesai.value = initialData.tanggalSelesai;

    // Inisialisasi mainPersons dari initialData
    print('Attempting to initialize mainPersons...');
    print('initialData.mainPersons raw value: ${initialData.mainPersons}');
    print('initialData.mainPersons runtimeType: ${initialData.mainPersons.runtimeType}');

    if (initialData.mainPersons != null && initialData.mainPersons!.isNotEmpty) {
      try {
        final List<Map<String, String>> persons = [];
        for (var person in initialData.mainPersons!) {
          print('Processing person: $person, type: ${person.runtimeType}');
          if (person is Map<String, dynamic>) {
            persons.add({
              'jabatan': person['jabatan']?.toString() ?? '',
              'nama': person['nama']?.toString() ?? '',
              'telp': person['telp']?.toString() ?? '',
            });
            print('Added person: ${persons.last}');
          } else {
            print('Warning: Unexpected main person item type: ${person.runtimeType}. Expected Map<String, dynamic>.');
          }
        }
        mainPersons.assignAll(persons);
        print('Initialized ${mainPersons.length} main persons from initialData successfully.');
      } catch (e) {
        print('Error initializing main persons in controller: $e');
        // Optionally clear mainPersons if an error occurs during parsing
        mainPersons.clear();
      }
    } else {
      print('initialData.mainPersons is null or empty. No main persons to initialize.');
      mainPersons.clear(); // Ensure it's empty if no data
    }
    print('Current mainPersons in controller: ${mainPersons.toList()}');
    print('--- End Initializing Controllers ---');
  }

  void initializeDropdowns(Visit initialData) {
    print('Initializing dropdowns with data: ${initialData.toJson()}');
    print('Available jabatanSFI: ${jabatanSFIList.length} items');
    print('Available area: ${areaList.length} items');
    print('Available branch: ${branchList.length} items');
    print('Available product: ${productList.length} items');
    print('Available type: ${typeList.length} items');
    print('Available purpose: ${purposeList.length} items');
    print('Available jabatan: ${jabatanList.length} items');

    // JabatanSFI: Cocokkan berdasarkan kode
    final matchedJabatanSFI = jabatanSFIList.firstWhereOrNull(
          (j) => j.kode == initialData.jabatanSaya,
    );
    if (matchedJabatanSFI != null) {
      selectedJabatanSFIName.value = matchedJabatanSFI.kode;
      print(
        'Initialized jabatanSFI: ${matchedJabatanSFI.kode} - ${matchedJabatanSFI.name}',
      );
    } else {
      print('No matching jabatanSFI for kode: ${initialData.jabatanSaya}');
      selectedJabatanSFIName.value = '';
    }

    // Area: Cocokkan berdasarkan code
    final matchedArea = areaList.firstWhereOrNull(
          (a) => a.code == initialData.areaCode,
    );
    if (matchedArea != null) {
      selectedAreaName.value = matchedArea.code;
      print('Initialized area: ${matchedArea.code} - ${matchedArea.name}');
    } else {
      print('No matching area for code: ${initialData.areaCode}');
      selectedAreaName.value = '';
    }

    // Branch: Cocokkan berdasarkan code
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
      selectedBranchName.value = '';
    }

    // Product: Cocokkan berdasarkan code
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
      selectedProductName.value = '';
    }

    // Type: Cocokkan berdasarkan kode
    final matchedType = typeList.firstWhereOrNull(
          (t) => t.kode == initialData.tipeVisit,
    );
    if (matchedType != null) {
      selectedTypeName.value = matchedType.kode;
      print('Initialized type: ${matchedType.kode} - ${matchedType.name}');
    } else {
      print('No matching type for kode: ${initialData.tipeVisit}');
      selectedTypeName.value = '';
    }

    // Purpose: Cocokkan berdasarkan kode
    final matchedPurpose = purposeList.firstWhereOrNull(
          (p) => p.kode == initialData.tujuanVisit,
    );
    if (matchedPurpose != null) {
      selectedPurposeName.value = matchedPurpose.kode;
      print(
        'Initialized purpose: ${matchedPurpose.kode} - ${matchedPurpose.name}',
      );
    } else {
      print('No matching purpose for kode: ${initialData.tujuanVisit}');
      selectedPurposeName.value = '';
    }

    // Jabatan (Main Person): Cocokkan berdasarkan kode
    // This part initializes the dropdown for adding *new* main persons,
    // not for displaying existing ones.
    if (initialData.mainPersons != null && initialData.mainPersons!.isNotEmpty) {
      final firstPerson = initialData.mainPersons!.firstWhereOrNull(
            (p) => p is Map<String, dynamic>,
      );
      if (firstPerson != null) {
        final matchedJabatan = jabatanList.firstWhereOrNull(
              (j) => j.kode == firstPerson['jabatan'],
        );
        if (matchedJabatan != null) {
          selectedJabatanName.value = matchedJabatan.kode;
          print(
            'Initialized jabatan (main person): ${matchedJabatan.kode} - ${matchedJabatan.name}',
          );
        } else {
          print('No matching jabatan for kode: ${firstPerson['jabatan']}');
          selectedJabatanName.value = '';
        }
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

  // Function to select date (moved from HistoryEdit)
  Future<void> selectDate(
      BuildContext context,
      String fieldType,
      ) async {
    DateTime initialDate = DateTime.now();
    DateTime firstDate = DateTime(2000);
    DateTime lastDate = DateTime(2100);
    Rx<DateTime?> targetRxDate;
    TextEditingController targetController;

    switch (fieldType) {
      case 'dariTanggal':
        targetRxDate = selectedDariTanggal;
        targetController = dariTanggalController;
        initialDate = selectedDariTanggal.value ?? DateTime.now();
        lastDate = DateTime.now();
        break;
      case 'sampaiTanggal':
        targetRxDate = selectedSampaiTanggal;
        targetController = sampaiTanggalController;
        initialDate = selectedSampaiTanggal.value ?? (selectedDariTanggal.value ?? DateTime.now());
        firstDate = selectedDariTanggal.value ?? DateTime(2000);
        break;
      case 'tanggalSelesai':
        targetRxDate = selectedTanggalSelesai;
        targetController = tanggalSelesaiController;
        initialDate = selectedTanggalSelesai.value ?? (selectedDariTanggal.value ?? DateTime.now());
        firstDate = selectedDariTanggal.value ?? DateTime(2000);
        lastDate = selectedSampaiTanggal.value ?? DateTime(2100);
        break;
      default:
        return;
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
      helpText: 'Pilih $fieldType',
    );

    if (picked != null) {
      bool isValid = true;
      String? errorMessage;

      if (fieldType == 'dariTanggal' && picked.isAfter(DateTime.now())) {
        isValid = false;
        errorMessage = 'Dari Tanggal tidak boleh melebihi hari ini';
      } else if (fieldType == 'sampaiTanggal' &&
          selectedDariTanggal.value != null &&
          picked.isBefore(selectedDariTanggal.value!)) {
        isValid = false;
        errorMessage =
        'Sampai Tanggal harus setelah atau sama dengan Dari Tanggal';
      } else if (fieldType == 'tanggalSelesai') {
        if (selectedDariTanggal.value != null &&
            picked.isBefore(selectedDariTanggal.value!)) {
          isValid = false;
          errorMessage =
          'Tanggal Selesai harus setelah atau sama dengan Dari Tanggal';
        } else if (selectedSampaiTanggal.value != null &&
            picked.isAfter(selectedSampaiTanggal.value!)) {
          isValid = false;
          errorMessage =
          'Tanggal Selesai harus sebelum atau sama dengan Sampai Tanggal';
        }
      }

      if (isValid) {
        targetRxDate.value = picked;
        targetController.text = DateFormat('dd MMM yyyy').format(picked);

        // Logic to reset dependent dates if they become invalid
        if (fieldType == 'dariTanggal') {
          if (selectedSampaiTanggal.value != null &&
              selectedSampaiTanggal.value!.isBefore(picked)) {
            selectedSampaiTanggal.value = null;
            sampaiTanggalController.text = '';
          }
          if (selectedTanggalSelesai.value != null &&
              selectedTanggalSelesai.value!.isBefore(picked)) {
            selectedTanggalSelesai.value = null;
            tanggalSelesaiController.text = '';
          }
        } else if (fieldType == 'sampaiTanggal') {
          if (selectedTanggalSelesai.value != null &&
              selectedTanggalSelesai.value!.isAfter(picked)) {
            selectedTanggalSelesai.value = null;
            tanggalSelesaiController.text = '';
          }
        }
      } else {
        Get.snackbar(
          'Peringatan',
          errorMessage!,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    }
  }

  Future<void> saveEditedData(
      Map<String, dynamic> data,
      File? photo1,
      File? photo2,
      ) async {
    isLoading.value = true;
    try {
      final String? id = data['id'];
      if (id == null) {
        throw Exception('ID tidak ditemukan dalam data');
      }

      String formatDate(dynamic date) {
        if (date == null) return '';
        if (date is String) {
          try {
            final parsedDate = DateTime.parse(date);
            return DateFormat('yyyy-MM-dd').format(parsedDate);
          } catch (e) {
            print('Error parsing date string: $date');
            return date;
          }
        } else if (date is DateTime) {
          return DateFormat('yyyy-MM-dd').format(date);
        }
        return '';
      }

      // Persiapkan request multipart
      final request = http.MultipartRequest(
        'PUT',
        Uri.parse('${Url}direct-visit/$id'),
      );

      // Tambahkan header
      request.headers['Authorization'] = 'Bearer ${GetStorage().read('token')}';

      // Tambahkan field data
      request.fields['jabatan_saya'] = getSelectedJabatanCode();
      request.fields['area_code'] = getSelectedAreaCode();
      request.fields['branch_code'] =
      selectedBranchName.value.isNotEmpty
          ? selectedBranchName.value
          : cabangController.text;
      request.fields['product_code'] =
      selectedProductName.value.isNotEmpty
          ? selectedProductName.value
          : produkController.text;
      request.fields['dealer_code'] = dealerController.text;
      request.fields['tipe_visit'] =
      selectedTypeName.value.isNotEmpty
          ? selectedTypeName.value
          : tipeVisitController.text;
      request.fields['tujuan_visit'] =
      selectedPurposeName.value.isNotEmpty
          ? selectedPurposeName.value
          : tujuanVisitController.text;
      request.fields['dari_tanggal'] = formatDate(data['dari_tanggal']);
      request.fields['sampai_tanggal'] = formatDate(data['sampai_tanggal']);
      request.fields['tanggal_selesai'] = formatDate(data['tanggal_selesai']);
      request.fields['nama_pic'] = picController.text;
      request.fields['theme_of_discussion'] = discussionController.text;
      request.fields['problem'] = problemController.text;
      request.fields['follow_up'] = followUpController.text;
      request.fields['description'] = pelaksanaanController.text;
      request.fields['latitude'] = data['latitude']?.toString() ?? '';
      request.fields['longitude'] = data['longitude']?.toString() ?? '';

      // Pastikan mainPersons di-encode ke JSON string
      request.fields['main_persons'] = jsonEncode(mainPersons.toList());

      // Tambahkan file gambar jika ada
      if (photo1 != null) {
        request.files.add(
          await http.MultipartFile.fromPath('photo1', photo1.path),
        );
      }
      if (photo2 != null) {
        request.files.add(
          await http.MultipartFile.fromPath('photo2', photo2.path),
        );
      }

      print('Mengirim data ke: ${Url}direct-visit/$id');
      print('Data fields: ${request.fields}');
      print('Files: ${request.files.length}');

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      print('Response status: ${response.statusCode}');
      print('Response body: $responseBody');

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('Data dan gambar berhasil disimpan: $responseBody');
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
    followUpController.dispose();
    pelaksanaanController.dispose();
    dealerController.dispose();
    mainPersonNameController.dispose();
    mainPersonPhoneController.dispose();
    super.onClose();
  }
}
