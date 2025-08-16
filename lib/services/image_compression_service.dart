import 'dart:io';
import 'dart:typed_data';
import 'package:image/image.dart' as img;

class ImageCompressionService {
  /// Nén ảnh nếu kích thước > 2MB
  static Future<File> compressImageIfNeeded(File imageFile) async {
    try {
      // Kiểm tra kích thước file
      final int fileSizeInBytes = await imageFile.length();
      final double fileSizeInMB = fileSizeInBytes / (1024 * 1024);
      
      print('Kích thước ảnh: ${fileSizeInMB.toStringAsFixed(2)} MB');
      
      // Nếu ảnh < 2MB, không cần nén
      if (fileSizeInMB < 2.0) {
        print('Ảnh không cần nén');
        return imageFile;
      }
      
      print('Bắt đầu nén ảnh...');
      
      // Đọc ảnh
      final Uint8List bytes = await imageFile.readAsBytes();
      final img.Image? image = img.decodeImage(bytes);
      
      if (image == null) {
        print('Không thể đọc ảnh');
        return imageFile;
      }
      
      // Tính toán tỷ lệ nén
      double compressionRatio = 2.0 / fileSizeInMB;
      compressionRatio = compressionRatio.clamp(0.1, 0.9); // Giới hạn tỷ lệ nén
      
      // Tính kích thước mới
      int newWidth = (image.width * compressionRatio).round();
      int newHeight = (image.height * compressionRatio).round();
      
      // Đảm bảo kích thước tối thiểu
      newWidth = newWidth.clamp(800, image.width);
      newHeight = newHeight.clamp(600, image.height);
      
      print('Nén từ ${image.width}x${image.height} xuống ${newWidth}x${newHeight}');
      
      // Resize ảnh
      final img.Image resizedImage = img.copyResize(
        image,
        width: newWidth,
        height: newHeight,
        interpolation: img.Interpolation.linear,
      );
      
      // Encode ảnh với chất lượng 85%
      final List<int> compressedBytes = img.encodeJpg(resizedImage, quality: 85);
      
      // Tạo file mới
      final String originalPath = imageFile.path;
      final String compressedPath = originalPath.replaceAll('.jpg', '_compressed.jpg')
          .replaceAll('.jpeg', '_compressed.jpeg')
          .replaceAll('.png', '_compressed.jpg');
      
      final File compressedFile = File(compressedPath);
      await compressedFile.writeAsBytes(compressedBytes);
      
      // Kiểm tra kích thước sau khi nén
      final int compressedSizeInBytes = await compressedFile.length();
      final double compressedSizeInMB = compressedSizeInBytes / (1024 * 1024);
      
      print('Kích thước sau nén: ${compressedSizeInMB.toStringAsFixed(2)} MB');
      print('Tỷ lệ nén: ${(compressedSizeInMB / fileSizeInMB * 100).toStringAsFixed(1)}%');
      
      return compressedFile;
    } catch (e) {
      print('Lỗi khi nén ảnh: $e');
      return imageFile; // Trả về file gốc nếu có lỗi
    }
  }
  
  /// Nén nhiều ảnh
  static Future<List<File>> compressImagesIfNeeded(List<File> imageFiles) async {
    List<File> compressedFiles = [];
    
    for (int i = 0; i < imageFiles.length; i++) {
      print('Đang xử lý ảnh ${i + 1}/${imageFiles.length}');
      final File compressedFile = await compressImageIfNeeded(imageFiles[i]);
      compressedFiles.add(compressedFile);
    }
    
    return compressedFiles;
  }
  
  /// Kiểm tra xem ảnh có cần nén không
  static Future<bool> needsCompression(File imageFile) async {
    final int fileSizeInBytes = await imageFile.length();
    final double fileSizeInMB = fileSizeInBytes / (1024 * 1024);
    return fileSizeInMB > 2.0;
  }
  
  /// Lấy thông tin kích thước ảnh
  static Future<Map<String, dynamic>> getImageInfo(File imageFile) async {
    try {
      final int fileSizeInBytes = await imageFile.length();
      final double fileSizeInMB = fileSizeInBytes / (1024 * 1024);
      
      final Uint8List bytes = await imageFile.readAsBytes();
      final img.Image? image = img.decodeImage(bytes);
      
      if (image != null) {
        return {
          'width': image.width,
          'height': image.height,
          'sizeInMB': fileSizeInMB,
          'needsCompression': fileSizeInMB > 2.0,
        };
      }
      
      return {
        'sizeInMB': fileSizeInMB,
        'needsCompression': fileSizeInMB > 2.0,
      };
    } catch (e) {
      return {
        'error': e.toString(),
      };
    }
  }
}
