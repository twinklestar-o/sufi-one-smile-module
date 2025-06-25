import 'package:get/get.dart';
import 'package:sufi_one/app/Auth/views/login_view.dart';
import 'package:sufi_one/app/Auth/views/register_view.dart';
import 'package:sufi_one/app/modules/smile/feature/smilehome/views/listMaster/area_screen.dart';
import 'package:sufi_one/app/modules/smile/feature/smilehome/views/listMaster/purpose_screen.dart';
import 'package:sufi_one/app/modules/smile/feature/smilehome/views/smile_view.dart';
import 'package:sufi_one/app/modules/smile/feature/smilehome/views/listMaster/data_master.dart';
import 'package:sufi_one/app/modules/smile/feature/smilehome/views/direct_visit.dart';
import 'package:sufi_one/app/modules/smile/feature/smilehome/views/TaskVisit/task_visit.dart';
import 'package:sufi_one/app/modules/smile/feature/smilehome/views/TaskVisit/task_edit.dart';
import 'package:sufi_one/app/modules/smile/feature/smilehome/views/TaskVisit/task_view.dart';
import 'package:sufi_one/app/modules/smile/feature/smilehome/bindings/task_visit_binding.dart';
import 'package:sufi_one/app/modules/smile/feature/smilehome/bindings/task_edit_binding.dart';
import 'package:sufi_one/app/modules/smile/feature/smilehome/bindings/task_view_binding.dart';
import 'package:sufi_one/app/modules/smile/feature/smilehome/views/History/history_visit.dart';
import 'package:sufi_one/app/modules/smile/feature/smilehome/views/History/history_view.dart';
import 'package:sufi_one/app/modules/smile/feature/smilehome/views/History/history_edit.dart';
import 'package:sufi_one/app/modules/smile/feature/smilehome/bindings/history_visit_binding.dart';
import 'package:sufi_one/app/modules/smile/feature/smilehome/bindings/history_view_binding.dart';
import 'package:sufi_one/app/modules/smile/feature/smilehome/bindings/history_edit_binding.dart';
import 'package:sufi_one/app/modules/smile/feature/smilehome/views/listMaster/jabatan_screen.dart';
import 'package:sufi_one/app/modules/smile/feature/smilehome/views/listMaster/type_screen.dart';
import 'package:sufi_one/app/modules/smile/feature/smilehome/views/listMaster/branch_screen.dart';
import 'package:sufi_one/app/modules/smile/feature/smilehome/views/listMaster/product_screen.dart';

class SmileRoutes {
  //Penamaan
  // variabel: pertamaKedua
  // route: pertama_kedua

  static const smile = '/public/smile';
  static const login = '/public/smile/login';
  static const register = '/public/smile/register';
  static const directVisit = '/public/smile/direct_visit';
  static const taskVisit = '/public/smile/task_visit';
  static const taskView = '/public/smile/task_view';
  static const taskEdit = '/public/smile/task_edit';
  static const historyVisit = '/public/smile/history_visit';
  static const dataMaster = '/public/smile/data_master';
  static const historyView = '/public/smile/history_view';
  static const historyEdit = '/public/smile/history_edit';
  static const taskVisitDetail = '/public/smile/task_visit_detail';
  static const taskVisitEdit = '/public/smile/task_visit_edit';
  static const jabatan = '/public/smile/list_master/jabatan';
  static const area = '/public/smile/list_master/area';
  static const historyVisitDetail = '/public/smile/history_visit_detail';
  static const historyVisitEdit = '/public/smile/history_visit_edit';
  static const type = '/public/smile/list_master/type';
  static const purpose = '/public/smile/list_master/purpose';
  static const branch = '/public/smile/list_master/branch';
  static const product = '/public/smile/list_master/product';



  static final routes = [
    GetPage(
      name: register,
      transition: Transition.zoom,
      page: () => RegisterPage(),
    ),
    GetPage(name: login, transition: Transition.zoom, page: () => LoginPage()),
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

    //Route untuk fitur Task Visit Dealer
    GetPage(
      name: taskVisit,
      transition: Transition.zoom,
      page: () => TaskVisit(),
      binding: TaskVisitBinding(),
    ),
    GetPage(
      name: taskView,
      transition: Transition.zoom,
      page: () => TaskView(),
      binding: TaskViewBinding(),
    ),
    GetPage(
      name: taskEdit, // Ubah dari taskVisitEdit ke taskEdit
      transition: Transition.zoom,
      page: () => TaskEdit(),
      binding: TaskEditBinding(),
    ),
    //Route untuk fitur History Visit Dealer
    GetPage(
      name: historyVisit,
      transition: Transition.zoom,
      page: () => HistoryVisit(),
      binding: HistoryVisitBinding(),
    ),
    GetPage(
      name: historyView,
      transition: Transition.zoom,
      page: () => HistoryView(),
      binding: HistoryViewBinding(),
    ),
    GetPage(
      name: historyEdit,
      transition: Transition.zoom,
      page: () => HistoryEdit(),
      binding: HistoryEditBinding(),
    ),
    //Route untuk fitur Data Master
    GetPage(
      name: dataMaster,
      transition: Transition.zoom,
      page: () => DataMaster(),
    ),
    GetPage(name: type, transition: Transition.zoom, page: () => TypeScreen()),
    GetPage(
      name: jabatan,
      transition: Transition.zoom,
      page: () => JabatanScreen(),
    ),
    GetPage(name: area, transition: Transition.zoom, page: () => AreaScreen()),
    GetPage(
      name: purpose,
      transition: Transition.zoom,
      page: () => PurposeScreen(),
    ),
    GetPage(
      name: branch,
      transition: Transition.zoom,
      page: () => BranchScreen(),
    ),
    GetPage(name: type, transition: Transition.zoom, page: () => ProductScreen()),
    GetPage(
      name: product,
      transition: Transition.zoom,
      page: () => ProductScreen(),
    ),
  ];
}

