# 🚀 Dự Án Phát Triển Phần Mềm - Nhóm 5 (Group 5)

> Kho lưu trữ mã nguồn và tài liệu phối hợp phát triển dự án của Nhóm 5.

---

## 👥 Danh sách thành viên & Phân công trách nhiệm

| STT | Mã sinh viên | Họ và tên | Vai trò | Trách nhiệm chính trong dự án |
|:---:|:---:|:---|:---:|:---|
| 1 | **2351170573** | **Phạm Quang Anh** | **Nhóm trưởng** (Team Lead) | Quản lý dự án, thiết lập Repo, kiểm duyệt Pull Request, phụ trách kiến trúc hệ thống |
| 2 | **2051063858** | **Nguyễn Phúc Bình An** | **Thành viên** (Frontend Dev) | Thiết kế UI/UX, phát triển các màn hình giao diện người dùng, xử lý logic hiển thị |
| 3 | **2351060452** | **Ngô Đức Nam Khánh** | **Thành viên** (Backend / Data Dev) | Thiết kế cấu trúc dữ liệu, xây dựng API / kết nối cơ sở dữ liệu, viết logic nghiệp vụ |
| 4 | **2351170597** | **Dương Văn Hưng** | **Thành viên** (QA / Tester) | Viết kịch bản kiểm thử (Test Cases), kiểm thử tính năng (Unit / Widget Test), rà soát lỗi |

---

## 📂 Cấu trúc thư mục dự án (Project Structure)

Dự án được tổ chức theo cấu trúc module hóa chuẩn để các thành viên dễ dàng phối hợp song song:

```text
Group05_Project/
├── .github/                   # Cấu hình GitHub Actions, PR template
│   └── pull_request_template.md
├── docs/                      # Tài liệu phân tích, biên bản họp nhóm
├── src/                       # Mã nguồn chính của dự án
│   ├── assets/                # Hình ảnh, font chữ, icons
│   ├── config/                # Cấu hình môi trường, constants
│   ├── models/                # Định nghĩa lớp đối tượng dữ liệu
│   ├── services/              # Xử lý kết nối API, Database
│   ├── views/                 # Giao diện người dùng (Screens / Components)
│   └── main.dart              # Điểm chạy khởi đầu của ứng dụng
├── tests/                     # Thư mục kiểm thử tự động
├── .gitignore                 # Các tệp và thư mục bị bỏ qua khi commit
└── README.md                  # Giới thiệu dự án và hướng dẫn chạy
```

---

## 🛠 Công nghệ dự kiến sử dụng (Tech Stack)

- **Ngôn ngữ / Framework**: Flutter & Dart
- **Hệ thống quản lý phiên bản**: Git & GitHub
- **Môi trường phát triển (IDE)**: Visual Studio Code / Android Studio
- **Quy trình làm việc**: Feature Branch Workflow & Pull Request Review

---

## 🚀 Hướng dẫn cài đặt cho thành viên (Getting Started)

### 1. Clone repository về máy cá nhân
```bash
git clone https://github.com/phamquanganhcode/Group05_Flutter_App.git
cd Group05_Flutter_App
```

### 2. Cài đặt các thư viện phụ thuộc
```bash
flutter pub get
```

### 3. Chạy thử nghiệm
```bash
flutter run
```

---

## 🌿 Quy định phối hợp mã nguồn (Git Workflow)

1. **Tuyệt đối không push trực tiếp lên nhánh `main`**.
2. **Quy tắc đặt tên nhánh**:
   - Tính năng mới: `feature/<ten-tinh-nang>` (Ví dụ: `feature/login-ui`, `feature/database-setup`)
   - Sửa lỗi: `fix/<ten-loi>` (Ví dụ: `fix/button-overflow`)
   - Tài liệu: `docs/<noi-dung>` (Ví dụ: `docs/update-readme`)
3. **Quy tắc tạo Pull Request (PR)**:
   - Mỗi Pull Request phải được gán ít nhất **1 thành viên khác review và Approve** trước khi nhóm trưởng bấm Merge.
