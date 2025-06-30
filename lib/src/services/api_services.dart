import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'package:sufi_one/app/Auth/views/login_view.dart';
import 'package:sufi_one/app/modules/smile/constants/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  final String baseUrl;

  ApiService({this.baseUrl = Url});

  Future<String> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null || token.isEmpty) {
      Get.offAll(() => LoginPage());
      throw Exception('Token tidak tersedia. Sesi telah berakhir.');
    }
    return token;
  }

  // Enhanced headers for better API compatibility
  Map<String, String> _getHeaders(String token) {
    return {
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };
  }

  // Type endpoint - returns Map with 'data' key
  Future<Map<String, dynamic>> fetchType() async {
    final token = await _getToken();
    final response = await http.get(
      Uri.parse(Url + 'type'),
      headers: _getHeaders(token),
    );

    print('Type API Response Status: ${response.statusCode}');
    print('Type API Response Body: ${response.body}');

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else if (response.statusCode == 401) {
      Get.offAll(() => LoginPage());
      throw Exception('Sesi telah berakhir, silakan login kembali');
    } else {
      throw Exception('Gagal memuat data Type: ${response.statusCode}');
    }
  }

  // Jabatan endpoint - returns Map with 'data' key
  Future<Map<String, dynamic>> fetchJabatan() async {
    final token = await _getToken();
    final response = await http.get(
      Uri.parse(Url + 'jabatan'),
      headers: _getHeaders(token),
    );

    print('Jabatan API Response Status: ${response.statusCode}');
    print('Jabatan API Response Body: ${response.body}');

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else if (response.statusCode == 401) {
      Get.offAll(() => LoginPage());
      throw Exception('Sesi telah berakhir, silakan login kembali');
    } else {
      throw Exception('Gagal memuat data jabatan: ${response.statusCode}');
    }
  }

  // Area endpoint - returns Map with 'data' key (backward compatible)
  Future<Map<String, dynamic>> fetchArea() async {
    final token = await _getToken();
    final response = await http.get(
      Uri.parse(
        Url + 'area',
      ), // Using singular 'area' as per colleague's version
      headers: _getHeaders(token),
    );

    print('Area API Response Status: ${response.statusCode}');
    print('Area API Response Body: ${response.body}');

    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);
      // If response is already a Map, return it
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
      // If response is a List, wrap it in a Map with 'data' key for backward compatibility
      else if (decoded is List) {
        return {'data': decoded};
      } else {
        throw Exception('Unexpected area response format');
      }
    } else if (response.statusCode == 401) {
      Get.offAll(() => LoginPage());
      throw Exception('Sesi telah berakhir, silakan login kembali');
    } else {
      throw Exception('Gagal memuat data area: ${response.statusCode}');
    }
  }

  // Branches endpoint - Enhanced version with optional area_code parameter
  Future<List<dynamic>> fetchBranches([String? areaCode]) async {
    final token = await _getToken();
    String url = Url + 'branches';
    if (areaCode != null && areaCode.isNotEmpty) {
      url += '?area_code=$areaCode';
    }

    final response = await http.get(
      Uri.parse(url),
      headers: _getHeaders(token),
    );

    print('Branches API Response Status: ${response.statusCode}');
    print('Branches API Response Body: ${response.body}');
    print('Branches API URL: $url');

    if (response.statusCode == 200) {
      final dynamic decodedResponse = json.decode(response.body);
      // Handle both direct array and wrapped response
      if (decodedResponse is List) {
        return decodedResponse;
      } else if (decodedResponse is Map<String, dynamic> &&
          decodedResponse.containsKey('data') &&
          decodedResponse['data'] is List) {
        return decodedResponse['data'] as List<dynamic>;
      } else {
        throw Exception(
          'Format respons API untuk branches tidak valid atau tidak sesuai harapan: $decodedResponse',
        );
      }
    } else if (response.statusCode == 401) {
      Get.offAll(() => LoginPage());
      throw Exception('Sesi telah berakhir, silakan login kembali');
    } else {
      throw Exception('Gagal memuat data Branches: ${response.statusCode}');
    }
  }

  // Product endpoint - returns Map (colleague's version)
  Future<Map<String, dynamic>> fetchProduct() async {
    final token = await _getToken();
    final response = await http.get(
      Uri.parse(
        Url + 'product',
      ), // Using singular 'product' as per colleague's version
      headers: _getHeaders(token),
    );

    print('Product API Response Status: ${response.statusCode}');
    print('Product API Response Body: ${response.body}');

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else if (response.statusCode == 401) {
      Get.offAll(() => LoginPage());
      throw Exception('Sesi telah berakhir, silakan login kembali');
    } else {
      throw Exception('Gagal memuat data product: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> fetchJabatanSFI() async {
    final token = await _getToken();
    final response = await http.get(
      Uri.parse(Url + 'jabatansfi'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else if (response.statusCode == 401) {
      // Token expired, redirect to login
      Get.offAll(() => LoginPage());
      throw Exception('Sesi telah berakhir, silakan login kembali');
    } else {
      throw Exception('Gagal memuat data jabatanSFI');
    }
  }

  // Products endpoint - returns List (for direct visit compatibility)
  Future<List<dynamic>> fetchProducts() async {
    final token = await _getToken();
    final response = await http.get(
      Uri.parse(Url + 'products'), // Using plural 'products'
      headers: _getHeaders(token),
    );

    print('Products API Response Status: ${response.statusCode}');
    print('Products API Response Body: ${response.body}');

    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);
      // Handle both direct array and wrapped response
      if (decoded is List) {
        return decoded;
      } else if (decoded is Map && decoded.containsKey('data')) {
        return decoded['data'];
      } else {
        throw Exception('Unexpected products response format');
      }
    } else if (response.statusCode == 401) {
      Get.offAll(() => LoginPage());
      throw Exception('Sesi telah berakhir, silakan login kembali');
    } else {
      throw Exception('Gagal memuat data produk: ${response.statusCode}');
    }
  }

  // Dealer endpoint - returns Map (colleague's version)
  Future<Map<String, dynamic>> fetchDealer() async {
    final token = await _getToken();
    final response = await http.get(
      Uri.parse(Url + 'dealers'),
      headers: _getHeaders(token),
    );

    print('Dealer API Response Status: ${response.statusCode}');
    print('Dealer API Response Body: ${response.body}');

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      if (jsonData is Map<String, dynamic>) {
        return jsonData; // Expected by DealerRepository
      } else {
        throw Exception('Unexpected response format');
      }
    } else if (response.statusCode == 401) {
      Get.offAll(() => LoginPage());
      throw Exception('Sesi telah berakhir, silakan login kembali');
    } else {
      throw Exception('Gagal memuat data dealer: ${response.statusCode}');
    }
  }

  // Dealers endpoint - returns List with optional query (for direct visit compatibility)
  Future<List<dynamic>> fetchDealers({String? query}) async {
    final token = await _getToken();
    String url = Url + 'dealers';
    if (query != null && query.isNotEmpty) {
      url += '?q=$query';
    }

    final response = await http.get(
      Uri.parse(url),
      headers: _getHeaders(token),
    );

    print('Dealers API Response Status: ${response.statusCode}');
    print('Dealers API Response Body: ${response.body}');

    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);
      // Handle both direct array and wrapped response
      if (decoded is List) {
        return decoded;
      } else if (decoded is Map && decoded.containsKey('data')) {
        return decoded['data'];
      } else {
        throw Exception('Unexpected dealers response format');
      }
    } else if (response.statusCode == 401) {
      Get.offAll(() => LoginPage());
      throw Exception('Sesi telah berakhir, silakan login kembali');
    } else {
      throw Exception('Gagal memuat data dealer: ${response.statusCode}');
    }
  }

  // Purpose endpoint - returns Map with 'data' key
  Future<Map<String, dynamic>> fetchPurpose() async {
    final token = await _getToken();
    final response = await http.get(
      Uri.parse(Url + 'purpose'),
      headers: _getHeaders(token),
    );

    print('Purpose API Response Status: ${response.statusCode}');
    print('Purpose API Response Body: ${response.body}');

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else if (response.statusCode == 401) {
      Get.offAll(() => LoginPage());
      throw Exception('Sesi telah berakhir, silakan login kembali');
    } else {
      throw Exception('Gagal memuat data purpose: ${response.statusCode}');
    }
  }

  // Submit Direct Visit - Enhanced with better error handling
  Future<Map<String, dynamic>> submitDirectVisit({
    required String jabatanSaya,
    required String areaCode,
    required String branchCode,
    required String productCode,
    required String dealerCode,
    required String tipeVisit,
    required String tujuanVisit,
    required String dariTanggal,
    required String sampaiTanggal,
    required String tanggalSelesai,
    required String namaPic,
    required String themeOfDiscussion,
    required String problem,
    required String followUp,
    required String description,
    required File photo1,
    required File photo2,
    required List<Map<String, String>> mainPersons,
    int status = 0, // default status = 0 (planning)
    double? latitude,
    double? longitude,
  }) async {
    final token = await _getToken();

    // Validasi panjang data
    if (dealerCode.length > 20) {
      throw Exception('Dealer code terlalu panjang. Maksimal 20 karakter.');
    }
    if (areaCode.length > 10) {
      throw Exception('Area code terlalu panjang. Maksimal 10 karakter.');
    }
    if (branchCode.length > 10) {
      throw Exception('Branch code terlalu panjang. Maksimal 10 karakter.');
    }
    if (productCode.length > 20) {
      throw Exception('Product code terlalu panjang. Maksimal 20 karakter.');
    }

    print('Validating field lengths:');
    print('Dealer Code: $dealerCode (${dealerCode.length} chars)');
    print('Area Code: $areaCode (${areaCode.length} chars)');
    print('Branch Code: $branchCode (${branchCode.length} chars)');
    print('Product Code: $productCode (${productCode.length} chars)');

    var request = http.MultipartRequest(
      'POST',
      Uri.parse(Url + 'direct-visit'),
    );

    request.headers['Authorization'] = 'Bearer $token';
    request.headers['Accept'] = 'application/json';

    // Kirim semua field
    request.fields['jabatan_saya'] = jabatanSaya;
    request.fields['area_code'] = areaCode;
    request.fields['branch_code'] = branchCode;
    request.fields['product_code'] = productCode;
    request.fields['dealer_code'] = dealerCode;
    request.fields['tipe_visit'] = tipeVisit;
    request.fields['tujuan_visit'] = tujuanVisit;
    request.fields['dari_tanggal'] = dariTanggal;
    request.fields['sampai_tanggal'] = sampaiTanggal;
    request.fields['tanggal_selesai'] = tanggalSelesai;
    request.fields['nama_pic'] = namaPic;
    request.fields['theme_of_discussion'] = themeOfDiscussion;
    request.fields['problem'] = problem;
    request.fields['follow_up'] = followUp;
    request.fields['description'] = description;
    request.fields['status'] = status.toString(); // <<-- tambahkan status

    if (latitude != null) request.fields['latitude'] = latitude.toString();
    if (longitude != null) request.fields['longitude'] = longitude.toString();

    // Kirim main persons
    for (int i = 0; i < mainPersons.length; i++) {
      request.fields['main_persons[$i][jabatan]'] = mainPersons[i]['jabatan']!;
      request.fields['main_persons[$i][nama_pic]'] =
      mainPersons[i]['nama']!;
      request.fields['main_persons[$i][telp_pic]'] =
      mainPersons[i]['telp']!;
    }

    // Kirim file foto
    request.files.add(await http.MultipartFile.fromPath('photo1', photo1.path));
    request.files.add(await http.MultipartFile.fromPath('photo2', photo2.path));

    print('Submitting Direct Visit with fields: ${request.fields}');

    try {
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print('Submit Response Status: ${response.statusCode}');
      print('Submit Response Body: ${response.body}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        return json.decode(response.body);
      } else if (response.statusCode == 401) {
        Get.offAll(() => LoginPage());
        throw Exception('Sesi telah berakhir, silakan login kembali');
      } else {
        final errorData = json.decode(response.body);
        throw Exception(
          'Gagal submit: ${errorData['message'] ?? 'Unknown error'} (${response.statusCode})',
        );
      }
    } catch (e) {
      print('Submit Error: $e');
      throw Exception('Error submitting direct visit: $e');
    }
  }

  // Last update time for collection sync
  Future<DateTime?> fetchLastUpdateTime() async {
    try {
      final token = await _getToken();
      final response = await http.get(
        Uri.parse(baseUrl + 'collection'),
        headers: _getHeaders(token),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data.containsKey('last_update') && data['last_update'] != null) {
          return DateTime.parse(data['last_update']);
        }
        return null;
      } else if (response.statusCode == 401) {
        Get.offAll(() => LoginPage());
        return null;
      }
      return null;
    } catch (e) {
      print('Error fetching last update time: $e');
      return null;
    }
  }
}