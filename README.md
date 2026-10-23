# 🚀 Dự Án Phát Triển Phần Mềm - Nhóm 5 (Group 5)

> Kho lưu trữ mã nguồn và tài liệu phối hợp phát triển dự án của Nhóm 5 · Lớp 65KTPM · Khoa Công nghệ Thông tin.

---

## 👥 Danh sách thành viên & Phân công nhiệm vụ TH2

*Căn cứ theo bảng phân công chính thức: `docs/Phan_Cong_TH2_Group05.pdf` / `DMS_Cloud_Integration/Phan_Cong_TH2_Group05.html`*

| STT | Mã sinh viên | Họ và tên | GitHub Account | Vai trò | Phụ trách chính trong TH2 (Checklist) |
|:---:|:---:|:---|:---:|:---:|:---|
| 1 | **2351170573** | **Phạm Quang Anh** | [@phamquanganhcode](https://github.com/phamquanganhcode) | **Nhóm trưởng** | **Checklist 1 & 6**: Kiến trúc Hybrid Cloud (Firebase + Supabase RLS), Supabase Storage bucket `documents`, điều phối Git & Review PR, tổng hợp kiểm thử & đóng gói báo cáo slide. |
| 2 | **2051063858** | **Nguyễn Phúc Bình An** | [@nguyenan1404z-spec](https://github.com/nguyenan1404z-spec) | **Thành viên** | **Checklist 2 & Tag (Checklist 3)**: Giao diện thích ứng Adaptive Responsive (Mobile / Web), form thêm sửa tài liệu 2 cột, responsive modal dialog, hệ thống Tag (Tag Cloud, autocomplete, multi-tag filter) và Widget Test. |
| 3 | **2351060452** | **Ngô Đức Nam Khánh** | [@kyokoxdev](https://github.com/kyokoxdev) | **Thành viên** | **Vị trí (Checklist 3) & Checklist 5**: Bản đồ vị trí vật lý khuôn viên và phòng đọc thư viện, định vị GPS, công thức tính khoảng cách Haversine, thuật toán Recommendation gợi ý tài liệu thông minh (Jaccard + Location + Explainable AI). |
| 4 | **2351170597** | **Dương Văn Hưng** | [@DuongHung1505](https://github.com/DuongHung1505) | **Thành viên** | **Checklist 4 & Firebase Messaging**: Luồng nghiệp vụ mượn & trả tài liệu (`BorrowRequest`), tự động phân quyền `document_permissions`, tích hợp Firebase Cloud Messaging (`NotificationService`), đồng bộ Realtime và kiểm thử tự động `app_test.dart`. |

---

## 📂 Danh mục các đề án trong Repository

```text
Group05_Flutter_App/
├── study_materials_app/          # [TH2] Ứng dụng Quản lý Tài liệu Học tập Đa nền tảng (Cloud DMS)
│   ├── lib/
│   │   ├── database/             # Local SQLite (Drift ORM) kiến trúc Local-first
│   │   ├── pages/                # HomePage (Responsive), AddEditMaterialPage
│   │   ├── providers/            # MaterialProvider (Quản lý trạng thái, Tag filter, mượn trả)
│   │   ├── services/             # AuthService, SupabaseService, RecommendationService, NotificationService
│   │   ├── struct/               # MaterialMeta, BorrowRequest, UserProfile
│   │   └── widgets/              # Map, Recommendations, Borrow & Share dialogs
│   ├── test/                     # app_test.dart (Unit test), widget_test.dart (Widget test)
│   └── chay_web_app.bat          # Script khởi chạy nhanh trên Web Chrome (Port 51428)
├── DMS_Cloud_Integration/        # [TH2] Hồ sơ đề án kỹ thuật & kịch bản triển khai Cloud
│   ├── Bao_Cao_Tich_Hop_Firebase_Supabase_DMS.md   # Báo cáo khoa học 6 mục Checklist
│   ├── Phan_Cong_TH2_Group05.pdf                   # Bảng phân công nhiệm vụ TH2
│   ├── Phan_Cong_TH2_Group05.html                  # Bản HTML bảng phân công
│   ├── Slide_Thuyet_Trinh_Firebase_Supabase.html   # Slide thuyết trình bảo vệ trước hội đồng
│   ├── Slide_Thuyet_Trinh_Firebase_Supabase.md     # Kịch bản thuyết trình kèm Speaker Notes
│   ├── supabase_schema_and_rls.sql                 # Script SQL CSDL & chính sách bảo mật RLS
│   └── chay_web_app.bat                            # Script khởi chạy web app
├── cashew/                       # [TH1] Ứng dụng Quản lý Chi tiêu Cá nhân
├── budget/                       # [TH1] Tài nguyên và cấu hình ứng dụng ngân sách
├── docs/                         # Tài liệu nhóm, biên bản họp và bảng phân công
│   ├── Phan_Cong_TH2_Group05.pdf
│   └── meeting_notes.md
└── README.md
```

---

## 🛠 Công nghệ sử dụng (Tech Stack)

- **Ngôn ngữ & Framework**: Flutter 3.47 / Dart 3.13 (Responsive Mobile & Web)
- **Local Database**: Drift ORM (SQLite / Wasm) theo kiến trúc Local-first (Zero Latency UI)
- **Hạ tầng Cloud**:
  - **Google Firebase**: Firebase Authentication (Google OAuth 2.0), Firebase Cloud Messaging (FCM), Cloud Firestore
  - **Supabase BaaS**: PostgreSQL 15, Row Level Security (RLS), Supabase Storage bucket
- **Thuật toán thông minh**:
  - Content-based Filtering với hệ số tương đồng Jaccard tập thẻ tag
  - Công thức khoảng cách Haversine tính độ lệch vị trí địa lý GPS
  - Mô hình Explainable AI giải thích lý do gợi ý trực quan cho sinh viên

---

## 🚀 Hướng dẫn cài đặt & Khởi chạy (Getting Started)

### 1. Clone repository
```bash
git clone https://github.com/phamquanganhcode/Group05_Flutter_App.git
cd Group05_Flutter_App
```

### 2. Chạy ứng dụng TH2 (Study Materials App)

#### Cách 1: Sử dụng Batch Script tiện ích
Nhấp đúp chuột vào tệp:
```text
Group05_Flutter_App/study_materials_app/chay_web_app.bat
```
Ứng dụng sẽ tự động khởi chạy trên Google Chrome tại cổng cố định `http://localhost:51428`.

#### Cách 2: Chạy bằng dòng lệnh Flutter
```bash
cd study_materials_app
flutter pub get
flutter run -d chrome --web-port=51428
```

### 3. Chạy kiểm thử tự động (Unit & Widget Tests)
```bash
cd study_materials_app
flutter test
```

---

## 🌿 Quy trình phối hợp mã nguồn qua Git (Git Workflow)

1. **Tuyệt đối không push trực tiếp lên nhánh `main`**.
2. **Quy tắc đặt tên nhánh**:
   - `feature/<ten-tinh-nang>`: Nhánh phát triển tính năng mới
   - `fix/<ten-loi>`: Nhánh sửa lỗi
   - `docs/<noi-dung>`: Nhánh tài liệu và báo cáo
3. **Quy trình Pull Request**:
   - Mỗi thành viên tạo feature branch, commit đúng thông tin định danh tác giả.
   - Tạo Pull Request, yêu cầu thành viên khác review và Approve trước khi Nhóm trưởng bấm Merge.
