import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HistoryVisit extends StatelessWidget {
  const HistoryVisit({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> historyData = [
      {
        'code': 'IMT-01-4W',
        'plv': 'PLV31052025000315',
        'type': 'Direct Visit Dealer',
        'activity': 'KORDINASI RUTIN',
        'time': '2025-06-11 16:44:00',
        'pic': 'Herman,rukiyanti.all sh',
        'problem': '',
      },
      {
        'code': 'RMK-02-4W-CDG',
        'plv': 'PLV31052025000318',
        'type': 'Diskusi On Site',
        'activity': 'KORDINASI RUTIN',
        'time': '2025-06-11 16:45:00',
        'pic': 'Herman,rukiyanti.all sh',
        'problem': '',
      },
      {
        'code': 'BITJ-18-4W-AS',
        'plv': 'DRV31052025001445',
        'type': 'Diskusi On Site',
        'activity': 'SOSIALISASI/DISKUSI/EVALUASI PROGRAM',
        'time': '2025-06-11 16:46:00',
        'pic': 'Herman,rukiyanti.all sh',
        'problem': '',
      },
      {
        'code': 'BITJ-05-4W-BSD',
        'plv': 'DRV31052025001447',
        'type': 'Regular Meeting On Site',
        'activity': '',
        'time': '2025-06-11 16:47:00',
        'pic': 'Herman,rukiyanti.all sh',
        'problem': '',
      },
    ];

    return Scaffold(
      backgroundColor: Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text('History visit dealer'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(8.0),
        itemCount: historyData.length,
        itemBuilder: (context, index) {
          final data = historyData[index];
          return Card(
            margin: EdgeInsets.symmetric(vertical: 8.0),
            child: ListTile(
              contentPadding: EdgeInsets.all(16.0),
              title: Text(
                data['code'] ?? '',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 4),
                  Text('PLV: ${data['plv'] ?? ''}'),
                  Text(data['type'] ?? ''),
                  Text(data['activity'] ?? ''),
                  Text(
                    data['time'] ?? '',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _menuCard(
                    icon: Icons.visibility,
                    label: 'View',
                    onTap: () => Get.toNamed('/public/smile/history_view', arguments: data),
                  ),
                  SizedBox(width: 8),
                  _menuCard(
                    icon: Icons.edit,
                    label: 'Edit',
                    onTap: () => Get.toNamed('/public/smile/history_edit', arguments: data),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // Placeholder for _menuCard widget
  Widget _menuCard({required IconData icon, required String label, required VoidCallback onTap}) {
    return OutlinedButton(
      onPressed: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.blue),
          SizedBox(width: 4),
          Text(label, style: TextStyle(color: Colors.blue)),
        ],
      ),
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: Colors.blue),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      ),
    );
  }
}