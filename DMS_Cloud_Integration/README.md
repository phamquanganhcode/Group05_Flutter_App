# THƯ MỤC HỒ SƠ ĐỀ ÁN: HỆ THỐNG QUẢN LÝ TÀI LIỆU (DMS CLOUD)

> **Dự án:** Quản lý Tài liệu Học tập Đa nền tảng (Study Materials App - Flutter)  
> **Nhóm thực hiện:** Group 5 · 4 thành viên  
> **Nhóm trưởng:** 2351170573 · Phạm Quang Anh  
> **Thành viên:** 2051063858 · Nguyễn Phúc Bình An | 2351060452 · Ngô Đức Nam Khánh | 2351170597 · Dương Văn Hưng  
> **Lớp:** 65KTPM - Khoa Công nghệ Thông tin  
> **Hạ tầng Cloud:** Google Firebase (Auth & Storage) kết hợp Supabase (PostgreSQL & Row Level Security)  

---

## 📁 DANH MỤC CÁC TÀI LIỆU TRỌNG TÂM TRONG THƯ MỤC

### 🌟 PHẦN NÂNG CẤP MỚI: FLUTTER + FIREBASE + SUPABASE HYBRID (CHECKLIST 6 MỤC)
| Tên tệp tin | Định dạng | Mục đích sử dụng |
| :--- | :--- | :--- |
| **`Bao_Cao_Tich_Hop_Firebase_Supabase_DMS.md`** | Markdown Document | **BÁO CÁO KHOA HỌC NÂNG CẤP (Đầy đủ 6 mục Checklist)**: Tích hợp Google Auth (Firebase), lưu tệp Firebase Storage, CSDL quan hệ 3 bảng trên Supabase, Row Level Security (RLS) và kiểm thử thực nghiệm 3 tài khoản. |
| **`supabase_schema_and_rls.sql`** | SQL Script | **Kịch bản CSDL & RLS hoàn chỉnh**: Chạy trực tiếp trên Supabase SQL Editor. Tự động sinh bảng `profiles`, `documents`, `document_permissions`, áp dụng toàn bộ RLS policies và nạp dữ liệu mẫu 3 tài khoản kiểm thử. |
| **`Slide_Thuyet_Trinh_Firebase_Supabase.html`** | Web Interactive Presentation | **Slide trình chiếu tương tác (Phiên bản Firebase + Supabase)**: Mở trực tiếp trên Chrome/Edge/Cốc Cốc, giao diện công nghệ Dark mode có bảng thành viên Group 5. |
| **`Slide_Thuyet_Trinh_Firebase_Supabase.md`** | Markdown / Slide Script | **Kịch bản thuyết trình chi tiết kèm Speaker Notes** phân công cho từng thành viên Group 5 bảo vệ trước hội đồng. |

---

### 📂 PHẦN TÍCH HỢP NỀN TẢNG (FIREBASE DMS):
| Tên tệp tin | Định dạng | Mục đích sử dụng |
| :--- | :--- | :--- |
| **`Bao_Cao_Tich_Hop_Cloud_DMS.md`** | Markdown Document | Báo cáo phân tích 4 khối cốt lõi, điểm nghẽn On-premise và tích hợp Firebase. |
| **`Slide_Thuyet_Trinh_Firebase.html`** | Web Slide | Bộ slide trình chiếu giao diện Firebase truyền thống. |
| **`Slide_Thuyet_Trinh_Firebase_Setup.md`** | Markdown Script | Kịch bản thuyết trình 14 slides về quy trình setup Firebase. |
| **`Video_Tong_Hop_Bao_Cao_Group05_DMS_Cloud.mp4`** | MP4 Video (1080p) | Video báo cáo thực nghiệm gộp 3 phần (Slide -> VS Code -> Chrome Google Sign-In) thời lượng 7:16. |
| **`chay_web_app.bat`** | Windows Batch Script | Nhấp đúp để khởi chạy app Flutter trên Chrome cổng cố định 51428. |
| **`setup_tools.bat`** | Windows Batch Script | Script tự động kiểm tra Flutter SDK và cài đặt Firebase CLI. |
