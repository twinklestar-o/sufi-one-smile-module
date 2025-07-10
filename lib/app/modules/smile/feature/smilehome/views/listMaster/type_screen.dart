import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../repositories/type_repository.dart';
import '../../../../models/type.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

class TypeScreen extends StatefulWidget {
  @override
  _TypeScreenState createState() => _TypeScreenState();
}

class _TypeScreenState extends State<TypeScreen> {
  // Deklarasi Future untuk menampung data Type
  late Future<List<Type>> _typeFuture;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadLocalDataOnly();
  }

  Future<void> _loadLocalDataOnly() async {
    final repository = Provider.of<TypeRepository>(context, listen: false);

    // Ambil data lokal saja
    final localData = await repository.dbHelper.getAllType();

    if (!mounted) return;

    setState(() {
      _typeFuture = Future.value(localData);
      _isLoading = false;
      _errorMessage =
          localData.isEmpty ? 'Data tipe visit kosong (offline)' : null;
    });
  }

  Future<void> _loadData() async {
    final repository = Provider.of<TypeRepository>(context, listen: false);

    try {
      final data = await repository.getType();
      if (!mounted) return;

      setState(() {
        _typeFuture = Future.value(data); // simpan future statis
        _isLoading = false;
        if (data.isEmpty) {
          _errorMessage = 'Data Tipe Visit kosong';
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

    final repository = Provider.of<TypeRepository>(context, listen: false);

    try {
      // Selalu coba ambil data terbaru dari API
      final data = await repository.getType(forceRefresh: true);

      setState(() {
        _typeFuture = Future.value(data);
        _isLoading = false;
        if (data.isEmpty) {
          _errorMessage = 'Data tipe visit kosong setelah refresh dari API.';
        }
      });
    } catch (e) {
      debugPrint('Gagal refresh dari API: $e');

      try {
        // Coba ambil dari database lokal
        final localData = await repository.getType(forceRefresh: false);
        setState(() {
          _typeFuture = Future.value(localData);
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
          _typeFuture = Future.value([]);
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
          'Daftar Tipe Visit',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh), // Ikon refresh
            onPressed: _refreshData, // Panggil _refreshData saat ditekan
            tooltip: 'Refresh Data', // Tooltip untuk ikon
            color: Colors.white,
          ),
        ],
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
      ),
      body: _buildBody(), // Membangun body screen
    );
  }

  // Widget pembangun body screen berdasarkan state loading/error/data
  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      ); // Tampilkan indikator loading
    }

    if (_errorMessage != null) {
      // Tampilkan pesan error dan tombol coba lagi
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _errorMessage!,
              style: const TextStyle(color: Colors.red, fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _loadData,
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      );
    }

    // Menggunakan FutureBuilder untuk menampilkan data setelah _typeFuture selesai
    return FutureBuilder<List<Type>>(
      future: _typeFuture,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          // Tangani error yang mungkin muncul dari FutureBuilder
          return Center(child: Text('Terjadi kesalahan: ${snapshot.error}'));
        }

        // Jika tidak ada data atau data kosong
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('Tidak ada data Type tersedia'));
        }

        // Jika data tersedia, tampilkan dalam ListView
        final typeList = snapshot.data!;
        return RefreshIndicator(
          onRefresh: _refreshData,
          child: ListView.builder(
            itemCount: typeList.length,
            itemBuilder: (context, index) {
              final type = typeList[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                child: ListTile(
                  title: Text(type.name ?? 'No Name'),
                  subtitle: Text('ID: ${type.id ?? 'N/A'}'),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
