import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;

class ImgBBService {
  static const String _apiKey = '9e2838c1396782869df8176245167639'; // API key thực của bạn
  static const String _uploadUrl = 'https://api.imgbb.com/1/upload';

  /// Upload ảnh lên ImgBB và trả về URL
  static Future<String?> uploadImage(File imageFile) async {
    try {
      // Kiểm tra file tồn tại
      if (!await imageFile.exists()) {
        throw Exception('File ảnh không tồn tại');
      }

      // Kiểm tra kích thước file (ImgBB giới hạn 32MB)
      final fileSize = await imageFile.length();
      if (fileSize > 32 * 1024 * 1024) {
        throw Exception('File ảnh quá lớn (tối đa 32MB)');
      }

      // Đọc file ảnh
      List<int> imageBytes = await imageFile.readAsBytes();
      String base64Image = base64Encode(imageBytes);

      // Tạo form data
      Map<String, String> fields = {
        'key': _apiKey,
        'image': base64Image,
        'name': path.basename(imageFile.path),
      };

      // Gửi request
      http.MultipartRequest request = http.MultipartRequest('POST', Uri.parse(_uploadUrl));
      request.fields.addAll(fields);

      http.StreamedResponse response = await request.send();
      String responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        Map<String, dynamic> jsonResponse = json.decode(responseBody);
        
        if (jsonResponse['success'] == true) {
          Map<String, dynamic> data = jsonResponse['data'];
          return data['url']; // URL ảnh trực tiếp
        } else {
          print('ImgBB upload failed: ${jsonResponse['error']?.message}');
          return null;
        }
      } else {
        print('HTTP error: ${response.statusCode} - $responseBody');
        return null;
      }
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }

  /// Upload nhiều ảnh cùng lúc
  static Future<List<String>> uploadMultipleImages(List<File> imageFiles) async {
    List<String> uploadedUrls = [];
    
    for (File imageFile in imageFiles) {
      String? url = await uploadImage(imageFile);
      if (url != null) {
        uploadedUrls.add(url);
      }
    }
    
    return uploadedUrls;
  }

  /// Kiểm tra API key có hợp lệ không
  static Future<bool> validateApiKey() async {
    try {
      // Tạo một ảnh test nhỏ
      final testImage = File('test_image.txt');
      await testImage.writeAsString('test');
      
      String? result = await uploadImage(testImage);
      await testImage.delete();
      
      return result != null;
    } catch (e) {
      return false;
    }
  }

  /// Lấy thông tin ảnh từ URL ImgBB
  static Future<Map<String, dynamic>?> getImageInfo(String imageUrl) async {
    try {
      final response = await http.get(Uri.parse(imageUrl));
      if (response.statusCode == 200) {
        return {
          'url': imageUrl,
          'size': response.contentLength,
          'type': response.headers['content-type'],
        };
      }
      return null;
    } catch (e) {
      print('Error getting image info: $e');
      return null;
    }
  }
}
