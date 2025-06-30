import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sufi_one/app/modules/smile/feature/smilehome/controllers/task_view_controller.dart'; // Pastikan controller TaskViewController telah ada

class TaskView extends GetView<TaskViewController> {
  const TaskView({super.key});

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> data =
        Get.arguments as Map<String, dynamic>? ?? {};

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0048A7), // Warna biru tua
        title: const Text(
          'View Task Visit',
          style: TextStyle(color: Colors.white), // Teks putih
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white), // Ikon putih
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() {
        if (controller.taskData.isEmpty && data.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Image Section (like TaskEdit) ---
              Container(
                width: double.infinity,
                height: 200,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(
                      'res/images/car.jpg',
                    ), // Use the same image as TaskEdit
                    fit: BoxFit.cover,
                  ),
                  borderRadius: BorderRadius.all(
                    Radius.circular(8),
                  ), // Add border radius for consistency
                ),
              ),
              const SizedBox(height: 16), // Spacing after the image
              // === BAGIAN DATA TASK ===
              _buildDataSectionCard(
                title: 'Data Task',
                children: [
                  _buildField('Jabatan Saya', data['jabatan'] ?? '-'),
                  _buildField('Area', data['area'] ?? '-'),
                  _buildField('Cabang', data['cabang'] ?? '-'),
                  _buildField('Produk', data['produk'] ?? '-'),
                  _buildField('Dealer', data['dealer'] ?? '-'),
                ],
              ),
              const SizedBox(height: 24), // Jarak antar bagian
              // === BAGIAN DATA VISIT ===
              _buildDataSectionCard(
                title: 'Data Visit',
                children: [
                  _buildField('Tipe visit', data['type'] ?? '-'),
                  _buildField('Tujuan visit', data['activity'] ?? '-'),
                  // Corrected to use date_finish_actual for "Tanggal selesai" if that's the intended field
                  _buildField('Dari tanggal', data['date_start'] ?? '-'),
                  _buildField('Sampai tanggal', data['date_finish'] ?? '-'),
                  _buildField(
                    'Tanggal selesai',
                    data['date_finish_actual'] ?? '-',
                  ), // Changed key here
                  _buildField('Nama PIC', data['pic'] ?? '-'),
                  _buildField('Theme discussion', data['discussion'] ?? '-'),
                  _buildField('Problem', data['problem'] ?? '-'),
                  _buildField('Follow Up', data['follow up'] ?? '-'),
                  _buildField('Description', data['description'] ?? '-'),
                  _buildField('Keterangan Pelaksanaan', data['pelakasanaan'] ?? '-',),
                  _buildField('Status', data['status'] ?? '-',),
                ],
              ),
              const SizedBox(height: 24), // Jarak antar bagian
              // === BAGIAN MAIN PERSON ===
              _buildDataSectionCard(
                title: 'Main Person',
                children: [
                  _buildField('Jabatan PIC', data['main_jabatan'] ?? '-'),
                  _buildField('Nama PIC', data['main_nama_pic'] ?? '-'),
                  _buildField('Nomor Telepon PIC', data['main_no_telp'] ?? '-'),
                  _buildField('Lokasi PIC', data['main_lokasi'] ?? '-'),
                ],
              ),
            ],
          ),
        );
      }),
    );
  }

  /// Helper widget to create a data section wrapped in a Card.
  Widget _buildDataSectionCard({
    required String title,
    required List<Widget> children,
  }) {
    return Card(
      margin: EdgeInsets.zero, // Remove default Card margin
      elevation: 2, // Add slight shadow
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8), // Consistent rounded corners
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0), // Padding inside the Card
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.stretch, // Stretch for centered title
          children: [
            // Section title within the Card
            _buildSectionTitle(title),
            const SizedBox(height: 8), // Space between title and first field
            // List of data fields
            ...children,
          ],
        ),
      ),
    );
  }

  /// Helper widget for Section Titles (e.g., "Data Task", "Data Visit").
  Widget _buildSectionTitle(String title) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.stretch, // Stretch for centered text
      children: [
        Text(
          title,
          textAlign: TextAlign.center, // Center the text
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black, // Text color black
          ),
        ),
        const Divider(
          color: Colors.grey, // Line color grey for consistency with TaskEdit
          thickness: 1,
          height: 20, // Adjust height to control space above/below line
        ), // Separator line
      ],
    );
  }

  /// Helper widget for each display field (Label above value box).
  Widget _buildField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 8,
      ), // Padding between fields
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label above the value box
          Text(
            label,
            style: const TextStyle(
              color: Colors.black54,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6), // Space between label and value box
          // Value box
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey[100], // Background color of the box
              border: Border.all(
                color: Colors.black, // Border color black
                width: 1.0, // Border width
              ),
              borderRadius: BorderRadius.circular(
                8,
              ), // Consistent rounded corners
            ),
            child: Text(
              value,
              style: const TextStyle(fontSize: 16, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}
