# 🚀 **Setup GitHub Auto-Update Hoàn Chỉnh**

## 📋 **Danh sách việc cần làm:**

### **1. Tạo GitHub Repository**
```bash
# Tạo repository mới trên GitHub
# Tên: gara-app (hoặc tên bạn muốn)
# Public hoặc Private đều được
```

### **2. Upload code lên GitHub**
```bash
# Trong thư mục project
git init
git add .
git commit -m "Initial commit: Gara Management App"
git branch -M main
git remote add origin https://github.com/YOUR_USERNAME/gara-app.git
git push -u origin main
```

### **3. Bật GitHub Pages**
- Vào repository → Settings → Pages
- Source: Deploy from a branch
- Branch: main
- Folder: / (root)
- Save

### **4. Cập nhật URL trong app**
```dart
// lib/services/app_service.dart
static const String _updateCheckUrl = 'https://YOUR_USERNAME.github.io/gara-app/api/update.json';
```

### **5. Build APK v1.0.0 (phiên bản hiện tại)**
```bash
# Windows
build_stable.bat

# Linux/Mac
chmod +x build_stable.sh
./build_stable.sh
```

### **6. Tạo GitHub Release v1.0.0**
- Vào repository → Releases → Create a new release
- Tag: v1.0.0
- Title: Gara App v1.0.0
- Description: Phiên bản đầu tiên
- Upload file: `build/app/outputs/flutter-apk/app-release.apk`

### **7. Test update**
- Cài đặt APK v1.0.0 trên thiết bị
- Mở app → Thống kê → Nhấn nút update
- Kiểm tra xem có hiển thị dialog update không

## 🔄 **Để test update thật:**

### **8. Cập nhật version trong app**
```dart
// lib/services/app_service.dart
static const String _currentVersion = '1.0.1'; // Tăng version
```

### **9. Build APK v1.0.1**
```bash
# Build lại
flutter build apk --release
```

### **10. Tạo GitHub Release v1.0.1**
- Tag: v1.0.1
- Title: Gara App v1.0.1
- Description: Cập nhật tính năng mới
- Upload APK v1.0.1

### **11. Test auto-update**
- Mở app v1.0.0
- Nhấn nút update
- Xem có tự động download và cài đặt không

## 📱 **Cấu trúc thư mục GitHub:**
```
gara-app/
├── api/
│   └── update.json          # API trả về thông tin update
├── lib/                     # Source code Flutter
├── android/                 # Android config
├── build_stable.bat         # Script build Windows
├── build_stable.sh          # Script build Linux/Mac
└── README.md
```

## 🎯 **Kết quả cuối cùng:**
- ✅ **API miễn phí** trên GitHub Pages
- ✅ **Lưu trữ APK** trên GitHub Releases
- ✅ **Auto-update** hoàn toàn trong app
- ✅ **Không cần server** riêng
- ✅ **Miễn phí 100%** 🎉

## 🚨 **Lưu ý quan trọng:**
1. **Thay `YOUR_USERNAME`** bằng username GitHub thật
2. **Commit và push** mọi thay đổi
3. **Đợi GitHub Pages** deploy (có thể mất vài phút)
4. **Test kỹ** trước khi release production

## 🆘 **Nếu gặp lỗi:**
- Kiểm tra URL API có đúng không
- Kiểm tra GitHub Pages đã bật chưa
- Kiểm tra file `update.json` có đúng format không
- Kiểm tra APK có upload đúng GitHub Releases không

---

**Chúc bạn thành công! 🎉**
