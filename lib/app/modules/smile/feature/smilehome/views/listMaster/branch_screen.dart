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
    _loadData();
  }

  Future<void> _loadData() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final repository = Provider.of<BranchRepository>(context, listen: false);
      _branchFuture = repository.getBranch();

      final data = await _branchFuture;

      if (data.isEmpty) {
        setState(() {
          _errorMessage = 'Data branch kosong';
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      debugPrint('Error loading data: $e');
      setState(() {
        _errorMessage = 'Gagal memuat data: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Future<void> _refreshData() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final repository = Provider.of<BranchRepository>(context, listen: false);
      _branchFuture = repository.getBranch(forceRefresh: true);

      final data = await _branchFuture;

      setState(() {
        _isLoading = false;
        if (data.isEmpty) {
          _errorMessage = 'Data branch kosong setelah refresh';
        }
      });
    } catch (e) {
      debugPrint('Error refreshing: $e');
      setState(() {
        _errorMessage = 'Gagal refresh: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Daftar Branch',
          style: TextStyle(
            color: Colors.white, // Mengubah warna teks judul menjadi putih
          ),
        ),
        backgroundColor: Color(0xFF0E47A1), // Mengubah warna background AppBar dengan kode hex
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _refreshData,
            tooltip: 'Refresh Data',
            color: Colors.white, // Mengubah warna icon di AppBar menjadi putih
          ),
        ],
        iconTheme: IconThemeData(
          color: Colors.white, // Mengubah warna icon panah kembali menjadi putih
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
                  subtitle: Text('Kode: ${branch.code} | Area: ${branch.areaCode}'),
                  trailing: Icon(Icons.chevron_right),
                  onTap: () {
                    // Aksi ketika item branch ditekan
                    // Misalnya navigasi ke halaman detail atau edit branch
                  },
                ),
              );
            },
          ),
        );
      },
    );
  }
}
