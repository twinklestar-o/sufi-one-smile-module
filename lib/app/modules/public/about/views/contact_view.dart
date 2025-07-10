import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:sufi_one/app/modules/public/about/controllers/contact_controller.dart';
import 'package:sufi_one/app/modules/public/widgets/appbarWOsidebar.dart';
import 'package:sufi_one/app/modules/public/widgets/bottomnavbar.dart';
import 'package:sufi_one/app/theme/color_constant.dart';
import 'package:sufi_one/app/modules/public/widgets/appbarWsidebar.dart';
import 'package:sufi_one/app/modules/public/widgets/sidebar.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ContactView extends StatefulWidget {
  const ContactView({Key? key}) : super(key: key);

  @override
  State<ContactView> createState() => _ContactViewState();
}

class _ContactViewState extends State<ContactView> {
  final controller = Get.find<ContactController>();

  bool isLoggedIn = false;
  @override
  void initState() {
    super.initState();
    checkLoginStatus(); // ⬅️ Tambahkan pengecekan login
  }

  Future<void> checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    setState(() {
      isLoggedIn = token != null && token.isNotEmpty;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg1,
      appBar: isLoggedIn
          ? SuzukiFinanceAppBarWsidebar() // ✅ Saat sudah login
          : SuzukiFinanceAppBarWOsidebar(),
      drawer: isLoggedIn ? Drawer(child: AppSidebar()) : null,
      resizeToAvoidBottomInset: false,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(30),
        child: Form(
          key: controller.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              const Text(
                "Hubungi Kami",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.button,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                "Silahkan isi informasi di bawah ini untuk keluhan dan layanan lainnya",
                style: TextStyle(fontSize: 14, color: AppColors.button),
              ),
              const SizedBox(height: 30),
              TextFormField(
                controller: controller.nameController,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp("[a-z A-Z]")),
                ],
                decoration: const InputDecoration(labelText: "nama lengkap"),
                validator: (value) {
                  if (value == null || value.isEmpty)
                    return "Nama lengkap tidak boleh kosong";
                  return null;
                },
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: controller.phoneController,
                keyboardType: TextInputType.phone,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(labelText: "nomor telepon"),
                validator: (value) {
                  if (value == null || value.isEmpty)
                    return "Nomor telepon tidak boleh kosong";
                  if (value.length < 10)
                    return "Nomor telepon minimal 10 digit";
                  if (value.length > 15)
                    return "Nomor telepon maksimal 15 digit";
                  return null;
                },
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: controller.emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(labelText: "email"),
                validator: (value) {
                  if (value == null || value.isEmpty)
                    return "Email tidak boleh kosong";
                  if (!GetUtils.isEmail(value))
                    return "Format email tidak valid";
                  return null;
                },
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: controller.messageController,
                maxLines: 4,
                decoration: const InputDecoration(labelText: "pesan"),
                validator: (value) {
                  if (value == null || value.isEmpty)
                    return "Pesan tidak boleh kosong";
                  return null;
                },
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: controller.onSubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.button,
                  ),
                  child: const Text(
                    "Konfirmasi",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavbar(selectedIndex: 2),
    );
  }
}
