import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:sufi_one/app/modules/smile/feature/smilehome/controllers/history_edit_controller.dart';
import 'package:sufi_one/app/modules/smile/models/area.dart';
import 'package:sufi_one/app/modules/smile/models/purpose.dart';
import 'package:sufi_one/app/modules/smile/models/visit.dart';

class HistoryEdit extends GetView<HistoryEditController> {
  const HistoryEdit({super.key});

  @override
  Widget build(BuildContext context) {
    // Inisialisasi data dari Get.arguments
    final Visit initialData = Visit.fromJson(Get.arguments as Map<String, dynamic>);
    final matchedJabatanSFI = controller.jabatanSFIList.firstWhereOrNull((j) => j.name == initialData.jabatanSaya);
    if (matchedJabatanSFI != null) {
      controller.selectedJabatanSFIName.value = matchedJabatanSFI.kode;
      print('Initialized jabatan: ${matchedJabatanSFI.kode} - ${matchedJabatanSFI.name}');
    } else {
      print('No matching jabatan for kode: ${initialData.jabatanSaya}');
    }
    final matchedArea = controller.areaList.firstWhereOrNull((a) => a.code == initialData.areaCode);
    if (matchedArea != null) {
      controller.selectedAreaName.value = matchedArea.code;
      print('Initialized area: ${matchedArea.code} - ${matchedArea.name}');
    } else {
      print('No matching area for code: ${initialData.areaCode}');
    }
    final matchedBranch = controller.branchList.firstWhereOrNull((a) => a.code == initialData.branchCode);
    if (matchedBranch != null) {
      controller.selectedBranchName.value = matchedBranch.code;
      print('Initialized branch: ${matchedBranch.code} - ${matchedBranch.name}');
    } else {
      print('No matching branch for code: ${initialData.branchCode}');
    }
    final matchedProduct = controller.productList.firstWhereOrNull((a) => a.code == initialData.productCode);
    if (matchedProduct != null) {
      controller.selectedProductName.value = matchedProduct.code;
      print('Initialized product: ${matchedProduct.code} - ${matchedProduct.name}');
    } else {
      print('No matching product for code: ${initialData.productCode}');
    }
    final matchedType = controller.typeList.firstWhereOrNull((t) => t.kode == initialData.tipeVisit);
    if (matchedType != null) {
      controller.selectedTypeName.value = matchedType.kode;
      print('Initialized type: ${matchedType.kode} - ${matchedType.name}');
    } else {
      print('No matching type for code: ${initialData.tipeVisit}');
    }
    final matchedPurpose = controller.purposeList.firstWhereOrNull((p) => p.kode == initialData.tujuanVisit);
    if (matchedPurpose != null) {
      controller.selectedPurposeName.value = matchedPurpose.kode;
      print('Initialized purpose: ${matchedPurpose.kode} - ${matchedPurpose.name}');
    } else {
      print('No matching purpose for code: ${initialData.tujuanVisit}');
    }

    // Inisialisasi TextEditingController di controller
    controller.initializeControllers(initialData);

    // State untuk tanggal
    final Rx<DateTime?> selectedDariTanggal = Rx<DateTime?>(initialData.dariTanggal);
    final Rx<DateTime?> selectedSampaiTanggal = Rx<DateTime?>(initialData.sampaiTanggal);
    final Rx<DateTime?> selectedTanggalSelesai = Rx<DateTime?>(initialData.tanggalSelesai);

    // Fungsi untuk memilih tanggal
    Future<void> selectDate(BuildContext context, String fieldType, Rx<DateTime?> selectedDate) async {
      DateTime initialDate = DateTime.now();
      DateTime firstDate = DateTime(2000);
      DateTime lastDate = DateTime(2100);

      switch (fieldType) {
        case 'dariTanggal':
          initialDate = selectedDariTanggal.value ?? DateTime.now();
          lastDate = DateTime.now();
          break;
        case 'sampaiTanggal':
          initialDate = selectedSampaiTanggal.value ?? (selectedDariTanggal.value ?? DateTime.now());
          firstDate = selectedDariTanggal.value ?? DateTime(2000);
          break;
        case 'tanggalSelesai':
          initialDate = selectedTanggalSelesai.value ?? (selectedDariTanggal.value ?? DateTime.now());
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
        } else if (fieldType == 'sampaiTanggal' && selectedDariTanggal.value != null && picked.isBefore(selectedDariTanggal.value!)) {
          isValid = false;
          errorMessage = 'Sampai Tanggal harus setelah atau sama dengan Dari Tanggal';
        } else if (fieldType == 'tanggalSelesai') {
          if (selectedDariTanggal.value != null && picked.isBefore(selectedDariTanggal.value!)) {
            isValid = false;
            errorMessage = 'Tanggal Selesai harus setelah atau sama dengan Dari Tanggal';
          } else if (selectedSampaiTanggal.value != null && picked.isAfter(selectedSampaiTanggal.value!)) {
            isValid = false;
            errorMessage = 'Tanggal Selesai harus sebelum atau sama dengan Sampai Tanggal';
          }
        }

        if (isValid) {
          selectedDate.value = picked;
          switch (fieldType) {
            case 'dariTanggal':
              controller.dariTanggalController.text = DateFormat('dd MMM yyyy').format(picked);
              if (selectedSampaiTanggal.value != null && selectedSampaiTanggal.value!.isBefore(picked)) {
                selectedSampaiTanggal.value = null;
                controller.sampaiTanggalController.text = '';
              }
              if (selectedTanggalSelesai.value != null && selectedTanggalSelesai.value!.isBefore(picked)) {
                selectedTanggalSelesai.value = null;
                controller.tanggalSelesaiController.text = '';
              }
              break;
            case 'sampaiTanggal':
              controller.sampaiTanggalController.text = DateFormat('dd MMM yyyy').format(picked);
              if (selectedTanggalSelesai.value != null && selectedTanggalSelesai.value!.isAfter(picked)) {
                selectedTanggalSelesai.value = null;
                controller.tanggalSelesaiController.text = '';
              }
              break;
            case 'tanggalSelesai':
              controller.tanggalSelesaiController.text = DateFormat('dd MMM yyyy').format(picked);
              break;
          }
        } else {
          Get.snackbar('Error', errorMessage ?? 'Tanggal tidak valid', snackPosition: SnackPosition.BOTTOM);
        }
      }
    }

    return WillPopScope(
      onWillPop: () async {
        print('Tombol Back perangkat ditekan');
        return true;
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),
        appBar: AppBar(
          backgroundColor: const Color(0xFF1A28C4),
          title: const Text(
            'Edit Visit Dealer',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              print('Tombol Back diklik');
              if (Get.isDialogOpen == true || Get.isBottomSheetOpen == true) {
                Get.back();
              } else if (Navigator.of(context).canPop()) {
                Navigator.of(context).pop();
              } else {
                Get.back();
                Get.snackbar('Peringatan', 'Tidak dapat kembali: Tidak ada halaman sebelumnya',
                    snackPosition: SnackPosition.BOTTOM);
              }
            },
          ),
          actions: [
            Obx(() => IconButton(
              icon: controller.isLoading.value
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Icon(Icons.save, color: Colors.white),
              onPressed: controller.isLoading.value
                  ? null
                  : () {
                print('Tombol Simpan diklik');
                print('Status isLoading: ${controller.isLoading.value}');
                if (controller.formKey.currentState!.validate()) {
                  print('Form valid, menyimpan data...');
                  try {
                    final updatedData = Visit(
                      jabatanSaya: controller.getSelectedJabatanCode(),
                      areaCode: controller.getSelectedAreaCode(),
                      branchCode: controller.cabangController.text,
                      productCode: controller.produkController.text,
                      tipeVisit: controller.tipeVisitController.text,
                      tujuanVisit: controller.tujuanVisitController.text,
                      dariTanggal: selectedDariTanggal.value,
                      sampaiTanggal: selectedSampaiTanggal.value,
                      tanggalSelesai: selectedTanggalSelesai.value,
                      namaPic: controller.picController.text,
                      themeOfDiscussion: controller.discussionController.text,
                      problem: controller.problemController.text,
                      description: controller.pelaksanaanController.text,
                      photo1: initialData.photo1,
                      latitude: initialData.latitude,
                      longitude: initialData.longitude,
                    );
                    print('Data yang akan disimpan: ${updatedData.toJson()}');
                    controller.saveEditedData(updatedData.toJson()).then((_) {
                      Get.snackbar('Sukses', 'Data berhasil disimpan',
                          snackPosition: SnackPosition.BOTTOM);
                      Get.back();
                    }).catchError((e) {
                      print('Error menyimpan data: $e');
                      Get.snackbar('Error', 'Gagal menyimpan data: $e',
                          snackPosition: SnackPosition.BOTTOM);
                    });
                  } catch (e) {
                    print('Error parsing data: $e');
                    Get.snackbar('Error', 'Gagal memproses data: $e',
                        snackPosition: SnackPosition.BOTTOM);
                  }
                } else {
                  print('Validasi form gagal');
                  Get.snackbar('Peringatan', 'Harap lengkapi semua field wajib',
                      snackPosition: SnackPosition.BOTTOM);
                }
              },
            )),
          ],
        ),
        body: Form(
          key: controller.formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  height: 200,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: initialData.photo1 != null && initialData.photo1!.isNotEmpty
                          ? NetworkImage(initialData.photo1!)
                          : const AssetImage('res/images/baleno.jpg') as ImageProvider,
                      fit: BoxFit.cover,
                      onError: (exception, stackTrace) {
                        print('Error memuat gambar: $exception\nStackTrace: $stackTrace');
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Data Dealer',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Jabatan',
                  style: TextStyle(fontSize: 14, color: Colors.black54),
                ),
                const SizedBox(height: 4),
                Obx(() => controller.isLoadingJabatanSFI.value
                    ? const Center(child: CircularProgressIndicator())
                    : controller.jabatanSFIList.isEmpty
                    ? const Center(child: Text('Tidak ada data jabatan tersedia'))
                    : DropdownButtonFormField<String>(
                  isExpanded: true,
                  value: controller.selectedJabatanSFIName.value.isNotEmpty
                      ? controller.selectedJabatanSFIName.value
                      : null,
                  hint: const Text('-- Pilih Jabatan --'),
                  items: controller.jabatanSFIList.map((jabatan) {
                    return DropdownMenuItem<String>(
                      value: jabatan.kode,
                      child: Text(jabatan.name),
                    );
                  }).toList(),
                  onChanged: (value) {
                    controller.selectedJabatanSFIName.value = value ?? '';
                  },
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                  ),
                  validator: (value) => value == null || value.isEmpty ? 'Harap pilih jabatan' : null,
                )),

                const SizedBox(height: 8),
                const Text(
                  'Area',
                  style: TextStyle(fontSize: 14, color: Colors.black54),
                ),
                const SizedBox(height: 4),
                Obx(() => controller.isLoadingArea.value
                    ? const Center(child: CircularProgressIndicator())
                    : controller.areaList.isEmpty
                    ? const Center(child: Text('Tidak ada data area tersedia'))
                    : DropdownButtonFormField<String>(
                  isExpanded: true,
                  value: controller.selectedAreaName.value.isNotEmpty
                      ? controller.selectedAreaName.value
                      : null,
                  hint: const Text('-- Pilih Area --'),
                  items: controller.areaList.map((area) {
                    return DropdownMenuItem<String>(
                      value: area.code,
                      child: Text(area.name),
                    );
                  }).toList(),
                  onChanged: (value) {
                    controller.selectedAreaName.value = value ?? '';
                  },
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                  ),
                  validator: (value) => value == null || value.isEmpty ? 'Harap pilih area' : null,
                )),

                const SizedBox(height: 8),
                const Text(
                  'Cabang',
                  style: TextStyle(fontSize: 14, color: Colors.black54),
                ),
                const SizedBox(height: 4),
                Obx(() => controller.isLoadingBranch.value
                    ? const Center(child: CircularProgressIndicator())
                    : controller.branchList.isEmpty
                    ? const Center(child: Text('Tidak ada data cabang tersedia'))
                    : DropdownButtonFormField<String>(
                  isExpanded: true,
                  value: controller.selectedBranchName.value.isNotEmpty
                      ? controller.selectedBranchName.value
                      : null,
                  hint: const Text('-- Pilih Cabang --'),
                  items: controller.branchList.map((branch) {
                    return DropdownMenuItem<String>(
                      value: branch.code,
                      child: Text(branch.name),
                    );
                  }).toList(),
                  onChanged: (value) {
                    controller.selectedBranchName.value = value ?? '';
                  },
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                  ),
                  validator: (value) => value == null || value.isEmpty ? 'Harap pilih cabang' : null,
                )),

                const SizedBox(height: 8),
                const Text(
                  'Produk',
                  style: TextStyle(fontSize: 14, color: Colors.black54),
                ),
                const SizedBox(height: 4),
                Obx(() => controller.isLoadingProduct.value
                    ? const Center(child: CircularProgressIndicator())
                    : controller.productList.isEmpty
                    ? const Center(child: Text('Tidak ada data Product tersedia'))
                    : DropdownButtonFormField<String>(
                  isExpanded: true,
                  value: controller.selectedProductName.value.isNotEmpty
                      ? controller.selectedProductName.value
                      : null,
                  hint: const Text('-- Pilih Product --'),
                  items: controller.productList.map((product) {
                    return DropdownMenuItem<String>(
                      value: product.code,
                      child: Text(product.name),
                    );
                  }).toList(),
                  onChanged: (value) {
                    controller.selectedProductName.value = value ?? '';
                  },
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                  ),
                  validator: (value) => value == null || value.isEmpty ? 'Harap pilih Product' : null,
                )),

                const SizedBox(height: 16),
                const Text(
                  'Data Visit',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Tipe Visit',
                  style: TextStyle(fontSize: 14, color: Colors.black54),
                ),
                const SizedBox(height: 4),
                Obx(() => controller.isLoadingType.value
                    ? const Center(child: CircularProgressIndicator())
                    : controller.typeList.isEmpty
                    ? const Center(child: Text('Tidak ada data Type tersedia'))
                    : DropdownButtonFormField<String>(
                  isExpanded: true,
                  value: controller.selectedTypeName.value.isNotEmpty
                      ? controller.selectedTypeName.value
                      : null,
                  hint: const Text('-- Pilih Tipe --'),
                  items: controller.typeList.map((type) {
                    return DropdownMenuItem<String>(
                      value: type.kode,
                      child: Text(type.name),
                    );
                  }).toList(),
                  onChanged: (value) {
                    controller.selectedTypeName.value = value ?? '';
                  },
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                  ),
                  validator: (value) => value == null || value.isEmpty ? 'Harap pilih Tipe' : null,
                )),

                const SizedBox(height: 8),
                const Text(
                  'Tujuan Visit',
                  style: TextStyle(fontSize: 14, color: Colors.black54),
                ),
                const SizedBox(height: 4),
                Obx(() => controller.isLoadingPurpose.value
                    ? const Center(child: CircularProgressIndicator())
                    : controller.purposeList.isEmpty
                    ? const Center(child: Text('Tidak ada data Purpose tersedia'))
                    : DropdownButtonFormField<String>(
                  isExpanded: true,
                  value: controller.selectedPurposeName.value.isNotEmpty
                      ? controller.selectedPurposeName.value
                      : null,
                  hint: const Text('-- Pilih Tujuan --'),
                  items: controller.purposeList.map((purpose) {
                    return DropdownMenuItem<String>(
                      value: purpose.kode,
                      child: Text(purpose.name),
                    );
                  }).toList(),
                  onChanged: (value) {
                    controller.selectedPurposeName.value = value ?? '';
                  },
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                  ),
                  validator: (value) => value == null || value.isEmpty ? 'Harap pilih Tujuan' : null,
                )),

                _buildTextField(
                  'Dari Tanggal',
                  controller.dariTanggalController,
                  readOnly: true,
                  onTap: () => selectDate(context, 'dariTanggal', selectedDariTanggal),
                  validator: (value) => selectedDariTanggal.value == null ? 'Dari Tanggal wajib diisi' : null,
                ),
                _buildTextField(
                  'Sampai Tanggal',
                  controller.sampaiTanggalController,
                  readOnly: true,
                  onTap: () => selectDate(context, 'sampaiTanggal', selectedSampaiTanggal),
                  validator: (value) => selectedSampaiTanggal.value == null ? 'Sampai Tanggal wajib diisi' : null,
                ),
                _buildTextField(
                  'Tanggal Selesai',
                  controller.tanggalSelesaiController,
                  readOnly: true,
                  onTap: () => selectDate(context, 'tanggalSelesai', selectedTanggalSelesai),
                  validator: (value) => selectedTanggalSelesai.value == null ? 'Tanggal Selesai wajib diisi' : null,
                ),
                _buildTextField('Nama PIC', controller.picController, readOnly: false),
                _buildTextField('Area Code', controller.areaController, readOnly: false), // Perbaikan dari picController
                _buildTextField('Theme Discussion', controller.discussionController, readOnly: false),
                _buildTextField('Problem', controller.problemController, readOnly: false),
                _buildTextField('Keterangan Pelaksanaan', controller.pelaksanaanController, readOnly: false),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
      String label,
      TextEditingController controller, {
        bool readOnly = false,
        VoidCallback? onTap,
        String? Function(String?)? validator,
      }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.black54, fontSize: 14),
          ),
          const SizedBox(height: 4),
          TextFormField(
            controller: controller,
            readOnly: readOnly,
            onTap: onTap,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.grey[100],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              suffixIcon: readOnly ? const Icon(Icons.calendar_today, size: 20) : null,
            ),
            validator: validator ?? (value) => (value == null || value.isEmpty) ? 'Field tidak boleh kosong' : null,
          ),
        ],
      ),
    );
  }
}