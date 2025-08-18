import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class GaraCard extends StatefulWidget {
  final Map<String, dynamic> gara;
  final String garaId;
  final VoidCallback onTap;

  const GaraCard({
    super.key,
    required this.gara,
    required this.garaId,
    required this.onTap,
  });

  @override
  State<GaraCard> createState() => _GaraCardState();
}

class _GaraCardState extends State<GaraCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Card(
          margin: const EdgeInsets.only(bottom: 16),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(
              color: const Color(0xFFE5E7EB),
              width: 1,
            ),
          ),
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Colors.white,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header với ảnh và thông tin cơ bản
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Image Section
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          width: 90,
                          height: 90,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF3F4F6),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: _buildImageWidget(widget.gara),
                        ),
                      ),
                      const SizedBox(width: 20),
                      // Info Section
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Tên gara
                            Text(
                              widget.gara['name'] ?? 'Tên gara',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1F2937),
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),
                            
                            // Địa chỉ
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFEF3C7),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(
                                    Icons.location_on,
                                    size: 14,
                                    color: Color(0xFFF59E0B),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    widget.gara['address'] ?? 'Địa chỉ',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Color(0xFF6B7280),
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            
                            const SizedBox(height: 6),
                            
                            // Chủ gara
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFDBEAFE),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(
                                    Icons.person,
                                    size: 14,
                                    color: Color(0xFF3B82F6),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Chủ gara: ${widget.gara['ownerName'] ?? 'N/A'}',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: Color(0xFF6B7280),
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            
                            const SizedBox(height: 6),
                            
                            // Số điện thoại
                            if (widget.gara['phoneNumbers'] != null && (widget.gara['phoneNumbers'] as List).isNotEmpty)
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFD1FAE5),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(
                                      Icons.phone,
                                      size: 14,
                                      color: Color(0xFF10B981),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'SĐT: ${(widget.gara['phoneNumbers'] as List).first}',
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: Color(0xFF3B82F6),
                                        fontWeight: FontWeight.w500,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Footer với trạng thái, ngày tạo và thông tin khác
                  Row(
                    children: [
                      // Trạng thái
                      _buildStatusChip(widget.gara['status'] ?? 'Chưa xác định'),
                      
                      const Spacer(),
                      
                      // Thông tin bổ sung
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          // Ngày tạo
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF3E8FF),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.calendar_today,
                                  size: 12,
                                  color: Color(0xFF8B5CF6),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                _formatTimestamp(widget.gara['createdAt']),
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF6B7280),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          
                          const SizedBox(height: 4),
                          
                          // Số ảnh
                          if (widget.gara['imageUrls'] != null && (widget.gara['imageUrls'] as List).isNotEmpty)
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE0E7FF),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(
                                    Icons.photo_camera,
                                    size: 12,
                                    color: Color(0xFF6366F1),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  '${(widget.gara['imageUrls'] as List).length} ảnh',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF6B7280),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _formatTimestamp(dynamic timestamp) {
    if (timestamp == null) return 'N/A';
    
    if (timestamp is Timestamp) {
      final date = timestamp.toDate();
      final now = DateTime.now();
      final difference = now.difference(date);
      
      if (difference.inDays == 0) {
        return 'Hôm nay';
      } else if (difference.inDays == 1) {
        return 'Hôm qua';
      } else if (difference.inDays < 7) {
        return '${difference.inDays} ngày trước';
      } else {
        return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
      }
    }
    
    if (timestamp is String) {
      return timestamp;
    }
    
    return 'N/A';
  }

  Widget _buildStatusChip(String status) {
    Color chipColor;
    Color textColor;
    Color iconColor;
    IconData icon;

    switch (status) {
      case 'Hoạt động':
        chipColor = const Color(0xFFD1FAE5);
        textColor = const Color(0xFF065F46);
        iconColor = const Color(0xFF10B981);
        icon = Icons.check_circle;
        break;
      case 'Tạm ngưng':
        chipColor = const Color(0xFFFEF3C7);
        textColor = const Color(0xFF92400E);
        iconColor = const Color(0xFFF59E0B);
        icon = Icons.pause_circle;
        break;
      case 'Đang sửa chữa':
        chipColor = const Color(0xFFDBEAFE);
        textColor = const Color(0xFF1E40AF);
        iconColor = const Color(0xFF3B82F6);
        icon = Icons.build_circle;
        break;
      default:
        chipColor = const Color(0xFFF3F4F6);
        textColor = const Color(0xFF374151);
        iconColor = const Color(0xFF6B7280);
        icon = Icons.help;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: chipColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: iconColor.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: iconColor,
          ),
          const SizedBox(width: 6),
          Text(
            status,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageWidget(Map<String, dynamic> gara) {
    // Kiểm tra imageUrls trước (field mới)
    if (gara['imageUrls'] != null && (gara['imageUrls'] as List).isNotEmpty) {
      return Image.network(
        gara['imageUrls'][0],
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildDefaultIcon();
        },
      );
    }
    
    // Fallback cho imageUrl cũ
    if (gara['imageUrl'] != null) {
      return Image.network(
        gara['imageUrl'],
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildDefaultIcon();
        },
      );
    }
    
    return _buildDefaultIcon();
  }

  Widget _buildDefaultIcon() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Icon(
        Icons.business,
        size: 40,
        color: Color(0xFF9CA3AF),
      ),
    );
  }
}
