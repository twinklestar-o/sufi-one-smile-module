import 'package:sufi_one/src/services/api_services.dart';
import '../../../../src/database/database_helper.dart';
import '../models/purpose.dart';

class PurposeRepository {
  final DatabaseHelper dbHelper;
  final ApiService apiService;

  PurposeRepository({required this.dbHelper, required this.apiService});

  Future<List<Purpose>> getPurpose({bool forceRefresh = false}) async {
    try {
      if (forceRefresh) {
        return await _fetchFromApiAndSave();
      }

      final localData = await dbHelper.getAllPurpose();
      if (localData.isEmpty) {
        return await _fetchFromApiAndSave();
      }

      final serverLastUpdate = await apiService.fetchLastUpdateTime();
      final localLastUpdate = await dbHelper.getLastUpdateTime(
        'purpose_last_update',
      );

      if (serverLastUpdate != null &&
          (localLastUpdate == null ||
              serverLastUpdate.isAfter(localLastUpdate))) {
        return await _fetchFromApiAndSave();
      }

      return localData;
    } catch (e) {
      // Fallback to local data if error occurs
      final localData = await dbHelper.getAllPurpose();
      if (localData.isNotEmpty) {
        return localData;
      }
      rethrow;
    }
  }

  Future<List<Purpose>> _fetchFromApiAndSave() async {
    try {
      final response = await apiService.fetchPurpose();

      // Pastikan response adalah Map dan memiliki field 'data'
      if (response is! Map<String, dynamic> || !response.containsKey('data')) {
        throw Exception('Invalid API response format');
      }

      // Ekstrak list purpose dari field 'data'
      final List<dynamic> purposeData = response['data'];

      // Konversi ke List<Purpose>
      final List<Purpose> purposeList =
          purposeData.map((json) => Purpose.fromJson(json)).toList();

      // Clear old data
      final db = await dbHelper.database;
      await db.delete('purpose');

      // Insert new data
      for (var purpose in purposeList) {
        await dbHelper.insertPurpose(purpose);
      }

      // Update timestamp
      await dbHelper.updateCollectionTimestamp('purpose_last_update');

      return purposeList;
    } catch (e) {
      // If API fails, try to return local data
      final localData = await dbHelper.getAllPurpose();
      if (localData.isNotEmpty) {
        return localData;
      }
      rethrow;
    }
  }
}
