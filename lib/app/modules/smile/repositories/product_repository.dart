import 'package:sufi_one/src/services/api_services.dart';
import '../../../../src/database/database_helper.dart';
import '../models/product.dart';

class ProductRepository {
  final DatabaseHelper dbHelper;
  final ApiService apiService;

  ProductRepository({required this.dbHelper, required this.apiService});

  // lib/app/modules/smile/repositories/product_repository.dart
  // lib/app/modules/smile/repositories/product_repository.dart
// ... (bagian atas tidak berubah)

  Future<List<Product>> getProduct({bool forceRefresh = false}) async {
    try {
      print('🚀 getProduct called with forceRefresh: $forceRefresh');

      if (forceRefresh) {
        print('🔄 Force refresh requested - calling API');
        return await _fetchFromApiAndSave();
      }

      final localData = await dbHelper.getAllProduct();
      print('📱 Local data count: ${localData.length}');

      if (localData.isEmpty) {
        print('📱 No local data found - calling API');
        return await _fetchFromApiAndSave();
      }

      // Debug: Print local data
      for (int i = 0; i < localData.length; i++) {
        print('📱 Local product $i: ${localData[i].code} - ${localData[i].name}'); // Ganti .kode menjadi .code
      }

      // Cek server update
      print('🔍 Checking server update...');
      final serverLastUpdate = await apiService.fetchLastUpdateTime();
      final localLastUpdate = await dbHelper.getLastUpdateTime('product_last_update');

      print('🔍 Server last update: $serverLastUpdate');
      print('🔍 Local last update: $localLastUpdate');

      if (serverLastUpdate != null &&
          (localLastUpdate == null ||
              serverLastUpdate.isAfter(localLastUpdate))) {
        print('🔄 Server has newer data - calling API');
        return await _fetchFromApiAndSave();
      }

      print('📱 Using local data (up to date)');
      return localData;
    } catch (e) {
      print('❌ Error in getProduct: $e');
      // Fallback to local data if error occurs
      final localData = await dbHelper.getAllProduct();
      if (localData.isNotEmpty) {
        print('📱 Fallback to local data: ${localData.length} products');
        return localData;
      }
      rethrow;
    }
  }

  Future<List<Product>> _fetchFromApiAndSave() async {
    try {
      print('🚀 Starting _fetchFromApiAndSave for products...');

      final response = await apiService.fetchProduct();

      print('🔍 Product Repository - Raw API Response: $response');
      print('🔍 Response Type: ${response.runtimeType}');

      if (response is! Map<String, dynamic>) {
        throw Exception('Invalid API response format: Expected Map, got ${response.runtimeType}');
      }

      if (!response.containsKey('data')) {
        throw Exception('Invalid API response format: Missing "data" field');
      }

      final dynamic productData = response['data'];
      print('🔍 Product Data: $productData');
      print('🔍 Product Data Type: ${productData.runtimeType}');

      if (productData is! List) {
        throw Exception('Invalid API response format: "data" field is not a List, got ${productData.runtimeType}');
      }

      print('🔍 Number of products from API: ${productData.length}');

      final List<Product> productList = [];

      for (int i = 0; i < productData.length; i++) {
        try {
          final json = productData[i];
          print('🔍 Processing product $i: $json');
          print('🔍 Product $i type: ${json.runtimeType}');

          if (json is Map<String, dynamic>) {
            final product = Product.fromJson(json);
            productList.add(product);
            print('✅ Successfully parsed product $i: ${product.toString()}');
          } else {
            print('❌ Product $i is not a Map: ${json.runtimeType}');
            continue;
          }
        } catch (e) {
          print('❌ Error parsing product JSON at index $i: ${productData[i]}, Error: $e');
          continue;
        }
      }

      print('✅ Successfully parsed ${productList.length} products total');

      // Debug: Print semua product yang berhasil di-parse
      for (int i = 0; i < productList.length; i++) {
        print('📦 Product $i: ${productList[i].code} - ${productList[i].name}'); // Ganti .kode menjadi .code
      }

      // Clear old data
      final db = await dbHelper.database;
      await db.delete('product');
      print('🗑️ Cleared old product data');

      // Insert new data
      for (var product in productList) {
        await dbHelper.insertProduct(product);
        print('💾 Inserted product: ${product.code} - ${product.name}'); // Ganti .kode menjadi .code
      }

      // Update timestamp
      await dbHelper.updateCollectionTimestamp('product_last_update');
      print('⏰ Updated product timestamp');

      return productList;
    } catch (e) {
      print('❌ Error in Product _fetchFromApiAndSave: $e');
      print('📱 Trying to fallback to local data...');

      final localData = await dbHelper.getAllProduct();
      print('📱 Local data count: ${localData.length}');

      if (localData.isNotEmpty) {
        for (var product in localData) {
          print('📱 Local product: ${product.code} - ${product.name}'); // Ganti .kode menjadi .code
        }
        return localData;
      }
      rethrow;
    }
  }
}
