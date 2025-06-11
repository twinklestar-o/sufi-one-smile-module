import 'package:get/get.dart';
import 'package:sufi_one/app/modules/smile/feature/smilehome/views/smile_view.dart';
import 'package:sufi_one/app/modules/smile/feature/smilehome/views/data_master.dart';
import 'package:sufi_one/app/modules/smile/feature/smilehome/views/direct_visit.dart';
import 'package:sufi_one/app/modules/smile/feature/smilehome/views/task_visit.dart';
import 'package:sufi_one/app/modules/smile/feature/smilehome/views/history_visit.dart';
import 'package:sufi_one/app/modules/smile/feature/smilehome/views/profile.dart';

class SmileRoutes {
  //Penamaan
  // variabel: pertamaKedua
  // route: pertama_kedua

  static const smile = '/public/smile';
  static const directVisit = '/public/smile/direct_visit';
  static const taskVisit = '/public/smile/task_visit';
  static const historyVisit = '/public/smile/history_visit';
  static const dataMaster = '/public/smile/data_master';
  static const profile = '/public/smile/profile';
  static final routes = [
    GetPage(
      name: smile,
      transition: Transition.zoom,
      page: () => SmileHomePage(),
    ),
    GetPage(
      name: directVisit,
      transition: Transition.zoom,
      page: () => DirectVisit(),
    ),
    GetPage(
      name: taskVisit,
      transition: Transition.zoom,
      page: () => TaskVisit(),
    ),
    GetPage(
      name: historyVisit,
      transition: Transition.zoom,
      page: () => HistoryVisit(),
    ),
    GetPage(
      name: dataMaster,
      transition: Transition.zoom,
      page: () => DataMaster(),
    ),
    GetPage(
      name: profile,
      transition: Transition.zoom,
      page: () => ProfilePage(),
    ),
  ];
}
