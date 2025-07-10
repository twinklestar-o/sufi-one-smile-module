import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../controllers/task_edit_controller.dart';
import '../../controllers/task_visit_controller.dart';
import '../../../../models/visit.dart';

class TaskEdit extends GetView<TaskEditController> {
  const TaskEdit({super.key});

  @override
  Widget build(BuildContext context) {
    final Visit visit = Get.arguments;
    controller.initializeData(visit);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0048A7),
        title: const Text('Edit Task Visit Dealer', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.save, color: Colors.white),
            onPressed: () {
              final Visit? updated = controller.saveEditedData();
              if (updated != null) {
                Get.back(result: updated);
              }
            },
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
                _buildSectionTitle('Data Dealer'),
                _buildTextField('Jabatan Saya', 'jabatanSaya', data),
                _buildTextField('Area', 'areaCode', data),
                _buildTextField('Cabang', 'branchCode', data),
                _buildTextField('Produk', 'productCode', data),
                _buildTextField('Dealer', 'dealerCode', data),
                const SizedBox(height: 16),
                _buildSectionTitle('Data Visit'),
                _buildTextField('Tipe visit', 'tipeVisit', data),
                _buildTextField('Tujuan visit', 'tujuanVisit', data),
                _buildDateTextField('Dari tanggal', 'dariTanggal', data),
                _buildDateTextField('Sampai tanggal', 'sampaiTanggal', data),
                _buildDateTextField('Tanggal selesai', 'tanggalSelesai', data),
                _buildTextField('Nama PIC', 'namaPic', data),
                _buildTextField('Theme discussion', 'themeOfDiscussion', data),
                _buildTextField('Problem', 'problem', data),
                _buildTextField('Follow Up', 'followUp', data),
                _buildTextField('Description', 'description', data),
                const SizedBox(height: 16),
                _buildSectionTitle('Status Kunjungan'),
                DropdownButtonFormField<String>(
                  value: data['status'],
                  decoration: const InputDecoration(
                    labelText: 'Status',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'Terlaksana', child: Text('Terlaksana')),
                    DropdownMenuItem(value: 'Dibatalkan', child: Text('Dibatalkan')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      data['status'] = value;
                    }
                  },
                ),
                const SizedBox(height: 16),
                _buildSectionTitle('Main Person'),
                _buildTextField('Jabatan PIC', 'mainJabatan', data),
                _buildTextField('Nama PIC', 'mainNamaPic', data),
                _buildTextField('Nomor Telepon PIC', 'mainNoTelp', data),
                _buildTextField('Lokasi PIC', 'mainLokasi', data),
              ],
            );
          }),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 12),
    child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
  );

  Widget _buildTextField(String label, String key, RxMap<String, dynamic> data) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.black54, fontSize: 14)),
        const SizedBox(height: 4),
        TextFormField(
          initialValue: data[key] ?? '',
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey[100],
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
          onChanged: (value) => data[key] = value,
          validator: (value) => (value?.isEmpty ?? true) ? 'Field cannot be empty' : null,
        ),
      ],
    ),
  );

  Widget _buildDateTextField(String label, String key, RxMap<String, dynamic> data) {
    final date = data[key] as DateTime?;
    final dateController = TextEditingController(
      text: date != null ? DateFormat('yyyy-MM-dd').format(date) : '',
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
          Text(label, style: const TextStyle(color: Colors.black54, fontSize: 14)),
          const SizedBox(height: 4),
          TextFormField(
            controller: dateController,
            readOnly: true,
            onTap: () async {
              DateTime? picked = await controller.selectDate(Get.context!, key);
              if (picked != null) {
                data[key] = picked;
              }
            },
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.grey[100],
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              suffixIcon: const Icon(Icons.calendar_today),
            ),
            validator: (value) => (value?.isEmpty ?? true) ? 'Field cannot be empty' : null,
          ),
        ],
      ),
    );
  }
}
