import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseConfig {
  static FirebaseFirestore? _firestore;

  /// Khởi tạo Firebase
  static Future<void> initialize() async {
    await Firebase.initializeApp();
    _firestore = FirebaseFirestore.instance;
  }

  /// Lấy instance Firestore
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
