import 'package:get/get.dart';
import 'package:sufi_one/app/modules/DAMS/dams_route.dart';
import 'package:sufi_one/app/modules/locationTest/location_routes.dart';
import 'package:sufi_one/app/modules/mobcol/mobcol_routes.dart';
import 'package:sufi_one/app/modules/smile/smile_route.dart';
import 'package:sufi_one/app/modules/survey/survey_routes.dart';
import 'package:sufi_one/app/modules/zeus/feature/zeushome/views/zeus_view.dart';
import 'package:sufi_one/app/modules/zeus/feature/zeushome/bindings/zeus_binding.dart';
import 'package:sufi_one/app/modules/public/home_routes.dart';

class AppRoutes {
  //MOBCOL
  static const mobileCollection = '/mobile_collection';
  static const survey = '/survey/splash';
  static const surveyHome = '/survey/home';
  static const mobileCollectionTugasBaru = '/mobile_collection/tugas_baru';
  static const mobileCollectionTugasBaruDetail =
      '/mobile_collection/tugas_baru/detail';
  static const mobileCollectionDetailCust =
      '/mobile_collection/tugas_baru/detail/customer';
  static const mobileCollectionKunjungan =
      '/mobile_collection/tugas_baru/kunjungan';
  static const mobileCollectionTugasBelumSelesai =
      '/mobile_collection/tugas_belum_selesai';
  static const mobileCollectionTugasBelumSelesaiDetail =
      '/mobile_collection/tugas_belum_selesai/detail';
  static const mobileCollectionUploadBukti = '/mobile_collection/upload_bukti';
  static const mobileCollectionUploadBuktiDetail =
      '/mobile_collection/upload_bukti/detail';
  static const mobileCollectionTugasSelesai =
      '/mobile_collection/tugas_selesai';
  static const mobileCollectionTugasSelesaiDetail =
      '/mobile_collection/tugas_selesai/detail';
  static const newtaskConfirm = '/public/mobile_survey/newtask';
  static const uploadChecking = '/public/mobile_survey/upload';
  static const finishChecking = '/public/mobile_survey/finish';
  static const processSurvey = '/public/mobile_survey/process';
  static const zeus = '/public/zeus';
  static const zeusDetail = '/public/zeus_detail_view';
  static const smile = '/public/smile';
  static const smileDetail = '/public/smile_detail_view';

  static final pages = [
    GetPage(name: zeus, page: () => ZeusView(), binding: ZeusBinding()),
    ...SurveyRoutes.routes,
    ...SmileRoutes.routes,
    ...HomeRoutes.routes,
    ...MobcolRoutes.routes,
    ...LocationRoutes.routes,
    ...DamsRoute.routes,
  ];
}
