import 'package:flutter/material.dart';
import '../models/gara.dart';
import '../screens/gara_detail_screen.dart';
import 'cached_image_widget.dart';

class GaraListItem extends StatelessWidget {
  final Gara gara;

  const GaraListItem({
    super.key,
    required this.gara,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => GaraDetailScreen(gara: gara),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header với tên và ảnh
              Row(
                children: [
                  // Ảnh gara
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.grey[200],
                    ),
                    child: gara.imageUrls.isNotEmpty
                        ? CachedImageWidget(
                            imageUrl: gara.imageUrls.first,
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                            borderRadius: BorderRadius.circular(8),
                            errorWidget: Icon(
                              Icons.car_repair,
                              size: 30,
                              color: Colors.grey[600],
                            ),
                          )
                        : Icon(
                            Icons.car_repair,
                            size: 30,
                            color: Colors.grey[600],
                          ),
                  ),
                  const SizedBox(width: 16),
                  
                  // Thông tin cơ bản
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          gara.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          gara.ownerName,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Icon mũi tên
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Colors.grey[400],
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Địa chỉ
              Row(
                children: [
                  Icon(
                    Icons.location_on,
                    size: 16,
                    color: Colors.red[400],
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      gara.address,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 8),
              
              // Số điện thoại
              Row(
                children: [
                  Icon(
                    Icons.phone,
                    size: 16,
                    color: Colors.green[600],
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      gara.phoneNumbers.join(', '),
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 8),
              
              // Footer với thời gian, người tạo và số ảnh
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tạo: ${_formatDate(gara.createdAt)}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[500],
                          ),
                        ),
                        if (gara.createdByName != null)
                          Text(
                            'Bởi: ${gara.createdByName}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[500],
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (gara.imageUrls.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.blue[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.photo,
                            size: 14,
                            color: Colors.blue[700],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${gara.imageUrls.length} ảnh',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.blue[700],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      return 'Hôm nay';
    } else if (difference.inDays == 1) {
      return 'Hôm qua';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} ngày trước';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
