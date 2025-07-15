import 'package:sufi_one/app/modules/DAMS/model/lokasi_user.dart';
import 'package:sufi_one/src/database/DAMS/database_helper.dart';
import 'package:sufi_one/src/services/DAMS/api_services.dart';

class LokasiUserRepository {
  final DatabaseHelperDams dbHelper;
  final ApiServiceDams apiService;

  LokasiUserRepository({required this.dbHelper, required this.apiService});

  Future<List<LokasiUser>> getLokasiUser({bool forceRefresh = false}) async {
    try {
      if (forceRefresh) {
        return await _fetchFromApiAndSave();
      }

      final localData = await dbHelper.getAllLokasiUser();
      if (localData.isEmpty) {
        return await _fetchFromApiAndSave();
      }

      final localLastUpdate = await dbHelper.getLastUpdateTime(
        'lokasi_user_last_update',
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
      final localData = await dbHelper.getAllLokasiUser();
      if (localData.isNotEmpty) {
        return localData;
      }
      rethrow;
    }
  }

  Future<List<LokasiUser>> _fetchFromApiAndSave() async {
    try {
      final response = await apiService.fetchLokasiUser();

      // Pastikan response adalah Map dan memiliki field 'data'
      if (response is! Map<String, dynamic> || !response.containsKey('data')) {
        throw Exception('Invalid API response format');
      }

      // Ekstrak list lokasi user dari field 'data'
      final List<dynamic> lokasiUserData = response['data'];

      // Konversi ke List<LokasiUser>
      final List<LokasiUser> lokasiUserList =
          lokasiUserData.map((json) => LokasiUser.fromJson(json)).toList();

      // Clear old data
      final db = await dbHelper.database;
      await db.delete('lokasiUser');

      // Insert new data
      for (var lokasiUser in lokasiUserList) {
        await dbHelper.insertLokasiUser(lokasiUser);
      }

      // Update timestamp
      await dbHelper.updateCollectionTimestamp('lokasi_user_last_update');

      return lokasiUserList;
    } catch (e) {
      // If API fails, try to return local data
      final localData = await dbHelper.getAllLokasiUser();
      if (localData.isNotEmpty) {
        return localData;
      }
      rethrow;
    }
  }
}
