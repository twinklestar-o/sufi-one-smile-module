import 'package:sufi_one/src/services/api_services.dart';
import '../../../../src/database/database_helper.dart';
import '../models/type.dart';

class InvalidApiResponseException implements Exception {
  final String message;
  InvalidApiResponseException(this.message);

  @override
  String toString() => 'InvalidApiResponseException: $message';
}

class TypeRepository {
  final DatabaseHelper dbHelper;
  final ApiService apiService;

  TypeRepository({required this.dbHelper, required this.apiService});

  Future<List<Type>> getType({bool forceRefresh = false}) async {
    try {
      if (forceRefresh) {
        return await _fetchFromApiAndSave();
      }


      final localTypes = await dbHelper.getAllType();

      if (localTypes.isEmpty) {
        return await _fetchFromApiAndSave();
      }

      final serverLastUpdate = await apiService.fetchLastUpdateTime();
      final localLastUpdate = await dbHelper.getLastTypeUpdateTime();

      if (serverLastUpdate != null &&
          (localLastUpdate == null ||
              serverLastUpdate.isAfter(localLastUpdate))) {
        return await _fetchFromApiAndSave();
      }

      return localTypes;
    } catch (e) {
      final localTypes = await dbHelper.getAllType();
      if (localTypes.isNotEmpty) {
        return localTypes;
      }
      rethrow;
    }
  }

  Future<List<Type>> _fetchFromApiAndSave() async {
    try {
      final response = await apiService.fetchType();

      if (response is! Map<String, dynamic> || !response.containsKey('data')) {
        throw InvalidApiResponseException('API response is not a valid map or missing "data" field.');
      }

      final List<dynamic> typeJsonList = response['data'];

      final List<Type> types =
      typeJsonList.map((json) => Type.fromJson(json)).toList();

      await dbHelper.clearAllType();
      for (var type in types) {
        await dbHelper.insertType(type);
      }

      await dbHelper.updateLastTypeUpdateTime();

      return types;
    } catch (e) {
      final localTypes = await dbHelper.getAllType();
      if (localTypes.isNotEmpty) {
        return localTypes;
      }
      rethrow;
    }
  }
}