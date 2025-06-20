import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sufi_one/app/modules/smile/feature/smilehome/controllers/task_edit_controller.dart';
import 'package:intl/intl.dart';
import '../../controllers/task_visit_controller.dart'; // Import for date formatting

class TaskEdit extends GetView<TaskEditController> {
  const TaskEdit({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(
          0xFF0048A7,
        ), // Ganti warna background ke #0048A7
        title: const Text(
          'Edit Task Visit Dealer',
          style: TextStyle(color: Colors.white), // Warna teks putih
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white), // Ikon putih
            onPressed: () {
              // Ambil data yang sudah diedit dari controller
              final updatedData = controller.editedData;

              // Panggil fungsi updateTaskVisit di TaskVisitController untuk memperbarui data di halaman utama
              Get.find<TaskVisitController>().updateTaskVisit(updatedData);

              // Setelah data disimpan, kembali ke halaman sebelumnya (TaskVisit)
              Get.back();
            }
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.save, color: Colors.white),
            onPressed: controller.saveEditedData,
          ),
        ],
      ),
      body: Form(
        key: controller.formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Obx(() {
            final data = controller.editedData;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  height: 200,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('res/images/car.jpg'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // --- Data Dealer Section ---
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment
                              .stretch, // Changed to stretch for centered text
                      children: [
                        Text(
                          'Data Dealer',
                          textAlign: TextAlign.center, // Centered text
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black, // Changed to black
                          ),
                        ),
                        const Divider(
                          thickness: 1,
                          color: Colors.grey,
                        ), // Horizontal line
                        _buildTextField('Jabatan Saya', 'jabatan', data),
                        _buildTextField('Area', 'area', data),
                        _buildTextField('Cabang', 'cabang', data),
                        _buildTextField('Produk', 'produk', data),
                      ],
                    ),
                  ),
                ),
                // --- Data Visit Section ---
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment
                              .stretch, // Changed to stretch for centered text
                      children: [
                        Text(
                          'Data Visit',
                          textAlign: TextAlign.center, // Centered text
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black, // Changed to black
                          ),
                        ),
                        const Divider(
                          thickness: 1,
                          color: Colors.grey,
                        ), // Horizontal line
                        _buildTextField('Tipe visit', 'type', data),
                        _buildTextField('Tujuan visit', 'activity', data),
                        // Menggunakan _buildDateTextField untuk field tanggal
                        _buildDateTextField('Dari tanggal', 'date_start', data),
                        _buildDateTextField(
                          'Sampai tanggal',
                          'date_finish',
                          data,
                        ),
                        _buildDateTextField(
                          'Tanggal selesai',
                          'date_finish_actual',
                          data,
                        ),
                        _buildTextField('Nama PIC', 'pic', data),
                        _buildTextField('Theme discussion', 'discussion', data),
                        _buildTextField('Problem', 'problem', data),
                        _buildTextField(
                          'Keterangan Pelaksanaan',
                          'pelakasanaan',
                          data,
                        ),
                        DropdownButtonFormField<String>(
                          value: controller.editedData['status'],
                          decoration: const InputDecoration(
                            labelText: 'Status',
                            border: OutlineInputBorder(),
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: 'Terlaksana',
                              child: Text('Terlaksana'),
                            ),
                            DropdownMenuItem(
                              value: 'Dibatalkan',
                              child: Text('Dibatalkan'),
                            ),
                          ],
                          onChanged: (value) {
                            if (value != null) {
                              controller.editedData['status'] = value;
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    String key,
    RxMap<String, dynamic> data,
  ) {
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
            initialValue: data[key] ?? '',
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.grey[100],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onChanged: (value) {
              data[key] = value;
            },
            validator: (value) {
              if (value?.isEmpty ?? true) {
                return 'Field cannot be empty';
              }
              return null;
            },
            onSaved: (newValue) {
              data[key] = newValue ?? '';
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDateTextField(
    String label,
    String key,
    RxMap<String, dynamic> data,
  ) {
    final TextEditingController dateController = TextEditingController(
      text: data[key] ?? '',
    );

    ever(data, (_) {
      if (dateController.text != (data[key] ?? '')) {
        dateController.text = data[key] ?? '';
      }
    });

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
            controller: dateController,
            readOnly: true,
            onTap: () async {
              DateTime? pickedDate = await controller.selectDate(Get.context!);
              if (pickedDate != null) {
                String formattedDate = DateFormat(
                  'yyyy-MM-dd',
                ).format(pickedDate);
                data[key] = formattedDate;
              }
            },
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.grey[100],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              suffixIcon: const Icon(Icons.calendar_today),
            ),
            validator: (value) {
              if (value?.isEmpty ?? true) {
                return 'Field cannot be empty';
              }
              return null;
            },
            onSaved: (newValue) {
              data[key] = newValue ?? '';
            },
          ),
        ],
      ),
    );
  }
}
