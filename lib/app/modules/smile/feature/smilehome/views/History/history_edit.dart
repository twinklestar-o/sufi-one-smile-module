import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sufi_one/app/modules/smile/feature/smilehome/controllers/history_edit_controller.dart';

class HistoryEdit extends GetView<HistoryEditController> {
  const HistoryEdit({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text('Edit visit dealer'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
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
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('res/images/baleno.jpg'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text('Data Dealer', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue)),
                _buildTextField('Jabatan Saya', 'jabatan', data),
                _buildTextField('Area', 'area', data),
                _buildTextField('Cabang', 'cabang', data),
                _buildTextField('Produk', 'produk', data),
                const SizedBox(height: 16),
                Text('Data Visit', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue)),
                _buildTextField('Tipe visit', 'type', data),
                _buildTextField('Tujuan visit', 'activity', data),
                _buildTextField('Dari tanggal', 'date_start', data),
                _buildTextField('Sampai tanggal', 'date_finish', data),
                _buildTextField('Tanggal selesai', 'date_finish', data),
                _buildTextField('Nama PIC', 'pic', data),
                _buildTextField('Theme discussion', 'discussion', data),
                _buildTextField('Problem', 'problem', data),
                _buildTextField('Keterangan Pelaksanaan', 'pelakasanaan', data),
              ],
            );
          }),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, String key, RxMap<String, dynamic> data) {
    return Padding(
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
            validator: (value) => value?.isEmpty ?? true ? 'Field cannot be empty' : null,
          ),
        ],
      ),
    );
  }
}