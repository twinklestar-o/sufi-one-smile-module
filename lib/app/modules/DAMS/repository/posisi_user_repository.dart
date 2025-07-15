import 'package:sufi_one/app/modules/DAMS/model/posisi_user.dart';
import 'package:sufi_one/src/database/DAMS/database_helper.dart';
import 'package:sufi_one/src/services/DAMS/api_services.dart';

class PosisiUserRepository {
  final DatabaseHelperDams dbHelper;
  final ApiServiceDams apiService;

  PosisiUserRepository({required this.dbHelper, required this.apiService});

  Future<List<PosisiUser>> getPosisiUser({bool forceRefresh = false}) async {
    try {
      if (forceRefresh) {
        return await _fetchFromApiAndSave();
      }

      final localData = await dbHelper.getAllPosisiUser();
      if (localData.isEmpty) {
        return await _fetchFromApiAndSave();
      }

      final localLastUpdate = await dbHelper.getLastUpdateTime(
        'posisi_user_last_update',
      );

      final serverLastUpdate = await apiService.fetchLastUpdateTime();

      if (serverLastUpdate != null &&
          (localLastUpdate == null ||
              serverLastUpdate.isAfter(localLastUpdate))) {
        return await _fetchFromApiAndSave();
      }
      return localData;
    } catch (e) {
      // Fallback to local data if error occurs
      final localData = await dbHelper.getAllPosisiUser();
      if (localData.isNotEmpty) {
        return localData;
      }
      rethrow;
    }
  }

  Future<List<PosisiUser>> _fetchFromApiAndSave() async {
    try {
      final response = await apiService.fetchPosisiUser();

      // Pastikan response adalah Map dan memiliki field 'data'
      if (response is! Map<String, dynamic> || !response.containsKey('data')) {
        throw Exception('Invalid API response format');
      }

      // Ekstrak list posisi user dari field 'data'
      final List<dynamic> posisiUserData = response['data'];

      // Konversi ke List<PosisiUser>
      final List<PosisiUser> posisiUserList =
          posisiUserData.map((json) => PosisiUser.fromJson(json)).toList();

      // Clear old data
      final db = await dbHelper.database;
      await db.delete('posisiUser');

      // Insert new data
      for (var posisiUser in posisiUserList) {
        await dbHelper.insertPosisiUser(posisiUser);
      }

      // Update timestamp
      await dbHelper.updateCollectionTimestamp('posisi_user_last_update');

      return posisiUserList;
    } catch (e) {
      // If API fails, try to return local data
      final localData = await dbHelper.getAllPosisiUser();
      if (localData.isNotEmpty) {
        return localData;
      }
      rethrow;
    }
  }
}
