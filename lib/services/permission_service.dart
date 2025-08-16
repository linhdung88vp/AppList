import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';

class PermissionService {
  /// Kiểm tra và yêu cầu tất cả quyền cần thiết
  /// Trả về true nếu có đủ quyền, false nếu không và thoát app
  static Future<bool> checkAndRequestPermissions(BuildContext context) async {
    try {
      // Kiểm tra quyền camera
      PermissionStatus cameraStatus = await Permission.camera.status;
      if (cameraStatus.isDenied) {
        cameraStatus = await Permission.camera.request();
      }

      // Kiểm tra quyền vị trí
      PermissionStatus locationStatus = await Permission.location.status;
      if (locationStatus.isDenied) {
        locationStatus = await Permission.location.request();
      }

      // Nếu bất kỳ quyền nào bị từ chối hoặc bị chặn vĩnh viễn
      if (cameraStatus.isDenied || cameraStatus.isPermanentlyDenied ||
          locationStatus.isDenied || locationStatus.isPermanentlyDenied) {
        
        // Hiển thị dialog giải thích
        bool shouldOpenSettings = await _showPermissionDialog(context);
        
        if (shouldOpenSettings) {
          // Mở cài đặt app
          await openAppSettings();
          // Đợi một chút rồi kiểm tra lại
          await Future.delayed(const Duration(seconds: 2));
          return await checkAndRequestPermissions(context);
        } else {
          // Thoát app
          exit(0);
        }
      }

      // Kiểm tra lại lần cuối
      if (cameraStatus.isGranted && locationStatus.isGranted) {
        return true;
      } else {
        // Nếu vẫn không có quyền, thoát app
        exit(0);
      }
    } catch (e) {
      debugPrint('Lỗi kiểm tra quyền: $e');
      // Nếu có lỗi, thoát app
      exit(0);
    }
    return false;
  }

  /// Hiển thị dialog yêu cầu quyền
  static Future<bool> _showPermissionDialog(BuildContext context) async {
    return await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.warning, color: Colors.red, size: 28),
              SizedBox(width: 8),
              Text('Quyền cần thiết'),
            ],
          ),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Ứng dụng cần các quyền sau để hoạt động:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.camera_alt, color: Colors.blue, size: 20),
                  SizedBox(width: 8),
                  Text('• Camera: Chụp ảnh gara'),
                ],
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.location_on, color: Colors.green, size: 20),
                  SizedBox(width: 8),
                  Text('• Vị trí: Xác định tọa độ gara'),
                ],
              ),
              SizedBox(height: 16),
              Text(
                'Nếu không cấp quyền, ứng dụng sẽ thoát.',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text('Thoát app'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
              child: const Text('Mở cài đặt'),
            ),
          ],
        );
      },
    ) ?? false;
  }

  /// Kiểm tra quyền camera
  static Future<bool> checkCameraPermission() async {
    PermissionStatus status = await Permission.camera.status;
    return status.isGranted;
  }

  /// Kiểm tra quyền vị trí
  static Future<bool> checkLocationPermission() async {
    PermissionStatus status = await Permission.location.status;
    return status.isGranted;
  }

  /// Yêu cầu quyền camera
  static Future<bool> requestCameraPermission() async {
    PermissionStatus status = await Permission.camera.request();
    return status.isGranted;
  }

  /// Yêu cầu quyền vị trí
  static Future<bool> requestLocationPermission() async {
    PermissionStatus status = await Permission.location.request();
    return status.isGranted;
  }
}
