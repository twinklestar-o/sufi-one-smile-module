import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sufi_one/app/modules/public/homepage/controllers/homepage_controller.dart';
import 'package:sufi_one/app/modules/public/home_routes.dart';
import 'package:sufi_one/app/modules/public/widgets/appbarWOsidebar.dart';
import 'package:sufi_one/app/modules/public/widgets/appbarWsidebar.dart';
import 'package:sufi_one/app/modules/public/widgets/sidebar.dart';
import 'package:sufi_one/app/modules/public/widgets/bottomnavbar.dart';
import 'package:sufi_one/app/theme/color_constant.dart';
import 'package:sufi_one/app/theme/fontstyle.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomepageView extends StatefulWidget {
  const HomepageView({Key? key}) : super(key: key);

  @override
  State<HomepageView> createState() => _HomepageViewState();
}

class _HomepageViewState extends State<HomepageView> {
  late final HomepageController controller;
  final RxBool isLoggedIn = false.obs;
  late final PageController _bannerPageController;
  final PageController _newsPageController = PageController(
    viewportFraction: 0.7,
  );

  final List<String> bannerImages = [
    'res/images/suzuki_iklan1.jpg',
    'res/images/suzuki_iklan2.jpg',
    'res/images/suzuki_iklan3.jpg',
    'res/images/suzuki_iklan4.jpg',
  ];

  final List<String> newsImages = [
    'res/images/suzuki_iklan1.jpg',
    'res/images/suzuki_iklan4.jpg',
    'res/images/suzuki_iklan2.jpg',
    'res/images/suzuki_iklan5.jpg',
    'res/images/suzuki_iklan3.jpg',
  ];

  @override
  void initState() {
    super.initState();
    checkLoginStatus();
    try {
      controller = Get.find<HomepageController>();
    } catch (e) {
      controller = Get.put(HomepageController());
    }
    _bannerPageController = PageController();
    controller.startAutoSlide(_bannerPageController);
  }



  @override
  void dispose() {
    _bannerPageController.dispose();
    _newsPageController.dispose();
    super.dispose();
  }

  Future<void> checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    isLoggedIn.value = token != null && token.isNotEmpty;
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg1,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Obx(() => isLoggedIn.value
            ? SuzukiFinanceAppBarWsidebar()
            : SuzukiFinanceAppBarWOsidebar()),
      ),


      drawer: Drawer(child: AppSidebar()),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildBanner(),
            const Divider(
              height: 20,
            thickness: 12,
            color: AppColors.splashStart,
            ),
            _buildMenuGrid(),
            const Divider(
              height: 20,
              thickness: 9,
              color: AppColors.splashStart,
            ),
            _OrderSection(),
            const Divider(
              height: 20,
              thickness: 9,
              color: AppColors.splashStart,
            ),
            _NewsCarousel(),
            // const Divider(
            //   height: 20,
            //   thickness: 12,
            //   color: AppColors.splashStart,
            // ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavbar(selectedIndex: 0),
    );
  }

  Widget _buildBanner() {
    return Obx(
          () => Column(
        children: [
          SizedBox(
            height: 240,
            child: PageView.builder(
              controller: _bannerPageController,
              onPageChanged: controller.onPageChanged,
              itemCount: bannerImages.length,
              itemBuilder:
                  (context, index) => Image.asset(
                bannerImages[index],
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              bannerImages.length,
                  (index) => Container(
                margin: const EdgeInsets.symmetric(horizontal: 4.0),
                width: 8.0,
                height: 8.0,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color:
                  controller.currentPage.value == index
                      ? AppColors.snack
                      : Colors.grey,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuGrid() {
    final List<Map<String, String>> menuItems = [
      {'icon': 'res/images/ic_icon_wop.png', 'label': 'Promo'},
      {'icon': 'res/images/ic_icon_product.png', 'label': 'Produk'},
      {
        'icon': 'res/images/ic_icon_credit_simulation.png',
        'label': 'Simulasi Kredit',
      },
      {'icon': 'res/images/ic_icon_promo.png', 'label': 'Fasilitas'},
      {'icon': 'res/images/ic_icon_branch.png', 'label': 'Cabang'},
      {
        'icon': 'res/images/ic_icon_installment_status.png',
        'label': 'Opsi Pembayaran & Asuransi',
      },
    ];

    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Fitur',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12.0),
          GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 3.0,
            mainAxisSpacing: 3.0,
            children:
            menuItems.map((item) {
              return InkWell(
                onTap: () {
                  final label = item['label'];

                  switch (label) {
                    case 'Promo':
                      Get.toNamed(HomeRoutes.promo);
                      break;
                    case 'Produk':
                      Get.toNamed(HomeRoutes.produkKategori);
                      break;
                    case 'Simulasi Kredit':
                      Get.toNamed(
                        HomeRoutes.genericWebView,
                        arguments: {
                          'title': 'Simulasi Kredit',
                          'url':
                          'https://sufismart.sfi.co.id/sufismart/api/simulasi_page_sufismart.php',
                        },
                      );
                      break;
                    case 'Cabang':
                      Get.toNamed(HomeRoutes.cabang);
                      break;
                    case 'Opsi Pembayaran & Asuransi':
                      Get.toNamed(
                        HomeRoutes.genericWebView,
                        arguments: {
                          'title': 'Opsi Pembayaran & Asuransi',
                          'url':
                          'https://sufismart.sfi.co.id/sufismart/api/layanan_2.php',
                        },
                      );
                      break;
                    case 'Fasilitas':
                      Get.toNamed(
                        HomeRoutes.genericWebView,
                        arguments: {
                          'title': 'Fasilitas',
                          'url':
                          'https://sufismart.sfi.co.id/sufismart/api/ic_product_sufismart.php?EMAIL=',
                        },
                      );
                      break;
                    default:
                      Get.snackbar('Oops', 'Fitur belum tersedia');
                  }
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10.0),
                      child: SizedBox(
                        width: 54,
                        height: 54,
                        child: Image.asset(item['icon']!),
                      ),
                    ),
                    const SizedBox(height: 6.0),
                    Text(
                      item['label']!,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.smallBody,
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _OrderSection() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          const Text(
            'Ayo, Order Kendaraan Suzuki',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8.0),
          ElevatedButton(
            onPressed: () {
              Get.toNamed(
                HomeRoutes.genericWebView,
                arguments: {
                  'title': 'Pengajuan Kredit',
                  'url':
                  'https://sufismart.sfi.co.id/sufismart/api/credit_simulation_apply_all.php?userid=',
                },
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.button,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.0),
              ),
            ),
            child: Text('Apply', style: TextStyle(color: AppColors.bg1)),
          ),
        ],
      ),
    );
  }

  Widget _NewsCarousel() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Berita Terbaru',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12.0),
          Container(
            height: 180,
            alignment: Alignment.centerLeft,
            child: PageView.builder(
              controller: PageController(viewportFraction: 0.9),
              itemCount: newsImages.length,
              itemBuilder:
                  (context, index) => Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 8.0,
                  horizontal: 8.0,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: Image.asset(newsImages[index], fit: BoxFit.fill),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
