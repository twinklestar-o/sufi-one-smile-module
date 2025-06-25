import 'package:sufi_one/src/services/api_services.dart';
import '../../../../src/database/database_helper.dart';
import '../models/dealer.dart';

class DealerRepository {
  final DatabaseHelper dbHelper;
  final ApiService apiService;

  DealerRepository({required this.dbHelper, required this.apiService});

  Future<List<Dealer>> getDealer({bool forceRefresh = false}) async {
    try {
      if (forceRefresh) {
        return await _fetchFromApiAndSave();
      }

      final localData = await dbHelper.getAllDealer();
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
      final localData = await dbHelper.getAllDealer();
      if (localData.isNotEmpty) {
        return localData;
      }
      rethrow;
    }
  }

  Future<List<Dealer>> _fetchFromApiAndSave() async {
    try {
      final response = await apiService.fetchDealer();

      // Pastikan response adalah Map dan memiliki field 'data'
      if (response is! Map<String, dynamic> || !response.containsKey('data')) {
        throw Exception('Invalid API response format');
      }

      // Ekstrak list Dealer dari field 'data'
      final List<dynamic> dealerData = response['data'];

      // Konversi ke List<Dealer>
      final List<Dealer> dealerList =
          dealerData.map((json) => Dealer.fromJson(json)).toList();

      // Clear old data
      final db = await dbHelper.database;
      await db.delete('dealers');

      // Insert new data
      for (var Dealer in dealerList) {
        await dbHelper.insertDealer(Dealer);
      }

      // Update timestamp
      await dbHelper.updateCollectionTimestamp();

      return dealerList;
    } catch (e) {
      // If API fails, try to return local data
      final localData = await dbHelper.getAllDealer();
      if (localData.isNotEmpty) {
        return localData;
      }
      rethrow;
    }
  }
}
