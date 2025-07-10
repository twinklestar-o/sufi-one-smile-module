import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../models/visit.dart';

class TaskEditController extends GetxController {
  final formKey = GlobalKey<FormState>();
  final RxMap<String, dynamic> editedData = <String, dynamic>{}.obs;

  void initializeData(Visit visit) {
    editedData.value = {
      'id': visit.id,
      'jabatanSaya': visit.jabatanSaya ?? '',
      'areaCode': visit.areaCode ?? '',
      'branchCode': visit.branchCode ?? '',
      'productCode': visit.productCode ?? '',
      'dealerCode': visit.dealerCode ?? '',
      'tipeVisit': visit.tipeVisit ?? '',
      'tujuanVisit': visit.tujuanVisit ?? '',
      'dariTanggal': visit.dariTanggal,
      'sampaiTanggal': visit.sampaiTanggal,
      'tanggalSelesai': visit.tanggalSelesai,
      'namaPic': visit.namaPic ?? '',
      'themeOfDiscussion': visit.themeOfDiscussion ?? '',
      'problem': visit.problem ?? '',
      'followUp': visit.followUp ?? '',
      'description': visit.description ?? '',
      'mainJabatan': '',
      'mainNamaPic': '',
      'mainNoTelp': '',
      'mainLokasi': '',
      'status': 'Terlaksana',
    };

    if (visit.mainPersons != null && visit.mainPersons!.isNotEmpty) {
      final main = visit.mainPersons!.first;
      editedData['mainJabatan'] = main['jabatan'] ?? '';
      editedData['mainNamaPic'] = main['nama'] ?? '';
      editedData['mainNoTelp'] = main['no_telp'] ?? '';
      editedData['mainLokasi'] = main['lokasi'] ?? '';
    }
  }

  Future<DateTime?> selectDate(BuildContext context, String key) async {
    DateTime initialDate = editedData[key] ?? DateTime.now();

    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.blue,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
            dialogBackgroundColor: Colors.white,
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: Colors.blue),
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      editedData[key] = pickedDate;
    }

    return pickedDate;
  }

  Visit? saveEditedData() {
    if (formKey.currentState?.validate() ?? false) {
      formKey.currentState?.save();

      return Visit(
        id: editedData['id'],
        jabatanSaya: editedData['jabatanSaya'],
        areaCode: editedData['areaCode'],
        branchCode: editedData['branchCode'],
        productCode: editedData['productCode'],
        dealerCode: editedData['dealerCode'],
        tipeVisit: editedData['tipeVisit'],
        tujuanVisit: editedData['tujuanVisit'],
        dariTanggal: editedData['dariTanggal'],
        sampaiTanggal: editedData['sampaiTanggal'],
        tanggalSelesai: editedData['tanggalSelesai'],
        namaPic: editedData['namaPic'],
        themeOfDiscussion: editedData['themeOfDiscussion'],
        problem: editedData['problem'],
        followUp: editedData['followUp'],
        description: editedData['description'],
        photo1: null,
        photo2: null,
        latitude: null,
        longitude: null,
        mainPersons: [
          {
            'jabatan': editedData['mainJabatan'],
            'nama': editedData['mainNamaPic'],
            'no_telp': editedData['mainNoTelp'],
            'lokasi': editedData['mainLokasi'],
          }
        ],
      );
    }
    return null;
  }
}
