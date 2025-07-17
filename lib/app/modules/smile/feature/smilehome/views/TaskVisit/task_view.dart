import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../models/visit.dart';
import '../../../../smile_route.dart';

class TaskView extends StatelessWidget {
  const TaskView({super.key});

  @override
  Widget build(BuildContext context) {
    final Visit visit = Get.arguments;

    Widget _buildSectionHeader(String title) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0048A7),
            ),
          ),
          const Divider(height: 24, thickness: 1, color: Colors.grey),
        ],
      );
    }

    Widget _buildDisplayField(String label, String value, {bool isLongText = false}) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 14, color: Colors.black54)),
            const SizedBox(height: 4),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade100),
              ),
              child: Text(
                value,
                style: const TextStyle(fontSize: 16, color: Colors.black87),
                maxLines: isLongText ? null : 1,
                overflow: isLongText ? TextOverflow.clip : TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      );
    }

    Widget _buildPhotoSection(String title, String? photoUrl1, String? photoUrl2) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0048A7)),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildPhotoPreview(photoUrl1, "Foto 1"),
              _buildPhotoPreview(photoUrl2, "Foto 2"),
            ],
          ),
        ],
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Task Visit'),
        backgroundColor: const Color(0xFF0048A7),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Jabatan Saya & Data Dealer
            _buildCardSection([
              _buildSectionHeader('Jabatan Saya'),
              _buildDisplayField('Jabatan', visit.jabatanSaya ?? "-"),
              const SizedBox(height: 16),
              _buildSectionHeader('Data Dealer'),
              _buildDisplayField('Area', visit.areaCode ?? "-"),
              _buildDisplayField('Cabang', visit.branchCode ?? "-"),
              _buildDisplayField('Produk', visit.productCode ?? "-"),
              _buildDisplayField('Dealer', visit.dealerCode ?? "-"),
            ]),

            // 2. Data Visit (digabung dengan Diskusi, Problem, Follow-Up, dan Description)
            _buildCardSection([
              _buildSectionHeader('Data Visit'),
              _buildDisplayField('Tipe Visit', visit.tipeVisit ?? "-"),
              _buildDisplayField('Tujuan Visit', visit.tujuanVisit ?? "-"),
              _buildDisplayField('Dari Tanggal', _formatTanggal(visit.dariTanggal)),
              _buildDisplayField('Sampai Tanggal', _formatTanggal(visit.sampaiTanggal)),
              _buildDisplayField('Tanggal Selesai', _formatTanggal(visit.tanggalSelesai)),
              _buildDisplayField('Nama PIC', visit.namaPic ?? "-"),
              _buildDisplayField('Theme of Discussion', visit.themeOfDiscussion ?? "-", isLongText: true),
              _buildDisplayField('Problem', visit.problem ?? "-", isLongText: true),
              _buildDisplayField('Follow-Up', visit.followUp ?? "-", isLongText: true),
              _buildDisplayField('Description', visit.description ?? "-", isLongText: true),
            ]),

            // 3. Main Person
            _buildCardSection([
              _buildSectionHeader('Main Person'),
              _buildDisplayField('Jabatan', visit.jabatanSaya ?? "-"),
              _buildDisplayField('Nama PIC', visit.namaPic ?? "-"),
            ]),

            // 4. Foto
            _buildCardSection([
              _buildPhotoSection('Foto', visit.photo1, visit.photo2),
            ]),

            // 5. Lokasi (tanpa tombol Ambil Lokasi)
            _buildCardSection([
              _buildSectionHeader('Informasi Lokasi'),
              Row(
                children: [
                  Expanded(child: _buildDisplayField('Latitude', visit.latitude?.toString() ?? "Belum diambil")),
                  const SizedBox(width: 16),
                  Expanded(child: _buildDisplayField('Longitude', visit.longitude?.toString() ?? "Belum diambil")),
                ],
              ),
            ]),


            // 6. Tombol Edit Saja
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton.icon(
                  icon: const Icon(Icons.edit),
                  label: const Text('Edit'),
                  onPressed: () async {
                    final result = await Get.toNamed(SmileRoutes.taskEdit, arguments: visit);
                    if (result != null && result is Visit) {
                      Get.back(result: result); // Kirim data hasil edit balik ke halaman sebelumnya
                    }
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF0048A7),
                    side: const BorderSide(color: Color(0xFF0048A7)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

          ],
        ),
      ),
    );
  }

  // ✅ Tambahan fungsi untuk menampilkan preview foto
  Widget _buildPhotoPreview(String? photoPath, String label) {
    if (photoPath == null || photoPath.isEmpty) {
      return Column(
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey),
            ),
            child: const Icon(Icons.image_not_supported, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          Text(label),
        ],
      );
    }

    final String fullUrl = 'https://sufione.com/storage/$photoPath';

    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            fullUrl,
            width: 100,
            height: 100,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) =>
            const Icon(Icons.broken_image, size: 50, color: Colors.red),
          ),
        ),
        const SizedBox(height: 8),
        Text(label),
      ],
    );
  }

  Widget _buildCardSection(List<Widget> children) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: Colors.grey.shade300),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children),
        ),
      ),
    );
  }

  String _formatTanggal(DateTime? date) {
    if (date == null) return '-';
    return '${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}';
  }
}
