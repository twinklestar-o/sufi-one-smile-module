import 'package:sqflite/sqflite.dart';
import 'package:sufi_one/src/services/api_services.dart';
import 'package:sufi_one/src/database/database_helper.dart';
import 'package:sufi_one/app/modules/smile/models/branch.dart';
import 'dart:convert';

class BranchRepository {
  final DatabaseHelper dbHelper;
  final ApiService apiService;

  BranchRepository({required this.dbHelper, required this.apiService});

  Future<List<Branch>> getBranch({bool forceRefresh = false}) async {
    try {
      if (forceRefresh) {
        return await _fetchFromApiAndSave();
      }

      final localData = await dbHelper.getAllBranches();
      if (localData.isEmpty) {
        return await _fetchFromApiAndSave();
      }

      final serverLastUpdate = await apiService.fetchLastUpdateTime();
      final localLastUpdate = await dbHelper.getLastUpdateTime(
        'cabang_last_update',
      );

      if (serverLastUpdate != null &&
          (localLastUpdate == null ||
              serverLastUpdate.isAfter(localLastUpdate))) {
        return await _fetchFromApiAndSave();
      }

      return localData;
    } catch (e) {
      print('Error fetching branch: $e');
      final localData = await dbHelper.getAllBranches();
      if (localData.isNotEmpty) {
        return localData;
      }
      rethrow;
    }
  }

  Future<List<Branch>> _fetchFromApiAndSave() async {
    try {
      final dynamic rawResponse = await apiService.fetchBranches();

      List<dynamic> branchData;

      if (rawResponse is List) {
        branchData = rawResponse;
      } else if (rawResponse is Map<String, dynamic> &&
          rawResponse.containsKey('data')) {
        branchData = rawResponse['data'];
      } else if (rawResponse is String) {
        final decodedResponse = json.decode(rawResponse);
        if (decodedResponse is List) {
          branchData = decodedResponse;
        } else if (decodedResponse is Map<String, dynamic> &&
            decodedResponse.containsKey('data')) {
          branchData = decodedResponse['data'];
        } else {
          throw Exception('Format respons API tidak didukung setelah decode');
        }
      } else {
        throw Exception(
          'Format respons API tidak valid: Tidak berupa List, Map, atau String JSON',
        );
      }

      if (branchData is! List) {
        throw Exception('Data cabang dari API bukan berupa daftar');
      }

      final List<Branch> branchList =
          branchData
              .map((json) => Branch.fromJson(json as Map<String, dynamic>))
              .toList();

      final db = await dbHelper.database;
      await db.delete('branches');

      Batch batch = db.batch();
      for (var branch in branchList) {
        batch.insert(
          'branches',
          branch.toJson(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
      await batch.commit();

      await dbHelper.updateCollectionTimestamp('cabang_last_update');

      return branchList;
    } catch (e) {
      print('Error fetching branches from API: $e');
      final localData = await dbHelper.getAllBranches();
      if (localData.isNotEmpty) {
        return localData;
      }
      rethrow;
    }
  }
}
