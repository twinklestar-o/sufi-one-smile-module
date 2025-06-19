import 'package:sufi_one/app/modules/smile/models/area.dart';
import 'package:sufi_one/src/database/database_helper.dart';
import 'package:sufi_one/src/services/api_services.dart';

class AreaRepository {
  final DatabaseHelper dbHelper;
  final ApiService apiService;

  AreaRepository({required this.dbHelper, required this.apiService});

  Future<List<Area>> getArea({bool forceRefresh = false}) async {
    try {
      if (forceRefresh) {
        return await _fetchFromApiAndSave();
      }

      final localData = await dbHelper.getAllArea();
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
      final localData = await dbHelper.getAllArea();
      if (localData.isNotEmpty) {
        return localData;
      }
      rethrow;
    }
  }

  Future<List<Area>> _fetchFromApiAndSave() async {
    try {
      final response = await apiService.fetchArea();

      // Pastikan response adalah Map dan memiliki field 'data'
      if (response is! Map<String, dynamic> || !response.containsKey('data')) {
        throw Exception('Invalid API response format');
      }

      // Ekstrak list area dari field 'data'
      final List<dynamic> areaData = response['data'];

      // Konversi ke List<Area>
      final List<Area> areaList =
          areaData.map((json) => Area.fromJson(json)).toList();

      // Clear old data
      final db = await dbHelper.database;
      await db.delete('area');

      // Insert new data
      for (var area in areaList) {
        await dbHelper.insertArea(area);
      }

      // Update timestamp
      await dbHelper.updateCollectionTimestamp();

      return areaList;
    } catch (e) {
      // If API fails, try to return local data
      final localData = await dbHelper.getAllArea();
      if (localData.isNotEmpty) {
        return localData;
      }
      rethrow;
    }
  }
}
