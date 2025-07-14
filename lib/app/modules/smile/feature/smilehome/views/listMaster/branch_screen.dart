import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../repositories/branch_repository.dart';
import '../../../../models/branch.dart';

class BranchScreen extends StatefulWidget {
  @override
  _BranchScreenState createState() => _BranchScreenState();
}

class _BranchScreenState extends State<BranchScreen> {
  late Future<List<Branch>> _branchFuture;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadLocalDataOnly();
  }

  Future<void> _loadLocalDataOnly() async {
    final repository = Provider.of<BranchRepository>(context, listen: false);

    // Ambil data lokal saja
    final localData = await repository.dbHelper.getAllBranches();

    if (!mounted) return;

    setState(() {
      _branchFuture = Future.value(localData);
      _isLoading = false;
      _errorMessage = localData.isEmpty ? 'Data cabang kosong (offline)' : null;
    });
  }

  Future<void> _loadData() async {
    final repository = Provider.of<BranchRepository>(context, listen: false);

    try {
      final data = await repository.getBranches();
      if (!mounted) return;

      setState(() {
        _branchFuture = Future.value(data); // simpan future statis
        _isLoading = false;
        if (data.isEmpty) {
          _errorMessage = 'Data Cabang kosong';
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

    final repository = Provider.of<BranchRepository>(context, listen: false);

    try {
      // Selalu coba ambil data terbaru dari API
      final data = await repository.getBranches(forceRefresh: true);

      setState(() {
        _branchFuture = Future.value(data);
        _isLoading = false;
        if (data.isEmpty) {
          _errorMessage = 'Data cabang kosong setelah refresh dari API.';
        }
      });
    } catch (e) {
      debugPrint('Gagal refresh dari API: $e');

      try {
        // Coba ambil dari database lokal
        final localData = await repository.getBranches(forceRefresh: false);
        setState(() {
          _branchFuture = Future.value(localData);
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
          _branchFuture = Future.value([]);
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
          'Daftar Cabang',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ), // Mengubah warna background AppBar dengan kode hex
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _refreshData,
            tooltip: 'Refresh Data',
            color: Colors.white, // Mengubah warna icon di AppBar menjadi putih
          ),
        ],
        iconTheme: IconThemeData(
          color:
              Colors.white, // Mengubah warna icon panah kembali menjadi putih
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

    return FutureBuilder<List<Branch>>(
      future: _branchFuture,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Terjadi kesalahan: ${snapshot.error}'));
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('Tidak ada data branch tersedia'));
        }

        final branchList = snapshot.data!;
        return RefreshIndicator(
          onRefresh: _refreshData,
          child: ListView.builder(
            itemCount: branchList.length,
            itemBuilder: (context, index) {
              final branch = branchList[index];
              return Card(
                margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                child: ListTile(
                  title: Text(branch.name),
                  subtitle: Text(
                    'Kode: ${branch.code} | Area: ${branch.areaCode}',
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
