import 'dart:async' show StreamSubscription;
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl_phone_field/intl_phone_field.dart' show IntlPhoneField;
import 'package:sufi_one/app/routes/app_routes.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import 'package:intl_phone_field/country_picker_dialog.dart' show Country;
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../../../src/services/api_services.dart';

class _DirectVisitState extends State<DirectVisit> {
  // API Service
  final ApiService _apiService = ApiService();

  // Dynamic dropdown values from API
  List<Map<String, dynamic>> jabatanList = [];
  List<Map<String, dynamic>> areaList = [];
  List<Map<String, dynamic>> cabangList = [];
  List<Map<String, dynamic>> produkList = [];
  List<Map<String, dynamic>> dealerList = [];
  List<Map<String, dynamic>> visitTypeList = [];
  List<Map<String, dynamic>> tujuanVisitList = [];

  // Loading states
  bool isLoadingJabatan = true;
  bool isLoadingArea = true;
  bool isLoadingCabang = false;
  bool isLoadingProduk = true;
  bool isLoadingDealer = false;
  bool isLoadingVisitType = true;
  bool isLoadingTujuanVisit = true;
  bool isSubmitting = false;

  final TextEditingController _namaPicController = TextEditingController();
  final TextEditingController _telpPicController = TextEditingController();
  List<Map<String, String>> mainPersons = [];
  final _formKey = GlobalKey<FormState>();
  final _mainPersonFormKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();
  late final PageController _pageCtrl;

  // selected values - now using codes instead of names
  String? selectedJabatan;
  String? selectedArea;
  String? selectedCabang;
  String? selectedProduk;
  String? selectedDealer;
  String? selectedVisitType;

  bool _hasInteractedWithJabatan = false;
  bool _hasInteractWithArea = false;
  bool _hasInteractWithCabang = false;
  bool _hasInteractWithProduk = false;
  bool _hasInteractWithDealer = false;
  bool _hasInteractWithVisitType = false;
  bool _hasInteractWithTujuanVisit = false;

  bool isPhoto1Uploaded = false;
  bool isPhoto2Uploaded = false;

  String? selectedTujuanVisit;
  DateTime? selectedTanggalMulai;
  DateTime? selectedTanggalBerakhir;
  DateTime? selectedTanggalPenyelesaian;
  String? selectedNamaPIC;
  String? temaDiskusi;
  String? problem;
  String? followUp;
  String? description;
  int namaPICLength = 0;
  int temaDiskusiLength = 0;
  int problemLength = 0;
  int followUpLength = 0;
  int descriptionLength = 0;
  int _currentPage = 0;

  String? selectedMainJabatan;
  String? selectedMainTelp;

  double? selectedLatitude;
  double? selectedLongitude;
  double? locationAccuracy;

  File? _photo1;
  File? _photo2;

  // define custom colors
  static const Color headerBlue = Color(0xFF1521A4);
  static const Color dropdownLight = Color(0xFF272728);
  static const Color dropdownLightNF = Color(0xFFCCCCCC);
  static const Color dropdownLightF = Color(0xFFAFA1CF);
  static const Color textButton = Color(0xFF8BADCA);

  @override
  void initState() {
    super.initState();
    _checkLocationPermission();
    _pageCtrl = PageController();
    _initializeData();

    // Initialize default selections
    selectedNamaPIC = '';
    temaDiskusi = '';
    problem = '';
    followUp = '';
    description = '';
    namaPICLength = selectedNamaPIC!.length;
    temaDiskusiLength = temaDiskusi!.length;
    problemLength = problem!.length;
    followUpLength = followUp!.length;
    descriptionLength = description!.length;
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    _positionStream?.cancel();
    _namaPicController.dispose();
    _telpPicController.dispose();
    super.dispose();
  }

  Future<void> _initializeData() async {
    await Future.wait([
      _loadJabatan(),
      _loadArea(),
      _loadProduk(),
      _loadVisitType(),
      _loadTujuanVisit(),
    ]);
  }

  Future<void> _loadJabatan() async {
    try {
      setState(() => isLoadingJabatan = true);
      final response = await _apiService.fetchJabatan();
      print('Jabatan Response: $response'); // Debug log

      setState(() {
        if (response is Map && response.containsKey('data')) {
          jabatanList = List<Map<String, dynamic>>.from(response['data']);
        } else if (response is List) {
          jabatanList = List<Map<String, dynamic>>.from(response as Iterable);
        } else {
          jabatanList = [];
        }
        isLoadingJabatan = false;
      });
    } catch (e) {
      print('Error loading jabatan: $e'); // Debug log
      setState(() => isLoadingJabatan = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading jabatan: $e')),
      );
    }
  }

  Future<void> _loadArea() async {
    try {
      setState(() => isLoadingArea = true);
      final response = await _apiService.fetchArea(); // Returns Map<String, dynamic>
      print('Area Response: $response'); // Debug log
      print('Area Response Type: ${response.runtimeType}'); // Debug log

      setState(() {
        // Handle Map response with 'data' key
        if (response is Map && response.containsKey('data')) {
          areaList = List<Map<String, dynamic>>.from(response['data']);
        } else if (response is List) {
          areaList = List<Map<String, dynamic>>.from(response as Iterable);
        } else {
          print('Unexpected area response format: $response');
          areaList = [];
        }
        isLoadingArea = false;
      });

      print('Area List Length: ${areaList.length}'); // Debug log
      if (areaList.isNotEmpty) {
        print('First Area Item: ${areaList.first}'); // Debug log
      }
    } catch (e) {
      print('Error loading area: $e'); // Debug log
      setState(() => isLoadingArea = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading area: $e')),
      );
    }
  }

  Future<void> _loadCabang(String areaCode) async {
    try {
      setState(() => isLoadingCabang = true);
      print('Loading cabang for area code: $areaCode'); // Debug log

      final response = await _apiService.fetchBranches(areaCode); // Returns List directly
      print('Cabang Response: $response'); // Debug log
      print('Cabang Response Type: ${response.runtimeType}'); // Debug log

      setState(() {
        cabangList = List<Map<String, dynamic>>.from(response);
        selectedCabang = null;
        isLoadingCabang = false;
      });

      print('Cabang List Length: ${cabangList.length}'); // Debug log
      if (cabangList.isNotEmpty) {
        print('First Cabang Item: ${cabangList.first}'); // Debug log
      }
    } catch (e) {
      print('Error loading cabang: $e'); // Debug log
      setState(() => isLoadingCabang = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading cabang: $e')),
      );
    }
  }

  Future<void> _loadProduk() async {
    try {
      setState(() => isLoadingProduk = true);
      final response = await _apiService.fetchProducts(); // Returns List directly
      print('Produk Response: $response'); // Debug log

      setState(() {
        produkList = List<Map<String, dynamic>>.from(response);
        isLoadingProduk = false;
      });
    } catch (e) {
      print('Error loading produk: $e'); // Debug log
      setState(() => isLoadingProduk = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading produk: $e')),
      );
    }
  }

  Future<void> _loadDealer({String? query}) async {
    try {
      setState(() => isLoadingDealer = true);
      final response = await _apiService.fetchDealers(query: query); // Returns List directly
      print('Dealer Response: $response'); // Debug log

      setState(() {
        dealerList = List<Map<String, dynamic>>.from(response);
        isLoadingDealer = false;
      });
    } catch (e) {
      print('Error loading dealer: $e'); // Debug log
      setState(() => isLoadingDealer = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading dealer: $e')),
      );
    }
  }

  Future<void> _loadVisitType() async {
    try {
      setState(() => isLoadingVisitType = true);
      final response = await _apiService.fetchType();
      print('Visit Type Response: $response'); // Debug log

      setState(() {
        if (response is Map && response.containsKey('data')) {
          visitTypeList = List<Map<String, dynamic>>.from(response['data']);
        } else if (response is List) {
          visitTypeList = List<Map<String, dynamic>>.from(response as Iterable);
        } else {
          visitTypeList = [];
        }
        isLoadingVisitType = false;
      });
    } catch (e) {
      print('Error loading visit type: $e'); // Debug log
      setState(() => isLoadingVisitType = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading visit type: $e')),
      );
    }
  }


  Future<void> _loadTujuanVisit() async {
    try {
      setState(() => isLoadingTujuanVisit = true);
      final response = await _apiService.fetchPurpose();
      print('Tujuan Visit Response: $response'); // Debug log

      setState(() {
        if (response is Map && response.containsKey('data')) {
          tujuanVisitList = List<Map<String, dynamic>>.from(response['data']);
        } else if (response is List) {
          tujuanVisitList = List<Map<String, dynamic>>.from(response as Iterable);
        } else {
          tujuanVisitList = [];
        }
        isLoadingTujuanVisit = false;
      });
    } catch (e) {
      print('Error loading tujuan visit: $e'); // Debug log
      setState(() => isLoadingTujuanVisit = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading tujuan visit: $e')),
      );
    }
  }

  // Helper method to safely get string value from dynamic data
  String _getStringValue(dynamic value) {
    if (value == null) return '';
    return value.toString();
  }

  // Helper method to safely get dropdown items
  List<DropdownMenuItem<String>> _buildDropdownItems(List<Map<String, dynamic>> items, {String codeKey = 'code', String nameKey = 'name'}) {
    return items.map((item) {
      final code = _getStringValue(item[codeKey]);
      final name = _getStringValue(item[nameKey]);
      return DropdownMenuItem<String>(
        value: code,
        child: Text(
          name.toUpperCase(),
          style: TextStyle(color: dropdownLight),
        ),
      );
    }).toList();
  }

  // Keep all existing methods for date selection, location, photos, etc.
  // ... (keeping all the existing methods from the original code)

  Future<void> _selectDate(
      BuildContext context,
      Function(DateTime?) setDate,
      String fieldType,
      ) async {
    DateTime initialDate = DateTime.now();
    DateTime firstDate = DateTime(2000);
    DateTime lastDate = DateTime(2100);

    switch (fieldType) {
      case 'dariTanggal':
        initialDate = selectedTanggalMulai ?? DateTime.now();
        lastDate = DateTime.now();
        break;
      case 'sampaiTanggal':
        initialDate = selectedTanggalBerakhir ?? (selectedTanggalMulai ?? DateTime.now());
        firstDate = selectedTanggalMulai ?? DateTime(2000);
        break;
      case 'tanggalSelesai':
        initialDate = selectedTanggalPenyelesaian ?? (selectedTanggalMulai ?? DateTime.now());
        firstDate = selectedTanggalMulai ?? DateTime(2000);
        lastDate = selectedTanggalBerakhir ?? DateTime(2100);
        break;
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
      helpText: 'Pilih $fieldType',
    );

    if (picked != null) {
      bool isValid = true;
      String? errorMessage;

      if (fieldType == 'dariTanggal' && picked.isAfter(DateTime.now())) {
        isValid = false;
        errorMessage = 'Dari Tanggal tidak boleh melebihi hari ini';
      } else if (fieldType == 'sampaiTanggal' && selectedTanggalMulai != null && picked.isBefore(selectedTanggalMulai!)) {
        isValid = false;
        errorMessage = 'Sampai Tanggal harus setelah atau sama dengan Dari Tanggal';
      } else if (fieldType == 'tanggalSelesai') {
        if (selectedTanggalMulai != null && picked.isBefore(selectedTanggalMulai!)) {
          isValid = false;
          errorMessage = 'Tanggal Selesai harus setelah atau sama dengan Dari Tanggal';
        } else if (selectedTanggalBerakhir != null && picked.isAfter(selectedTanggalBerakhir!)) {
          isValid = false;
          errorMessage = 'Tanggal Selesai harus sebelum atau sama dengan Sampai Tanggal';
        }
      }

      if (isValid) {
        setState(() {
          setDate(picked);
        });
      } else {
        _resetAllDates();
      }
    }
  }

  Future<void> _checkLocationPermission() async {
    LocationPermission perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) {
      perm = await Geolocator.requestPermission();
    }
    if (!await Geolocator.isLocationServiceEnabled()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('GPS/device location mati. Hidupkan dulu.'),
        ),
      );
      return;
    }

    if (perm == LocationPermission.deniedForever ||
        perm == LocationPermission.denied) {
      return;
    }
  }

  Future<void> _updateLocation() async {
    await _checkLocationPermission();
    try {
      Position pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.bestForNavigation,
        timeLimit: const Duration(seconds: 10),
      );
      setState(() {
        selectedLatitude = pos.latitude;
        selectedLongitude = pos.longitude;
      });
    } catch (e) {
      debugPrint('Location error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal mengambil lokasi: $e'))
      );
    }
  }

  StreamSubscription<Position>? _positionStream;

  void _resetAllDates() {
    setState(() {
      selectedTanggalMulai = null;
      selectedTanggalBerakhir = null;
      selectedTanggalPenyelesaian = null;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Input tanggal tidak valid. Semua tanggal direset. Silakan masukkan ulang.'),
      ),
    );
  }

  void _startListeningLocation() {
    _positionStream = Geolocator.getPositionStream(
      locationSettings: LocationSettings(
        accuracy: LocationAccuracy.bestForNavigation,
        distanceFilter: 5,
      ),
    ).listen((pos) {
      setState(() {
        selectedLatitude = pos.latitude;
        selectedLongitude = pos.longitude;
        locationAccuracy = pos.accuracy;
      });
    });
  }

  void _stopListeningLocation() {
    _positionStream?.cancel();
  }

  Future<void> _pickPhoto({
    required bool first,
    required ImageSource src,
  }) async {
    try {
      final XFile? f = await ImagePicker().pickImage(
        source: src,
        maxWidth: 800,
        maxHeight: 800,
      );
      if (f == null) return;
      setState(() {
        if (first) {
          _photo1 = File(f.path);
          isPhoto1Uploaded = true;
        } else {
          _photo2 = File(f.path);
          isPhoto2Uploaded = true;
        }
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengambil foto: $e')),
      );
    }
  }

  Future<void> _replaceCurrentPhoto(ImageSource src) async {
    try {
      final XFile? f = await _picker.pickImage(
        source: src,
        maxWidth: 800,
        maxHeight: 800,
      );
      if (f == null) return;

      setState(() {
        final file = File(f.path);
        if (_currentPage == 0 && isPhoto1Uploaded) {
          _photo1 = file;
          isPhoto1Uploaded = true;
        } else if (_currentPage == 1 && isPhoto2Uploaded) {
          _photo2 = file;
          isPhoto2Uploaded = true;
        }
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengambil foto: $e')),
      );
    }
  }

  Widget _photoRow({required bool first, File? file}) {
    return Column(
      children: [
        Center(
          child: Text(
            file == null ? 'Pilih ${first ? "Foto 1" : "Foto 2"}' : 'Foto ${first ? "1" : "2"} terunggah',
            style: TextStyle(
              color: headerBlue,
              fontSize: 16,
              fontWeight: file == null ? FontWeight.normal : FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _iconButton(
              icon: Icons.camera_alt,
              onTap: () => _pickPhoto(first: first, src: ImageSource.camera),
              borderColor: textButton,
              iconColor: const Color(0xFFCE3970),
              bgColor: Colors.white,
            ),
            _iconButton(
              icon: Icons.folder,
              onTap: () => _pickPhoto(first: first, src: ImageSource.gallery),
              borderColor: textButton,
              iconColor: const Color(0xFFFDBF12),
              bgColor: Colors.white,
            ),
          ],
        ),
      ],
    );
  }

  Widget _iconButton({
    required IconData icon,
    required VoidCallback onTap,
    Color borderColor = Colors.lightBlue,
    Color iconColor = Colors.pinkAccent,
    Color bgColor = Colors.white,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: bgColor,
          border: Border.all(color: borderColor, width: 2),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Icon(icon, size: 32, color: iconColor),
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Text(
      label,
      style: TextStyle(
        fontWeight: FontWeight.bold,
        color: dropdownLight,
        fontSize: 16,
      ),
      textAlign: TextAlign.start,
    );
  }

  Widget _buildDateField(DateTime? date, VoidCallback onTap, String fieldType) {
    return Row(
      children: [
        Expanded(
          child: InkWell(
            onTap: () {
              print('Field $fieldType tapped at ${DateTime.now()}');
              onTap();
            },
            child: InputDecorator(
              decoration: InputDecoration(
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: dropdownLightNF, width: 1.0),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: dropdownLightF, width: 2.0),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
                errorText: _validateDateField(fieldType),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    date != null ? DateFormat('yyyy-MM-dd').format(date) : 'Pilih tanggal',
                    style: TextStyle(color: dropdownLight, fontSize: 16),
                  ),
                  const Icon(Icons.calendar_today, color: Colors.blue, size: 20),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  String? _validateDateField(String fieldType) {
    if (selectedTanggalMulai == null && selectedTanggalBerakhir == null && selectedTanggalPenyelesaian == null) {
      return null;
    }

    switch (fieldType) {
      case 'dariTanggal':
        if (selectedTanggalMulai == null) {
          return 'Dari Tanggal wajib diisi';
        } else if (selectedTanggalMulai!.isAfter(DateTime.now())) {
          _resetAllDates();
          return null;
        }
        break;
      case 'sampaiTanggal':
        if (selectedTanggalBerakhir == null) {
          return 'Sampai Tanggal wajib diisi';
        } else if (selectedTanggalMulai != null && selectedTanggalBerakhir!.isBefore(selectedTanggalMulai!)) {
          _resetAllDates();
          return null;
        }
        break;
      case 'tanggalSelesai':
        if (selectedTanggalPenyelesaian == null) {
          return 'Tanggal Selesai wajib diisi';
        } else if (selectedTanggalMulai != null && selectedTanggalPenyelesaian!.isBefore(selectedTanggalMulai!)) {
          _resetAllDates();
          return null;
        } else if (selectedTanggalBerakhir != null && selectedTanggalPenyelesaian!.isAfter(selectedTanggalBerakhir!)) {
          _resetAllDates();
          return null;
        }
        break;
    }
    return null;
  }

  Widget _photoPreview({required File? file}) {
    return Visibility(
      visible: file != null,
      child: Card(
        color: const Color(0xFFFDFDFF),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Center(
                child: Text(
                  'Preview Foto',
                  style: TextStyle(fontSize: 22, color: headerBlue),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 200,
                child: PageView(
                  controller: _pageCtrl,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(file!, fit: BoxFit.cover),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _photoPreviewSection() {
    if (_photo1 == null && _photo2 == null) {
      return const SizedBox.shrink();
    }

    if (_photo1 != null && _photo2 == null) {
      return Card(
        color: const Color(0xFFFDFDFF),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Center(
                child: Text(
                  'Preview Foto 1',
                  style: TextStyle(fontSize: 22, color: headerBlue),
                ),
              ),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: () => _showFullScreenImage(context, _photo1!),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(
                    _photo1!,
                    fit: BoxFit.cover,
                    height: 350,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: () => _pickPhoto(first: true, src: ImageSource.camera),
                    icon: const Icon(Icons.camera_alt, color: Colors.white),
                    label: const Text("Ambil Ulang"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: headerBlue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _pickPhoto(first: true, src: ImageSource.gallery),
                    icon: const Icon(Icons.photo, color: Colors.white),
                    label: const Text("Browse Ulang"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: headerBlue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }

    if (_photo1 == null && _photo2 != null) {
      return Card(
        color: const Color(0xFFFDFDFF),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Center(
                child: Text(
                  'Preview Foto 2',
                  style: TextStyle(fontSize: 22, color: headerBlue),
                ),
              ),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: () => _showFullScreenImage(context, _photo2!),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(
                    _photo2!,
                    fit: BoxFit.cover,
                    height: 350,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: () => _pickPhoto(first: false, src: ImageSource.camera),
                    icon: const Icon(Icons.camera_alt, color: Colors.white),
                    label: const Text("Retake"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: headerBlue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _pickPhoto(first: false, src: ImageSource.gallery),
                    icon: const Icon(Icons.photo, color: Colors.white),
                    label: const Text("Browse"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: headerBlue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }

    final photos = [_photo1!, _photo2!];
    return Card(
      color: const Color(0xFFFDFDFF),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Center(
              child: Text(
                'Preview Foto (${_currentPage + 1}/2)',
                style: TextStyle(fontSize: 22, color: headerBlue),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 350,
              child: PageView.builder(
                controller: _pageCtrl,
                onPageChanged: (i) => setState(() => _currentPage = i),
                itemCount: photos.length,
                itemBuilder: (context, i) => GestureDetector(
                  onTap: () => _showFullScreenImage(context, photos[i]),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Stack(
                      children: [
                        Image.file(
                          photos[i],
                          fit: BoxFit.cover,
                          height: double.infinity,
                          width: double.infinity,
                        ),
                        Positioned(
                          right: 10,
                          bottom: 10,
                          child: IconButton(
                            icon: Icon(
                              Icons.fullscreen_sharp,
                              color: Colors.white,
                              shadows: [
                                Shadow(
                                  blurRadius: 4.0,
                                  color: Colors.black.withOpacity(1),
                                  offset: const Offset(2, 2),
                                ),
                              ],
                            ),
                            onPressed: () => _showFullScreenImage(context, photos[i]),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () => _replaceCurrentPhoto(ImageSource.camera),
                  icon: const Icon(Icons.camera_alt, color: Colors.white),
                  label: const Text("Retake Foto"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: headerBlue,
                    foregroundColor: Colors.white,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => _replaceCurrentPhoto(ImageSource.gallery),
                  icon: const Icon(Icons.photo, color: Colors.white),
                  label: const Text("Browse"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: headerBlue,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _photoCarouselWithControls() {
    final photos = [_photo1!, _photo2!];

    return Column(
      children: [
        SizedBox(
          height: 200,
          child: PageView.builder(
            controller: _pageCtrl,
            onPageChanged: (i) => setState(() => _currentPage = i),
            itemCount: photos.length,
            itemBuilder: (context, i) => ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.file(photos[i], fit: BoxFit.cover),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton.icon(
              onPressed: () => _replaceCurrentPhoto(ImageSource.camera),
              icon: const Icon(Icons.camera_alt),
              label: const Text("Ulangi"),
            ),
            ElevatedButton.icon(
              onPressed: () => _replaceCurrentPhoto(ImageSource.gallery),
              icon: const Icon(Icons.folder),
              label: const Text("Browse Folder"),
            ),
          ],
        ),
      ],
    );
  }

  void _addMainPerson() {
    if (!_mainPersonFormKey.currentState!.validate()) return;

    _mainPersonFormKey.currentState!.save();

    if (mainPersons.any((e) => e['telp'] == selectedMainTelp)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nomor telepon sudah pernah digunakan')),
      );
      return;
    }

    if (mainPersons.any(
          (e) =>
      e['jabatan'] == selectedMainJabatan &&
          e['nama'] == _namaPicController.text &&
          e['telp'] == selectedMainTelp,
    )) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Data PIC ini sudah ada')),
      );
      return;
    }

    setState(() {
      mainPersons.add({
        'jabatan': selectedMainJabatan!,
        'nama': _namaPicController.text,
        'telp': selectedMainTelp!,
      });
      selectedMainJabatan = null;
      selectedMainTelp = null;
      _namaPicController.clear();
      _telpPicController.text = '';
    });
  }

  void _removeMainPerson(int index) {
    setState(() => mainPersons.removeAt(index));
  }

  void _showFullScreenImage(BuildContext context, File photo) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Scaffold(
          backgroundColor: Colors.black,
          body: Stack(
            children: [
              Center(
                child: InteractiveViewer(
                  child: Image.file(photo),
                ),
              ),
              Positioned(
                top: 40,
                right: 20,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white, size: 30),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mohon lengkapi semua field yang wajib diisi')),
      );
      return;
    }

    if (_photo1 == null || _photo2 == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mohon upload kedua foto')),
      );
      return;
    }

    if (selectedLatitude == null || selectedLongitude == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mohon ambil lokasi terlebih dahulu')),
      );
      return;
    }

    try {
      setState(() => isSubmitting = true);

      final response = await _apiService.submitDirectVisit(
        jabatanSaya: selectedJabatan!,
        areaCode: selectedArea!,
        branchCode: selectedCabang!,
        productCode: selectedProduk!,
        dealerCode: selectedDealer!,
        tipeVisit: selectedVisitType!,
        tujuanVisit: selectedTujuanVisit!,
        dariTanggal: DateFormat('yyyy-MM-dd').format(selectedTanggalMulai!),
        sampaiTanggal: DateFormat('yyyy-MM-dd').format(selectedTanggalBerakhir!),
        tanggalSelesai: DateFormat('yyyy-MM-dd').format(selectedTanggalPenyelesaian!),
        namaPic: selectedNamaPIC!,
        themeOfDiscussion: temaDiskusi ?? '',
        problem: problem ?? '',
        followUp: followUp ?? '',
        description: description ?? '',
        photo1: _photo1!,
        photo2: _photo2!,
        mainPersons: mainPersons,
        latitude: selectedLatitude,
        longitude: selectedLongitude,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Direct visit berhasil disubmit!'),
          backgroundColor: Colors.green,
        ),
      );

      Get.back();

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFDFF),
      appBar: AppBar(
        backgroundColor: headerBlue,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
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
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Center(
                          child: Text(
                            'Jabatan Saya',
                            style: TextStyle(fontSize: 22, color: headerBlue),
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildFieldLabel('Jabatan'),
                        isLoadingJabatan
                            ? const CircularProgressIndicator()
                            : DropdownButtonFormField<String>(
                          isExpanded: true,
                          value: selectedJabatan,
                          hint: Text(
                            '-- Pilih Jabatan --',
                            style: TextStyle(color: dropdownLight),
                          ),
                          icon: const Icon(Icons.expand_more),
                          iconEnabledColor: dropdownLight,
                          style: TextStyle(color: dropdownLight),
                          decoration: const InputDecoration(
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: Color(0xFFCCCCCC),
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
                          items: _buildDropdownItems(jabatanList, codeKey: 'name', nameKey: 'name'),
                          onChanged: (v) => setState(() {
                            selectedJabatan = v;
                            _hasInteractedWithJabatan = true;
                          }),
                          onTap: () {
                            setState(() {
                              _hasInteractedWithJabatan = true;
                            });
                          },
                          validator: (v) =>
                          _hasInteractedWithJabatan && v == null
                              ? 'Harap pilih jabatan'
                              : null,
                        ),
                        const SizedBox(height: 16),
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
                        if (isLoadingArea)
                          const CircularProgressIndicator()
                        else
                          DropdownButtonFormField<String>(
                            isExpanded: true,
                            value: selectedArea,
                            hint: Text(
                              '-- Pilih Area --',
                              style: TextStyle(color: dropdownLight),
                            ),
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
                            items: _buildDropdownItems(areaList),
                            onChanged: (val) {
                              print('Area selected: $val'); // Debug log
                              setState(() {
                                selectedArea = val;
                                selectedCabang = null;
                                cabangList.clear(); // Clear existing cabang list
                                _hasInteractWithArea = true;
                              });
                              if (val != null && val.isNotEmpty) {
                                _loadCabang(val);
                              }
                            },
                            onTap: () {
                              setState(() {
                                _hasInteractWithArea = true;
                              });
                            },
                            validator: (v) =>
                            _hasInteractWithArea && v == null
                                ? 'Harap Pilih Area'
                                : null,
                          ),
                        const SizedBox(height: 12),
                        Text(
                          'Cabang',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: dropdownLight,
                          ),
                        ),
                        if (isLoadingCabang)
                          const CircularProgressIndicator()
                        else
                          DropdownButtonFormField<String>(
                            isExpanded: true,
                            value: selectedCabang,
                            hint: Text(
                              selectedArea == null
                                  ? '-- Pilih Area Dulu --'
                                  : cabangList.isEmpty
                                  ? '-- Tidak ada cabang --'
                                  : '-- Pilih Cabang --',
                              style: TextStyle(color: dropdownLight),
                            ),
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
                            items: _buildDropdownItems(cabangList),
                            onChanged: selectedArea == null || cabangList.isEmpty ? null : (val) {
                              print('Cabang selected: $val'); // Debug log
                              setState(() {
                                selectedCabang = val;
                                _hasInteractWithCabang = true;
                              });
                            },
                            onTap: () {
                              setState(() {
                                _hasInteractWithCabang = true;
                              });
                            },
                            validator: (v) =>
                            _hasInteractWithCabang && v == null
                                ? 'Harap Pilih Cabang'
                                : null,
                          ),
                        const SizedBox(height: 12),
                        Text(
                          'Produk',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: dropdownLight,
                          ),
                        ),
                        isLoadingProduk
                            ? const CircularProgressIndicator()
                            : DropdownButtonFormField<String>(
                          isExpanded: true,
                          value: selectedProduk,
                          hint: Text(
                            '-- Pilih Produk --',
                            style: TextStyle(color: dropdownLight),
                          ),
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
                          items: _buildDropdownItems(produkList),
                          onChanged: (val) => setState(() {
                            selectedProduk = val;
                            _hasInteractWithProduk = true;
                            // Load dealers when product is selected
                            if (val != null) {
                              _loadDealer();
                            }
                          }),
                          onTap: () {
                            setState(() {
                              _hasInteractWithProduk = true;
                            });
                          },
                          validator: (v) =>
                          _hasInteractWithProduk && v == null
                              ? 'Harap Pilih Produk'
                              : null,
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
                                _loadDealer();
                              },
                            ),
                          ],
                        ),
                        isLoadingDealer
                            ? const CircularProgressIndicator()
                            : DropdownButtonFormField<String>(
                          isExpanded: true,
                          value: selectedDealer,
                          hint: Text(
                            '-- Pilih Dealer --',
                            style: TextStyle(color: dropdownLight),
                          ),
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
                          items: _buildDropdownItems(dealerList),
                          onChanged: (val) => setState(() {
                            selectedDealer = val;
                            _hasInteractWithDealer = true;
                          }),
                          onTap: () {
                            setState(() {
                              _hasInteractWithDealer = true;
                            });
                          },
                          validator: (v) =>
                          _hasInteractWithDealer && v == null
                              ? 'Harap Pilih Dealer'
                              : null,
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
                        _buildFieldLabel('Tipe Visit'),
                        isLoadingVisitType
                            ? const CircularProgressIndicator()
                            : DropdownButtonFormField<String>(
                          isExpanded: true,
                          value: selectedVisitType,
                          hint: Text('-- Pilih Tipe Visit --', style: TextStyle(color: dropdownLight)),
                          icon: const Icon(Icons.expand_more),
                          iconEnabledColor: dropdownLight,
                          style: const TextStyle(color: dropdownLight),
                          decoration: const InputDecoration(
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: dropdownLightNF, width: 0.5),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: dropdownLightF, width: 2.0),
                            ),
                          ),
                          items: _buildDropdownItems(visitTypeList, codeKey: 'name', nameKey: 'name'),
                          onChanged: (val) => setState(() => selectedVisitType = val),
                          validator: (v) => v == null ? 'Harap Pilih Tipe Visit' : null,
                        ),
                        const SizedBox(height: 12),
                        _buildFieldLabel('Tujuan Visit'),
                        isLoadingTujuanVisit
                            ? const CircularProgressIndicator()
                            : DropdownButtonFormField<String>(
                          isExpanded: true,
                          value: selectedTujuanVisit,
                          hint: Text('-- Pilih Tujuan Visit --', style: TextStyle(color: dropdownLight)),
                          icon: const Icon(Icons.expand_more),
                          iconEnabledColor: dropdownLight,
                          style: const TextStyle(color: dropdownLight),
                          decoration: const InputDecoration(
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: dropdownLightNF, width: 0.5),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: dropdownLightF, width: 2.0),
                            ),
                          ),
                          items: _buildDropdownItems(tujuanVisitList, codeKey: 'name', nameKey: 'name'),
                          onChanged: (val) => setState(() => selectedTujuanVisit = val),
                          validator: (v) => v == null ? 'Harap Pilih Tujuan Visit' : null,
                        ),
                        const SizedBox(height: 12),
                        _buildFieldLabel('Dari Tanggal'),
                        _buildDateField(
                          selectedTanggalMulai,
                              () => _selectDate(
                            context,
                                (date) {
                              setState(() {
                                selectedTanggalMulai = date;
                                if (date != null) {
                                  if (selectedTanggalBerakhir != null && selectedTanggalBerakhir!.isBefore(date)) {
                                    selectedTanggalBerakhir = null;
                                  }
                                  if (selectedTanggalPenyelesaian != null && selectedTanggalPenyelesaian!.isBefore(date)) {
                                    selectedTanggalPenyelesaian = null;
                                  }
                                }
                              });
                            },
                            'dariTanggal',
                          ),
                          'dariTanggal',
                        ),
                        const SizedBox(height: 12),
                        _buildFieldLabel('Sampai Tanggal'),
                        _buildDateField(
                          selectedTanggalBerakhir,
                              () => _selectDate(
                            context,
                                (date) {
                              setState(() {
                                selectedTanggalBerakhir = date;
                                if (date != null && selectedTanggalPenyelesaian != null && selectedTanggalPenyelesaian!.isAfter(date)) {
                                  selectedTanggalPenyelesaian = null;
                                }
                              });
                            },
                            'sampaiTanggal',
                          ),
                          'sampaiTanggal',
                        ),
                        const SizedBox(height: 12),
                        _buildFieldLabel('Tanggal Selesai'),
                        _buildDateField(
                          selectedTanggalPenyelesaian,
                              () => _selectDate(
                            context,
                                (date) => setState(() => selectedTanggalPenyelesaian = date),
                            'tanggalSelesai',
                          ),
                          'tanggalSelesai',
                        ),
                        const SizedBox(height: 12),
                        _buildFieldLabel('Nama PIC'),
                        TextFormField(
                          initialValue: selectedNamaPIC ?? '',
                          style: TextStyle(color: dropdownLight, fontSize: 16),
                          maxLength: 50,
                          maxLengthEnforcement: MaxLengthEnforcement.enforced,
                          decoration: InputDecoration(
                            hintText: 'Masukkan nama PIC',
                            hintStyle: TextStyle(color: dropdownLightNF),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: dropdownLightF, width: 1.5),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: dropdownLightF, width: 3.0),
                            ),
                            counterText: '$namaPICLength/50',
                            counterStyle: TextStyle(color: dropdownLight, fontSize: 12),
                            contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                          ),
                          keyboardType: TextInputType.text,
                          inputFormatters: [
                            FilteringTextInputFormatter.deny(RegExp(r'[0-9]')),
                          ],
                          onChanged: (val) => setState(() {
                            selectedNamaPIC = val;
                            namaPICLength = val.length;
                          }),
                          validator: (v) => v == null || v.isEmpty ? 'Nama PIC wajib diisi' : null,
                        ),
                        const SizedBox(height: 12),
                        _buildFieldLabel('Theme of Discussion'),
                        TextFormField(
                          initialValue: temaDiskusi ?? '',
                          style: TextStyle(color: dropdownLight, fontSize: 16),
                          maxLength: 1000,
                          maxLengthEnforcement: MaxLengthEnforcement.enforced,
                          minLines: 3,
                          maxLines: 5,
                          decoration: InputDecoration(
                            hintText: 'Masukkan tema diskusi',
                            hintStyle: TextStyle(color: dropdownLightNF),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: dropdownLightNF, width: 0.5),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: dropdownLightF, width: 2.0),
                            ),
                            contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                          ),
                          onChanged: (val) => setState(() {
                            temaDiskusi = val;
                            temaDiskusiLength = val.length;
                          }),
                          validator: (v) => v == null || v.isEmpty ? 'Tema diskusi wajib diisi' : null,
                        ),
                        const SizedBox(height: 12),
                        _buildFieldLabel('Problem'),
                        TextFormField(
                          initialValue: problem ?? '',
                          style: TextStyle(color: dropdownLight, fontSize: 16),
                          maxLength: 1000,
                          maxLengthEnforcement: MaxLengthEnforcement.enforced,
                          minLines: 3,
                          maxLines: 5,
                          decoration: InputDecoration(
                            hintText: 'Masukkan Problem',
                            hintStyle: TextStyle(color: dropdownLightNF),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: dropdownLightNF, width: 0.5),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: dropdownLightF, width: 2.0),
                            ),
                            contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                          ),
                          onChanged: (val) => setState(() {
                            problem = val;
                            problemLength = val.length;
                          }),
                          validator: (v) => v == null || v.isEmpty ? 'Problem wajib diisi' : null,
                        ),
                        const SizedBox(height: 12),
                        _buildFieldLabel('Follow-Up'),
                        TextFormField(
                          initialValue: followUp ?? '',
                          style: TextStyle(color: dropdownLight, fontSize: 16),
                          maxLength: 1000,
                          maxLengthEnforcement: MaxLengthEnforcement.enforced,
                          minLines: 3,
                          maxLines: 5,
                          decoration: InputDecoration(
                            hintText: 'Masukkan Follow-Up',
                            hintStyle: TextStyle(color: dropdownLightNF),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: dropdownLightNF, width: 0.5),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: dropdownLightF, width: 2.0),
                            ),
                            contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                          ),
                          onChanged: (val) => setState(() {
                            followUp = val;
                            followUpLength = val.length;
                          }),
                          validator: (v) => v == null || v.isEmpty ? 'Follow-Up wajib diisi' : null,
                        ),
                        const SizedBox(height: 12),
                        _buildFieldLabel('Description'),
                        TextFormField(
                          initialValue: description ?? '',
                          style: TextStyle(color: dropdownLight, fontSize: 16),
                          maxLength: 1000,
                          maxLengthEnforcement: MaxLengthEnforcement.enforced,
                          minLines: 3,
                          maxLines: 5,
                          decoration: InputDecoration(
                            hintText: 'Masukkan deskripsi',
                            hintStyle: TextStyle(color: dropdownLightNF),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: dropdownLightNF, width: 0.5),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: dropdownLightF, width: 2.0),
                            ),
                            contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                          ),
                          onChanged: (val) => setState(() {
                            description = val;
                            descriptionLength = val.length;
                          }),
                          validator: (v) => v == null || v.isEmpty ? 'Deskripsi wajib diisi' : null,
                        ),
                      ],
                    ),
                  ),
                ),

                // Card Main Person
                Card(
                  color: const Color(0xFFFDFDFF),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Text(
                            'Main Person',
                            style: TextStyle(fontSize: 22, color: headerBlue),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Form(
                          key: _mainPersonFormKey,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildFieldLabel('Jabatan'),
                              DropdownButtonFormField<String>(
                                isExpanded: true,
                                value: selectedMainJabatan,
                                hint: Text(
                                  '-- Pilih Jabatan --',
                                  style: TextStyle(color: dropdownLight),
                                ),
                                icon: const Icon(Icons.expand_more),
                                iconEnabledColor: dropdownLight,
                                style: TextStyle(color: dropdownLight),
                                decoration: const InputDecoration(
                                  enabledBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Color(0xFFCCCCCC),
                                      width: 0.5,
                                    ),
                                  ),
                                ),
                                items: _buildDropdownItems(jabatanList, codeKey: 'name', nameKey: 'name'),
                                onChanged: (v) => setState(() {
                                  selectedMainJabatan = v;
                                }),
                                validator: (v) => v == null ? 'Harap Pilih Jabatan' : null,
                              ),
                              const SizedBox(height: 12),
                              _buildFieldLabel('Nama PIC'),
                              TextFormField(
                                controller: _namaPicController,
                                maxLength: 50,
                                decoration: const InputDecoration(
                                  hintText: 'Masukkan nama PIC',
                                  counterText: null,
                                  enabledBorder: UnderlineInputBorder(),
                                ),
                                keyboardType: TextInputType.text,
                                inputFormatters: [
                                  FilteringTextInputFormatter.deny(RegExp(r'[0-9]')),
                                ],
                                onChanged: (_) => setState(() {}),
                                validator: (v) => (v == null || v.isEmpty) ? 'Nama wajib diisi' : null,
                              ),
                              const SizedBox(height: 12),
                              _buildFieldLabel('No Telpon PIC'),
                              IntlPhoneField(
                                controller: _telpPicController,
                                decoration: const InputDecoration(
                                  hintText: 'Masukkan no. telepon',
                                  enabledBorder: UnderlineInputBorder(),
                                ),
                                initialCountryCode: 'ID',
                                keyboardType: TextInputType.phone,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                                onChanged: (phone) {},
                                onSaved: (phone) {
                                  if (phone != null && phone.number.isNotEmpty && phone.number.length >= 6) {
                                    selectedMainTelp = phone.completeNumber;
                                  } else {
                                    selectedMainTelp = null;
                                  }
                                },
                                validator: (phone) {
                                  if (phone == null || phone.number.isEmpty) return 'Nomor telepon wajib diisi';
                                  final number = phone.number;
                                  if (number.length < 6) return 'Nomor telepon tidak valid';
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              Align(
                                alignment: Alignment.center,
                                child: OutlinedButton(
                                  onPressed: _addMainPerson,
                                  style: OutlinedButton.styleFrom(
                                    side: BorderSide(color: textButton),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: Text(
                                    'Tambahkan',
                                    style: TextStyle(color: textButton, fontSize: 16),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (mainPersons.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: mainPersons.length,
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                              childAspectRatio: 3 / 3,
                            ),
                            itemBuilder: (context, i) {
                              final pic = mainPersons[i];
                              return Card(
                                color: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  side: BorderSide(color: textButton, width: 2),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(8),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: SingleChildScrollView(
                                          physics: const BouncingScrollPhysics(),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                pic['jabatan']!,
                                                style: const TextStyle(
                                                  color: textButton,
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                pic['nama']!,
                                                style: const TextStyle(
                                                  color: textButton,
                                                  fontSize: 14,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                pic['telp']!,
                                                style: const TextStyle(
                                                  color: textButton,
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Align(
                                        alignment: Alignment.center,
                                        child: IconButton(
                                          icon: const Icon(
                                            Icons.delete,
                                            color: Colors.red,
                                            size: 24,
                                          ),
                                          onPressed: () {
                                            showDialog(
                                              context: context,
                                              builder: (context) => AlertDialog(
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(12),
                                                ),
                                                title: Text(
                                                  'Konfirmasi Hapus',
                                                  style: TextStyle(
                                                    color: headerBlue,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                content: Text(
                                                  'Apakah Anda yakin ingin menghapus ${pic['nama']} dari daftar PIC?',
                                                  style: const TextStyle(color: textButton),
                                                ),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () => Navigator.pop(context),
                                                    child: Text(
                                                      'Batal',
                                                      style: TextStyle(color: textButton),
                                                    ),
                                                  ),
                                                  TextButton(
                                                    onPressed: () {
                                                      _removeMainPerson(i);
                                                      Navigator.pop(context);
                                                    },
                                                    child: const Text(
                                                      'Hapus',
                                                      style: TextStyle(color: Colors.red),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            );
                                          },
                                          tooltip: 'Hapus PIC',
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Card Upload Foto
                Card(
                  color: const Color(0xFFFDFDFF),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 24,
                      horizontal: 16,
                    ),
                    child: Column(
                      children: [
                        Center(
                          child: Text(
                            'Upload Foto',
                            style: TextStyle(fontSize: 22, color: headerBlue),
                          ),
                        ),
                        const SizedBox(height: 20),
                        _photoRow(first: true, file: _photo1),
                        const SizedBox(height: 24),
                        _photoRow(first: false, file: _photo2),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                const SizedBox(height: 16),
                _photoPreviewSection(),

                // Card Lokasi Visit
                Card(
                  color: const Color(0xFFFDFDFF),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Text(
                            'Lokasi Visit',
                            style: TextStyle(fontSize: 22, color: headerBlue),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Latitude',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: dropdownLight,
                          ),
                        ),
                        Text(
                          selectedLatitude != null
                              ? selectedLatitude!.toStringAsFixed(6)
                              : '-',
                          style: TextStyle(color: dropdownLight),
                        ),
                        const Divider(color: Colors.grey),
                        Text(
                          'Longitude',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: dropdownLight,
                          ),
                        ),
                        Text(
                          selectedLongitude?.toStringAsFixed(6) ?? '-',
                          style: TextStyle(color: dropdownLight),
                        ),
                        const Divider(color: Colors.grey),
                        Align(
                          alignment: Alignment.center,
                          child: OutlinedButton(
                            onPressed: _updateLocation,
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: textButton, width: 2),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(13),
                              ),
                              padding: const EdgeInsets.symmetric(
                                vertical: 12,
                                horizontal: 24,
                              ),
                            ),
                            child: Text(
                              'cek lokasi',
                              style: TextStyle(color: textButton, fontSize: 16),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Submit Button
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF1B25A4),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(45),
                    ),
                  ),
                  onPressed: isSubmitting ? null : _submitForm,
                  child: isSubmitting
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Submit'),
                ),
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
