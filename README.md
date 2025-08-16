# 🚗 Gara Management App - Ứng dụng Quản lý Gara Ô tô

## 📋 Mô tả dự án

**Gara Management App** là ứng dụng Android được phát triển bằng Flutter, dành cho dịch vụ kinh doanh bóng đèn LED ô tô. Ứng dụng giúp nhân viên thị trường có thể:

- **Thêm mới gara** với thông tin chi tiết
- **Chụp ảnh gara** và lưu trữ trực tuyến
- **Quản lý danh sách gara** một cách hiệu quả
- **Lấy tọa độ địa chỉ** tự động từ GPS
- **Tìm kiếm và lọc gara** theo nhiều tiêu chí

## 🚀 Tính năng chính

### ✨ Quản lý Gara
- **Thêm gara mới** với form đầy đủ thông tin
- **Xem danh sách gara** với giao diện đẹp mắt
- **Xem chi tiết gara** với ảnh và thông tin đầy đủ
- **Chỉnh sửa và xóa gara** (đang phát triển)

### 📞 Liên lạc và Định vị
- **Gọi điện trực tiếp** từ ứng dụng với dialog chọn số
- **Mở bản đồ chỉ đường** đến gara với Google Maps
- **Lấy vị trí GPS chính xác** với độ chính xác cao
- **Hiển thị tọa độ GPS** chi tiết trong form thêm gara

### 📱 Giao diện người dùng
- **Material Design 3** với theme hiện đại
- **Responsive design** tối ưu cho mọi kích thước màn hình
- **Dark/Light theme** (đang phát triển)
- **Pull-to-refresh** để làm mới dữ liệu

### 🔍 Tìm kiếm và lọc
- **Tìm kiếm gara** theo tên, địa chỉ, chủ gara
- **Lọc theo khu vực** (Hai Bà Trưng, Cầu Giấy, Đống Đa)
- **Kết hợp tìm kiếm và lọc** để có kết quả chính xác

### 📸 Quản lý ảnh
- **Chụp ảnh trực tiếp** từ camera
- **Tải ảnh từ thư viện** thiết bị
- **Xem ảnh fullscreen** với zoom và swipe
- **Hiển thị ảnh** với PageView đẹp mắt
- **Upload ảnh lên ImgBB** để lấy link trực tiếp

### 📍 Vị trí và địa chỉ
- **Lấy vị trí GPS chính xác** với độ chính xác cao
- **Chuyển đổi tọa độ** thành địa chỉ thực
- **Lưu trữ tọa độ** chính xác của gara
- **Hiển thị tọa độ GPS** trong form thêm gara

## 🏗️ Kiến trúc kỹ thuật

### **Frontend**
- **Flutter 3.0+** - Framework cross-platform
- **Material Design 3** - UI/UX hiện đại
- **Provider Pattern** - State management

### **Backend & Storage**
- **Local Storage** - Lưu trữ dữ liệu demo
- **ImgBB API** - Lưu trữ ảnh trực tuyến
- **Firebase** - Đang phát triển (Firestore + Storage)

### **State Management**
- **Provider** - Quản lý state của ứng dụng
- **ChangeNotifier** - Notify UI khi data thay đổi

### **Services**
- **LocationService** - Xử lý vị trí và GPS thực
- **CameraService** - Xử lý camera và ảnh
- **ImgBBService** - Upload ảnh lên ImgBB
- **PhoneService** - Xử lý gọi điện và mở bản đồ

## 📱 Cài đặt và chạy

### **Yêu cầu hệ thống**
- Flutter SDK 3.0.0 trở lên
- Android Studio / VS Code
- Android SDK API 21+
- Thiết bị Android hoặc emulator

### **Bước cài đặt**

1. **Clone dự án**
```bash
git clone <repository-url>
cd gara_management_app
```

2. **Cài đặt dependencies**
```bash
flutter pub get
```

3. **Chạy ứng dụng**
```bash
flutter run
```

### **Build APK**
```bash
flutter build apk --release
```

## 🗂️ Cấu trúc dự án

```
lib/
├── main.dart                 # Entry point của ứng dụng
├── models/
│   └── gara.dart            # Model dữ liệu Gara
├── providers/
│   └── gara_provider.dart   # State management cho Gara
├── screens/
│   ├── home_screen.dart     # Màn hình chính
│   ├── add_gara_screen.dart # Màn hình thêm gara
│   └── gara_detail_screen.dart # Màn hình chi tiết gara
├── services/
│   ├── location_service.dart # Service xử lý vị trí và GPS
│   ├── camera_service.dart  # Service xử lý camera
│   ├── imgbb_service.dart   # Service upload ảnh
│   └── phone_service.dart   # Service gọi điện và mở bản đồ
└── widgets/
    └── gara_list_item.dart  # Widget hiển thị item gara
```

## 📊 Dữ liệu mẫu

Ứng dụng đã có sẵn 3 gara mẫu:

1. **Gara Ô tô Minh Khai**
   - Địa chỉ: 123 Đường Minh Khai, Hai Bà Trưng, Hà Nội
   - Chủ gara: Nguyễn Văn A
   - SĐT: 0123456789, 0987654321

2. **Gara Ô tô Cầu Giấy**
   - Địa chỉ: 456 Đường Cầu Giấy, Cầu Giấy, Hà Nội
   - Chủ gara: Trần Thị B
   - SĐT: 0111222333

3. **Gara Ô tô Đống Đa**
   - Địa chỉ: 789 Đường Đống Đa, Đống Đa, Hà Nội
   - Chủ gara: Lê Văn C
   - SĐT: 0444555666, 0555666777, 0666777888

## 🎯 Luồng hoạt động

### **Thêm gara mới:**
1. Nhấn nút "Thêm Gara" (FAB)
2. Nhập thông tin cơ bản (tên, chủ gara, SĐT)
3. Lấy vị trí GPS tự động với độ chính xác cao
4. Chụp ảnh hoặc tải ảnh từ thư viện
5. Upload ảnh lên ImgBB tự động
6. Lưu gara vào hệ thống

### **Quản lý gara:**
1. Xem danh sách tất cả gara
2. Tìm kiếm gara theo từ khóa
3. Lọc gara theo khu vực
4. Xem chi tiết gara với ảnh fullscreen
5. Gọi điện trực tiếp từ ứng dụng
6. Mở bản đồ chỉ đường đến gara
7. Chỉnh sửa hoặc xóa gara (admin)

### **Demo tính năng:**
1. Vào menu user → "Demo Tính Năng"
2. Test GPS với vị trí thực
3. Test gọi điện với dialog chọn số
4. Test mở bản đồ với Google Maps
5. Test xem ảnh fullscreen với zoom

## ✅ Tính năng đã hoàn thành

- [x] **Firebase Integration** - Lưu trữ dữ liệu thực
- [x] **Camera thực** - Chụp ảnh thực từ thiết bị
- [x] **GPS thực** - Lấy vị trí chính xác
- [x] **Authentication** - Đăng nhập/đăng ký người dùng
- [x] **Gọi điện** - Gọi điện trực tiếp từ ứng dụng
- [x] **Mở bản đồ** - Chỉ đường đến gara
- [x] **Xem ảnh fullscreen** - Zoom và swipe ảnh
- [x] **Phân quyền Admin/User** - Quản lý quyền truy cập

## 🚧 Tính năng đang phát triển

- [ ] **Push Notifications** - Thông báo real-time
- [ ] **Offline Support** - Hoạt động khi không có mạng
- [ ] **Export Data** - Xuất dữ liệu ra Excel/PDF
- [ ] **Maps Integration** - Hiển thị gara trên bản đồ
- [ ] **Chỉnh sửa gara** - Cập nhật thông tin gara

## 🔧 Cấu hình

### **ImgBB API Key**
Để sử dụng tính năng upload ảnh, cần cập nhật API key trong:
```dart
// lib/services/imgbb_service.dart
static const String _apiKey = 'YOUR_IMGBB_API_KEY';
```

### **Firebase Configuration**
Khi tích hợp Firebase, cần:
1. Tạo project Firebase
2. Thêm file `google-services.json`
3. Cập nhật dependencies trong `pubspec.yaml`

## 📱 Screenshots

### **Màn hình chính**
- Danh sách gara với tìm kiếm và lọc
- Giao diện Material Design 3 đẹp mắt

### **Màn hình thêm gara**
- Form nhập thông tin đầy đủ
- Chụp ảnh và tải ảnh
- Validation form hoàn chỉnh

### **Màn hình chi tiết gara**
- Hiển thị thông tin chi tiết
- Xem ảnh với PageView
- Nút hành động (gọi điện, chỉ đường)

## 🤝 Đóng góp

1. Fork dự án
2. Tạo feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit thay đổi (`git commit -m 'Add some AmazingFeature'`)
4. Push to branch (`git push origin feature/AmazingFeature`)
5. Mở Pull Request

## 📄 License

Dự án này được phát triển cho mục đích thương mại của dịch vụ bóng đèn LED ô tô.

## 📞 Liên hệ

- **Tác giả:** [Tên của bạn]
- **Email:** [email@example.com]
- **Dự án:** [Link repository]

---

**⭐ Nếu dự án này hữu ích, hãy cho một star! ⭐**
