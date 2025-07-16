import 'package:sufi_one/src/database/SMILE/database_helper.dart';
import 'package:sufi_one/src/services/SMILE/api_services.dart';
import 'package:sufi_one/app/modules/smile/models/branch.dart';
import 'package:sufi_one/src/utils/app_constants.dart'; // Import AppConstants
import 'package:flutter/foundation.dart'; // Untuk debugPrint

class BranchRepository {
  final DatabaseHelperSmile dbHelper;
  final ApiServiceSmile apiService;

  BranchRepository({required this.dbHelper, required this.apiService});

  Future<List<Branch>> getBranches({bool forceRefresh = false}) async {
    debugPrint('🚀 getBranches called with forceRefresh: $forceRefresh');
    List<Branch> localData = [];

    try {
      localData = await dbHelper.getAllBranch();
      debugPrint('📱 Fetched ${localData.length} branches from SQLite');
    } catch (e) {
      debugPrint('❌ Error fetching local branches: $e');
      forceRefresh = true; // Force refresh if local data fetch fails
    }

    final lastUpdate = await dbHelper.getLastUpdate(
      AppConstants.branchCacheKey,
    );
    debugPrint(
      '🔍 AppConstants.cacheDurationHours (Branch): ${AppConstants.cacheDurationHours} hours',
    );
    debugPrint('🔍 Last update for branches: $lastUpdate');

    final bool shouldFetch =
        forceRefresh ||
        localData.isEmpty ||
        (lastUpdate == null ||
            DateTime.now().difference(lastUpdate).inHours >
                AppConstants.cacheDurationHours);

    debugPrint('📱 Local data count (Branch): ${localData.length}');
    debugPrint('📱 Should fetch from API for branches: $shouldFetch');

    if (shouldFetch) {
      debugPrint('📱 No local data or cache expired (Branch) - calling API');
      try {
        return await _fetchFromApiAndSave();
      } catch (e) {
        debugPrint('❌ Error in Branch _fetchFromApiAndSave: $e');
        debugPrint('📱 Trying to fallback to local data (Branch)...');
        if (localData.isNotEmpty) {
          debugPrint(
            '📱 Fallback successful, returning ${localData.length} local branches.',
          );
          return localData;
        } else {
          debugPrint('📱 No local data available for fallback (Branch).');
          rethrow;
        }
      }
    } else {
      debugPrint('✅ Returning ${localData.length} branches from cache.');
      return localData;
    }
  }

  Future<List<Branch>> _fetchFromApiAndSave() async {
    debugPrint('🚀 Starting _fetchFromApiAndSave for branches...');
    try {
      final dynamic rawResponse = await apiService.fetchBranches();
      debugPrint('🔍 Branch Repository - Raw API Response: $rawResponse');
      debugPrint(
        '🔍 Branch Repository - Raw API Response Type: ${rawResponse.runtimeType}',
      );

      List<dynamic> branchData;
      if (rawResponse is Map<String, dynamic> &&
          rawResponse.containsKey('data')) {
        branchData = rawResponse['data'];
        debugPrint('🔍 Response is a Map with "data" key (Branch).');
      } else if (rawResponse is List) {
        branchData = rawResponse;
        debugPrint('🔍 Response is a direct List (Branch).');
      } else {
        throw Exception(
          'Invalid API response format for branches: Expected Map with "data" or direct List, got ${rawResponse.runtimeType}',
        );
      }

      if (branchData is! List) {
        throw Exception(
          'Invalid API response format: "data" field is not a List (Branch), got ${branchData.runtimeType}',
        );
      }
      debugPrint('🔍 Branch Data (extracted): $branchData');
      debugPrint('🔍 Number of branches from API: ${branchData.length}');

      final List<Branch> branchList =
          branchData.map((json) {
            try {
              final branch = Branch.fromJson(json as Map<String, dynamic>);
              debugPrint('✅ Successfully parsed branch: $branch');
              return branch;
            } catch (e) {
              debugPrint('❌ Error parsing branch JSON: $json, Error: $e');
              rethrow;
            }
          }).toList();

      debugPrint('✅ Successfully parsed ${branchList.length} branches total');

      debugPrint('🗑️ Cleared old branch data');
      await dbHelper.clearBranches();
      await dbHelper.insertBranches(branchList);
      debugPrint('💾 Inserted ${branchList.length} branches to SQLite');

      await dbHelper.updateLastUpdate(AppConstants.branchCacheKey);
      debugPrint('⏰ Updated last update timestamp for branches');

      return branchList;
    } catch (e) {
      debugPrint('❌ Error fetching branches from API: $e');
      rethrow;
    }
  }

  Future<void> _clearAndRefreshBranches() async {
    debugPrint('🗑️ Clearing local branch data');
    await dbHelper.clearBranches();
    await dbHelper.deleteLastUpdate(AppConstants.branchCacheKey);
    debugPrint('🔄 Force refreshing branches from API...');
    await getBranches(forceRefresh: true);
  }
}
