# 🔐 Test Accounts for Debug

## 📧 **Tài Khoản Test**

### **Admin Account:**
```
Email: admin@gara.com
Password: 123456
```

### **User Account:**
```
Email: user@gara.com
Password: 123456
```

## 🚀 **Cách Tạo Tài Khoản Test**

### **1. Sử dụng Firebase Console:**
1. Vào [Firebase Console](https://console.firebase.google.com)
2. Chọn project của bạn
3. Vào Authentication > Users
4. Click "Add User"
5. Nhập email và password

### **2. Sử dụng App (Đăng ký):**
1. Mở app
2. Chọn "Đăng ký"
3. Nhập thông tin:
   - Tên: Admin User
   - Email: admin@gara.com
   - Password: 123456

### **3. Tạo Admin User (Code):**
```dart
// Trong AuthProvider, gọi method này
await authProvider.createAdminUser(
  'admin@gara.com',
  '123456',
  'Admin User'
);
```

## 🔍 **Debug Steps**

### **1. Kiểm tra Firebase:**
- Xem console logs khi khởi động app
- Kiểm tra Firebase initialization
- Verify google-services.json

### **2. Test Login:**
- Thử đăng nhập với tài khoản test
- Xem error messages
- Check AuthProvider state

### **3. Check Navigation:**
- Verify AuthWrapper logic
- Test navigation flow
- Check user state persistence

## 🐛 **Common Issues**

### **1. Firebase not initialized:**
```
Error: Firebase chưa được khởi tạo
```
**Solution:** Check google-services.json and Firebase.initializeApp()

### **2. Invalid credentials:**
```
Error: Không tìm thấy tài khoản với email này
```
**Solution:** Create test account first

### **3. Network error:**
```
Error: Lỗi kết nối
```
**Solution:** Check internet connection and Firebase rules

## 📱 **Test Commands**

```bash
# Run debug script
debug_login.bat

# Or run directly
flutter run --debug --verbose
```

## 🔧 **Firebase Rules (Test)**

```javascript
// Firestore Rules
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Allow read/write for authenticated users
    match /{document=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

## 📊 **Expected Behavior**

1. **App Start:** Show loading → Login screen
2. **Login Success:** Navigate to Home screen
3. **Login Fail:** Show error message
4. **Logout:** Return to Login screen
