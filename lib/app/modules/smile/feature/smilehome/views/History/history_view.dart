import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sufi_one/app/modules/smile/feature/smilehome/controllers/history_view_controller.dart';
import 'package:sufi_one/app/modules/smile/models/visit.dart';
import 'package:intl/intl.dart';

class HistoryView extends GetView<HistoryViewController> {
  const HistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    // Define custom colors - sama dengan HistoryEdit
    const Color headerBlue = Color(0xFF1521A4);
    const Color dropdownLight = Color(0xFF272728);
    const Color dropdownLightNF = Color(0xFFCCCCCC);

    return Scaffold(
      backgroundColor: const Color(0xFFFDFDFF),
      appBar: AppBar(
        backgroundColor: headerBlue,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'View Visit Dealer',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
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

        final data = Get.arguments != null
            ? Visit.fromJson(Get.arguments as Map<String, dynamic>)
            : null;

        if (data == null) {
          return const Center(
            child: Text('Tidak ada data kunjungan untuk ditampilkan'),
          );
        }

        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Card Data Gambar
                Card(
                  color: const Color(0xFFFDFDFF),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Text(
                            'Data Gambar',
                            style: TextStyle(fontSize: 22, color: headerBlue),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Slider untuk gambar
                        if ((data.photo1 != null && data.photo1!.isNotEmpty) ||
                            (data.photo2 != null && data.photo2!.isNotEmpty)) ...[
                          SizedBox(
                            height: 200,
                            child: PageView(
                              children: [
                                if (data.photo1 != null && data.photo1!.isNotEmpty)
                                  _buildImageContainer(data.photo1!),
                                if (data.photo2 != null && data.photo2!.isNotEmpty)
                                  _buildImageContainer(data.photo2!),
                              ],
                            ),
                          ),
                        ] else ...[
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
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Card Jabatan Saya
                Card(
                  color: const Color(0xFFFDFDFF),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Center(
                          child: Text(
                            'Jabatan Saya',
                            style: TextStyle(fontSize: 22, color: headerBlue),
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildViewField('Jabatan', data.jabatanSaya ?? '-'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Card Data Dealer
                Card(
                  color: const Color(0xFFFDFDFF),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Text(
                            'Data Dealer',
                            style: TextStyle(fontSize: 22, color: headerBlue),
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildViewField(
                          'Area',
                          controller.getAreaNameFromKode(data.areaCode) ?? '-',
                        ),
                        _buildViewField(
                          'Cabang',
                          controller.getBranchNameFromKode(data.branchCode) ?? '-',
                        ),
                        _buildViewField(
                          'Produk',
                          controller.getProductNameFromKode(data.productCode) ?? '-',
                        ),
                        _buildViewField('Dealer', data.dealerCode ?? '-'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Card Data Visit
                Card(
                  color: const Color(0xFFFDFDFF),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Text(
                            'Data Visit',
                            style: TextStyle(fontSize: 22, color: headerBlue),
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildViewField('Tipe Visit', data.tipeVisit ?? '-'),
                        _buildViewField('Tujuan Visit', data.tujuanVisit ?? '-'),
                        _buildViewField(
                          'Dari Tanggal',
                          data.dariTanggal != null
                              ? DateFormat('dd MMM yyyy').format(data.dariTanggal!)
                              : '-',
                        ),
                        _buildViewField(
                          'Sampai Tanggal',
                          data.sampaiTanggal != null
                              ? DateFormat('dd MMM yyyy').format(data.sampaiTanggal!)
                              : '-',
                        ),
                        _buildViewField(
                          'Tanggal Selesai',
                          data.tanggalSelesai != null
                              ? DateFormat('dd MMM yyyy').format(data.tanggalSelesai!)
                              : '-',
                        ),
                        _buildViewField('Nama PIC', data.namaPic ?? '-'),
                        _buildViewField('Theme of Discussion', data.themeOfDiscussion ?? '-'),
                        _buildViewField('Problem', data.problem ?? '-'),
                        _buildViewField('Follow-Up', data.followUp ?? '-'),
                        _buildViewField('Description', data.description ?? '-'),
                      ],
                    ),
                  ),
                ),

                // Card Main Person
                Card(
                  color: const Color(0xFFFDFDFF),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Text(
                            'Main Person',
                            style: TextStyle(fontSize: 22, color: headerBlue),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Menampilkan daftar main persons
                        if (data.mainPersons != null && data.mainPersons!.isNotEmpty) ...[
                          ...data.mainPersons!.map((person) {
                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              color: Colors.grey[50],
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildViewField('Nama', person['nama'] ?? '-'),
                                    _buildViewField('Jabatan', person['jabatan'] ?? '-'),
                                    _buildViewField('No. Telepon', person['telp'] ?? '-'),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ] else ...[
                          Center(
                            child: Text(
                              'Tidak ada data main person',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

                // Informasi lokasi
                if (data.latitude != null && data.longitude != null) ...[
                  const SizedBox(height: 16),
                  Card(
                    color: const Color(0xFFFDFDFF),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: Text(
                              'Informasi Lokasi',
                              style: TextStyle(fontSize: 22, color: headerBlue),
                            ),
                          ),
                          const SizedBox(height: 12),
                          _buildViewField('Latitude', data.latitude.toString()),
                          _buildViewField('Longitude', data.longitude.toString()),
                        ],
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildImageContainer(String photo) {
    return Container(
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
          'http://10.0.2.2:8000/storage/$photo',
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            print('Error memuat gambar: $error');
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
    );
  }

  Widget _buildFieldLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Color(0xFF272728),
        ),
      ),
    );
  }

  Widget _buildViewField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFieldLabel(label),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              border: Border(
                bottom: BorderSide(
                  color: const Color(0xFFCCCCCC),
                  width: 0.5,
                ),
              ),
            ),
            child: Text(
              value,
              style: const TextStyle(
                color: Color(0xFF272728),
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
