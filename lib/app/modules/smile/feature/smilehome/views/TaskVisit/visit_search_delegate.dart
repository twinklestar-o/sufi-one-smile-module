import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sufi_one/app/modules/smile/feature/smilehome/controllers/task_visit_controller.dart';
import '../../../../models/visit.dart';

class VisitSearchDelegate extends SearchDelegate {
  final TaskVisitController controller;

  VisitSearchDelegate(this.controller);

  @override
  String get searchFieldLabel => 'Cari berdasarkan Cabang, PIC, Tipe, Tujuan...';

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () {
            query = '';
            controller.updateSearchQuery('');
            showSuggestions(context);
          },
        ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        controller.updateSearchQuery('');
        close(context, null);
      },
    );
  }

  // ✅ Gunakan showResults & showSuggestions untuk update query di luar build phase
  @override
  void showResults(BuildContext context) {
    controller.updateSearchQuery(query);
    super.showResults(context);
  }

  @override
  void showSuggestions(BuildContext context) {
    controller.updateSearchQuery(query);
    super.showSuggestions(context);
  }

  @override
  Widget buildResults(BuildContext context) {
    return Obx(() {
      final results = controller.filteredTaskVisitData;
      if (results.isEmpty) {
        return const Center(child: Text('Tidak ada hasil yang cocok.'));
      }
      return _buildResultList(results);
    });
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return Obx(() {
      final results = controller.filteredTaskVisitData;
      if (results.isEmpty && query.isEmpty) {
        return const Center(child: Text('Ketik untuk mencari...'));
      } else if (results.isEmpty) {
        return const Center(child: Text('Tidak ditemukan hasil.'));
      }
      return _buildResultList(results);
    });
  }

  Widget _buildResultList(List<Visit> visits) {
    return ListView.separated(
      itemCount: visits.length,
      separatorBuilder: (_, __) => const Divider(height: 0),
      itemBuilder: (context, index) {
        final visit = visits[index];
        return ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          tileColor: Colors.white,
          title: Text(
            visit.branchCode ?? 'Cabang Tidak Diketahui',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('PIC : ${visit.namaPic ?? '-'}'),
              Text('Tipe : ${visit.tipeVisit ?? '-'}'),
              Text('Tujuan : ${visit.tujuanVisit ?? '-'}'),
            ],
          ),
          onTap: () {
            close(context, null);
            Get.toNamed('/public/smile/task_view', arguments: visit);
          },
        );
      },
    );
  }
}
