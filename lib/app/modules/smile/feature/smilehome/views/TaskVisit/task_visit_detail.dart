import 'package:flutter/material.dart';
import 'package:sufi_one/app/modules/smile/feature/smilehome/views/TaskVisit/task_visit.dart';
import 'package:intl/intl.dart';

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

    // Inisialisasi semua controller dari widget.visit
    _tipeVisitController = TextEditingController(text: widget.visit.jenisVisit);
    _tujuanVisitController = TextEditingController(text: widget.visit.subJenis);
    _dariTanggalController = TextEditingController(
      text: DateFormat('yyyy-MM-dd').format(widget.visit.tanggal),
    );
    _sampaiTanggalController = TextEditingController(text: ''); // opsional
    _namaPicController = TextEditingController(text: ''); // opsional
    _themeDiscussionController = TextEditingController(text: '');
    _problemController = TextEditingController(text: '');
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'View Visit Dealer',
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF0048A7),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        padding: const EdgeInsets.all(16),
        color: Colors.white,
        child: ListView(
          children: [
            // Foto selfie statis sementara
            Container(
              height: 200,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black, width: 3),
                borderRadius: BorderRadius.circular(12),
                image: const DecorationImage(
                  image: AssetImage('assets/images/selfie_dealer.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
              child: Align(
                alignment: Alignment.bottomLeft,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${DateFormat('dd MMM yyyy HH:mm:ss').format(widget.visit.tanggal)} - Lokasi Dealer',
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Jabatan
            Center(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  border: Border.all(color: Colors.blue),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  'Jabatan Saya: BM',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // DATA DEALER
            _buildSectionBox(
              title: 'Data Dealer',
              children: [
                _buildTextField('Area', '01.JABODETABEKSER'),
                _buildTextField('Cabang', widget.visit.kodeCabang),
                _buildTextField('Produk', 'MBBR'),
              ],
            ),
            const SizedBox(height: 16),

            // DATA VISIT
            _buildSectionBox(
              title: 'Data Visit',
              children: [
                _buildTextField('Tipe Visit', _tipeVisitController.text),
                _buildTextField('Tujuan Visit', _tujuanVisitController.text),
                _buildTextField('Dari Tanggal', _dariTanggalController.text),
                _buildTextField('Sampai Tanggal', _sampaiTanggalController.text),
                _buildTextField('Nama PIC', _namaPicController.text),
                _buildTextField('Theme Discussion', _themeDiscussionController.text),
                _buildTextField('Problem', _problemController.text),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: TextEditingController(text: value),
        readOnly: true,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
      ),
    );
  }

  Widget _buildSectionBox({required String title, required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        border: Border.all(color: Colors.grey, width: 1.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2C308B),
              ),
            ),
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }
}
