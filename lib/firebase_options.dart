import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

/// Firebase options cho chạy local (WEB).
/// Lưu ý: Đây là cấu hình tạm thời suy luận từ android/google-services.json.
/// Để cấu hình chuẩn, hãy chạy `flutterfire configure` để generate file này tự động.
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform => kIsWeb ? web : web;

  // Cấu hình WEB
  static final FirebaseOptions web = FirebaseOptions(
    apiKey: const String.fromEnvironment(
      'FIREBASE_WEB_API_KEY',
      defaultValue: 'AIzaSyCd7h8fbrf2LhfDdLHlSvwUA2_d6My4yV8',
    ),
    appId: const String.fromEnvironment(
      'FIREBASE_WEB_APP_ID',
      // AppId tạm thời cho local. Nên thay bằng appId thật của Web app trong Firebase console.
      defaultValue: '1:739609749459:web:localdev',
    ),
    messagingSenderId: const String.fromEnvironment(
      'FIREBASE_MESSAGING_SENDER_ID',
      defaultValue: '739609749459',
    ),
    projectId: const String.fromEnvironment(
      'FIREBASE_PROJECT_ID',
      defaultValue: 'gara-management-app',
    ),
    storageBucket: const String.fromEnvironment(
      'FIREBASE_STORAGE_BUCKET',
      defaultValue: 'gara-management-app.firebasestorage.app',
    ),
    authDomain: const String.fromEnvironment(
      'FIREBASE_AUTH_DOMAIN',
      defaultValue: 'gara-management-app.firebaseapp.com',
    ),
    measurementId: const String.fromEnvironment(
      'FIREBASE_MEASUREMENT_ID',
      defaultValue: '',
    ),
  );
}
