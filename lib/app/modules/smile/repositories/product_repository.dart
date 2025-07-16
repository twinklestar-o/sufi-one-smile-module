import 'package:sufi_one/src/database/SMILE/database_helper.dart';
import 'package:sufi_one/src/services/SMILE/api_services.dart';
import 'package:sufi_one/app/modules/smile/models/product.dart';
import 'package:sufi_one/src/utils/app_constants.dart'; // Import AppConstants
import 'package:flutter/foundation.dart'; // Untuk debugPrint

class ProductRepository {
  final DatabaseHelperSmile dbHelper;
  final ApiServiceSmile apiService;

  ProductRepository({required this.dbHelper, required this.apiService});

  Future<List<Product>> getProducts({bool forceRefresh = false}) async {
    // Mengubah nama metode ke plural
    debugPrint('🚀 getProducts called with forceRefresh: $forceRefresh');
    List<Product> localData = [];

    try {
      localData = await dbHelper.getAllProduct(); // Menggunakan getAllProducts
      debugPrint('📱 Fetched ${localData.length} products from SQLite');
    } catch (e) {
      debugPrint('❌ Error fetching local products: $e');
      forceRefresh = true;
    }

    final lastUpdate = await dbHelper.getLastUpdate(
      AppConstants.productCacheKey,
    ); // Menggunakan getLastUpdate
    final bool shouldFetch =
        forceRefresh ||
        localData.isEmpty ||
        (lastUpdate == null ||
            DateTime.now().difference(lastUpdate).inHours >
                AppConstants.cacheDurationHours);

    debugPrint('📱 Local data count: ${localData.length}');
    debugPrint('📱 Last update for products: $lastUpdate');
    debugPrint('📱 Should fetch from API for products: $shouldFetch');

    if (shouldFetch) {
      debugPrint('📱 No local data or cache expired - calling API');
      try {
        return await _fetchFromApiAndSave();
      } catch (e) {
        debugPrint('❌ Error in Product _fetchFromApiAndSave: $e');
        debugPrint('📱 Trying to fallback to local data...');
        if (localData.isNotEmpty) {
          debugPrint(
            '📱 Fallback successful, returning ${localData.length} local products.',
          );
          return localData;
        } else {
          debugPrint('📱 No local data available for fallback.');
          rethrow;
        }
      }
    } else {
      debugPrint('✅ Returning ${localData.length} products from cache.');
      return localData;
    }
  }

  Future<List<Product>> _fetchFromApiAndSave() async {
    debugPrint('🚀 Starting _fetchFromApiAndSave for products...');
    try {
      final response =
          await apiService
              .fetchProduct(); // Asumsi ada fetchProduct di ApiService
      debugPrint('🔍 Product Repository - Raw API Response: $response');

      if (response['status'] == true && response['data'] is List) {
        final List<dynamic> productData = response['data'];
        debugPrint('🔍 Product Data: $productData');
        debugPrint('🔍 Product Data Type: ${productData.runtimeType}');
        debugPrint('🔍 Number of products from API: ${productData.length}');

        final List<Product> productList =
            productData.map((json) {
              final product = Product.fromJson(json);
              debugPrint('✅ Successfully parsed product: $product');
              return product;
            }).toList();

        debugPrint(
          '✅ Successfully parsed ${productList.length} products total',
        );
        for (var p in productList) {
          debugPrint('📦 Product: ${p.code} - ${p.name}'); // Menggunakan .code
        }

        debugPrint('🗑️ Cleared old product data');
        await dbHelper.clearProducts(); // Menggunakan clearProducts
        await dbHelper.insertProducts(
          productList,
        ); // Menggunakan insertProducts
        debugPrint('💾 Inserted ${productList.length} products to SQLite');

        await dbHelper.updateLastUpdate(
          AppConstants.productCacheKey,
        ); // Menggunakan updateLastUpdate
        debugPrint('⏰ Updated last update timestamp for products');

        return productList;
      } else {
        throw Exception('Unexpected response format for products: $response');
      }
    } catch (e) {
      debugPrint('❌ Error fetching products from API: $e');
      rethrow;
    }
  }

  // Tambahkan metode clearAndRefresh jika Anda ingin memilikinya di repository
  Future<void> _clearAndRefreshProducts() async {
    debugPrint('🗑️ Clearing local product data');
    await dbHelper.clearProducts();
    await dbHelper.deleteLastUpdate(AppConstants.productCacheKey);
    debugPrint('🔄 Force refreshing products from API...');
    await getProducts(forceRefresh: true);
  }
}
