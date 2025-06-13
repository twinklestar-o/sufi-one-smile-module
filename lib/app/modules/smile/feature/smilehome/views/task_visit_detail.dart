import 'package:flutter/material.dart';
import 'package:sufi_one/app/modules/smile/feature/smilehome/views/task_visit.dart';

class TaskVisitDetail extends StatefulWidget {
  final Visit visit;

  const TaskVisitDetail({Key? key, required this.visit}) : super(key: key);

  @override
  _TaskVisitDetailState createState() => _TaskVisitDetailState();
}

class _TaskVisitDetailState extends State<TaskVisitDetail> {
  late TextEditingController _tipeVisitController;
  late TextEditingController _tujuanVisitController;
  late TextEditingController _dariTanggalController;
  late TextEditingController _sampaiTanggalController;
  late TextEditingController _namaPicController;
  late TextEditingController _themeDiscussionController;
  late TextEditingController _problemController;

  @override
  void initState() {
    super.initState();
    _tipeVisitController = TextEditingController();
    _tujuanVisitController = TextEditingController();
    _dariTanggalController = TextEditingController();
    _sampaiTanggalController = TextEditingController();
    _namaPicController = TextEditingController();
    _themeDiscussionController = TextEditingController();
    _problemController = TextEditingController();
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

  Future<void> _selectDate(
    BuildContext context,
    TextEditingController controller,
  ) async {
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
        title: const Text('View Visit Dealer'),
        backgroundColor: const Color(0xFF1628B0), // AppBar background color
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        color: Colors.white, // Background color of the body (white)
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // Selfie Camera View (with a camera-like appearance)
            Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.black, width: 3),
                image: const DecorationImage(
                  image: AssetImage(
                    'assets/images/selfie_dealer.jpg',
                  ), // Replace with selfie image path
                  fit: BoxFit.cover,
                ),
              ),
              child: Stack(
                children: [
                  Align(
                    alignment: Alignment.bottomLeft,
                    child: Container(
                      padding: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        borderRadius: const BorderRadius.only(
                          topRight: Radius.circular(12),
                          bottomLeft: Radius.circular(12),
                        ),
                      ),
                      child: const Text(
                        '30 Mei 2025 14:28:55 - Pondok Jaya, Banten',
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Jabatan Saya in a Box in the Center
            Center(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue, width: 2),
                ),
                child: const Text(
                  'Jabatan Saya: BM',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Data Dealer Box with Title Centered and Custom Title Color
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey, width: 2),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    // Center the title of Data Dealer
                    child: const Text(
                      'Data Dealer',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2C308B),
                      ), // Set color here
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildTextField('Area', _tipeVisitController),
                  const SizedBox(height: 16),
                  _buildTextField('Cabang', _tujuanVisitController),
                  const SizedBox(height: 16),
                  _buildTextField('Produk', _dariTanggalController),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Data Visit Box with Title Centered and Custom Title Color
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey, width: 2),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    // Center the title of Data Visit
                    child: const Text(
                      'Data Visit',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2C308B),
                      ), // Set color here
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildTextField('Tipe Visit', _tipeVisitController),
                  const SizedBox(height: 16),
                  _buildTextField('Tujuan Visit', _tujuanVisitController),
                  const SizedBox(height: 16),
                  _buildDatePickerField(
                    'Dari Tanggal',
                    _dariTanggalController,
                    context,
                  ),
                  const SizedBox(height: 16),
                  _buildDatePickerField(
                    'Sampai Tanggal',
                    _sampaiTanggalController,
                    context,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField('Nama PIC', _namaPicController),
                  const SizedBox(height: 16),
                  _buildTextField(
                    'Theme Discussion',
                    _themeDiscussionController,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField('Problem', _problemController),
                ],
              ),
            ),
          ],
        ),
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

  Widget _buildDatePickerField(
    String label,
    TextEditingController controller,
    BuildContext context,
  ) {
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
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputBox(String label, String value) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
        child: Row(
          children: [
            Text(
              '$label: ',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: Text(
                value,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
