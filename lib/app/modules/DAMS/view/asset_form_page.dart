import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:sufi_one/app/modules/DAMS/controller/scan_controller.dart';
import 'package:sufi_one/app/modules/DAMS/model/asset.dart';

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
  Asset? _editedAsset;
  AssetDetail? _editedAssetDetail;
  bool _isLoading = false;
  bool _isSaving = false;

  final _formKey = GlobalKey<FormState>();
  final _namaAssetController = TextEditingController();
  final _tanggalBeliController = TextEditingController();
  final _hargaBeliController = TextEditingController();
  final _nilaiBukuController = TextEditingController();
  final _namaUserAssetController = TextEditingController();
  final _keteranganController = TextEditingController();
  final _statusAssetController = TextEditingController();
  final _kondisiAssetController = TextEditingController();
  final _statusUserAssetController = TextEditingController();
  final _posisiUserController = TextEditingController();
  final _divisiUserController = TextEditingController();
  final _lokasiUserController = TextEditingController();
  final _lantaiUserController = TextEditingController();
  final _gambarController = TextEditingController();

  final _lokasiController = TextEditingController();
  final _branchIdController = TextEditingController();
  final _divisionController = TextEditingController();
  final _personalLocController = TextEditingController();
  final _deptController = TextEditingController();
  final _roomController = TextEditingController();
  final _floorController = TextEditingController();
  final _groupController = TextEditingController();

  // Dropdown options
  final List<String> _statusOptions = ['Exist', 'Lost'];
  final List<String> _conditionOptions = ['Good', 'Broken'];
  String? _selectedStatus;
  String? _selectedCondition;

  @override
  void initState() {
    super.initState();
    // Jika ada initialAsset, gunakan langsung tanpa fetch
    if (widget.initialAsset != null) {
      _editedAsset = widget.initialAsset;
      _initializeControllers(widget.initialAsset!);
      _futureAsset = Future.value(widget.initialAsset);
    } else {
      _futureAsset = _fetchAssetData();
    }
  }

  Future<Asset> _fetchAssetData() async {
    try {
      final asset = await _scanController.getAssetByKodeAset(widget.kodeAset);
      _initializeControllers(asset);
      return asset;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load asset data: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
      rethrow;
    }
  }

  void _initializeControllers(Asset asset) {
    setState(() {
      _editedAsset = asset;
      _editedAssetDetail = asset.detail;

      _namaAssetController.text = asset.detail?.item ?? '';
      // Initialize date picker value
      if (asset.detail?.tanggalPembelian != null) {
        _tanggalBeliController.text = DateFormat(
          'dd/MM/yyyy',
        ).format(asset.detail!.tanggalPembelian!);
      }
      // Initialize price fields with Rupiah format
      if (asset.detail?.costAc != null && asset.detail!.costAc!.isNotEmpty) {
        _hargaBeliController.text = _formatCurrency(
          double.tryParse(asset.detail!.costAc!) ?? 0,
        );
      }

      if (asset.detail?.bokVal != null && asset.detail!.bokVal!.isNotEmpty) {
        _nilaiBukuController.text = _formatCurrency(
          double.tryParse(asset.detail!.bokVal!) ?? 0,
        );
      }
      _namaUserAssetController.text = asset.detail?.username ?? '';
      _keteranganController.text = asset.detail?.description ?? '';

      // Initialize dropdown values
      _selectedStatus = asset.detail?.status;
      _selectedCondition = asset.detail?.condition;

      _statusAssetController.text = asset.detail?.status ?? '';
      _kondisiAssetController.text = asset.detail?.condition ?? '';
      _statusUserAssetController.text = asset.detail?.username ?? '';
      _posisiUserController.text = asset.detail?.position ?? '';
      _divisiUserController.text = asset.branchName ?? '';
      _lokasiUserController.text = asset.detail?.locRoom ?? '';
      _lantaiUserController.text = asset.floor ?? '';
      _gambarController.text = asset.lokasi ?? '';

      _lokasiController.text = asset.lokasi;
      _branchIdController.text = asset.branchId;
      _divisionController.text = asset.division ?? '';
      _personalLocController.text = asset.personalLoc ?? '';
      _deptController.text = asset.dept ?? '';
      _roomController.text = asset.room ?? '';
      _floorController.text = asset.floor ?? '';
      _groupController.text = asset.detail?.group ?? '';
    });
  }

  // Format currency to Rupiah
  String _formatCurrency(double amount) {
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(amount);
  }

  // Parse Rupiah string to double
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
      final updatedAsset = _editedAsset!.copyWith(
        lokasi: _lokasiController.text,
        branchId: _branchIdController.text,
        division:
            _divisionController.text.isEmpty ? null : _divisionController.text,
        personalLoc:
            _personalLocController.text.isEmpty
                ? null
                : _personalLocController.text,
        dept: _deptController.text.isEmpty ? null : _deptController.text,
        room: _roomController.text.isEmpty ? null : _roomController.text,
        floor: _floorController.text.isEmpty ? null : _floorController.text,
        lastUpdate: DateTime.now(),
        userUpdate: "Current User", // Ganti dengan user yang login
      );

      final updatedDetailAsset = _editedAssetDetail!.copyWith(
        group: _groupController.text.isEmpty ? null : _groupController.text,
        lastUpdate: DateTime.now(),
        userUpdate: "Current User", // Ganti dengan user yang login
      );

      final success = await _scanController.updateAsset(updatedAsset);
      final successDetail = await _scanController.updateDetailAsset(
        updatedDetailAsset,
      );
      if (success && mounted && successDetail) {
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
          e.toString(),
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
        actions: [
          IconButton(
            icon:
                _isSaving
                    ? const CircularProgressIndicator()
                    : const Icon(Icons.save),
            onPressed: _isSaving || _editedAsset == null ? null : _saveChanges,
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
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'DAMS',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _namaAssetController,
              decoration: const InputDecoration(
                labelText: 'Nama Asset',
                border: OutlineInputBorder(),
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
              decoration: const InputDecoration(
                labelText: 'Tanggal Beli',
                border: OutlineInputBorder(),
                suffixIcon: Icon(Icons.calendar_today),
              ),
              readOnly: true,
              onTap: () => _selectDate(context),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _hargaBeliController,
              decoration: const InputDecoration(
                labelText: 'Harga Beli',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nilaiBukuController,
              decoration: const InputDecoration(
                labelText: 'Nilai Buku',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _namaUserAssetController,
              decoration: const InputDecoration(
                labelText: 'Nama User Asset',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _keteranganController,
              decoration: const InputDecoration(
                labelText: 'Keterangan',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedStatus,
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
              decoration: const InputDecoration(
                labelText: 'Status Asset',
                border: OutlineInputBorder(),
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
              value: _selectedCondition,
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
              decoration: const InputDecoration(
                labelText: 'Kondisi Asset',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || !_conditionOptions.contains(value)) {
                  return 'Pilih kondisi asset yang valid';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),
            TextFormField(
              controller: _statusUserAssetController,
              decoration: const InputDecoration(
                labelText: 'Status User Asset',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _posisiUserController,
              decoration: const InputDecoration(
                labelText: 'Posisi User',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _divisiUserController,
              decoration: const InputDecoration(
                labelText: 'Divisi User',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _lokasiController,
              decoration: const InputDecoration(
                labelText: 'Lokasi User',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _lantaiUserController,
              decoration: const InputDecoration(
                labelText: 'Lantai User',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _gambarController,
              decoration: const InputDecoration(
                labelText: 'Gambar',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
