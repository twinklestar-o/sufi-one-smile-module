import 'package:sufi_one/app/modules/smile/models/area.dart';
import 'package:sufi_one/src/database/database_helper.dart';
import 'package:sufi_one/src/services/api_services.dart';
import 'package:sufi_one/src/utils/app_constants.dart'; // Import AppConstants
import 'package:flutter/foundation.dart'; // Untuk debugPrint

class AreaRepository {
  final DatabaseHelper dbHelper;
  final ApiService apiService;

  AreaRepository({required this.dbHelper, required this.apiService});

  Future<List<Area>> getAreas({bool forceRefresh = false}) async { // Mengubah nama metode ke plural
    debugPrint('🚀 getAreas called with forceRefresh: $forceRefresh');
    List<Area> localData = [];

    try {
      localData = await dbHelper.getAllAreas(); // Menggunakan getAllAreas
      debugPrint('📱 Fetched ${localData.length} areas from SQLite');
    } catch (e) {
      debugPrint('❌ Error fetching local areas: $e');
      forceRefresh = true;
    }

    final lastUpdate = await dbHelper.getLastUpdate(AppConstants.areaCacheKey); // Menggunakan getLastUpdate
    final bool shouldFetch = forceRefresh ||
        localData.isEmpty ||
        (lastUpdate == null || DateTime.now().difference(lastUpdate).inHours > AppConstants.cacheDurationHours);

    debugPrint('📱 Local data count: ${localData.length}');
    debugPrint('📱 Last update for areas: $lastUpdate');
    debugPrint('📱 Should fetch from API for areas: $shouldFetch');

    if (shouldFetch) {
      debugPrint('📱 No local data or cache expired - calling API for areas');
      try {
        return await _fetchFromApiAndSave();
      } catch (e) {
        debugPrint('❌ Error in Area _fetchFromApiAndSave: $e');
        debugPrint('📱 Trying to fallback to local data...');
        if (localData.isNotEmpty) {
          debugPrint('📱 Fallback successful, returning ${localData.length} local areas.');
          return localData;
        } else {
          debugPrint('📱 No local data available for fallback.');
          rethrow;
        }
      }
    } else {
      debugPrint('✅ Returning ${localData.length} areas from cache.');
      return localData;
    }
  }

  Future<List<Area>> _fetchFromApiAndSave() async {
    debugPrint('🚀 Starting _fetchFromApiAndSave for areas...');
    try {
      final response = await apiService.fetchArea(); // Asumsi ada fetchArea di ApiService

      if (response['status'] == true && response['data'] is List) {
        final List<dynamic> areaData = response['data'];
        debugPrint('🔍 Area Data: $areaData');
        debugPrint('🔍 Number of areas from API: ${areaData.length}');

        final List<Area> areaList = areaData.map((json) {
          final area = Area.fromJson(json);
          debugPrint('✅ Successfully parsed area: $area');
          return area;
        }).toList();

        debugPrint('✅ Successfully parsed ${areaList.length} areas total');

        debugPrint('🗑️ Cleared old area data');
        await dbHelper.clearAreas(); // Menggunakan clearAreas
        await dbHelper.insertAreas(areaList); // Menggunakan insertAreas
        debugPrint('💾 Inserted ${areaList.length} areas to SQLite');

        await dbHelper.updateLastUpdate(AppConstants.areaCacheKey); // Menggunakan updateLastUpdate
        debugPrint('⏰ Updated last update timestamp for areas');

        return areaList;
      } else {
        throw Exception('Unexpected response format for areas: $response');
      }
    } catch (e) {
      debugPrint('❌ Error fetching areas from API: $e');
      rethrow;
    }
  }

  // Tambahkan metode clearAndRefresh jika Anda ingin memilikinya di repository
  Future<void> _clearAndRefreshAreas() async {
    debugPrint('🗑️ Clearing local area data');
    await dbHelper.clearAreas();
    await dbHelper.deleteLastUpdate(AppConstants.areaCacheKey);
    debugPrint('🔄 Force refreshing areas from API...');
    await getAreas(forceRefresh: true);
  }
}