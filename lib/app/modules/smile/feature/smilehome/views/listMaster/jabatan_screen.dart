import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../repositories/jabatan_repository.dart';
import '../../../../models/jabatan.dart';

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
    _loadData();
  }

  Future<void> _loadData() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final repository = Provider.of<JabatanRepository>(context, listen: false);
      _jabatanFuture = repository.getJabatan();

      final data = await _jabatanFuture;

      if (data.isEmpty) {
        setState(() {
          _errorMessage = 'Data jabatan kosong';
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
      final repository = Provider.of<JabatanRepository>(context, listen: false);
      _jabatanFuture = repository.getJabatan(forceRefresh: true);

      final data = await _jabatanFuture;

      setState(() {
        _isLoading = false;
        if (data.isEmpty) {
          _errorMessage = 'Data jabatan kosong setelah refresh';
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
        title: Text('Daftar Jabatan'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _refreshData,
            tooltip: 'Refresh Data',
          ),
        ],
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
