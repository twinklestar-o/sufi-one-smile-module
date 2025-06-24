import 'package:sqflite/sqflite.dart';
import 'package:sufi_one/src/services/api_services.dart';
import 'package:sufi_one/src/database/database_helper.dart';
import 'package:sufi_one/app/modules/smile/models/branch.dart';

class BranchRepository {
  final DatabaseHelper dbHelper;
  final ApiService apiService;

  BranchRepository({required this.dbHelper, required this.apiService});

  // Fungsi untuk mengambil data cabang
  Future<List<Branch>> getBranch({bool forceRefresh = false}) async {
    try {
      // Jika forceRefresh = true, ambil data dari API dan simpan
      if (forceRefresh) {
        return await _fetchFromApiAndSave();
      }

      // Cek data lokal
      final localData = await dbHelper.getAllBranches();
      if (localData.isEmpty) {
        return await _fetchFromApiAndSave();
      }

      // Cek waktu update dari server dan lokal
      final serverLastUpdate = await apiService.fetchLastUpdateTime();
      final localLastUpdate = await dbHelper.getLastUpdateTime();

      // Jika ada pembaruan di server
      if (serverLastUpdate != null &&
          (localLastUpdate == null || serverLastUpdate.isAfter(localLastUpdate))) {
        return await _fetchFromApiAndSave();
      }

      // Jika data lokal sudah terbaru, kembalikan data lokal
      return localData;
    } catch (e) {
      // Jika terjadi error, fallback ke data lokal
      print('Error fetching branch: $e');
      final localData = await dbHelper.getAllBranches();
      if (localData.isNotEmpty) {
        return localData;
      }
      rethrow;
    }
  }

  // Fungsi untuk mengambil data dari API dan menyimpan di database
  Future<List<Branch>> _fetchFromApiAndSave() async {
    try {
      // Ambil data cabang dari API
      final response = await apiService.fetchBranches();

      // Pastikan response adalah Map dan memiliki field 'data'
      if (response is! Map<String, dynamic> || !response.containsKey('data') || response['data'] == null) {
        throw Exception('Invalid or empty API response format');
      }

      // Ambil data cabang dari field 'data'
      final List<dynamic> branchData = response['data'];

      // Konversi data ke List<Branch>
      final List<Branch> branchList = branchData.map((json) => Branch.fromJson(json)).toList();

      // Clear old data di database dengan batch insert untuk performa yang lebih baik
      final db = await dbHelper.database;
      await db.delete('branches');

      // Gunakan batch insert untuk memasukkan data baru secara efisien
      Batch batch = db.batch();
      for (var branch in branchList) {
        batch.insert('branches', branch.toJson(), conflictAlgorithm: ConflictAlgorithm.replace);
      }
      await batch.commit();

      // Update timestamp pada collections
      await dbHelper.updateCollectionTimestamp();

      return branchList;
    } catch (e) {
      // Jika API gagal, coba kembalikan data lokal
      print('Error fetching branches from API: $e');
      final localData = await dbHelper.getAllBranches();
      if (localData.isNotEmpty) {
        return localData;
      }
      rethrow;
    }
  }
}
