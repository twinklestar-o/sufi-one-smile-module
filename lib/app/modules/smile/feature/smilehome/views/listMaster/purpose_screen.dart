import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:sufi_one/app/modules/smile/models/purpose.dart';
import 'package:sufi_one/app/modules/smile/repositories/purpose_repository.dart';
import 'package:get/get_core/src/get_main.dart';

class PurposeScreen extends StatefulWidget {
  @override
  _PurposeScreenState createState() => _PurposeScreenState();
}

class _PurposeScreenState extends State<PurposeScreen> {
  late Future<List<Purpose>> _purposeFuture;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadLocalDataOnly();
  }

  Future<void> _loadLocalDataOnly() async {
    final repository = Provider.of<PurposeRepository>(context, listen: false);

    // Ambil data lokal saja
    final localData = await repository.dbHelper.getAllPurposes();

    if (!mounted) return;

    setState(() {
      _purposeFuture = Future.value(localData);
      _isLoading = false;
      _errorMessage =
          localData.isEmpty ? 'Data tujuan visit kosong (offline)' : null;
    });
  }

  Future<void> _loadData() async {
    final repository = Provider.of<PurposeRepository>(context, listen: false);

    try {
      final data = await repository.getPurposes();
      if (!mounted) return;

      setState(() {
        _purposeFuture = Future.value(data); // simpan future statis
        _isLoading = false;
        if (data.isEmpty) {
          _errorMessage = 'Data Tujuan Visit kosong';
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Gagal memuat data: ${e.toString()}';
      });
    }
  }

  Future<void> _refreshData() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final repository = Provider.of<PurposeRepository>(context, listen: false);

    try {
      // Selalu coba ambil data terbaru dari API
      final data = await repository.getPurposes(forceRefresh: true);

      setState(() {
        _purposeFuture = Future.value(data);
        _isLoading = false;
        if (data.isEmpty) {
          _errorMessage = 'Data tujuan visit kosong setelah refresh dari API.';
        }
      });
    } catch (e) {
      debugPrint('Gagal refresh dari API: $e');

      try {
        // Coba ambil dari database lokal
        final localData = await repository.getPurposes(forceRefresh: false);
        setState(() {
          _purposeFuture = Future.value(localData);
          _isLoading = false;

          if (localData.isEmpty) {
            _errorMessage = 'Gagal ambil dari API & database lokal kosong.';
          } else {
            _errorMessage = 'Gagal ambil dari API, tampilkan data lokal.';
          }
        });
      } catch (e2) {
        debugPrint('Gagal ambil dari lokal juga: $e2');
        setState(() {
          _purposeFuture = Future.value([]);
          _isLoading = false;
          _errorMessage = 'Gagal total: tidak bisa ambil data.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0E47A1),
        title: const Text(
          'Daftar Tujuan Visit',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _refreshData,
            tooltip: 'Refresh Data',
            color: Colors.white,
          ),
        ],
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _errorMessage!,
              style: TextStyle(color: Colors.red, fontSize: 16),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            ElevatedButton(onPressed: _loadData, child: Text('Coba Lagi')),
          ],
        ),
      );
    }

    return FutureBuilder<List<Purpose>>(
      future: _purposeFuture,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Terjadi kesalahan: ${snapshot.error}'));
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('Tidak ada data purpose tersedia'));
        }

        final purposeList = snapshot.data!;
        return RefreshIndicator(
          onRefresh: _refreshData,
          child: ListView.builder(
            itemCount: purposeList.length,
            itemBuilder: (context, index) {
              final purpose = purposeList[index];
              return Card(
                margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                child: ListTile(
                  title: Text(purpose.name),
                  subtitle: Text('Kode: ${purpose.kode}'),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
