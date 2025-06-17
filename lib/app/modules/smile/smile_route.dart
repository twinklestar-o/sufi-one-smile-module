import 'package:get/get.dart';
import 'package:sufi_one/app/Auth/views/login_view.dart';
import 'package:sufi_one/app/Auth/views/profile.dart';
import 'package:sufi_one/app/Auth/views/register_view.dart';
import 'package:sufi_one/app/modules/smile/feature/smilehome/views/smile_view.dart';
import 'package:sufi_one/app/modules/smile/feature/smilehome/views/data_master.dart';
import 'package:sufi_one/app/modules/smile/feature/smilehome/views/direct_visit.dart';
import 'package:sufi_one/app/modules/smile/feature/smilehome/views/TaskVisit/task_visit.dart';
import 'package:sufi_one/app/modules/smile/feature/smilehome/views/History/history_visit.dart';
import 'package:sufi_one/app/modules/smile/feature/smilehome/views/History/history_view.dart';
import 'package:sufi_one/app/modules/smile/feature/smilehome/views/History/history_edit.dart';
import 'package:sufi_one/app/modules/smile/feature/smilehome/views/TaskVisit/task_visit_detail.dart';
import 'package:sufi_one/app/modules/smile/feature/smilehome/views/TaskVisit/task_visit_edit.dart';

import 'package:sufi_one/app/modules/smile/feature/smilehome/bindings/history_visit_binding.dart';
import 'package:sufi_one/app/modules/smile/feature/smilehome/bindings/history_view_binding.dart';
import 'package:sufi_one/app/modules/smile/feature/smilehome/bindings/history_edit_binding.dart';

class SmileRoutes {
  //Penamaan
  // variabel: pertamaKedua
  // route: pertama_kedua

  static const smile = '/public/smile';
  static const login = '/public/smile/login';
  static const register = '/public/smile/register';
  static const profile = '/public/smile/profile';
  static const directVisit = '/public/smile/direct_visit';
  static const taskVisit = '/public/smile/task_visit';
  static const historyVisit = '/public/smile/history_visit';
  static const dataMaster = '/public/smile/data_master';
  static const historyView = '/public/smile/history_view';
  static const historyEdit = '/public/smile/history_edit';
  static const taskVisitDetail = '/public/smile/task_visit_detail';
  static const taskVisitEdit = '/public/smile/task_visit_edit';

  static final routes = [
    GetPage(
      name: register,
      transition: Transition.zoom,
      page: () => RegisterPage(),
    ),
    GetPage(name: login, transition: Transition.zoom, page: () => LoginPage()),
    GetPage(
      name: profile,
      transition: Transition.zoom,
      page: () => ProfilePage(),
    ),
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
      binding: HistoryVisitBinding(), // Tambahkan binding untuk HistoryVisit
    ),
    GetPage(
      name: dataMaster,
      transition: Transition.zoom,
      page: () => DataMaster(),
    ),
    GetPage(
      name: historyView,
      transition: Transition.zoom,
      page: () => HistoryView(),
      binding: HistoryViewBinding(), // Tambahkan binding untuk HistoryView
    ),
    GetPage(
      name: historyEdit,
      transition: Transition.zoom,
      page: () => HistoryEdit(),
      binding: HistoryEditBinding(), // Tambahkan binding untuk HistoryEdit
    ),
    GetPage(
      name: taskVisitDetail,
      transition: Transition.zoom,
      page: () {
        final args = Get.arguments as Visit;
        return TaskVisitDetail(visit: args);
      },
    ),
    GetPage(
      name: taskVisitEdit,
      transition: Transition.zoom,
      page: () {
        final args = Get.arguments as Visit;
        return TaskVisitEdit(visit: args);
      },
    ),
  ];
}
