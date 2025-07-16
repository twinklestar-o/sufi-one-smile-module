import 'package:sufi_one/src/database/SMILE/database_helper.dart';
import 'package:sufi_one/src/services/SMILE/api_services.dart';
import 'package:sufi_one/app/modules/smile/models/type.dart'; // Asumsi ini adalah VisitType
import 'package:sufi_one/src/utils/app_constants.dart'; // Import AppConstants
import 'package:flutter/foundation.dart'; // Untuk debugPrint

class TypeRepository {
  // Menggunakan TypeRepository
  final DatabaseHelperSmile dbHelper;
  final ApiServiceSmile apiService;

  TypeRepository({required this.dbHelper, required this.apiService});

  Future<List<Type>> getTypes({bool forceRefresh = false}) async {
    // Mengubah nama metode ke plural
    debugPrint('🚀 getTypes called with forceRefresh: $forceRefresh');
    List<Type> localData = [];

    try {
      localData = await dbHelper.getAllType(); // Menggunakan getAllTypes
      debugPrint('📱 Fetched ${localData.length} types from SQLite');
    } catch (e) {
      debugPrint('❌ Error fetching local types: $e');
      forceRefresh = true;
    }

    final lastUpdate = await dbHelper.getLastUpdate(
      AppConstants.typeCacheKey,
    ); // Menggunakan getLastUpdate
    final bool shouldFetch =
        forceRefresh ||
        localData.isEmpty ||
        (lastUpdate == null ||
            DateTime.now().difference(lastUpdate).inHours >
                AppConstants.cacheDurationHours);

    debugPrint('📱 Local data count: ${localData.length}');
    debugPrint('📱 Last update for types: $lastUpdate');
    debugPrint('📱 Should fetch from API for types: $shouldFetch');

    if (shouldFetch) {
      debugPrint('📱 No local data or cache expired - calling API for types');
      try {
        return await _fetchFromApiAndSave();
      } catch (e) {
        debugPrint('❌ Error in Type _fetchFromApiAndSave: $e');
        debugPrint('📱 Trying to fallback to local data...');
        if (localData.isNotEmpty) {
          debugPrint(
            '📱 Fallback successful, returning ${localData.length} local types.',
          );
          return localData;
        } else {
          debugPrint('📱 No local data available for fallback.');
          rethrow;
        }
      }
    } else {
      debugPrint('✅ Returning ${localData.length} types from cache.');
      return localData;
    }
  }

  Future<List<Type>> _fetchFromApiAndSave() async {
    debugPrint('🚀 Starting _fetchFromApiAndSave for types...');
    try {
      final response =
          await apiService.fetchType(); // Asumsi ada fetchType di ApiService

      if (response['status'] == true && response['data'] is List) {
        final List<dynamic> typeData = response['data'];
        debugPrint('🔍 Type Data: $typeData');
        debugPrint('🔍 Number of types from API: ${typeData.length}');

        final List<Type> typeList =
            typeData.map((json) {
              final type = Type.fromJson(json);
              debugPrint('✅ Successfully parsed type: $type');
              return type;
            }).toList();

        debugPrint('✅ Successfully parsed ${typeList.length} types total');

        debugPrint('🗑️ Cleared old type data');
        await dbHelper.clearTypes(); // Menggunakan clearTypes
        await dbHelper.insertTypes(typeList); // Menggunakan insertTypes
        debugPrint('💾 Inserted ${typeList.length} types to SQLite');

        await dbHelper.updateLastUpdate(
          AppConstants.typeCacheKey,
        ); // Menggunakan updateLastUpdate
        debugPrint('⏰ Updated last update timestamp for types');

        return typeList;
      } else {
        throw Exception('Unexpected response format for types: $response');
      }
    } catch (e) {
      debugPrint('❌ Error fetching types from API: $e');
      rethrow;
    }
  }

  // Tambahkan metode clearAndRefresh jika Anda ingin memilikinya di repository
  Future<void> _clearAndRefreshTypes() async {
    debugPrint('🗑️ Clearing local type data');
    await dbHelper.clearTypes();
    await dbHelper.deleteLastUpdate(AppConstants.typeCacheKey);
    debugPrint('🔄 Force refreshing types from API...');
    await getTypes(forceRefresh: true);
  }
}
