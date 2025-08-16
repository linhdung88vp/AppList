import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class FreeImageService {
  static const String _baseUrl = 'https://freeimage.host/api/1/upload';
  static const String _apiKey = '6d207e02198a847aa98d0a2a901485a5'; // API key mẫu, cần thay thế bằng key thật

  /// Upload ảnh lên FreeImage.host
  static Future<String?> uploadImage(File imageFile) async {
    try {
      // Tạo multipart request
      var request = http.MultipartRequest('POST', Uri.parse(_baseUrl));
      
      // Thêm API key
      request.fields['key'] = _apiKey;
      
      // Thêm file ảnh
      var stream = http.ByteStream(imageFile.openRead());
      var length = await imageFile.length();
      
      var multipartFile = http.MultipartFile(
        'source',
        stream,
        length,
        filename: imageFile.path.split('/').last,
      );
      
      request.files.add(multipartFile);
      
      // Gửi request
      var response = await request.send();
      var responseData = await response.stream.bytesToString();
      var jsonData = json.decode(responseData);
      
      if (response.statusCode == 200) {
        if (jsonData['success'] != null && jsonData['image'] != null) {
          // Trả về URL ảnh
          return jsonData['image']['url'];
        } else if (jsonData['error'] != null) {
          print('Lỗi upload ảnh: ${jsonData['error']}');
          return null;
        } else {
          print('Response không có success hoặc image field');
          return null;
        }
      } else {
        print('HTTP Error: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Lỗi khi upload ảnh: $e');
      return null;
    }
  }

  /// Upload nhiều ảnh
  static Future<List<String>> uploadImages(List<File> imageFiles) async {
    List<String> uploadedUrls = [];
    
    for (File imageFile in imageFiles) {
      String? url = await uploadImage(imageFile);
      if (url != null) {
        uploadedUrls.add(url);
      }
    }
    
    return uploadedUrls;
  }

  /// Kiểm tra trạng thái API
  static Future<bool> checkApiStatus() async {
    try {
      var response = await http.get(Uri.parse('https://freeimage.host/api/1/upload'));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
