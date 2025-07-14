// lib/src/utils/app_constants.dart
class AppConstants {
  static const int cacheDurationHours = 24; // Durasi cache dalam jam (misal: 24 jam)

  // Kunci untuk timestamp cache di database
  static const String productCacheKey = 'product_last_update';
  static const String dealerCacheKey = 'dealer_last_update';
  static const String areaCacheKey = 'area_last_update';
  static const String branchCacheKey = 'branch_last_update';
  static const String jabatanCacheKey = 'jabatan_last_update';
  static const String jabatanSFICacheKey = 'jabatanSFI_last_update';
  static const String purposeCacheKey = 'purpose_last_update';
  static const String typeCacheKey = 'type_last_update';
  static const String collectionCacheKey = 'collection_last_update';


}