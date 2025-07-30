import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:sufi_one/app/modules/DAMS/repository/divisi_user_repository.dart';
import 'package:sufi_one/app/modules/DAMS/repository/kondisi_asset_repository.dart';
import 'package:sufi_one/app/modules/DAMS/repository/lantai_user_repository.dart';
import 'package:sufi_one/app/modules/DAMS/repository/lokasi_user_repository.dart';
import 'package:sufi_one/app/modules/DAMS/repository/posisi_user_repository.dart';
import 'package:sufi_one/app/modules/DAMS/repository/status_asset_repository.dart';
import 'package:sufi_one/app/modules/DAMS/repository/status_user_asset_repository.dart';
import 'package:sufi_one/app/modules/smile/models/purpose.dart';
import 'package:sufi_one/app/modules/smile/repositories/area_repository.dart';
import 'package:sufi_one/app/modules/smile/repositories/branch_repository.dart';
import 'package:sufi_one/app/modules/smile/repositories/dealer_repository.dart';
import 'package:sufi_one/app/modules/smile/repositories/jabatanSFI_repository.dart';
import 'package:sufi_one/app/modules/smile/repositories/jabatan_repository.dart';
import 'package:sufi_one/app/modules/smile/repositories/product_repository.dart';
import 'package:sufi_one/app/modules/smile/repositories/purpose_repository.dart';
import 'package:sufi_one/app/modules/smile/repositories/type_repository.dart';
import 'package:sufi_one/app/modules/smile/smile_route.dart';

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
  Future<List>? _areaFuture;
  Future<List>? _cabangFuture;
  Future<List>? _dealerFuture;
  Future<List>? _jabatanFuture;
  Future<List>? _jabatansfiFuture;
  Future<List>? _productFuture;
  Future<List>? _typeFuture;
  Future<List>? _purposeFuture;

  final List<Map<String, dynamic>> masterItems = const [
    {'title': 'AREA', 'route': SmileRoutes.area},
    {'title': 'CABANG', 'route': SmileRoutes.branch},
    {'title': 'DEALER', 'route': SmileRoutes.dealer},
    {'title': 'JABATAN', 'route': SmileRoutes.jabatan},
    {'title': 'JABATAN SFI', 'route': SmileRoutes.jabatanSFI},
    {'title': 'PRODUK', 'route': SmileRoutes.product},
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
    final areaRepository = Provider.of<AreaRepository>(context, listen: false);
    final cabangRepository = Provider.of<BranchRepository>(
      context,
      listen: false,
    );
    final dealerRepository = Provider.of<DealerRepository>(
      context,
      listen: false,
    );
    final jabatanRepository = Provider.of<JabatanRepository>(
      context,
      listen: false,
    );
    final jabatansfiRepository = Provider.of<JabatanSFIRepository>(
      context,
      listen: false,
    );
    final productRepository = Provider.of<ProductRepository>(
      context,
      listen: false,
    );
    final typeRepository = Provider.of<TypeRepository>(context, listen: false);
    final purposeRepository = Provider.of<PurposeRepository>(
      context,
      listen: false,
    );
    try {
      // Paksa ambil dari API
      final results = await Future.wait([
        areaRepository.getAreas(),
        cabangRepository.getBranches(forceRefresh: true),
        dealerRepository.getDealers(forceRefresh: true),
        jabatanRepository.getJabatans(forceRefresh: true),
        jabatansfiRepository.getJabatanSFIs(forceRefresh: true),
        productRepository.getProducts(forceRefresh: true),
        typeRepository.getTypes(forceRefresh: true),
        purposeRepository.getPurposes(forceRefresh: true),
      ]);

      final areaData = results[0];
      final cabangData = results[1];
      final dealerData = results[2];
      final jabatanData = results[3];
      final jabatansfiData = results[4];
      final productData = results[5];
      final typeData = results[6];
      final purposeData = results[7];

      setState(() {
        _areaFuture = Future.value(areaData);
        _cabangFuture = Future.value(cabangData);
        _dealerFuture = Future.value(dealerData);
        _jabatanFuture = Future.value(jabatanData);
        _jabatansfiFuture = Future.value(jabatansfiData);
        _productFuture = Future.value(productData);
        _typeFuture = Future.value(typeData);
        _purposeFuture = Future.value(purposeData);
        _isLoading = false;
      });

      // Validasi apakah ada data kosong
      if (areaData.isEmpty ||
          cabangData.isEmpty ||
          dealerData.isEmpty ||
          jabatanData.isEmpty ||
          jabatansfiData.isEmpty ||
          productData.isEmpty ||
          purposeData.isEmpty ||
          typeData.isEmpty) {
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
        _areaFuture = Future.value([]);
        _cabangFuture = Future.value([]);
        _dealerFuture = Future.value([]);
        _jabatanFuture = Future.value([]);
        _jabatansfiFuture = Future.value([]);
        _productFuture = Future.value([]);
        _typeFuture = Future.value([]);
        _purposeFuture = Future.value([]);
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
      body: Stack(
        children: [
          ListView.builder(
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
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0E47A1)),
              ),
            ),
        ],
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
