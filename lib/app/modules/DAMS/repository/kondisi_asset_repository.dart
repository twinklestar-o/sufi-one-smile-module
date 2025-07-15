import 'package:sufi_one/app/modules/DAMS/model/kondisi_asset.dart';
import 'package:sufi_one/src/database/DAMS/database_helper.dart';
import 'package:sufi_one/src/services/DAMS/api_services.dart';

class KondisiAssetRepository {
  final DatabaseHelperDams dbHelper;
  final ApiServiceDams apiService;

  KondisiAssetRepository({required this.dbHelper, required this.apiService});

  Future<List<KondisiAsset>> getKondisiAsset({
    bool forceRefresh = false,
  }) async {
    try {
      if (forceRefresh) {
        return await _fetchFromApiAndSave();
      }

      final localData = await dbHelper.getAllKondisiAsset();
      if (localData.isEmpty) {
        return await _fetchFromApiAndSave();
      }

      final localLastUpdate = await dbHelper.getLastUpdateTime(
        'kondisi_asset_last_update',
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
      final localData = await dbHelper.getAllKondisiAsset();
      if (localData.isNotEmpty) {
        return localData;
      }
      rethrow;
    }
  }

  Future<List<KondisiAsset>> _fetchFromApiAndSave() async {
    try {
      final response = await apiService.fetchKondisiAsset();

      // Pastikan response adalah Map dan memiliki field 'data'
      if (response is! Map<String, dynamic> || !response.containsKey('data')) {
        throw Exception('Invalid API response format');
      }

      // Ekstrak list kondisi asset dari field 'data'
      final List<dynamic> kondisiAssetData = response['data'];

      // Konversi ke List<KondisiAsset>
      final List<KondisiAsset> kondisiAssetList =
          kondisiAssetData.map((json) => KondisiAsset.fromJson(json)).toList();

      // Clear old data
      final db = await dbHelper.database;
      await db.delete('kondisiAsset');

      // Insert new data
      for (var kondisiAsset in kondisiAssetList) {
        await dbHelper.insertKondisiAsset(kondisiAsset);
      }

      // Update timestamp
      await dbHelper.updateCollectionTimestamp('kondisi_asset_last_update');

      return kondisiAssetList;
    } catch (e) {
      // If API fails, try to return local data
      final localData = await dbHelper.getAllKondisiAsset();
      if (localData.isNotEmpty) {
        return localData;
      }
      rethrow;
    }
  }
}
