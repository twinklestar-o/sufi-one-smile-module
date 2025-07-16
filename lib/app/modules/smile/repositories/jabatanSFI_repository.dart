import 'package:sufi_one/src/database/SMILE/database_helper.dart';
import 'package:sufi_one/src/services/SMILE/api_services.dart';
import 'package:sufi_one/app/modules/smile/models/jabatanSFI.dart';
import 'package:sufi_one/src/utils/app_constants.dart'; // Import AppConstants
import 'package:flutter/foundation.dart'; // Untuk debugPrint

class JabatanSFIRepository {
  final DatabaseHelperSmile dbHelper;
  final ApiServiceSmile apiService;

  JabatanSFIRepository({required this.dbHelper, required this.apiService});

  Future<List<JabatanSFI>> getJabatanSFIs({bool forceRefresh = false}) async {
    // Mengubah nama metode ke plural
    debugPrint('🚀 getJabatanSFIs called with forceRefresh: $forceRefresh');
    List<JabatanSFI> localData = [];

    try {
      localData =
          await dbHelper.getAllJabatanSFI(); // Menggunakan getAllJabatanSFIs
      debugPrint('📱 Fetched ${localData.length} JabatanSFI from SQLite');
    } catch (e) {
      debugPrint('❌ Error fetching local JabatanSFI: $e');
      forceRefresh = true;
    }

    final lastUpdate = await dbHelper.getLastUpdate(
      AppConstants.jabatanSFICacheKey,
    ); // Menggunakan getLastUpdate
    final bool shouldFetch =
        forceRefresh ||
        localData.isEmpty ||
        (lastUpdate == null ||
            DateTime.now().difference(lastUpdate).inHours >
                AppConstants.cacheDurationHours);

    debugPrint('📱 Local data count: ${localData.length}');
    debugPrint('📱 Last update for JabatanSFI: $lastUpdate');
    debugPrint('📱 Should fetch from API for JabatanSFI: $shouldFetch');

    if (shouldFetch) {
      debugPrint(
        '📱 No local data or cache expired - calling API for JabatanSFI',
      );
      try {
        return await _fetchFromApiAndSave();
      } catch (e) {
        debugPrint('❌ Error in JabatanSFI _fetchFromApiAndSave: $e');
        debugPrint('📱 Trying to fallback to local data...');
        if (localData.isNotEmpty) {
          debugPrint(
            '📱 Fallback successful, returning ${localData.length} local JabatanSFI.',
          );
          return localData;
        } else {
          debugPrint('📱 No local data available for fallback.');
          rethrow;
        }
      }
    } else {
      debugPrint('✅ Returning ${localData.length} JabatanSFI from cache.');
      return localData;
    }
  }

  Future<List<JabatanSFI>> _fetchFromApiAndSave() async {
    debugPrint('🚀 Starting _fetchFromApiAndSave for JabatanSFI...');
    try {
      final response =
          await apiService
              .fetchJabatanSFI(); // Asumsi ada fetchJabatanSFI di ApiService

      if (response['status'] == true && response['data'] is List) {
        final List<dynamic> jabatanSFIData = response['data'];
        debugPrint('🔍 JabatanSFI Data: $jabatanSFIData');
        debugPrint(
          '🔍 Number of JabatanSFI from API: ${jabatanSFIData.length}',
        );

        final List<JabatanSFI> jabatanSFIList =
            jabatanSFIData.map((json) {
              final jabatanSFI = JabatanSFI.fromJson(json);
              debugPrint('✅ Successfully parsed JabatanSFI: $jabatanSFI');
              return jabatanSFI;
            }).toList();

        debugPrint(
          '✅ Successfully parsed ${jabatanSFIList.length} JabatanSFI total',
        );

        debugPrint('🗑️ Cleared old JabatanSFI data');
        await dbHelper.clearJabatanSFIs(); // Menggunakan clearJabatanSFIs
        await dbHelper.insertJabatanSFIs(
          jabatanSFIList,
        ); // Menggunakan insertJabatanSFIs
        debugPrint('💾 Inserted ${jabatanSFIList.length} JabatanSFI to SQLite');

        await dbHelper.updateLastUpdate(
          AppConstants.jabatanSFICacheKey,
        ); // Menggunakan updateLastUpdate
        debugPrint('⏰ Updated last update timestamp for JabatanSFI');

        return jabatanSFIList;
      } else {
        throw Exception('Unexpected response format for JabatanSFI: $response');
      }
    } catch (e) {
      debugPrint('❌ Error fetching JabatanSFI from API: $e');
      rethrow;
    }
  }

  // Tambahkan metode clearAndRefresh jika Anda ingin memilikinya di repository
  Future<void> _clearAndRefreshJabatanSFIs() async {
    debugPrint('🗑️ Clearing local JabatanSFI data');
    await dbHelper.clearJabatanSFIs();
    await dbHelper.deleteLastUpdate(AppConstants.jabatanSFICacheKey);
    debugPrint('🔄 Force refreshing JabatanSFI from API...');
    await getJabatanSFIs(forceRefresh: true);
  }
}
