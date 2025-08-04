import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sufi_one/app/modules/smile/feature/smilehome/controllers/history_view_controller.dart';
import 'package:sufi_one/app/modules/smile/models/visit.dart';
import 'package:intl/intl.dart';

class HistoryView extends GetView<HistoryViewController> {
  const HistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A28C4),
        title: const Text(
          'View visit dealer',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.errorMessage.value.isNotEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  controller.errorMessage.value,
                  style: const TextStyle(color: Colors.red, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => controller.refreshData(),
                  child: const Text('Coba Lagi'),
                ),
              ],
            ),
          );
        }
        final data =
            Get.arguments != null
                ? Visit.fromJson(Get.arguments as Map<String, dynamic>)
                : null;
        if (data == null) {
          return const Center(
            child: Text('Tidak ada data kunjungan untuk ditampilkan'),
          );
        }
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Container untuk gambar utama (photo1)
              if (data.photo1 != null && data.photo1!.isNotEmpty)
                Container(
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
                    child: Image.network(
                      'http://10.0.2.2:8000/storage/${data.photo1!}',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        print('Error memuat gambar photo1: $error');
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
                    ),
                  ),
                ),

              // Container untuk gambar kedua (photo2)
              if (data.photo2 != null && data.photo2!.isNotEmpty)
                Container(
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
                    child: Image.network(
                      'http://10.0.2.2:8000/storage/${data.photo2!}',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        print('Error memuat gambar photo2: $error');
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
                    ),
                  ),
                ),

              // Jika tidak ada gambar, tampilkan placeholder
              if ((data.photo1 == null || data.photo1!.isEmpty) &&
                  (data.photo2 == null || data.photo2!.isEmpty))
                Container(
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
                ),

              const SizedBox(height: 16),
              Text(
                'Data Dealer',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              _buildField('Jabatan Saya', data.jabatanSaya ?? '-'),
              _buildField(
                'Area',
                controller.getAreaNameFromKode(data.areaCode) ?? '-',
              ),
              _buildField(
                'Cabang',
                controller.getBranchNameFromKode(data.branchCode) ?? '-',
              ),
              _buildField(
                'Produk',
                controller.getProductNameFromKode(data.productCode) ?? '-',
              ),

              const SizedBox(height: 16),
              Text(
                'Data Visit',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              _buildField('Tipe Visit', data.tipeVisit ?? '-'),
              _buildField('Tujuan Visit', data.tujuanVisit ?? '-'),
              _buildField(
                'Dari Tanggal',
                data.dariTanggal != null
                    ? DateFormat('dd MMM yyyy').format(data.dariTanggal!)
                    : '-',
              ),
              _buildField(
                'Sampai Tanggal',
                data.sampaiTanggal != null
                    ? DateFormat('dd MMM yyyy').format(data.sampaiTanggal!)
                    : '-',
              ),
              _buildField(
                'Tanggal Selesai',
                data.tanggalSelesai != null
                    ? DateFormat('dd MMM yyyy').format(data.tanggalSelesai!)
                    : '-',
              ),
              _buildField('Nama PIC', data.namaPic ?? '-'),
              _buildField('Theme Discussion', data.themeOfDiscussion ?? '-'),
              _buildField('Problem', data.problem ?? '-'),
              _buildField('Keterangan Pelaksanaan', data.description ?? '-'),

              // Informasi lokasi
              if (data.latitude != null && data.longitude != null) ...[
                const SizedBox(height: 16),
                Text(
                  'Informasi Lokasi',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                _buildField('Latitude', data.latitude.toString()),
                _buildField('Longitude', data.longitude.toString()),
              ],
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
          Text(
            label,
            style: const TextStyle(color: Colors.black54, fontSize: 14),
          ),
          const SizedBox(height: 4),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(value, style: const TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }
}
