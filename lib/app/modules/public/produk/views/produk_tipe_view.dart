import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sufi_one/app/theme/color_constant.dart';
import 'package:sufi_one/app/modules/public/produk/controllers/produk_controller.dart';
import 'package:sufi_one/app/modules/public/produk/views/produk_harga_view.dart';
import 'package:sufi_one/app/modules/public/widgets/appbarWsidebar.dart';
import 'package:sufi_one/app/modules/public/widgets/appbarWOsidebar.dart';
import 'package:sufi_one/app/modules/public/widgets/sidebar.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProdukTipeView extends StatefulWidget {
  @override
  State<ProdukTipeView> createState() => _ProdukTipeViewState();
}

class _ProdukTipeViewState extends State<ProdukTipeView> {
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
    final tipeList = controller.getTipeList();
    return Scaffold(
      backgroundColor: AppColors.bg1,
      appBar: isLoggedIn
          ? SuzukiFinanceAppBarWsidebar() // ✅ Saat sudah login
          : SuzukiFinanceAppBarWOsidebar(),
      drawer: isLoggedIn ? Drawer(child: AppSidebar()) : null,
      resizeToAvoidBottomInset: false,
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 1,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 16 / 9,
        ),
        itemCount: tipeList.length,
        itemBuilder: (context, index) {
          final tipe = tipeList[index];
          return GestureDetector(
            onTap: () {
              controller.selectedTipe.value = tipe['name'];
              Get.to(() => ProdukHargaView());
            },
            child: Card(
              color: AppColors.bg1,
              elevation: 4,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Image.asset(tipe['image']!, fit: BoxFit.cover),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      tipe['name']!,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
