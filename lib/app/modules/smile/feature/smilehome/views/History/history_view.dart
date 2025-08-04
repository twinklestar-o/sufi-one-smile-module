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
        final data = Get.arguments != null ? Visit.fromJson(Get.arguments as Map<String, dynamic>) : null;
        if (data == null) {
          return const Center(child: Text('Tidak ada data kunjungan untuk ditampilkan'));
        }
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
                    image: data.photo1 != null && data.photo1!.isNotEmpty
                        ? NetworkImage(data.photo1!)
                        : const AssetImage('res/images/baleno.jpg') as ImageProvider,
                    fit: BoxFit.cover,
                    onError: (exception, stackTrace) {
                      print('Error memuat gambar: $exception\nStackTrace: $stackTrace');
                    },
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
                        data.tanggalSelesai != null
                            ? DateFormat('dd MMM yyyy').format(data.tanggalSelesai!)
                            : '-',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Positioned(
                      bottom: 8,
                      left: 8,
                      child: Text(
                        (data.latitude != null && data.longitude != null)
                            ? '${data.latitude}, ${data.longitude}'
                            : '-',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text('Data Dealer', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue)),
              _buildField('Jabatan Saya', data.jabatanSaya ?? '-'),
              _buildField('Area', controller.getAreaNameFromKode(data.areaCode) ?? '-'),
              _buildField('Cabang', controller.getBranchNameFromKode(data.branchCode) ?? '-'),
              _buildField('Produk', controller.getProductNameFromKode(data.productCode) ?? '-'),

              const SizedBox(height: 16),
              Text('Data Visit', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue)),
              _buildField('Tipe Visit', data.tipeVisit ?? '-'),
              _buildField('Tujuan Visit', data.tujuanVisit ?? '-'),
              _buildField('Dari Tanggal', data.dariTanggal != null ? DateFormat('dd MMM yyyy').format(data.dariTanggal!) : '-'),
              _buildField('Sampai Tanggal', data.sampaiTanggal != null ? DateFormat('dd MMM yyyy').format(data.sampaiTanggal!) : '-'),
              _buildField('Tanggal Selesai', data.tanggalSelesai != null ? DateFormat('dd MMM yyyy').format(data.tanggalSelesai!) : '-'),
              _buildField('Nama PIC', data.namaPic ?? '-'),
              _buildField('Theme Discussion', data.themeOfDiscussion ?? '-'),
              _buildField('Problem', data.problem ?? '-'),
              _buildField('Keterangan Pelaksanaan', data.description ?? '-'),

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