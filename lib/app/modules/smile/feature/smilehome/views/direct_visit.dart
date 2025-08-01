import 'dart:async' show StreamSubscription, Timer;
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl_phone_field/intl_phone_field.dart' show IntlPhoneField;
import 'package:provider/provider.dart';
import 'package:sufi_one/app/routes/app_routes.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import 'package:intl_phone_field/country_picker_dialog.dart' show Country;
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sufi_one/src/services/SMILE/api_services.dart';
import '../../../models/area.dart';
import '../../../models/branch.dart';
import '../../../models/dealer.dart';
import '../../../models/jabatan.dart';
import '../../../models/jabatanSFI.dart';
import '../../../models/product.dart';
import '../../../models/purpose.dart';
import '../../../models/visit.dart';
import '../../../models/type.dart' as models;
import 'dart:core' hide Type; // hide built-in Type
import 'dart:io';

import '../../../repositories/area_repository.dart';
import '../../../repositories/branch_repository.dart';
import '../../../repositories/dealer_repository.dart';
import '../../../repositories/jabatanSFI_repository.dart';
import '../../../repositories/jabatan_repository.dart';
import '../../../repositories/product_repository.dart';
import '../../../repositories/purpose_repository.dart';
import '../../../repositories/type_repository.dart';
import '../controllers/task_visit_controller.dart';

class _DirectVisitState extends State<DirectVisit> {
  // Dynamic dropdown values from API
  List<Area> areaList = [];
  List<Branch> cabangList = [];
  List<Product> produkList = [];
  List<Dealer> dealerList = [];
  List<Dealer> filteredDealerList = [];
  List<Purpose> tujuanVisitList = [];
  List<Jabatan> jabatanList = [];
  List<JabatanSFI> jabatanSFIList = [];
  List<models.Type> visitTypeList = [];

  // API Service
  final ApiServiceSmile _apiService = ApiServiceSmile();
  // Loading states
  bool isLoadingJabatan = true;
  bool isLoadingJabatanSFI = true;
  bool isLoadingArea = true;
  bool isLoadingCabang = false;
  bool isLoadingProduk = true;
  bool isLoadingDealer = false;
  bool isLoadingVisitType = true;
  bool isLoadingTujuanVisit = true;
  bool isSubmitting = false;
  bool isLoadingLocation = false;
  bool isDealerSearchEnabled = false;
  bool isDealerSearchExpanded = false;

  // Search controllers and focus
  final TextEditingController _dealerSearchController = TextEditingController();
  final FocusNode _dealerSearchFocus = FocusNode();
  Timer? _searchDebounceTimer;

  final TextEditingController _namaPicController = TextEditingController();
  final TextEditingController _telpPicController = TextEditingController();
  List<Map<String, String>> mainPersons = [];
  final _formKey = GlobalKey<FormState>();
  final _mainPersonFormKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();
  late final PageController _pageCtrl;

  // selected values - now using codes instead of names
  String? selectedJabatanSFI;
  String? selectedArea;
  String? selectedCabang;
  String? selectedProductCode;
  String? selectedDealer;
  String? selectedDealerName;
  String? selectedVisitType;
  String? selectedStatus = 'Planning'; // Default ke Planning

  bool _hasInteractedWithJabatanSFI = false;
  bool _hasInteractWithArea = false;
  bool _hasInteractWithCabang = false;
  bool _hasInteractWithProduk = false;
  bool _hasInteractWithDealer = false;
  bool _hasInteractWithVisitType = false;
  bool _hasInteractWithTujuanVisit = false;
  bool _isLoadingCollections = false;
  bool _hasInteractWithStatus = false;

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

  String? selectedJabatan;
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
    print('🚀 DirectVisit initState called');
    _checkLocationPermission();
    _pageCtrl = PageController();
    _initializeData();

    // Initialize search controller listener
    _dealerSearchController.addListener(_onDealerSearchChanged);

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
    _dealerSearchController.dispose();
    _dealerSearchFocus.dispose();
    _searchDebounceTimer?.cancel();
    super.dispose();
  }

  void _onDealerSearchChanged() {
    _searchDebounceTimer?.cancel();
    _searchDebounceTimer = Timer(const Duration(milliseconds: 300), () {
      _filterDealers(_dealerSearchController.text);
    });
  }

  // Update method _filterDealers:
  void _filterDealers(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredDealerList = List.from(dealerList);
      } else {
        filteredDealerList =
            dealerList.where((dealer) {
              final name = dealer.name.toLowerCase();
              final code = dealer.code.toLowerCase();
              final searchQuery = query.toLowerCase();
              return name.contains(searchQuery) || code.contains(searchQuery);
            }).toList();
      }
    });
  }

  Future<void> _initializeData() async {
    await Future.wait([
      _loadJabatanSFI(),
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
      final repository = Provider.of<JabatanRepository>(context, listen: false);
      final data = await repository.getJabatans(); // Offline-first
      setState(() {
        jabatanList = data;
        isLoadingJabatan = false;
      });
    } catch (e) {
      print('Error loading jabatan: $e');
      setState(() => isLoadingJabatan = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error loading jabatan: $e')));
    }
  }

  Future<void> _loadJabatanSFI() async {
    try {
      setState(() => isLoadingJabatanSFI = true);
      final repository = Provider.of<JabatanSFIRepository>(
        context,
        listen: false,
      );
      final data = await repository.getJabatanSFIs(); // Offline-first
      setState(() {
        jabatanSFIList = data;
        isLoadingJabatanSFI = false;
      });
    } catch (e) {
      print('Error loading jabatan SFI: $e');
      setState(() => isLoadingJabatanSFI = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error loading jabatan SFI: $e')));
    }
  }

  Future<void> _loadArea() async {
    try {
      setState(() => isLoadingArea = true);
      final repository = Provider.of<AreaRepository>(context, listen: false);
      final data = await repository.getAreas(); // Offline-first
      setState(() {
        areaList = data;
        isLoadingArea = false;
      });
    } catch (e) {
      print('Error loading area: $e');
      setState(() => isLoadingArea = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error loading area: $e')));
    }
  }

  Future<void> _loadCabang(String areaCode) async {
    try {
      setState(() => isLoadingCabang = true);
      final repository = Provider.of<BranchRepository>(context, listen: false);
      final allBranches = await repository.getBranches(); // Offline-first

      // Filter branches by area code
      final filteredBranches =
          allBranches.where((branch) => branch.areaCode == areaCode).toList();

      setState(() {
        cabangList = filteredBranches;
        selectedCabang = null;
        isLoadingCabang = false;
      });
    } catch (e) {
      print('Error loading cabang: $e');
      setState(() => isLoadingCabang = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error loading cabang: $e')));
    }
  }

  // lib/app/modules/smile/feature/smilehome/views/direct_visit.dart
  Future<void> _loadProduk() async {
    try {
      print('🚀 Starting _loadProduk...');
      setState(() => isLoadingProduk = true);

      final repository = Provider.of<ProductRepository>(context, listen: false);
      final data = await repository.getProducts(); // Offline-first

      print('✅ _loadProduk completed. Products count: ${data.length}');

      // Debug: Print semua product yang di-load
      for (int i = 0; i < data.length; i++) {
        print('📦 Product $i: ${data[i].code} - ${data[i].name}');
      }

      setState(() {
        produkList = data;
        isLoadingProduk = false;
      });
    } catch (e) {
      print('❌ Error loading produk: $e');
      setState(() => isLoadingProduk = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error loading produk: $e')));
    }
  }

  Future<void> _loadDealer({String? query}) async {
    try {
      setState(() => isLoadingDealer = true);
      final repository = Provider.of<DealerRepository>(context, listen: false);
      final data = await repository.getDealers(); // Offline-first

      // Filter by query if provided
      List<Dealer> filteredData = data;
      if (query != null && query.isNotEmpty) {
        filteredData =
            data.where((dealer) {
              final name = dealer.name.toLowerCase();
              final code = dealer.code.toLowerCase();
              final searchQuery = query.toLowerCase();
              return name.contains(searchQuery) || code.contains(searchQuery);
            }).toList();
      }

      setState(() {
        dealerList = data;
        filteredDealerList = filteredData;
        isLoadingDealer = false;
      });
    } catch (e) {
      print('Error loading dealer: $e');
      setState(() => isLoadingDealer = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error loading dealer: $e')));
    }
  }

  Future<void> _loadVisitType() async {
    try {
      setState(() => isLoadingVisitType = true);
      final repository = Provider.of<TypeRepository>(context, listen: false);
      final data = await repository.getTypes(); // Offline-first
      setState(() {
        visitTypeList = data;
        isLoadingVisitType = false;
      });
    } catch (e) {
      print('Error loading visit type: $e');
      setState(() => isLoadingVisitType = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error loading visit type: $e')));
    }
  }

  // lib/app/modules/smile/feature/smilehome/views/direct_visit.dart
  // Tambahkan di initState atau onPressed button
  // lib/app/modules/smile/feature/smilehome/views/direct_visit.dart
  Future<void> _forceRefreshProducts() async {
    try {
      print('🔄 Force refreshing products...');
      setState(() => isLoadingProduk = true);

      final repository = Provider.of<ProductRepository>(context, listen: false);
      final products = await repository.getProducts(forceRefresh: true);

      setState(() {
        produkList = products;
        isLoadingProduk = false;
      });

      print('✅ Force refresh completed. Products count: ${products.length}');

      // Debug: Print semua product yang di-load
      for (int i = 0; i < products.length; i++) {
        print(
          '📦 Loaded product $i: ${products[i].code} - ${products[i].name}',
        );
      }
    } catch (e) {
      print('❌ Force refresh failed: $e');
      setState(() => isLoadingProduk = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Force refresh failed: $e')));
    }
  }

  Future<void> _loadTujuanVisit() async {
    try {
      setState(() => isLoadingTujuanVisit = true);
      final repository = Provider.of<PurposeRepository>(context, listen: false);
      final data = await repository.getPurposes(); // Offline-first
      setState(() {
        tujuanVisitList = data;
        isLoadingTujuanVisit = false;
      });
    } catch (e) {
      print('Error loading tujuan visit: $e');
      setState(() => isLoadingTujuanVisit = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error loading tujuan visit: $e')));
    }
  }

  // Helper method to safely get string value from dynamic data
  String _getStringValue(dynamic value) {
    if (value == null) return '';
    return value.toString();
  }

  // Update method untuk build dropdown items:
  List<DropdownMenuItem<String>> _buildAreaDropdownItems() {
    final seen = <String>{};
    return areaList
        .map((area) {
          if (seen.contains(area.code)) return null;
          seen.add(area.code);
          return DropdownMenuItem<String>(
            value: area.code,
            child: Text(
              area.name.toUpperCase(),
              style: TextStyle(color: dropdownLight),
            ),
          );
        })
        .whereType<DropdownMenuItem<String>>()
        .toList();
  }

  List<DropdownMenuItem<String>> _buildCabangDropdownItems() {
    final seen = <String>{};
    return cabangList
        .map((cabang) {
          if (seen.contains(cabang.code)) return null;
          seen.add(cabang.code);
          return DropdownMenuItem<String>(
            value: cabang.code,
            child: Text(
              cabang.name.toUpperCase(),
              style: TextStyle(color: dropdownLight),
            ),
          );
        })
        .whereType<DropdownMenuItem<String>>()
        .toList();
  }

  // lib/app/modules/smile/feature/smilehome/views/direct_visit.dart
  // Update method _buildProdukDropdownItems
  // lib/app/modules/smile/feature/smilehome/views/direct_visit.dart
  List<DropdownMenuItem<String>> _buildProdukDropdownItems() {
    print(
      '🔍 _buildProdukDropdownItems called with ${produkList.length} products',
    );

    final items = <DropdownMenuItem<String>>[];

    // Tambahkan option "Pilih Product" di awal
    items.add(
      DropdownMenuItem<String>(
        value: null,
        child: Text('Pilih Product', style: TextStyle(color: Colors.grey)),
      ),
    );

    for (int i = 0; i < produkList.length; i++) {
      final produk = produkList[i];
      final code = produk.code.trim(); // Ganti .kode menjadi .code
      final name = produk.name.trim();

      print(
        '🔍 Processing product $i: code="$code" (${code.length} chars), name="$name"',
      );

      // Skip jika kode kosong atau N/A
      if (code.isEmpty || code == 'N/A') {
        print("⚠️ Skipping product with invalid code: $code - $name");
        continue;
      }

      // Validasi panjang kode
      if (code.length != 4) {
        // Pastikan panjangnya 4 karakter sesuai Laravel
        print(
          "⚠️ Product code length is not 4: $code (${code.length} chars) - $name",
        );
        continue;
      }

      items.add(
        DropdownMenuItem<String>(
          value: code,
          child: Text(
            '$code - ${name.toUpperCase()}',
            style: TextStyle(color: dropdownLight),
          ),
        ),
      );

      print("✅ Added product to dropdown: $code - $name");
    }

    print(
      "📦 Built ${items.length - 1} product dropdown items from ${produkList.length} products",
    );
    return items;
  }
  // add

  List<DropdownMenuItem<String>> _buildJabatanSFIDropdownItems() {
    final seen = <String>{};
    return jabatanSFIList
        .map((jabatan) {
          if (seen.contains(jabatan.name)) return null;
          seen.add(jabatan.name);
          return DropdownMenuItem<String>(
            value: jabatan.name,
            child: Text(
              jabatan.name.toUpperCase(),
              style: TextStyle(color: dropdownLight),
            ),
          );
        })
        .whereType<DropdownMenuItem<String>>()
        .toList();
  }

  List<DropdownMenuItem<String>> _buildJabatanDropdownItems() {
    final seen = <String>{};
    return jabatanList
        .map((jabatan) {
          if (seen.contains(jabatan.name)) return null;
          seen.add(jabatan.name);
          return DropdownMenuItem<String>(
            value: jabatan.name,
            child: Text(
              jabatan.name.toUpperCase(),
              style: TextStyle(color: dropdownLight),
            ),
          );
        })
        .whereType<DropdownMenuItem<String>>()
        .toList();
  }

  List<DropdownMenuItem<String>> _buildVisitTypeDropdownItems() {
    final seen = <String>{};
    return visitTypeList
        .map((type) {
          if (seen.contains(type.name)) return null;
          seen.add(type.name);
          return DropdownMenuItem<String>(
            value: type.name,
            child: Text(
              type.name.toUpperCase(),
              style: TextStyle(color: dropdownLight),
            ),
          );
        })
        .whereType<DropdownMenuItem<String>>()
        .toList();
  }

  List<DropdownMenuItem<String>> _buildTujuanVisitDropdownItems() {
    final seen = <String>{};
    return tujuanVisitList
        .map((purpose) {
          if (seen.contains(purpose.name)) return null;
          seen.add(purpose.name);
          return DropdownMenuItem<String>(
            value: purpose.name,
            child: Text(
              purpose.name.toUpperCase(),
              style: TextStyle(color: dropdownLight),
            ),
          );
        })
        .whereType<DropdownMenuItem<String>>()
        .toList();
  }

  List<DropdownMenuItem<String>> _buildStatusDropdownItems() {
    return [
      DropdownMenuItem<String>(
        value: 'Planning',
        child: Text('PLANNING', style: TextStyle(color: dropdownLight)),
      ),
      DropdownMenuItem<String>(
        value: 'Selesai',
        child: Text('SELESAI', style: TextStyle(color: dropdownLight)),
      ),
    ];
  }

  void _activateDealerSearch() {
    if (selectedProductCode == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih produk terlebih dahulu'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      isDealerSearchEnabled = true;
      isDealerSearchExpanded = true;
    });

    _loadDealer().then((_) {
      // Auto focus search field after data loads
      Future.delayed(const Duration(milliseconds: 100), () {
        _dealerSearchFocus.requestFocus();
      });
    });
  }

  void _selectDealer(String code, String name) {
    setState(() {
      selectedDealer = code;
      selectedDealerName = name;
      _hasInteractWithDealer = true;
      _dealerSearchController.text = name;
      isDealerSearchExpanded = false;
    });
    _dealerSearchFocus.unfocus();
  }

  void _clearDealerSelection() {
    setState(() {
      selectedDealer = null;
      selectedDealerName = null;
      _dealerSearchController.clear();
      filteredDealerList = List.from(dealerList);
      isDealerSearchExpanded = true;
    });
    _dealerSearchFocus.requestFocus();
  }

  Widget _buildAdvancedDealerSearch() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header dengan search activation
        Row(
          children: [
            Expanded(
              child: Text(
                'Dealer',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: dropdownLight,
                  fontSize: 16,
                ),
              ),
            ),
            if (!isDealerSearchEnabled)
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue.shade400, Colors.blue.shade600],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: _activateDealerSearch,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.search, color: Colors.white, size: 18),
                          const SizedBox(width: 6),
                          Text(
                            'Cari Dealer',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),

        // Search interface
        if (!isDealerSearchEnabled)
          // Inactive state
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.grey.shade600, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Klik tombol "Cari Dealer" untuk memulai pencarian',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                  ),
                ),
              ],
            ),
          )
        else
          // Active search interface
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color:
                    isDealerSearchExpanded
                        ? Colors.blue.shade300
                        : dropdownLightNF,
                width: isDealerSearchExpanded ? 2 : 1,
              ),
              boxShadow:
                  isDealerSearchExpanded
                      ? [
                        BoxShadow(
                          color: Colors.blue.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                      : null,
            ),
            child: Column(
              children: [
                // Search input
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.search,
                        color:
                            isDealerSearchExpanded ? Colors.blue : Colors.grey,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _dealerSearchController,
                          focusNode: _dealerSearchFocus,
                          decoration: InputDecoration(
                            hintText:
                                selectedDealer == null
                                    ? 'Ketik nama atau kode dealer...'
                                    : 'Dealer terpilih: $selectedDealerName',
                            hintStyle: TextStyle(
                              color:
                                  selectedDealer == null
                                      ? Colors.grey.shade500
                                      : Colors.green.shade600,
                              fontSize: 14,
                            ),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                          ),
                          style: TextStyle(color: dropdownLight, fontSize: 14),
                          onTap: () {
                            if (!isDealerSearchExpanded) {
                              setState(() {
                                isDealerSearchExpanded = true;
                              });
                            }
                          },
                          validator:
                              (v) =>
                                  _hasInteractWithDealer &&
                                          selectedDealer == null
                                      ? 'Harap Pilih Dealer'
                                      : null,
                        ),
                      ),
                      if (selectedDealer != null)
                        IconButton(
                          icon: Icon(
                            Icons.clear,
                            color: Colors.grey.shade600,
                            size: 18,
                          ),
                          onPressed: _clearDealerSelection,
                          padding: EdgeInsets.zero,
                          constraints: BoxConstraints(
                            minWidth: 32,
                            minHeight: 32,
                          ),
                        ),
                      if (isLoadingDealer)
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.blue,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                // Results dropdown
                if (isDealerSearchExpanded && !isLoadingDealer)
                  Container(
                    constraints: BoxConstraints(maxHeight: 200),
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(color: Colors.grey.shade200),
                      ),
                    ),
                    child:
                        filteredDealerList.isEmpty
                            ? Container(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.search_off,
                                    color: Colors.grey.shade400,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      _dealerSearchController.text.isEmpty
                                          ? 'Mulai mengetik untuk mencari dealer...'
                                          : 'Tidak ada dealer yang cocok dengan "${_dealerSearchController.text}"',
                                      style: TextStyle(
                                        color: Colors.grey.shade600,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )
                            : ListView.builder(
                              shrinkWrap: true,
                              itemCount: filteredDealerList.length,
                              itemBuilder: (context, index) {
                                final dealer = filteredDealerList[index];
                                final code = dealer.code;
                                final name = dealer.name;
                                final isSelected = selectedDealer == code;

                                return Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: () => _selectDealer(code, name),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 12,
                                      ),
                                      decoration: BoxDecoration(
                                        color:
                                            isSelected
                                                ? Colors.blue.shade50
                                                : Colors.transparent,
                                        border:
                                            index <
                                                    filteredDealerList.length -
                                                        1
                                                ? Border(
                                                  bottom: BorderSide(
                                                    color: Colors.grey.shade100,
                                                  ),
                                                )
                                                : null,
                                      ),
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 8,
                                            height: 8,
                                            decoration: BoxDecoration(
                                              color:
                                                  isSelected
                                                      ? Colors.blue
                                                      : Colors.grey.shade300,
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  name,
                                                  style: TextStyle(
                                                    color:
                                                        isSelected
                                                            ? Colors
                                                                .blue
                                                                .shade700
                                                            : dropdownLight,
                                                    fontWeight:
                                                        isSelected
                                                            ? FontWeight.w600
                                                            : FontWeight.normal,
                                                    fontSize: 14,
                                                  ),
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                                if (code.isNotEmpty)
                                                  Text(
                                                    'Kode: $code',
                                                    style: TextStyle(
                                                      color:
                                                          Colors.grey.shade600,
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                              ],
                                            ),
                                          ),
                                          if (isSelected)
                                            Icon(
                                              Icons.check_circle,
                                              color: Colors.blue,
                                              size: 20,
                                            ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                  ),
              ],
            ),
          ),
      ],
    );
  }

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
        initialDate =
            selectedTanggalBerakhir ?? (selectedTanggalMulai ?? DateTime.now());
        firstDate = selectedTanggalMulai ?? DateTime(2000);
        break;
      case 'tanggalSelesai':
        initialDate =
            selectedTanggalPenyelesaian ??
            (selectedTanggalMulai ?? DateTime.now());
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
      } else if (fieldType == 'sampaiTanggal' &&
          selectedTanggalMulai != null &&
          picked.isBefore(selectedTanggalMulai!)) {
        isValid = false;
        errorMessage =
            'Sampai Tanggal harus setelah atau sama dengan Dari Tanggal';
      } else if (fieldType == 'tanggalSelesai') {
        if (selectedTanggalMulai != null &&
            picked.isBefore(selectedTanggalMulai!)) {
          isValid = false;
          errorMessage =
              'Tanggal Selesai harus setelah atau sama dengan Dari Tanggal';
        } else if (selectedTanggalBerakhir != null &&
            picked.isAfter(selectedTanggalBerakhir!)) {
          isValid = false;
          errorMessage =
              'Tanggal Selesai harus sebelum atau sama dengan Sampai Tanggal';
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
      setState(() => isLoadingLocation = true);

      Position pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.bestForNavigation,
        timeLimit: const Duration(seconds: 10),
      );

      setState(() {
        selectedLatitude = pos.latitude;
        selectedLongitude = pos.longitude;
        isLoadingLocation = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lokasi berhasil diperbarui'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      setState(() => isLoadingLocation = false);
      debugPrint('Location error: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal mengambil lokasi: $e')));
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
        content: Text(
          'Input tanggal tidak valid. Semua tanggal direset. Silakan masukkan ulang.',
        ),
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal mengambil foto: $e')));
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal mengambil foto: $e')));
    }
  }

  Widget _photoRow({required bool first, File? file}) {
    return Column(
      children: [
        Center(
          child: Text(
            file == null
                ? 'Pilih ${first ? "Foto 1" : "Foto 2"}'
                : 'Foto ${first ? "1" : "2"} terunggah',
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
                    date != null
                        ? DateFormat('yyyy-MM-dd').format(date)
                        : 'Pilih tanggal',
                    style: TextStyle(color: dropdownLight, fontSize: 16),
                  ),
                  const Icon(
                    Icons.calendar_today,
                    color: Colors.blue,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  String? _validateDateField(String fieldType) {
    if (selectedTanggalMulai == null &&
        selectedTanggalBerakhir == null &&
        selectedTanggalPenyelesaian == null) {
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
        } else if (selectedTanggalMulai != null &&
            selectedTanggalBerakhir!.isBefore(selectedTanggalMulai!)) {
          _resetAllDates();
          return null;
        }
        break;
      case 'tanggalSelesai':
        if (selectedTanggalPenyelesaian == null) {
          return 'Tanggal Selesai wajib diisi';
        } else if (selectedTanggalMulai != null &&
            selectedTanggalPenyelesaian!.isBefore(selectedTanggalMulai!)) {
          _resetAllDates();
          return null;
        } else if (selectedTanggalBerakhir != null &&
            selectedTanggalPenyelesaian!.isAfter(selectedTanggalBerakhir!)) {
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
                  child: Image.file(_photo1!, fit: BoxFit.cover, height: 350),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed:
                        () => _pickPhoto(first: true, src: ImageSource.camera),
                    icon: const Icon(Icons.camera_alt, color: Colors.white),
                    label: const Text("Ambil Ulang"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: headerBlue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed:
                        () => _pickPhoto(first: true, src: ImageSource.gallery),
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
                  child: Image.file(_photo2!, fit: BoxFit.cover, height: 350),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed:
                        () => _pickPhoto(first: false, src: ImageSource.camera),
                    icon: const Icon(Icons.camera_alt, color: Colors.white),
                    label: const Text("Retake"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: headerBlue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed:
                        () =>
                            _pickPhoto(first: false, src: ImageSource.gallery),
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
                itemBuilder:
                    (context, i) => GestureDetector(
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
                                onPressed:
                                    () => _showFullScreenImage(
                                      context,
                                      photos[i],
                                    ),
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
            itemBuilder:
                (context, i) => ClipRRect(
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
          e['jabatan'] == selectedJabatan &&
          e['nama'] == _namaPicController.text &&
          e['telp'] == selectedMainTelp,
    )) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Data PIC ini sudah ada')));
      return;
    }

    setState(() {
      // Insert at beginning instead of add to end
      mainPersons.insert(0, {
        'jabatan': selectedJabatan!,
        'nama': _namaPicController.text,
        'telp': selectedMainTelp!,
      });
      selectedJabatan = null;
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
        builder:
            (_) => Scaffold(
              backgroundColor: Colors.black,
              body: Stack(
                children: [
                  Center(child: InteractiveViewer(child: Image.file(photo))),
                  Positioned(
                    top: 40,
                    right: 20,
                    child: IconButton(
                      icon: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 30,
                      ),
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
        const SnackBar(
          content: Text('Mohon lengkapi semua field yang wajib diisi'),
        ),
      );
      return;
    }

    if (_photo1 == null || _photo2 == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Mohon upload kedua foto')));
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
        jabatanSaya: selectedJabatanSFI!,
        areaCode: selectedArea!,
        branchCode: selectedCabang!,
        productCode: selectedProductCode!,
        dealerCode: selectedDealer!,
        tipeVisit: selectedVisitType!,
        tujuanVisit: selectedTujuanVisit!,
        dariTanggal: DateFormat('yyyy-MM-dd').format(selectedTanggalMulai!),
        sampaiTanggal: DateFormat(
          'yyyy-MM-dd',
        ).format(selectedTanggalBerakhir!),
        tanggalSelesai: DateFormat(
          'yyyy-MM-dd',
        ).format(selectedTanggalPenyelesaian!),
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
        status: selectedStatus == 'Planning' ? 0 : 1,
      );

      final newVisit = Visit(
        jabatanSaya: selectedJabatanSFI,
        areaCode: selectedArea,
        branchCode: selectedCabang,
        productCode: selectedProductCode,
        dealerCode: selectedDealer,
        tipeVisit: selectedVisitType,
        tujuanVisit: selectedTujuanVisit,
        dariTanggal: selectedTanggalMulai,
        sampaiTanggal: selectedTanggalBerakhir,
        tanggalSelesai: selectedTanggalPenyelesaian,
        namaPic: selectedNamaPIC,
        themeOfDiscussion: temaDiskusi,
        problem: problem,
        followUp: followUp,
        description: description,
        photo1: _photo1?.path,
        photo2: _photo2?.path,
        latitude: selectedLatitude,
        longitude: selectedLongitude,
        mainPersons: mainPersons,
        status: selectedStatus == 'Planning' ? 0 : 1,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Direct visit berhasil disubmit!'),
          backgroundColor: Colors.green,
        ),
      );

      // ✅ Refresh data di halaman Task Visit
      Get.find<TaskVisitController>().addNewVisit(newVisit);

      // ✅ Kembali ke halaman sebelumnya
      Get.back();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
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
                        isLoadingJabatanSFI
                            ? const CircularProgressIndicator()
                            : DropdownButtonFormField<String>(
                              isExpanded: true,
                              value: selectedJabatanSFI,
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
                              items: _buildJabatanSFIDropdownItems(),
                              onChanged:
                                  (v) => setState(() {
                                    selectedJabatanSFI = v;
                                    _hasInteractedWithJabatanSFI = true;
                                  }),
                              onTap: () {
                                setState(() {
                                  _hasInteractedWithJabatanSFI = true;
                                });
                              },
                              validator:
                                  (v) =>
                                      _hasInteractedWithJabatanSFI && v == null
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
                        _buildFieldLabel('Area'),
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
                          items:
                              areaList.isEmpty ? [] : _buildAreaDropdownItems(),
                          onChanged:
                              areaList.isEmpty
                                  ? null
                                  : (val) {
                                    print('Area selected: $val');
                                    setState(() {
                                      selectedArea = val;
                                      selectedCabang = null;
                                      cabangList.clear();
                                      _hasInteractWithArea = true;
                                      // Reset dealer search when area changes
                                      isDealerSearchEnabled = false;
                                      isDealerSearchExpanded = false;
                                      selectedDealer = null;
                                      selectedDealerName = null;
                                      dealerList.clear();
                                      filteredDealerList.clear();
                                      _dealerSearchController.clear();
                                    });
                                    if (val != null && val.isNotEmpty) {
                                      _loadCabang(val);
                                    }
                                  },
                          onTap: () {
                            if (areaList.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Data area sedang dimuat, mohon tunggu...',
                                  ),
                                  backgroundColor: Colors.orange,
                                ),
                              );
                            } else {
                              setState(() {
                                _hasInteractWithArea = true;
                              });
                            }
                          },
                          validator:
                              (v) =>
                                  _hasInteractWithArea && v == null
                                      ? 'Harap Pilih Area'
                                      : null,
                        ),
                        const SizedBox(height: 12),
                        _buildFieldLabel('Cabang'),
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
                            items: _buildCabangDropdownItems(),
                            onChanged:
                                selectedArea == null || cabangList.isEmpty
                                    ? null
                                    : (val) {
                                      print(
                                        'Cabang selected: $val',
                                      ); // Debug log
                                      setState(() {
                                        selectedCabang = val;
                                        _hasInteractWithCabang = true;
                                      });
                                    },
                            onTap: () {
                              if (selectedArea == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Pilih area terlebih dahulu'),
                                    backgroundColor: Colors.orange,
                                  ),
                                );
                              } else {
                                setState(() {
                                  _hasInteractWithCabang = true;
                                });
                              }
                            },
                            validator:
                                (v) =>
                                    _hasInteractWithCabang && v == null
                                        ? 'Harap Pilih Cabang'
                                        : null,
                          ),
                        const SizedBox(height: 12),
                        _buildFieldLabel('Produk'),
                        isLoadingProduk
                            ? const CircularProgressIndicator()
                            : DropdownButtonFormField<String>(
                              isExpanded: true,
                              value: selectedProductCode,
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
                              items: _buildProdukDropdownItems(),
                              onChanged:
                                  (val) => setState(() {
                                    selectedProductCode = val;
                                    _hasInteractWithProduk = true;
                                    // Reset dealer search when product changes
                                    isDealerSearchEnabled = false;
                                    isDealerSearchExpanded = false;
                                    selectedDealer = null;
                                    selectedDealerName = null;
                                    dealerList.clear();
                                    filteredDealerList.clear();
                                    _dealerSearchController.clear();
                                  }),
                              onTap: () {
                                setState(() {
                                  _hasInteractWithProduk = true;
                                });
                              },
                              validator:
                                  (v) =>
                                      _hasInteractWithProduk && v == null
                                          ? 'Harap Pilih Produk'
                                          : null,
                            ),
                        const SizedBox(height: 16),

                        // Advanced Dealer Search
                        _buildAdvancedDealerSearch(),
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
                              hint: Text(
                                '-- Pilih Tipe Visit --',
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
                              items: _buildVisitTypeDropdownItems(),
                              onChanged:
                                  (val) => setState(() {
                                    selectedVisitType = val;
                                    _hasInteractWithVisitType = true;
                                  }),
                              onTap: () {
                                setState(() {
                                  _hasInteractWithVisitType = true;
                                });
                              },
                              validator:
                                  (v) =>
                                      _hasInteractWithVisitType && v == null
                                          ? 'Harap Pilih Tipe Visit'
                                          : null,
                            ),
                        const SizedBox(height: 12),
                        _buildFieldLabel('Tujuan Visit'),
                        isLoadingTujuanVisit
                            ? const CircularProgressIndicator()
                            : DropdownButtonFormField<String>(
                              isExpanded: true,
                              value: selectedTujuanVisit,
                              hint: Text(
                                '-- Pilih Tujuan Visit --',
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
                              items: _buildTujuanVisitDropdownItems(),
                              onChanged:
                                  (val) => setState(() {
                                    selectedTujuanVisit = val;
                                    _hasInteractWithTujuanVisit = true;
                                  }),
                              onTap: () {
                                setState(() {
                                  _hasInteractWithTujuanVisit = true;
                                });
                              },
                              validator:
                                  (v) =>
                                      _hasInteractWithTujuanVisit && v == null
                                          ? 'Harap Pilih Tujuan Visit'
                                          : null,
                            ),
                        const SizedBox(height: 12),
                        _buildFieldLabel('Dari Tanggal'),
                        _buildDateField(
                          selectedTanggalMulai,
                          () => _selectDate(context, (date) {
                            setState(() {
                              selectedTanggalMulai = date;
                              if (date != null) {
                                if (selectedTanggalBerakhir != null &&
                                    selectedTanggalBerakhir!.isBefore(date)) {
                                  selectedTanggalBerakhir = null;
                                }
                                if (selectedTanggalPenyelesaian != null &&
                                    selectedTanggalPenyelesaian!.isBefore(
                                      date,
                                    )) {
                                  selectedTanggalPenyelesaian = null;
                                }
                              }
                            });
                          }, 'dariTanggal'),
                          'dariTanggal',
                        ),
                        const SizedBox(height: 12),
                        _buildFieldLabel('Sampai Tanggal'),
                        _buildDateField(
                          selectedTanggalBerakhir,
                          () => _selectDate(context, (date) {
                            setState(() {
                              selectedTanggalBerakhir = date;
                              if (date != null &&
                                  selectedTanggalPenyelesaian != null &&
                                  selectedTanggalPenyelesaian!.isAfter(date)) {
                                selectedTanggalPenyelesaian = null;
                              }
                            });
                          }, 'sampaiTanggal'),
                          'sampaiTanggal',
                        ),
                        const SizedBox(height: 12),
                        _buildFieldLabel('Tanggal Selesai'),
                        _buildDateField(
                          selectedTanggalPenyelesaian,
                          () => _selectDate(
                            context,
                            (date) => setState(
                              () => selectedTanggalPenyelesaian = date,
                            ),
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
                          keyboardType: TextInputType.text,
                          inputFormatters: [
                            FilteringTextInputFormatter.deny(RegExp(r'[0-9]')),
                          ],
                          onChanged:
                              (val) => setState(() {
                                selectedNamaPIC = val;
                                namaPICLength = val.length;
                              }),
                          validator:
                              (v) =>
                                  v == null || v.isEmpty
                                      ? 'Nama PIC wajib diisi'
                                      : null,
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
                          validator:
                              (v) =>
                                  v == null || v.isEmpty
                                      ? 'Tema diskusi wajib diisi'
                                      : null,
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
                                problem = val;
                                problemLength = val.length;
                              }),
                          validator:
                              (v) =>
                                  v == null || v.isEmpty
                                      ? 'Problem wajib diisi'
                                      : null,
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
                                followUp = val;
                                followUpLength = val.length;
                              }),
                          validator:
                              (v) =>
                                  v == null || v.isEmpty
                                      ? 'Follow-Up wajib diisi'
                                      : null,
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
                                description = val;
                                descriptionLength = val.length;
                              }),
                          validator:
                              (v) =>
                                  v == null || v.isEmpty
                                      ? 'Deskripsi wajib diisi'
                                      : null,
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
                                ),
                                items: _buildJabatanDropdownItems(),

                                onChanged:
                                    (v) => setState(() {
                                      selectedJabatan = v;
                                    }),
                                validator:
                                    (v) =>
                                        v == null
                                            ? 'Harap Pilih Jabatan'
                                            : null,
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
                                  FilteringTextInputFormatter.deny(
                                    RegExp(r'[0-9]'),
                                  ),
                                ],
                                onChanged: (_) => setState(() {}),
                                validator:
                                    (v) =>
                                        (v == null || v.isEmpty)
                                            ? 'Nama wajib diisi'
                                            : null,
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
                                  if (phone != null &&
                                      phone.number.isNotEmpty &&
                                      phone.number.length >= 6) {
                                    selectedMainTelp = phone.completeNumber;
                                  } else {
                                    selectedMainTelp = null;
                                  }
                                },
                                validator: (phone) {
                                  if (phone == null || phone.number.isEmpty)
                                    return 'Nomor telepon wajib diisi';
                                  final number = phone.number;
                                  if (number.length < 6)
                                    return 'Nomor telepon tidak valid';
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
                                    style: TextStyle(
                                      color: textButton,
                                      fontSize: 16,
                                    ),
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
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: SingleChildScrollView(
                                          physics:
                                              const BouncingScrollPhysics(),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
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
                                              builder:
                                                  (context) => AlertDialog(
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            12,
                                                          ),
                                                    ),
                                                    title: Text(
                                                      'Konfirmasi Hapus',
                                                      style: TextStyle(
                                                        color: headerBlue,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                    content: Text(
                                                      'Apakah Anda yakin ingin menghapus ${pic['nama']} dari daftar PIC?',
                                                      style: const TextStyle(
                                                        color: textButton,
                                                      ),
                                                    ),
                                                    actions: [
                                                      TextButton(
                                                        onPressed:
                                                            () => Navigator.pop(
                                                              context,
                                                            ),
                                                        child: Text(
                                                          'Batal',
                                                          style: TextStyle(
                                                            color: textButton,
                                                          ),
                                                        ),
                                                      ),
                                                      TextButton(
                                                        onPressed: () {
                                                          _removeMainPerson(i);
                                                          Navigator.pop(
                                                            context,
                                                          );
                                                        },
                                                        child: const Text(
                                                          'Hapus',
                                                          style: TextStyle(
                                                            color: Colors.red,
                                                          ),
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

                // Photo Upload Section
                _photoRow(first: true, file: _photo1),
                const SizedBox(height: 16),
                _photoRow(first: false, file: _photo2),
                const SizedBox(height: 16),
                _photoPreviewSection(),

                const SizedBox(height: 24),

                // Location Section
                if (isLoadingLocation)
                  const Center(child: CircularProgressIndicator())
                else
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: textButton),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    icon: const Icon(Icons.location_on, color: Colors.blue),
                    label: const Text(
                      'Ambil Lokasi',
                      style: TextStyle(color: Colors.blue, fontSize: 16),
                    ),
                    onPressed: _updateLocation,
                  ),
                const SizedBox(height: 12),

                // Location Display
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.location_on, color: Colors.blue, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Informasi Lokasi',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: dropdownLight,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Latitude',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: dropdownLight,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  selectedLatitude != null
                                      ? selectedLatitude!.toStringAsFixed(6)
                                      : 'Belum diambil',
                                  style: TextStyle(
                                    color:
                                        selectedLatitude != null
                                            ? Colors.green.shade700
                                            : Colors.grey.shade600,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Longitude',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: dropdownLight,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  selectedLongitude != null
                                      ? selectedLongitude!.toStringAsFixed(6)
                                      : 'Belum diambil',
                                  style: TextStyle(
                                    color:
                                        selectedLongitude != null
                                            ? Colors.green.shade700
                                            : Colors.grey.shade600,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      // TAMBAHAN STATUS DI SINI
                      const SizedBox(height: 16),
                      Divider(color: Colors.grey.shade300, thickness: 1),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Icon(Icons.flag, color: Colors.blue, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Status Visit',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: dropdownLight,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        isExpanded: true,
                        value: selectedStatus,
                        hint: Text(
                          '-- Pilih Status --',
                          style: TextStyle(color: dropdownLight),
                        ),
                        icon: const Icon(Icons.expand_more),
                        iconEnabledColor: dropdownLight,
                        style: const TextStyle(color: dropdownLight),
                        decoration: InputDecoration(
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: dropdownLightNF,
                              width: 1.0,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: dropdownLightF,
                              width: 2.0,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 16,
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        items: _buildStatusDropdownItems(),
                        onChanged:
                            (val) => setState(() {
                              selectedStatus = val;
                              _hasInteractWithStatus = true;
                            }),
                        onTap: () {
                          setState(() {
                            _hasInteractWithStatus = true;
                          });
                        },
                        validator:
                            (v) =>
                                _hasInteractWithStatus && v == null
                                    ? 'Harap Pilih Status'
                                    : null,
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color:
                              selectedStatus == 'Planning'
                                  ? Colors.orange.shade50
                                  : selectedStatus == 'Selesai'
                                  ? Colors.green.shade50
                                  : Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color:
                                selectedStatus == 'Planning'
                                    ? Colors.orange.shade200
                                    : selectedStatus == 'Selesai'
                                    ? Colors.green.shade200
                                    : Colors.grey.shade200,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              selectedStatus == 'Planning'
                                  ? Icons.schedule
                                  : selectedStatus == 'Selesai'
                                  ? Icons.check_circle
                                  : Icons.help_outline,
                              size: 16,
                              color:
                                  selectedStatus == 'Planning'
                                      ? Colors.orange.shade600
                                      : selectedStatus == 'Selesai'
                                      ? Colors.green.shade600
                                      : Colors.grey.shade600,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              selectedStatus == 'Planning'
                                  ? 'Status: Planning'
                                  : selectedStatus == 'Selesai'
                                  ? 'Status: Selesai'
                                  : 'Status: Belum dipilih',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color:
                                    selectedStatus == 'Planning'
                                        ? Colors.orange.shade700
                                        : selectedStatus == 'Selesai'
                                        ? Colors.green.shade700
                                        : Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Submit Button
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: headerBlue,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    textStyle: const TextStyle(fontSize: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: isSubmitting ? null : _submitForm,
                  child:
                      isSubmitting
                          ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                              strokeWidth: 2,
                            ),
                          )
                          : const Text(
                            'Submit Direct Visit',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                ),
                const SizedBox(height: 16),
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
  State<StatefulWidget> createState() => _DirectVisitState();
}
