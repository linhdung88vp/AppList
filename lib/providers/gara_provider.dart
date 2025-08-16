import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/gara.dart';
import '../config/firebase_config.dart';

class GaraProvider with ChangeNotifier {
  List<Gara> _garas = [];
  bool _isLoading = false;
  String? _error;
  bool _isAdmin = false; // Chỉ admin mới có quyền xóa

  // Getters
  List<Gara> get garas => _garas;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAdmin => _isAdmin;

  // Set quyền admin (sẽ được gọi từ AuthProvider sau này)
  void setAdminStatus(bool isAdmin) {
    _isAdmin = isAdmin;
    notifyListeners();
  }

  // Khởi tạo
  GaraProvider() {
    _loadGarasFromFirebase();
  }

  /// Tải dữ liệu từ Firebase
  Future<void> _loadGarasFromFirebase() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final snapshot = await FirebaseConfig.garasCollection
          .orderBy('createdAt', descending: true)
          .get();

      _garas = snapshot.docs
          .map((doc) => Gara.fromFirestore(doc))
          .toList();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Lỗi khi tải dữ liệu: $e';
      _isLoading = false;
      notifyListeners();
      
      // Fallback: Load demo data nếu Firebase lỗi
      _loadDemoData();
    }
  }

  /// Tải dữ liệu demo (fallback)
  void _loadDemoData() {
    _garas = [
      Gara.create(
        name: 'Gara Ô tô Minh Khai',
        address: '123 Đường Minh Khai, Hai Bà Trưng, Hà Nội',
        ownerName: 'Nguyễn Văn A',
        phoneNumbers: ['0123456789', '0987654321'],
        location: const GeoPoint(21.0285, 105.8542),
        notes: 'Gara chuyên sửa chữa ô tô các loại',
      ),
      Gara.create(
        name: 'Gara Ô tô Cầu Giấy',
        address: '456 Đường Cầu Giấy, Cầu Giấy, Hà Nội',
        ownerName: 'Trần Thị B',
        phoneNumbers: ['0111222333'],
        location: const GeoPoint(21.0368, 105.8342),
        notes: 'Gara bảo dưỡng và sửa chữa',
      ),
      Gara.create(
        name: 'Gara Ô tô Đống Đa',
        address: '789 Đường Đống Đa, Đống Đa, Hà Nội',
        ownerName: 'Lê Văn C',
        phoneNumbers: ['0444555666', '0555666777', '0666777888'],
        location: const GeoPoint(21.0208, 105.8258),
        notes: 'Gara chuyên về điện và điện tử ô tô',
      ),
    ];
    notifyListeners();
  }

  /// Thêm gara mới vào Firebase
  Future<void> addGara(Gara gara) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Lưu vào Firebase
      final docRef = await FirebaseConfig.garasCollection.add(gara.toFirestore());
      
      // Cập nhật local data
      final newGara = gara.copyWith(id: docRef.id);
      _garas.insert(0, newGara); // Thêm vào đầu danh sách

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Lỗi khi thêm gara: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Cập nhật gara trong Firebase
  Future<void> updateGara(Gara gara) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      if (gara.id == null) {
        throw Exception('Không thể cập nhật gara không có ID');
      }

      // Cập nhật trong Firebase
      await FirebaseConfig.garasCollection
          .doc(gara.id)
          .update(gara.copyWith(updatedAt: DateTime.now()).toFirestore());

      // Cập nhật local data
      final index = _garas.indexWhere((g) => g.id == gara.id);
      if (index != -1) {
        _garas[index] = gara.copyWith(updatedAt: DateTime.now());
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Lỗi khi cập nhật gara: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Xóa gara khỏi Firebase
  Future<void> deleteGara(String garaId) async {
    if (!_isAdmin) {
      _error = 'Bạn không có quyền xóa gara';
      notifyListeners();
      return;
    }

    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Xóa khỏi Firebase
      await FirebaseConfig.garasCollection.doc(garaId).delete();

      // Cập nhật local data
      _garas.removeWhere((g) => g.id == garaId);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Lỗi khi xóa gara: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Làm mới dữ liệu
  Future<void> refreshData() async {
    await _loadGarasFromFirebase();
  }

  /// Xóa lỗi
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Tìm kiếm gara
  List<Gara> searchGaras(String query) {
    if (query.isEmpty) return _garas;
    
    final lowercaseQuery = query.toLowerCase();
    return _garas.where((gara) {
      return gara.name.toLowerCase().contains(lowercaseQuery) ||
             gara.address.toLowerCase().contains(lowercaseQuery) ||
             gara.ownerName.toLowerCase().contains(lowercaseQuery) ||
             gara.phoneNumbers.any((phone) => phone.contains(lowercaseQuery));
    }).toList();
  }

  /// Lọc gara theo khu vực
  List<Gara> filterGarasByArea(String area) {
    if (area.isEmpty) return _garas;
    
    return _garas.where((gara) {
      return gara.address.toLowerCase().contains(area.toLowerCase());
    }).toList();
  }

  /// Lấy gara theo ID
  Gara? getGaraById(String id) {
    try {
      return _garas.firstWhere((gara) => gara.id == id);
    } catch (e) {
      return null;
    }
  }
}
