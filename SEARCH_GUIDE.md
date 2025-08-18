# 🔍 Hướng Dẫn Sử Dụng Chức Năng Tìm Kiếm

## 📱 Giao Diện Tìm Kiếm

### 🎯 **Thanh Tìm Kiếm**
- **Vị trí**: Ở đầu màn hình chính, dưới header
- **Chức năng**: Tìm kiếm theo tên gara, địa chỉ, số điện thoại
- **Cách sử dụng**: Nhập từ khóa vào ô tìm kiếm

### 🏙️ **Bộ Lọc Quận/Huyện**
- **Vị trí**: Nhấn nút filter (⚙️) bên cạnh ô tìm kiếm
- **Chức năng**: Lọc gara theo 30 quận/huyện ở Hà Nội
- **Cách sử dụng**: Chọn quận/huyện từ danh sách

## 🔎 **Cách Tìm Kiếm**

### 1. **Tìm Theo Tên Gara**
```
Ví dụ: Nhập "Bmm" → Hiển thị gara có tên "Bmm"
```

### 2. **Tìm Theo Địa Chỉ**
```
Ví dụ: Nhập "Phúc La" → Hiển thị gara ở Phúc La
```

### 3. **Tìm Theo Số Điện Thoại**
```
Ví dụ: Nhập "0123456789" → Hiển thị gara có số điện thoại này
```

### 4. **Lọc Theo Quận/Huyện**
```
Bước 1: Nhấn nút filter (⚙️)
Bước 2: Chọn quận/huyện từ danh sách
Bước 3: Gara sẽ được lọc theo quận/huyện đã chọn
```

## 🏛️ **30 Quận/Huyện Hà Nội**

### **Quận Nội Thành:**
1. Ba Đình
2. Hoàn Kiếm
3. Hai Bà Trưng
4. Đống Đa
5. Tây Hồ
6. Cầu Giấy
7. Thanh Xuân
8. Hoàng Mai
9. Long Biên
10. Nam Từ Liêm
11. Bắc Từ Liêm
12. Hà Đông

### **Huyện Ngoại Thành:**
13. Sơn Tây
14. Ba Vì
15. Phúc Thọ
16. Đan Phượng
17. Hoài Đức
18. Quốc Oai
19. Thạch Thất
20. Chương Mỹ
21. Thanh Oai
22. Thường Tín
23. Phú Xuyên
24. Ứng Hòa
25. Mỹ Đức
26. Gia Lâm
27. Đông Anh
28. Sóc Sơn
29. Mê Linh
30. Phú Thọ

## 📊 **Thống Kê Thời Gian Thực**

### **3 Chỉ Số Chính:**
- **Tổng Gara**: Số lượng gara trong hệ thống
- **Đang hoạt động**: Gara có trạng thái "Hoạt động"
- **Đang sửa chữa**: Gara có trạng thái "Đang sửa chữa"

### **Cách Xem:**
- Thống kê hiển thị ngay dưới thanh tìm kiếm
- Cập nhật tự động khi có thay đổi dữ liệu

## 🎨 **Tính Năng Giao Diện**

### **Animation:**
- Hiệu ứng fade in/slide in cho các phần tử
- Loading skeleton khi đang tải dữ liệu
- Smooth transitions khi chuyển đổi

### **Responsive:**
- Tương thích với mọi kích thước màn hình
- Layout tự động điều chỉnh

## 🚀 **Cách Test**

### **Chạy Ứng Dụng:**
```bash
# Cách 1: Sử dụng script
test_search.bat

# Cách 2: Chạy trực tiếp
flutter run
```

### **Test Cases:**
1. **Tìm kiếm cơ bản:**
   - Nhập tên gara → Kiểm tra kết quả
   - Nhập địa chỉ → Kiểm tra kết quả
   - Nhập số điện thoại → Kiểm tra kết quả

2. **Lọc theo quận:**
   - Chọn "Tất cả quận" → Hiển thị tất cả
   - Chọn quận cụ thể → Kiểm tra gara trong quận đó

3. **Kết hợp tìm kiếm:**
   - Tìm kiếm + Lọc quận → Kiểm tra kết quả chính xác

## ⚡ **Tối Ưu Hiệu Suất**

### **Tìm Kiếm Thông Minh:**
- Tìm kiếm không phân biệt hoa thường
- Tìm kiếm theo từ khóa một phần
- Kết quả hiển thị ngay lập tức

### **Lọc Hiệu Quả:**
- Lọc theo quận/huyện chính xác
- Kết hợp với tìm kiếm text
- Không ảnh hưởng hiệu suất

## 🐛 **Xử Lý Lỗi**

### **Không Tìm Thấy Kết Quả:**
- Hiển thị thông báo thân thiện
- Gợi ý từ khóa tìm kiếm khác
- Icon trực quan

### **Lỗi Kết Nối:**
- Hiển thị thông báo lỗi rõ ràng
- Nút thử lại
- Fallback UI

---

**💡 Lưu ý:** Chức năng tìm kiếm hoạt động real-time và không cần nhấn nút tìm kiếm. Kết quả sẽ hiển thị ngay khi bạn nhập từ khóa.
