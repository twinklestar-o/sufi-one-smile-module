// lib/app/modules/public/task_visit/views/task_visit.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Model untuk merepresentasikan satu tugas kunjungan.
class Visit {
  final String kodeCabang;
  final String noPlan;
  final String jenisVisit;
  final String subJenis;
  final DateTime tanggal;

  const Visit({
    required this.kodeCabang,
    required this.noPlan,
    required this.jenisVisit,
    required this.subJenis,
    required this.tanggal,
  });
}

/// Delegate yang menyediakan UI dan logika pencarian untuk daftar [Visit].
class VisitSearchDelegate extends SearchDelegate<Visit?> {
  final List<Visit> visits;

  VisitSearchDelegate(this.visits)
    : super(
        searchFieldLabel: 'Cari kode cabang...',
        keyboardType: TextInputType.text,
      );

  @override
  TextStyle? get searchFieldStyle => const TextStyle(fontSize: 16);

  @override
  ThemeData appBarTheme(BuildContext context) {
    final base = Theme.of(context);
    return base.copyWith(
      appBarTheme: base.appBarTheme.copyWith(
        backgroundColor: const Color(0xFF0048A7),
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          icon: const Icon(Icons.clear, color: Colors.white),
          onPressed: () => query = '',
        ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back, color: Colors.white),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final results =
        visits
            .where(
              (v) => v.kodeCabang.toLowerCase().contains(query.toLowerCase()),
            )
            .toList();

    if (results.isEmpty) {
      return const Center(child: Text('Tidak ada hasil.'));
    }

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, i) {
        final v = results[i];
        return ListTile(
          title: Text(v.kodeCabang),
          subtitle: Text(v.noPlan),
          onTap: () => close(context, v),
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestions =
        visits
            .where(
              (v) => v.kodeCabang.toLowerCase().contains(query.toLowerCase()),
            )
            .toList();

    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (context, i) {
        final v = suggestions[i];
        return ListTile(
          title: Text(v.kodeCabang),
          onTap: () {
            query = v.kodeCabang;
            showResults(context);
          },
        );
      },
    );
  }
}

/// Halaman Task Visit yang menampilkan daftar tugas dalam Card bergaya.
class AssetHistory extends StatelessWidget {
  const AssetHistory({Key? key}) : super(key: key);

  // Data dummy — ganti dengan data dari GetX Controller / API
  static final List<Visit> _visits = [
    Visit(
      kodeCabang: 'IMT-01-4W',
      noPlan: 'PLV31052025000315',
      jenisVisit: 'Direct Visit Dealer',
      subJenis: 'KORDINASI RUTIN',
      tanggal: DateTime.parse('2025-05-31T17:23:39.683'),
    ),
    Visit(
      kodeCabang: 'RMK-02-4W-CDG',
      noPlan: 'PLV31052025000318',
      jenisVisit: 'Diskusi On Site',
      subJenis: 'KORDINASI RUTIN',
      tanggal: DateTime.parse('2025-05-31T20:23:44.687'),
    ),
    Visit(
      kodeCabang: 'BITJ-18-4W-AS',
      noPlan: 'DRV31052025001445',
      jenisVisit: 'Diskusi On Site',
      subJenis: 'SOSIALISASI/DISKUSI/EVALUASI PROGRAM',
      tanggal: DateTime.parse('2025-05-31T22:26:56.633'),
    ),
    Visit(
      kodeCabang: 'BITJ-05-4W-BSD',
      noPlan: 'DRV31052025001447',
      jenisVisit: 'Reguler Meeting On Site',
      subJenis: '',
      tanggal: DateTime.parse('2025-05-31T23:00:00.000'),
    ),
  ];

  static const Color _buttonColor = Color(0xFF8ABCEB);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0048A7),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Task visit dealer',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: GestureDetector(
              onTap: () async {
                final result = await showSearch<Visit?>(
                  context: context,
                  delegate: VisitSearchDelegate(_visits),
                );
                // if (result != null) {
                //   Get.toNamed(SmileRoutes.taskVisitDetail, arguments: result);
                // }
              },
              child: Container(
                width: 80,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F4FB),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Center(
                  child: Icon(Icons.search, color: Color(0xFF4E90E5), size: 28),
                ),
              ),
            ),
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        itemCount: _visits.length,
        itemBuilder: (context, index) {
          final v = _visits[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    v.kodeCabang,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    v.noPlan,
                    style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    v.jenisVisit,
                    style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                  ),
                  if (v.subJenis.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      v.subJenis,
                      style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                    ),
                  ],
                  const SizedBox(height: 4),
                  Text(
                    '${v.tanggal.toLocal()}'.split('.').first,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      OutlinedButton.icon(
                        onPressed: () {
                          // Get.toNamed(
                          //   SmileRoutes.taskVisitDetail,
                          //   arguments: v,
                          // );
                        },
                        icon: const Icon(
                          Icons.remove_red_eye,
                          size: 18,
                          color: Color(0xFF4E90E5),
                        ),
                        label: const Text(
                          'View',
                          style: TextStyle(
                            color: Color(0xFF4E90E5),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFF4E90E5)),
                          shape: const StadiumBorder(),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      OutlinedButton.icon(
                        onPressed: () {
                          // Get.toNamed(SmileRoutes.taskVisitEdit, arguments: v);
                        },
                        icon: const Icon(
                          Icons.edit,
                          size: 18,
                          color: Color(0xFF4E90E5),
                        ),
                        label: const Text(
                          'Edit',
                          style: TextStyle(
                            color: Color(0xFF4E90E5),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFF4E90E5)),
                          shape: const StadiumBorder(),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
