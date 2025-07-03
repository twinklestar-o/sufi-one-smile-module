import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:io';
import 'package:installed_apps/installed_apps.dart';
import 'package:installed_apps/app_info.dart';
import 'package:sufi_one/app/services/check_app_model.dart';
import 'package:sufi_one/app/theme/color_constant.dart';
import 'package:sufi_one/app/theme/fontstyle.dart';
import 'package:sufi_one/app/modules/public/home_routes.dart';

// Pengecekan aplikasi akan running jika melakukan perpindahan page/module melalui side bar dan ter print di terminal
class CheckingInstalledAppService {
  Future<void> checkInstalledApps() async {
    if (Platform.isAndroid) {
      try {
        List<AppModel> appModels = [];
        List<AppInfo> apps = await InstalledApps.getInstalledApps(true, true);
        bool foundFakeGpsApp = false;
        String? detectedAppName;

        for (var app in apps) {
          final appModel = AppModel(
            appName: app.name.isNotEmpty ? app.name : "unknown",
            packageName:
                app.packageName.isNotEmpty ? app.packageName : "unknown",
            versionName:
                app.versionName.isNotEmpty ? app.versionName : "unknown",
            versionCode: app.versionCode,
          );
          appModels.add(appModel);

          if (AppModel.fakeGpsPackages.contains(appModel.packageName)) {
            foundFakeGpsApp = true;
            detectedAppName = appModel.appName;

            print(
              "\n Ditemukan aplikasi Fake GPS: '${appModel.appName}' "
              "(Package: ${appModel.packageName})\n"
              "Harap hapus aplikasi '${appModel.appName}' yang berfungsi untuk mengelabui lokasi Anda.\n",
            );
          }
        }

        if (foundFakeGpsApp && detectedAppName != null) {
          Get.dialog(
            AlertDialog(
              title: Text(
                "Pemberitahuan Keamanan",
                textAlign: TextAlign.center,
                style: AppTextStyles.medBodyBold,
              ),
              content: Text(
                "Aplikasi dengan nama '$detectedAppName' terdeteksi sebagai aplikasi yang dapat memanipulasi lokasi perangkat (Fake GPS).\n\n"
                "Untuk menjaga integritas dan keamanan sistem, mohon untuk menghapus aplikasi tersebut sebelum melanjutkan penggunaan layanan ini.",
                textAlign: TextAlign.center,
                style: AppTextStyles.medBody,
              ),
              actionsAlignment: MainAxisAlignment.center,
              actions: [
                SizedBox(
                  width: 150,
                  height: 40,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.splashStart,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () {
                      Get.back();
                      Get.offAllNamed(HomeRoutes.homepage);
                    },
                    child: Text(
                      "Saya Mengerti",
                      style: AppTextStyles.medBodyBold.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            barrierDismissible: false,
          );
        }

        print("📋 Detail list aplikasi terinstall:");
        for (int i = 0; i < appModels.length; i++) {
          final app = appModels[i];
          print(
            "${i + 1}. ${app.appName} "
            "(Package: ${app.packageName}, Version: ${app.versionName} - Code: ${app.versionCode})",
          );
        }

        if (!foundFakeGpsApp) {
          print("\n Tidak ditemukan aplikasi Fake GPS.\n");
        }
      } catch (e) {
        print("Error saat memeriksa aplikasi terinstal: $e");
      }
    } else if (Platform.isIOS) {
      print("Fitur ini belum didukung untuk iOS.");
    }
  }
}
