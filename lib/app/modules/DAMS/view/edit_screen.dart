import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:sufi_one/app/modules/DAMS/controller/history_controller.dart';

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

  // Dropdown options
  final List<String> _statusOptions = ['Exist', 'Not Exist', 'Broken'];
  final List<String> _conditionOptions = ['Good', 'Bad', 'Repair'];
  String? _selectedStatus;
  String? _selectedCondition;

  @override
  void initState() {
    super.initState();
    print('Initial data: ${widget.initialData}'); // Debug initial data
    _initializeFormData();
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
                        value: _selectedStatus,
                        items:
                            _statusOptions.map((status) {
                              return DropdownMenuItem(
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
                          labelText: 'Status*',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) => value == null ? 'Required' : null,
                      ),
                      SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: _selectedCondition,
                        items:
                            _conditionOptions.map((condition) {
                              return DropdownMenuItem(
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
                          labelText: 'Kondisi*',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) => value == null ? 'Required' : null,
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

                      // Location Information
                      TextFormField(
                        controller: _positionController,
                        decoration: InputDecoration(
                          labelText: 'Posisi',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: _divisionController,
                        decoration: InputDecoration(
                          labelText: 'Divisi',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: _locationController,
                        decoration: InputDecoration(
                          labelText: 'Lokasi',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: _floorController,
                        decoration: InputDecoration(
                          labelText: 'Lantai',
                          border: OutlineInputBorder(),
                        ),
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
