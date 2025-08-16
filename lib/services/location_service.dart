import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:permission_handler/permission_handler.dart';

class LocationService {
  /// Kiểm tra quyền vị trí
  static Future<bool> checkLocationPermission() async {
    try {
      // Kiểm tra quyền vị trí
      LocationPermission permission = await Geolocator.checkPermission();
      
      if (permission == LocationPermission.denied) {
        // Yêu cầu quyền vị trí
        permission = await Geolocator.requestPermission();
        
        if (permission == LocationPermission.denied) {
          return false;
        }
      }
      
      if (permission == LocationPermission.deniedForever) {
        return false;
      }
      
      return true;
    } catch (e) {
      print('Error checking location permission: $e');
      return false;
    }
  }

  /// Lấy vị trí hiện tại từ GPS
  static Future<Map<String, double>?> getCurrentLocation() async {
    try {
      // Kiểm tra quyền vị trí
      bool hasPermission = await checkLocationPermission();
      if (!hasPermission) {
        throw 'Không có quyền truy cập vị trí';
      }

      // Kiểm tra GPS có bật không
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw 'GPS chưa được bật. Vui lòng bật GPS và thử lại.';
      }

      // Lấy vị trí hiện tại với độ chính xác cao
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 15),
      );

      return {
        'latitude': position.latitude,
        'longitude': position.longitude,
      };
    } catch (e) {
      print('Error getting current location: $e');
      rethrow;
    }
  }

  /// Lấy địa chỉ từ tọa độ
  static Future<String?> getAddressFromCoordinates(
    double latitude,
    double longitude,
  ) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(latitude, longitude);
      
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        
        // Tạo địa chỉ chi tiết từ các thành phần
        List<String> addressParts = [];
        
        // Số nhà và tên đường
        if (place.name != null && place.name!.isNotEmpty && place.name != place.street) {
          addressParts.add(place.name!);
        }
        if (place.street != null && place.street!.isNotEmpty) {
          addressParts.add(place.street!);
        }
        
        // Phường/Xã
        if (place.subLocality != null && place.subLocality!.isNotEmpty) {
          addressParts.add(place.subLocality!);
        }
        
        // Quận/Huyện
        if (place.locality != null && place.locality!.isNotEmpty) {
          addressParts.add(place.locality!);
        }
        
        // Tỉnh/Thành phố
        if (place.administrativeArea != null && place.administrativeArea!.isNotEmpty) {
          addressParts.add(place.administrativeArea!);
        }
        
        // Mã bưu điện
        if (place.postalCode != null && place.postalCode!.isNotEmpty) {
          addressParts.add('Mã bưu điện: ${place.postalCode}');
        }
        
        // Quốc gia
        if (place.country != null && place.country!.isNotEmpty) {
          addressParts.add(place.country!);
        }
        
        return addressParts.join(', ');
      }
      
      return null;
    } catch (e) {
      print('Error getting address from coordinates: $e');
      return null;
    }
  }

  /// Lấy tọa độ từ địa chỉ
  static Future<Map<String, double>?> getCoordinatesFromAddress(
    String address,
  ) async {
    try {
      List<Location> locations = await locationFromAddress(address);
      
      if (locations.isNotEmpty) {
        Location location = locations[0];
        return {
          'latitude': location.latitude,
          'longitude': location.longitude,
        };
      }
      
      return null;
    } catch (e) {
      print('Error getting coordinates from address: $e');
      return null;
    }
  }

  /// Tính khoảng cách giữa 2 điểm (km)
  static double calculateDistance(
    double startLatitude,
    double startLongitude,
    double endLatitude,
    double endLongitude,
  ) {
    return Geolocator.distanceBetween(
      startLatitude,
      startLongitude,
      endLatitude,
      endLongitude,
    ) / 1000; // Chuyển từ mét sang km
  }

  /// Lấy vị trí gần nhất đã biết
  static Future<Map<String, double>?> getLastKnownLocation() async {
    try {
      Position? position = await Geolocator.getLastKnownPosition();
      
      if (position != null) {
        return {
          'latitude': position.latitude,
          'longitude': position.longitude,
        };
      }
      
      return null;
    } catch (e) {
      print('Error getting last known location: $e');
      return null;
    }
  }

  /// Lấy vị trí với timeout và retry
  static Future<Map<String, double>?> getLocationWithRetry({
    int maxRetries = 3,
    Duration timeout = const Duration(seconds: 10),
  }) async {
    for (int i = 0; i < maxRetries; i++) {
      try {
        return await getCurrentLocation().timeout(timeout);
      } catch (e) {
        print('Attempt ${i + 1} failed: $e');
        if (i == maxRetries - 1) {
          rethrow;
        }
        // Chờ một chút trước khi thử lại
        await Future.delayed(Duration(seconds: i + 1));
      }
    }
    return null;
  }
}
