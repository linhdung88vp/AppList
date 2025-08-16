# 🚀 Gara App Update API

## 📍 **Cách setup miễn phí:**

### **1. Tạo GitHub Repository:**
```bash
# Clone repository này
git clone https://github.com/yourusername/gara-app.git
cd gara-app
```

### **2. Upload file API:**
- Copy file `api/update.json` vào repository
- Commit và push lên GitHub

### **3. Bật GitHub Pages:**
- Vào Settings > Pages
- Source: Deploy from a branch
- Branch: main
- Folder: / (root)
- Save

### **4. URL API sẽ là:**
```
https://yourusername.github.io/gara-app/api/update.json
```

### **5. Cập nhật trong app:**
```dart
// lib/services/app_service.dart
static const String _updateCheckUrl = 'https://yourusername.github.io/gara-app/api/update.json';
```

## 📱 **Cách test:**

1. **Build APK v1.0.0** (phiên bản hiện tại)
2. **Cập nhật version trong app** thành v1.0.1
3. **Build APK v1.0.1** và upload lên GitHub Releases
4. **Test update** trong app v1.0.0

## 🔄 **Quy trình update:**

1. App check API → Có bản mới
2. Tự động download APK từ GitHub Releases
3. Tự động cài đặt và restart
4. Hoàn tất! 🎉

## 📋 **Cấu trúc API:**
```json
{
  "version": "1.0.1",
  "downloadUrl": "https://github.com/.../app-release.apk",
  "changelog": "Mô tả thay đổi...",
  "isForceUpdate": false,
  "releaseDate": "2024-01-15T10:00:00Z"
}
```
