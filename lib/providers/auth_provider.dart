import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthProvider with ChangeNotifier {
  User? _user;
  bool _isLoading = false;
  String? _error;
  bool _isAdmin = false;

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAdmin => _isAdmin;
  bool get isLoggedIn => _user != null;

  AuthProvider() {
    _initAuth();
  }

  void _initAuth() {
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      _user = user;
      if (user != null) {
        _checkAdminStatus(user.uid);
      } else {
        _isAdmin = false;
      }
      notifyListeners();
    });
  }

  Future<void> _checkAdminStatus(String uid) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();
      
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        _isAdmin = data['role'] == 'admin' || data['isAdmin'] == true;
      } else {
        // Tạo user mới với role user
        await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .set({
          'email': _user?.email,
          'displayName': _user?.displayName,
          'role': 'user',
          'isAdmin': false,
          'createdAt': FieldValue.serverTimestamp(),
        });
        _isAdmin = false;
      }
      notifyListeners();
    } catch (e) {
      print('Error checking admin status: $e');
      _isAdmin = false;
      notifyListeners();
    }
  }

  Future<bool> signInWithEmailAndPassword(String email, String password) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _isLoading = false;
      switch (e.code) {
        case 'user-not-found':
          _error = 'Không tìm thấy tài khoản với email này';
          break;
        case 'wrong-password':
          _error = 'Mật khẩu không đúng';
          break;
        case 'invalid-email':
          _error = 'Email không hợp lệ';
          break;
        case 'user-disabled':
          _error = 'Tài khoản đã bị vô hiệu hóa';
          break;
        default:
          _error = 'Lỗi đăng nhập: ${e.message}';
      }
      notifyListeners();
      return false;
    } catch (e) {
      _isLoading = false;
      _error = 'Lỗi không xác định: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> createUserWithEmailAndPassword(String email, String password, String displayName) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Cập nhật display name
      await credential.user?.updateDisplayName(displayName);

      // Tạo user document trong Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(credential.user!.uid)
          .set({
        'email': email,
        'displayName': displayName,
        'role': 'user',
        'isAdmin': false,
        'createdAt': FieldValue.serverTimestamp(),
      });

      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _isLoading = false;
      switch (e.code) {
        case 'weak-password':
          _error = 'Mật khẩu quá yếu';
          break;
        case 'email-already-in-use':
          _error = 'Email đã được sử dụng';
          break;
        case 'invalid-email':
          _error = 'Email không hợp lệ';
          break;
        default:
          _error = 'Lỗi đăng ký: ${e.message}';
      }
      notifyListeners();
      return false;
    } catch (e) {
      _isLoading = false;
      _error = 'Lỗi không xác định: $e';
      notifyListeners();
      return false;
    }
  }

  Future<void> signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
      _user = null;
      _isAdmin = false;
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = 'Lỗi đăng xuất: $e';
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Tạo admin user (chỉ dùng trong development)
  Future<void> createAdminUser(String email, String password, String displayName) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await credential.user?.updateDisplayName(displayName);

      await FirebaseFirestore.instance
          .collection('users')
          .doc(credential.user!.uid)
          .set({
        'email': email,
        'displayName': displayName,
        'role': 'admin',
        'isAdmin': true,
        'createdAt': FieldValue.serverTimestamp(),
      });

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = 'Lỗi tạo admin: $e';
      notifyListeners();
    }
  }
}
