import 'package:flutter/material.dart';
import '../models/gara.dart';

class UserStatisticsWidget extends StatefulWidget {
  final List<Gara> allGaras;
  final List<Gara> filteredGaras;
  final int usersPerPage;

  const UserStatisticsWidget({
    super.key,
    required this.allGaras,
    required this.filteredGaras,
    this.usersPerPage = 10,
  });

  @override
  State<UserStatisticsWidget> createState() => _UserStatisticsWidgetState();
}

class _UserStatisticsWidgetState extends State<UserStatisticsWidget> {
  int _currentPage = 0;
  String _searchQuery = '';
  String _sortBy = 'count'; // count, name, percentage

  @override
  Widget build(BuildContext context) {
    // Nhóm gara theo user
    Map<String, List<Gara>> userGroups = {};
    for (Gara gara in widget.allGaras) {
      String userKey = gara.createdByEmail ?? 'Unknown';
      if (_searchQuery.isEmpty || 
          userKey.toLowerCase().contains(_searchQuery.toLowerCase())) {
        userGroups.putIfAbsent(userKey, () => []).add(gara);
      }
    }

    // Sắp xếp theo tiêu chí
    List<MapEntry<String, List<Gara>>> sortedUsers = userGroups.entries.toList();
    switch (_sortBy) {
      case 'count':
        sortedUsers.sort((a, b) => b.value.length.compareTo(a.value.length));
        break;
      case 'name':
        sortedUsers.sort((a, b) => a.key.compareTo(b.key));
        break;
      case 'percentage':
        sortedUsers.sort((a, b) {
          final aPeriodCount = widget.filteredGaras
              .where((gara) => gara.createdByEmail == a.key).length;
          final bPeriodCount = widget.filteredGaras
              .where((gara) => gara.createdByEmail == b.key).length;
          final aPercentage = a.value.isEmpty ? 0 : (aPeriodCount / a.value.length);
          final bPercentage = b.value.isEmpty ? 0 : (bPeriodCount / b.value.length);
          return bPercentage.compareTo(aPercentage);
        });
        break;
    }

    // Phân trang
    final totalPages = (sortedUsers.length / widget.usersPerPage).ceil();
    final startIndex = _currentPage * widget.usersPerPage;
    final endIndex = (startIndex + widget.usersPerPage).clamp(0, sortedUsers.length);
    final currentPageUsers = sortedUsers.sublist(startIndex, endIndex);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header với tìm kiếm và sắp xếp
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Thống kê theo User',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${sortedUsers.length} users',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Tìm kiếm
            TextField(
              decoration: const InputDecoration(
                hintText: 'Tìm kiếm user...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                  _currentPage = 0; // Reset về trang đầu
                });
              },
            ),
            const SizedBox(height: 12),

            // Sắp xếp
            Row(
              children: [
                const Text('Sắp xếp theo: '),
                const SizedBox(width: 8),
                DropdownButton<String>(
                  value: _sortBy,
                  items: const [
                    DropdownMenuItem(value: 'count', child: Text('Số lượng')),
                    DropdownMenuItem(value: 'name', child: Text('Tên')),
                    DropdownMenuItem(value: 'percentage', child: Text('Phần trăm')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _sortBy = value!;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Danh sách user
            if (currentPageUsers.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: Text('Không tìm thấy user nào'),
                ),
              )
            else
              ...currentPageUsers.map((entry) {
                final userEmail = entry.key;
                final userGaras = entry.value;
                final periodGaras = widget.filteredGaras
                    .where((gara) => gara.createdByEmail == userEmail).length;
                final percentage = userGaras.isEmpty 
                    ? 0.0 
                    : (periodGaras / userGaras.length) * 100;
                
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: _getUserColor(userEmail),
                      child: Text(
                        userEmail.substring(0, 1).toUpperCase(),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    title: Text(
                      userEmail,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${userGaras.length} gara tổng cộng'),
                        const SizedBox(height: 4),
                        LinearProgressIndicator(
                          value: percentage / 100,
                          backgroundColor: Colors.grey[200],
                          valueColor: AlwaysStoppedAnimation<Color>(
                            _getPercentageColor(percentage),
                          ),
                        ),
                      ],
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '$periodGaras trong kỳ',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                        Text(
                          '${percentage.toStringAsFixed(1)}%',
                          style: TextStyle(
                            fontSize: 10,
                            color: _getPercentageColor(percentage),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    onTap: () => _showUserDetail(userEmail, userGaras, periodGaras),
                  ),
                );
              }).toList(),

            // Phân trang
            if (totalPages > 1) ...[
              const SizedBox(height: 16),
              _buildPagination(totalPages),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPagination(int totalPages) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.first_page),
          onPressed: _currentPage > 0
              ? () => setState(() => _currentPage = 0)
              : null,
        ),
        IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: _currentPage > 0
              ? () => setState(() => _currentPage--)
              : null,
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            '${_currentPage + 1} / $totalPages',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.chevron_right),
          onPressed: _currentPage < totalPages - 1
              ? () => setState(() => _currentPage++)
              : null,
        ),
        IconButton(
          icon: const Icon(Icons.last_page),
          onPressed: _currentPage < totalPages - 1
              ? () => setState(() => _currentPage = totalPages - 1)
              : null,
        ),
      ],
    );
  }

  Color _getUserColor(String email) {
    // Tạo màu dựa trên email để mỗi user có màu khác nhau
    int hash = email.hashCode;
    return Color.fromARGB(255, hash % 256, (hash >> 8) % 256, (hash >> 16) % 256);
  }

  Color _getPercentageColor(double percentage) {
    if (percentage >= 80) return Colors.green;
    if (percentage >= 60) return Colors.orange;
    if (percentage >= 40) return Colors.yellow[700]!;
    return Colors.red;
  }

  void _showUserDetail(String userEmail, List<Gara> userGaras, int periodGaras) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Chi tiết: $userEmail'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Tổng số gara: ${userGaras.length}'),
            Text('Gara trong kỳ: $periodGaras'),
            Text('Tỷ lệ: ${((periodGaras / userGaras.length) * 100).toStringAsFixed(1)}%'),
            const SizedBox(height: 16),
            const Text('Danh sách gara:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            SizedBox(
              height: 200,
              child: ListView.builder(
                itemCount: userGaras.length,
                itemBuilder: (context, index) {
                  final gara = userGaras[index];
                  final isInPeriod = widget.filteredGaras.contains(gara);
                  return ListTile(
                    leading: Icon(
                      isInPeriod ? Icons.check_circle : Icons.circle_outlined,
                      color: isInPeriod ? Colors.green : Colors.grey,
                    ),
                    title: Text(gara.name),
                    subtitle: Text(gara.address),
                    trailing: Text(
                      gara.createdAt.toString().substring(0, 10),
                      style: const TextStyle(fontSize: 12),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }
}
