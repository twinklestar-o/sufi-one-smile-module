import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../repositories/type_repository.dart';
import '../../../../models/type.dart';

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
    _loadData(); // Memuat data saat screen diinisialisasi
  }

  // Fungsi untuk memuat data Type
  Future<void> _loadData() async {
    // Memastikan widget masih terpasang di pohon widget sebelum melakukan setState
    if (!mounted) return;

    setState(() {
      _isLoading = true; // Set loading state menjadi true
      _errorMessage = null; // Hapus pesan error sebelumnya
    });

    try {
      // Mengambil instance TypeRepository dari Provider
      final repository = Provider.of<TypeRepository>(context, listen: false);
      // Memanggil method getType untuk mendapatkan data
      _typeFuture = repository.getType();

      // Menunggu hingga data selesai diambil
      final data = await _typeFuture;

      if (data.isEmpty) {
        // Jika data kosong, set pesan error dan hentikan loading
        setState(() {
          _errorMessage = 'Data Type kosong';
          _isLoading = false;
        });
      } else {
        // Jika data ada, hentikan loading
        setState(() => _isLoading = false);
      }
    } catch (e) {
      // Tangani error jika terjadi saat memuat data
      debugPrint('Error loading Type data: $e');
      setState(() {
        _errorMessage = 'Gagal memuat data Type: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  // Fungsi untuk merefresh data Type
  Future<void> _refreshData() async {
    // Memastikan widget masih terpasang di pohon widget
    if (!mounted) return;

    setState(() {
      _isLoading = true; // Set loading state menjadi true
      _errorMessage = null; // Hapus pesan error sebelumnya
    });

    try {
      // Mengambil instance TypeRepository dari Provider
      final repository = Provider.of<TypeRepository>(context, listen: false);
      // Memanggil method getType dengan forceRefresh: true untuk memaksa pengambilan dari API
      _typeFuture = repository.getType(forceRefresh: true);

      // Menunggu hingga data selesai direfresh
      final data = await _typeFuture;

      setState(() {
        _isLoading = false; // Hentikan loading
        if (data.isEmpty) {
          // Jika data kosong setelah refresh, set pesan error
          _errorMessage = 'Data Type kosong setelah refresh';
        }
      });
    } catch (e) {
      // Tangani error jika terjadi saat merefresh data
      debugPrint('Error refreshing Type data: $e');
      setState(() {
        _errorMessage = 'Gagal refresh data Type: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Type'), // Judul AppBar
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh), // Ikon refresh
            onPressed: _refreshData, // Panggil _refreshData saat ditekan
            tooltip: 'Refresh Data Type', // Tooltip untuk ikon
          ),
        ],
      ),
      body: _buildBody(), // Membangun body screen
    );
  }

  // Widget pembangun body screen berdasarkan state loading/error/data
  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator()); // Tampilkan indikator loading
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
            ElevatedButton(onPressed: _loadData, child: const Text('Coba Lagi')),
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
          onRefresh: _refreshData, // Panggil _refreshData saat user melakukan pull-to-refresh
          child: ListView.builder(
            itemCount: typeList.length,
            itemBuilder: (context, index) {
              final type = typeList[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                child: ListTile(
                  title: Text(type.name ?? 'No Name'), // Asumsi model Type memiliki properti 'name'
                  subtitle: Text('ID: ${type.id ?? 'N/A'}'), // Asumsi model Type memiliki properti 'id'
                  // Anda bisa menambahkan detail lain dari model Type di sini
                  // Contoh: subtitle: Text('Deskripsi: ${type.description ?? ''}'),
                  trailing: const Icon(Icons.chevron_right),
                ),
              );
            },
          ),
        );
      },
    );
  }
}