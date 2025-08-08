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

  // Fungsi pembantu untuk menampilkan gambar (dari File atau URL)
  Widget _buildImageDisplay(File? selectedFile, String? initialUrl) {
    final String baseUrl = 'http://10.0.2.2:8000/storage/';
    Widget imageWidget;

    if (selectedFile != null) {
      imageWidget = Image.file(selectedFile, fit: BoxFit.cover);
    } else if (initialUrl != null && initialUrl.isNotEmpty) {
      imageWidget = Image.network(
        '$baseUrl$initialUrl',
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          print('Error memuat gambar: $error');
          return Container(
            color: Colors.grey[300],
            child: const Center(
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
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          );
        },
      );
    } else {
      imageWidget = Container(
        color: Colors.grey[300],
        child: const Center(
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
      );
    }

    return Container(
      width: double.infinity,
      height: 200,
      margin: const EdgeInsets.only(bottom: 16),
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
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: imageWidget,
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
              color: selectedDate != null
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
                  color: selectedDate != null
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

  @override
  Widget build(BuildContext context) {
    // Inisialisasi data dari Get.arguments
    final Visit initialData = Visit.fromJson(
      Get.arguments as Map<String, dynamic>,
    );

    // Inisialisasi TextEditingController dan Rx variables di controller
    controller.initializeControllers(initialData);

    // Inisialisasi state untuk file gambar
    // Menggunakan Rx<File?> dari controller agar bisa diobservasi
    final Rx<File?> selectedPhoto1 = controller.selectedPhoto1;
    final Rx<File?> selectedPhoto2 = controller.selectedPhoto2;

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
    Future<void> pickImage(Rx<File?> selectedPhoto) async {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        selectedPhoto.value = File(pickedFile.path);
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
                // Card Data Gambar
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
                        // Slider untuk gambar
                        Obx(() {
                          List<Widget> imageWidgets = [];

                          // Tambahkan photo1 jika tersedia
                          if (selectedPhoto1.value != null ||
                              (initialData.photo1 != null &&
                                  initialData.photo1!.isNotEmpty)) {
                            imageWidgets.add(
                                _buildImageDisplay(selectedPhoto1.value, initialData.photo1));
                          }

                          // Tambahkan photo2 jika tersedia
                          if (selectedPhoto2.value != null ||
                              (initialData.photo2 != null &&
                                  initialData.photo2!.isNotEmpty)) {
                            imageWidgets.add(
                                _buildImageDisplay(selectedPhoto2.value, initialData.photo2));
                          }

                          if (imageWidgets.isEmpty) {
                            return Container(
                              width: double.infinity,
                              height: 200,
                              margin: const EdgeInsets.only(bottom: 16),
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
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
                              child: const Center(
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
                            );
                          } else {
                            return SizedBox(
                              height: 200,
                              child: PageView(
                                children: imageWidgets,
                              ),
                            );
                          }
                        }),
                        // Tombol pilih gambar 1
                        _buildFieldLabel('Gambar 1'),
                        ElevatedButton(
                          onPressed: () => pickImage(selectedPhoto1),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                          ),
                          child: const Text('Pilih Gambar 1'),
                        ),
                        const SizedBox(height: 16),
                        // Tombol pilih gambar 2
                        _buildFieldLabel('Gambar 2'),
                        ElevatedButton(
                          onPressed: () => pickImage(selectedPhoto2),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                          ),
                          child: const Text('Pilih Gambar 2'),
                        ),
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
                              () => controller.isLoadingJabatanSFI.value
                              ? const CircularProgressIndicator()
                              : controller.jabatanSFIList.isEmpty
                              ? const Center(
                            child: Text(
                              'Tidak ada data jabatan tersedia',
                            ),
                          )
                              : DropdownButtonFormField<String>(
                            isExpanded: true,
                            value: controller
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
                                  color: Color(0xFFCCCCCC),
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
                            items: controller.jabatanSFIList.map(
                                  (jabatan) {
                                return DropdownMenuItem<String>(
                                  value: jabatan.kode,
                                  child: Text(jabatan.name),
                                );
                              },
                            ).toList(),
                            onChanged: (value) {
                              controller.selectedJabatanSFIName.value =
                                  value ?? '';
                            },
                            validator: (value) =>
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
                              () => controller.isLoadingArea.value
                              ? const CircularProgressIndicator()
                              : controller.areaList.isEmpty
                              ? const Center(
                            child: Text('Tidak ada data area tersedia'),
                          )
                              : DropdownButtonFormField<String>(
                            isExpanded: true,
                            value: controller
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
                            items: controller.areaList.map((area) {
                              return DropdownMenuItem<String>(
                                value: area.code,
                                child: Text(area.name),
                              );
                            }).toList(),
                            onChanged: (value) {
                              controller.selectedAreaName.value =
                                  value ?? '';
                            },
                            validator: (value) =>
                            value == null || value.isEmpty
                                ? 'Harap pilih area'
                                : null,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildFieldLabel('Cabang'),
                        Obx(
                              () => controller.isLoadingBranch.value
                              ? const CircularProgressIndicator()
                              : controller.branchList.isEmpty
                              ? const Center(
                            child: Text(
                              'Tidak ada data cabang tersedia',
                            ),
                          )
                              : DropdownButtonFormField<String>(
                            isExpanded: true,
                            value: controller
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
                            items: controller.branchList.map((branch) {
                              return DropdownMenuItem<String>(
                                value: branch.code,
                                child: Text(branch.name),
                              );
                            }).toList(),
                            onChanged: (value) {
                              controller.selectedBranchName.value =
                                  value ?? '';
                            },
                            validator: (value) =>
                            value == null || value.isEmpty
                                ? 'Harap pilih cabang'
                                : null,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildFieldLabel('Produk'),
                        Obx(
                              () => controller.isLoadingProduct.value
                              ? const CircularProgressIndicator()
                              : controller.productList.isEmpty
                              ? const Center(
                            child: Text(
                              'Tidak ada data Product tersedia',
                            ),
                          )
                              : DropdownButtonFormField<String>(
                            isExpanded: true,
                            value: controller
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
                            items: controller.productList.map((product) {
                              return DropdownMenuItem<String>(
                                value: product.code,
                                child: Text(product.name),
                              );
                            }).toList(),
                            onChanged: (value) {
                              controller.selectedProductName.value =
                                  value ?? '';
                            },
                            validator: (value) =>
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
                              () => controller.isLoadingType.value
                              ? const CircularProgressIndicator()
                              : controller.typeList.isEmpty
                              ? const Center(
                            child: Text('Tidak ada data Type tersedia'),
                          )
                              : DropdownButtonFormField<String>(
                            isExpanded: true,
                            value: controller
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
                            items: controller.typeList.map((type) {
                              return DropdownMenuItem<String>(
                                value: type.kode,
                                child: Text(type.name),
                              );
                            }).toList(),
                            onChanged: (value) {
                              controller.selectedTypeName.value =
                                  value ?? '';
                            },
                            validator: (value) =>
                            value == null || value.isEmpty
                                ? 'Harap Pilih Tipe Visit'
                                : null,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildFieldLabel('Tujuan Visit'),
                        Obx(
                              () => controller.isLoadingPurpose.value
                              ? const CircularProgressIndicator()
                              : controller.purposeList.isEmpty
                              ? const Center(
                            child: Text(
                              'Tidak ada data Purpose tersedia',
                            ),
                          )
                              : DropdownButtonFormField<String>(
                            isExpanded: true,
                            value: controller
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
                            items: controller.purposeList.map((purpose) {
                              return DropdownMenuItem<String>(
                                value: purpose.kode,
                                child: Text(purpose.name),
                              );
                            }).toList(),
                            onChanged: (value) {
                              controller.selectedPurposeName.value =
                                  value ?? '';
                            },
                            validator: (value) =>
                            value == null || value.isEmpty
                                ? 'Harap Pilih Tujuan Visit'
                                : null,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildFieldLabel('Dari Tanggal'),
                        Obx(
                              () => _buildDateField(
                            controller.selectedDariTanggal.value,
                                () => controller.selectDate(
                              context,
                              'dariTanggal',
                            ),
                            'dariTanggal',
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildFieldLabel('Sampai Tanggal'),
                        Obx(
                              () => _buildDateField(
                            controller.selectedSampaiTanggal.value,
                                () => controller.selectDate(
                              context,
                              'sampaiTanggal',
                            ),
                            'sampaiTanggal',
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildFieldLabel('Tanggal Selesai'),
                        Obx(
                              () => _buildDateField(
                            controller.selectedTanggalSelesai.value,
                                () => controller.selectDate(
                              context,
                              'tanggalSelesai',
                            ),
                            'tanggalSelesai',
                          ),
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
                          validator: (v) =>
                          v == null || v.isEmpty ? 'Nama PIC wajib diisi' : null,
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
                          validator: (v) =>
                          v == null || v.isEmpty ? 'Tema diskusi wajib diisi' : null,
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
                          validator: (v) =>
                          v == null || v.isEmpty ? 'Problem wajib diisi' : null,
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
                          validator: (v) =>
                          v == null || v.isEmpty ? 'Follow-Up wajib diisi' : null,
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
                          validator: (v) =>
                          v == null || v.isEmpty ? 'Deskripsi wajib diisi' : null,
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
                        Form(
                          key: controller.mainPersonFormKey, // Use controller's key
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildFieldLabel('Jabatan'),
                              Obx(
                                    () => controller.isLoadingJabatan.value
                                    ? const CircularProgressIndicator()
                                    : controller.jabatanList.isEmpty
                                    ? const Center(
                                  child: Text(
                                    'Tidak ada data jabatan tersedia',
                                  ),
                                )
                                    : DropdownButtonFormField<String>(
                                  isExpanded: true,
                                  value: controller
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
                                  items: controller.jabatanList.map((jabatan) {
                                    return DropdownMenuItem<String>(
                                      value: jabatan.kode,
                                      child: Text(jabatan.name),
                                    );
                                  }).toList(),
                                  onChanged: (value) {
                                    controller.selectedJabatanName.value =
                                        value ?? '';
                                  },
                                  validator: (v) =>
                                  v == null ? 'Harap Pilih Jabatan' : null,
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
                                  FilteringTextInputFormatter.deny(
                                    RegExp(r'[0-9]'),
                                  ),
                                ],
                                // No setState needed here, as controller's text is already reactive
                                validator: (v) =>
                                (v == null || v.isEmpty) ? 'Nama wajib diisi' : null,
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
                                    // Add logic to add main person to controller.mainPersons
                                    if (controller.mainPersonFormKey.currentState!
                                        .validate()) {
                                      controller.mainPersons.add({
                                        'jabatan': controller.selectedJabatanName.value,
                                        'nama': controller.mainPersonNameController.text,
                                        'telp': controller.mainPersonPhoneController.text,
                                      });
                                      controller.selectedJabatanName.value =
                                      ''; // Clear dropdown
                                      controller.mainPersonNameController.clear();
                                      controller.mainPersonPhoneController.clear();
                                      Get.snackbar('Sukses', 'Main Person berhasil ditambahkan');
                                    }
                                  },
                                  style: OutlinedButton.styleFrom(
                                    side: BorderSide(color: textButton),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: Text(
                                    'Tambahkan',
                                    style: TextStyle(
                                      color: textButton,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Menampilkan daftar main persons
                        Obx(
                              () => Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (controller.mainPersons.isNotEmpty) ...[
                                const SizedBox(height: 16),
                                Text(
                                  'Daftar Main Persons:',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: headerBlue,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                GridView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: controller.mainPersons.length,
                                  gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    crossAxisSpacing: 12,
                                    mainAxisSpacing: 12,
                                    childAspectRatio: 3 / 3,
                                  ),
                                  itemBuilder: (context, i) {
                                    final pic = controller.mainPersons[i];
                                    return Card(
                                      color: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        side: BorderSide(color: textButton, width: 2),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(8),
                                        child: Column(
                                          crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                          children: [
                                            Expanded(
                                              child: SingleChildScrollView(
                                                physics:
                                                const BouncingScrollPhysics(),
                                                child: Column(
                                                  crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      pic['jabatan']!,
                                                      style: const TextStyle(
                                                        color: textButton,
                                                        fontSize: 14,
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 4),
                                                    Text(
                                                      'Nama: ${pic['nama']!}',
                                                      style: const TextStyle(
                                                        color: textButton,
                                                        fontSize: 14,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 4),
                                                    Text(
                                                      'Telp: ${pic['telp']!}',
                                                      style: const TextStyle(
                                                        color: textButton,
                                                        fontSize: 14,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            Align(
                                              alignment: Alignment.center,
                                              child: IconButton(
                                                icon: const Icon(
                                                  Icons.delete,
                                                  color: Colors.red,
                                                  size: 24,
                                                ),
                                                onPressed: () {
                                                  showDialog(
                                                    context: context,
                                                    builder: (context) => AlertDialog(
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius:
                                                        BorderRadius.circular(
                                                          12,
                                                        ),
                                                      ),
                                                      title: Text(
                                                        'Konfirmasi Hapus',
                                                        style: TextStyle(
                                                          color: headerBlue,
                                                          fontWeight:
                                                          FontWeight.bold,
                                                        ),
                                                      ),
                                                      content: Text(
                                                        'Apakah Anda yakin ingin menghapus ${pic['nama']} dari daftar PIC?',
                                                        style: const TextStyle(
                                                          color: textButton,
                                                        ),
                                                      ),
                                                      actions: [
                                                        TextButton(
                                                          onPressed: () =>
                                                              Navigator.pop(
                                                                context,
                                                              ),
                                                          child: Text(
                                                            'Batal',
                                                            style: TextStyle(
                                                              color: textButton,
                                                            ),
                                                          ),
                                                        ),
                                                        TextButton(
                                                          onPressed: () {
                                                            controller.mainPersons
                                                                .removeAt(i); // Use removeAt with index
                                                            Navigator.pop(
                                                              context,
                                                            );
                                                          },
                                                          child: const Text(
                                                            'Hapus',
                                                            style: TextStyle(
                                                              color: Colors.red,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  );
                                                },
                                                tooltip: 'Hapus PIC',
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ] else ...[
                                const SizedBox(height: 16),
                                Center(
                                  child: Text(
                                    'Tidak ada data main person',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Location Section
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: textButton),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  icon: const Icon(Icons.location_on, color: Colors.blue),
                  label: const Text(
                    'Ambil Lokasi',
                    style: TextStyle(color: Colors.blue, fontSize: 16),
                  ),
                  onPressed: () {
                    // This part needs to be handled by the controller or passed as a callback
                    // For now, it's a placeholder.
                    Get.snackbar('Info', 'Fitur ambil lokasi akan segera tersedia');
                  },
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.location_on, color: Colors.blue, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Informasi Lokasi',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: dropdownLight,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Latitude',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: dropdownLight,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  initialData.latitude != null
                                      ? initialData.latitude!.toStringAsFixed(6)
                                      : 'Belum diambil',
                                  style: TextStyle(
                                    color: initialData.latitude != null
                                        ? Colors.green.shade700
                                        : Colors.grey.shade600,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Longitude',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: dropdownLight,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  initialData.longitude != null
                                      ? initialData.longitude!.toStringAsFixed(6)
                                      : 'Belum diambil',
                                  style: TextStyle(
                                    color: initialData.longitude != null
                                        ? Colors.green.shade700
                                        : Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Divider(color: Colors.grey.shade300, thickness: 1),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Icon(Icons.flag, color: Colors.blue, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Status Visit',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: dropdownLight,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        isExpanded: true,
                        value: initialData.status == 0
                            ? 'Planning'
                            : 'Selesai', // Set initial value based on data
                        hint: Text(
                          '-- Pilih Status --',
                          style: TextStyle(color: dropdownLight),
                        ),
                        icon: const Icon(Icons.expand_more),
                        iconEnabledColor: dropdownLight,
                        style: const TextStyle(color: dropdownLight),
                        decoration: InputDecoration(
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: dropdownLightNF,
                              width: 1.0,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: dropdownLightF,
                              width: 2.0,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 16,
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        items: [
                          DropdownMenuItem<String>(
                            value: 'Planning',
                            child: Text('Planning', style: TextStyle(color: dropdownLight)),
                          ),
                          DropdownMenuItem<String>(
                            value: 'Selesai',
                            child: Text('Selesai', style: TextStyle(color: dropdownLight)),
                          ),
                        ],
                        onChanged: (val) {
                          // This needs to update the initialData or a separate RxString in controller
                          // For now, it's just a placeholder.
                          Get.snackbar('Info', 'Status changed to: $val');
                        },
                        validator: (v) => v == null ? 'Harap Pilih Status' : null,
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: initialData.status == 0
                              ? Colors.orange.shade50
                              : Colors.green.shade50,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: initialData.status == 0
                                ? Colors.orange.shade200
                                : Colors.green.shade200,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              initialData.status == 0
                                  ? Icons.schedule
                                  : Icons.check_circle,
                              size: 16,
                              color: initialData.status == 0
                                  ? Colors.orange.shade600
                                  : Colors.green.shade600,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              initialData.status == 0
                                  ? 'Status: Planning'
                                  : 'Status: Selesai',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: initialData.status == 0
                                    ? Colors.orange.shade700
                                    : Colors.green.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
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
                    onPressed: controller.isLoading.value
                        ? null
                        : () async {
                      if (controller.formKey.currentState!.validate()) {
                        try {
                          final updatedData = Visit(
                            id: initialData.id,
                            jabatanSaya: controller.getSelectedJabatanCode(),
                            areaCode: controller.getSelectedAreaCode(),
                            branchCode: controller.selectedBranchName.value.isNotEmpty
                                ? controller.selectedBranchName.value
                                : controller.cabangController.text,
                            productCode: controller.selectedProductName.value.isNotEmpty
                                ? controller.selectedProductName.value
                                : controller.produkController.text,
                            dealerCode: controller.dealerController.text,
                            tipeVisit: controller.selectedTypeName.value.isNotEmpty
                                ? controller.selectedTypeName.value
                                : controller.tipeVisitController.text,
                            tujuanVisit: controller.selectedPurposeName.value.isNotEmpty
                                ? controller.selectedPurposeName.value
                                : controller.tujuanVisitController.text,
                            dariTanggal: controller.selectedDariTanggal.value, // Use controller's Rx value
                            sampaiTanggal: controller.selectedSampaiTanggal.value, // Use controller's Rx value
                            tanggalSelesai: controller.selectedTanggalSelesai.value, // Use controller's Rx value
                            namaPic: controller.picController.text,
                            themeOfDiscussion: controller.discussionController.text,
                            problem: controller.problemController.text,
                            followUp: controller.followUpController.text,
                            description: controller.pelaksanaanController.text,
                            photo1: selectedPhoto1.value != null
                                ? selectedPhoto1.value!.path
                                : initialData.photo1,
                            photo2: selectedPhoto2.value != null
                                ? selectedPhoto2.value!.path
                                : initialData.photo2,
                            latitude: initialData.latitude, // Keep original latitude
                            longitude: initialData.longitude, // Keep original longitude
                            mainPersons: controller.mainPersons.toList(), // Use the RxList from controller
                            status: initialData.status, // Keep original status or update from UI
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
                    child: controller.isLoading.value
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
}
