import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sufi_one/app/modules/public/cabang/controllers/cabang_controller.dart';
import 'package:sufi_one/app/modules/public/cabang/models/cabang_model.dart';
import 'package:sufi_one/app/modules/public/widgets/appbarWsidebar.dart';
import 'package:sufi_one/app/modules/public/widgets/appbarWOsidebar.dart';
import 'package:sufi_one/app/modules/public/widgets/sidebar.dart';
import 'package:sufi_one/app/theme/color_constant.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CabangView extends StatefulWidget {
  const CabangView({Key? key}) : super(key: key);

  @override
  State<CabangView> createState() => _CabangViewState();
}

class _CabangViewState extends State<CabangView> {
  final CabangController controller = Get.find<CabangController>();
  late Future<bool> _loginCheckFuture;

  Future<bool> checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    return token != null && token.isNotEmpty;
  }

  @override
  void initState() {
    super.initState();
    _loginCheckFuture = checkLoginStatus();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _loginCheckFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        final isLoggedIn = snapshot.data!;

        return Scaffold(
          backgroundColor: AppColors.bg1,
          appBar: isLoggedIn
              ? SuzukiFinanceAppBarWsidebar()
              : SuzukiFinanceAppBarWOsidebar(),
          drawer: isLoggedIn ? const Drawer(child: AppSidebar()) : null,
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Obx(() => DropdownButtonFormField<String>(
                  isExpanded: true,
                  value: controller.selectedCabang.value.isEmpty
                      ? null
                      : controller.selectedCabang.value,
                  hint: Text(
                    'Pilih Cabang',
                    style: TextStyle(color: AppColors.iconDefault),
                  ),
                  items: controller.cabangList.map((cabang) {
                    return DropdownMenuItem<String>(
                      value: cabang.name,
                      child: Text(
                        cabang.name,
                        style: TextStyle(color: AppColors.iconDefault),
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      controller.updateSelectedCabang(value);
                    }
                  },
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: AppColors.bg1,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: AppColors.iconDefault),
                    ),
                  ),
                )),
                const SizedBox(height: 20),
                Obx(() {
                  if (controller.selectedCabang.value.isEmpty) {
                    return Text(
                      'Pilih cabang untuk melihat detail lokasi',
                      style: TextStyle(
                          color: AppColors.iconDefault, fontSize: 14),
                    );
                  }

                  final selectedCabang = controller.cabangList.firstWhere(
                        (cabang) =>
                    cabang.name == controller.selectedCabang.value,
                    orElse: () => CabangModel(
                      name: 'Cabang Tidak Ditemukan',
                      address: 'Alamat tidak tersedia',
                      latitude: 0,
                      longitude: 0,
                      distance: '0 km',
                    ),
                  );

                  return Card(
                    color: AppColors.bg1,
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            selectedCabang.name,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.iconDefault,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            selectedCabang.address,
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.iconDefault,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                selectedCabang.distance,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppColors.iconDefault,
                                ),
                              ),
                              GestureDetector(
                                onTap: () =>
                                    controller.goToMap(selectedCabang.name),
                                child: Row(
                                  children: [
                                    Text(
                                      'Lihat Lokasi',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: AppColors.splashEnd,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Icon(
                                      Icons.location_on,
                                      color: AppColors.splashEnd,
                                      size: 18,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }
}
