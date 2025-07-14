import 'package:sufi_one/src/services/api_services.dart';
import 'package:sufi_one/src/database/database_helper.dart';
import 'package:sufi_one/app/modules/smile/models/branch.dart';
import 'package:sufi_one/src/utils/app_constants.dart'; // Import AppConstants
import 'package:flutter/foundation.dart'; // Untuk debugPrint

class BranchRepository {
  final DatabaseHelper dbHelper;
  final ApiService apiService;

  BranchRepository({required this.dbHelper, required this.apiService});

  Future<List<Branch>> getBranches({bool forceRefresh = false}) async { // Mengubah nama metode ke plural
    debugPrint('🚀 getBranches called with forceRefresh: $forceRefresh');
    List<Branch> localData = [];

    try {
      localData = await dbHelper.getAllBranches(); // Menggunakan getAllBranches
      debugPrint('📱 Fetched ${localData.length} branches from SQLite');
    } catch (e) {
      debugPrint('❌ Error fetching local branches: $e');
      forceRefresh = true;
    }

    final lastUpdate = await dbHelper.getLastUpdate(AppConstants.branchCacheKey); // Menggunakan getLastUpdate
    final bool shouldFetch = forceRefresh ||
        localData.isEmpty ||
        (lastUpdate == null || DateTime.now().difference(lastUpdate).inHours > AppConstants.cacheDurationHours);

    debugPrint('📱 Local data count: ${localData.length}');
    debugPrint('📱 Last update for branches: $lastUpdate');
    debugPrint('📱 Should fetch from API for branches: $shouldFetch');

    if (shouldFetch) {
      debugPrint('📱 No local data or cache expired - calling API for branches');
      try {
        return await _fetchFromApiAndSave();
      } catch (e) {
        debugPrint('❌ Error in Branch _fetchFromApiAndSave: $e');
        debugPrint('📱 Trying to fallback to local data...');
        if (localData.isNotEmpty) {
          debugPrint('📱 Fallback successful, returning ${localData.length} local branches.');
          return localData;
        } else {
          debugPrint('📱 No local data available for fallback.');
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
      final dynamic rawResponse = await apiService.fetchBranches(); // Asumsi ada fetchBranches di ApiService
      debugPrint('🔍 Branch Repository - Raw API Response: $rawResponse');

      List<dynamic> branchData;
      if (rawResponse is Map<String, dynamic> && rawResponse.containsKey('data')) {
        branchData = rawResponse['data'];
      } else if (rawResponse is List) { // Jika API langsung mengembalikan List
        branchData = rawResponse;
      } else {
        throw Exception('Invalid API response format: Expected Map with "data" or direct List, got ${rawResponse.runtimeType}');
      }

      if (branchData is! List) {
        throw Exception('Data cabang dari API bukan berupa daftar');
      }
      debugPrint('🔍 Branch Data: $branchData');
      debugPrint('🔍 Number of branches from API: ${branchData.length}');

      final List<Branch> branchList = branchData.map((json) {
        final branch = Branch.fromJson(json as Map<String, dynamic>);
        debugPrint('✅ Successfully parsed branch: $branch');
        return branch;
      }).toList();

      debugPrint('✅ Successfully parsed ${branchList.length} branches total');

      debugPrint('🗑️ Cleared old branch data');
      await dbHelper.clearBranches(); // Menggunakan clearBranches
      await dbHelper.insertBranches(branchList); // Menggunakan insertBranches
      debugPrint('💾 Inserted ${branchList.length} branches to SQLite');

      await dbHelper.updateLastUpdate(AppConstants.branchCacheKey); // Menggunakan updateLastUpdate
      debugPrint('⏰ Updated last update timestamp for branches');

      return branchList;
    } catch (e) {
      debugPrint('❌ Error fetching branches from API: $e');
      rethrow;
    }
  }

  // Tambahkan metode clearAndRefresh jika Anda ingin memilikinya di repository
  Future<void> _clearAndRefreshBranches() async {
    debugPrint('🗑️ Clearing local branch data');
    await dbHelper.clearBranches();
    await dbHelper.deleteLastUpdate(AppConstants.branchCacheKey);
    debugPrint('🔄 Force refreshing branches from API...');
    await getBranches(forceRefresh: true);
  }
}