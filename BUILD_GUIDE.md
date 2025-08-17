# 🚀 **Hướng Dẫn Build và Upload APK v1.0.2**

## 📋 **Danh sách scripts đã tạo:**

### **1. `simple_build.bat`** - Build nhanh
```bash
# Chạy script này để build APK
.\simple_build.bat
```

### **2. `build_and_upload.bat`** - Build chi tiết
```bash
# Script build đầy đủ với hướng dẫn
.\build_and_upload.bat
```

### **3. `quick_test.bat`** - Test update
```bash
# Test chức năng update
.\quick_test.bat
```

## 🔧 **Bước 1: Bật Developer Mode (nếu cần)**

Nếu gặp lỗi "Building with plugins requires symlink support":

1. **Nhấn:** `Win + I` (mở Settings)
2. **Vào:** Privacy & Security > For developers
3. **Bật:** Developer Mode
4. **Restart** terminal

## 🏗️ **Bước 2: Build APK**

### **Cách 1: Script đơn giản**
```bash
.\simple_build.bat
```

### **Cách 2: Build thủ công**
```bash
flutter clean
flutter pub get
flutter build apk --debug
copy "build\app\outputs\flutter-apk\app-debug.apk" "build\app\outputs\flutter-apk\app-release.apk"
```

## 📤 **Bước 3: Upload lên GitHub Releases**

1. **Vào:** https://github.com/linhdung88vp/AppList/releases
2. **Click:** "Create a new release"
3. **Tag:** `v1.0.2`
4. **Title:** `Gara App v1.0.2`
5. **Description:**
   ```
   ✨ Tính năng mới:
   • Tự động cập nhật app
   • Cải thiện UI/UX
   • Sửa lỗi GPS
   • Tối ưu hiệu suất
   
   🔧 Cải tiến:
   • Bắt buộc chụp ảnh trực tiếp
   • Kiểm tra quyền tự động
   • Thống kê theo ngày tùy chọn
   ```
6. **Upload file:** `build\app\outputs\flutter-apk\app-release.apk`
7. **Click:** "Publish release"

## 🧪 **Bước 4: Test Update**

### **Test API endpoint:**
```bash
.\quick_test.bat
```

### **Test trong app:**
1. **Cài đặt app hiện tại** (v1.0.0)
2. **Mở app** → Thống kê
3. **Nhấn nút update** (⚙️ icon)
4. **Kiểm tra:**
   - ✅ Dialog update hiển thị v1.0.2
   - ✅ Download progress hoạt động
   - ✅ APK mở để cài đặt

## 📊 **Thông tin Version:**

- **App hiện tại:** v1.0.0
- **App mới:** v1.0.2
- **API endpoint:** `https://linhdung88vp.github.io/AppList/api/update.json`
- **Download URL:** `https://github.com/linhdung88vp/AppList/releases/download/public/app-release.apk`

## 🎯 **Kết quả mong đợi:**

- ✅ **APK build thành công**
- ✅ **Upload lên GitHub Releases**
- ✅ **API trả về thông tin v1.0.2**
- ✅ **App phát hiện có bản mới**
- ✅ **Auto-update hoạt động**

## 🆘 **Nếu gặp lỗi:**

### **Lỗi Developer Mode:**
- Bật Developer Mode trong Windows Settings
- Restart terminal

### **Lỗi Java heap space:**
- Đã tăng heap memory lên 4GB trong `gradle.properties`

### **Lỗi API không cập nhật:**
- Commit và push file `api/update.json`
- Đợi GitHub Pages deploy (vài phút)

---

**Chúc bạn thành công! 🎉**
