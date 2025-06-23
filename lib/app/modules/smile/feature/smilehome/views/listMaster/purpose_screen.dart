import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sufi_one/app/modules/smile/models/purpose.dart';
import 'package:sufi_one/app/modules/smile/repositories/purpose_repository.dart';

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
    _loadData();
  }

  Future<void> _loadData() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final repository = Provider.of<PurposeRepository>(context, listen: false);
      _purposeFuture = repository.getPurpose();

      final data = await _purposeFuture;

      if (data.isEmpty) {
        setState(() {
          _errorMessage = 'Data purpose kosong';
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
      final repository = Provider.of<PurposeRepository>(context, listen: false);
      _purposeFuture = repository.getPurpose(forceRefresh: true);

      final data = await _purposeFuture;

      setState(() {
        _isLoading = false;
        if (data.isEmpty) {
          _errorMessage = 'Data purpose kosong setelah refresh';
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
        title: Text('Daftar Purpose'),
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