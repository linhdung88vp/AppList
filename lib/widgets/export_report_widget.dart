import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/gara.dart';

class ExportReportWidget extends StatelessWidget {
  final List<Gara> allGaras;
  final List<Gara> filteredGaras;
  final String selectedPeriod;
  final DateTime? customStartDate;
  final DateTime? customEndDate;

  const ExportReportWidget({
    super.key,
    required this.allGaras,
    required this.filteredGaras,
    required this.selectedPeriod,
    this.customStartDate,
    this.customEndDate,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Xuất báo cáo',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _exportToPDF(context),
                    icon: const Icon(Icons.picture_as_pdf),
                    label: const Text('PDF'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _exportToExcel(context),
                    icon: const Icon(Icons.table_chart),
                    label: const Text('Excel'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () => _shareReport(context),
              icon: const Icon(Icons.share),
              label: const Text('Chia sẻ báo cáo'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _exportToPDF(BuildContext context) {
    // TODO: Implement PDF export
    _showExportDialog(context, 'PDF', 'Đang xuất báo cáo PDF...');
  }

  void _exportToExcel(BuildContext context) {
    // TODO: Implement Excel export
    _showExportDialog(context, 'Excel', 'Đang xuất báo cáo Excel...');
  }

  void _shareReport(BuildContext context) {
    final reportData = _generateReportData();
    final shareText = _formatReportForSharing(reportData);
    
    // TODO: Implement sharing functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Chia sẻ báo cáo: $shareText'),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showExportDialog(BuildContext context, String format, String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text('Xuất báo cáo $format'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(message),
          ],
        ),
      ),
    );

    // Simulate export process
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.of(context).pop();
      _showExportSuccessDialog(context, format);
    });
  }

  void _showExportSuccessDialog(BuildContext context, String format) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Xuất báo cáo thành công'),
        content: Text('Báo cáo $format đã được xuất thành công!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Đóng'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // TODO: Open file or share
            },
            child: const Text('Mở file'),
          ),
        ],
      ),
    );
  }

  Map<String, dynamic> _generateReportData() {
    final now = DateTime.now();
    final periodText = _getPeriodText();
    
    // Thống kê tổng quan
    final totalGaras = allGaras.length;
    final periodGaras = filteredGaras.length;
    
    // Thống kê theo user
    Map<String, int> userStats = {};
    for (Gara gara in allGaras) {
      String userEmail = gara.createdByEmail ?? 'Unknown';
      userStats[userEmail] = (userStats[userEmail] ?? 0) + 1;
    }
    
    // Thống kê theo khu vực
    Map<String, int> areaStats = {};
    for (Gara gara in allGaras) {
      String area = _extractArea(gara.address);
      areaStats[area] = (areaStats[area] ?? 0) + 1;
    }
    
    // Thống kê theo thời gian
    Map<String, int> timeStats = {};
    for (Gara gara in allGaras) {
      String date = DateFormat('dd/MM/yyyy').format(gara.createdAt);
      timeStats[date] = (timeStats[date] ?? 0) + 1;
    }

    return {
      'reportDate': DateFormat('dd/MM/yyyy HH:mm').format(now),
      'period': periodText,
      'totalGaras': totalGaras,
      'periodGaras': periodGaras,
      'userStats': userStats,
      'areaStats': areaStats,
      'timeStats': timeStats,
    };
  }

  String _getPeriodText() {
    switch (selectedPeriod) {
      case 'today':
        return 'Hôm nay';
      case 'week':
        return 'Tuần này';
      case 'month':
        return 'Tháng này';
      case 'custom':
        if (customStartDate != null && customEndDate != null) {
          return 'Từ ${DateFormat('dd/MM/yyyy').format(customStartDate!)} đến ${DateFormat('dd/MM/yyyy').format(customEndDate!)}';
        }
        return 'Tùy chọn';
      case 'all':
      default:
        return 'Tất cả';
    }
  }

  String _extractArea(String address) {
    List<String> parts = address.split(',');
    if (parts.length >= 2) {
      return parts[parts.length - 2].trim();
    }
    return address;
  }

  String _formatReportForSharing(Map<String, dynamic> data) {
    final buffer = StringBuffer();
    buffer.writeln('📊 BÁO CÁO THỐNG KÊ GARA');
    buffer.writeln('📅 Ngày xuất: ${data['reportDate']}');
    buffer.writeln('⏰ Kỳ báo cáo: ${data['period']}');
    buffer.writeln('');
    buffer.writeln('📈 THỐNG KÊ TỔNG QUAN:');
    buffer.writeln('• Tổng số gara: ${data['totalGaras']}');
    buffer.writeln('• Gara trong kỳ: ${data['periodGaras']}');
    buffer.writeln('• Tỷ lệ: ${((data['periodGaras'] / data['totalGaras']) * 100).toStringAsFixed(1)}%');
    buffer.writeln('');
    
    // Top 5 user
    final sortedUsers = (data['userStats'] as Map<String, int>).entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    buffer.writeln('👥 TOP 5 USER:');
    for (int i = 0; i < sortedUsers.length && i < 5; i++) {
      final entry = sortedUsers[i];
      buffer.writeln('${i + 1}. ${entry.key}: ${entry.value} gara');
    }
    buffer.writeln('');
    
    // Top 5 khu vực
    final sortedAreas = (data['areaStats'] as Map<String, int>).entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    buffer.writeln('📍 TOP 5 KHU VỰC:');
    for (int i = 0; i < sortedAreas.length && i < 5; i++) {
      final entry = sortedAreas[i];
      buffer.writeln('${i + 1}. ${entry.key}: ${entry.value} gara');
    }
    
    return buffer.toString();
  }
}
