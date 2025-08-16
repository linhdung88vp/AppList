import 'dart:io';
import 'package:image_picker/image_picker.dart';

class CameraService {
  static final ImagePicker _picker = ImagePicker();

  /// Chụp ảnh từ camera
  static Future<File?> takePhoto() async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 100, // Giữ chất lượng ảnh gốc
        preferredCameraDevice: CameraDevice.rear, // Ưu tiên camera sau
      );

      if (photo != null) {
        return File(photo.path);
      }
      return null;
    } catch (e) {
      print('Error taking photo: $e');
      rethrow;
    }
  }

  /// Chọn ảnh từ thư viện
  static Future<File?> pickImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 100, // Giữ chất lượng ảnh gốc
      );

      if (image != null) {
        return File(image.path);
      }
      return null;
    } catch (e) {
      print('Error picking image: $e');
      rethrow;
    }
  }

  /// Chọn nhiều ảnh từ thư viện
  static Future<List<File>> pickMultipleImages() async {
    try {
      final List<XFile> images = await _picker.pickMultiImage(
        imageQuality: 100, // Giữ chất lượng ảnh gốc
      );

      return images.map((xFile) => File(xFile.path)).toList();
    } catch (e) {
      print('Error picking multiple images: $e');
      rethrow;
    }
  }

  /// Kiểm tra quyền camera
  static Future<bool> checkCameraPermission() async {
    // Tạm thời trả về true, sẽ cập nhật sau khi có permission_handler
    return true;
  }

  /// Kiểm tra quyền thư viện ảnh
  static Future<bool> checkGalleryPermission() async {
    // Tạm thời trả về true, sẽ cập nhật sau khi có permission_handler
    return true;
  }

  /// Lấy ảnh demo (fallback)
  static List<String> getDemoImages() {
    return [
      'https://via.placeholder.com/300x200/FF6B6B/FFFFFF?text=Gara+1',
      'https://via.placeholder.com/300x200/4ECDC4/FFFFFF?text=Gara+2',
      'https://via.placeholder.com/300x200/45B7D1/FFFFFF?text=Gara+3',
    ];
  }
}
