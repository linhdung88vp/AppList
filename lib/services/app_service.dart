import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';


class AppUpdateInfo {
  final String version;
  final String downloadUrl;
  final String changelog;
  final bool isForceUpdate;
  final DateTime releaseDate;

  AppUpdateInfo({
    required this.version,
    required this.downloadUrl,
    required this.changelog,
    required this.isForceUpdate,
    required this.releaseDate,
  });

  factory AppUpdateInfo.fromJson(Map<String, dynamic> json) {
    return AppUpdateInfo(
      version: json['version'] ?? '',
      downloadUrl: json['downloadUrl'] ?? '',
      changelog: json['changelog'] ?? '',
      isForceUpdate: json['isForceUpdate'] ?? false,
      releaseDate: DateTime.parse(json['releaseDate'] ?? DateTime.now().toIso8601String()),
    );
  }
}

class AppService {
  static const String _currentVersion = '1.0.0';
  static const String _updateCheckUrl = 'https://linhdung88vp.github.io/AppList/api/update.json'; // Thay thế bằng URL thật
  
  // Kiểm tra cập nhật
  static Future<AppUpdateInfo?> checkForUpdate() async {
    try {
      debugPrint('🔍 Đang kiểm tra cập nhật từ: $_updateCheckUrl');
      final response = await http.get(Uri.parse(_updateCheckUrl));
      
      debugPrint('📡 Response status: ${response.statusCode}');
      debugPrint('📄 Response body: ${response.body}');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final updateInfo = AppUpdateInfo.fromJson(data);
        
        debugPrint('📱 Phiên bản hiện tại: $_currentVersion');
        debugPrint('🆕 Phiên bản mới: ${updateInfo.version}');
        
        // So sánh phiên bản
        final comparison = _compareVersions(updateInfo.version, _currentVersion);
        debugPrint('⚖️ So sánh phiên bản: $comparison');
        
        if (comparison > 0) {
          debugPrint('✅ Có bản cập nhật mới!');
          return updateInfo;
        } else {
          debugPrint('ℹ️ Không có bản cập nhật mới');
        }
      } else {
        debugPrint('❌ HTTP Error: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('💥 Lỗi kiểm tra cập nhật: $e');
    }
    return null;
  }

  // So sánh phiên bản
  static int _compareVersions(String version1, String version2) {
    List<int> v1 = version1.split('.').map((e) => int.tryParse(e) ?? 0).toList();
    List<int> v2 = version2.split('.').map((e) => int.tryParse(e) ?? 0).toList();
    
    for (int i = 0; i < 3; i++) {
      int num1 = i < v1.length ? v1[i] : 0;
      int num2 = i < v2.length ? v2[i] : 0;
      
      if (num1 > num2) return 1;
      if (num1 < num2) return -1;
    }
    return 0;
  }

  // Tải xuống file cập nhật với progress
  static Future<String?> downloadUpdate(String downloadUrl, Function(double)? onProgress) async {
    try {
      final request = http.Request('GET', Uri.parse(downloadUrl));
      final streamedResponse = await http.Client().send(request);
      
      if (streamedResponse.statusCode == 200) {
        final directory = await getApplicationDocumentsDirectory();
        final file = File('${directory.path}/app_update.apk');
        final sink = file.openWrite();
        
        int downloaded = 0;
        final total = streamedResponse.contentLength ?? 0;
        
        await for (final chunk in streamedResponse.stream) {
          sink.add(chunk);
          downloaded += chunk.length;
          
          if (total > 0 && onProgress != null) {
            final progress = downloaded / total;
            onProgress(progress);
          }
        }
        
        await sink.close();
        return file.path;
      }
    } catch (e) {
      debugPrint('Lỗi tải xuống: $e');
    }
    return null;
  }

  // Cài đặt APK tự động
  static Future<bool> installApk(String apkPath) async {
    try {
      // Mở file APK để user cài đặt thủ công
      // (Cách này an toàn hơn và không cần quyền đặc biệt)
      return await openUpdateUrl('file://$apkPath');
    } catch (e) {
      debugPrint('Lỗi cài đặt APK: $e');
      return false;
    }
  }

  // Mở URL cập nhật
  static Future<bool> openUpdateUrl(String url) async {
    try {
      if (await canLaunchUrl(Uri.parse(url))) {
        return await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      debugPrint('Lỗi mở URL: $e');
    }
    return false;
  }

  // Lấy phiên bản hiện tại
  static String getCurrentVersion() {
    return _currentVersion;
  }

  // Kiểm tra xem có phải lần đầu chạy app không
  static Future<bool> isFirstRun() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isFirstRun') ?? true;
  }

  // Đánh dấu đã chạy lần đầu
  static Future<void> markFirstRunComplete() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isFirstRun', false);
  }
}
