import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sufi_one/app/modules/public/widgets/appbarWOsidebar.dart';
import 'package:sufi_one/app/theme/color_constant.dart';
import 'package:sufi_one/app/modules/public/produk/controllers/produk_controller.dart';
import 'package:sufi_one/app/modules/public/produk/views/produk_detail_view.dart';
import 'package:sufi_one/app/modules/public/widgets/appbarWsidebar.dart';
import 'package:sufi_one/app/modules/public/widgets/sidebar.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProdukHargaView extends StatefulWidget {
  @override
  State<ProdukHargaView> createState() => _ProdukHargaViewState();
}

class _ProdukHargaViewState extends State<ProdukHargaView> {
  final ProdukController controller = Get.find<ProdukController>();
  bool isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    checkLoginStatus(); // ⬅️ Tambahkan pengecekan login
  }

  Future<void> checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    setState(() {
      isLoggedIn = token != null && token.isNotEmpty;
    });
  }

  @override
  Widget build(BuildContext context) {
    final tipeDetail = controller.getProdukDetail();

    if (tipeDetail == null) {
      return Scaffold(
        backgroundColor: AppColors.bg1,
        appBar: SuzukiFinanceAppBarWsidebar(),
        drawer: Drawer(child: AppSidebar()),
        body: const Center(child: Text('Produk tidak ditemukan')),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.bg1,
      appBar: isLoggedIn
          ? SuzukiFinanceAppBarWsidebar() // ✅ Saat sudah login
          : SuzukiFinanceAppBarWOsidebar(),
      drawer: isLoggedIn ? Drawer(child: AppSidebar()) : null,
      resizeToAvoidBottomInset: false,
      body: Center(
        child: GestureDetector(
          onTap: () {
            Get.to(() => ProdukDetailView());
          },
          child: Card(
            color: AppColors.bg1,
            elevation: 4,
            margin: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  tipeDetail['image'],
                  height: 200,
                  fit: BoxFit.cover,
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    tipeDetail['price'],
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
