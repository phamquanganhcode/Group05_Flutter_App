# CẨM NANG THỰC HÀNH: TỪNG BƯỚC THIẾT LẬP FIREBASE CHO ỨNG DỤNG FLUTTER
> **Tài liệu nội bộ nhóm:** Dành cho các thành viên thực hiện cấu hình môi trường và liên kết ứng dụng với tài khoản Google Firebase.

---

## BƯỚC 1: KHỞI TẠO PROJECT TRÊN FIREBASE CONSOLE
1. Truy cập vào trang quản trị: [https://console.firebase.google.com/](https://console.firebase.google.com/).
2. Đăng nhập bằng tài khoản Google của nhóm.
3. Nhấp vào nút **"Add Project"** (hoặc "Thêm dự án"):
   - Đặt tên dự án: `study-materials-dms` (hoặc tên tùy chọn của nhóm).
   - Bấm **Continue**.
   - Tại bước Google Analytics: Có thể tắt (Disable) để quy trình tạo dự án nhanh hơn.
   - Bấm **Create project** và đợi khoảng 15 giây cho đến khi hệ thống báo dự án đã sẵn sàng.

---

## BƯỚC 2: CÀI ĐẶT CÔNG CỤ DÒNG LỆNH (CLI) TRÊN MÁY TÍNH
Mở ứng dụng **PowerShell** hoặc **Command Prompt (cmd)** và chạy các lệnh sau:

### 2.1. Cài đặt Firebase CLI thông qua Node.js (npm):
```powershell
npm install -g firebase-tools
```

### 2.2. Đăng nhập vào tài khoản Google:
```powershell
firebase login
```
*(Trình duyệt sẽ tự động mở lên, bạn chỉ cần bấm xác nhận cho phép tài khoản Google của bạn kết nối với Firebase CLI).*

### 2.3. Cài đặt FlutterFire CLI toàn cục:
```powershell
dart pub global activate flutterfire_cli
```

---

## BƯỚC 3: LẤY MÃ VÂN TAY SHA-1 CHO TÍNH NĂNG GOOGLE SIGN-IN TRÊN ANDROID
> ⚠️ **LƯU Ý QUAN TRỌNG:** Nếu không cấu hình SHA-1, ứng dụng sẽ báo lỗi `ApiException: 10` khi bấm đăng nhập Google trên máy thật hoặc máy ảo Android!

1. Tại terminal, di chuyển vào thư mục `android/` của dự án:
   ```powershell
   cd d:\65KTPM\nam4\flutter\study_materials_app\android
   ./gradlew signingReport
   ```
2. Tìm khối có dòng:
   ```text
   Variant: debug
   Config: debug
   Store: ...\debug.keystore
   Alias: androiddebugkey
   SHA1: XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX
   SHA-256: YY:YY:YY:YY:YY:YY:YY:YY:YY:YY:YY:YY:YY:YY:YY:YY:YY:YY:YY:YY:YY:YY...
   ```
3. Sao chép chuỗi mã `SHA1` và `SHA-256`.
4. Mở **Firebase Console** $\rightarrow$ Chọn dự án `study-materials-dms` $\rightarrow$ Nhấp biểu tượng bánh răng **Project Settings** $\rightarrow$ Kéo xuống mục **Your apps** $\rightarrow$ Chọn ứng dụng Android $\rightarrow$ Bấm **Add fingerprint** $\rightarrow$ Dán mã SHA-1 vào và bấm **Save**.

---

## BƯỚC 4: CHẠY LỆNH CẤU HÌNH TỰ ĐỘNG FLUTTERFIRE CONFIGURE
Di chuyển về thư mục gốc của ứng dụng Flutter:
```powershell
cd d:\65KTPM\nam4\flutter\study_materials_app
flutterfire configure --project=study-materials-dms
```
- Khi được hỏi các nền tảng muốn hỗ trợ, dùng phím mũi tên và phím cách để chọn: `android`, `ios`, `web`.
- Nhấn `Enter`.
- FlutterFire CLI sẽ tự động:
  1. Tải và tạo tệp cấu hình `android/app/google-services.json`.
  2. Tải và tạo tệp `ios/Runner/GoogleService-Info.plist`.
  3. Tạo mã nguồn cấu hình chính thức tại `lib/firebase_options.dart`.

---

## BƯỚC 5: KÍCH HOẠT CÁC DỊCH VỤ TRÊN FIREBASE CONSOLE

### 5.1. Kích hoạt Authentication (Google Sign-In):
- Vào menu **Build** $\rightarrow$ **Authentication** $\rightarrow$ Bấm **Get Started**.
- Chuyển sang tab **Sign-in method** $\rightarrow$ Nhấp chọn **Google**.
- Gạt thanh gạt sang **Enable**.
- Chọn **Project support email** (chọn chính email của bạn).
- Bấm **Save**.

### 5.2. Kích hoạt Cloud Storage (Lưu trữ tệp tài liệu):
- Vào menu **Build** $\rightarrow$ **Storage** $\rightarrow$ Bấm **Get Started**.
- Chọn chế độ bảo mật ban đầu: Chọn **Start in test mode** (hoặc Production mode tùy chọn).
- Tại bước chọn vị trí Cloud Storage Location: Chọn **`asia-southeast1` (Singapore)** để tốc độ upload/download tại Việt Nam nhanh nhất.
- Bấm **Done**.

### 5.3. Cấu hình Storage Security Rules:
Tại tab **Rules** của Storage, dán nội dung sau để đảm bảo an toàn phân quyền:
```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /documents/{userId}/{allPaths=**} {
      allow read: if request.auth != null;
      allow write: if request.auth != null 
                   && request.auth.uid == userId
                   && request.resource.size < 50 * 1024 * 1024;
    }
  }
}
```
Nhấp **Publish** để áp dụng.

---

## BƯỚC 6: CHẠY VÀ KIỂM THỬ ỨNG DỤNG
Tại thư mục `study_materials_app`:
```powershell
flutter pub get
flutter run
```
1. Mở app, bấm **"Đăng nhập với Google"** và chọn tài khoản.
2. Thêm mới tài liệu, đính kèm tệp PDF.
3. Kiểm tra trên Firebase Console: Tệp tin sẽ xuất hiện trong tab **Storage**, siêu dữ liệu xuất hiện trong tab **Firestore**!
