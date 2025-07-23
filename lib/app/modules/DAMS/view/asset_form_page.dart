import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:sufi_one/app/modules/DAMS/controller/scan_controller.dart';
import 'package:sufi_one/app/modules/DAMS/dams_route.dart';
import 'package:sufi_one/app/modules/DAMS/model/asset.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sufi_one/app/modules/DAMS/model/divisi_user.dart';
import 'package:sufi_one/app/modules/DAMS/model/kondisi_asset.dart';
import 'package:sufi_one/app/modules/DAMS/model/lantai_user.dart';
import 'package:sufi_one/app/modules/DAMS/model/lokasi_user.dart';
import 'package:sufi_one/app/modules/DAMS/model/posisi_user.dart';
import 'package:sufi_one/app/modules/DAMS/model/status_asset.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:sufi_one/app/modules/DAMS/model/status_user_asset.dart';
import 'package:sufi_one/app/modules/DAMS/repository/divisi_user_repository.dart';
import 'package:sufi_one/app/modules/DAMS/repository/kondisi_asset_repository.dart';
import 'package:sufi_one/app/modules/DAMS/repository/lantai_user_repository.dart';
import 'package:sufi_one/app/modules/DAMS/repository/lokasi_user_repository.dart';
import 'package:sufi_one/app/modules/DAMS/repository/posisi_user_repository.dart';
import 'package:sufi_one/app/modules/DAMS/repository/status_asset_repository.dart';
import 'package:sufi_one/app/modules/DAMS/repository/status_user_asset_repository.dart';

class AssetFormPage extends StatefulWidget {
  final String kodeAset;
  final Asset? initialAsset;

  const AssetFormPage({super.key, required this.kodeAset, this.initialAsset});

  @override
  State<AssetFormPage> createState() => _AssetFormPageState();
}

class _AssetFormPageState extends State<AssetFormPage> {
  final ScanController _scanController = Get.find();
  late Future<Asset> _futureAsset;

  String? _errorMessage;
  Asset? _editedAsset;
  AssetDetail? _editedAssetDetail;
  bool _isLoading = false;
  bool _isSaving = false;
  bool _hasLoaded = false;
  bool isPhoto1Uploaded = false;
  File? _photo1;
  String? _photo1Url;

  late Future<List<StatusAsset>> _statusAssetFuture;
  late Future<List<KondisiAsset>> _kondisiAssetFuture;
  late Future<List<StatusUserAsset>> _statusUserAssetFuture;
  late Future<List<PosisiUser>> _posisiUserFuture;
  late Future<List<DivisiUser>> _divisiUserFuture;
  late Future<List<LokasiUser>> _lokasiUserFuture;
  late Future<List<LantaiUser>> _lantaiUserFuture;

  final _formKey = GlobalKey<FormState>();
  final _namaAssetController = TextEditingController();
  final _tanggalBeliController = TextEditingController();
  final _hargaBeliController = TextEditingController();
  final _nilaiBukuController = TextEditingController();
  final _namaUserAssetController = TextEditingController();
  final _keteranganController = TextEditingController();
  final _lokasiController = TextEditingController();
  final _branchIdController = TextEditingController();
  final _personalLocController = TextEditingController();
  final _deptController = TextEditingController();
  final _roomController = TextEditingController();
  final _floorController = TextEditingController();
  final _groupController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  static const Color textButton = Color(0xFF8BADCA);
  static const Color headerBlue = Color(0xFF1521A4);

  List<String> _statusOptions = [];
  String? _selectedStatus;

  List<String> _conditionOptions = [];
  String? _selectedCondition;

  List<String> _statusUserAssetOptions = [];
  String? _selectedStatusUserAsset;

  List<String> _posisiUserOptions = [];
  String? _selectedPosisiUser;

  List<String> _divisiUserOptions = [];
  String? _selectedDivisiUser;

  List<String> _lokasiUserOptions = [];
  String? _selectedLokasiUser;

  List<String> _lantaiUserOptions = [];
  String? _selectedLantaiUser;

  @override
  void initState() {
    super.initState();
    if (!_hasLoaded) {
      if (widget.initialAsset != null) {
        _editedAsset = widget.initialAsset;
        _futureAsset = Future.value(widget.initialAsset);
        _initializeControllers(widget.initialAsset!);
      } else {
        _futureAsset = _fetchAssetData();
      }

      _loadStatusAsset();
      _loadKondisiAsset();
      _loadStatusUserAsset();
      _loadPosisiUser();
      _loadDivisiUser();
      _loadLokasiUser();
      _loadLantaiUser();

      _hasLoaded = true;
    }
  }

  Future<void> _loadStatusAsset() async {
    final repository = Provider.of<StatusAssetRepository>(
      context,
      listen: false,
    );
    try {
      final localData = await repository.dbHelper.getAllStatusAsset();
      if (!mounted) return;
      setState(() {
        _statusAssetFuture = Future.value(localData);
        _statusOptions = localData.map((e) => e.name ?? '-').toSet().toList();
        if (_editedAsset?.detail?.status != null &&
            _statusOptions.contains(_editedAsset!.detail!.status)) {
          _selectedStatus = _editedAsset!.detail!.status;
        }
        _isLoading = false;
        _errorMessage =
            localData.isEmpty ? 'Data status asset kosong (offline)' : null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Gagal memuat data status asset: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _loadKondisiAsset() async {
    final repository = Provider.of<KondisiAssetRepository>(
      context,
      listen: false,
    );
    try {
      final localData = await repository.dbHelper.getAllKondisiAsset();
      if (!mounted) return;
      setState(() {
        _kondisiAssetFuture = Future.value(localData);
        _conditionOptions =
            localData.map((e) => e.name ?? '-').toSet().toList();
        if (_editedAsset?.detail?.condition != null &&
            _conditionOptions.contains(_editedAsset!.detail!.condition)) {
          _selectedCondition = _editedAsset!.detail!.condition;
        }
        _isLoading = false;
        _errorMessage =
            localData.isEmpty ? 'Data kondisi asset kosong (offline)' : null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Gagal memuat data kondisi asset: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _loadStatusUserAsset() async {
    final repository = Provider.of<StatusUserAssetRepository>(
      context,
      listen: false,
    );
    try {
      final localData = await repository.dbHelper.getAllStatusUserAsset();
      if (!mounted) return;
      setState(() {
        _statusUserAssetFuture = Future.value(localData);
        _statusUserAssetOptions =
            localData.map((e) => e.name ?? '-').toSet().toList();
        if (_editedAsset?.detail?.username != null &&
            _statusUserAssetOptions.contains(_editedAsset!.detail!.username)) {
          _selectedStatusUserAsset = _editedAsset!.detail!.username;
        }
        _isLoading = false;
        _errorMessage =
            localData.isEmpty
                ? 'Data status user asset kosong (offline)'
                : null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Gagal memuat data status user asset: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _loadPosisiUser() async {
    final repository = Provider.of<PosisiUserRepository>(
      context,
      listen: false,
    );
    try {
      final localData = await repository.dbHelper.getAllPosisiUser();
      if (!mounted) return;
      setState(() {
        _posisiUserFuture = Future.value(localData);
        _posisiUserOptions =
            localData.map((e) => e.name ?? '-').toSet().toList();
        if (_editedAsset?.detail?.position != null &&
            _posisiUserOptions.contains(_editedAsset!.detail!.position)) {
          _selectedPosisiUser = _editedAsset!.detail!.position;
        }
        _isLoading = false;
        _errorMessage =
            localData.isEmpty ? 'Data posisi user kosong (offline)' : null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Gagal memuat data posisi user: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _loadDivisiUser() async {
    final repository = Provider.of<DivisiUserRepository>(
      context,
      listen: false,
    );
    try {
      final localData = await repository.dbHelper.getAllDivisiUser();
      if (!mounted) return;
      setState(() {
        _divisiUserFuture = Future.value(localData);
        _divisiUserOptions =
            localData.map((e) => e.name ?? '-').toSet().toList();
        if (_editedAsset?.branchName != null &&
            _divisiUserOptions.contains(_editedAsset!.branchName)) {
          _selectedDivisiUser = _editedAsset!.branchName;
        }
        _isLoading = false;
        _errorMessage =
            localData.isEmpty ? 'Data divisi kosong (offline)' : null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Gagal memuat data divisi user: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _loadLokasiUser() async {
    final repository = Provider.of<LokasiUserRepository>(
      context,
      listen: false,
    );
    try {
      final localData = await repository.dbHelper.getAllLokasiUser();
      if (!mounted) return;
      setState(() {
        _lokasiUserFuture = Future.value(localData);
        _lokasiUserOptions =
            localData.map((e) => e.name ?? '-').toSet().toList();
        if (_editedAsset?.detail?.locRoom != null &&
            _lokasiUserOptions.contains(_editedAsset!.detail!.locRoom)) {
          _selectedLokasiUser = _editedAsset!.detail!.locRoom;
        }
        _isLoading = false;
        _errorMessage =
            localData.isEmpty ? 'Data lokasi user kosong (offline)' : null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Gagal memuat data lokasi user: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _loadLantaiUser() async {
    final repository = Provider.of<LantaiUserRepository>(
      context,
      listen: false,
    );
    try {
      final localData = await repository.dbHelper.getAllLantaiUser();
      if (!mounted) return;
      setState(() {
        _lantaiUserFuture = Future.value(localData);
        _lantaiUserOptions =
            localData.map((e) => e.name ?? '-').toSet().toList();
        if (_editedAsset?.floor != null &&
            _lantaiUserOptions.contains(_editedAsset!.floor)) {
          _selectedLantaiUser = _editedAsset!.floor;
        }
        _isLoading = false;
        _errorMessage =
            localData.isEmpty ? 'Data lantai kosong (offline)' : null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Gagal memuat data lantai: $e';
        _isLoading = false;
      });
    }
  }

  Future<Asset> _fetchAssetData() async {
    try {
      final asset = await _scanController.getAssetByKodeAset(widget.kodeAset);
      _initializeControllers(asset);
      setState(() {
        _editedAsset = asset;
        _photo1Url = asset.detail?.imageUrl;
        if (_photo1Url != null && _photo1Url!.isNotEmpty) {
          isPhoto1Uploaded = true;
        }
      });
      return asset;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load asset data: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      rethrow;
    }
  }

  void _initializeControllers(Asset asset) {
    _editedAsset = asset;
    _editedAssetDetail = asset.detail;

    _namaAssetController.text = asset.detail?.item ?? '';
    _tanggalBeliController.text =
        asset.detail?.tanggalPembelian != null
            ? DateFormat('dd/MM/yyyy').format(asset.detail!.tanggalPembelian!)
            : '';
    _hargaBeliController.text =
        asset.detail?.costAc != null
            ? _formatCurrency(double.tryParse(asset.detail!.costAc!) ?? 0)
            : '';
    _nilaiBukuController.text =
        asset.detail?.bokVal != null
            ? _formatCurrency(double.tryParse(asset.detail!.bokVal!) ?? 0)
            : '';
    _namaUserAssetController.text = asset.detail?.username ?? '';
    _keteranganController.text = asset.detail?.addRemark ?? '';
    _lokasiController.text = asset.lokasi ?? '';
    _branchIdController.text = asset.branchId ?? '';
    _personalLocController.text = asset.personalLoc ?? '';
    _deptController.text = asset.dept ?? '';
    _roomController.text = asset.room ?? '';
    _floorController.text = asset.floor ?? '';
    _groupController.text = asset.detail?.group ?? '';

    _selectedStatus = asset.detail?.status;
    _selectedStatusUserAsset = asset.detail?.username;
    _selectedCondition = asset.detail?.condition;
    _selectedDivisiUser = asset.division;
    _selectedPosisiUser = asset.detail?.position;
    _selectedLokasiUser = asset.detail?.locRoom;
    _selectedLantaiUser = asset.floor;
  }

  String _formatCurrency(double amount) {
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(amount);
  }

  double? _parseCurrency(String value) {
    if (value.isEmpty) return null;
    try {
      String numStr = value.replaceAll(RegExp(r'[^0-9]'), '');
      return double.tryParse(numStr);
    } catch (e) {
      return null;
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _editedAssetDetail?.tanggalPembelian ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (picked != null) {
      setState(() {
        _tanggalBeliController.text = DateFormat('dd/MM/yyyy').format(picked);
        _editedAssetDetail = _editedAssetDetail?.copyWith(
          tanggalPembelian: picked,
        );
      });
    }
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate() || _editedAsset == null) return;

    setState(() => _isSaving = true);

    try {
      String? uploadedPhotoUrl = _photo1Url;
      // if (_photo1 != null) {
      //   final request = http.MultipartRequest(
      //     'POST',
      //     Uri.parse(
      //       'http://your-api-url/api/direct-visits/${widget.kodeAset}/photo',
      //     ),
      //   );
      //   request.files.add(
      //     await http.MultipartFile.fromPath(
      //       'photo1',
      //       _photo1!.path,
      //       filename: path.basename(_photo1!.path),
      //     ),
      //   );

      //   final response = await request.send();
      //   if (response.statusCode == 200 || response.statusCode == 201) {
      //     final responseData = await response.stream.bytesToString();
      //     uploadedPhotoUrl =
      //         jsonDecode(responseData)['photo_url'] ?? _photo1Url;
      //   } else {
      //     throw Exception('Failed to upload photo: ${response.statusCode}');
      //   }
      // }

      final updatedAsset = _editedAsset!.copyWith(
        division: _selectedDivisiUser ?? _editedAsset!.division,
        floor: _selectedLantaiUser ?? _editedAsset!.floor,
        lokasi: _selectedLantaiUser ?? _editedAsset!.lokasi,
        // lokasi:
        //     _lokasiController.text.isNotEmpty
        //         ? _lokasiController.text
        //         : _editedAsset!.lokasi,
        branchId:
            _branchIdController.text.isNotEmpty
                ? _branchIdController.text
                : _editedAsset!.branchId,
        personalLoc:
            _personalLocController.text.isNotEmpty
                ? _personalLocController.text
                : _editedAsset!.personalLoc,
        dept:
            _deptController.text.isNotEmpty
                ? _deptController.text
                : _editedAsset!.dept,
        room:
            _roomController.text.isNotEmpty
                ? _roomController.text
                : _editedAsset!.room,
        lastUpdate: DateTime.now(),
      );

      final updatedDetail = _editedAssetDetail!.copyWith(
        item:
            _namaAssetController.text.isNotEmpty
                ? _namaAssetController.text
                : _editedAssetDetail!.item,
        tanggalPembelian:
            _tanggalBeliController.text.isNotEmpty
                ? DateFormat('dd/MM/yyyy').parse(_tanggalBeliController.text)
                : _editedAssetDetail!.tanggalPembelian,
        costAc:
            _hargaBeliController.text.isNotEmpty
                ? _parseCurrency(_hargaBeliController.text)?.toString() ??
                    _editedAssetDetail!.costAc
                : _editedAssetDetail!.costAc,
        bokVal:
            _nilaiBukuController.text.isNotEmpty
                ? _parseCurrency(_nilaiBukuController.text)?.toString() ??
                    _editedAssetDetail!.bokVal
                : _editedAssetDetail!.bokVal,
        username: _selectedStatusUserAsset ?? _editedAssetDetail!.username,
        addRemark:
            _keteranganController.text.isNotEmpty
                ? _keteranganController.text
                : _editedAssetDetail!.addRemark,
        status: _selectedStatus ?? _editedAssetDetail!.status,
        condition: _selectedCondition ?? _editedAssetDetail!.condition,
        position: _selectedPosisiUser ?? _editedAssetDetail!.position,
        locRoom: _selectedLokasiUser ?? _editedAssetDetail!.locRoom,
        group:
            _groupController.text.isNotEmpty
                ? _groupController.text
                : _editedAssetDetail!.group,
        //imageUrl: uploadedPhotoUrl ?? _editedAssetDetail!.imageUrl,
        lastUpdate: DateTime.now(),
      );

      await _scanController.updateAssetAndDetail(
        updatedAsset,
        updatedDetail,
        _photo1,
      );

      if (mounted) {
        Get.back();
        Get.snackbar(
          'Success',
          'Asset updated successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      if (mounted) {
        Get.snackbar(
          'Error',
          'Failed to save changes: ${e.toString()}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Asset: ${widget.kodeAset}'),
        backgroundColor: headerBlue,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.offAllNamed(DamsRoute.homePage),
        ),
        actions: [
          IconButton(
            icon:
                _isSaving
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Icon(Icons.save),
            onPressed: _isSaving ? null : _saveChanges,
          ),
        ],
      ),
      body: FutureBuilder<Asset>(
        future: _futureAsset,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'Failed to load asset data',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(snapshot.error.toString(), textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _futureAsset = _fetchAssetData();
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: headerBlue,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          } else if (snapshot.hasData) {
            return _buildForm();
          } else {
            return const Center(child: Text('No asset data available'));
          }
        },
      ),
    );
  }

  Widget _buildForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [_buildDamsSection(), const SizedBox(height: 16)],
        ),
      ),
    );
  }

  Widget _buildDamsSection() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'DAMS',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: headerBlue,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _namaAssetController,
              decoration: InputDecoration(
                labelText: 'Nama Asset',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Masukkan nama asset';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _tanggalBeliController,
              validator: (value) {
                if (value!.isNotEmpty) {
                  try {
                    final date = DateFormat('dd/MM/yyyy').parse(value);
                    if (date.isAfter(DateTime.now())) {
                      return 'Tanggal tidak boleh melebihi hari ini';
                    }
                  } catch (e) {
                    return 'Format tanggal tidak valid';
                  }
                }
                return null;
              },
              decoration: InputDecoration(
                labelText: 'Tanggal Beli',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                suffixIcon: const Icon(Icons.calendar_today),
                filled: true,
                fillColor: Colors.grey[100],
              ),
              readOnly: true,
              onTap: () => _selectDate(context),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _hargaBeliController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Harga Beli',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Masukkan harga beli';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nilaiBukuController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Nilai Buku',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _namaUserAssetController,
              decoration: InputDecoration(
                labelText: 'Nama User Asset',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _keteranganController,
              decoration: InputDecoration(
                labelText: 'Keterangan',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Masukkan keterangan';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value:
                  _statusOptions.contains(_selectedStatus)
                      ? _selectedStatus
                      : null,
              items:
                  _statusOptions.map((status) {
                    return DropdownMenuItem<String>(
                      value: status,
                      child: Text(status),
                    );
                  }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedStatus = value;
                });
              },
              decoration: InputDecoration(
                labelText: 'Status Asset',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
              validator: (value) {
                if (value == null || !_statusOptions.contains(value)) {
                  return 'Pilih status asset yang valid';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value:
                  _conditionOptions.contains(_selectedCondition)
                      ? _selectedCondition
                      : null,
              items:
                  _conditionOptions.map((condition) {
                    return DropdownMenuItem<String>(
                      value: condition,
                      child: Text(condition),
                    );
                  }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCondition = value;
                });
              },
              decoration: InputDecoration(
                labelText: 'Kondisi Asset',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
              validator: (value) {
                if (value == null || !_conditionOptions.contains(value)) {
                  return 'Pilih kondisi asset yang valid';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value:
                  _statusUserAssetOptions.contains(_selectedStatusUserAsset)
                      ? _selectedStatusUserAsset
                      : null,
              items:
                  _statusUserAssetOptions.map((statusUserAsset) {
                    return DropdownMenuItem<String>(
                      value: statusUserAsset,
                      child: Text(statusUserAsset),
                    );
                  }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedStatusUserAsset = value;
                  _namaUserAssetController.text = value ?? '';
                });
              },
              decoration: InputDecoration(
                labelText: 'Status User Asset',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
              validator: (value) {
                if (value == null || !_statusUserAssetOptions.contains(value)) {
                  return 'Pilih status user asset yang valid';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value:
                  _posisiUserOptions.contains(_selectedPosisiUser)
                      ? _selectedPosisiUser
                      : null,
              items:
                  _posisiUserOptions.map((posisiUser) {
                    return DropdownMenuItem<String>(
                      value: posisiUser,
                      child: Text(posisiUser),
                    );
                  }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedPosisiUser = value;
                });
              },
              decoration: InputDecoration(
                labelText: 'Posisi User',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
              validator: (value) {
                if (value == null || !_posisiUserOptions.contains(value)) {
                  return 'Pilih posisi user yang valid';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value:
                  _divisiUserOptions.contains(_selectedDivisiUser)
                      ? _selectedDivisiUser
                      : null,
              items:
                  _divisiUserOptions.map((divisiUser) {
                    return DropdownMenuItem<String>(
                      value: divisiUser,
                      child: Text(divisiUser),
                    );
                  }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedDivisiUser = value;
                });
              },
              decoration: InputDecoration(
                labelText: 'Divisi User',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
              validator: (value) {
                if (value == null || !_divisiUserOptions.contains(value)) {
                  return 'Pilih divisi user yang valid';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value:
                  _lokasiUserOptions.contains(_selectedLokasiUser)
                      ? _selectedLokasiUser
                      : null,
              items:
                  _lokasiUserOptions.map((lokasiUser) {
                    return DropdownMenuItem<String>(
                      value: lokasiUser,
                      child: Text(lokasiUser),
                    );
                  }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedLokasiUser = value;
                });
              },
              decoration: InputDecoration(
                labelText: 'Lokasi User',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
              validator: (value) {
                if (value == null || !_lokasiUserOptions.contains(value)) {
                  return 'Pilih lokasi user yang valid';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value:
                  _lantaiUserOptions.contains(_selectedLantaiUser)
                      ? _selectedLantaiUser
                      : null,
              items:
                  _lantaiUserOptions.map((lantaiUser) {
                    return DropdownMenuItem<String>(
                      value: lantaiUser,
                      child: Text(lantaiUser),
                    );
                  }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedLantaiUser = value;
                });
              },
              decoration: InputDecoration(
                labelText: 'Lantai User',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
              validator: (value) {
                if (value == null || !_lantaiUserOptions.contains(value)) {
                  return 'Pilih lantai user yang valid';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            Card(
              color: const Color(0xFFFDFDFF),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 24,
                  horizontal: 16,
                ),
                child: Column(
                  children: [
                    Text(
                      'Upload Foto',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: headerBlue,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _photoRow(first: true, file: _photo1),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            _photoPreviewSection(),
          ],
        ),
      ),
    );
  }

  Widget _photoRow({required bool first, File? file}) {
    return Column(
      children: [
        Text(
          file == null && _photo1Url == null ? 'Pilih Foto' : 'Foto Terunggah',
          style: TextStyle(
            color: headerBlue,
            fontSize: 16,
            fontWeight:
                (file != null || _photo1Url != null)
                    ? FontWeight.bold
                    : FontWeight.normal,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _iconButton(
              icon: Icons.camera_alt,
              onTap: () => _pickPhoto(first: true, src: ImageSource.camera),
              borderColor: textButton,
              iconColor: const Color(0xFFCE3970),
              bgColor: Colors.white,
            ),
            _iconButton(
              icon: Icons.folder,
              onTap: () => _pickPhoto(first: true, src: ImageSource.gallery),
              borderColor: textButton,
              iconColor: const Color(0xFFFDBF12),
              bgColor: Colors.white,
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _pickPhoto({
    required bool first,
    required ImageSource src,
  }) async {
    try {
      final XFile? f = await _picker.pickImage(
        source: src,
        maxWidth: 800,
        maxHeight: 800,
      );
      if (f == null) return;
      setState(() {
        _photo1 = File(f.path);
        isPhoto1Uploaded = true;
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal mengambil foto: $e')));
    }
  }

  Widget _photoPreviewSection() {
    Widget imageWidget;
    if (_photo1 != null) {
      imageWidget = Image.file(
        _photo1!,
        fit: BoxFit.cover,
        height: 350,
        width: double.infinity,
      );
    } else if (_photo1Url != null && _photo1Url!.isNotEmpty) {
      imageWidget = Image.network(
        _photo1Url!,
        fit: BoxFit.cover,
        height: 350,
        width: double.infinity,
        errorBuilder:
            (context, error, stackTrace) =>
                const Icon(Icons.broken_image, size: 100, color: Colors.grey),
      );
    } else {
      return const SizedBox.shrink();
    }

    return Card(
      color: const Color(0xFFFDFDFF),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              'Preview Foto',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: headerBlue,
              ),
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () => _showFullScreenImage(context, _photo1, _photo1Url),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Stack(
                  children: [
                    imageWidget,
                    Positioned(
                      right: 10,
                      bottom: 10,
                      child: IconButton(
                        icon: Icon(
                          Icons.fullscreen,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              blurRadius: 4.0,
                              color: Colors.black.withOpacity(0.5),
                              offset: const Offset(2, 2),
                            ),
                          ],
                        ),
                        onPressed:
                            () => _showFullScreenImage(
                              context,
                              _photo1,
                              _photo1Url,
                            ),
                      ),
                    ),
                  ],
                ),
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
                  label: const Text("Retake"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: headerBlue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed:
                      () => _pickPhoto(first: true, src: ImageSource.gallery),
                  icon: const Icon(Icons.photo, color: Colors.white),
                  label: const Text("Browse"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: headerBlue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showFullScreenImage(
    BuildContext context,
    File? photo,
    String? photoUrl,
  ) {
    Widget imageWidget;
    if (photo != null) {
      imageWidget = Image.file(photo);
    } else if (photoUrl != null && photoUrl.isNotEmpty) {
      imageWidget = Image.network(
        photoUrl,
        errorBuilder:
            (context, error, stackTrace) =>
                const Icon(Icons.broken_image, size: 100, color: Colors.grey),
      );
    } else {
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (_) => Scaffold(
              backgroundColor: Colors.black,
              body: Stack(
                children: [
                  Center(child: InteractiveViewer(child: imageWidget)),
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

  @override
  void dispose() {
    _namaAssetController.dispose();
    _tanggalBeliController.dispose();
    _hargaBeliController.dispose();
    _nilaiBukuController.dispose();
    _namaUserAssetController.dispose();
    _keteranganController.dispose();
    _lokasiController.dispose();
    _branchIdController.dispose();
    _personalLocController.dispose();
    _deptController.dispose();
    _roomController.dispose();
    _floorController.dispose();
    _groupController.dispose();
    super.dispose();
  }
}
