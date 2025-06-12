import 'package:get/get.dart';
import 'package:sufi_one/app/modules/smile/feature/smilehome/views/smile_view.dart';
import 'package:sufi_one/app/modules/smile/feature/smilehome/views/data_master.dart';
import 'package:sufi_one/app/modules/smile/feature/smilehome/views/direct_visit.dart';
import 'package:sufi_one/app/modules/smile/feature/smilehome/views/task_visit.dart';
import 'package:sufi_one/app/modules/smile/feature/smilehome/views/History/history_visit.dart';
import 'package:sufi_one/app/modules/smile/feature/smilehome/views/History/history_view.dart';
import 'package:sufi_one/app/modules/smile/feature/smilehome/views/History/history_edit.dart';
import 'package:sufi_one/app/modules/smile/feature/smilehome/views/task_visit_detail.dart';
import 'package:sufi_one/app/modules/smile/feature/smilehome/views/task_visit_edit.dart';

class SmileRoutes {
  //Penamaan
  // variabel: pertamaKedua
  // route: pertama_kedua

  static const smile = '/public/smile';
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
      name: historyView,
      transition: Transition.zoom,
      page: () => HistoryView(),
    ),
    GetPage(
      name: historyEdit,
      transition: Transition.zoom,
      page: () => HistoryEdit(),
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
