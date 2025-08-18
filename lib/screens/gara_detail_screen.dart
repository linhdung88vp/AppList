import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/gara.dart';
import '../providers/gara_provider.dart';
import '../providers/auth_provider.dart';
import '../services/phone_service.dart';
import '../screens/image_viewer_screen.dart';

import '../widgets/cached_image_widget.dart';

class GaraDetailScreen extends StatelessWidget {
  final Gara gara;

  const GaraDetailScreen({
    super.key,
    required this.gara,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(gara.name),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        elevation: 2,
        actions: [
          // Nút chỉnh sửa (chỉ hiển thị cho admin hoặc người tạo gara)
          Consumer2<GaraProvider, AuthProvider>(
            builder: (context, garaProvider, authProvider, child) {
              final currentUser = authProvider.user;
              final isAdmin = garaProvider.isAdmin;
              final canEdit = isAdmin || (currentUser != null && gara.createdBy == currentUser.uid);
              
              if (!canEdit) return const SizedBox.shrink();
              
              return IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Tính năng chỉnh sửa đang phát triển')),
                  );
                },
                tooltip: 'Chỉnh sửa',
              );
            },
          ),
          // Nút xóa (chỉ hiển thị cho admin)
          if (context.watch<GaraProvider>().isAdmin)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => _showDeleteDialog(context),
              tooltip: 'Xóa gara',
              style: IconButton.styleFrom(
                foregroundColor: Colors.red,
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ảnh gara
            if (gara.imageUrls.isNotEmpty) ...[
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ImageViewerScreen(
                        imageUrls: gara.imageUrls,
                        initialIndex: 0,
                      ),
                    ),
                  );
                },
                child: Container(
                  width: double.infinity,
                  height: 200,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.grey[200],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Stack(
                      children: [
                        CachedImageListWidget(
                          imageUrls: gara.imageUrls,
                          width: double.infinity,
                          height: 200,
                          fit: BoxFit.cover,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        // Overlay để hiển thị icon zoom
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.black54,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Icon(
                              Icons.zoom_in,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // Chỉ báo số ảnh
              if (gara.imageUrls.length > 1)
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      '1 / ${gara.imageUrls.length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 24),
            ],

            // Thông tin cơ bản
            _buildInfoSection(
              title: 'Thông tin cơ bản',
              children: [
                _buildInfoRow('Tên gara:', gara.name),
                _buildInfoRow('Chủ gara:', gara.ownerName),
                _buildInfoRow('Địa chỉ:', gara.address),
                if (gara.status != null && gara.status!.isNotEmpty)
                  _buildInfoRow('Trạng thái:', gara.status!),
              ],
            ),

            const SizedBox(height: 16),

            // Thông tin liên hệ
            _buildInfoSection(
              title: 'Thông tin liên hệ',
              children: gara.phoneNumbers.map((phone) {
                return _buildInfoRow('Số điện thoại:', phone, isPhone: true);
              }).toList(),
            ),

            const SizedBox(height: 16),

            // Vị trí
            _buildInfoSection(
              title: 'Vị trí',
              children: [
                _buildInfoRow('Vĩ độ:', gara.location.latitude.toStringAsFixed(6)),
                _buildInfoRow('Kinh độ:', gara.location.longitude.toStringAsFixed(6)),
              ],
            ),

            const SizedBox(height: 16),

            // Ghi chú
            if (gara.notes != null && gara.notes!.isNotEmpty)
              _buildInfoSection(
                title: 'Ghi chú',
                children: [
                  _buildInfoRow('', gara.notes!),
                ],
              ),

            const SizedBox(height: 16),

            // Thông tin thời gian
            _buildInfoSection(
              title: 'Thông tin thời gian',
              children: [
                _buildInfoRow('Ngày tạo:', _formatDate(gara.createdAt)),
                _buildInfoRow('Cập nhật lần cuối:', _formatDate(gara.updatedAt)),
                if (gara.createdByEmail != null)
                  _buildInfoRow('Tạo bởi:', gara.createdByEmail!),
                if (gara.createdByName != null)
                  _buildInfoRow('Tên người tạo:', gara.createdByName!),
              ],
            ),

            const SizedBox(height: 32),

            // Nút hành động
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      PhoneService.showPhoneCallDialog(context, gara.phoneNumbers);
                    },
                    icon: const Icon(Icons.phone),
                    label: const Text('Gọi điện'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      try {
                        await PhoneService.openMap(
                          gara.location.latitude,
                          gara.location.longitude,
                          label: gara.name,
                        );
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Lỗi khi mở bản đồ: $e'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    },
                    icon: const Icon(Icons.directions),
                    label: const Text('Chỉ đường'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isPhone = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (label.isNotEmpty) ...[
            SizedBox(
              width: 100,
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[700],
                ),
              ),
            ),
            const SizedBox(width: 16),
          ],
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                color: isPhone ? Colors.blue[700] : Colors.grey[800],
                fontWeight: isPhone ? FontWeight.w500 : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Xác nhận xóa'),
          content: Text('Bạn có chắc chắn muốn xóa gara "${gara.name}"?\n\nHành động này không thể hoàn tác.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Hủy'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                
                try {
                  await context.read<GaraProvider>().deleteGara(gara.id!);
                  
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Đã xóa gara thành công'),
                        backgroundColor: Colors.green,
                      ),
                    );
                    // Quay về home screen thay vì màn hình trước
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Lỗi khi xóa gara: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: const Text('Xóa'),
            ),
          ],
        );
      },
    );
  }
}
