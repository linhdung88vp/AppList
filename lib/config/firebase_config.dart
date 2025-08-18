import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../firebase_options.dart';

class FirebaseConfig {
  static FirebaseFirestore? _firestore;
  static bool _initialized = false;

  static bool get isInitialized => _initialized;

  /// Khởi tạo Firebase (an toàn cho Web nếu chưa cấu hình)
  static Future<void> initialize() async {
    try {
      if (kIsWeb) {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
      } else {
        await Firebase.initializeApp();
      }
      _firestore = FirebaseFirestore.instance;
      _initialized = true;
      // ignore: avoid_print
      print('✅ Firebase initialized (apps: '+Firebase.apps.length.toString()+')');
    } catch (e) {
      _initialized = false;
      // ignore: avoid_print
      print('⚠️ Firebase initialization failed: $e');
    }
  }

  /// Lấy instance Firestore (ném lỗi nếu chưa init)
  static FirebaseFirestore get firestore {
    if (_firestore == null) {
      throw Exception('Firebase chưa được khởi tạo. Gọi FirebaseConfig.initialize() trước.');
    }
    return _firestore!;
  }

  /// Collection references
  static CollectionReference<Map<String, dynamic>> get garasCollection {
    return firestore.collection('garas');
  }

  static CollectionReference<Map<String, dynamic>> get usersCollection {
    return firestore.collection('users');
  }
}
