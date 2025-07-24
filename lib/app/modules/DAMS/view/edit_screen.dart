import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:sufi_one/app/modules/DAMS/controller/history_controller.dart';
import 'package:sufi_one/app/modules/DAMS/model/asset.dart';
import 'package:sufi_one/app/modules/DAMS/model/divisi_user.dart';
import 'package:sufi_one/app/modules/DAMS/model/kondisi_asset.dart';
import 'package:sufi_one/app/modules/DAMS/model/lantai_user.dart';
import 'package:sufi_one/app/modules/DAMS/model/lokasi_user.dart';
import 'package:sufi_one/app/modules/DAMS/model/posisi_user.dart';
import 'package:sufi_one/app/modules/DAMS/model/status_asset.dart';
import 'package:sufi_one/app/modules/DAMS/model/status_user_asset.dart';
import 'package:sufi_one/app/modules/DAMS/repository/divisi_user_repository.dart';
import 'package:sufi_one/app/modules/DAMS/repository/kondisi_asset_repository.dart';
import 'package:sufi_one/app/modules/DAMS/repository/lantai_user_repository.dart';
import 'package:sufi_one/app/modules/DAMS/repository/lokasi_user_repository.dart';
import 'package:sufi_one/app/modules/DAMS/repository/posisi_user_repository.dart';
import 'package:sufi_one/app/modules/DAMS/repository/status_asset_repository.dart';
import 'package:sufi_one/app/modules/DAMS/repository/status_user_asset_repository.dart';

class EditScreen extends StatefulWidget {
  final String assetId;
  final Map<String, dynamic> initialData;
  static const Color headerBlue = Color(0xFF1521A4);

  const EditScreen({Key? key, required this.assetId, required this.initialData})
    : super(key: key);

  @override
  _EditScreenState createState() => _EditScreenState();
}

class _EditScreenState extends State<EditScreen> {
  final _formKey = GlobalKey<FormState>();
  final HistoryController _controller = Get.find();
  bool _isLoading = false;
  bool _isSaving = false;
  String? _errorMessage;

  Asset? _editedAsset;
  AssetDetail? _editedAssetDetail;
  // Controllers
  final _trxNoController = TextEditingController();
  final _userController = TextEditingController();
  final _costController = TextEditingController();
  final _bookValueController = TextEditingController();
  final _positionController = TextEditingController();
  final _divisionController = TextEditingController();
  final _locationController = TextEditingController();
  final _floorController = TextEditingController();
  final _remarkController = TextEditingController();
  final _dateController = TextEditingController();

  late Future<List<StatusAsset>> _statusAssetFuture;
  late Future<List<KondisiAsset>> _kondisiAssetFuture;
  late Future<List<StatusUserAsset>> _statusUserAssetFuture;
  late Future<List<PosisiUser>> _posisiUserFuture;
  late Future<List<DivisiUser>> _divisiUserFuture;
  late Future<List<LokasiUser>> _lokasiUserFuture;
  late Future<List<LantaiUser>> _lantaiUserFuture;

  // Dropdown options
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
    print('Initial data: ${widget.initialData}'); // Debug initial data
    _initializeFormData();
    if (!_isLoading) {
      // Initialize _editedAsset from initialData if needed
      _editedAsset = Asset.fromJson(
        widget.initialData,
      ); // Adjust based on Asset model
      _loadStatusAsset();
      _loadKondisiAsset();
      _loadStatusUserAsset();
      _loadPosisiUser();
      _loadDivisiUser();
      _loadLokasiUser();
      _loadLantaiUser();
    }
  }

  void _initializeFormData() {
    _trxNoController.text = widget.initialData['trx_no'] ?? '';
    _userController.text = widget.initialData['username'] ?? '';
    _costController.text = widget.initialData['cost']?.toString() ?? '';
    _bookValueController.text =
        widget.initialData['book_value']?.toString() ?? '';
    _positionController.text = widget.initialData['posisi'] ?? '';
    _divisionController.text = widget.initialData['divisi'] ?? '';
    _locationController.text = widget.initialData['lokasi'] ?? '';
    _floorController.text = widget.initialData['lantai'] ?? '';
    _remarkController.text = widget.initialData['remark'] ?? '';
    _selectedStatus = widget.initialData['status'];
    _selectedCondition = widget.initialData['kondisi'];
    _selectedDivisiUser = widget.initialData['divisi'];
    _selectedPosisiUser = widget.initialData['posisi'];
    _selectedLokasiUser = widget.initialData['lokasi'];
    _selectedLantaiUser = widget.initialData['lantai'];
    if (widget.initialData['crdt'] != null) {
      _dateController.text = _formatDate(widget.initialData['crdt']);
    }
  }

  String _formatDate(dynamic date) {
    if (date == null) return '';
    if (date is String) {
      try {
        final parsedDate = DateTime.parse(date);
        return DateFormat('dd/MM/yyyy').format(parsedDate);
      } catch (e) {
        return date;
      }
    } else if (date is DateTime) {
      return DateFormat('dd/MM/yyyy').format(date);
    }
    return date.toString();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _dateController.text = DateFormat('dd/MM/yyyy').format(picked);
      });
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

      // Ambil semua nama divisi dari DB
      final loadedOptions =
          localData.map((e) => e.name ?? '-').toSet().toList();

      // Debug semua data yang masuk ke list dropdown
      print('>>> [DEBUG] _divisiUserOptions loaded from DB:');
      for (var item in loadedOptions) {
        print('- "$item"');
      }

      // Debug branch name dari asset yang sedang diedit
      print(
        '>>> [DEBUG] _editedAsset.branchName: "${_editedAsset?.branchName}"',
      );

      // Coba cocokkan secara manual (abaikan huruf besar kecil dan spasi)
      String? matched;
      if (_editedAsset?.branchName != null) {
        matched = loadedOptions.firstWhere(
          (e) =>
              e.trim().toLowerCase() ==
              _editedAsset!.branchName!.trim().toLowerCase(),
          orElse: () => '',
        );
        if (matched.isEmpty) {
          print(
            '>>> [WARNING] Tidak ada match yang cocok untuk _editedAsset.branchName.',
          );
        } else {
          print('>>> [DEBUG] Match ditemukan: "$matched"');
        }
      }

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

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final updateData = {
        'KODE_ASET': widget.initialData['kode_asset'],
        'TANGGAL_PEMBELIAN':
            _dateController.text.isNotEmpty
                ? _dateController.text
                : widget.initialData['crdt'],
        'COST_AC': _costController.text,
        'BOK_VAL': _bookValueController.text,
        'NAMA_USER_ASET': _userController.text,
        'KETERANGAN': _remarkController.text,
        'STATUS_ASET': _selectedStatus,
        'CONDITION': _selectedCondition,
        'POSITION': _positionController.text,
        'DIVISION': _divisionController.text,
        'LOC_ROOM': _locationController.text,
        'FLOOR': _floorController.text,
      };

      print('Data yang akan dikirim: $updateData');

      final success = await _controller.updateStockOpname(
        id: widget.assetId,
        data: updateData,
      );

      if (success) {
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
      Get.snackbar(
        'Error',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
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
        title: Text('Edit Asset', style: TextStyle(color: Colors.white)),
        backgroundColor: EditScreen.headerBlue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon:
                _isSaving
                    ? CircularProgressIndicator(color: Colors.white)
                    : Icon(Icons.save),
            onPressed: _isSaving ? null : _saveChanges,
          ),
        ],
      ),
      body:
          _isLoading
              ? Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // Basic Information
                      TextFormField(
                        controller: _trxNoController,
                        decoration: InputDecoration(
                          labelText: 'TRX NO*',
                          border: OutlineInputBorder(),
                          filled: true,
                          fillColor: Colors.grey.shade200,
                        ),
                        enabled: false,
                        validator:
                            (value) =>
                                value?.isEmpty ?? true ? 'Required' : null,
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: _userController,
                        decoration: InputDecoration(
                          labelText: 'Nama User*',
                          border: OutlineInputBorder(),
                        ),
                        validator:
                            (value) =>
                                value?.isEmpty ?? true ? 'Required' : null,
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: _dateController,
                        decoration: InputDecoration(
                          labelText: 'Tanggal',
                          border: OutlineInputBorder(),
                          suffixIcon: Icon(Icons.calendar_today),
                        ),
                        readOnly: true,
                        onTap: () => _selectDate(context),
                      ),
                      SizedBox(height: 16),

                      // Status and Condition
                      DropdownButtonFormField<String>(
                        isExpanded: true,
                        value:
                            _statusOptions.contains(_selectedStatus)
                                ? _selectedStatus
                                : null,
                        items:
                            _statusOptions.map((status) {
                              return DropdownMenuItem<String>(
                                value: status,
                                child: Text(
                                  status,
                                  overflow: TextOverflow.ellipsis,
                                ),
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
                          fillColor: Colors.white,
                        ),
                        validator: (value) {
                          if (value == null ||
                              !_statusOptions.contains(value)) {
                            return 'Pilih status asset yang valid';
                          }
                          return null;
                        },
                      ),

                      SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        isExpanded: true,
                        value:
                            _conditionOptions.contains(_selectedCondition)
                                ? _selectedCondition
                                : null,
                        items:
                            _conditionOptions.map((condition) {
                              return DropdownMenuItem<String>(
                                value: condition,
                                child: Text(
                                  condition,
                                  overflow: TextOverflow.ellipsis,
                                ),
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
                          fillColor: Colors.white,
                        ),
                        validator: (value) {
                          if (value == null ||
                              !_conditionOptions.contains(value)) {
                            return 'Pilih kondisi asset yang valid';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16),

                      // Financial Information
                      TextFormField(
                        controller: _costController,
                        decoration: InputDecoration(
                          labelText: 'Cost',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: _bookValueController,
                        decoration: InputDecoration(
                          labelText: 'Book Value',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                      SizedBox(height: 16),

                      DropdownButtonFormField<String>(
                        isExpanded: true,
                        value:
                            _posisiUserOptions.contains(_selectedPosisiUser)
                                ? _selectedPosisiUser
                                : null,
                        items:
                            _posisiUserOptions.map((posisiUser) {
                              return DropdownMenuItem<String>(
                                value: posisiUser,
                                child: Text(
                                  posisiUser,
                                  overflow: TextOverflow.ellipsis,
                                ),
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
                          fillColor: Colors.white,
                        ),
                        validator: (value) {
                          if (value == null ||
                              !_posisiUserOptions.contains(value)) {
                            return 'Pilih posisi user yang valid';
                          }
                          return null;
                        },
                      ),

                      SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        isExpanded: true,
                        value:
                            _divisiUserOptions.contains(_selectedDivisiUser)
                                ? _selectedDivisiUser
                                : null,
                        items:
                            _divisiUserOptions.map((divisiUser) {
                              return DropdownMenuItem<String>(
                                value: divisiUser,
                                child: Text(
                                  divisiUser,
                                  overflow: TextOverflow.ellipsis,
                                ),
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
                          fillColor: Colors.white,
                        ),
                        validator: (value) {
                          if (value == null ||
                              !_divisiUserOptions.contains(value)) {
                            return 'Pilih divisi user yang valid';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        isExpanded: true,
                        value:
                            _lokasiUserOptions.contains(_selectedLokasiUser)
                                ? _selectedLokasiUser
                                : null,
                        items:
                            _lokasiUserOptions.map((lokasiUser) {
                              return DropdownMenuItem<String>(
                                value: lokasiUser,
                                child: Text(
                                  lokasiUser,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              );
                            }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedLokasiUser = value;
                          });
                        },
                        decoration: InputDecoration(
                          labelText: 'Lokasi',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        validator: (value) {
                          if (value == null ||
                              !_lokasiUserOptions.contains(value)) {
                            return 'Pilih lokasi user yang valid';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        isExpanded: true,
                        value:
                            _lantaiUserOptions.contains(_selectedLantaiUser)
                                ? _selectedLantaiUser
                                : null,
                        items:
                            _lantaiUserOptions.map((lantaiUser) {
                              return DropdownMenuItem<String>(
                                value: lantaiUser,
                                child: Text(
                                  lantaiUser,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              );
                            }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedLantaiUser = value;
                          });
                        },
                        decoration: InputDecoration(
                          labelText: 'Lantai',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        validator: (value) {
                          if (value == null ||
                              !_lantaiUserOptions.contains(value)) {
                            return 'Pilih lantai yang valid';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16),

                      // Remarks
                      TextFormField(
                        controller: _remarkController,
                        decoration: InputDecoration(
                          labelText: 'Keterangan',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 3,
                      ),
                      SizedBox(height: 24),

                      // Save Button
                      ElevatedButton(
                        onPressed: _saveChanges,
                        style: ElevatedButton.styleFrom(
                          minimumSize: Size(double.infinity, 50),
                          backgroundColor: EditScreen.headerBlue,
                        ),
                        child:
                            _isSaving
                                ? CircularProgressIndicator(color: Colors.white)
                                : Text(
                                  'Simpan Perubahan',
                                  style: TextStyle(fontSize: 16),
                                ),
                      ),
                    ],
                  ),
                ),
              ),
    );
  }

  @override
  void dispose() {
    _trxNoController.dispose();
    _userController.dispose();
    _costController.dispose();
    _bookValueController.dispose();
    _positionController.dispose();
    _divisionController.dispose();
    _locationController.dispose();
    _floorController.dispose();
    _remarkController.dispose();
    _dateController.dispose();
    super.dispose();
  }
}
