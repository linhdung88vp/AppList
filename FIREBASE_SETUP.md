# 🔥 Hướng dẫn cài đặt Firebase

## 📋 Bước 1: Tạo project Firebase

1. Truy cập [Firebase Console](https://console.firebase.google.com/)
2. Click "Create a project" hoặc "Add project"
3. Đặt tên project: `gara-management-app`
4. Chọn "Enable Google Analytics" (khuyến nghị)
5. Click "Create project"

## 📱 Bước 2: Thêm ứng dụng Android

1. Trong Firebase Console, click biểu tượng Android
2. Nhập package name: `com.example.gara_management_app`
3. Nhập app nickname: `Gara Management App`
4. Click "Register app"

## 📄 Bước 3: Tải file cấu hình

1. Tải file `google-services.json`
2. Thay thế file `android/app/google-services.json` hiện tại
3. **QUAN TRỌNG:** Không commit file này lên git (đã có trong .gitignore)

## 🔧 Bước 4: Cấu hình Firestore Database

1. Trong Firebase Console, chọn "Firestore Database"
2. Click "Create database"
3. Chọn "Start in test mode" (cho development)
4. Chọn location gần nhất (ví dụ: `asia-southeast1`)

## 📸 Bước 5: Cấu hình Storage

1. Trong Firebase Console, chọn "Storage"
2. Click "Get started"
3. Chọn "Start in test mode"
4. Chọn location giống Firestore

## 🔐 Bước 6: Cấu hình Authentication (tùy chọn)

1. Trong Firebase Console, chọn "Authentication"
2. Click "Get started"
3. Chọn "Email/Password" sign-in method
4. Enable "Email/Password"

## 🚀 Bước 7: Test ứng dụng

1. Chạy `flutter clean`
2. Chạy `flutter pub get`
3. Chạy `flutter run`

## ⚠️ Lưu ý quan trọng

- **Test mode:** Firestore và Storage đang ở chế độ test (ai cũng có thể đọc/ghi)
- **Production:** Cần cấu hình Security Rules trước khi deploy
- **Billing:** Firebase có free tier rộng rãi cho development

## 🔒 Security Rules mẫu (sau này)

### Firestore Rules
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /garas/{garaId} {
      allow read, write: if request.auth != null;
    }
  }
}
```

### Storage Rules
```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /gara_images/{imageId} {
      allow read, write: if request.auth != null;
    }
  }
}
```

## 📞 Hỗ trợ

Nếu gặp vấn đề, kiểm tra:
1. File `google-services.json` đã đúng chưa
2. Package name trong `build.gradle` có khớp không
3. Firebase project đã được tạo và cấu hình đúng chưa
