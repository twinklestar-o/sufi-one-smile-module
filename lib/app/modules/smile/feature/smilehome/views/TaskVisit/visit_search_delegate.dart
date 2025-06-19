import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sufi_one/app/modules/smile/feature/smilehome/controllers/task_visit_controller.dart';

class VisitSearchDelegate extends SearchDelegate {
  final TaskVisitController controller;

  VisitSearchDelegate(this.controller);

  // Label untuk kolom pencarian
  @override
  String get searchFieldLabel =>
      'Cari berdasarkan Cabang, PIC, Tipe, Aktivitas...';

  // Aksi di AppBar (misalnya tombol clear)
  @override
  List<Widget> buildActions(BuildContext context) => [
    IconButton(
      icon: const Icon(Icons.clear),
      onPressed: () {
        query = ''; // Menghapus teks di kolom pencarian SearchDelegate
        controller.updateSearchQuery(''); // Menghapus query di controller
        showSuggestions(context); // Tampilkan kembali saran
      },
    ),
  ];

  // Tombol kembali di AppBar
  @override
  Widget buildLeading(BuildContext context) => IconButton(
    icon: const Icon(Icons.arrow_back),
    onPressed: () {
      controller.updateSearchQuery(
        '',
      ); // Pastikan query di controller bersih saat keluar
      close(context, null); // Menutup halaman pencarian
    },
  );

  // Hasil pencarian yang akan ditampilkan setelah menekan enter/submit
  @override
  Widget buildResults(BuildContext context) {
    // Memperbarui query di controller. Debounce di controller akan memfilter data.
    controller.updateSearchQuery(query);

    return Obx(() {
      final results = controller.filteredTaskVisitData;
      if (results.isEmpty) {
        // Tampilkan loading jika data asli belum dimuat atau kosong
        if (controller.taskVisitData.isEmpty && query.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        // Jika data sudah dimuat tapi tidak ada hasil, tampilkan pesan
        return const Center(child: Text('Tidak ada hasil yang cocok.'));
      }
      return _buildResultList(results);
    });
  }

  // Saran pencarian yang muncul saat pengguna mengetik
  @override
  Widget buildSuggestions(BuildContext context) {
    // Memperbarui query di controller. Debounce di controller akan memfilter data.
    controller.updateSearchQuery(query);

    return Obx(() {
      final results = controller.filteredTaskVisitData;
      if (results.isEmpty) {
        if (controller.taskVisitData.isEmpty && query.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        // Pesan jika tidak ada saran atau pengguna baru mulai mengetik
        return const Center(child: Text('Ketik untuk mencari...'));
      }
      return _buildSuggestionList(results);
    });
  }

  Widget _buildResultList(List<Map<String, dynamic>> results) {
    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final data = results[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          elevation: 2.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16.0),
            title: Text(
              data['cabang'] ?? 'N/A',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16.0,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('PIC: ${data['pic'] ?? 'N/A'}'),
                Text('Tipe: ${data['type'] ?? 'N/A'}'),
                Text('Aktivitas: ${data['activity'] ?? 'N/A'}'),
              ],
            ),
            onTap: () {
              close(context, null); // Tutup pencarian
              Get.toNamed(
                '/public/smile/task_view',
                arguments: data,
              ); // Navigasi ke halaman detail
            },
          ),
        );
      },
    );
  }

  Widget _buildSuggestionList(List<Map<String, dynamic>> results) {
    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final data = results[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          elevation: 2.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16.0),
            title: Text(
              data['cabang'] ?? 'N/A',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16.0,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('PIC: ${data['pic'] ?? 'N/A'}'),
                Text('Tipe: ${data['type'] ?? 'N/A'}'),
                Text('Aktivitas: ${data['activity'] ?? 'N/A'}'),
              ],
            ),
            onTap: () {
              query = data['cabang'] ?? ''; // Set query ke item yang dipilih
              showResults(context); // Tampilkan hasil untuk item yang dipilih
            },
          ),
        );
      },
    );
  }
}
