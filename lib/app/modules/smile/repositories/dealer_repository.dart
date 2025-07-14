import 'package:sufi_one/src/services/api_services.dart';
import '../../../../src/database/database_helper.dart';
import '../models/dealer.dart';

class DealerRepository {
  final DatabaseHelper dbHelper;
  final ApiService apiService;

  DealerRepository({required this.dbHelper, required this.apiService});

  // lib/app/modules/smile/repositories/dealer_repository.dart
// Update method getDealer
  Future<List<Dealer>> getDealer({bool forceRefresh = false}) async {
    try {
      if (forceRefresh) {
        return await _fetchFromApiAndSave();
      }

      final localData = await dbHelper.getAllDealer();
      if (localData.isEmpty) {
        return await _fetchFromApiAndSave();
      }

      // Kurangi frekuensi pengecekan server update
      final localLastUpdate = await dbHelper.getLastUpdateTime(
          'dealer_last_update');
      if (localLastUpdate != null) {
        final now = DateTime.now();
        final difference = now.difference(localLastUpdate);

        // Hanya cek server update jika data lokal sudah lebih dari 1 jam
        if (difference.inHours < 1) {
          print(
              'Using cached dealer data (${difference.inMinutes} minutes old)');
          return localData;
        }
      }

      // Cek server update hanya jika perlu
      try {
        final serverLastUpdate = await apiService.fetchLastUpdateTime();
        if (serverLastUpdate != null &&
            (localLastUpdate == null ||
                serverLastUpdate.isAfter(localLastUpdate))) {
          return await _fetchFromApiAndSave();
        }
      } catch (e) {
        print('Failed to check server update, using local data: $e');
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

      print('Dealer Repository - API Response: $response');

      // Pastikan response adalah Map dan memiliki field 'data'
      if (response is! Map<String, dynamic>) {
        throw Exception(
            'Invalid API response format: Expected Map, got ${response
                .runtimeType}');
      }

      if (!response.containsKey('data')) {
        throw Exception('Invalid API response format: Missing "data" field');
      }

      // Ekstrak list Dealer dari field 'data'
      final dynamic dealerData = response['data'];
      if (dealerData is! List) {
        throw Exception(
            'Invalid API response format: "data" field is not a List');
      }

      // Konversi ke List<Dealer>
      final List<Dealer> dealerList = dealerData.map((json) {
        try {
          return Dealer.fromJson(json as Map<String, dynamic>);
        } catch (e) {
          print('Error parsing dealer JSON: $json, Error: $e');
          rethrow;
        }
      }).toList();

      print('Successfully parsed ${dealerList.length} dealers');

      // Clear old data
      final db = await dbHelper.database;
      await db.delete('dealers');

      // Insert new data
      for (var dealer in dealerList) {
        await dbHelper.insertDealer(dealer);
      }

      // Update timestamp
      await dbHelper.updateCollectionTimestamp('dealer_last_update');

      return dealerList;
    } catch (e) {
      print('Error in _fetchFromApiAndSave: $e');
      // If API fails, try to return local data
      final localData = await dbHelper.getAllDealer();
      if (localData.isNotEmpty) {
        return localData;
      }
      rethrow;
    }
  }
}
