import 'package:sufi_one/src/services/api_services.dart';
import '../../../../src/database/database_helper.dart';
import '../models/jabatanSFI.dart';

class JabatanSFIRepository {
  final DatabaseHelper dbHelper;
  final ApiService apiService;

  JabatanSFIRepository({required this.dbHelper, required this.apiService});

  Future<List<JabatanSFI>> getJabatanSFI({bool forceRefresh = false}) async {
    try {
      if (forceRefresh) {
        return await _fetchFromApiAndSave();
      }

      final localData = await dbHelper.getAllJabatanSFI();
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
      final localData = await dbHelper.getAllJabatanSFI();
      if (localData.isNotEmpty) {
        return localData;
      }
      rethrow;
    }
  }

  Future<List<JabatanSFI>> _fetchFromApiAndSave() async {
    try {
      final response = await apiService.fetchJabatanSFI();

      // Pastikan response adalah Map dan memiliki field 'data'
      if (response is! Map<String, dynamic> || !response.containsKey('data')) {
        throw Exception('Invalid API response format');
      }

      // Ekstrak list JabatanSFI dari field 'data'
      final List<dynamic> jabatanSFIData = response['data'];

      // Konversi ke List<JabatanSFI>
      final List<JabatanSFI> jabatanSFIList =
      jabatanSFIData.map((json) => JabatanSFI.fromJson(json)).toList();

      // Clear old data
      final db = await dbHelper.database;
      await db.delete('jabatanSFI');

      // Insert new data
      for (var jabatanSFI in jabatanSFIList) {
        await dbHelper.insertJabatanSFI(jabatanSFI);
      }

      // Update timestamp
      await dbHelper.updateCollectionTimestamp();

      return jabatanSFIList;
    } catch (e) {
      // If API fails, try to return local data
      final localData = await dbHelper.getAllJabatanSFI();
      if (localData.isNotEmpty) {
        return localData;
      }
      rethrow;
    }
  }
}
