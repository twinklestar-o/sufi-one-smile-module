import 'dart:convert';
import 'dart:io';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sufi_one/app/modules/DAMS/model/asset.dart';
import 'package:sufi_one/src/constants/constants.dart';

class ScanController extends GetxController {
  Future<Asset> getAssetByKodeAset(String kodeAset) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null || token.isEmpty) {
        throw Exception('Session expired, please login again');
      }

      final response = await http.post(
        Uri.parse(Url + 'asset-branches/asset'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'KODE_ASET': kodeAset}),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        if (responseData['data'] == null) {
          throw Exception('Asset not found or data is missing');
        }

        return Asset.fromJson(responseData['data']);
      } else if (response.statusCode == 404) {
        throw Exception('Asset with code $kodeAset not found');
      } else {
        throw Exception('Failed to fetch asset data: ${response.statusCode}');
      }
    } on SocketException {
      throw Exception('No internet connection');
    } catch (e) {
      throw Exception('Error: ${e.toString()}');
    }
  }

  Future<bool> updateAsset(Asset asset) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null || token.isEmpty) {
        throw Exception('Session expired, please login again');
      }

      final response = await http.put(
        Uri.parse('${Url}asset/${asset.kodeAset}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(asset.toJson()),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        throw Exception('Failed to update asset: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error updating asset: ${e.toString()}');
    }
  }
}
