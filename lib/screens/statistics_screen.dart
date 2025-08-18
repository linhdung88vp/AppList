import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/gara_provider.dart';
import '../providers/auth_provider.dart';
import '../models/gara.dart';
import '../services/app_service.dart';
import '../widgets/user_statistics_widget.dart';
import '../widgets/export_report_widget.dart';
import '../widgets/update_progress_widget.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  String _selectedPeriod = 'today'; // today, week, month, custom, all
  DateTime? _customStartDate;
  DateTime? _customEndDate;
  final int _usersPerPage = 10;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thống kê Gara'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.system_update, color: Colors.white),
            onPressed: _checkForUpdate,
            tooltip: 'Kiểm tra cập nhật',
          ),
        ],
      ),
      body: Consumer2<GaraProvider, AuthProvider>(
        builder: (context, garaProvider, authProvider, child) {
          final List<Gara> allGaras = garaProvider.garas;
          final currentUser = authProvider.user;
          final isAdmin = garaProvider.isAdmin;
          
          if (allGaras.isEmpty) {
            return const Center(
              child: Text('Chưa có dữ liệu thống kê'),
            );
          }

          // Lọc gara theo quyền và thời gian
          List<Gara> accessibleGaras = allGaras;
          if (!isAdmin) {
            // User chỉ thấy gara của mình
            accessibleGaras = allGaras.where((gara) => gara.createdBy == currentUser?.uid).toList();
          }
          
          final List<Gara> filteredGaras = _filterGarasByPeriod(accessibleGaras, _selectedPeriod);
          
          // Thống kê tổng quan
          final totalGaras = accessibleGaras.length;
          final periodGaras = filteredGaras.length;
          final userGaras = accessibleGaras.where((gara) => gara.createdBy == currentUser?.uid).length;
          final userPeriodGaras = filteredGaras.where((gara) => gara.createdBy == currentUser?.uid).length;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Hiển thị role
                _buildRoleInfo(isAdmin),
                const SizedBox(height: 16),
                
                // Bộ lọc thời gian
                _buildPeriodFilter(),
                const SizedBox(height: 24),

                // Thống kê tổng quan
                _buildOverviewCards(totalGaras, periodGaras, userGaras, userPeriodGaras, isAdmin),
                const SizedBox(height: 24),

                // Thống kê theo user (chỉ admin) với phân trang
                if (isAdmin) ...[
                  UserStatisticsWidget(
                    allGaras: allGaras,
                    filteredGaras: filteredGaras,
                    usersPerPage: _usersPerPage,
                  ),
                  const SizedBox(height: 24),
                ],

                // Xuất báo cáo
                ExportReportWidget(
                  allGaras: accessibleGaras,
                  filteredGaras: filteredGaras,
                  selectedPeriod: _selectedPeriod,
                  customStartDate: _customStartDate,
                  customEndDate: _customEndDate,
                ),
                const SizedBox(height: 24),

                // Thống kê theo khu vực
                _buildAreaStatistics(accessibleGaras),
                const SizedBox(height: 24),

                // Biểu đồ thời gian
                _buildTimeChart(accessibleGaras),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildRoleInfo(bool isAdmin) {
    return Card(
      color: isAdmin ? Colors.blue[50] : Colors.green[50],
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Icon(
              isAdmin ? Icons.admin_panel_settings : Icons.person,
              color: isAdmin ? Colors.blue[700] : Colors.green[700],
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isAdmin ? 'Quản trị viên' : 'Người dùng',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isAdmin ? Colors.blue[700] : Colors.green[700],
                    ),
                  ),
                  Text(
                    isAdmin 
                        ? 'Có thể xem thống kê của tất cả người dùng'
                        : 'Chỉ xem thống kê của bạn',
                    style: TextStyle(
                      fontSize: 12,
                      color: isAdmin ? Colors.blue[600] : Colors.green[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodFilter() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Chọn thời gian',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: [
                _buildPeriodChip('today', 'Hôm nay'),
                _buildPeriodChip('week', 'Tuần này'),
                _buildPeriodChip('month', 'Tháng này'),
                _buildPeriodChip('custom', 'Tùy chọn'),
                _buildPeriodChip('all', 'Tất cả'),
              ],
            ),
            if (_selectedPeriod == 'custom') ...[
              const SizedBox(height: 16),
              _buildCustomDatePicker(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCustomDatePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: _buildDateField(
                'Từ ngày',
                _customStartDate,
                (date) => setState(() => _customStartDate = date),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildDateField(
                'Đến ngày',
                _customEndDate,
                (date) => setState(() => _customEndDate = date),
              ),
            ),
          ],
        ),
        if (_customStartDate != null && _customEndDate != null) ...[
          const SizedBox(height: 12),
          Text(
            'Khoảng thời gian: ${DateFormat('dd/MM/yyyy').format(_customStartDate!)} - ${DateFormat('dd/MM/yyyy').format(_customEndDate!)}',
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildDateField(String label, DateTime? date, Function(DateTime?) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 4),
        InkWell(
          onTap: () async {
            final selectedDate = await showDatePicker(
              context: context,
              initialDate: date ?? DateTime.now(),
              firstDate: DateTime(2020),
              lastDate: DateTime.now(),
            );
            if (selectedDate != null) {
              onChanged(selectedDate);
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today, size: 16, color: Colors.grey.shade600),
                const SizedBox(width: 8),
                Text(
                  date != null 
                      ? DateFormat('dd/MM/yyyy').format(date)
                      : 'Chọn ngày',
                  style: TextStyle(
                    color: date != null ? Colors.black : Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPeriodChip(String period, String label) {
    final isSelected = _selectedPeriod == period;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedPeriod = period;
          if (period != 'custom') {
            _customStartDate = null;
            _customEndDate = null;
          }
        });
      },
      selectedColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
    );
  }

  Widget _buildOverviewCards(int total, int period, int userTotal, int userPeriod, bool isAdmin) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: [
        _buildStatCard(
          'Tổng gara',
          total.toString(),
          Icons.business,
          Colors.blue,
        ),
        _buildStatCard(
          'Gara trong kỳ',
          period.toString(),
          Icons.trending_up,
          Colors.green,
        ),
        _buildStatCard(
          isAdmin ? 'Gara của bạn' : 'Tổng gara',
          userTotal.toString(),
          Icons.person,
          Colors.orange,
        ),
        _buildStatCard(
          isAdmin ? 'Gara của bạn trong kỳ' : 'Gara trong kỳ',
          userPeriod.toString(),
          Icons.star,
          Colors.purple,
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 28, color: color),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              title,
              style: const TextStyle(
                fontSize: 10,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }



  Widget _buildAreaStatistics(List<Gara> garas) {
    // Nhóm gara theo khu vực (dựa trên địa chỉ)
    Map<String, int> areaStats = {};
    for (Gara gara in garas) {
      String area = _extractArea(gara.address);
      areaStats[area] = (areaStats[area] ?? 0) + 1;
    }

    // Sắp xếp theo số lượng giảm dần
    List<MapEntry<String, int>> sortedAreas = areaStats.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Thống kê theo Khu vực',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...sortedAreas.take(5).map((entry) {
              final percentage = (entry.value / garas.length * 100).toStringAsFixed(1);
              return ListTile(
                leading: const Icon(Icons.location_on, color: Colors.red),
                title: Text(entry.key),
                subtitle: Text('$percentage%'),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${entry.value}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeChart(List<Gara> garas) {
    // Nhóm gara theo ngày
    Map<String, int> dailyStats = {};
    for (Gara gara in garas) {
      String date = DateFormat('dd/MM').format(gara.createdAt);
      dailyStats[date] = (dailyStats[date] ?? 0) + 1;
    }

    // Sắp xếp theo ngày
    List<MapEntry<String, int>> sortedDays = dailyStats.entries.toList()
      ..sort((a, b) {
        DateTime dateA = DateFormat('dd/MM').parse(a.key);
        DateTime dateB = DateFormat('dd/MM').parse(b.key);
        return dateA.compareTo(dateB);
      });

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Thống kê theo Thời gian',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: sortedDays.isEmpty
                  ? const Center(child: Text('Không có dữ liệu'))
                  : ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: sortedDays.length,
                      itemBuilder: (context, index) {
                        final entry = sortedDays[index];
                        final maxValue = sortedDays.map((e) => e.value).reduce((a, b) => a > b ? a : b);
                        final height = (entry.value / maxValue) * 150;
                        
                        return Container(
                          width: 60,
                          margin: const EdgeInsets.only(right: 8),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Container(
                                width: 40,
                                height: height,
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.primary,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Center(
                                  child: Text(
                                    '${entry.value}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                entry.key,
                                style: const TextStyle(fontSize: 10),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  List<Gara> _filterGarasByPeriod(List<Gara> garas, String period) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    switch (period) {
      case 'today':
        return garas.where((gara) => gara.createdAt.isAfter(today)).toList();
      case 'week':
        final weekAgo = today.subtract(const Duration(days: 7));
        return garas.where((gara) => gara.createdAt.isAfter(weekAgo)).toList();
      case 'month':
        final monthAgo = DateTime(now.year, now.month - 1, now.day);
        return garas.where((gara) => gara.createdAt.isAfter(monthAgo)).toList();
      case 'custom':
        if (_customStartDate != null && _customEndDate != null) {
          final startDate = DateTime(_customStartDate!.year, _customStartDate!.month, _customStartDate!.day);
          final endDate = DateTime(_customEndDate!.year, _customEndDate!.month, _customEndDate!.day, 23, 59, 59);
          return garas.where((gara) => 
            gara.createdAt.isAfter(startDate.subtract(const Duration(seconds: 1))) &&
            gara.createdAt.isBefore(endDate.add(const Duration(seconds: 1)))
          ).toList();
        }
        return garas;
      case 'all':
      default:
        return garas;
    }
  }

  String _extractArea(String address) {
    // Tách khu vực từ địa chỉ
    List<String> parts = address.split(',');
    if (parts.length >= 2) {
      return parts[parts.length - 2].trim();
    }
    return address;
  }

  Future<void> _checkForUpdate() async {
    try {
      final updateInfo = await AppService.checkForUpdate();
      
      if (updateInfo != null) {
        _showUpdateDialog(updateInfo);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Ứng dụng đã là phiên bản mới nhất!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi kiểm tra cập nhật: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showUpdateDialog(AppUpdateInfo updateInfo) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => UpdateProgressWidget(
        updateInfo: updateInfo,
        onUpdateComplete: () {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Cập nhật thành công! Ứng dụng sẽ khởi động lại.'),
              backgroundColor: Colors.green,
            ),
          );
        },
        onUpdateFailed: () {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Cập nhật thất bại. Vui lòng thử lại.'),
              backgroundColor: Colors.red,
            ),
          );
        },
      ),
    );
  }
}
