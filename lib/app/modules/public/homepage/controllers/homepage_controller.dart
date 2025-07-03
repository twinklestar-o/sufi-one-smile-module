import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sufi_one/app/modules/public/homepage/views/homepage_view.dart';
import 'package:sufi_one/app/modules/smile/models/user.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:sufi_one/app/modules/public/homepage/models/homepage_model.dart';
import 'package:sufi_one/app/modules/public/home_routes.dart';
import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sufi_one/app/Auth/views/login_view.dart';
import 'package:sufi_one/app/modules/smile/constants/constants.dart';

class HomepageController extends GetxController {
  var currentPage = 0.obs;
  Timer? _timer;

  List<ImageContentModel> bannerImages = [
    ImageContentModel(imagePath: 'res/images/suzuki_iklan1.jpg'),
    ImageContentModel(imagePath: 'res/images/suzuki_iklan2.jpg'),
    ImageContentModel(imagePath: 'res/images/suzuki_iklan3.jpg'),
    ImageContentModel(imagePath: 'res/images/suzuki_iklan4.jpg'),
  ];

  List<ImageContentModel> newsImages = [
    ImageContentModel(imagePath: 'res/images/suzuki_iklan1.jpg'),
    ImageContentModel(imagePath: 'res/images/suzuki_iklan4.jpg'),
    ImageContentModel(imagePath: 'res/images/suzuki_iklan2.jpg'),
    ImageContentModel(imagePath: 'res/images/suzuki_iklan5.jpg'),
    ImageContentModel(imagePath: 'res/images/suzuki_iklan3.jpg'),
  ];

  List<MenuItemModel> menuItems = [
    MenuItemModel(
      iconPath: 'res/images/ic_icon_wop.png',
      label: 'Promo',
      route: HomeRoutes.promo,
    ),
    MenuItemModel(
      iconPath: 'res/images/ic_icon_product.png',
      label: 'Produk',
      route: HomeRoutes.produkKategori,
    ),
    MenuItemModel(
      iconPath: 'res/images/ic_icon_credit_simulation.png',
      label: 'Simulasi Kredit',
      route: HomeRoutes.genericWebView,
    ),
    MenuItemModel(
      iconPath: 'res/images/ic_icon_promo.png',
      label: 'Fasilitas',
      route: HomeRoutes.genericWebView,
    ),
    MenuItemModel(
      iconPath: 'res/images/ic_icon_branch.png',
      label: 'Cabang',
      route: HomeRoutes.cabang,
    ),
    MenuItemModel(
      iconPath: 'res/images/ic_icon_installment_status.png',
      label: 'Opsi Pembayaran & Asuransi',
      route: HomeRoutes.genericWebView,
    ),
  ];

  void onPageChanged(int index) {
    currentPage.value = index;
  }

  void startAutoSlide(PageController pageController) {
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (!pageController.hasClients) return;
      final nextPage = (currentPage.value + 1) % bannerImages.length;
      pageController.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    });
  }

  // ✅ Fungsi untuk membuka halaman website promo
  Future<void> openPromoWebsite() async {
    final Uri promoUrl = Uri.parse(
      'https://www.sfi.co.id/category_news/category/5',
    );
    if (await canLaunchUrl(promoUrl)) {
      await launchUrl(promoUrl, mode: LaunchMode.externalApplication);
    } else {
      Get.snackbar('Error', 'Tidak dapat membuka link promo');
    }
  }

  Future<User> fetchUser() async {
    try {
      // Ambil token dari SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null || token.isEmpty) {
        Get.offAll(() => LoginPage());
        throw Exception('Token tidak tersedia');
      }

      // Lakukan request ke endpoint profile dengan token
      final response = await http.get(
        Uri.parse(Url + 'profile'),
        headers: {
          HttpHeaders.authorizationHeader: 'Bearer $token',
          HttpHeaders.acceptHeader: 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final responseJson = jsonDecode(response.body) as Map<String, dynamic>;
        return User.fromJson(responseJson);
      } else {
        // Jika status code bukan 200, arahkan ke login
        Get.offAll(() => HomepageView());
        throw Exception(
          'Gagal mengambil data profil. Status code: ${response.statusCode}',
        );
      }
    } catch (e) {
      // Tangani error lainnya dan arahkan ke login
      Get.offAll(() => HomepageView());
      throw Exception('Terjadi kesalahan: $e');
    }
  }


  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }
}
