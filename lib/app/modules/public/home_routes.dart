import 'package:get/get.dart';
import 'package:sufi_one/app/Auth/bindings/forgot_password_binding.dart';
import 'package:sufi_one/app/Auth/bindings/login_binding.dart';
import 'package:sufi_one/app/Auth/bindings/register_binding.dart';
import 'package:sufi_one/app/Auth/views/forgot_password_view.dart';
import 'package:sufi_one/app/Auth/views/login_view.dart';
import 'package:sufi_one/app/Auth/views/register_view.dart';
import 'package:sufi_one/app/modules/public/homepage/views/home_view.dart';
import 'package:sufi_one/app/modules/public/homepage/views/homepage_cust_view.dart';
import 'package:sufi_one/app/modules/public/homepage/splash/splash_view.dart';
import 'package:sufi_one/app/modules/public/homepage/bindings/homepage_cust_binding.dart';
import 'package:sufi_one/app/modules/public/profile_page/views/profile_page_view.dart';
import 'package:sufi_one/app/modules/public/profile_page/bindings/profile_page_binding.dart';
import 'package:sufi_one/app/modules/public/profile_page/views/profile_edit_view.dart';
import 'package:sufi_one/app/modules/public/homepage/views/promo_view.dart';
import 'package:sufi_one/app/modules/public/about/views/about_view.dart';
import 'package:sufi_one/app/modules/public/about/bindings/about_binding.dart';
import 'package:sufi_one/app/modules/public/about/views/contact_view.dart';
import 'package:sufi_one/app/modules/public/about/bindings/contact_binding.dart';
import 'package:sufi_one/app/modules/public/profile_page/views/ubah_password_view.dart';
import 'package:sufi_one/app/modules/public/profile_page/views/transaksi_point_view.dart';
import 'package:sufi_one/app/modules/public/produk/views/produk_kategori_view.dart';
import 'package:sufi_one/app/modules/public/produk/bindings/produk_binding.dart';
import 'package:sufi_one/app/modules/public/produk/views/produk_tipe_view.dart';
import 'package:sufi_one/app/modules/public/produk/views/produk_harga_view.dart';
import 'package:sufi_one/app/modules/public/produk/views/produk_detail_view.dart';
import 'package:sufi_one/app/modules/public/cabang/views/cabang_view.dart';
import 'package:sufi_one/app/modules/public/cabang/bindings/cabang_binding.dart';
import 'package:sufi_one/app/modules/public/webview/generic_webview.dart';

class HomeRoutes {
  static const splash = '/';
  static const publicHome = '/public/home';
  static const homepageCust = '/public/homepage/homepage_cust_view';
  static const catalog = '/public/catalog';
  static const login = '/public/profile_page/login';
  static const register = '/public/profile_page/register';
  static const forgotPassword = '/public/profile_page/forgot_password';
  static const profilePage = '/public/profile_page/profile_page_view';
  static const profileEdit = '/public/profile_page/profile_edit_view';
  static const promo = '/public/homepage/promo';
  static const about = '/public/about';
  static const contact = '/public/about/contact';
  static const ubahPassword = '/public/profile_page/ubah-password';
  static const transaksiPoint = '/public/profile_page/transaksi-point';
  static const cabang = '/public/cabang';
  static const produkKategori = '/public/produk/produk_kategori';
  static const produkTipe = '/public/produk/produk_tipe';
  static const produkHarga = '/public/produk/produk_harga';
  static const produkDetail = '/public/produk/produk_detail';
  static const genericWebView = '/public/webview';

  static final routes = [
    GetPage(name: splash, page: () => SplashPage()),
    GetPage(name: publicHome, page: () => PublicHomePage()),
    GetPage(
      name: homepageCust,
      page: () => const HomepageCustView(),
      binding: HomepageCustBinding(),
    ),
    GetPage(name: login, page: () => LoginPage(), binding: LoginBinding()),
    GetPage(
      name: register,
      page: () => RegisterPage(),
      binding: RegisterBinding(),
    ),
    GetPage(
      name: forgotPassword,
      page: () => ForgotPasswordPage(),
      binding: ForgotPasswordBinding(),
    ),
    GetPage(
      name: profilePage,
      page: () => ProfilePageView(),
      binding: ProfilePageBinding(),
    ),
    GetPage(
      name: profileEdit,
      page: () => ProfileEditView(),
      binding: ProfilePageBinding(),
    ),
    GetPage(name: promo, page: () => const PromoView()),
    GetPage(
      name: about,
      page: () => const AboutView(),
      binding: AboutBinding(),
    ),
    GetPage(
      name: contact,
      page: () => const ContactView(),
      binding: ContactBinding(),
    ),
    GetPage(
      name: ubahPassword,
      page: () => const UbahPasswordView(),
      binding: ProfilePageBinding(),
    ),
    GetPage(
      name: transaksiPoint,
      page: () => TransaksiPointView(),
      binding: ProfilePageBinding(),
    ),
    GetPage(
      name: produkKategori,
      page: () => ProdukKategoriView(),
      binding: ProdukBinding(),
    ),
    GetPage(
      name: produkTipe,
      page: () => ProdukTipeView(),
      binding: ProdukBinding(),
    ),
    GetPage(
      name: produkHarga,
      page: () => ProdukHargaView(),
      binding: ProdukBinding(),
    ),
    GetPage(
      name: produkDetail,
      page: () => ProdukDetailView(),
      binding: ProdukBinding(),
    ),
    GetPage(name: cabang, page: () => CabangView(), binding: CabangBinding()),
    GetPage(name: genericWebView, page: () => const GenericWebView()), //webview
  ];
}
