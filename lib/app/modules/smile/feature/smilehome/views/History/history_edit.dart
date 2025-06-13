import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HistoryEdit extends StatelessWidget {
  const HistoryEdit({super.key});

  @override
  Widget build(BuildContext context) {
    // Data dummy berdasarkan gambar
    final data = Get.arguments ?? {
      'jabatan': 'BM',
      'area': '01.JABODETABEKSER',
      'cabang': '1507',
      'produk': 'MBBR',
      'type': 'Direct Visit Dealer',
      'activity': 'KORDINASI RUTIN',
      'date_start': '2025-05-30',
      'date_finish': '2025-05-30',
      'pic': 'Herman,rukiyanti,all sh',
      'discussion': 'Koordinasi rutin',
      'problem': '-',
      'location': 'Kecamatan Pondok Jaya, Kecamatan Pondok Aren, Kota Tangerang Selatan, Banten',
      'timestamp': '30 May 2025 14:28:55',
    };

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text('View visit dealer'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gambar dan informasi lokasi
            Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('res/images/baleno.jpg'), // Path disesuaikan dengan struktur proyek
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
            // Data Dealer
            Text('Data Dealer', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue)),
            _buildField('Jabatan Saya', data['jabatan'] ?? '-'),
            _buildField('Area', data['area'] ?? '-'),
            _buildField('Cabang', data['cabang'] ?? '-'),
            _buildField('Produk', data['produk'] ?? '-'),
            const SizedBox(height: 16),
            // Data Visit
            Text('Data Visit', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue)),
            _buildField('Tipe visit', data['type'] ?? '-'),
            _buildField('Tujuan visit', data['activity'] ?? '-'),
            _buildField('Dari tanggal', data['date_start'] ?? '-'),
            _buildField('Sampai tanggal', data['date_finish'] ?? '-'),
            _buildField('Tanggal selesai', data['date_finish'] ?? '-'),
            _buildField('Nama PIC', data['pic'] ?? '-'),
            _buildField('Theme discussion', data['discussion'] ?? '-'),
            _buildField('Problem', data['problem'] ?? '-'),
            _buildField('Keterangan Pelaksanaan', data['pelaksanaan'] ?? '-'),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Logika simpan bisa ditambahkan di sini
                Get.back();
              },
              child: Text('Save'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            ),
          ],
        ),
      ),
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
          TextField(
            controller: TextEditingController(text: value),
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.grey[100],
              contentPadding: const EdgeInsets.all(12),
              border: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.blue),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
}