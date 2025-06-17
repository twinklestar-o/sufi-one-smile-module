import 'package:sufi_one/src/services/api_services.dart';
import '../database/database_helper.dart';
import '../models/jabatan.dart';

class JabatanRepository {
  final DatabaseHelper dbHelper;
  final ApiService apiService;

  JabatanRepository({required this.dbHelper, required this.apiService});

  Future<List<Jabatan>> getJabatan({bool forceRefresh = false}) async {
    try {
      if (forceRefresh) {
        return await _fetchFromApiAndSave();
      }

      final localData = await dbHelper.getAllJabatan();
      if (localData.isEmpty) {
        return await _fetchFromApiAndSave();
      }

      final serverLastUpdate = await apiService.fetchLastUpdateTime();
      final localLastUpdate = await dbHelper.getLastUpdateTime();

      if (serverLastUpdate != null &&
          (localLastUpdate == null ||
              serverLastUpdate.isAfter(localLastUpdate))) {
        return await _fetchFromApiAndSave();
      }

      return localData;
    } catch (e) {
      // Fallback to local data if error occurs
      final localData = await dbHelper.getAllJabatan();
      if (localData.isNotEmpty) {
        return localData;
      }
      rethrow;
    }
  }

  Future<List<Jabatan>> _fetchFromApiAndSave() async {
    try {
      final response = await apiService.fetchJabatan();

      // Pastikan response adalah Map dan memiliki field 'data'
      if (response is! Map<String, dynamic> || !response.containsKey('data')) {
        throw Exception('Invalid API response format');
      }

      // Ekstrak list jabatan dari field 'data'
      final List<dynamic> jabatanData = response['data'];

      // Konversi ke List<Jabatan>
      final List<Jabatan> jabatanList =
          jabatanData.map((json) => Jabatan.fromJson(json)).toList();

      // Clear old data
      final db = await dbHelper.database;
      await db.delete('jabatan');

      // Insert new data
      for (var jabatan in jabatanList) {
        await dbHelper.insertJabatan(jabatan);
      }

      // Update timestamp
      await dbHelper.updateCollectionTimestamp();

      return jabatanList;
    } catch (e) {
      // If API fails, try to return local data
      final localData = await dbHelper.getAllJabatan();
      if (localData.isNotEmpty) {
        return localData;
      }
      rethrow;
    }
  }
}
