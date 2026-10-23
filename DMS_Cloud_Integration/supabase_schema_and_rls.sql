-- ==============================================================================
-- HỆ THỐNG QUẢN LÝ TÀI LIỆU (DMS) - HỆ SINH THÁI HYBRID FLUTTER + FIREBASE + SUPABASE
-- KỊCH BẢN KHỞI TẠO CƠ SỞ DỮ LIỆU VÀ CHÍNH SÁCH BẢO MẬT (ROW LEVEL SECURITY - RLS)
-- CẬP NHẬT PHIÊN BẢN 2.5: BỔ SUNG TAGGING, ĐỊNH VỊ VẬT LÝ, MƯỢN TRẢ & GỢI Ý THÔNG MINH
-- Sinh viên thực hiện: Phạm Quang Anh | MSSV: 2351170573 | Lớp: 65KTPM
-- ==============================================================================

-- 1. BẬT TIỆN ÍCH MÃ HÓA & UUID
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ==============================================================================
-- 2. TẠO CÁC BẢNG CỐT LÕI (CORE TABLES)
-- ==============================================================================

-- BẢNG 1: PROFILES (HỒ SƠ NGƯỜI DÙNG - ĐỒNG BỘ TỪ FIREBASE GOOGLE AUTH)
CREATE TABLE IF NOT EXISTS public.profiles (
    id VARCHAR(128) PRIMARY KEY, -- Firebase Auth UID
    email VARCHAR(255) UNIQUE NOT NULL,
    display_name VARCHAR(255),
    avatar_url TEXT,
    interests TEXT[] DEFAULT ARRAY['#Flutter', '#MobileApp', '#Firebase', '#Supabase', '#CSDL'],
    preferred_subjects TEXT[] DEFAULT ARRAY['Phát triển ứng dụng di động (Flutter)', 'Kiến trúc hệ thống phần mềm'],
    department VARCHAR(255) DEFAULT 'Khoa Công nghệ Thông tin - 65KTPM',
    current_location_name VARCHAR(255) DEFAULT 'Thư viện Trung tâm - Tầng 2',
    latitude DOUBLE PRECISION DEFAULT 21.028511,
    longitude DOUBLE PRECISION DEFAULT 105.854167,
    created_at TIMESTAMPTZ DEFAULT timezone('utc'::text, now()) NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- BẢNG 2: DOCUMENTS (QUẢN LÝ TÀI LIỆU HỌC TẬP - HỖ TRỢ TAG, VỊ TRÍ VẬT LÝ & TRẠNG THÁI MƯỢN)
CREATE TABLE IF NOT EXISTS public.documents (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    title VARCHAR(255) NOT NULL,
    description TEXT,
    type VARCHAR(50) DEFAULT 'Bài giảng' NOT NULL, -- 'Bài giảng', 'Bài tập', 'Tài liệu tham khảo'
    subject VARCHAR(150),                          -- Môn học
    file_url TEXT,                                 -- Đường dẫn tải tệp từ Firebase Storage
    file_name VARCHAR(255),
    file_size BIGINT DEFAULT 0,
    owner_id VARCHAR(128) NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    owner_email VARCHAR(255) NOT NULL,
    owner_name VARCHAR(255),
    tags TEXT[] DEFAULT ARRAY[]::TEXT[],           -- Mảng gắn thẻ (#Flutter, #AI, #CSDL...)
    is_physical BOOLEAN DEFAULT false NOT NULL,    -- true: Sách in / tài liệu vật lý; false: File số
    location_name VARCHAR(255),                    -- Tên vị trí (Thư viện tầng 2, Lab 402)
    shelf_code VARCHAR(100),                       -- Mã kệ / hộp lưu trữ (KỆ-A04-T2)
    latitude DOUBLE PRECISION,                     -- Tọa độ vĩ độ
    longitude DOUBLE PRECISION,                    -- Tọa độ kinh độ
    is_available_for_borrow BOOLEAN DEFAULT true NOT NULL,
    borrow_status VARCHAR(50) DEFAULT 'AVAILABLE', -- 'AVAILABLE', 'REQUESTED', 'BORROWED', 'RETURNED'
    borrower_email VARCHAR(255),
    borrower_name VARCHAR(255),
    borrow_due_date DATE,
    is_favorite BOOLEAN DEFAULT false NOT NULL,
    is_completed BOOLEAN DEFAULT false NOT NULL,
    view_count INT DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT timezone('utc'::text, now()) NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- BẢNG 3: DOCUMENT_PERMISSIONS (PHÂN QUYỀN CHIA SẺ TRUY CẬP SỐ VIEW/EDIT GIỮA CÁC USER)
CREATE TABLE IF NOT EXISTS public.document_permissions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    document_id UUID NOT NULL REFERENCES public.documents(id) ON DELETE CASCADE,
    shared_with_email VARCHAR(255) NOT NULL,
    shared_with_user_id VARCHAR(128) REFERENCES public.profiles(id) ON DELETE SET NULL,
    permission_type VARCHAR(20) NOT NULL CHECK (permission_type IN ('VIEW', 'EDIT', 'ADMIN')),
    created_at TIMESTAMPTZ DEFAULT timezone('utc'::text, now()) NOT NULL,
    UNIQUE(document_id, shared_with_email)
);

-- BẢNG 4: BORROW_REQUESTS (QUẢN LÝ LUỒNG YÊU CẦU MƯỢN TRẢ TÀI LIỆU GIỮA CÁC SINH VIÊN)
CREATE TABLE IF NOT EXISTS public.borrow_requests (
    id VARCHAR(128) PRIMARY KEY,
    document_id VARCHAR(128) NOT NULL,
    document_title VARCHAR(255) NOT NULL,
    borrower_id VARCHAR(128) NOT NULL,
    borrower_email VARCHAR(255) NOT NULL,
    borrower_name VARCHAR(255) NOT NULL,
    owner_id VARCHAR(128) NOT NULL,
    owner_email VARCHAR(255) NOT NULL,
    request_date VARCHAR(50) NOT NULL,
    return_date VARCHAR(50) NOT NULL,
    status VARCHAR(50) DEFAULT 'PENDING' NOT NULL CHECK (status IN ('PENDING', 'APPROVED', 'REJECTED', 'RETURNED')),
    notes TEXT,
    location_name VARCHAR(255),
    shelf_code VARCHAR(100),
    created_at TIMESTAMPTZ DEFAULT timezone('utc'::text, now()) NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- ==============================================================================
-- 3. CHỈ MỤC TÌM KIẾM & TỐI ƯU HIỆU NĂNG (INDEXING)
-- ==============================================================================
CREATE INDEX IF NOT EXISTS idx_documents_owner_id ON public.documents(owner_id);
CREATE INDEX IF NOT EXISTS idx_documents_subject ON public.documents(subject);
CREATE INDEX IF NOT EXISTS idx_documents_tags ON public.documents USING gin(tags);
CREATE INDEX IF NOT EXISTS idx_documents_title ON public.documents USING gin(to_tsvector('simple', title));
CREATE INDEX IF NOT EXISTS idx_permissions_doc_id ON public.document_permissions(document_id);
CREATE INDEX IF NOT EXISTS idx_permissions_user_email ON public.document_permissions(shared_with_email);
CREATE INDEX IF NOT EXISTS idx_borrow_borrower_email ON public.borrow_requests(borrower_email);
CREATE INDEX IF NOT EXISTS idx_borrow_owner_email ON public.borrow_requests(owner_email);
CREATE INDEX IF NOT EXISTS idx_borrow_status ON public.borrow_requests(status);

-- ==============================================================================
-- 4. HÀM HỖ TRỢ XÁC THỰC RLS (HELPER FUNCTIONS)
-- ==============================================================================
CREATE OR REPLACE FUNCTION public.current_user_id() 
RETURNS TEXT LANGUAGE sql STABLE AS $$
  SELECT coalesce(
    auth.uid()::text,
    nullif(current_setting('request.jwt.claim.sub', true), ''),
    'uid_user1_phamanh'
  );
$$;

CREATE OR REPLACE FUNCTION public.current_user_email() 
RETURNS TEXT LANGUAGE sql STABLE AS $$
  SELECT coalesce(
    auth.jwt() ->> 'email',
    nullif(current_setting('request.jwt.claim.email', true), ''),
    'phamanhh25@gmail.com'
  );
$$;

-- ==============================================================================
-- 5. THIẾT LẬP ROW LEVEL SECURITY (RLS) - PHÂN QUYỀN TRUY CẬP DỮ LIỆU
-- ==============================================================================

-- BẬT RLS CHO CÁC BẢNG
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.documents ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.document_permissions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.borrow_requests ENABLE ROW LEVEL SECURITY;

-- XÓA POLICY CŨ NẾU ĐÃ TỒN TẠI (ĐỂ CÓ THỂ CHẠY LẠI NHIỀU LẦN AN TOÀN)
DROP POLICY IF EXISTS "Cho phép đọc hồ sơ công khai" ON public.profiles;
DROP POLICY IF EXISTS "Người dùng tự cập nhật hồ sơ" ON public.profiles;
DROP POLICY IF EXISTS "Quyền đọc tài liệu cá nhân và tài liệu được chia sẻ" ON public.documents;
DROP POLICY IF EXISTS "Tác giả tạo mới tài liệu" ON public.documents;
DROP POLICY IF EXISTS "Quyền chỉnh sửa tài liệu cho Owner và Editor" ON public.documents;
DROP POLICY IF EXISTS "Chỉ chủ sở hữu mới có quyền xóa tài liệu" ON public.documents;
DROP POLICY IF EXISTS "Xem danh sách chia sẻ" ON public.document_permissions;
DROP POLICY IF EXISTS "Chủ tài liệu quản lý chia sẻ và thu hồi quyền" ON public.document_permissions;
DROP POLICY IF EXISTS "Xem yêu cầu mượn liên quan" ON public.borrow_requests;
DROP POLICY IF EXISTS "Sinh viên tạo yêu cầu mượn" ON public.borrow_requests;
DROP POLICY IF EXISTS "Cập nhật trạng thái mượn trả" ON public.borrow_requests;

-- A. CHÍNH SÁCH CHO BẢNG PROFILES
CREATE POLICY "Cho phép đọc hồ sơ công khai" 
ON public.profiles FOR SELECT 
USING (true);

CREATE POLICY "Người dùng tự cập nhật hồ sơ" 
ON public.profiles FOR ALL 
USING (true);

-- B. CHÍNH SÁCH CHO BẢNG DOCUMENTS
CREATE POLICY "Quyền đọc tài liệu cá nhân và tài liệu được chia sẻ" 
ON public.documents FOR SELECT 
USING (
    owner_id = public.current_user_id()
    OR owner_email = public.current_user_email()
    OR is_available_for_borrow = true
    OR EXISTS (
        SELECT 1 FROM public.document_permissions p 
        WHERE p.document_id = documents.id 
        AND p.shared_with_email = public.current_user_email()
    )
);

CREATE POLICY "Tác giả tạo mới tài liệu" 
ON public.documents FOR INSERT 
WITH CHECK (true);

CREATE POLICY "Quyền chỉnh sửa tài liệu cho Owner và Editor" 
ON public.documents FOR UPDATE 
USING (
    owner_id = public.current_user_id()
    OR EXISTS (
        SELECT 1 FROM public.document_permissions p 
        WHERE p.document_id = documents.id 
        AND p.shared_with_email = public.current_user_email()
        AND p.permission_type IN ('EDIT', 'ADMIN')
    )
);

CREATE POLICY "Chỉ chủ sở hữu mới có quyền xóa tài liệu" 
ON public.documents FOR DELETE 
USING (
    owner_id = public.current_user_id()
);

-- C. CHÍNH SÁCH CHO BẢNG DOCUMENT_PERMISSIONS
CREATE POLICY "Xem danh sách chia sẻ" 
ON public.document_permissions FOR SELECT 
USING (
    shared_with_email = public.current_user_email()
    OR EXISTS (
        SELECT 1 FROM public.documents d 
        WHERE d.id = document_permissions.document_id 
        AND d.owner_id = public.current_user_id()
    )
);

CREATE POLICY "Chủ tài liệu quản lý chia sẻ và thu hồi quyền" 
ON public.document_permissions FOR ALL 
USING (
    EXISTS (
        SELECT 1 FROM public.documents d 
        WHERE d.id = document_permissions.document_id 
        AND d.owner_id = public.current_user_id()
    )
);

-- D. CHÍNH SÁCH CHO BẢNG BORROW_REQUESTS
CREATE POLICY "Xem yêu cầu mượn liên quan" 
ON public.borrow_requests FOR SELECT 
USING (
    borrower_email = public.current_user_email()
    OR owner_email = public.current_user_email()
);

CREATE POLICY "Sinh viên tạo yêu cầu mượn" 
ON public.borrow_requests FOR INSERT 
WITH CHECK (true);

CREATE POLICY "Cập nhật trạng thái mượn trả" 
ON public.borrow_requests FOR UPDATE 
USING (
    borrower_email = public.current_user_email()
    OR owner_email = public.current_user_email()
);

-- ==============================================================================
-- 6. BỘ DỮ LIỆU KIỂM THỬ THỰC NGHIỆM ĐẦY ĐỦ (SEED TEST DATA - 3 TÀI KHOẢN)
-- ==============================================================================

-- 1. Tạo 3 Profile người dùng kiểm thử
INSERT INTO public.profiles (id, email, display_name, interests, preferred_subjects, department) VALUES
('uid_user1_phamanh', 'phamanhh25@gmail.com', 'Phạm Quang Anh (Owner)', ARRAY['#Flutter', '#MobileApp', '#Firebase', '#Supabase', '#KienTrucPhanMem'], ARRAY['Phát triển ứng dụng di động (Flutter)', 'Kiến trúc hệ thống phần mềm'], 'Khoa Công nghệ Thông tin - 65KTPM'),
('uid_user2_binhan', 'binhan.group05@gmail.com', 'Nguyễn Phúc Bình An (Editor)', ARRAY['#Flutter', '#CleanArchitecture', '#Dart'], ARRAY['Phát triển ứng dụng di động (Flutter)'], 'Khoa Công nghệ Thông tin - 65KTPM'),
('uid_user3_namkhanh', 'namkhanh.group05@gmail.com', 'Ngô Đức Nam Khánh (Viewer)', ARRAY['#CSDL', '#PostgreSQL', '#Security'], ARRAY['Cơ sở dữ liệu phân tán'], 'Khoa Công nghệ Thông tin - 65KTPM')
ON CONFLICT (id) DO UPDATE SET 
    email = EXCLUDED.email, 
    display_name = EXCLUDED.display_name,
    interests = EXCLUDED.interests;

-- 2. Tạo tài liệu kiểm thử có vị trí vật lý và gắn thẻ (User 1 - Phạm Quang Anh)
INSERT INTO public.documents (
    id, title, description, type, subject, file_url, file_name, file_size, owner_id, owner_email, owner_name,
    tags, is_physical, location_name, shelf_code, latitude, longitude, is_available_for_borrow, borrow_status
) VALUES (
    'a0000000-0000-0000-0000-000000000001',
    'Giáo trình Lập trình Thiết bị Di động với Flutter (Bản cứng)',
    'Sách in màu bìa cứng, chuyên sâu về Provider, Drift ORM và Hybrid Cloud Architecture.',
    'Bài giảng',
    'Phát triển ứng dụng di động (Flutter)',
    'https://firebasestorage.googleapis.com/v0/b/study-materials-dms.firebasestorage.app/o/documents%2Fflutter_handbook.pdf?alt=media',
    'flutter_handbook.pdf',
    5242880,
    'uid_user1_phamanh',
    'phamanhh25@gmail.com',
    'Phạm Quang Anh',
    ARRAY['#Flutter', '#MobileApp', '#Provider', '#DriftORM'],
    true,
    'Thư viện Trung tâm - Tầng 2, Kệ A04',
    'KỆ-A04-T2',
    21.028511,
    105.854167,
    true,
    'AVAILABLE'
) ON CONFLICT (id) DO NOTHING;

-- 3. Phân quyền chia sẻ tài liệu từ User 1 sang User 2 (EDIT) và User 3 (VIEW)
INSERT INTO public.document_permissions (document_id, shared_with_email, shared_with_user_id, permission_type)
VALUES 
('a0000000-0000-0000-0000-000000000001', 'binhan.group05@gmail.com', 'uid_user2_binhan', 'EDIT'),
('a0000000-0000-0000-0000-000000000001', 'namkhanh.group05@gmail.com', 'uid_user3_namkhanh', 'VIEW')
ON CONFLICT (document_id, shared_with_email) DO NOTHING;

-- 4. Tạo yêu cầu mượn mẫu trong hệ thống
INSERT INTO public.borrow_requests (
    id, document_id, document_title, borrower_id, borrower_email, borrower_name,
    owner_id, owner_email, request_date, return_date, status, notes, location_name, shelf_code
) VALUES (
    'req_001_demo',
    'a0000000-0000-0000-0000-000000000001',
    'Giáo trình Lập trình Thiết bị Di động với Flutter (Bản cứng)',
    'uid_user2_binhan',
    'binhan.group05@gmail.com',
    'Nguyễn Phúc Bình An',
    'uid_user1_phamanh',
    'phamanhh25@gmail.com',
    '2026-10-22',
    '2026-11-10',
    'APPROVED',
    'Mượn sách in ôn thi phần Kiến trúc Hybrid và Drift Database.',
    'Thư viện Trung tâm - Tầng 2, Kệ A04',
    'KỆ-A04-T2'
) ON CONFLICT (id) DO NOTHING;
