import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sufi_one/app/modules/smile/feature/smilehome/controllers/history_edit_controller.dart';
import 'package:sufi_one/app/modules/smile/models/visit.dart';
import 'dart:io';

class HistoryEdit extends GetView<HistoryEditController> {
  const HistoryEdit({super.key});

  @override
  Widget build(BuildContext context) {
    // Inisialisasi data dari Get.arguments
    final Visit initialData = Visit.fromJson(
      Get.arguments as Map<String, dynamic>,
    );

    // Inisialisasi TextEditingController di controller
    controller.initializeControllers(initialData);

    // Inisialisasi state untuk tanggal
    final Rx<DateTime?> selectedDariTanggal = Rx<DateTime?>(
      initialData.dariTanggal,
    );
    final Rx<DateTime?> selectedSampaiTanggal = Rx<DateTime?>(
      initialData.sampaiTanggal,
    );
    final Rx<DateTime?> selectedTanggalSelesai = Rx<DateTime?>(
      initialData.tanggalSelesai,
    );

    // Inisialisasi state untuk file gambar
    final Rx<File?> selectedPhoto1 = Rx<File?>(null);
    final Rx<File?> selectedPhoto2 = Rx<File?>(null);

    // Page controller untuk slider gambar
    final PageController pageController = PageController();
    final RxInt currentImageIndex = 0.obs;

    // Pastikan semua data dimuat sebelum inisialisasi dropdown
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        // Tunggu hingga semua data dimuat
        await controller.loadAllData();
        // Inisialisasi dropdown dengan data yang sesuai
        controller.initializeDropdowns(initialData);
      } catch (e) {
        print('Error loading data: $e');
        Get.snackbar(
          'Error',
          'Gagal memuat data: $e',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    });

    // Fungsi untuk memilih gambar
    Future<void> pickImage(int imageIndex) async {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        if (imageIndex == 0) {
          selectedPhoto1.value = File(pickedFile.path);
        } else {
          selectedPhoto2.value = File(pickedFile.path);
        }
      }
    }

    // Fungsi untuk memilih tanggal
    Future<void> selectDate(
        BuildContext context,
        String fieldType,
        Rx<DateTime?> selectedDate,
        ) async {
      DateTime initialDate = DateTime.now();
      DateTime firstDate = DateTime(2000);
      DateTime lastDate = DateTime(2100);

      switch (fieldType) {
        case 'dariTanggal':
          initialDate = selectedDariTanggal.value ?? DateTime.now();
          lastDate = DateTime.now();
          break;
        case 'sampaiTanggal':
          initialDate =
              selectedSampaiTanggal.value ??
                  (selectedDariTanggal.value ?? DateTime.now());
          firstDate = selectedDariTanggal.value ?? DateTime(2000);
          break;
        case 'tanggalSelesai':
          initialDate =
              selectedTanggalSelesai.value ??
                  (selectedDariTanggal.value ?? DateTime.now());
          firstDate = selectedDariTanggal.value ?? DateTime(2000);
          lastDate = selectedSampaiTanggal.value ?? DateTime(2100);
          break;
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
          selectedDate.value = picked;
          switch (fieldType) {
            case 'dariTanggal':
              controller.dariTanggalController.text = DateFormat(
                'dd MMM yyyy',
              ).format(picked);
              if (selectedSampaiTanggal.value != null &&
                  selectedSampaiTanggal.value!.isBefore(picked)) {
                selectedSampaiTanggal.value = null;
                controller.sampaiTanggalController.text = '';
              }
              if (selectedTanggalSelesai.value != null &&
                  selectedTanggalSelesai.value!.isBefore(picked)) {
                selectedTanggalSelesai.value = null;
                controller.tanggalSelesaiController.text = '';
              }
              break;
            case 'sampaiTanggal':
              controller.sampaiTanggalController.text = DateFormat(
                'dd MMM yyyy',
              ).format(picked);
              if (selectedTanggalSelesai.value != null &&
                  selectedTanggalSelesai.value!.isAfter(picked)) {
                selectedTanggalSelesai.value = null;
                controller.tanggalSelesaiController.text = '';
              }
              break;
            case 'tanggalSelesai':
              controller.tanggalSelesaiController.text = DateFormat(
                'dd MMM yyyy',
              ).format(picked);
              break;
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(errorMessage!), backgroundColor: Colors.red),
          );
        }
      }
    }

    // Define custom colors - sama persis dengan direct_visit.dart
    const Color headerBlue = Color(0xFF1521A4);
    const Color dropdownLight = Color(0xFF272728);
    const Color dropdownLightNF = Color(0xFFCCCCCC);
    const Color dropdownLightF = Color(0xFFAFA1CF);
    const Color textButton = Color(0xFF8BADCA);

    return Scaffold(
      backgroundColor: const Color(0xFFFDFDFF),
      appBar: AppBar(
        backgroundColor: headerBlue,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Edit Visit Dealer',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: controller.formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Card Data Gambar dengan Slider
                Card(
                  color: const Color(0xFFFDFDFF),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Text(
                            'Data Gambar',
                            style: TextStyle(fontSize: 22, color: headerBlue),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Image Slider Container
                        Container(
                          height: 200,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.3),
                                spreadRadius: 2,
                                blurRadius: 5,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Stack(
                            children: [
                              // PageView untuk slider
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: PageView(
                                  controller: pageController,
                                  physics: const BouncingScrollPhysics(), // Tambahkan physics
                                  onPageChanged: (index) {
                                    currentImageIndex.value = index;
                                  },
                                  children: [
                                    // Gambar 1
                                    _buildImageSlide(
                                      selectedPhoto1,
                                      initialData.photo1,
                                      'Gambar 1',
                                      0,
                                    ),
                                    // Gambar 2
                                    _buildImageSlide(
                                      selectedPhoto2,
                                      initialData.photo2,
                                      'Gambar 2',
                                      1,
                                    ),
                                  ],
                                ),
                              ),

                              // Page Indicators
                              Positioned(
                                bottom: 10,
                                left: 0,
                                right: 0,
                                child: Obx(() => Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    _buildPageIndicator(0, currentImageIndex.value),
                                    const SizedBox(width: 8),
                                    _buildPageIndicator(1, currentImageIndex.value),
                                  ],
                                )),
                              ),

                              // Edit Button Overlay - posisi yang tidak menghalangi swipe
                              Positioned(
                                top: 10,
                                right: 10,
                                child: GestureDetector(
                                  onTap: () => pickImage(currentImageIndex.value),
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.blue.withOpacity(0.8),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.camera_alt,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Image Selection Buttons
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  pageController.animateToPage(
                                    0,
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeInOut,
                                  );
                                },
                                icon: const Icon(Icons.image, size: 16),
                                label: const Text('Gambar 1'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  pageController.animateToPage(
                                    1,
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeInOut,
                                  );
                                },
                                icon: const Icon(Icons.image, size: 16),
                                label: const Text('Gambar 2'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        // Tombol untuk pick image
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () => pickImage(0),
                                icon: const Icon(Icons.camera_alt, size: 16),
                                label: const Text('Pilih Gambar 1'),
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(color: Colors.blue),
                                  foregroundColor: Colors.blue,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () => pickImage(1),
                                icon: const Icon(Icons.camera_alt, size: 16),
                                label: const Text('Pilih Gambar 2'),
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(color: Colors.blue),
                                  foregroundColor: Colors.blue,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        // Info text
                        Obx(() => Center(
                          child: Text(
                            'Geser untuk melihat ${currentImageIndex.value == 0 ? 'Gambar 1' : 'Gambar 2'}',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        )),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Card Jabatan Saya
                Card(
                  color: const Color(0xFFFDFDFF),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Center(
                          child: Text(
                            'Jabatan Saya',
                            style: TextStyle(fontSize: 22, color: headerBlue),
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildFieldLabel('Jabatan'),
                        Obx(
                              () =>
                          controller.isLoadingJabatanSFI.value
                              ? const CircularProgressIndicator()
                              : controller.jabatanSFIList.isEmpty
                              ? const Center(
                            child: Text(
                              'Tidak ada data jabatan tersedia',
                            ),
                          )
                              : DropdownButtonFormField<String>(
                            isExpanded: true,
                            value:
                            controller
                                .selectedJabatanSFIName
                                .value
                                .isNotEmpty &&
                                controller.jabatanSFIList.any(
                                      (item) =>
                                  item.kode ==
                                      controller
                                          .selectedJabatanSFIName
                                          .value,
                                )
                                ? controller
                                .selectedJabatanSFIName
                                .value
                                : null,
                            hint: Text(
                              '-- Pilih Jabatan --',
                              style: TextStyle(color: dropdownLight),
                            ),
                            icon: const Icon(Icons.expand_more),
                            iconEnabledColor: dropdownLight,
                            style: TextStyle(color: dropdownLight),
                            decoration: const InputDecoration(
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: dropdownLightNF,
                                  width: 0.5,
                                ),
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: dropdownLightF,
                                  width: 2.0,
                                ),
                              ),
                            ),
                            items:
                            controller.jabatanSFIList.map((
                                jabatan,
                                ) {
                              return DropdownMenuItem<String>(
                                value: jabatan.kode,
                                child: Text(jabatan.name),
                              );
                            }).toList(),
                            onChanged: (value) {
                              controller.selectedJabatanSFIName.value =
                                  value ?? '';
                            },
                            validator:
                                (value) =>
                            value == null || value.isEmpty
                                ? 'Harap pilih jabatan'
                                : null,
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Card Data Dealer
                Card(
                  color: const Color(0xFFFDFDFF),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Text(
                            'Data Dealer',
                            style: TextStyle(fontSize: 22, color: headerBlue),
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildFieldLabel('Area'),
                        Obx(
                              () =>
                          controller.isLoadingArea.value
                              ? const CircularProgressIndicator()
                              : controller.areaList.isEmpty
                              ? const Center(
                            child: Text('Tidak ada data area tersedia'),
                          )
                              : DropdownButtonFormField<String>(
                            isExpanded: true,
                            value:
                            controller
                                .selectedAreaName
                                .value
                                .isNotEmpty &&
                                controller.areaList.any(
                                      (item) =>
                                  item.code ==
                                      controller
                                          .selectedAreaName
                                          .value,
                                )
                                ? controller.selectedAreaName.value
                                : null,
                            hint: Text(
                              '-- Pilih Area --',
                              style: TextStyle(color: dropdownLight),
                            ),
                            icon: const Icon(Icons.expand_more),
                            iconEnabledColor: dropdownLight,
                            style: const TextStyle(
                              color: dropdownLight,
                            ),
                            decoration: const InputDecoration(
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: dropdownLightNF,
                                  width: 0.5,
                                ),
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: dropdownLightF,
                                  width: 2.0,
                                ),
                              ),
                            ),
                            items:
                            controller.areaList.map((area) {
                              return DropdownMenuItem<String>(
                                value: area.code,
                                child: Text(area.name),
                              );
                            }).toList(),
                            onChanged: (value) {
                              controller.selectedAreaName.value =
                                  value ?? '';
                            },
                            validator:
                                (value) =>
                            value == null || value.isEmpty
                                ? 'Harap pilih area'
                                : null,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildFieldLabel('Cabang'),
                        Obx(
                              () =>
                          controller.isLoadingBranch.value
                              ? const CircularProgressIndicator()
                              : controller.branchList.isEmpty
                              ? const Center(
                            child: Text(
                              'Tidak ada data cabang tersedia',
                            ),
                          )
                              : DropdownButtonFormField<String>(
                            isExpanded: true,
                            value:
                            controller
                                .selectedBranchName
                                .value
                                .isNotEmpty &&
                                controller.branchList.any(
                                      (item) =>
                                  item.code ==
                                      controller
                                          .selectedBranchName
                                          .value,
                                )
                                ? controller
                                .selectedBranchName
                                .value
                                : null,
                            hint: Text(
                              '-- Pilih Cabang --',
                              style: TextStyle(color: dropdownLight),
                            ),
                            icon: const Icon(Icons.expand_more),
                            iconEnabledColor: dropdownLight,
                            style: const TextStyle(
                              color: dropdownLight,
                            ),
                            decoration: const InputDecoration(
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: dropdownLightNF,
                                  width: 0.5,
                                ),
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: dropdownLightF,
                                  width: 2.0,
                                ),
                              ),
                            ),
                            items:
                            controller.branchList.map((branch) {
                              return DropdownMenuItem<String>(
                                value: branch.code,
                                child: Text(branch.name),
                              );
                            }).toList(),
                            onChanged: (value) {
                              controller.selectedBranchName.value =
                                  value ?? '';
                            },
                            validator:
                                (value) =>
                            value == null || value.isEmpty
                                ? 'Harap pilih cabang'
                                : null,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildFieldLabel('Produk'),
                        Obx(
                              () =>
                          controller.isLoadingProduct.value
                              ? const CircularProgressIndicator()
                              : controller.productList.isEmpty
                              ? const Center(
                            child: Text(
                              'Tidak ada data Product tersedia',
                            ),
                          )
                              : DropdownButtonFormField<String>(
                            isExpanded: true,
                            value:
                            controller
                                .selectedProductName
                                .value
                                .isNotEmpty &&
                                controller.productList.any(
                                      (item) =>
                                  item.code ==
                                      controller
                                          .selectedProductName
                                          .value,
                                )
                                ? controller
                                .selectedProductName
                                .value
                                : null,
                            hint: Text(
                              '-- Pilih Produk --',
                              style: TextStyle(color: dropdownLight),
                            ),
                            icon: const Icon(Icons.expand_more),
                            iconEnabledColor: dropdownLight,
                            style: const TextStyle(
                              color: dropdownLight,
                            ),
                            decoration: const InputDecoration(
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: dropdownLightNF,
                                  width: 0.5,
                                ),
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: dropdownLightF,
                                  width: 2.0,
                                ),
                              ),
                            ),
                            items:
                            controller.productList.map((product) {
                              return DropdownMenuItem<String>(
                                value: product.code,
                                child: Text(product.name),
                              );
                            }).toList(),
                            onChanged: (value) {
                              controller.selectedProductName.value =
                                  value ?? '';
                            },
                            validator:
                                (value) =>
                            value == null || value.isEmpty
                                ? 'Harap pilih Product'
                                : null,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildFieldLabel('Dealer'),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: controller.dealerController,
                                readOnly: true,
                                decoration: InputDecoration(
                                  hintText: 'Pilih dealer terlebih dahulu',
                                  hintStyle: TextStyle(color: dropdownLightNF),
                                  enabledBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(
                                      color: dropdownLightNF,
                                      width: 0.5,
                                    ),
                                  ),
                                  focusedBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(
                                      color: dropdownLightF,
                                      width: 2.0,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton.icon(
                              onPressed: () {
                                Get.snackbar(
                                  'Info',
                                  'Fitur pencarian dealer akan segera tersedia',
                                );
                              },
                              icon: const Icon(Icons.search, size: 16),
                              label: const Text('Cari Dealer'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.info, color: Colors.blue, size: 16),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                'Klik tombol "Cari Dealer" untuk memulai pencarian',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Card Data Visit
                Card(
                  color: const Color(0xFFFDFDFF),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Text(
                            'Data Visit',
                            style: TextStyle(fontSize: 22, color: headerBlue),
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildFieldLabel('Tipe Visit'),
                        Obx(
                              () =>
                          controller.isLoadingType.value
                              ? const CircularProgressIndicator()
                              : controller.typeList.isEmpty
                              ? const Center(
                            child: Text('Tidak ada data Type tersedia'),
                          )
                              : DropdownButtonFormField<String>(
                            isExpanded: true,
                            value:
                            controller
                                .selectedTypeName
                                .value
                                .isNotEmpty &&
                                controller.typeList.any(
                                      (item) =>
                                  item.kode ==
                                      controller
                                          .selectedTypeName
                                          .value,
                                )
                                ? controller.selectedTypeName.value
                                : null,
                            hint: Text(
                              '-- Pilih Tipe Visit --',
                              style: TextStyle(color: dropdownLight),
                            ),
                            icon: const Icon(Icons.expand_more),
                            iconEnabledColor: dropdownLight,
                            style: const TextStyle(
                              color: dropdownLight,
                            ),
                            decoration: const InputDecoration(
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: dropdownLightNF,
                                  width: 0.5,
                                ),
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: dropdownLightF,
                                  width: 2.0,
                                ),
                              ),
                            ),
                            items:
                            controller.typeList.map((type) {
                              return DropdownMenuItem<String>(
                                value: type.kode,
                                child: Text(type.name),
                              );
                            }).toList(),
                            onChanged: (value) {
                              controller.selectedTypeName.value =
                                  value ?? '';
                            },
                            validator:
                                (value) =>
                            value == null || value.isEmpty
                                ? 'Harap Pilih Tipe Visit'
                                : null,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildFieldLabel('Tujuan Visit'),
                        Obx(
                              () =>
                          controller.isLoadingPurpose.value
                              ? const CircularProgressIndicator()
                              : controller.purposeList.isEmpty
                              ? const Center(
                            child: Text(
                              'Tidak ada data Purpose tersedia',
                            ),
                          )
                              : DropdownButtonFormField<String>(
                            isExpanded: true,
                            value:
                            controller
                                .selectedPurposeName
                                .value
                                .isNotEmpty &&
                                controller.purposeList.any(
                                      (item) =>
                                  item.kode ==
                                      controller
                                          .selectedPurposeName
                                          .value,
                                )
                                ? controller
                                .selectedPurposeName
                                .value
                                : null,
                            hint: Text(
                              '-- Pilih Tujuan Visit --',
                              style: TextStyle(color: dropdownLight),
                            ),
                            icon: const Icon(Icons.expand_more),
                            iconEnabledColor: dropdownLight,
                            style: const TextStyle(
                              color: dropdownLight,
                            ),
                            decoration: const InputDecoration(
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: dropdownLightNF,
                                  width: 0.5,
                                ),
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: dropdownLightF,
                                  width: 2.0,
                                ),
                              ),
                            ),
                            items:
                            controller.purposeList.map((purpose) {
                              return DropdownMenuItem<String>(
                                value: purpose.kode,
                                child: Text(purpose.name),
                              );
                            }).toList(),
                            onChanged: (value) {
                              controller.selectedPurposeName.value =
                                  value ?? '';
                            },
                            validator:
                                (value) =>
                            value == null || value.isEmpty
                                ? 'Harap Pilih Tujuan Visit'
                                : null,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildFieldLabel('Dari Tanggal'),
                        _buildDateField(
                          selectedDariTanggal.value,
                              () => selectDate(
                            context,
                            'dariTanggal',
                            selectedDariTanggal,
                          ),
                          'dariTanggal',
                        ),
                        const SizedBox(height: 12),
                        _buildFieldLabel('Sampai Tanggal'),
                        _buildDateField(
                          selectedSampaiTanggal.value,
                              () => selectDate(
                            context,
                            'sampaiTanggal',
                            selectedSampaiTanggal,
                          ),
                          'sampaiTanggal',
                        ),
                        const SizedBox(height: 12),
                        _buildFieldLabel('Tanggal Selesai'),
                        _buildDateField(
                          selectedTanggalSelesai.value,
                              () => selectDate(
                            context,
                            'tanggalSelesai',
                            selectedTanggalSelesai,
                          ),
                          'tanggalSelesai',
                        ),
                        const SizedBox(height: 12),
                        _buildFieldLabel('Nama PIC'),
                        TextFormField(
                          controller: controller.picController,
                          style: TextStyle(color: dropdownLight, fontSize: 16),
                          maxLength: 50,
                          maxLengthEnforcement: MaxLengthEnforcement.enforced,
                          decoration: InputDecoration(
                            hintText: 'Masukkan nama PIC',
                            hintStyle: TextStyle(color: dropdownLightNF),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: dropdownLightF,
                                width: 1.5,
                              ),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: dropdownLightF,
                                width: 3.0,
                              ),
                            ),
                            contentPadding: EdgeInsets.symmetric(
                              vertical: 16,
                              horizontal: 8,
                            ),
                          ),
                          keyboardType: TextInputType.text,
                          inputFormatters: [
                            FilteringTextInputFormatter.deny(RegExp(r'[0-9]')),
                          ],
                          validator:
                              (v) =>
                          v == null || v.isEmpty
                              ? 'Nama PIC wajib diisi'
                              : null,
                        ),
                        const SizedBox(height: 12),
                        _buildFieldLabel('Theme of Discussion'),
                        TextFormField(
                          controller: controller.discussionController,
                          style: TextStyle(color: dropdownLight, fontSize: 16),
                          maxLength: 1000,
                          maxLengthEnforcement: MaxLengthEnforcement.enforced,
                          minLines: 3,
                          maxLines: 5,
                          decoration: InputDecoration(
                            hintText: 'Masukkan tema diskusi',
                            hintStyle: TextStyle(color: dropdownLightNF),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: dropdownLightNF,
                                width: 0.5,
                              ),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: dropdownLightF,
                                width: 2.0,
                              ),
                            ),
                            contentPadding: EdgeInsets.symmetric(
                              vertical: 16,
                              horizontal: 8,
                            ),
                          ),
                          validator:
                              (v) =>
                          v == null || v.isEmpty
                              ? 'Tema diskusi wajib diisi'
                              : null,
                        ),
                        const SizedBox(height: 12),
                        _buildFieldLabel('Problem'),
                        TextFormField(
                          controller: controller.problemController,
                          style: TextStyle(color: dropdownLight, fontSize: 16),
                          maxLength: 1000,
                          maxLengthEnforcement: MaxLengthEnforcement.enforced,
                          minLines: 3,
                          maxLines: 5,
                          decoration: InputDecoration(
                            hintText: 'Masukkan Problem',
                            hintStyle: TextStyle(color: dropdownLightNF),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: dropdownLightNF,
                                width: 0.5,
                              ),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: dropdownLightF,
                                width: 2.0,
                              ),
                            ),
                            contentPadding: EdgeInsets.symmetric(
                              vertical: 16,
                              horizontal: 8,
                            ),
                          ),
                          validator:
                              (v) =>
                          v == null || v.isEmpty
                              ? 'Problem wajib diisi'
                              : null,
                        ),
                        const SizedBox(height: 12),
                        _buildFieldLabel('Follow-Up'),
                        TextFormField(
                          controller: controller.followUpController,
                          style: TextStyle(color: dropdownLight, fontSize: 16),
                          maxLength: 1000,
                          maxLengthEnforcement: MaxLengthEnforcement.enforced,
                          minLines: 3,
                          maxLines: 5,
                          decoration: InputDecoration(
                            hintText: 'Masukkan Follow-Up',
                            hintStyle: TextStyle(color: dropdownLightNF),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: dropdownLightNF,
                                width: 0.5,
                              ),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: dropdownLightF,
                                width: 2.0,
                              ),
                            ),
                            contentPadding: EdgeInsets.symmetric(
                              vertical: 16,
                              horizontal: 8,
                            ),
                          ),
                          validator:
                              (v) =>
                          v == null || v.isEmpty
                              ? 'Follow-Up wajib diisi'
                              : null,
                        ),
                        const SizedBox(height: 12),
                        _buildFieldLabel('Description'),
                        TextFormField(
                          controller: controller.pelaksanaanController,
                          style: TextStyle(color: dropdownLight, fontSize: 16),
                          maxLength: 1000,
                          maxLengthEnforcement: MaxLengthEnforcement.enforced,
                          minLines: 3,
                          maxLines: 5,
                          decoration: InputDecoration(
                            hintText: 'Masukkan deskripsi',
                            hintStyle: TextStyle(color: dropdownLightNF),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: dropdownLightNF,
                                width: 0.5,
                              ),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: dropdownLightF,
                                width: 2.0,
                              ),
                            ),
                            contentPadding: EdgeInsets.symmetric(
                              vertical: 16,
                              horizontal: 8,
                            ),
                          ),
                          validator:
                              (v) =>
                          v == null || v.isEmpty
                              ? 'Deskripsi wajib diisi'
                              : null,
                        ),
                      ],
                    ),
                  ),
                ),

                // Card Main Person
                Card(
                  color: const Color(0xFFFDFDFF),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Text(
                            'Main Person',
                            style: TextStyle(fontSize: 22, color: headerBlue),
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildFieldLabel('Jabatan'),
                        Obx(
                              () =>
                          controller.isLoadingJabatan.value
                              ? const CircularProgressIndicator()
                              : controller.jabatanList.isEmpty
                              ? const Center(
                            child: Text(
                              'Tidak ada data jabatan tersedia',
                            ),
                          )
                              : DropdownButtonFormField<String>(
                            isExpanded: true,
                            value:
                            controller
                                .selectedJabatanName
                                .value
                                .isNotEmpty
                                ? controller
                                .selectedJabatanName
                                .value
                                : null,
                            hint: Text(
                              '-- Pilih Jabatan --',
                              style: TextStyle(color: dropdownLight),
                            ),
                            icon: const Icon(Icons.expand_more),
                            iconEnabledColor: dropdownLight,
                            style: TextStyle(color: dropdownLight),
                            decoration: const InputDecoration(
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: Color(0xFFCCCCCC),
                                  width: 0.5,
                                ),
                              ),
                            ),
                            items:
                            controller.jabatanList.map((jabatan) {
                              return DropdownMenuItem<String>(
                                value: jabatan.kode,
                                child: Text(jabatan.name),
                              );
                            }).toList(),
                            onChanged: (value) {
                              controller.selectedJabatanName.value =
                                  value ?? '';
                            },
                            validator:
                                (value) =>
                            value == null || value.isEmpty
                                ? 'Harap Pilih Jabatan'
                                : null,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildFieldLabel('Nama PIC'),
                        TextFormField(
                          controller: controller.mainPersonNameController,
                          maxLength: 50,
                          decoration: const InputDecoration(
                            hintText: 'Masukkan nama PIC',
                            counterText: null,
                            enabledBorder: UnderlineInputBorder(),
                          ),
                          keyboardType: TextInputType.text,
                          inputFormatters: [
                            FilteringTextInputFormatter.deny(RegExp(r'[0-9]')),
                          ],
                          validator:
                              (v) =>
                          (v == null || v.isEmpty)
                              ? 'Nama wajib diisi'
                              : null,
                        ),
                        const SizedBox(height: 12),
                        _buildFieldLabel('No Telpon PIC'),
                        TextFormField(
                          controller: controller.mainPersonPhoneController,
                          decoration: const InputDecoration(
                            hintText: 'Masukkan no. telepon',
                            enabledBorder: UnderlineInputBorder(),
                          ),
                          keyboardType: TextInputType.phone,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          validator: (phone) {
                            if (phone == null || phone.isEmpty)
                              return 'Nomor telepon wajib diisi';
                            if (phone.length < 6)
                              return 'Nomor telepon tidak valid';
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        Align(
                          alignment: Alignment.center,
                          child: OutlinedButton(
                            onPressed: () {
                              Get.snackbar(
                                'Info',
                                'Fitur tambah main person akan segera tersedia',
                              );
                            },
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: textButton),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(
                              'Tambahkan',
                              style: TextStyle(color: textButton, fontSize: 16),
                            ),
                          ),
                        ),
                        // Menampilkan daftar main persons
                        if (controller.mainPersons.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          Text(
                            'Main Persons:',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Obx(
                                () => Column(
                              children:
                              controller.mainPersons.map((person) {
                                return ListTile(
                                  title: Text(
                                    'Nama: ${person['nama'] ?? ''}',
                                  ),
                                  subtitle: Text(
                                    'Jabatan: ${person['jabatan'] ?? ''}\nTelp: ${person['telp'] ?? ''}',
                                  ),
                                  trailing: IconButton(
                                    icon: Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                    ),
                                    onPressed: () {
                                      controller.mainPersons.remove(person);
                                    },
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Submit Button
                Obx(
                      () => ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: headerBlue,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      textStyle: const TextStyle(fontSize: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed:
                    controller.isLoading.value
                        ? null
                        : () async {
                      if (controller.formKey.currentState!.validate()) {
                        try {
                          final updatedData = Visit(
                            id: initialData.id,
                            jabatanSaya:
                            controller.getSelectedJabatanCode(),
                            areaCode: controller.getSelectedAreaCode(),
                            branchCode:
                            controller
                                .selectedBranchName
                                .value
                                .isNotEmpty
                                ? controller
                                .selectedBranchName
                                .value
                                : controller.cabangController.text,
                            productCode:
                            controller
                                .selectedProductName
                                .value
                                .isNotEmpty
                                ? controller
                                .selectedProductName
                                .value
                                : controller.produkController.text,
                            dealerCode:
                            controller.dealerController.text,
                            tipeVisit:
                            controller
                                .selectedTypeName
                                .value
                                .isNotEmpty
                                ? controller.selectedTypeName.value
                                : controller
                                .tipeVisitController
                                .text,
                            tujuanVisit:
                            controller
                                .selectedPurposeName
                                .value
                                .isNotEmpty
                                ? controller
                                .selectedPurposeName
                                .value
                                : controller
                                .tujuanVisitController
                                .text,
                            dariTanggal: selectedDariTanggal.value,
                            sampaiTanggal: selectedSampaiTanggal.value,
                            tanggalSelesai:
                            selectedTanggalSelesai.value,
                            namaPic: controller.picController.text,
                            themeOfDiscussion:
                            controller.discussionController.text,
                            problem: controller.problemController.text,
                            followUp:
                            controller.followUpController.text,
                            description:
                            controller.pelaksanaanController.text,
                            photo1:
                            selectedPhoto1.value != null
                                ? selectedPhoto1.value!.path
                                : initialData.photo1,
                            photo2:
                            selectedPhoto2.value != null
                                ? selectedPhoto2.value!.path
                                : initialData.photo2,
                            latitude: initialData.latitude,
                            longitude: initialData.longitude,
                            mainPersons:
                            controller.mainPersons.toList(),
                          );

                          print(
                            'Data yang akan disimpan: ${updatedData.toJson()}',
                          );

                          await controller.saveEditedData(
                            updatedData.toJson(),
                            selectedPhoto1.value,
                            selectedPhoto2.value,
                          );

                          Get.snackbar(
                            'Sukses',
                            'Data berhasil diperbarui',
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: Colors.green,
                            colorText: Colors.white,
                          );

                          Get.back();
                        } catch (e) {
                          print('Error menyimpan data: $e');
                          Get.snackbar(
                            'Error',
                            'Gagal menyimpan data: $e',
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: Colors.red,
                            colorText: Colors.white,
                          );
                        }
                      } else {
                        Get.snackbar(
                          'Peringatan',
                          'Harap lengkapi semua field wajib',
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: Colors.orange,
                          colorText: Colors.white,
                        );
                      }
                    },
                    child:
                    controller.isLoading.value
                        ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.white,
                        ),
                        strokeWidth: 2,
                      ),
                    )
                        : const Text(
                      'Save',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImageSlide(Rx<File?> selectedPhoto, String? initialPhoto, String label, int index) {
    return Obx(() => Container(
      width: double.infinity,
      height: 200,
      child: selectedPhoto.value != null
          ? Image.file(
        selectedPhoto.value!,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          print('Error memuat gambar $label: $error');
          return Container(
            color: Colors.grey[300],
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.image_not_supported,
                    size: 50,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Gambar tidak dapat dimuat',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
          );
        },
      )
          : (initialPhoto != null && initialPhoto.isNotEmpty)
          ? Image.network(
        'http://10.0.2.2:8000/storage/$initialPhoto',
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          print('Error memuat gambar $label: $error');
          return Container(
            color: Colors.grey[300],
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.image_not_supported,
                    size: 50,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Gambar tidak dapat dimuat',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
          );
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            color: Colors.grey[200],
            child: Center(
              child: CircularProgressIndicator(),
            ),
          );
        },
      )
          : Container(
        color: Colors.grey[300],
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.image_not_supported,
                size: 50,
                color: Colors.grey,
              ),
              SizedBox(height: 8),
              Text(
                'Tidak ada gambar tersedia',
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    ));
  }

  Widget _buildPageIndicator(int index, int currentIndex) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: currentIndex == index
            ? Colors.blue
            : Colors.white.withOpacity(0.5),
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Color(0xFF272728),
        ),
      ),
    );
  }

  Widget _buildDateField(
      DateTime? selectedDate,
      VoidCallback onTap,
      String fieldName,
      ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color:
              selectedDate != null
                  ? const Color(0xFFAFA1CF)
                  : const Color(0xFFCCCCCC),
              width: selectedDate != null ? 2.0 : 0.5,
            ),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                selectedDate != null
                    ? DateFormat('dd MMM yyyy').format(selectedDate)
                    : '-- Pilih $fieldName --',
                style: TextStyle(
                  color:
                  selectedDate != null
                      ? const Color(0xFF272728)
                      : const Color(0xFFCCCCCC),
                  fontSize: 16,
                ),
              ),
            ),
            const Icon(Icons.calendar_today, color: Color(0xFF272728)),
          ],
        ),
      ),
    );
  }
}
