import 'package:sufi_one/src/services/api_services.dart';
import '../../../../src/database/database_helper.dart';
import '../models/product.dart';

class ProductRepository {
  final DatabaseHelper dbHelper;
  final ApiService apiService;

  ProductRepository({required this.dbHelper, required this.apiService});

  Future<List<Product>> getProduct({bool forceRefresh = false}) async {
    try {
      if (forceRefresh) {
        return await _fetchFromApiAndSave();
      }

      final localData = await dbHelper.getAllProduct();
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
      final localData = await dbHelper.getAllProduct();
      if (localData.isNotEmpty) {
        return localData;
      }
      rethrow;
    }
  }

  Future<List<Product>> _fetchFromApiAndSave() async {
    try {
      final response = await apiService.fetchProduct();

      // Pastikan response adalah Map dan memiliki field 'data'
      if (response is! Map<String, dynamic> || !response.containsKey('data')) {
        throw Exception('Invalid API response format');
      }

      // Ekstrak list Product dari field 'data'
      final List<dynamic> productData = response['data'];

      // Konversi ke List<Product>
      final List<Product> productList =
      productData.map((json) => Product.fromJson(json)).toList();

      // Clear old data
      final db = await dbHelper.database;
      await db.delete('product');

      // Insert new data
      for (var product in productList) {
        await dbHelper.insertProduct(product);
      }

      // Update timestamp
      await dbHelper.updateCollectionTimestamp();

      return productList;
    } catch (e) {
      // If API fails, try to return local data
      final localData = await dbHelper.getAllProduct();
      if (localData.isNotEmpty) {
        return localData;
      }
      rethrow;
    }
  }
}
