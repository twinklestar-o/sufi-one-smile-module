import 'package:sufi_one/src/services/api_services.dart';
import 'package:sufi_one/src/database/database_helper.dart';
import 'package:sufi_one/app/modules/smile/models/jabatan.dart';
import 'package:sufi_one/src/utils/app_constants.dart'; // Import AppConstants
import 'package:flutter/foundation.dart'; // Untuk debugPrint

class JabatanRepository {
  final DatabaseHelper dbHelper;
  final ApiService apiService;

  JabatanRepository({required this.dbHelper, required this.apiService});

  Future<List<Jabatan>> getJabatans({bool forceRefresh = false}) async { // Mengubah nama metode ke plural
    debugPrint('🚀 getJabatans called with forceRefresh: $forceRefresh');
    List<Jabatan> localData = [];

    try {
      localData = await dbHelper.getAllJabatans(); // Menggunakan getAllJabatans
      debugPrint('📱 Fetched ${localData.length} jabatans from SQLite');
    } catch (e) {
      debugPrint('❌ Error fetching local jabatans: $e');
      forceRefresh = true;
    }

    final lastUpdate = await dbHelper.getLastUpdate(AppConstants.jabatanCacheKey); // Menggunakan getLastUpdate
    final bool shouldFetch = forceRefresh ||
        localData.isEmpty ||
        (lastUpdate == null || DateTime.now().difference(lastUpdate).inHours > AppConstants.cacheDurationHours);

    debugPrint('📱 Local data count: ${localData.length}');
    debugPrint('📱 Last update for jabatans: $lastUpdate');
    debugPrint('📱 Should fetch from API for jabatans: $shouldFetch');

    if (shouldFetch) {
      debugPrint('📱 No local data or cache expired - calling API for jabatans');
      try {
        return await _fetchFromApiAndSave();
      } catch (e) {
        debugPrint('❌ Error in Jabatan _fetchFromApiAndSave: $e');
        debugPrint('📱 Trying to fallback to local data...');
        if (localData.isNotEmpty) {
          debugPrint('📱 Fallback successful, returning ${localData.length} local jabatans.');
          return localData;
        } else {
          debugPrint('📱 No local data available for fallback.');
          rethrow;
        }
      }
    } else {
      debugPrint('✅ Returning ${localData.length} jabatans from cache.');
      return localData;
    }
  }

  Future<List<Jabatan>> _fetchFromApiAndSave() async {
    debugPrint('🚀 Starting _fetchFromApiAndSave for jabatans...');
    try {
      final response = await apiService.fetchJabatan(); // Asumsi ada fetchJabatan di ApiService

      if (response['status'] == true && response['data'] is List) {
        final List<dynamic> jabatanData = response['data'];
        debugPrint('🔍 Jabatan Data: $jabatanData');
        debugPrint('🔍 Number of jabatans from API: ${jabatanData.length}');

        final List<Jabatan> jabatanList = jabatanData.map((json) {
          final jabatan = Jabatan.fromJson(json);
          debugPrint('✅ Successfully parsed jabatan: $jabatan');
          return jabatan;
        }).toList();

        debugPrint('✅ Successfully parsed ${jabatanList.length} jabatans total');

        debugPrint('🗑️ Cleared old jabatan data');
        await dbHelper.clearJabatans(); // Menggunakan clearJabatans
        await dbHelper.insertJabatans(jabatanList); // Menggunakan insertJabatans
        debugPrint('💾 Inserted ${jabatanList.length} jabatans to SQLite');

        await dbHelper.updateLastUpdate(AppConstants.jabatanCacheKey); // Menggunakan updateLastUpdate
        debugPrint('⏰ Updated last update timestamp for jabatans');

        return jabatanList;
      } else {
        throw Exception('Unexpected response format for jabatans: $response');
      }
    } catch (e) {
      debugPrint('❌ Error fetching jabatans from API: $e');
      rethrow;
    }
  }

  // Tambahkan metode clearAndRefresh jika Anda ingin memilikinya di repository
  Future<void> _clearAndRefreshJabatans() async {
    debugPrint('🗑️ Clearing local jabatan data');
    await dbHelper.clearJabatans();
    await dbHelper.deleteLastUpdate(AppConstants.jabatanCacheKey);
    debugPrint('🔄 Force refreshing jabatans from API...');
    await getJabatans(forceRefresh: true);
  }
}