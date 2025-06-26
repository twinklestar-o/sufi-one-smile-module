import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../repositories/jabatanSFI_repository.dart';
import '../../../../models/jabatanSFI.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

class JabatanSFIScreen extends StatefulWidget {
  @override
  _JabatanSFIScreenState createState() => _JabatanSFIScreenState();
}

class _JabatanSFIScreenState extends State<JabatanSFIScreen> {
  late Future<List<JabatanSFI>> _jabatanSFIFuture;
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
      final repository = Provider.of<JabatanSFIRepository>(context, listen: false);
      _jabatanSFIFuture = repository.getJabatanSFI();

      final data = await _jabatanSFIFuture;

      if (data.isEmpty) {
        setState(() {
          _errorMessage = 'Data jabatan SFI kosong';
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
      final repository = Provider.of<JabatanSFIRepository>(context, listen: false);
      _jabatanSFIFuture = repository.getJabatanSFI(forceRefresh: true);

      final data = await _jabatanSFIFuture;

      setState(() {
        _isLoading = false;
        if (data.isEmpty) {
          _errorMessage = 'Data jabatanSFI kosong setelah refresh';
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
        backgroundColor: const Color(0xFF0E47A1),
        title: const Text(
          'Daftar Jabatan SFI',
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

    return FutureBuilder<List<JabatanSFI>>(
      future: _jabatanSFIFuture,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Terjadi kesalahan: ${snapshot.error}'));
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('Tidak ada data jabatanSFI tersedia'));
        }

        final jabatanSFIList = snapshot.data!;
        return RefreshIndicator(
          onRefresh: _refreshData,
          child: ListView.builder(
            itemCount: jabatanSFIList.length,
            itemBuilder: (context, index) {
              final jabatanSFI = jabatanSFIList[index];
              return Card(
                margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                child: ListTile(
                  title: Text(jabatanSFI.name),
                  subtitle: Text('Kode: ${jabatanSFI.kode}'),
                  trailing: Icon(Icons.chevron_right),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
