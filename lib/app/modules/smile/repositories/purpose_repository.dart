import 'package:sufi_one/src/database/SMILE/database_helper.dart';
import 'package:sufi_one/src/services/SMILE/api_services.dart';
import 'package:sufi_one/app/modules/smile/models/purpose.dart';
import 'package:sufi_one/src/utils/app_constants.dart'; // Import AppConstants
import 'package:flutter/foundation.dart'; // Untuk debugPrint

class PurposeRepository {
  final DatabaseHelperSmile dbHelper;
  final ApiServiceSmile apiService;

  PurposeRepository({required this.dbHelper, required this.apiService});

  Future<List<Purpose>> getPurposes({bool forceRefresh = false}) async {
    // Mengubah nama metode ke plural
    debugPrint('🚀 getPurposes called with forceRefresh: $forceRefresh');
    List<Purpose> localData = [];

    try {
      localData = await dbHelper.getAllPurpose(); // Menggunakan getAllPurposes
      debugPrint('📱 Fetched ${localData.length} purposes from SQLite');
    } catch (e) {
      debugPrint('❌ Error fetching local purposes: $e');
      forceRefresh = true; // Force refresh if local data fetch fails
    }

    final lastUpdate = await dbHelper.getLastUpdate(
      AppConstants.purposeCacheKey,
    ); // Menggunakan getLastUpdate
    final bool shouldFetch =
        forceRefresh ||
        localData.isEmpty ||
        (lastUpdate == null ||
            DateTime.now().difference(lastUpdate).inHours >
                AppConstants.cacheDurationHours);

    debugPrint('📱 Local data count: ${localData.length}');
    debugPrint('📱 Last update for purposes: $lastUpdate');
    debugPrint('📱 Should fetch from API for purposes: $shouldFetch');

    if (shouldFetch) {
      debugPrint(
        '📱 No local data or cache expired - calling API for purposes',
      );
      try {
        return await _fetchFromApiAndSave();
      } catch (e) {
        debugPrint('❌ Error in Purpose _fetchFromApiAndSave: $e');
        debugPrint('📱 Trying to fallback to local data...');
        if (localData.isNotEmpty) {
          debugPrint(
            '📱 Fallback successful, returning ${localData.length} local purposes.',
          );
          return localData;
        } else {
          debugPrint('📱 No local data available for fallback.');
          rethrow;
        }
      }
    } else {
      debugPrint('✅ Returning ${localData.length} purposes from cache.');
      return localData;
    }
  }

  Future<List<Purpose>> _fetchFromApiAndSave() async {
    debugPrint('🚀 Starting _fetchFromApiAndSave for purposes...');
    try {
      final response =
          await apiService
              .fetchPurpose(); // Asumsi ada fetchPurpose di ApiService

      if (response['status'] == true && response['data'] is List) {
        final List<dynamic> purposeData = response['data'];
        debugPrint('🔍 Purpose Data: $purposeData');
        debugPrint('🔍 Number of purposes from API: ${purposeData.length}');

        final List<Purpose> purposeList =
            purposeData.map((json) {
              final purpose = Purpose.fromJson(json);
              debugPrint('✅ Successfully parsed purpose: $purpose');
              return purpose;
            }).toList();

        debugPrint(
          '✅ Successfully parsed ${purposeList.length} purposes total',
        );

        debugPrint('🗑️ Cleared old purpose data');
        await dbHelper.clearPurposes(); // Menggunakan clearPurposes
        await dbHelper.insertPurposes(
          purposeList,
        ); // Menggunakan insertPurposes
        debugPrint('💾 Inserted ${purposeList.length} purposes to SQLite');

        await dbHelper.updateLastUpdate(
          AppConstants.purposeCacheKey,
        ); // Menggunakan updateLastUpdate
        debugPrint('⏰ Updated last update timestamp for purposes');

        return purposeList;
      } else {
        throw Exception('Unexpected response format for purposes: $response');
      }
    } catch (e) {
      debugPrint('❌ Error fetching purposes from API: $e');
      rethrow;
    }
  }

  // Tambahkan metode clearAndRefresh jika Anda ingin memilikinya di repository
  Future<void> _clearAndRefreshPurposes() async {
    debugPrint('🗑️ Clearing local purpose data');
    await dbHelper.clearPurposes();
    await dbHelper.deleteLastUpdate(AppConstants.purposeCacheKey);
    debugPrint('🔄 Force refreshing purposes from API...');
    await getPurposes(forceRefresh: true);
  }
}
