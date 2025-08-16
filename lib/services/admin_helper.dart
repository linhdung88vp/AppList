import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminHelper {
  static const String _demoUserEmail = 'user@lightech.com';
  static const String _demoUserPassword = '123456';
  static const String _demoUserDisplayName = 'Demo User';
  
  static const String _demoAdminEmail = 'admin@lightech.com';
  static const String _demoAdminPassword = 'Thitkhotau@123';
  static const String _demoAdminDisplayName = 'Demo Admin';

  /// Tạo tài khoản demo nếu chưa tồn tại
  static Future<void> createDemoAccountsIfNeeded() async {
    try {
      // Kiểm tra và tạo demo user
      await _createDemoUserIfNeeded();
      
      // Kiểm tra và tạo demo admin
      await _createDemoAdminIfNeeded();
      
      print('✅ Demo accounts đã được kiểm tra và tạo thành công');
    } catch (e) {
      print('❌ Lỗi khi tạo demo accounts: $e');
    }
  }

  /// Tạo demo user nếu chưa tồn tại
  static Future<void> _createDemoUserIfNeeded() async {
    try {
      // Kiểm tra user đã tồn tại chưa
      final methods = await FirebaseAuth.instance.fetchSignInMethodsForEmail(_demoUserEmail);
      
      if (methods.isEmpty) {
        // Tạo user mới
        final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _demoUserEmail,
          password: _demoUserPassword,
        );

        // Cập nhật display name
        await credential.user?.updateDisplayName(_demoUserDisplayName);

        // Tạo user document trong Firestore
        await FirebaseFirestore.instance
            .collection('users')
            .doc(credential.user!.uid)
            .set({
          'email': _demoUserEmail,
          'displayName': _demoUserDisplayName,
          'role': 'user',
          'isAdmin': false,
          'isDemoAccount': true,
          'createdAt': FieldValue.serverTimestamp(),
        });

        print('✅ Demo user đã được tạo: $_demoUserEmail');
      } else {
        print('ℹ️ Demo user đã tồn tại: $_demoUserEmail');
      }
    } catch (e) {
      print('❌ Lỗi khi tạo demo user: $e');
      // Thử tạo lại nếu có lỗi
      try {
        final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _demoUserEmail,
          password: _demoUserPassword,
        );

        await credential.user?.updateDisplayName(_demoUserDisplayName);

        await FirebaseFirestore.instance
            .collection('users')
            .doc(credential.user!.uid)
            .set({
          'email': _demoUserEmail,
          'displayName': _demoUserDisplayName,
          'role': 'user',
          'isAdmin': false,
          'isDemoAccount': true,
          'createdAt': FieldValue.serverTimestamp(),
        });

        print('✅ Demo user đã được tạo lại: $_demoUserEmail');
      } catch (retryError) {
        print('❌ Lỗi khi tạo lại demo user: $retryError');
      }
    }
  }

  /// Tạo demo admin nếu chưa tồn tại
  static Future<void> _createDemoAdminIfNeeded() async {
    try {
      // Kiểm tra admin đã tồn tại chưa
      final methods = await FirebaseAuth.instance.fetchSignInMethodsForEmail(_demoAdminEmail);
      
      if (methods.isEmpty) {
        // Tạo admin mới
        final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _demoAdminEmail,
          password: _demoAdminPassword,
        );

        // Cập nhật display name
        await credential.user?.updateDisplayName(_demoAdminDisplayName);

        // Tạo admin document trong Firestore
        await FirebaseFirestore.instance
            .collection('users')
            .doc(credential.user!.uid)
            .set({
          'email': _demoAdminEmail,
          'displayName': _demoAdminDisplayName,
          'role': 'admin',
          'isAdmin': true,
          'isDemoAccount': true,
          'createdAt': FieldValue.serverTimestamp(),
        });

        print('✅ Demo admin đã được tạo: $_demoAdminEmail');
      } else {
        print('ℹ️ Demo admin đã tồn tại: $_demoAdminEmail');
      }
    } catch (e) {
      print('❌ Lỗi khi tạo demo admin: $e');
      // Thử tạo lại nếu có lỗi
      try {
        final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _demoAdminEmail,
          password: _demoAdminPassword,
        );

        await credential.user?.updateDisplayName(_demoAdminDisplayName);

        await FirebaseFirestore.instance
            .collection('users')
            .doc(credential.user!.uid)
            .set({
          'email': _demoAdminEmail,
          'displayName': _demoAdminDisplayName,
          'role': 'admin',
          'isAdmin': true,
          'isDemoAccount': true,
          'createdAt': FieldValue.serverTimestamp(),
        });

        print('✅ Demo admin đã được tạo lại: $_demoAdminEmail');
      } catch (retryError) {
        print('❌ Lỗi khi tạo lại demo admin: $retryError');
      }
    }
  }

  /// Xóa tài khoản demo (chỉ dùng trong development)
  static Future<void> deleteDemoAccounts() async {
    try {
      // Xóa demo user
      await _deleteDemoUser();
      
      // Xóa demo admin
      await _deleteDemoAdmin();
      
      print('✅ Demo accounts đã được xóa');
    } catch (e) {
      print('❌ Lỗi khi xóa demo accounts: $e');
    }
  }

  /// Xóa demo user
  static Future<void> _deleteDemoUser() async {
    try {
      // Tìm user document có isDemoAccount = true
      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: _demoUserEmail)
          .where('isDemoAccount', isEqualTo: true)
          .get();

      for (var doc in querySnapshot.docs) {
        final uid = doc.id;
        
        // Xóa user document
        await doc.reference.delete();
        
        // Xóa user authentication
        try {
          await FirebaseAuth.instance.currentUser?.delete();
        } catch (e) {
          print('Không thể xóa user auth: $e');
        }
        
        print('✅ Demo user đã được xóa: $_demoUserEmail');
      }
    } catch (e) {
      print('❌ Lỗi khi xóa demo user: $e');
    }
  }

  /// Xóa demo admin
  static Future<void> _deleteDemoAdmin() async {
    try {
      // Tìm admin document có isDemoAccount = true
      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: _demoAdminEmail)
          .where('isDemoAccount', isEqualTo: true)
          .get();

      for (var doc in querySnapshot.docs) {
        final uid = doc.id;
        
        // Xóa admin document
        await doc.reference.delete();
        
        // Xóa admin authentication
        try {
          await FirebaseAuth.instance.currentUser?.delete();
        } catch (e) {
          print('Không thể xóa admin auth: $e');
        }
        
        print('✅ Demo admin đã được xóa: $_demoAdminEmail');
      }
    } catch (e) {
      print('❌ Lỗi khi xóa demo admin: $e');
    }
  }

  /// Kiểm tra xem có phải tài khoản demo không
  static bool isDemoAccount(String email) {
    return email == _demoUserEmail || email == _demoAdminEmail;
  }

  /// Lấy thông tin tài khoản demo
  static Map<String, String> getDemoAccounts() {
    return {
      'user': '$_demoUserEmail / $_demoUserPassword',
      'admin': '$_demoAdminEmail / $_demoAdminPassword',
    };
  }
}
