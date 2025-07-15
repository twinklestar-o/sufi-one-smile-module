import 'package:sufi_one/app/modules/DAMS/model/lantai_user.dart';
import 'package:sufi_one/src/database/DAMS/database_helper.dart';
import 'package:sufi_one/src/services/DAMS/api_services.dart';

class LantaiUserRepository {
  final DatabaseHelperDams dbHelper;
  final ApiServiceDams apiService;

  LantaiUserRepository({required this.dbHelper, required this.apiService});

  Future<List<LantaiUser>> getLantaiUser({bool forceRefresh = false}) async {
    try {
      if (forceRefresh) {
        return await _fetchFromApiAndSave();
      }

      final localData = await dbHelper.getAllLantaiUser();
      if (localData.isEmpty) {
        return await _fetchFromApiAndSave();
      }

      final localLastUpdate = await dbHelper.getLastUpdateTime(
        'lantai_user_last_update',
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
      final localData = await dbHelper.getAllLantaiUser();
      if (localData.isNotEmpty) {
        return localData;
      }
      rethrow;
    }
  }

  Future<List<LantaiUser>> _fetchFromApiAndSave() async {
    try {
      final response = await apiService.fetchLantaiUser();

      // Pastikan response adalah Map dan memiliki field 'data'
      if (response is! Map<String, dynamic> || !response.containsKey('data')) {
        throw Exception('Invalid API response format');
      }

      // Ekstrak list lantai user dari field 'data'
      final List<dynamic> lantaiUserData = response['data'];

      // Konversi ke List<LantaiUser>
      final List<LantaiUser> lantaiUserList =
          lantaiUserData.map((json) => LantaiUser.fromJson(json)).toList();

      // Clear old data
      final db = await dbHelper.database;
      await db.delete('lantaiUser');

      // Insert new data
      for (var lantaiUser in lantaiUserList) {
        await dbHelper.insertLantaiUser(lantaiUser);
      }

      // Update timestamp
      await dbHelper.updateCollectionTimestamp('lantai_user_last_update');

      return lantaiUserList;
    } catch (e) {
      // If API fails, try to return local data
      final localData = await dbHelper.getAllLantaiUser();
      if (localData.isNotEmpty) {
        return localData;
      }
      rethrow;
    }
  }
}
