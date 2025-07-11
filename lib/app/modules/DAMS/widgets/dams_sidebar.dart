import 'package:flutter/material.dart';
import 'package:sufi_one/app/modules/mobcol/mobcol_routes.dart';
import 'package:sufi_one/app/modules/public/home_routes.dart';
import 'package:sufi_one/app/modules/smile/smile_route.dart';
import 'package:sufi_one/app/theme/color_constant.dart';
import 'package:get/get.dart';
import 'package:sufi_one/app/theme/fontstyle.dart';

class DamsSidebar extends StatelessWidget {
  const DamsSidebar({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      child: Material(
        color: AppColors.splashStart,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: ListView.separated(
                  itemCount: _sidebarItems.length,
                  separatorBuilder:
                      (BuildContext context, int index) =>
                          const Divider(color: Colors.white60, thickness: 2),
                  itemBuilder: (BuildContext context, int index) {
                    final item = _sidebarItems[index];
                    return SidebarItem(
                      icon: item.icon,
                      title: item.title,
                      onTap: item.onTap,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SidebarItemData {
  final Widget? icon;
  final String title;
  final VoidCallback? onTap;

  SidebarItemData({this.icon, required this.title, this.onTap});
}

final List<SidebarItemData> _sidebarItems = [
  SidebarItemData(
    icon: const Icon(Icons.qr_code, color: Colors.white),
    title: 'Scan  QR',
    onTap: () {
      Get.offNamed(SmileRoutes.directVisit);
    },
  ),
  SidebarItemData(
    icon: const Icon(Icons.history, color: Colors.white),
    title: 'History',
    onTap: () {
      Get.toNamed(SmileRoutes.taskVisit);
    },
  ),
  SidebarItemData(
    icon: const Icon(Icons.table_chart, color: Colors.white),
    title: 'Data Master',
    onTap: () {
      Get.offNamed(SmileRoutes.historyVisit);
    },
  ),
  SidebarItemData(
    icon: const Icon(Icons.keyboard_backspace_sharp, color: Colors.white),
    title: 'Kembali',
    onTap: () {
      Get.offNamed(HomeRoutes.homepage);
    },
  ),
];

class SidebarItem extends StatelessWidget {
  final Widget? icon;
  final String title;
  final Widget? trailing;
  final VoidCallback? onTap;
  const SidebarItem({
    super.key,
    this.icon,
    required this.title,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final textStyle = AppTextStyles.sidebar;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Row(
          children: [
            if (icon != null) ...[icon!, const SizedBox(width: 12.0)],
            Expanded(child: Text(title, style: textStyle)),
            if (trailing != null) ...[const SizedBox(width: 12.0), trailing!],
          ],
        ),
      ),
    );
  }
}
