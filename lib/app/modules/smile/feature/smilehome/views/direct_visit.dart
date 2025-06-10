// direct_visit_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sufi_one/app/routes/app_routes.dart';

class DirectVisit extends StatefulWidget {
  const DirectVisit({Key? key}) : super(key: key);

  @override
  _DirectVisitState createState() => _DirectVisitState();
}

class _DirectVisitState extends State<DirectVisit> {
  // sample dropdown values
  final List<String> jabatanList = ['Branch Manager', 'Sales', 'Staff'];
  final List<String> areaList = ['SFI JABODETABEKSER', 'SFI JAWA BARAT'];
  final List<String> cabangList = ['1507 TANGERANG - MBL', '1508 BEKASI - MBL'];
  final List<String> produkList = ['Mobil Baru', 'Mobil Bekas'];
  final List<String> dealerList = ['PT. BUANA INDOMOBIL TRADA PULOGADUNG', 'PT. OTO ABADI'];
  final List<String> visitTypeList = ['Direct Visit Dealer', 'Direct Visit Customer'];

  // selected values
  String? selectedJabatan;
  String? selectedArea;
  String? selectedCabang;
  String? selectedProduk;
  String? selectedDealer;
  String? selectedVisitType;

  // CHANGE: define custom colors
  static const Color headerBlue = Color(0xFF1521A4);
  static const Color dropdownLight = Color(0xFF272728);
  static const Color dropdownLightNF = Color(0xFFCCCCCC);
  static const Color dropdownLightF = Color(0xFFAFA1CF);


  @override
  void initState() {
    super.initState();
    // initialize default selections
    selectedJabatan = jabatanList.first;
    selectedArea = areaList.first;
    selectedCabang = cabangList.first;
    selectedProduk = produkList.first;
    selectedDealer = dealerList.first;
    selectedVisitType = visitTypeList.first;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFDFF),
      appBar: AppBar(
        backgroundColor: headerBlue, // CHANGE: gunakan headerBlue
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(), // kembali page sebelumnya
        ),
        title: const Text(
          'Form direct visit',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Card Jabatan Saya
              Card(
                color: const Color(0xFFFDFDFF),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Text(
                          'Jabatan Saya',
                          style: TextStyle(
                            fontSize: 22,
                            color: headerBlue, // CHANGE: set header color
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Jabatan',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color:dropdownLight,
                        ),
                      ),
                      DropdownButtonFormField<String>(
                        value: selectedJabatan,
                        icon: const Icon(Icons.expand_more),
                        iconEnabledColor: dropdownLight,  // atur warnanya
                        style: const TextStyle(color: dropdownLight), // CHANGE: teks dropdown terpilih
                        decoration: const InputDecoration(
                          // garis bawah saat tidak fokus
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: dropdownLightNF,   // ganti dengan warna yang diinginkan
                              width: 0.5,          // ganti dengan ketebalan yang diinginkan
                            ),
                          ),
                          // garis bawah saat fokus
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: dropdownLightF,  // ganti dengan warna fokus
                              width: 2.0,          // ganti dengan ketebalan fokus
                            ),
                          ),
                        ),
                        items: jabatanList.map((j) {
                          return DropdownMenuItem(
                            value: j,
                            child: Text(
                              j,
                              style: const TextStyle(color: dropdownLight), // CHANGE: teks item dropdown
                            ),
                          );
                        }).toList(),
                        onChanged: (val) => setState(() => selectedJabatan = val),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Card Data Dealer
              Card(
                color: const Color(0xFFFDFDFF),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Text(
                          'Data Dealer',
                          style: TextStyle(
                            fontSize: 22,
                            color: headerBlue, // CHANGE: set header color
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Area',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color:dropdownLight,
                        ),
                      ),
                      DropdownButtonFormField<String>(
                        value: selectedArea,
                        icon: const Icon(Icons.expand_more),
                        iconEnabledColor: dropdownLight,  // atur warnanya
                        style: const TextStyle(color: dropdownLight), // CHANGE
                        decoration: const InputDecoration(
                          // garis bawah saat tidak fokus
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: dropdownLightNF,   // ganti dengan warna yang diinginkan
                              width: 0.5,          // ganti dengan ketebalan yang diinginkan
                            ),
                          ),
                          // garis bawah saat fokus
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: dropdownLightF,  // ganti dengan warna fokus
                              width: 2.0,          // ganti dengan ketebalan fokus
                            ),
                          ),
                        ),
                        items: areaList.map((a) => DropdownMenuItem(
                          value: a,
                          child: Text(
                            a,
                            style: const TextStyle(color: dropdownLight), // CHANGE
                          ),
                        )).toList(),
                        onChanged: (val) => setState(() => selectedArea = val),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Cabang',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color:dropdownLight,
                        ),
                      ),
                      DropdownButtonFormField<String>(
                        value: selectedCabang,
                        icon: const Icon(Icons.expand_more),
                        iconEnabledColor: dropdownLight,  // atur warnanya
                        style: const TextStyle(color: dropdownLight), // CHANGE
                        decoration: const InputDecoration(
                          // garis bawah saat tidak fokus
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: dropdownLightNF,   // ganti dengan warna yang diinginkan
                              width: 0.5,          // ganti dengan ketebalan yang diinginkan
                            ),
                          ),
                          // garis bawah saat fokus
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: dropdownLightF,  // ganti dengan warna fokus
                              width: 2.0,          // ganti dengan ketebalan fokus
                            ),
                          ),
                        ),
                        items: cabangList.map((c) => DropdownMenuItem(
                          value: c,
                          child: Text(
                            c,
                            style: const TextStyle(color: dropdownLight), // CHANGE
                          ),
                        )).toList(),
                        onChanged: (val) => setState(() => selectedCabang = val),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Produk',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color:dropdownLight,
                        ),
                      ),
                      DropdownButtonFormField<String>(
                        value: selectedProduk,
                        icon: const Icon(Icons.expand_more),
                        iconEnabledColor: dropdownLight,  // atur warnanya
                        style: const TextStyle(color: dropdownLight), // CHANGE
                        decoration: const InputDecoration(
                          // garis bawah saat tidak fokus
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: dropdownLightNF,   // ganti dengan warna yang diinginkan
                              width: 0.5,          // ganti dengan ketebalan yang diinginkan
                            ),
                          ),
                          // garis bawah saat fokus
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: dropdownLightF,  // ganti dengan warna fokus
                              width: 2.0,          // ganti dengan ketebalan fokus
                            ),
                          ),
                        ),
                        items: produkList.map((p) => DropdownMenuItem(
                          value: p,
                          child: Text(
                            p,
                            style: const TextStyle(color: dropdownLight), // CHANGE
                          ),
                        )).toList(),
                        onChanged: (val) => setState(() => selectedProduk = val),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Dealer',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color:dropdownLight,
                        ),
                      ),
                      DropdownButtonFormField<String>(
                        value: selectedDealer,
                        decoration: const InputDecoration(
                          suffixIcon: Icon(Icons.search),
                            // garis bawah saat tidak fokus
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: dropdownLightNF,   // ganti dengan warna yang diinginkan
                                width: 0.5,          // ganti dengan ketebalan yang diinginkan
                              ),
                            ),
                            // garis bawah saat fokus
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: dropdownLightF,  // ganti dengan warna fokus
                                width: 2.0,          // ganti dengan ketebalan fokus
                            ),
                          ),// ikon search
                        ),
                        icon: const Icon(Icons.expand_more),
                        iconEnabledColor: dropdownLight,  // atur warnanya
                        style: const TextStyle(color: dropdownLight), // CHANGE

                        items: dealerList.map((d) => DropdownMenuItem(
                          value: d,
                          child: Text(
                            d,
                            style: const TextStyle(color: dropdownLight), // CHANGE
                          ),
                        )).toList(),
                        onChanged: (val) => setState(() => selectedDealer = val),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Card Data Visit
              Card(
                color: const Color(0xFFFDFDFF),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Text(
                          'Data Visit',
                          style: TextStyle(
                            fontSize: 22,
                            color: headerBlue, // CHANGE: set header color
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Text(
                      //   'Tipe visit',
                      //   style: const TextStyle(
                      //     fontWeight: FontWeight.bold,
                      //     color:dropdownLight,
                      //   ),
                      // ),
                      DropdownButtonFormField<String>(
                        value: selectedVisitType,
                        icon: const Icon(Icons.expand_more),
                        iconEnabledColor: dropdownLight,  // atur warnanya
                        style: const TextStyle(color: dropdownLight), // CHANGE
                        decoration: const InputDecoration(
                          // garis bawah saat tidak fokus
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: dropdownLightNF,   // ganti dengan warna yang diinginkan
                              width: 0.5,          // ganti dengan ketebalan yang diinginkan
                            ),
                          ),
                          // garis bawah saat fokus
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: dropdownLightF,  // ganti dengan warna fokus
                              width: 2.0,          // ganti dengan ketebalan fokus
                            ),
                          ),
                        ),
                        items: visitTypeList.map((v) => DropdownMenuItem(
                          value: v,
                          child: Text(
                            v,
                            style: const TextStyle(color: dropdownLight), // CHANGE
                          ),
                        )).toList(),
                        onChanged: (val) => setState(() => selectedVisitType = val),
                      ),
                      // tambahkan field lain di sini sesuai kebutuhan
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),
              // tombol Submit
              ElevatedButton(
                onPressed: () {
                  // navigasi atau aksi submit
                  // Get.toNamed(AppRoutes.nextPage);
                },
                child: const Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
