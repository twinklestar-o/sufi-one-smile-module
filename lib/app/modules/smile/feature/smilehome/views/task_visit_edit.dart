import 'package:flutter/material.dart';
import 'package:sufi_one/app/modules/smile/feature/smilehome/views/task_visit.dart';

class TaskVisitEdit extends StatefulWidget {
  final Visit visit;

  const TaskVisitEdit({Key? key, required this.visit}) : super(key: key);

  @override
  _TaskVisitEditState createState() => _TaskVisitEditState();
}

class _TaskVisitEditState extends State<TaskVisitEdit> {
  late TextEditingController _tipeVisitController;
  late TextEditingController _tujuanVisitController;
  late TextEditingController _dariTanggalController;
  late TextEditingController _sampaiTanggalController;
  late TextEditingController _namaPicController;
  late TextEditingController _themeDiscussionController;
  late TextEditingController _problemController;

  String? _status; // Variable to store the selected status

  @override
  void initState() {
    super.initState();
    // Initialize the controllers with empty strings
    _tipeVisitController = TextEditingController(text: "");
    _tujuanVisitController = TextEditingController(text: "");
    _dariTanggalController = TextEditingController(text: "");
    _sampaiTanggalController = TextEditingController(text: "");
    _namaPicController = TextEditingController(text: "");
    _themeDiscussionController = TextEditingController(text: "");
    _problemController = TextEditingController(text: "");
    _status = null; // Set the initial status to null
  }

  @override
  void dispose() {
    _tipeVisitController.dispose();
    _tujuanVisitController.dispose();
    _dariTanggalController.dispose();
    _sampaiTanggalController.dispose();
    _namaPicController.dispose();
    _themeDiscussionController.dispose();
    _problemController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != DateTime.now()) {
      controller.text = "${picked.toLocal()}".split(' ')[0];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Task Visit'),
        backgroundColor: const Color(0xFF1628B0),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView(
                children: [
                  _buildTextField('Tipe Visit', _tipeVisitController),
                  const SizedBox(height: 16),
                  _buildTextField('Tujuan Visit', _tujuanVisitController),
                  const SizedBox(height: 16),
                  _buildDatePickerField('Dari Tanggal', _dariTanggalController, context),
                  const SizedBox(height: 16),
                  _buildDatePickerField('Sampai Tanggal', _sampaiTanggalController, context),
                  const SizedBox(height: 16),
                  _buildTextField('Nama PIC', _namaPicController),
                  const SizedBox(height: 16),
                  _buildTextField('Theme Discussion', _themeDiscussionController),
                  const SizedBox(height: 16),
                  _buildTextField('Problem', _problemController),
                  const SizedBox(height: 16),

                  // Adding the Dropdown for STATUS
                  DropdownButtonFormField<String>(
                    value: _status,
                    onChanged: (String? newValue) {
                      setState(() {
                        _status = newValue;
                      });
                    },
                    decoration: InputDecoration(
                      labelText: 'STATUS',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    items: <String>['Terlaksana', 'Dibatalkan']
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),

          // Save Button at the bottom with styling for blue background and white text
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity, // Make the button take the full width
              child: ElevatedButton(
                onPressed: () {
                  // Handle save/update logic here
                  // Update visit details and pop the screen
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.lightBlue, // Blue background color
                  foregroundColor: Colors.white, // White text color
                  padding: const EdgeInsets.symmetric(vertical: 16), // Vertical padding for larger button
                ),
                child: const Text('Save'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    );
  }

  Widget _buildDatePickerField(String label, TextEditingController controller, BuildContext context) {
    return GestureDetector(
      onTap: () => _selectDate(context, controller),
      child: AbsorbPointer(
        child: TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: label,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
        ),
      ),
    );
  }
}
