import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:sufi_one/app/modules/DAMS/dams_route.dart';
import 'package:sufi_one/app/modules/DAMS/repository/divisi_user_repository.dart';
import 'package:sufi_one/app/modules/DAMS/repository/kondisi_asset_repository.dart';
import 'package:sufi_one/app/modules/DAMS/repository/lantai_user_repository.dart';
import 'package:sufi_one/app/modules/DAMS/repository/lokasi_user_repository.dart';
import 'package:sufi_one/app/modules/DAMS/repository/posisi_user_repository.dart';
import 'package:sufi_one/app/modules/DAMS/repository/status_asset_repository.dart';
import 'package:sufi_one/app/modules/DAMS/repository/status_user_asset_repository.dart';

class DataMaster extends StatefulWidget {
  const DataMaster({super.key});

  @override
  State<DataMaster> createState() => _DataMasterState();
}

class _DataMasterState extends State<DataMaster> {
  final ScrollController _scrollController = ScrollController();
  bool _showScrollToTop = false;
  bool _isLoading = false;
  String? _errorMessage;
  Future<List>? _statusAssetFuture;
  Future<List>? _kondisiAssetFuture;
  Future<List>? _statusUserAssetFuture;
  Future<List>? _posisiUserFuture;
  Future<List>? _divisiUserFuture;
  Future<List>? _lokasiUserFuture;
  Future<List>? _lantaiUserFuture;

  final List<Map<String, dynamic>> masterItems = const [
    {'title': 'Status Asset', 'route': DamsRoute.statusAsset},
    {'title': 'Kondisi Asset', 'route': DamsRoute.kondisiAsset},
    {'title': 'Status User Asset', 'route': DamsRoute.statusUserAsset},
    {'title': 'Posisi User', 'route': DamsRoute.posisiUser},
    {'title': 'Divisi User', 'route': DamsRoute.divisiUser},
    {'title': 'Lokasi User', 'route': DamsRoute.lokasiUser},
    {'title': 'Lantai User', 'route': DamsRoute.lantaiUser},
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

  Future<void> _refreshMasterData(BuildContext context) async {
    if (!context.mounted) return;

    // Tampilkan snackbar awal
    Get.snackbar(
      'Refresh',
      'Mengambil data master dari API...',
      backgroundColor: Colors.green,
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
    );

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    // Ambil semua repository
    final statusAssetRepository = Provider.of<StatusAssetRepository>(
      context,
      listen: false,
    );
    final kondisiRepository = Provider.of<KondisiAssetRepository>(
      context,
      listen: false,
    );
    final statusUserAssetRepository = Provider.of<StatusUserAssetRepository>(
      context,
      listen: false,
    );
    final posisiUserRepository = Provider.of<PosisiUserRepository>(
      context,
      listen: false,
    );
    final divisiRepository = Provider.of<DivisiUserRepository>(
      context,
      listen: false,
    );
    final lokasiUserRepository = Provider.of<LokasiUserRepository>(
      context,
      listen: false,
    );
    final lantaiUserRepository = Provider.of<LantaiUserRepository>(
      context,
      listen: false,
    );

    try {
      // Paksa ambil dari API
      final results = await Future.wait([
        statusAssetRepository.getStatusAsset(),
        kondisiRepository.getKondisiAsset(forceRefresh: true),
        statusUserAssetRepository.getStatusUserAsset(forceRefresh: true),
        posisiUserRepository.getPosisiUser(forceRefresh: true),
        divisiRepository.getDivisiUser(forceRefresh: true),
        lokasiUserRepository.getLokasiUser(forceRefresh: true),
        lantaiUserRepository.getLantaiUser(forceRefresh: true),
      ]);

      final statusAssetData = results[0];
      final kondisiData = results[1];
      final statusUserAssetData = results[2];
      final posisiUserData = results[3];
      final divisiData = results[4];
      final lokasiUserData = results[5];
      final lantaiUserData = results[6];

      setState(() {
        _statusAssetFuture = Future.value(statusAssetData);
        _kondisiAssetFuture = Future.value(kondisiData);
        _statusUserAssetFuture = Future.value(statusUserAssetData);
        _posisiUserFuture = Future.value(posisiUserData);
        _divisiUserFuture = Future.value(divisiData);
        _lokasiUserFuture = Future.value(lokasiUserData);
        _lantaiUserFuture = Future.value(lantaiUserData);
        _isLoading = false;
      });

      // Validasi apakah ada data kosong
      if (statusAssetData.isEmpty ||
          kondisiData.isEmpty ||
          statusUserAssetData.isEmpty ||
          posisiUserData.isEmpty ||
          divisiData.isEmpty ||
          lokasiUserData.isEmpty ||
          lantaiUserData.isEmpty) {
        _errorMessage =
            'Beberapa data master kosong meskipun berhasil ambil dari API.';
        Get.snackbar(
          'Peringatan',
          _errorMessage!,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
      } else {
        Get.snackbar(
          'Sukses',
          'Data berhasil diambil langsung dari API!',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      debugPrint('Gagal ambil data master dari API: $e');
      setState(() {
        _statusAssetFuture = Future.value([]);
        _kondisiAssetFuture = Future.value([]);
        _statusUserAssetFuture = Future.value([]);
        _posisiUserFuture = Future.value([]);
        _divisiUserFuture = Future.value([]);
        _lokasiUserFuture = Future.value([]);
        _lantaiUserFuture = Future.value([]);
        _isLoading = false;
        _errorMessage = 'Gagal ambil data master dari API.';
      });

      Get.snackbar(
        'Error',
        _errorMessage!,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
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
              onPressed: _isLoading ? null : () => _refreshMasterData(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF0E47A1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child:
                  _isLoading
                      ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Color(0xFF0E47A1),
                          ),
                        ),
                      )
                      : const Text('Refresh'),
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
}
