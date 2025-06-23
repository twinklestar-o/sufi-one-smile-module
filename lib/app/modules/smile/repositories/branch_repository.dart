import 'package:sufi_one/src/services/api_services.dart';
import '../../../../src/database/database_helper.dart';
import '../models/branch.dart';

class BranchRepository {
  final DatabaseHelper dbHelper;
  final ApiService apiService;

  BranchRepository({required this.dbHelper, required this.apiService});

  // Mengambil data cabang
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

      if (serverLastUpdate != null &&
          (localLastUpdate == null ||
              serverLastUpdate.isAfter(localLastUpdate))) {
        return await _fetchFromApiAndSave();
      }

      // Jika data lokal sudah terbaru, kembalikan data lokal
      return localData;
    } catch (e) {
      // Jika terjadi error, fallback ke data lokal
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
      if (response is! Map<String, dynamic> || !response.containsKey('data')) {
        throw Exception('Invalid API response format');
      }

      // Ambil data cabang dari field 'data'
      final List<dynamic> branchData = response['data'];

      // Konversi data ke List<Branch>
      final List<Branch> branchList =
      branchData.map((json) => Branch.fromJson(json)).toList();

      // Clear old data di database
      final db = await dbHelper.database;
      await db.delete('branches');

      // Insert data baru ke database
      for (var branch in branchList) {
        await dbHelper.insertBranch(branch);
      }

      // Update timestamp pada collections
      await dbHelper.updateCollectionTimestamp();

      return branchList;
    } catch (e) {
      // Jika API gagal, coba kembalikan data lokal
      final localData = await dbHelper.getAllBranches();
      if (localData.isNotEmpty) {
        return localData;
      }
      rethrow;
    }
  }
}
