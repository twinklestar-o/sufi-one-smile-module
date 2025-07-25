import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sufi_one/app/modules/DAMS/view/edit_screen.dart';

class ViewScreen extends StatelessWidget {
  final Map<String, dynamic> data;

  const ViewScreen({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final staging_asset = data['staging_asset'];
    final stock_opname_image = data['stock_opname_image'];
    final imageUrl = stock_opname_image['full_image_url'];

    return Scaffold(
      appBar: AppBar(
        title: Text('Detail Asset'),
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed:
                () => Get.to(
                  () => EditScreen(
                    assetId: staging_asset['id'].toString(),
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
            // ✅ Gambar
            if (imageUrl != null && imageUrl.toString().isNotEmpty)
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: GestureDetector(
                    onTap: () => _showFullScreenImageFromUrl(context, imageUrl),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        imageUrl,
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder:
                            (context, error, stackTrace) => Icon(
                              Icons.broken_image,
                              size: 80,
                              color: Colors.grey,
                            ),
                      ),
                    ),
                  ),
                ),
              ),

            SizedBox(height: 16),

            // ✅ Informasi asset
            _buildDetailRow('Kode Aset', staging_asset['kode_asset'] ?? '-'),
            _buildDetailRow('Item', staging_asset['item'] ?? '-'),
            _buildDetailRow('Nama User', staging_asset['username'] ?? '-'),
            _buildDetailRow('Status', staging_asset['status'] ?? '-'),
            _buildDetailRow('Kondisi', staging_asset['kondisi'] ?? '-'),
            _buildDetailRow('Posisi', staging_asset['posisi'] ?? '-'),
            _buildDetailRow('Divisi', staging_asset['divisi'] ?? '-'),
            _buildDetailRow('Lokasi', staging_asset['lokasi'] ?? '-'),
            _buildDetailRow('Lantai', staging_asset['lantai'] ?? '-'),
            _buildDetailRow('Cost', staging_asset['cost']?.toString() ?? '-'),
            _buildDetailRow(
              'Book Value',
              staging_asset['book_value']?.toString() ?? '-',
            ),
            _buildDetailRow('Keterangan', staging_asset['remark'] ?? '-'),
            _buildDetailRow('Dibuat Oleh', staging_asset['uscrt'] ?? '-'),
            _buildDetailRow('Tanggal Dibuat', staging_asset['crdt'] ?? '-'),
            _buildDetailRow('Diupdate Oleh', staging_asset['updt_usr'] ?? '-'),
            _buildDetailRow('Tanggal Update', staging_asset['updt_dt'] ?? '-'),
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

void _showFullScreenImageFromUrl(BuildContext context, String imageUrl) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder:
          (_) => Scaffold(
            backgroundColor: Colors.black,
            body: Stack(
              children: [
                Center(
                  child: InteractiveViewer(
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.contain,
                      errorBuilder:
                          (context, error, stackTrace) => Icon(
                            Icons.broken_image,
                            color: Colors.white,
                            size: 80,
                          ),
                    ),
                  ),
                ),
                Positioned(
                  top: 40,
                  right: 20,
                  child: IconButton(
                    icon: Icon(Icons.close, color: Colors.white, size: 30),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
              ],
            ),
          ),
    ),
  );
}
