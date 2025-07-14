import 'package:sufi_one/src/services/api_services.dart';
import 'package:sufi_one/src/database/database_helper.dart';
import 'package:sufi_one/app/modules/smile/models/dealer.dart';
import 'package:sufi_one/src/utils/app_constants.dart'; // Import AppConstants
import 'package:flutter/foundation.dart'; // Untuk debugPrint

class DealerRepository {
  final DatabaseHelper dbHelper;
  final ApiService apiService;

  DealerRepository({required this.dbHelper, required this.apiService});

  Future<List<Dealer>> getDealers({bool forceRefresh = false}) async {
    debugPrint('🚀 getDealers called with forceRefresh: $forceRefresh');
    List<Dealer> localData = [];

    try {
      localData = await dbHelper.getAllDealers();
      debugPrint('📱 Fetched ${localData.length} dealers from SQLite');
    } catch (e) {
      debugPrint('❌ Error fetching local dealers: $e');
      forceRefresh = true; // Force refresh if local data fetch fails
    }

    final lastUpdate = await dbHelper.getLastUpdate(AppConstants.dealerCacheKey);
    debugPrint('🔍 AppConstants.cacheDurationHours: ${AppConstants.cacheDurationHours} hours');
    debugPrint('🔍 Last update for dealers: $lastUpdate');

    final bool shouldFetch = forceRefresh ||
        localData.isEmpty ||
        (lastUpdate == null || DateTime.now().difference(lastUpdate).inHours > AppConstants.cacheDurationHours);

    debugPrint('📱 Local data count: ${localData.length}');
    debugPrint('📱 Should fetch from API for dealers: $shouldFetch');

    if (shouldFetch) {
      debugPrint('📱 No local data or cache expired - calling API for dealers');
      try {
        return await _fetchFromApiAndSave();
      } catch (e) {
        debugPrint('❌ Error in Dealer _fetchFromApiAndSave: $e');
        debugPrint('📱 Trying to fallback to local data...');
        if (localData.isNotEmpty) {
          debugPrint('📱 Fallback successful, returning ${localData.length} local dealers.');
          return localData;
        } else {
          debugPrint('📱 No local data available for fallback.');
          rethrow;
        }
      }
    } else {
      debugPrint('✅ Returning ${localData.length} dealers from cache.');
      return localData;
    }
  }

  Future<List<Dealer>> _fetchFromApiAndSave() async {
    debugPrint('🚀 Starting _fetchFromApiAndSave for dealers...');
    try {
      final dynamic rawResponse = await apiService.fetchDealer();
      debugPrint('🔍 Dealer Repository - Raw API Response: $rawResponse');
      debugPrint('🔍 Dealer Repository - Raw API Response Type: ${rawResponse.runtimeType}');

      List<dynamic> dealerData;

      // Check if the rawResponse is a Map and has a 'data' key (standard API response)
      if (rawResponse is Map<String, dynamic> && rawResponse.containsKey('data')) {
        dealerData = rawResponse['data'];
        debugPrint('🔍 Response is a Map with "data" key.');
      }
      // Check if the rawResponse is directly a List (API returns list directly)
      else if (rawResponse is List) {
        dealerData = rawResponse;
        debugPrint('🔍 Response is a direct List.');
      } else {
        throw Exception('Invalid API response format: Expected Map with "data" key or direct List, got ${rawResponse.runtimeType}');
      }

      if (dealerData is! List) {
        throw Exception('Invalid API response format: "data" field is not a List, got ${dealerData.runtimeType}');
      }
      debugPrint('🔍 Dealer Data (extracted): $dealerData');
      debugPrint('🔍 Number of dealers from API: ${dealerData.length}');

      final List<Dealer> dealerList = dealerData.map((json) {
        try {
          return Dealer.fromJson(json as Map<String, dynamic>);
        } catch (e) {
          debugPrint('❌ Error parsing dealer JSON: $json, Error: $e');
          rethrow;
        }
      }).toList();

      debugPrint('✅ Successfully parsed ${dealerList.length} dealers');

      debugPrint('🗑️ Cleared old dealer data');
      await dbHelper.clearDealers();
      await dbHelper.insertDealers(dealerList);
      debugPrint('💾 Inserted ${dealerList.length} dealers to SQLite');

      await dbHelper.updateLastUpdate(AppConstants.dealerCacheKey);
      debugPrint('⏰ Updated last update timestamp for dealers');

      return dealerList;
    } catch (e) {
      debugPrint('❌ Error fetching dealers from API: $e');
      rethrow;
    }
  }

  // Tambahkan metode clearAndRefresh jika Anda ingin memilikinya di repository
  Future<void> _clearAndRefreshDealers() async {
    debugPrint('🗑️ Clearing local dealer data');
    await dbHelper.clearDealers();
    await dbHelper.deleteLastUpdate(AppConstants.dealerCacheKey);
    debugPrint('🔄 Force refreshing dealers from API...');
    await getDealers(forceRefresh: true);
  }
}