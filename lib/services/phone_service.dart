import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';

class PhoneService {
  /// Gọi điện thoại
  static Future<bool> makePhoneCall(String phoneNumber) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
    
    try {
      if (await canLaunchUrl(phoneUri)) {
        return await launchUrl(phoneUri);
      } else {
        throw 'Không thể gọi số điện thoại này';
      }
    } catch (e) {
      throw 'Lỗi khi gọi điện: $e';
    }
  }

  /// Mở bản đồ với vị trí
  static Future<bool> openMap(double latitude, double longitude, {String? label}) async {
    try {
      // Thử mở Google Maps app trước (với intent rõ ràng cho Xiaomi)
      final String googleMapsAppUrl = 'geo:$latitude,$longitude?q=$latitude,$longitude${label != null ? '($label)' : ''}';
      final Uri googleMapsAppUri = Uri.parse(googleMapsAppUrl);
      
      if (await canLaunchUrl(googleMapsAppUri)) {
        return await launchUrl(
          googleMapsAppUri, 
          mode: LaunchMode.externalApplication,
          webViewConfiguration: const WebViewConfiguration(
            enableJavaScript: true,
            enableDomStorage: true,
          ),
        );
      }
      
      // Fallback: Sử dụng Google Maps web với intent rõ ràng
      final String googleMapsWebUrl = 'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
      final Uri googleMapsWebUri = Uri.parse(googleMapsWebUrl);
      
      if (await canLaunchUrl(googleMapsWebUri)) {
        return await launchUrl(
          googleMapsWebUri, 
          mode: LaunchMode.externalApplication,
          webViewConfiguration: const WebViewConfiguration(
            enableJavaScript: true,
            enableDomStorage: true,
          ),
        );
      }
      
      // Fallback: Sử dụng intent trực tiếp cho Xiaomi
      final String xiaomiMapsUrl = 'intent://maps.google.com/maps?q=$latitude,$longitude#Intent;scheme=https;package=com.google.android.apps.maps;end';
      final Uri xiaomiMapsUri = Uri.parse(xiaomiMapsUrl);
      
      if (await canLaunchUrl(xiaomiMapsUri)) {
        return await launchUrl(
          xiaomiMapsUri, 
          mode: LaunchMode.externalApplication,
        );
      }
      
      // Fallback: Sử dụng Apple Maps (iOS)
      final String appleMapsUrl = 'https://maps.apple.com/?q=$latitude,$longitude';
      final Uri appleMapsUri = Uri.parse(appleMapsUrl);
      
      if (await canLaunchUrl(appleMapsUri)) {
        return await launchUrl(appleMapsUri, mode: LaunchMode.externalApplication);
      }
      
      // Fallback cuối cùng: Sử dụng bản đồ mặc định của hệ thống
      final String systemMapsUrl = 'maps:$latitude,$longitude';
      final Uri systemMapsUri = Uri.parse(systemMapsUrl);
      
      if (await canLaunchUrl(systemMapsUri)) {
        return await launchUrl(systemMapsUri, mode: LaunchMode.externalApplication);
      }
      
      throw 'Không thể mở bản đồ. Vui lòng cài đặt Google Maps hoặc ứng dụng bản đồ khác.';
    } catch (e) {
      throw 'Lỗi khi mở bản đồ: $e';
    }
  }

  /// Mở bản đồ với địa chỉ
  static Future<bool> openMapWithAddress(String address) async {
    final String encodedAddress = Uri.encodeComponent(address);
    final String googleMapsUrl = 'https://www.google.com/maps/search/?api=1&query=$encodedAddress';
    final Uri mapUri = Uri.parse(googleMapsUrl);
    
    try {
      if (await canLaunchUrl(mapUri)) {
        return await launchUrl(mapUri, mode: LaunchMode.externalApplication);
      } else {
        throw 'Không thể mở bản đồ';
      }
    } catch (e) {
      throw 'Lỗi khi mở bản đồ: $e';
    }
  }

  /// Hiển thị dialog chọn số điện thoại để gọi
  static Future<void> showPhoneCallDialog(BuildContext context, List<String> phoneNumbers) async {
    if (phoneNumbers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không có số điện thoại để gọi')),
      );
      return;
    }

    if (phoneNumbers.length == 1) {
      // Chỉ có 1 số điện thoại, gọi trực tiếp
      await _makeCallWithLoading(context, phoneNumbers.first);
    } else {
      // Có nhiều số điện thoại, hiển thị dialog chọn
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Chọn số điện thoại'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: phoneNumbers.map((phone) {
                return ListTile(
                  leading: const Icon(Icons.phone),
                  title: Text(phone),
                  onTap: () {
                    Navigator.of(context).pop();
                    _makeCallWithLoading(context, phone);
                  },
                );
              }).toList(),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Hủy'),
              ),
            ],
          );
        },
      );
    }
  }

  /// Gọi điện với loading indicator
  static Future<void> _makeCallWithLoading(BuildContext context, String phoneNumber) async {
    // Hiển thị loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text('Đang gọi...'),
            ],
          ),
        );
      },
    );

    try {
      final success = await makePhoneCall(phoneNumber);
      
      if (context.mounted) {
        Navigator.of(context).pop(); // Đóng loading dialog
        
        if (!success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Không thể thực hiện cuộc gọi'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context).pop(); // Đóng loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
