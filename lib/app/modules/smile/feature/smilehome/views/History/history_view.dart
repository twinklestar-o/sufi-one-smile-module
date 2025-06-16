import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sufi_one/app/modules/smile/feature/smilehome/controllers/history_view_controller.dart';

class HistoryView extends GetView<HistoryViewController> {
  const HistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text('View visit dealer'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() {
        if (controller.historyData.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        final data = Get.arguments as Map<String, dynamic>? ?? {};
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
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
                child: Stack(
                  children: [
                    Positioned(
                      top: 8,
                      left: 8,
                      child: CircleAvatar(
                        backgroundColor: Colors.blue,
                        child: Icon(Icons.location_on, color: Colors.white),
                      ),
                    ),
                    Positioned(
                      bottom: 8,
                      right: 8,
                      child: Text(
                        data['timestamp'] ?? '-',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Positioned(
                      bottom: 8,
                      left: 8,
                      child: Text(
                        data['location'] ?? '-',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text('Data Dealer', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue)),
              _buildField('Jabatan Saya', data['jabatan'] ?? '-'),
              _buildField('Area', data['area'] ?? '-'),
              _buildField('Cabang', data['cabang'] ?? '-'),
              _buildField('Produk', data['produk'] ?? '-'),
              const SizedBox(height: 16),
              Text('Data Visit', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue)),
              _buildField('Tipe visit', data['type'] ?? '-'),
              _buildField('Tujuan visit', data['activity'] ?? '-'),
              _buildField('Dari tanggal', data['date_start'] ?? '-'),
              _buildField('Sampai tanggal', data['date_finish'] ?? '-'),
              _buildField('Tanggal selesai', data['date_finish'] ?? '-'),
              _buildField('Nama PIC', data['pic'] ?? '-'),
              _buildField('Theme discussion', data['discussion'] ?? '-'),
              _buildField('Problem', data['problem'] ?? '-'),
              _buildField('Keterangan Pelaksanaan', data['pelakasanaan'] ?? '-'),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.black54, fontSize: 14)),
          const SizedBox(height: 4),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              value,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}