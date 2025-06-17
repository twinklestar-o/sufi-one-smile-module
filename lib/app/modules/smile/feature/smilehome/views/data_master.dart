import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DataMaster extends StatefulWidget {
  const DataMaster({super.key});

  @override
  State<DataMaster> createState() => _DataMasterState();
}

class _DataMasterState extends State<DataMaster> {
  final ScrollController _scrollController = ScrollController();
  bool _showScrollToTop = false;

  final List<String> masterItems = const [
    'AREA',
    'CABANG',
    'DEALER',
    'JABATAN',
    'JABATAN SFI',
    'MAIN DEALER',
    'PRODUK',
    'TIPE VISIT',
    'TUJUAN VISIT',
    'Tanggal Mulai',
    'Sampai Tanggal'
    'Tanggal Selesai',
    'Nama PIC',
    'Theme Discussion',
    'Problem',
  ];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      // Tampilkan tombol scroll jika scroll melewati 200px
      if (_scrollController.offset > 200 && !_showScrollToTop) {
        setState(() => _showScrollToTop = true);
      } else if (_scrollController.offset <= 200 && _showScrollToTop) {
        setState(() => _showScrollToTop = false);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0E47A1),
        title: const Text(
          'List Master',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          Padding(

            padding: const EdgeInsets.only(right: 12.0),
            child: ElevatedButton(
              onPressed: () {
                // Tambahkan logika download di sini
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF0E47A1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Text('Download'),
            ),
          ),
        ],
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
      ),
      body: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        itemCount: masterItems.length,
        itemBuilder: (context, index) {
          return Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 2,
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16), // buat lebih tinggi
              visualDensity: const VisualDensity(vertical: 2), // tambah tinggi jarak dalam tile
              title: Text(
                masterItems[index],
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                // Tambahkan navigasi ke detail master di sini
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_showScrollToTop) {
            _scrollController.animateTo(
              0,
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOut,
            );
          } else {
            _scrollController.animateTo(
              _scrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOut,
            );
          }
        },
        backgroundColor: Colors.white,
        foregroundColor: Colors.redAccent,
        shape: const CircleBorder(),
        child: Icon(
          _showScrollToTop ? Icons.arrow_upward : Icons.arrow_downward,
        ),
      ),
    );
  }
}
