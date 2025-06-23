import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sufi_one/app/modules/smile/smile_route.dart';

class DataMaster extends StatefulWidget {
  const DataMaster({super.key});

  @override
  State<DataMaster> createState() => _DataMasterState();
}

class _DataMasterState extends State<DataMaster> {
  final ScrollController _scrollController = ScrollController();
  bool _showScrollToTop = false;

  final List<Map<String, dynamic>> masterItems = const [
    {'title': 'AREA', 'route': SmileRoutes.area},
    {'title': 'CABANG', 'route': '/master/cabang'},
    {'title': 'DEALER', 'route': '/master/dealer'},
    {'title': 'JABATAN', 'route': SmileRoutes.jabatan},
    {'title': 'JABATAN SFI', 'route': '/master/jabatan-sfi'},
    {'title': 'MAIN DEALER', 'route': '/master/main-dealer'},
    {'title': 'PRODUK', 'route': '/master/produk'},
    {'title': 'TIPE VISIT', 'route': SmileRoutes.type},
    {'title': 'TUJUAN VISIT', 'route': SmileRoutes.purpose},
  ];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
  }

  void _scrollListener() {
    if (_scrollController.offset > 200 && !_showScrollToTop) {
      setState(() => _showScrollToTop = true);
    } else if (_scrollController.offset <= 200 && _showScrollToTop) {
      setState(() => _showScrollToTop = false);
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  void _navigateToMaster(String route) {
    // Anda bisa menambahkan logika tambahan sebelum navigasi di sini
    Get.toNamed(route);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0E47A1),
        title: const Text(
          'List Master',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: ElevatedButton(
              onPressed: _downloadMasterData,
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
          final item = masterItems[index];
          return Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 2,
            margin: const EdgeInsets.only(bottom: 12),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => _navigateToMaster(item['route']),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 16,
                ),
                visualDensity: const VisualDensity(vertical: 2),
                title: Text(
                  item['title'],
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                trailing: const Icon(Icons.arrow_forward_ios),
              ),
            ),
          );
        },
      ),
      floatingActionButton: AnimatedOpacity(
        opacity: _showScrollToTop ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 300),
        child: FloatingActionButton(
          onPressed: () {
            _scrollController.animateTo(
              _showScrollToTop ? 0 : _scrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOut,
            );
          },
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF0E47A1),
          shape: const CircleBorder(),
          child: Icon(
            _showScrollToTop ? Icons.arrow_upward : Icons.arrow_downward,
          ),
        ),
      ),
    );
  }

  void _downloadMasterData() {
    // Implementasi download master data
    Get.snackbar(
      'Download',
      'Memulai download data master...',
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
  }
}
