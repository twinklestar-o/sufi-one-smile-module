import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:intl/intl.dart';

import '../views/TaskVisit/task_edit.dart'; // Import for date formatting in controller for default values if needed

class TaskEditController extends GetxController {
  RxMap<String, dynamic> editedData = RxMap<String, dynamic>({});
  final formKey = GlobalKey<FormState>();

  @override
  void onInit() {
    super.onInit();
    // Inisialisasi editedData dari arguments atau jika tidak ada, berikan nilai default
    // Pastikan semua keys yang digunakan di UI ada di sini, meskipun nilainya kosong
    editedData.value = (Get.arguments as Map<String, dynamic>?) ?? {
      'jabatan': '',
      'area': '',
      'cabang': '',
      'produk': '',
      'type': '',
      'activity': '',
      'date_start': '', // Nilai awal kosong untuk tanggal
      'date_finish': '', // Nilai awal kosong untuk tanggal
      'date_finish_actual': '', // Nilai awal kosong untuk tanggal selesai aktual
      'pic': '',
      'discussion': '',
      'problem': '',
      'pelakasanaan': '',
      'noPlan': '', // Pastikan 'noPlan' ada di sini juga
      'timestamp': '' // Pastikan 'timestamp' ada di sini juga
    };
  }

  // Fungsi untuk menampilkan date picker
  Future<DateTime?> selectDate(BuildContext context) async {
    DateTime initialDate = DateTime.now();

    // Coba parse tanggal yang sudah ada dari editedData jika ada dan valid
    String? currentPickedDateString = editedData['date_start']; // Contoh mengambil dari date_start
    if (context.findAncestorWidgetOfExactType<TaskEdit>()?.controller.editedData['date_start'] != null &&
        context.findAncestorWidgetOfExactType<TaskEdit>()!.controller.editedData['date_start']!.isNotEmpty) {
      try {
        initialDate = DateFormat('yyyy-MM-dd').parse(context.findAncestorWidgetOfExactType<TaskEdit>()!.controller.editedData['date_start']!);
      } catch (e) {
        print("Error parsing initial date: $e");
        // Jika gagal parse, biarkan initialDate sebagai DateTime.now()
      }
    }


    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate, // Menggunakan tanggal yang ada atau tanggal saat ini
      firstDate: DateTime(2000), // Tanggal paling awal yang bisa dipilih
      lastDate: DateTime(2101), // Tanggal paling akhir yang bisa dipilih
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.blue, // Warna background header date picker
              onPrimary: Colors.white, // Warna teks header (hari, bulan, tahun)
              surface: Colors.white, // Warna background date picker body
              onSurface: Colors.black, // Warna teks tanggal
            ),
            dialogBackgroundColor: Colors.white, // Warna background dialog
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Colors.blue, // Warna tombol Cancel/OK
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    return pickedDate;
  }

  Future<void> saveEditedData() async {
    if (formKey.currentState?.validate() ?? false) {
      formKey.currentState?.save(); // Memastikan data tersimpan dengan benar

      // Debugging: Print data edited
      print("Edited Data: ${editedData.value}");

      // Pastikan noPlan sudah terisi sebelum menyimpan
      if (editedData['noPlan'] == null || editedData['noPlan'].isEmpty) {
        Get.snackbar(
          'Error',
          'No Plan is required',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      // Data yang akan disimpan. Pastikan semua field yang ingin Anda simpan sudah ada di sini.
      final taskData = {
        'noPlan': editedData['noPlan'] ?? '',
        'cabang': editedData['cabang'] ?? '',
        'pic': editedData['pic'] ?? '',
        'type': editedData['type'] ?? '',
        'activity': editedData['activity'] ?? '',
        'timestamp': editedData['timestamp'] ?? '',
        'jabatan': editedData['jabatan'] ?? '',
        'area': editedData['area'] ?? '',
        'produk': editedData['produk'] ?? '',
        'date_start': editedData['date_start'] ?? '',
        'date_finish': editedData['date_finish'] ?? '',
        'date_finish_actual': editedData['date_finish_actual'] ?? '',
        'discussion': editedData['discussion'] ?? '',
        'problem': editedData['problem'] ?? '',
        'pelakasanaan': editedData['pelakasanaan'] ?? '',
      };

      try {
        final directory = await getApplicationDocumentsDirectory();
        final file = File('${directory.path}/task_data.json');
        final existingData = await _loadLocalData();

        // Periksa apakah noPlan ada di existingData untuk update atau tambah baru
        existingData[editedData['noPlan']] = taskData;


        // Simpan data yang sudah diperbarui ke file JSON
        // Menggunakan .values.toList() jika Anda ingin menyimpan sebagai list of maps
        // Jika Anda ingin menyimpan sebagai map of maps, cukup jsonEncode(existingData)
        await file.writeAsString(jsonEncode(existingData.values.toList()), flush: true);

        Get.snackbar(
          'Success',
          'Task data saved successfully',
          snackPosition: SnackPosition.BOTTOM,
        );
        Get.back();
      } catch (e) {
        Get.snackbar(
          'Error',
          'Failed to save task data: $e',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } else {
      Get.snackbar(
        'Error',
        'Please fill in the required fields.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<Map<String, Map<String, dynamic>>> _loadLocalData() async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/task_data.json');
    if (await file.exists()) {
      final String response = await file.readAsString();
      final data = jsonDecode(response) as List<dynamic>;

      // Membaca data dan mengorganisirnya dengan 'noPlan' sebagai key
      return {for (var item in data) item['noPlan']: item.cast<String, dynamic>()};
    }
    return {};
  }

  @override
  void onClose() {
    super.onClose();
  }
}