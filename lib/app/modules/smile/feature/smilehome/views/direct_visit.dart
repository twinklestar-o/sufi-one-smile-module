// direct_visit_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl_phone_field/intl_phone_field.dart' show IntlPhoneField;
import 'package:sufi_one/app/routes/app_routes.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import 'package:intl_phone_field/country_picker_dialog.dart' show Country;


class _DirectVisitState extends State<DirectVisit> {
  // sample dropdown values
  final List<String> jabatanList = ['Branch Manager', 'Sales', 'Staff'];
  final List<String> areaList = ['SFI JABODETABEKSER', 'SFI JAWA BARAT'];
  final List<String> cabangList = ['1507 TANGERANG - MBL', '1508 BEKASI - MBL'];
  final List<String> produkList = ['Mobil Baru', 'Mobil Bekas'];
  final List<String> dealerList = [
    'PT. BUANA INDOMOBIL TRADA PULOGADUNG',
    'PT. OTO ABADI',
  ];
  final List<String> visitTypeList = [
    'Direct Visit Dealer',
    'Direct Visit Customer',
  ];
  final List<String> tujuanVisitList = [
    'KOORDINASI RUTIN',
    'PRESENTASI',
  ]; //belum semua

  final TextEditingController _namaPicController = TextEditingController();
  final TextEditingController _telpPicController = TextEditingController();
  List<Map<String,String>> mainPersons = []; // setiap item: {'jabatan':…, 'nama':…, 'telp':…}
  final _formKey = GlobalKey<FormState>();

  // selected values
  String? selectedJabatan;
  String? selectedArea;
  String? selectedCabang;
  String? selectedProduk;
  String? selectedDealer;
  String? selectedVisitType;

  String? selectedTujuanVisit; //start card 3 data visit
  DateTime? selectedTanggalMulai;
  DateTime? selectedTanggalBerakhir;
  DateTime? selectedTanggalPenyelesaian;
  String? selectedNamaPIC;
  String? temaDiskusi;
  int namaPICLength = 0;
  int temaDiskusiLength = 0;

  String? selectedMainJabatan;
  String? selectedMainTelp;



  // CHANGE: define custom colors
  static const Color headerBlue = Color(0xFF1521A4);
  static const Color dropdownLight = Color(0xFF272728);
  static const Color dropdownLightNF = Color(0xFFCCCCCC);
  static const Color dropdownLightF = Color(0xFFAFA1CF);
  static const Color textButton = Color(0xFF8BADCA);

  Future<void> _selectDate(
    BuildContext context,
    Function(DateTime?) setDate,
  ) async {
    //fungsi selectDate untuk memilih tanggal
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        setDate(picked);
      });
    }
  }

  Widget _buildFieldLabel(String label) {
    return Text(
      label,
      style: TextStyle(
        fontWeight: FontWeight.bold,
        color: dropdownLight,
        fontSize: 16,
      ),
    );
  }

  Widget _buildDateField(DateTime? date, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: InputDecorator(
        decoration: InputDecoration(
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: dropdownLightNF, width: 1.0),
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: dropdownLightF, width: 2.0),
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              date != null
                  ? DateFormat('yyyy-MM-dd').format(date)
                  : 'Pilih tanggal',
              style: TextStyle(color: dropdownLight, fontSize: 16),
            ),
            const Icon(Icons.calendar_today, color: Colors.blue, size: 20),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    selectedMainJabatan = null; // agar pakai hint “--pilih--”
    // initialize default selections
    selectedJabatan = jabatanList.first;
    selectedArea = areaList.first;
    selectedCabang = cabangList.first;
    selectedProduk = produkList.first;
    selectedDealer = dealerList.first;
    selectedVisitType = visitTypeList.first;
    selectedTujuanVisit = tujuanVisitList.first;
    // selectedMainJabatan = jabatanList.first;
    selectedTanggalMulai =
        DateTime.now(); //set time jika belum dipilih ke tanggal saat akses
    selectedTanggalBerakhir = DateTime.now();
    selectedTanggalPenyelesaian = DateTime.now();
    selectedNamaPIC = ''; //pengguna harus input
    temaDiskusi = '';
    namaPICLength = selectedNamaPIC!.length; // Initialize counter
    temaDiskusiLength = temaDiskusi!.length;
  }

  // fungsi untuk menambah PIC ke daftar
  void _addMainPerson() {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      mainPersons.add({
        'jabatan': selectedMainJabatan!,
        'nama'   : _namaPicController.text,
        'telp'   : selectedMainTelp!,      // ← pakai variabel ini
      });
      // reset field:
      selectedMainJabatan = null;
      selectedMainTelp = null;
      _namaPicController.clear();
    });
  }


  // fungsi untuk menghapus
  void _removeMainPerson(int index) {
    setState(() => mainPersons.removeAt(index));
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
    child: Form(
    key: _formKey,
    autovalidateMode: AutovalidateMode.onUserInteraction,
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
                          color: dropdownLight,
                        ),
                      ),
                      DropdownButtonFormField<String>(
                        value: selectedJabatan,
                        icon: const Icon(Icons.expand_more),
                        iconEnabledColor: dropdownLight, // atur warnanya
                        style: const TextStyle(
                          color: dropdownLight,
                        ), // CHANGE: teks dropdown terpilih
                        decoration: const InputDecoration(
                          // garis bawah saat tidak fokus
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color:
                                  dropdownLightNF, // ganti dengan warna yang diinginkan
                              width:
                                  0.5, // ganti dengan ketebalan yang diinginkan
                            ),
                          ),
                          // garis bawah saat fokus
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: dropdownLightF, // ganti dengan warna fokus
                              width: 2.0, // ganti dengan ketebalan fokus
                            ),
                          ),
                        ),
                        items:
                            jabatanList.map((j) {
                              return DropdownMenuItem(
                                value: j,
                                child: Text(
                                  j,
                                  style: const TextStyle(
                                    color: dropdownLight,
                                  ), // CHANGE: teks item dropdown
                                ),
                              );
                            }).toList(),
                        onChanged:
                            (val) => setState(() => selectedJabatan = val),
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
                          style: TextStyle(fontSize: 22, color: headerBlue),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Area',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: dropdownLight,
                        ),
                      ),
                      DropdownButtonFormField<String>(
                        value: selectedArea,
                        icon: const Icon(Icons.expand_more),
                        iconEnabledColor: dropdownLight,
                        style: const TextStyle(color: dropdownLight),
                        decoration: const InputDecoration(
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: dropdownLightNF,
                              width: 0.5,
                            ),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: dropdownLightF,
                              width: 2.0,
                            ),
                          ),
                        ),
                        items:
                            areaList
                                .map(
                                  (a) => DropdownMenuItem(
                                    value: a,
                                    child: Text(
                                      a,
                                      style: const TextStyle(
                                        color: dropdownLight,
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                        onChanged: (val) => setState(() => selectedArea = val),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Cabang',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: dropdownLight,
                        ),
                      ),
                      DropdownButtonFormField<String>(
                        value: selectedCabang,
                        icon: const Icon(Icons.expand_more),
                        iconEnabledColor: dropdownLight,
                        style: const TextStyle(color: dropdownLight),
                        decoration: const InputDecoration(
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: dropdownLightNF,
                              width: 0.5,
                            ),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: dropdownLightF,
                              width: 2.0,
                            ),
                          ),
                        ),
                        items:
                            cabangList
                                .map(
                                  (c) => DropdownMenuItem(
                                    value: c,
                                    child: Text(
                                      c,
                                      style: const TextStyle(
                                        color: dropdownLight,
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                        onChanged:
                            (val) => setState(() => selectedCabang = val),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Produk',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: dropdownLight,
                        ),
                      ),
                      DropdownButtonFormField<String>(
                        value: selectedProduk,
                        icon: const Icon(Icons.expand_more),
                        iconEnabledColor: dropdownLight,
                        style: const TextStyle(color: dropdownLight),
                        decoration: const InputDecoration(
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: dropdownLightNF,
                              width: 0.5,
                            ),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: dropdownLightF,
                              width: 2.0,
                            ),
                          ),
                        ),
                        items:
                            produkList
                                .map(
                                  (p) => DropdownMenuItem(
                                    value: p,
                                    child: Text(
                                      p,
                                      style: const TextStyle(
                                        color: dropdownLight,
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                        onChanged:
                            (val) => setState(() => selectedProduk = val),
                      ),
                      const SizedBox(height: 0),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Dealer',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: dropdownLight,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.search,
                              color: Colors.blue,
                            ),
                            onPressed: () {
                              // TODO: Implement search functionality
                            },
                          ),
                        ],
                      ),
                      DropdownButtonFormField<String>(
                        value: selectedDealer,
                        icon: const Icon(Icons.expand_more),
                        iconEnabledColor: dropdownLight,
                        style: const TextStyle(color: dropdownLight),
                        decoration: const InputDecoration(
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: dropdownLightNF,
                              width: 0.5,
                            ),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: dropdownLightF,
                              width: 2.0,
                            ),
                          ),
                        ),
                        items:
                            dealerList
                                .map(
                                  (d) => DropdownMenuItem(
                                    value: d,
                                    child: Text(
                                      d,
                                      style: const TextStyle(
                                        color: dropdownLight,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                )
                                .toList(),
                        onChanged:
                            (val) => setState(() => selectedDealer = val),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),

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
                          style: TextStyle(fontSize: 22, color: headerBlue),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Tipe Visit',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: dropdownLight,
                        ),
                      ),
                      DropdownButtonFormField<String>(
                        value: selectedVisitType,
                        icon: const Icon(Icons.expand_more),
                        iconEnabledColor: dropdownLight,
                        style: const TextStyle(color: dropdownLight),
                        decoration: const InputDecoration(
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: dropdownLightNF,
                              width: 0.5,
                            ),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: dropdownLightF,
                              width: 2.0,
                            ),
                          ),
                        ),
                        items:
                            visitTypeList
                                .map(
                                  (v) => DropdownMenuItem(
                                    value: v,
                                    child: Text(
                                      v,
                                      style: TextStyle(color: dropdownLight),
                                    ),
                                  ),
                                )
                                .toList(),
                        onChanged:
                            (val) => setState(() => selectedVisitType = val),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Tujuan visit',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: dropdownLight,
                        ),
                      ),
                      DropdownButtonFormField<String>(
                        value: selectedTujuanVisit,
                        icon: const Icon(Icons.expand_more),
                        iconEnabledColor: dropdownLight,
                        style: const TextStyle(color: dropdownLight),
                        decoration: const InputDecoration(
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: dropdownLightNF,
                              width: 0.5,
                            ),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: dropdownLightF,
                              width: 2.0,
                            ),
                          ),
                        ),
                        items:
                            tujuanVisitList.map(
                              (v) => DropdownMenuItem(
                                value: v,
                                child: Text(
                                  v,
                                  style: TextStyle(color: dropdownLight),
                                ),
                              ),
                            ).toList(),
                        onChanged:
                            (val) => setState(() => selectedTujuanVisit = val),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Dari tanggal',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: dropdownLight,
                        ),
                      ),
                      _buildDateField(
                        selectedTanggalMulai,
                        () => _selectDate(
                          context,
                          (date) => setState(() => selectedTanggalMulai = date),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Sampai tanggal',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: dropdownLight,
                        ),
                      ),
                      _buildDateField(
                        selectedTanggalBerakhir,
                        () => _selectDate(
                          context,
                          (date) =>
                              setState(() => selectedTanggalBerakhir = date),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Tanggal selesai',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: dropdownLight,
                        ),
                      ),
                      _buildDateField(
                        selectedTanggalPenyelesaian,
                        () => _selectDate(
                          context,
                          (date) => setState(
                            () => selectedTanggalPenyelesaian = date,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Nama PIC',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: dropdownLight,
                        ),
                      ),
                      TextFormField(
                        initialValue: selectedNamaPIC ?? '',
                        style: TextStyle(
                          color: dropdownLight,
                          fontSize: 16,
                        ),
                        maxLength: 50,
                        maxLengthEnforcement: MaxLengthEnforcement.enforced,
                        decoration: InputDecoration(
                          hintText: 'Masukkan nama PIC',
                          hintStyle: TextStyle(color: dropdownLightNF),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: dropdownLightF,
                              width: 1.5,
                            ),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: dropdownLightF,
                              width: 3.0,
                            ),
                          ),
                          counterText: '$namaPICLength/50',
                          counterStyle: TextStyle(
                            color: dropdownLight,
                            fontSize: 12,
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            vertical: 16,
                            horizontal: 8,
                          ),
                        ),
                        onChanged: (val) => setState(() {
                          selectedNamaPIC = val;
                          namaPICLength = val.length;
                        }),
                      ),


                      const SizedBox(height: 12),
                      Text(
                        'Theme of discussion',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: dropdownLight,
                        ),
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              initialValue: temaDiskusi ?? '',
                              style: TextStyle(
                                color: dropdownLight,
                                fontSize: 16,
                              ),
                              maxLength: 1000,
                              maxLengthEnforcement:
                                  MaxLengthEnforcement.enforced,
                              minLines: 3,
                              maxLines: 5,
                              decoration: InputDecoration(
                                hintText: 'Masukkan tema diskusi',
                                hintStyle: TextStyle(color: dropdownLightNF),
                                enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(
                                    color: dropdownLightNF,
                                    width: 0.5,
                                  ),
                                ),
                                focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(
                                    color: dropdownLightF,
                                    width: 2.0,
                                  ),
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                  vertical: 16,
                                  horizontal: 8,
                                ),
                              ),
                              onChanged:
                                  (val) => setState(() {
                                    temaDiskusi = val;
                                    temaDiskusiLength = val.length;
                                  }),
                            ),
                          ),
                         ],
                      ),
                    ],
                  ),
                ),
              ),
              // ─── Card Main Person ─────────────────────────────
              Card(
                color: const Color(0xFFFDFDFF),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(
                        child: Text(
                          'Main Person',
                          style: TextStyle(fontSize: 22, color: headerBlue),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Dropdown Jabatan
                      _buildFieldLabel('Jabatan'),
                      DropdownButtonFormField<String>(
                        isExpanded: true,
                        value: selectedMainJabatan,
                        hint: Text('--pilih--', style: TextStyle(color: dropdownLight)),
                        icon: const Icon(Icons.expand_more),
                        iconEnabledColor: dropdownLight,
                        style: TextStyle(color: dropdownLight),
                        decoration: const InputDecoration(
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFFCCCCCC), width: 0.5),
                          ),
                        ),
                        items: jabatanList.map((j) => DropdownMenuItem(
                          value: j,
                          child: Text(j, style: TextStyle(color: dropdownLight)),
                        )).toList(),
                        onChanged: (v) => setState(() => selectedMainJabatan = v),
                      ),
                      const SizedBox(height: 12),

                      // Text Nama PIC
                      _buildFieldLabel('Nama PIC'),
                      TextFormField(
                        controller: _namaPicController,
                        maxLength: 50,
                        decoration: const InputDecoration(
                          hintText: 'Masukkan nama PIC',
                          counterText: null, // pakai default counter
                          enabledBorder: UnderlineInputBorder(),
                        ),
                        onChanged: (_) => setState(() {}),
                        validator: (v) =>
                        (v == null || v.isEmpty) ? 'Nama wajib diisi' : null,
                      ),
                      const SizedBox(height: 12),

                      // Text No Telpon PIC
                      _buildFieldLabel('No Telpon PIC'),
                      IntlPhoneField(
                        decoration: const InputDecoration(
                          hintText: 'Masukkan no. telepon',
                          enabledBorder: UnderlineInputBorder(),
                        ),
                        initialCountryCode: 'ID',
                        onChanged: (phone) {
                          setState(() {
                            selectedMainTelp = phone.completeNumber;  // ← simpan di sini
                          });
                        },
                        validator: (phone) {
                          if (phone == null || phone.number.isEmpty) return 'No. telepon wajib diisi';
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      // Tombol Tambahkan
                      // Tombol Tambahkan (contoh trigger validasi)
                      Align(
                        alignment: Alignment.center,
                        child: OutlinedButton(
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              _addMainPerson();
                            }
                          },
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: textButton, width: 2),       // warna & tebal border
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(13),            // radius sudut
                            ),
                            padding: const EdgeInsets.symmetric(
                              vertical: 12, horizontal: 20,
                            ),                                                     // spasi tombol
                          ),
                          child: Text(
                            'tambahkan',
                            style: TextStyle(
                              color: textButton,                                  // warna teks
                              fontSize: 16,                                       // ukuran teks
                            ),
                          ),
                        ),
                      ),

                      // Daftar PIC yang sudah ditambahkan
                      if (mainPersons.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 12, runSpacing: 12,
                          children: List.generate(mainPersons.length, (i) {
                            final pic = mainPersons[i];
                            return Card(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              // side: const BorderSide(color: Color(0xFF90CAF9)),
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  children: [
                                    Text(pic['jabatan']!, style: TextStyle(color: headerBlue)),
                                    Text(pic['nama']!, style: TextStyle(color: headerBlue)),
                                    Text(pic['telp']!, style: TextStyle(color: headerBlue)),
                                    IconButton(
                                      icon: const Icon(Icons.delete, color: Colors.red),
                                      onPressed: () => _removeMainPerson(i),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // … lanjut Card Data Visit, Upload Foto, dst.

              // const SizedBox(height: 24),
              // // tombol Submit
              // ElevatedButton(
              //   onPressed: () {
              //     // navigasi atau aksi submit
              //     // Get.toNamed(AppRoutes.nextPage);
              //   },
              //   child: const Text('Submit'),
              // ),
            ],
          ),
        ),
      ),
      ),
    );
  }
}

class DirectVisit extends StatefulWidget {
  const DirectVisit({Key? key}) : super(key: key);

  @override
  _DirectVisitState createState() => _DirectVisitState();
}
