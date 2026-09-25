# 🚀 Hướng Dẫn Chạy Ứng Dụng (Dành Cho Nhóm 5)

Mã nguồn trong thư mục này đã được Nhóm trưởng nâng cấp và fix lỗi hoàn toàn để tương thích với Flutter mới nhất (đã cập nhật V2 Embedding, SDK 36). Các bạn làm theo hướng dẫn dưới đây để chạy app nhé.

## 🛠 Yêu cầu môi trường
- Đã cài đặt **Flutter SDK**
- Đã cài đặt **Android Studio** (cùng máy ảo hoặc cắm điện thoại thật)

## ⚙️ Các bước khởi chạy

**Bước 1:** Mở thư mục gốc Group05_Flutter_App bằng Android Studio hoặc VS Code.

**Bước 2:** Mở Terminal (trong VS Code hoặc Android Studio), di chuyển vào thư mục cashew:
`ash
cd cashew
`

**Bước 3:** Tải các thư viện cần thiết:
`ash
flutter pub get
`

**Bước 4:** Khởi chạy ứng dụng:
`ash
flutter run
`
*(Hoặc bạn có thể mở file lib/main.dart và bấm nút **Run / Play** trực tiếp trên giao diện IDE).*

---
## 📝 Lưu ý khi làm việc nhóm
- Trước khi code, luôn nhớ chạy lệnh git pull để lấy code mới nhất về.
- Sửa code xong, hãy tạo Pull Request để Nhóm trưởng (Quang Anh) duyệt code nhé.
- Mọi thao tác lệnh lutter (như thêm thư viện, build app) **đều phải được chạy bên trong thư mục cashew/**.
