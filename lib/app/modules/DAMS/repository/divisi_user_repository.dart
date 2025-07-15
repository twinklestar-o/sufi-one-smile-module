import 'package:sufi_one/app/modules/DAMS/model/divisi_user.dart';
import 'package:sufi_one/src/database/DAMS/database_helper.dart';
import 'package:sufi_one/src/services/DAMS/api_services.dart';

class DivisiUserRepository {
  final DatabaseHelperDams dbHelper;
  final ApiServiceDams apiService;

  DivisiUserRepository({required this.dbHelper, required this.apiService});

  Future<List<DivisiUser>> getDivisiUser({bool forceRefresh = false}) async {
    try {
      if (forceRefresh) {
        return await _fetchFromApiAndSave();
      }

      final localData = await dbHelper.getAllDivisiUser();
      if (localData.isEmpty) {
        return await _fetchFromApiAndSave();
      }

      final localLastUpdate = await dbHelper.getLastUpdateTime(
        'divisi_user_last_update',
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
      final localData = await dbHelper.getAllDivisiUser();
      if (localData.isNotEmpty) {
        return localData;
      }
      rethrow;
    }
  }

  Future<List<DivisiUser>> _fetchFromApiAndSave() async {
    try {
      final response = await apiService.fetchDivisiUser();

      // Pastikan response adalah Map dan memiliki field 'data'
      if (response is! Map<String, dynamic> || !response.containsKey('data')) {
        throw Exception('Invalid API response format');
      }

      // Ekstrak list divisi user dari field 'data'
      final List<dynamic> divisiUserData = response['data'];

      // Konversi ke List<DivisiUser>
      final List<DivisiUser> divisiUserList =
          divisiUserData.map((json) => DivisiUser.fromJson(json)).toList();

      // Clear old data
      final db = await dbHelper.database;
      await db.delete('divisiUser');

      // Insert new data
      for (var divisiUser in divisiUserList) {
        await dbHelper.insertDivisiUser(divisiUser);
      }

      // Update timestamp
      await dbHelper.updateCollectionTimestamp('divisi_user_last_update');

      return divisiUserList;
    } catch (e) {
      // If API fails, try to return local data
      final localData = await dbHelper.getAllDivisiUser();
      if (localData.isNotEmpty) {
        return localData;
      }
      rethrow;
    }
  }
}
