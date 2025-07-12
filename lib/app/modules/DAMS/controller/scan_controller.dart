import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sufi_one/app/Auth/views/login_view.dart';
import 'package:sufi_one/app/modules/DAMS/model/asset.dart';
import 'package:sufi_one/app/modules/DAMS/model/stockOpname.dart';
import 'package:sufi_one/src/constants/constants.dart';

class ScanController extends GetxController {
  final isLoading = false.obs;

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

        if (responseData['data']['ms_asset_branch'] == null ||
            responseData['data']['asset_detail'] == null) {
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

  Future<List<HistoryStockOpname>> fetchHistoryStock(String token) async {
    final response = await http.get(
      Uri.parse(Url + 'asset-branches'), // Fixed: Added Url prefix
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );

    if (response.statusCode == 200) {
      List<dynamic> body = json.decode(response.body);
      return body.map((e) => HistoryStockOpname.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load history stock');
    }
  }

  Future<void> updateAssetAndDetail(Asset asset, AssetDetail detail) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null || token.isEmpty) {
        Get.offAll(() => LoginPage());
        return;
      }

      final body = {
        "KODE_ASET": asset.kodeAset,
        "DIVISION": asset.division ?? '',
        "FLOOR": asset.floor ?? '',
        "ITEM": detail.item ?? '',
        "TANGGAL_PEMBELIAN":
            detail.tanggalPembelian != null
                ? DateFormat('yyyy-MM-dd').format(detail.tanggalPembelian!)
                : '',
        "COST_AC": detail.costAc != null ? detail.costAc.toString() : '0',
        "BOK_VAL": detail.bokVal != null ? detail.bokVal.toString() : '0',
        "NAMA_USER_ASET": detail.username ?? '',
        "KETERANGAN": detail.description?.trim() ?? '-',
        "STATUS_ASET": detail.status ?? '',
        "CONDITION": detail.condition ?? '',
        "STATUS_USER": detail.username ?? '',
        "POSITION": detail.position ?? '',
        "LOC_ROOM": detail.locRoom ?? '',
        "GROUP": detail.group ?? '',
      };

      final response = await http.put(
        Uri.parse(Url + 'asset-branches'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );

      print('===[DEBUG] BODY UPDATE==');
      print(jsonEncode(body));
      print('Response Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        // Update new token if exists
        if (responseData['token'] != null) {
          await prefs.setString('token', responseData['token']);
        }

        Get.snackbar(
          'Sukses',
          'Data aset berhasil diperbarui',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        return;
      } else {
        final errorMessage =
            responseData['message'] ??
            'Gagal memperbarui aset. Status code: ${response.statusCode}';
        throw Exception(errorMessage);
      }
    } catch (e) {
      String errorMessage = 'Terjadi kesalahan';

      if (e is SocketException) {
        errorMessage = 'Tidak ada koneksi internet';
      } else if (e.toString().contains('401')) {
        errorMessage = 'Sesi telah berakhir, silakan login kembali';
        Get.offAll(() => LoginPage());
      } else {
        errorMessage = e.toString().replaceAll('Exception: ', '');
      }

      Get.snackbar(
        'Error',
        errorMessage,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> updateDetailAsset(AssetDetail asset) async {
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
