import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/gara.dart';
import '../providers/gara_provider.dart';
import '../config/firebase_config.dart';
import 'gara_form.dart';
import 'gara_detail_view.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final isFirebase = FirebaseConfig.isInitialized;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản trị Gara'),
        actions: [
          IconButton(
            tooltip: 'Thêm gara',
            onPressed: () async {
              final created = await showDialog<bool>(
                context: context,
                builder: (context) => const Dialog(child: SizedBox(width: 640, child: GaraForm())),
              );
              if (created == true && mounted) setState(() {});
            },
            icon: const Icon(Icons.add),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchCtrl,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.search),
                      hintText: 'Tìm theo tên, địa chỉ, SĐT...',
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: isFirebase ? _buildOnlineTable() : _buildLocalTable(context),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildOnlineTable() {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseConfig.garasCollection.orderBy('createdAt', descending: true).snapshots(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snap.hasError) {
          return Center(child: Text('Lỗi: ${snap.error}'));
        }
        final docs = snap.data?.docs ?? [];
        final rows = docs.map((d) => Gara.fromFirestore(d)).where((g) {
          final q = _searchCtrl.text.trim().toLowerCase();
          if (q.isEmpty) return true;
          return g.name.toLowerCase().contains(q) ||
              g.address.toLowerCase().contains(q) ||
              g.ownerName.toLowerCase().contains(q) ||
              g.phoneNumbers.any((p) => p.contains(q));
        }).toList();

        return _buildDataTable(rows, onDelete: (id) async {
          await FirebaseConfig.garasCollection.doc(id).delete();
        });
      },
    );
  }

  Widget _buildLocalTable(BuildContext context) {
    final provider = context.watch<GaraProvider>();
    final q = _searchCtrl.text.trim().toLowerCase();
    final rows = provider.garas.where((g) {
      if (q.isEmpty) return true;
      return g.name.toLowerCase().contains(q) ||
          g.address.toLowerCase().contains(q) ||
          g.ownerName.toLowerCase().contains(q) ||
          g.phoneNumbers.any((p) => p.contains(q));
    }).toList();
    return _buildDataTable(rows);
  }

  Widget _buildDataTable(List<Gara> rows, {Future<void> Function(String id)? onDelete}) {
    return LayoutBuilder(builder: (context, c) {
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: const [
            DataColumn(label: Text('Ảnh')),
            DataColumn(label: Text('Tên Gara')),
            DataColumn(label: Text('Địa chỉ')),
            DataColumn(label: Text('Số điện thoại')),
            DataColumn(label: Text('Trạng thái')),
            DataColumn(label: Text('Hành động')),
          ],
          rows: rows.map((g) {
            final thumb = g.imageUrls.isNotEmpty ? g.imageUrls.first : null;
            return DataRow(cells: [
              DataCell(
                thumb == null
                    ? const Icon(Icons.image_not_supported)
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: CachedNetworkImage(
                          imageUrl: thumb,
                          width: 56,
                          height: 40,
                          fit: BoxFit.cover,
                        ),
                      ),
              ),
              DataCell(Text(g.name)),
              DataCell(SizedBox(width: 360, child: Text(g.address))),
              DataCell(Text(g.phoneNumbers.join(', '))),
              DataCell(Text(g.status ?? 'Hoạt động')),
              DataCell(Row(
                children: [
                  TextButton.icon(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (_) => GaraDetailView(gara: g),
                      );
                    },
                    icon: const Icon(Icons.visibility),
                    label: const Text('Xem'),
                  ),
                  const SizedBox(width: 4),
                  TextButton.icon(
                    onPressed: () async {
                      final updated = await showDialog<bool>(
                        context: context,
                        builder: (context) => Dialog(
                          child: SizedBox(width: 640, child: GaraForm(gara: g)),
                        ),
                      );
                      if (updated == true && mounted) setState(() {});
                    },
                    icon: const Icon(Icons.edit),
                    label: const Text('Sửa'),
                  ),
                  const SizedBox(width: 4),
                  TextButton.icon(
                    onPressed: onDelete == null || g.id == null
                        ? null
                        : () async {
                            final ok = await showDialog<bool>(
                              context: context,
                              builder: (_) => AlertDialog(
                                title: const Text('Xác nhận xoá'),
                                content: Text('Xoá gara "${g.name}"?'),
                                actions: [
                                  TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Huỷ')),
                                  TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Xoá')),
                                ],
                              ),
                            );
                            if (ok == true) {
                              await onDelete(g.id!);
                            }
                          },
                    icon: const Icon(Icons.delete, color: Colors.red),
                    label: const Text('Xoá', style: TextStyle(color: Colors.red)),
                  )
                ],
              )),
            ]);
          }).toList(),
        ),
      );
    });
  }
}
