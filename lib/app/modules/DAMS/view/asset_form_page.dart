import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:sufi_one/app/modules/DAMS/controller/scan_controller.dart';
import 'package:sufi_one/app/modules/DAMS/model/asset.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;

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
  bool _hasLoaded = false;
  bool isPhoto1Uploaded = false;
  File? _photo1;

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
  final ImagePicker _picker = ImagePicker();
  static const Color textButton = Color(0xFF8BADCA);
  static const Color headerBlue = Color(0xFF1521A4);

  final List<String> _statusOptions = ['Exist', 'Not Exist'];
  final List<String> _conditionOptions = ['Good', 'Broken'];
  String? _selectedStatus;
  String? _selectedCondition;

  @override
  void initState() {
    super.initState();
    if (!_hasLoaded) {
      if (widget.initialAsset != null) {
        _editedAsset = widget.initialAsset;
        _initializeControllers(widget.initialAsset!);
        _futureAsset = Future.value(widget.initialAsset);
      } else {
        _futureAsset = _fetchAssetData();
      }
      _hasLoaded = true;
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
    if (asset.detail?.tanggalPembelian != null) {
      _tanggalBeliController.text = DateFormat(
        'dd/MM/yyyy',
      ).format(asset.detail!.tanggalPembelian!);
    }
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
      final updatedAsset = _editedAsset!.copyWith(
        division: _divisionController.text,
        floor: _lantaiUserController.text,
        lastUpdate: DateTime.now(),
      );

      final updatedDetail = _editedAssetDetail!.copyWith(
        item: _namaAssetController.text,
        tanggalPembelian: DateFormat(
          'dd/MM/yyyy',
        ).parse(_tanggalBeliController.text),
        costAc: _hargaBeliController.text.replaceAll(RegExp(r'[^0-9]'), ''),
        bokVal: _nilaiBukuController.text.replaceAll(RegExp(r'[^0-9]'), ''),
        username: _namaUserAssetController.text,
        description: _keteranganController.text,
        status: _selectedStatus ?? '',
        condition: _selectedCondition ?? '',
        position: _posisiUserController.text,
        locRoom: _lokasiUserController.text,
        group: _groupController.text,
        lastUpdate: DateTime.now(),
      );

      // Prepare multipart request for photo upload
      if (_photo1 != null) {
        final request = http.MultipartRequest(
          'POST', // Use POST or PUT depending on your API endpoint
          Uri.parse(
            'http://your-api-url/api/direct-visits/${widget.kodeAset}/photo',
          ), // Adjust URL to your endpoint
        );

        // Add photo file
        request.files.add(
          await http.MultipartFile.fromPath(
            'photo1', // Match the field name expected by the PHP controller
            _photo1!.path,
            filename: path.basename(_photo1!.path),
          ),
        );

        // Add authentication headers if required (e.g., Bearer token)
        // request.headers['Authorization'] = 'Bearer ${yourToken}';

        final response = await request.send();
        if (response.statusCode != 200 && response.statusCode != 201) {
          throw Exception('Failed to upload photo: ${response.statusCode}');
        }
      }

      // Update asset and detail
      await _scanController.updateAssetAndDetail(updatedAsset, updatedDetail);

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
        backgroundColor: headerBlue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon:
                _isSaving
                    ? const CircularProgressIndicator(color: Colors.white)
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
            TextFormField(
              controller: _statusUserAssetController,
              decoration: InputDecoration(
                labelText: 'Status User Asset',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _posisiUserController,
              decoration: InputDecoration(
                labelText: 'Posisi User',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _divisionController,
              decoration: InputDecoration(
                labelText: 'Divisi User',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _lokasiController,
              decoration: InputDecoration(
                labelText: 'Lokasi User',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _lantaiUserController,
              decoration: InputDecoration(
                labelText: 'Lantai User',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _gambarController,
              decoration: InputDecoration(
                labelText: 'Gambar',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
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
          file == null ? 'Pilih Foto' : 'Foto Terunggah',
          style: TextStyle(
            color: headerBlue,
            fontSize: 16,
            fontWeight: file == null ? FontWeight.normal : FontWeight.bold,
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
    if (_photo1 == null) {
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
              onTap: () => _showFullScreenImage(context, _photo1!),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Stack(
                  children: [
                    Image.file(
                      _photo1!,
                      fit: BoxFit.cover,
                      height: 350,
                      width: double.infinity,
                    ),
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
                            () => _showFullScreenImage(context, _photo1!),
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

  @override
  void dispose() {
    _namaAssetController.dispose();
    _tanggalBeliController.dispose();
    _hargaBeliController.dispose();
    _nilaiBukuController.dispose();
    _namaUserAssetController.dispose();
    _keteranganController.dispose();
    _statusAssetController.dispose();
    _kondisiAssetController.dispose();
    _statusUserAssetController.dispose();
    _posisiUserController.dispose();
    _divisiUserController.dispose();
    _lokasiUserController.dispose();
    _lantaiUserController.dispose();
    _gambarController.dispose();
    _lokasiController.dispose();
    _branchIdController.dispose();
    _divisionController.dispose();
    _personalLocController.dispose();
    _deptController.dispose();
    _roomController.dispose();
    _floorController.dispose();
    _groupController.dispose();
    super.dispose();
  }
}
