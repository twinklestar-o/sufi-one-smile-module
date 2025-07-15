import 'package:sufi_one/app/modules/DAMS/model/status_asset.dart';
import 'package:sufi_one/src/database/DAMS/database_helper.dart';
import 'package:sufi_one/src/services/DAMS/api_services.dart';

class StatusAssetRepository {
  final DatabaseHelperDams dbHelper;
  final ApiServiceDams apiService;

  StatusAssetRepository({required this.dbHelper, required this.apiService});

  Future<List<StatusAsset>> getStatusAsset({bool forceRefresh = false}) async {
    try {
      if (forceRefresh) {
        return await _fetchFromApiAndSave();
      }

      final localData = await dbHelper.getAllStatusAsset();
      if (localData.isEmpty) {
        return await _fetchFromApiAndSave();
      }

      final localLastUpdate = await dbHelper.getLastUpdateTime(
        'status_asset_last_update',
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
      final localData = await dbHelper.getAllStatusAsset();
      if (localData.isNotEmpty) {
        return localData;
      }
      rethrow;
    }
  }

  Future<List<StatusAsset>> _fetchFromApiAndSave() async {
    try {
      final response = await apiService.fetchStatusAsset();

      // Pastikan response adalah Map dan memiliki field 'data'
      if (response is! Map<String, dynamic> || !response.containsKey('data')) {
        throw Exception('Invalid API response format');
      }

      // Ekstrak list status asset dari field 'data'
      final List<dynamic> statusAssetData = response['data'];

      // Konversi ke List<StatusAsset>
      final List<StatusAsset> statusAssetList =
          statusAssetData.map((json) => StatusAsset.fromJson(json)).toList();

      // Clear old data
      final db = await dbHelper.database;
      await db.delete('statusAsset');

      // Insert new data
      for (var statusAsset in statusAssetList) {
        await dbHelper.insertStatusAsset(statusAsset);
      }

      // Update timestamp
      await dbHelper.updateCollectionTimestamp('status_asset_last_update');

      return statusAssetList;
    } catch (e) {
      // If API fails, try to return local data
      final localData = await dbHelper.getAllStatusAsset();
      if (localData.isNotEmpty) {
        return localData;
      }
      rethrow;
    }
  }
}
