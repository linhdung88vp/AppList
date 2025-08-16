import '../models/gara.dart';
import 'dart:math';

class ValidationService {
  /// Kiểm tra trùng lặp gara
  static List<String> checkDuplicateGara(Gara newGara, List<Gara> existingGaras) {
    List<String> duplicates = [];
    
    for (Gara existingGara in existingGaras) {
      // Kiểm tra trùng tên gara
      if (newGara.name.toLowerCase().trim() == existingGara.name.toLowerCase().trim()) {
        duplicates.add('Tên gara "${existingGara.name}" đã tồn tại');
      }
      
      // Kiểm tra trùng số điện thoại
      for (String newPhone in newGara.phoneNumbers) {
        for (String existingPhone in existingGara.phoneNumbers) {
          if (newPhone.replaceAll(RegExp(r'[^\d]'), '') == 
              existingPhone.replaceAll(RegExp(r'[^\d]'), '')) {
            duplicates.add('Số điện thoại "$existingPhone" đã được sử dụng bởi gara "${existingGara.name}"');
          }
        }
      }
      
      // Kiểm tra trùng địa chỉ (nếu có tọa độ gần nhau)
      if (newGara.location.latitude != 0 && newGara.location.longitude != 0) {
        double distance = _calculateDistance(
          newGara.location.latitude,
          newGara.location.longitude,
          existingGara.location.latitude,
          existingGara.location.longitude,
        );
        
        // Nếu khoảng cách < 100m và địa chỉ tương tự
        if (distance < 0.1 && _isSimilarAddress(newGara.address, existingGara.address)) {
          duplicates.add('Địa chỉ tương tự với gara "${existingGara.name}" (cách ${(distance * 1000).toStringAsFixed(0)}m)');
        }
      }
    }
    
    return duplicates;
  }
  
  /// Tính khoảng cách giữa 2 điểm (km)
  static double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371; // km
    
    double dLat = _degreesToRadians(lat2 - lat1);
    double dLon = _degreesToRadians(lon2 - lon1);
    
    double a = sin(dLat / 2) * sin(dLat / 2) +
        sin(lat1) * sin(lat2) * sin(dLon / 2) * sin(dLon / 2);
    double c = 2 * atan(sqrt(a) / sqrt(1 - a));
    
    return earthRadius * c;
  }
  
  static double _degreesToRadians(double degrees) {
    return degrees * (3.14159265359 / 180);
  }
  
  /// Kiểm tra địa chỉ có tương tự không
  static bool _isSimilarAddress(String address1, String address2) {
    String clean1 = address1.toLowerCase().replaceAll(RegExp(r'[^\w\s]'), '');
    String clean2 = address2.toLowerCase().replaceAll(RegExp(r'[^\w\s]'), '');
    
    // Tách thành từng từ
    List<String> words1 = clean1.split(' ').where((word) => word.length > 2).toList();
    List<String> words2 = clean2.split(' ').where((word) => word.length > 2).toList();
    
    // Đếm số từ chung
    int commonWords = 0;
    for (String word in words1) {
      if (words2.contains(word)) {
        commonWords++;
      }
    }
    
    // Nếu có ít nhất 2 từ chung, coi như tương tự
    return commonWords >= 2;
  }
  
  /// Validate số điện thoại
  static bool isValidPhoneNumber(String phone) {
    // Loại bỏ tất cả ký tự không phải số
    String cleanPhone = phone.replaceAll(RegExp(r'[^\d]'), '');
    
    // Kiểm tra độ dài (10-11 số cho VN)
    if (cleanPhone.length < 10 || cleanPhone.length > 11) {
      return false;
    }
    
    // Kiểm tra đầu số VN
    List<String> validPrefixes = [
      '03', '05', '07', '08', '09', // Di động
      '02', '04', '06', // Cố định
    ];
    
    String prefix = cleanPhone.substring(0, 2);
    return validPrefixes.contains(prefix);
  }
  
  /// Validate tên gara
  static bool isValidGaraName(String name) {
    return name.trim().length >= 3 && name.trim().length <= 100;
  }
  
  /// Validate địa chỉ
  static bool isValidAddress(String address) {
    return address.trim().length >= 10 && address.trim().length <= 200;
  }
  
  /// Validate tên chủ gara
  static bool isValidOwnerName(String ownerName) {
    return ownerName.trim().length >= 2 && ownerName.trim().length <= 50;
  }
}
