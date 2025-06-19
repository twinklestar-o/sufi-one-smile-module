import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sufi_one/app/modules/smile/models/area.dart';
import 'package:sufi_one/app/modules/smile/repositories/area_repository.dart';

class AreaScreen extends StatefulWidget {
  @override
  _AreaScreenState createState() => _AreaScreenState();
}

class _AreaScreenState extends State<AreaScreen> {
  late Future<List<Area>> _areaFuture;
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
      final repository = Provider.of<AreaRepository>(context, listen: false);
      _areaFuture = repository.getArea();

      final data = await _areaFuture;

      if (data.isEmpty) {
        setState(() {
          _errorMessage = 'Data Area kosong';
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
      final repository = Provider.of<AreaRepository>(context, listen: false);
      _areaFuture = repository.getArea(forceRefresh: true);

      final data = await _areaFuture;

      setState(() {
        _isLoading = false;
        if (data.isEmpty) {
          _errorMessage = 'Data Area kosong setelah refresh';
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
        title: Text('Daftar Area'),
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

    return FutureBuilder<List<Area>>(
      future: _areaFuture,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Terjadi kesalahan: ${snapshot.error}'));
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('Tidak ada data area tersedia'));
        }

        final areaList = snapshot.data!;
        return RefreshIndicator(
          onRefresh: _refreshData,
          child: ListView.builder(
            itemCount: areaList.length,
            itemBuilder: (context, index) {
              final area = areaList[index];
              return Card(
                margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                child: ListTile(
                  title: Text(area.name),
                  subtitle: Text('Kode: ${area.code}'),
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
