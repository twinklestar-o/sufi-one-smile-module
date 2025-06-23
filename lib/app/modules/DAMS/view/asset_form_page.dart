import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
  bool _isLoading = false;
  bool _isSaving = false;

  final _formKey = GlobalKey<FormState>();
  final _lokasiController = TextEditingController();
  final _branchIdController = TextEditingController();
  final _divisionController = TextEditingController();
  final _personalLocController = TextEditingController();
  final _deptController = TextEditingController();
  final _roomController = TextEditingController();
  final _floorController = TextEditingController();

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
      _lokasiController.text = asset.lokasi;
      _branchIdController.text = asset.branchId;
      _divisionController.text = asset.division ?? '';
      _personalLocController.text = asset.personalLoc ?? '';
      _deptController.text = asset.dept ?? '';
      _roomController.text = asset.room ?? '';
      _floorController.text = asset.floor ?? '';
    });
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

      final success = await _scanController.updateAsset(updatedAsset);

      if (success && mounted) {
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
          children: [
            _buildBasicInfoSection(),
            const SizedBox(height: 16),
            _buildLocationInfoSection(),
            const SizedBox(height: 16),
            if (_editedAsset != null) _buildStatusSwitch(),
            const SizedBox(height: 16),
            if (_editedAsset != null) _buildAssetInfoSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildBasicInfoSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Basic Information',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _branchIdController,
              decoration: const InputDecoration(
                labelText: 'Branch ID',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter branch ID';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _divisionController,
              decoration: const InputDecoration(
                labelText: 'Division',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationInfoSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Location Information',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _lokasiController,
              decoration: const InputDecoration(
                labelText: 'Lokasi',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter location';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _personalLocController,
              decoration: const InputDecoration(
                labelText: 'Personal Location',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _deptController,
              decoration: const InputDecoration(
                labelText: 'Department',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _roomController,
              decoration: const InputDecoration(
                labelText: 'Room',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _floorController,
              decoration: const InputDecoration(
                labelText: 'Floor',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusSwitch() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            const Text('Status:', style: TextStyle(fontSize: 16)),
            const SizedBox(width: 16),
            Switch(
              value: _editedAsset!.isActive == 1,
              onChanged: (value) {
                setState(() {
                  _editedAsset = _editedAsset!.copyWith(
                    isActive: value ? 1 : 0,
                  );
                });
              },
            ),
            Text(
              _editedAsset!.isActive == 1 ? 'Active' : 'Inactive',
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAssetInfoSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Asset Details',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 16),
            _buildInfoRow('Asset Code', _editedAsset!.kodeAset),
            _buildInfoRow('Created by', _editedAsset!.userCreate),
            _buildInfoRow('Create Date', _formatDate(_editedAsset!.createDate)),
            if (_editedAsset!.lastUpdate != null)
              _buildInfoRow(
                'Last Update',
                _formatDate(_editedAsset!.lastUpdate!),
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
