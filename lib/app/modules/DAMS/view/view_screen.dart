import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:sufi_one/app/modules/DAMS/view/edit_screen.dart';

class ViewScreen extends StatelessWidget {
  final Map<String, dynamic> data;

  ViewScreen({required this.data});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detail Asset'),
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed:
                () => Get.to(
                  () => EditScreen(
                    assetId:
                        data['id']?.toString() ??
                        '', // Provide required assetId
                    initialData: data,
                  ),
                ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Kode Aset', data['kode_asset'] ?? '-'),
            _buildDetailRow('Item', data['item'] ?? '-'),
            _buildDetailRow('Nama User', data['username'] ?? '-'),
            _buildDetailRow('Status', data['status'] ?? '-'),
            _buildDetailRow('Kondisi', data['kondisi'] ?? '-'),
            _buildDetailRow('Posisi', data['posisi'] ?? '-'),
            _buildDetailRow('Divisi', data['divisi'] ?? '-'),
            _buildDetailRow('Lokasi', data['lokasi'] ?? '-'),
            _buildDetailRow('Lantai', data['lantai'] ?? '-'),
            _buildDetailRow('Cost', data['cost']?.toString() ?? '-'),
            _buildDetailRow(
              'Book Value',
              data['book_value']?.toString() ?? '-',
            ),
            _buildDetailRow('Keterangan', data['remark'] ?? '-'),
            _buildDetailRow('Dibuat Oleh', data['uscrt'] ?? '-'),
            _buildDetailRow('Tanggal Dibuat', data['crdt'] ?? '-'),
            _buildDetailRow('Diupdate Oleh', data['updt_usr'] ?? '-'),
            _buildDetailRow('Tanggal Update', data['updt_dt'] ?? '-'),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          SizedBox(width: 10),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
