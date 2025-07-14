import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../repositories/jabatan_repository.dart';
import '../../../../models/jabatan.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

class JabatanScreen extends StatefulWidget {
  @override
  _JabatanScreenState createState() => _JabatanScreenState();
}

class _JabatanScreenState extends State<JabatanScreen> {
  late Future<List<Jabatan>> _jabatanFuture;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadLocalDataOnly();
  }

  Future<void> _loadLocalDataOnly() async {
    final repository = Provider.of<JabatanRepository>(context, listen: false);

    // Ambil data lokal saja
    final localData = await repository.dbHelper.getAllJabatans();

    if (!mounted) return;

    setState(() {
      _jabatanFuture = Future.value(localData);
      _isLoading = false;
      _errorMessage =
          localData.isEmpty ? 'Data jabatan kosong (offline)' : null;
    });
  }

  Future<void> _loadData() async {
    final repository = Provider.of<JabatanRepository>(context, listen: false);

    try {
      final data = await repository.getJabatans();
      if (!mounted) return;

      setState(() {
        _jabatanFuture = Future.value(data); // simpan future statis
        _isLoading = false;
        if (data.isEmpty) {
          _errorMessage = 'Data Jabatan kosong';
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

    final repository = Provider.of<JabatanRepository>(context, listen: false);

    try {
      // Selalu coba ambil data terbaru dari API
      final data = await repository.getJabatans(forceRefresh: true);

      setState(() {
        _jabatanFuture = Future.value(data);
        _isLoading = false;
        if (data.isEmpty) {
          _errorMessage = 'Data jabatan kosong setelah refresh dari API.';
        }
      });
    } catch (e) {
      debugPrint('Gagal refresh dari API: $e');

      try {
        // Coba ambil dari database lokal
        final localData = await repository.getJabatans(forceRefresh: false);
        setState(() {
          _jabatanFuture = Future.value(localData);
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
          _jabatanFuture = Future.value([]);
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
          'Daftar Jabatan',
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

    return FutureBuilder<List<Jabatan>>(
      future: _jabatanFuture,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Terjadi kesalahan: ${snapshot.error}'));
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('Tidak ada data jabatan tersedia'));
        }

        final jabatanList = snapshot.data!;
        return RefreshIndicator(
          onRefresh: _refreshData,
          child: ListView.builder(
            itemCount: jabatanList.length,
            itemBuilder: (context, index) {
              final jabatan = jabatanList[index];
              return Card(
                margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                child: ListTile(
                  title: Text(jabatan.name),
                  subtitle: Text('Kode: ${jabatan.kode}'),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
