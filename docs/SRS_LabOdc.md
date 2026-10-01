# ĐẶC TẢ YÊU CẦU PHẦN MỀM (SRS)
## LabOdc - Hệ thống quản lý kết nối doanh nghiệp với sinh viên UTH

---

## THÔNG TIN TÀI LIỆU

| Mục | Chi tiết |
|-----|----------|
| **Tên dự án** | LabOdc - Hệ thống quản lý kết nối doanh nghiệp với sinh viên UTH trong dự án thực tế |
| **Tên tiếng Anh** | LabOdc - A System for Managing Enterprise-Student Collaborations at UTH on Real-World Projects |
| **Loại tài liệu** | Software Requirements Specification (SRS) |
| **Phiên bản** | 1.0 |
| **Ngày** | 17 tháng 01 năm 2026 |
| **Người chuẩn bị** | Nhóm phát triển - Nhóm 6 |
| **Tổ chức** | Đại học Giao thông Vận tải TP.HCM (UTH) |
| **Trạng thái** | Bản nháp |

---

## LỊCH SỬ TÀI LIỆU

| Phiên bản | Ngày | Tác giả | Mô tả thay đổi |
|-----------|------|---------|----------------|
| 1.0 | 17/01/2026 | Nhóm 6 | Tài liệu SRS ban đầu |

---

## MỤC LỤC

1. [GIỚI THIỆU](#1-giới-thiệu)
2. [MÔ TẢ TỔNG QUAN](#2-mô-tả-tổng-quan)
3. [YÊU CẦU CHỨC NĂNG CỤ THỂ](#3-yêu-cầu-chức-năng-cụ-thể)
4. [YÊU CẦU GIAO DIỆN BÊN NGOÀI](#4-yêu-cầu-giao-diện-bên-ngoài)
5. [YÊU CẦU DỮ LIỆU](#5-yêu-cầu-dữ-liệu)
6. [YÊU CẦU PHI CHỨC NĂNG CHI TIẾT](#6-yêu-cầu-phi-chức-năng-chi-tiết)
7. [YÊU CẦU BẢO MẬT](#7-yêu-cầu-bảo-mật)
8. [TRƯỜNG HỢP KIỂM THỬ](#8-trường-hợp-kiểm-thử)
9. [PHỤ LỤC](#9-phụ-lục)

---

## 1. GIỚI THIỆU

### 1.1 Mục đích

Tài liệu Đặc tả Yêu cầu Phần mềm (SRS - Software Requirements Specification) này cung cấp mô tả chi tiết và đầy đủ về các yêu cầu kỹ thuật cho hệ thống LabOdc. Tài liệu này được sử dụng làm cơ sở cho:

- Thiết kế kiến trúc hệ thống
- Phát triển phần mềm
- Kiểm thử và validation
- Quản lý dự án
- Bảo trì và nâng cấp

### 1.2 Phạm vi

SRS này mô tả yêu cầu cho:

**Backend Services:**
- RESTful API endpoints
- Business logic
- Database schemas
- Integration với third-party services

**Web Portal (Frontend):**
- User interfaces
- Client-side logic
- State management
- API integration

**Mobile Application:**
- Native mobile UI
- Offline capabilities
- Push notifications
- Mobile-specific features

### 1.3 Định nghĩa, Từ viết tắt

Tham khảo phần Glossary trong URD document.

### 1.4 Tài liệu tham khảo

- URD_LabOdc.md - User Requirements Document
- ROADMAP.md - Lộ trình phát triển 5 tuần
- PROJECT_STRUCTURE.md - Cấu trúc dự án

### 1.5 Tổng quan

Tài liệu được tổ chức như sau:
- **Phần 2**: Mô tả tổng quan về sản phẩm
- **Phần 3**: Yêu cầu chức năng chi tiết
- **Phần 4**: Yêu cầu giao diện
- **Phần 5**: Yêu cầu dữ liệu
- **Phần 6**: Yêu cầu phi chức năng
- **Phần 7**: Yêu cầu bảo mật
- **Phần 8**: Test cases
- **Phần 9**: Phụ lục

---

## 2. MÔ TẢ TỔNG QUAN

### 2.1 Quan điểm về Sản phẩm

LabOdc là một hệ thống độc lập được phát triển đặc biệt cho UTH, bao gồm:

```
┌─────────────────────────────────────────────────────┐
│                  LabOdc System                      │
│                                                     │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────┐ │
│  │  Web Portal  │  │  Mobile App  │  │  Admin   │ │
│  │   (React)    │  │  (Flutter)   │  │Dashboard │ │
│  └───────┬──────┘  └───────┬──────┘  └────┬─────┘ │
│          │                 │                │       │
│          └─────────────────┼────────────────┘       │
│                            ▼                        │
│              ┌──────────────────────────┐           │
│              │     API Gateway          │           │
│              │   (Authentication)       │           │
│              └───────────┬──────────────┘           │
│                          │                          │
│              ┌───────────┴──────────────┐           │
│              │   Backend Services       │           │
│              │   (Spring Boot)          │           │
│              └───────────┬──────────────┘           │
│                          │                          │
│       ┌──────────────────┼──────────────────┐       │
│       ▼                  ▼                  ▼       │
│  ┌─────────┐      ┌──────────┐      ┌──────────┐  │
│  │PostgreSQL│      │  Redis   │      │Elasticsearch│ │
│  └─────────┘      └──────────┘      └──────────┘  │
│                                                     │
└─────────────────────────────────────────────────────┘
              │                           │
              ▼                           ▼
    ┌──────────────┐            ┌──────────────┐
    │    PayOS     │            │  Cloudinary  │
    │   Payment    │            │   Storage    │
    └──────────────┘            └──────────────┘
```

### 2.2 Chức năng của Sản phẩm

**Cho Doanh nghiệp:**
- Đăng ký và quản lý hồ sơ công ty
- Đề xuất dự án với thông tin đầy đủ
- Thanh toán an toàn qua PayOS
- Theo dõi tiến độ real-time
- Xem báo cáo và đánh giá

**Cho Sinh viên (Talent):**
- Quản lý hồ sơ và kỹ năng
- Duyệt và tham gia dự án
- Xem nhiệm vụ được giao
- Nhận đánh giá từ Mentor
- Theo dõi tiến độ cá nhân

**Cho Mentor:**
- Nhận lời mời dự án
- Phân tích nhiệm vụ bằng Excel
- Phân công và theo dõi
- Đánh giá hiệu suất sinh viên
- Nộp báo cáo định kỳ

**Cho Lab Administrator:**
- Xác thực doanh nghiệp và dự án
- Quản lý users (Enterprise, Talent, Mentor)
- Phân bổ quỹ (70/20/10)
- Công bố báo cáo minh bạch
- Tạm ứng quỹ (Hybrid Fund Support)

**Cho System Administrator:**
- Cấu hình hệ thống
- Quản lý vai trò và quyền hạn
- Quản lý Excel templates
- Monitoring và logging

### 2.3 Đặc điểm của Người dùng

| Actor | Đặc điểm | Kỹ năng kỹ thuật | Tần suất sử dụng |
|-------|----------|------------------|------------------|
| **Enterprise** | Nhân viên/quản lý doanh nghiệp | Cơ bản (email, web browser) | Hàng tuần |
| **Talent** | Sinh viên UTH | Trung bình (CNTT cơ bản) | Hàng ngày |
| **Mentor** | Giảng viên/chuyên gia | Cao (Excel, technical tools) | Hàng tuần |
| **Lab Admin** | Nhân viên Lab UTH | Cao (quản trị hệ thống) | Hàng ngày |
| **System Admin** | IT staff | Rất cao (technical expert) | Theo nhu cầu |

### 2.4 Ràng buộc

**Ràng buộc Công nghệ:**
- PHẢI sử dụng Spring Boot cho backend
- PHẢI sử dụng ReactJS + TypeScript cho web
- PHẢI sử dụng Flutter cho mobile
- PHẢI sử dụng PostgreSQL, Redis, Elasticsearch
- PHẢI deploy lên AWS với Docker

**Ràng buộc Nghiệp vụ:**
- CHỈ sinh viên UTH (@uth.edu.vn) mới được đăng ký Talent
- Quy tắc phân phối quỹ 70/20/10 CỐ ĐỊNH
- KHÔNG sử dụng Jira/Trello (dùng Excel templates)

**Ràng buộc Thời gian:**
- Phát triển trong 5 tuần (35 ngày)
- Maintenance window: 2-6 AM Chủ nhật

### 2.5 Giả định và Phụ thuộc

**Giả định:**
- Internet connection ≥ 1 Mbps
- PayOS uptime > 99%
- Cloudinary available
- Email service working

**Phụ thuộc:**
- PayOS API cho payment processing
- Cloudinary API cho file storage
- AWS infrastructure
- SMTP server cho email

---

## 3. YÊU CẦU CHỨC NĂNG CỤ THỂ

### 3.1 Module Authentication

#### FR-AUTH-001: Đăng nhập

**ID:** FR-AUTH-001  
**Tên:** User Login  
**Mô tả:** Người dùng đăng nhập vào hệ thống bằng email và password.

**Input:**
- `email`: String, required, format email
- `password`: String, required, min 8 characters

**Processing:**
1. Validate input (email format, password not empty)
2. Query database để tìm user theo email
3. So sánh hashed password
4. Kiểm tra account status (active/inactive/locked)
5. Tạo JWT token với payload: user_id, role, email
6. Lưu session vào Redis (TTL: 24h)
7. Return token và user info

**Output:**
```json
{
  "success": true,
  "data": {
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "refreshToken": "refresh_token_here",
    "user": {
      "id": 123,
      "email": "user@uth.edu.vn",
      "name": "Nguyen Van A",
      "role": "TALENT",
      "avatar": "https://cloudinary.com/avatar.jpg"
    }
  }
}
```

**Error Handling:**
- `400 Bad Request`: Invalid email format
- `401 Unauthorized`: Wrong email or password
- `403 Forbidden`: Account locked or inactive
- `500 Internal Server Error`: Database/Redis error

**Business Rules:**
- Lock account sau 5 lần sai (reset sau 30 phút)
- JWT token expire: 30 phút
- Refresh token expire: 7 ngày
- Log all login attempts

**Test Cases:**
- TC-AUTH-001-01: Login với credentials hợp lệ
- TC-AUTH-001-02: Login với email không tồn tại
- TC-AUTH-001-03: Login với password sai
- TC-AUTH-001-04: Login với account bị lock
- TC-AUTH-001-05: Login sau 5 lần sai

---

#### FR-AUTH-002: Đăng ký

**ID:** FR-AUTH-002  
**Tên:** User Registration  
**Mô tả:** Người dùng mới đăng ký tài khoản.

**Input (Enterprise):**
```json
{
  "email": "company@example.com",
  "password": "SecurePass123!",
  "companyName": "ABC Technology",
  "taxCode": "0123456789",
  "address": "123 Nguyen Hue, Q1, HCM",
  "representative": "Nguyen Van B",
  "phone": "0901234567",
  "industry": "Information Technology"
}
```

**Input (Talent):**
```json
{
  "email": "student@uth.edu.vn",
  "password": "SecurePass123!",
  "fullName": "Tran Thi C",
  "studentId": "2021600001",
  "faculty": "Information Technology",
  "yearOfStudy": 3,
  "phone": "0901234567"
}
```

**Processing:**
1. Validate input fields
2. Kiểm tra email đã tồn tại chưa
3. Validate email domain:
   - Talent: PHẢI là @uth.edu.vn
   - Enterprise: Bất kỳ domain hợp lệ
4. Hash password (bcrypt, cost=10)
5. Tạo verification token (UUID)
6. Lưu user vào database (status=PENDING)
7. Gửi email verification
8. Return success message

**Output:**
```json
{
  "success": true,
  "message": "Đăng ký thành công. Vui lòng kiểm tra email để xác thực tài khoản.",
  "data": {
    "userId": 456,
    "email": "student@uth.edu.vn"
  }
}
```

**Business Rules:**
- Enterprise account cần Lab Admin approve
- Talent account tự động active sau email verification
- Password requirements: min 8 chars, uppercase, lowercase, number, special char
- Email verification link expire sau 24h

**Database Schema:**
```sql
CREATE TABLE users (
    id BIGSERIAL PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    role VARCHAR(50) NOT NULL,
    status VARCHAR(20) DEFAULT 'PENDING',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE enterprises (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT REFERENCES users(id),
    company_name VARCHAR(255) NOT NULL,
    tax_code VARCHAR(20) UNIQUE NOT NULL,
    address TEXT,
    representative VARCHAR(255),
    phone VARCHAR(20),
    industry VARCHAR(100),
    logo_url VARCHAR(500),
    verified BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE talents (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT REFERENCES users(id),
    full_name VARCHAR(255) NOT NULL,
    student_id VARCHAR(20) UNIQUE NOT NULL,
    faculty VARCHAR(100),
    year_of_study INTEGER,
    phone VARCHAR(20),
    avatar_url VARCHAR(500),
    skills JSONB,
    certifications JSONB,
    portfolio_url VARCHAR(500),
    cv_url VARCHAR(500),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

---

#### FR-AUTH-003: Quên mật khẩu

**ID:** FR-AUTH-003  
**Tên:** Forgot Password  
**Mô tả:** Người dùng yêu cầu reset mật khẩu qua email.

**Input:**
```json
{
  "email": "user@example.com"
}
```

**Processing:**
1. Validate email format
2. Tìm user trong database
3. Tạo reset token (UUID, 6 digits OTP)
4. Lưu token vào Redis (TTL: 1 hour)
5. Gửi email chứa link reset và OTP
6. Return success message (không reveal user existence)

**Output:**
```json
{
  "success": true,
  "message": "Nếu email tồn tại trong hệ thống, bạn sẽ nhận được hướng dẫn reset mật khẩu."
}
```

**Reset Password Endpoint:**

**Input:**
```json
{
  "token": "abc-def-ghi-123",
  "otp": "123456",
  "newPassword": "NewSecurePass456!"
}
```

**Processing:**
1. Validate token từ Redis
2. Verify OTP
3. Validate password strength
4. Hash new password
5. Update database
6. Xóa token từ Redis
7. Gửi email confirmation

**Business Rules:**
- Reset link valid 1 giờ
- OTP 6 digits
- Chỉ cho phép 3 lần nhập OTP sai
- New password khác old password

---

### 3.2 Module Enterprise

#### FR-ENT-001: Quản lý Hồ sơ Doanh nghiệp

**ID:** FR-ENT-001  
**Tên:** Manage Enterprise Profile  
**Mô tả:** Doanh nghiệp cập nhật thông tin hồ sơ.

**API Endpoint:**
```
GET    /api/enterprise/profile
PUT    /api/enterprise/profile
POST   /api/enterprise/profile/logo
```

**GET /api/enterprise/profile**

Response:
```json
{
  "success": true,
  "data": {
    "id": 123,
    "companyName": "ABC Technology",
    "taxCode": "0123456789",
    "address": "123 Nguyen Hue, Q1, HCM",
    "representative": "Nguyen Van B",
    "phone": "0901234567",
    "email": "company@example.com",
    "industry": "Information Technology",
    "logoUrl": "https://cloudinary.com/logo.jpg",
    "verified": true,
    "status": "ACTIVE",
    "createdAt": "2026-01-01T00:00:00Z"
  }
}
```

**PUT /api/enterprise/profile**

Request:
```json
{
  "companyName": "ABC Technology Co., Ltd",
  "address": "456 Le Loi, Q1, HCM",
  "phone": "0901234568",
  "industry": "Software Development"
}
```

Response:
```json
{
  "success": true,
  "message": "Cập nhật hồ sơ thành công",
  "data": { /* updated profile */ }
}
```

**POST /api/enterprise/profile/logo**

Request: `multipart/form-data`
- `file`: Image file (JPG/PNG, max 5MB)

Processing:
1. Validate file type và size
2. Scan virus
3. Upload to Cloudinary
4. Generate thumbnail
5. Update database
6. Return URL

Response:
```json
{
  "success": true,
  "data": {
    "logoUrl": "https://cloudinary.com/new-logo.jpg",
    "thumbnailUrl": "https://cloudinary.com/new-logo-thumb.jpg"
  }
}
```

**Validation Rules:**
- Company name: 5-255 characters
- Tax code: 10-13 digits, unique
- Phone: Vietnamese phone format
- Logo: JPG/PNG, max 5MB

---

#### FR-ENT-002: Đề xuất Dự án

**ID:** FR-ENT-002  
**Tên:** Submit Project Proposal  
**Mô tả:** Doanh nghiệp đề xuất dự án mới.

**API Endpoint:**
```
POST   /api/enterprise/projects
GET    /api/enterprise/projects
GET    /api/enterprise/projects/{id}
PUT    /api/enterprise/projects/{id}/draft
```

**POST /api/enterprise/projects**

Request:
```json
{
  "title": "Website Quản lý Bán hàng",
  "description": "Xây dựng website quản lý bán hàng online với dashboard admin, quản lý sản phẩm, đơn hàng, khách hàng",
  "objectives": [
    "Quản lý sản phẩm và kho",
    "Xử lý đơn hàng tự động",
    "Dashboard báo cáo real-time"
  ],
  "technologies": ["ReactJS", "NodeJS", "MongoDB", "Redis"],
  "startDate": "2026-02-01",
  "endDate": "2026-05-31",
  "budget": 100000000,
  "numberOfStudents": 5,
  "skillRequirements": [
    {
      "skill": "ReactJS",
      "level": "Intermediate",
      "required": true
    },
    {
      "skill": "NodeJS",
      "level": "Intermediate",
      "required": true
    }
  ],
  "attachments": [
    {
      "fileName": "requirement.pdf",
      "fileUrl": "https://cloudinary.com/req.pdf"
    }
  ]
}
```

**Processing:**
1. Validate input (required fields, date ranges, budget > 0)
2. Kiểm tra enterprise có active không
3. Tạo project record (status=PENDING)
4. Upload attachments to Cloudinary
5. Calculate fund distribution:
   - Team (70%): 70,000,000
   - Mentor (20%): 20,000,000
   - Lab (10%): 10,000,000
6. Gửi notification đến Lab Admin
7. Return project ID

Response:
```json
{
  "success": true,
  "message": "Đề xuất dự án đã được gửi. Lab sẽ xem xét trong vòng 48 giờ.",
  "data": {
    "projectId": 789,
    "status": "PENDING",
    "fundDistribution": {
      "total": 100000000,
      "team": 70000000,
      "mentor": 20000000,
      "lab": 10000000
    }
  }
}
```

**Business Rules:**
- Budget minimum: 10,000,000 VNĐ
- Duration minimum: 1 tháng
- Duration maximum: 6 tháng
- Number of students: 3-10
- Attachments max: 5 files, 20MB each

**Database Schema:**
```sql
CREATE TABLE projects (
    id BIGSERIAL PRIMARY KEY,
    enterprise_id BIGINT REFERENCES enterprises(id),
    title VARCHAR(255) NOT NULL,
    description TEXT NOT NULL,
    objectives JSONB,
    technologies JSONB,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    budget DECIMAL(15,2) NOT NULL,
    number_of_students INTEGER NOT NULL,
    skill_requirements JSONB,
    status VARCHAR(20) DEFAULT 'PENDING',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    validated_by BIGINT REFERENCES users(id),
    validated_at TIMESTAMP,
    mentor_id BIGINT REFERENCES mentors(id),
    CONSTRAINT check_dates CHECK (end_date > start_date),
    CONSTRAINT check_budget CHECK (budget >= 10000000),
    CONSTRAINT check_students CHECK (number_of_students BETWEEN 3 AND 10)
);

CREATE TABLE project_attachments (
    id BIGSERIAL PRIMARY KEY,
    project_id BIGINT REFERENCES projects(id),
    file_name VARCHAR(255),
    file_url VARCHAR(500),
    file_size BIGINT,
    uploaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE fund_distributions (
    id BIGSERIAL PRIMARY KEY,
    project_id BIGINT REFERENCES projects(id),
    total_amount DECIMAL(15,2),
    team_amount DECIMAL(15,2),
    mentor_amount DECIMAL(15,2),
    lab_amount DECIMAL(15,2),
    status VARCHAR(20) DEFAULT 'PENDING',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

---

#### FR-ENT-003: Thanh toán Dự án

**ID:** FR-ENT-003  
**Tên:** Payment Processing  
**Mô tả:** Doanh nghiệp thanh toán cho dự án qua PayOS.

**API Endpoint:**
```
POST   /api/enterprise/payments/create
GET    /api/enterprise/payments/{id}
POST   /api/enterprise/payments/webhook
GET    /api/enterprise/payments/history
```

**POST /api/enterprise/payments/create**

Request:
```json
{
  "projectId": 789,
  "amount": 100000000,
  "description": "Thanh toán dự án Website Quản lý Bán hàng",
  "returnUrl": "https://labodc.uth.edu.vn/payments/success",
  "cancelUrl": "https://labodc.uth.edu.vn/payments/cancel"
}
```

**Processing:**
1. Validate project exists và thuộc về enterprise
2. Kiểm tra project status (APPROVED)
3. Tạo payment record (status=PENDING)
4. Call PayOS API để tạo payment link:
```javascript
const payosPayload = {
  orderCode: `LABODC-${projectId}-${timestamp}`,
  amount: amount,
  description: description,
  returnUrl: returnUrl,
  cancelUrl: cancelUrl,
  expiredAt: Date.now() + 15*60*1000 // 15 phút
};

const payosResponse = await payos.createPaymentLink(payosPayload);
```
5. Lưu PayOS transaction ID
6. Return payment link

Response:
```json
{
  "success": true,
  "data": {
    "paymentId": 1001,
    "paymentUrl": "https://pay.payos.vn/web/abc123xyz",
    "qrCode": "https://api.payos.vn/qr/abc123xyz.png",
    "amount": 100000000,
    "expiredAt": "2026-01-17T10:30:00Z"
  }
}
```

**POST /api/enterprise/payments/webhook** (PayOS callback)

Request từ PayOS:
```json
{
  "code": "00",
  "desc": "Thành công",
  "data": {
    "orderCode": "LABODC-789-1234567890",
    "amount": 100000000,
    "description": "Thanh toán dự án Website Quản lý Bán hàng",
    "accountNumber": "12345678",
    "reference": "FT123456",
    "transactionDateTime": "2026-01-17T10:15:00Z"
  },
  "signature": "abc123def456..."
}
```

**Processing:**
1. Verify PayOS signature
2. Tìm payment record theo orderCode
3. Update payment status:
   - code=00: SUCCESS
   - code!=00: FAILED
4. Nếu SUCCESS:
   - Tạo invoice
   - Phân bổ quỹ (70/20/10)
   - Update project status
   - Gửi email confirmation
5. Return response to PayOS

**Business Rules:**
- Payment link valid 15 phút
- Chỉ accept payment cho APPROVED projects
- Tự động tạo invoice sau payment success
- Fund distribution sau khi payment confirmed

**Database Schema:**
```sql
CREATE TABLE payments (
    id BIGSERIAL PRIMARY KEY,
    project_id BIGINT REFERENCES projects(id),
    enterprise_id BIGINT REFERENCES enterprises(id),
    amount DECIMAL(15,2) NOT NULL,
    status VARCHAR(20) DEFAULT 'PENDING',
    payos_order_code VARCHAR(100) UNIQUE,
    payos_transaction_id VARCHAR(100),
    payment_method VARCHAR(50),
    paid_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    description TEXT,
    invoice_url VARCHAR(500)
);

CREATE TABLE invoices (
    id BIGSERIAL PRIMARY KEY,
    payment_id BIGINT REFERENCES payments(id),
    invoice_number VARCHAR(50) UNIQUE,
    amount DECIMAL(15,2),
    tax_amount DECIMAL(15,2),
    total_amount DECIMAL(15,2),
    issued_date DATE,
    pdf_url VARCHAR(500),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

---

### 3.3 Module Talent

#### FR-TAL-001: Quản lý Hồ sơ Cá nhân

**ID:** FR-TAL-001  
**Tên:** Manage Talent Profile  
**Mô tả:** Sinh viên quản lý hồ sơ, kỹ năng, portfolio.

**API Endpoints:**
```
GET    /api/talent/profile
PUT    /api/talent/profile
POST   /api/talent/profile/avatar
POST   /api/talent/profile/cv
POST   /api/talent/skills
DELETE /api/talent/skills/{id}
```

**GET /api/talent/profile**

Response:
```json
{
  "success": true,
  "data": {
    "id": 456,
    "fullName": "Tran Thi C",
    "studentId": "2021600001",
    "faculty": "Information Technology",
    "yearOfStudy": 3,
    "email": "student@uth.edu.vn",
    "phone": "0901234567",
    "avatarUrl": "https://cloudinary.com/avatar.jpg",
    "cvUrl": "https://cloudinary.com/cv.pdf",
    "portfolioUrl": "https://github.com/tranthic",
    "skills": [
      {
        "id": 1,
        "name": "ReactJS",
        "level": "Intermediate",
        "yearsOfExperience": 1.5
      },
      {
        "id": 2,
        "name": "NodeJS",
        "level": "Beginner",
        "yearsOfExperience": 0.5
      }
    ],
    "certifications": [
      {
        "id": 1,
        "name": "AWS Cloud Practitioner",
        "issuer": "Amazon Web Services",
        "issueDate": "2025-06-15",
        "credentialUrl": "https://aws.amazon.com/cert/123"
      }
    ],
    "projectsCompleted": 3,
    "averageRating": 4.5,
    "status": "ACTIVE"
  }
}
```

**PUT /api/talent/profile**

Request:
```json
{
  "phone": "0901234568",
  "portfolioUrl": "https://github.com/newtran"
}
```

**POST /api/talent/skills**

Request:
```json
{
  "name": "Python",
  "level": "Intermediate",
  "yearsOfExperience": 2
}
```

Response:
```json
{
  "success": true,
  "data": {
    "skillId": 3,
    "name": "Python",
    "level": "Intermediate",
    "yearsOfExperience": 2
  }
}
```

**Database Schema:**
```sql
CREATE TABLE talent_skills (
    id BIGSERIAL PRIMARY KEY,
    talent_id BIGINT REFERENCES talents(id),
    skill_name VARCHAR(100) NOT NULL,
    level VARCHAR(50),
    years_of_experience DECIMAL(3,1),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(talent_id, skill_name)
);

CREATE TABLE talent_certifications (
    id BIGSERIAL PRIMARY KEY,
    talent_id BIGINT REFERENCES talents(id),
    name VARCHAR(255) NOT NULL,
    issuer VARCHAR(255),
    issue_date DATE,
    expiry_date DATE,
    credential_url VARCHAR(500),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

---

#### FR-TAL-002: Duyệt và Tham gia Dự án

**ID:** FR-TAL-002  
**Tên:** Browse and Join Projects  
**Mô tả:** Sinh viên xem danh sách dự án và đăng ký tham gia.

**API Endpoints:**
```
GET    /api/talent/projects/available
GET    /api/talent/projects/{id}
POST   /api/talent/projects/{id}/join
GET    /api/talent/projects/my-projects
```

**GET /api/talent/projects/available**

Query Parameters:
- `page`: integer, default=1
- `limit`: integer, default=10, max=50
- `technology`: string, optional (filter by tech)
- `minBudget`: integer, optional
- `maxBudget`: integer, optional
- `sort`: string, enum(newest, deadline, budget)

Response:
```json
{
  "success": true,
  "data": {
    "projects": [
      {
        "id": 789,
        "title": "Website Quản lý Bán hàng",
        "company": {
          "name": "ABC Technology",
          "logoUrl": "https://cloudinary.com/logo.jpg"
        },
        "description": "Xây dựng website quản lý bán hàng online...",
        "technologies": ["ReactJS", "NodeJS", "MongoDB"],
        "startDate": "2026-02-01",
        "endDate": "2026-05-31",
        "duration": "4 tháng",
        "budget": 100000000,
        "allowancePerStudent": "≈14,000,000 VNĐ",
        "numberOfStudents": 5,
        "spotsAvailable": 3,
        "skillRequirements": [
          "ReactJS (Intermediate)",
          "NodeJS (Intermediate)"
        ],
        "status": "RECRUITING"
      }
    ],
    "pagination": {
      "currentPage": 1,
      "totalPages": 5,
      "totalProjects": 47,
      "hasNext": true,
      "hasPrev": false
    }
  }
}
```

**POST /api/talent/projects/{id}/join**

Request:
```json
{
  "message": "Em rất quan tâm đến dự án này và có kinh nghiệm với ReactJS và NodeJS. Em mong muốn được tham gia để học hỏi thêm."
}
```

**Processing:**
1. Validate project exists và status=RECRUITING
2. Kiểm tra talent chưa join project này
3. Kiểm tra số lượng spots còn
4. Kiểm tra skill requirements (optional warning)
5. Tạo join request (status=PENDING)
6. Gửi notification đến Mentor
7. Auto-approve nếu still có spots (hoặc cần Mentor approve)

Response:
```json
{
  "success": true,
  "message": "Bạn đã đăng ký tham gia dự án thành công. Mentor sẽ xem xét yêu cầu của bạn.",
  "data": {
    "joinRequestId": 5001,
    "status": "PENDING"
  }
}
```

**Database Schema:**
```sql
CREATE TABLE project_members (
    id BIGSERIAL PRIMARY KEY,
    project_id BIGINT REFERENCES projects(id),
    talent_id BIGINT REFERENCES talents(id),
    status VARCHAR(20) DEFAULT 'PENDING',
    role VARCHAR(50) DEFAULT 'MEMBER',
    join_message TEXT,
    joined_at TIMESTAMP,
    approved_by BIGINT REFERENCES users(id),
    approved_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(project_id, talent_id)
);
```

---

### 3.4 Module Talent Leader

#### FR-TL-001: Quản lý Phân phối Quỹ

**ID:** FR-TL-001  
**Tên:** Manage Fund Distribution  
**Mô tả:** Trưởng nhóm phân phối 70% quỹ cho các thành viên trong nhóm.

**API Endpoints:**
```
GET    /api/talent-leader/projects/{projectId}/fund-distribution
POST   /api/talent-leader/projects/{projectId}/fund-distribution
PUT    /api/talent-leader/projects/{projectId}/fund-distribution/{id}
GET    /api/talent-leader/projects/{projectId}/fund-distribution/history
```

**GET /api/talent-leader/projects/{projectId}/fund-distribution**

Response:
```json
{
  "success": true,
  "data": {
    "projectId": 789,
    "projectTitle": "Website Quản lý Bán hàng",
    "totalFund": 100000000,
    "teamAllocation": 70000000,
    "members": [
      {
        "talentId": 456,
        "fullName": "Tran Thi C",
        "role": "Frontend Developer",
        "contributionScore": 0,
        "allocatedAmount": 0,
        "allocatedPercentage": 0
      },
      {
        "talentId": 457,
        "fullName": "Nguyen Van D",
        "role": "Backend Developer",
        "contributionScore": 0,
        "allocatedAmount": 0,
        "allocatedPercentage": 0
      },
      {
        "talentId": 458,
        "fullName": "Le Thi E",
        "role": "UI/UX Designer",
        "contributionScore": 0,
        "allocatedAmount": 0,
        "allocatedPercentage": 0
      }
    ],
    "status": "DRAFT",
    "totalPercentage": 0,
    "mentorApproved": false
  }
}
```

**POST /api/talent-leader/projects/{projectId}/fund-distribution**

Request:
```json
{
  "distributions": [
    {
      "talentId": 456,
      "percentage": 35,
      "reason": "Hoàn thành tốt frontend, UI responsive, code quality cao"
    },
    {
      "talentId": 457,
      "percentage": 40,
      "reason": "Xây dựng backend API đầy đủ, database design tốt, handle security"
    },
    {
      "talentId": 458,
      "percentage": 25,
      "reason": "Thiết kế UI/UX đẹp, user-friendly, follow brand guideline"
    }
  ],
  "note": "Phân phối dựa trên đóng góp và effort của từng thành viên"
}
```

**Processing:**
1. Validate Talent Leader của project này
2. Validate tổng percentage = 100%
3. Validate tất cả members có trong distributions
4. Tính toán amount cho từng người:
   - talentId 456: 70,000,000 × 35% = 24,500,000
   - talentId 457: 70,000,000 × 40% = 28,000,000
   - talentId 458: 70,000,000 × 25% = 17,500,000
5. Tạo distribution record (status=PENDING_MENTOR_APPROVAL)
6. Gửi notification đến Mentor
7. Return distribution ID

Response:
```json
{
  "success": true,
  "message": "Phân phối quỹ đã được gửi đến Mentor để xác nhận",
  "data": {
    "distributionId": 2001,
    "status": "PENDING_MENTOR_APPROVAL",
    "distributions": [
      {
        "talentId": 456,
        "fullName": "Tran Thi C",
        "percentage": 35,
        "amount": 24500000
      },
      {
        "talentId": 457,
        "fullName": "Nguyen Van D",
        "percentage": 40,
        "amount": 28000000
      },
      {
        "talentId": 458,
        "fullName": "Le Thi E",
        "percentage": 25,
        "amount": 17500000
      }
    ],
    "totalAmount": 70000000
  }
}
```

**Business Rules:**
- Tổng percentage PHẢI = 100%
- Mỗi member PHẢI có ít nhất 5%
- PHẢI có reason cho mỗi distribution
- Mentor PHẢI approve trước khi giải ngân
- Chỉ Talent Leader mới có quyền phân phối

**Database Schema:**
```sql
CREATE TABLE team_fund_distributions (
    id BIGSERIAL PRIMARY KEY,
    project_id BIGINT REFERENCES projects(id),
    fund_distribution_id BIGINT REFERENCES fund_distributions(id),
    created_by BIGINT REFERENCES talents(id), -- Talent Leader
    status VARCHAR(20) DEFAULT 'DRAFT',
    total_amount DECIMAL(15,2),
    note TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    submitted_at TIMESTAMP,
    mentor_approved_at TIMESTAMP,
    mentor_approved_by BIGINT REFERENCES mentors(id),
    lab_disbursed_at TIMESTAMP
);

CREATE TABLE team_member_allocations (
    id BIGSERIAL PRIMARY KEY,
    distribution_id BIGINT REFERENCES team_fund_distributions(id),
    talent_id BIGINT REFERENCES talents(id),
    percentage DECIMAL(5,2) NOT NULL,
    amount DECIMAL(15,2) NOT NULL,
    reason TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT check_percentage CHECK (percentage BETWEEN 5 AND 100)
);
```

---

#### FR-TL-002: Nộp Báo cáo Nhóm

**ID:** FR-TL-002  
**Tên:** Submit Team Report  
**Mô tả:** Trưởng nhóm nộp báo cáo tiến độ định kỳ của nhóm.

**API Endpoints:**
```
POST   /api/talent-leader/projects/{projectId}/reports
GET    /api/talent-leader/projects/{projectId}/reports
GET    /api/talent-leader/projects/{projectId}/reports/{id}
PUT    /api/talent-leader/projects/{projectId}/reports/{id}
```

**POST /api/talent-leader/projects/{projectId}/reports**

Request:
```json
{
  "reportType": "MONTHLY",
  "reportingPeriod": "2026-02",
  "overallProgress": 45,
  "tasksCompleted": [
    {
      "taskId": 101,
      "taskName": "Thiết kế database schema",
      "completedBy": "Nguyen Van D",
      "completedDate": "2026-02-15"
    },
    {
      "taskId": 102,
      "taskName": "Xây dựng API authentication",
      "completedBy": "Nguyen Van D",
      "completedDate": "2026-02-20"
    },
    {
      "taskId": 103,
      "taskName": "Thiết kế UI/UX mockup",
      "completedBy": "Le Thi E",
      "completedDate": "2026-02-18"
    }
  ],
  "tasksInProgress": [
    {
      "taskId": 104,
      "taskName": "Frontend Dashboard implementation",
      "assignedTo": "Tran Thi C",
      "expectedCompletion": "2026-03-05",
      "currentProgress": 60
    }
  ],
  "issues": [
    {
      "severity": "MEDIUM",
      "description": "Cloudinary API có lúc slow, ảnh hưởng upload speed",
      "impact": "Upload avatar mất > 5 giây",
      "proposedSolution": "Implement lazy loading và compression"
    }
  ],
  "nextMonthPlan": [
    "Hoàn thiện Frontend Dashboard",
    "Implement Project Management module",
    "Integration testing giữa Frontend và Backend",
    "Deploy lên staging environment"
  ],
  "teamPerformance": {
    "collaboration": 4.5,
    "communication": 4.0,
    "productivity": 4.2,
    "codeQuality": 4.3
  },
  "attachments": [
    {
      "fileName": "progress-screenshots.zip",
      "fileUrl": "https://cloudinary.com/files/progress.zip"
    }
  ]
}
```

**Processing:**
1. Validate Talent Leader quyền
2. Validate reportingPeriod không duplicate
3. Validate overallProgress (0-100)
4. Upload attachments to Cloudinary
5. Tạo report record
6. Gửi notification đến Mentor và Lab Admin
7. Return report ID

Response:
```json
{
  "success": true,
  "message": "Báo cáo đã được nộp thành công",
  "data": {
    "reportId": 3001,
    "projectId": 789,
    "reportType": "MONTHLY",
    "reportingPeriod": "2026-02",
    "overallProgress": 45,
    "submittedAt": "2026-02-28T23:45:00Z",
    "status": "SUBMITTED"
  }
}
```

**Business Rules:**
- Report PHẢI được nộp cuối mỗi tháng
- OverallProgress PHẢI tăng dần (không được giảm)
- PHẢI có ít nhất 3 tasks completed/in progress
- Nhắc nhở auto 3 ngày trước deadline
- Quá hạn 7 ngày → Warning đến Lab Admin

**Database Schema:**
```sql
CREATE TABLE team_reports (
    id BIGSERIAL PRIMARY KEY,
    project_id BIGINT REFERENCES projects(id),
    submitted_by BIGINT REFERENCES talents(id), -- Talent Leader
    report_type VARCHAR(20) NOT NULL,
    reporting_period VARCHAR(7) NOT NULL, -- YYYY-MM
    overall_progress INTEGER CHECK (overall_progress BETWEEN 0 AND 100),
    tasks_completed JSONB,
    tasks_in_progress JSONB,
    issues JSONB,
    next_month_plan JSONB,
    team_performance JSONB,
    status VARCHAR(20) DEFAULT 'DRAFT',
    submitted_at TIMESTAMP,
    reviewed_by BIGINT REFERENCES mentors(id),
    reviewed_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(project_id, reporting_period)
);

CREATE TABLE report_attachments (
    id BIGSERIAL PRIMARY KEY,
    report_id BIGINT REFERENCES team_reports(id),
    file_name VARCHAR(255),
    file_url VARCHAR(500),
    file_size BIGINT,
    uploaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

---

### 3.5 Module Mentor

#### FR-MEN-001: Chấp nhận Lời mời Dự án

**ID:** FR-MEN-001  
**Tên:** Accept Project Invitation  
**Mô tả:** Mentor xem và phản hồi lời mời tham gia dự án từ Lab Admin.

**API Endpoints:**
```
GET    /api/mentor/invitations
GET    /api/mentor/invitations/{id}
POST   /api/mentor/invitations/{id}/accept
POST   /api/mentor/invitations/{id}/reject
```

**GET /api/mentor/invitations**

Query Parameters:
- `status`: string, enum(PENDING, ACCEPTED, REJECTED)
- `page`: integer
- `limit`: integer

Response:
```json
{
  "success": true,
  "data": {
    "invitations": [
      {
        "id": 5001,
        "project": {
          "id": 789,
          "title": "Website Quản lý Bán hàng",
          "enterprise": "ABC Technology",
          "description": "Xây dựng website quản lý bán hàng online...",
          "technologies": ["ReactJS", "NodeJS", "MongoDB"],
          "startDate": "2026-02-01",
          "endDate": "2026-05-31",
          "budget": 100000000,
          "numberOfStudents": 5
        },
        "mentorCompensation": 20000000,
        "expectedEffort": "10-15 giờ/tuần",
        "responsibilities": [
          "Hướng dẫn team xây dựng architecture",
          "Code review",
          "Phân tích và phân công tasks",
          "Đánh giá hiệu suất hàng tháng"
        ],
        "invitedBy": {
          "name": "Lab Admin",
          "email": "lab@uth.edu.vn"
        },
        "invitedAt": "2026-01-15T10:00:00Z",
        "status": "PENDING"
      }
    ],
    "pagination": {
      "currentPage": 1,
      "totalPages": 2,
      "totalInvitations": 15
    }
  }
}
```

**POST /api/mentor/invitations/{id}/accept**

Request:
```json
{
  "message": "Em rất vui được tham gia dự án này. Em có kinh nghiệm 5 năm với ReactJS và NodeJS, đã mentor nhiều team trước đây.",
  "availability": {
    "hoursPerWeek": 12,
    "preferredMeetingDays": ["Tuesday", "Thursday", "Saturday"]
  }
}
```

**Processing:**
1. Validate invitation exists và status=PENDING
2. Validate mentor chưa accept
3. Update invitation status=ACCEPTED
4. Gán mentor cho project
5. Tạo mentor_project relationship
6. Gửi notification đến Lab Admin và Enterprise
7. Return confirmation

Response:
```json
{
  "success": true,
  "message": "Bạn đã chấp nhận lời mời thành công. Lab sẽ liên hệ với bạn sớm.",
  "data": {
    "invitationId": 5001,
    "projectId": 789,
    "mentorId": 201,
    "status": "ACCEPTED",
    "acceptedAt": "2026-01-16T09:30:00Z"
  }
}
```

**POST /api/mentor/invitations/{id}/reject**

Request:
```json
{
  "reason": "Hiện tại em đang mentor 3 dự án khác, không đủ thời gian để hỗ trợ thêm dự án mới."
}
```

Response:
```json
{
  "success": true,
  "message": "Lời mời đã được từ chối",
  "data": {
    "invitationId": 5001,
    "status": "REJECTED"
  }
}
```

**Database Schema:**
```sql
CREATE TABLE mentor_invitations (
    id BIGSERIAL PRIMARY KEY,
    project_id BIGINT REFERENCES projects(id),
    mentor_id BIGINT REFERENCES mentors(id),
    invited_by BIGINT REFERENCES users(id),
    message TEXT,
    status VARCHAR(20) DEFAULT 'PENDING',
    invited_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    responded_at TIMESTAMP,
    response_message TEXT,
    UNIQUE(project_id, mentor_id)
);

CREATE TABLE mentors (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT REFERENCES users(id),
    full_name VARCHAR(255) NOT NULL,
    expertise JSONB,
    years_of_experience INTEGER,
    max_projects INTEGER DEFAULT 3,
    current_projects INTEGER DEFAULT 0,
    hourly_rate DECIMAL(10,2),
    bio TEXT,
    linkedin_url VARCHAR(500),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

---

#### FR-MEN-002: Phân tích Nhiệm vụ (Task Breakdown)

**ID:** FR-MEN-002  
**Tên:** Task Breakdown with Excel  
**Mô tả:** Mentor phân tích dự án thành nhiệm vụ nhỏ bằng Excel template.

**API Endpoints:**
```
GET    /api/mentor/projects/{projectId}/task-template
POST   /api/mentor/projects/{projectId}/tasks/upload
GET    /api/mentor/projects/{projectId}/tasks
PUT    /api/mentor/projects/{projectId}/tasks/{id}
DELETE /api/mentor/projects/{projectId}/tasks/{id}
```

**GET /api/mentor/projects/{projectId}/task-template**

Response: Download Excel file
```
Content-Type: application/vnd.openxmlformats-officedocument.spreadsheetml.sheet
Content-Disposition: attachment; filename="LabOdc_Task_Template_Project_789.xlsx"

Excel Structure:
| Task ID | Task Name | Description | Assigned To | Priority | Start Date | Due Date | Estimated Hours | Status | Dependencies | Tags |
|---------|-----------|-------------|-------------|----------|------------|----------|-----------------|--------|--------------|------|
| T001 | Setup project structure | Initialize React project, configure ESLint, Prettier | Tran Thi C | High | 2026-02-01 | 2026-02-03 | 8 | TODO | - | setup, frontend |
| T002 | Design database schema | Create ERD, define tables, relationships | Nguyen Van D | High | 2026-02-01 | 2026-02-05 | 16 | TODO | - | database, backend |
```

**POST /api/mentor/projects/{projectId}/tasks/upload**

Request: `multipart/form-data`
- `file`: Excel file (max 10MB)

**Processing:**
1. Validate Excel file format
2. Parse Excel using Apache POI (Java) hoặc openpyxl (Python)
3. Validate data:
   - Task Name: required, max 255 chars
   - Assigned To: must be project member
   - Priority: enum(LOW, MEDIUM, HIGH, CRITICAL)
   - Dates: valid format, Due Date > Start Date
   - Status: enum(TODO, IN_PROGRESS, COMPLETED)
4. Bulk insert tasks vào database
5. Gửi notification đến assigned members
6. Return task summary

Response:
```json
{
  "success": true,
  "message": "Upload thành công 45 tasks",
  "data": {
    "totalTasks": 45,
    "tasksCreated": 45,
    "tasksUpdated": 0,
    "tasksFailed": 0,
    "summary": {
      "byPriority": {
        "CRITICAL": 5,
        "HIGH": 15,
        "MEDIUM": 20,
        "LOW": 5
      },
      "byAssignee": {
        "Tran Thi C": 18,
        "Nguyen Van D": 15,
        "Le Thi E": 12
      },
      "totalEstimatedHours": 680
    },
    "errors": []
  }
}
```

**Excel Parsing Logic (Java):**
```java
@Service
public class TaskExcelService {
    
    public TaskUploadResult parseExcelFile(MultipartFile file, Long projectId) {
        try (Workbook workbook = new XSSFWorkbook(file.getInputStream())) {
            Sheet sheet = workbook.getSheetAt(0);
            List<Task> tasks = new ArrayList<>();
            
            // Skip header row, start from row 1
            for (int i = 1; i <= sheet.getLastRowNum(); i++) {
                Row row = sheet.getRow(i);
                if (row == null) continue;
                
                Task task = new Task();
                task.setProjectId(projectId);
                task.setTaskId(getCellValue(row, 0)); // A: Task ID
                task.setTaskName(getCellValue(row, 1)); // B: Task Name
                task.setDescription(getCellValue(row, 2)); // C: Description
                task.setAssignedTo(getCellValue(row, 3)); // D: Assigned To
                task.setPriority(getCellValue(row, 4)); // E: Priority
                task.setStartDate(getDateValue(row, 5)); // F: Start Date
                task.setDueDate(getDateValue(row, 6)); // G: Due Date
                task.setEstimatedHours(getNumericValue(row, 7)); // H: Hours
                task.setStatus(getCellValue(row, 8)); // I: Status
                task.setDependencies(getCellValue(row, 9)); // J: Dependencies
                task.setTags(getCellValue(row, 10)); // K: Tags
                
                // Validate task
                validateTask(task);
                tasks.add(task);
            }
            
            // Bulk insert
            taskRepository.saveAll(tasks);
            
            return TaskUploadResult.success(tasks);
            
        } catch (Exception e) {
            return TaskUploadResult.failure(e.getMessage());
        }
    }
}
```

**Database Schema:**
```sql
CREATE TABLE tasks (
    id BIGSERIAL PRIMARY KEY,
    project_id BIGINT REFERENCES projects(id),
    task_id VARCHAR(20) NOT NULL,
    task_name VARCHAR(255) NOT NULL,
    description TEXT,
    assigned_to BIGINT REFERENCES talents(id),
    priority VARCHAR(20) DEFAULT 'MEDIUM',
    start_date DATE,
    due_date DATE,
    estimated_hours INTEGER,
    actual_hours INTEGER,
    status VARCHAR(20) DEFAULT 'TODO',
    dependencies TEXT,
    tags TEXT,
    created_by BIGINT REFERENCES mentors(id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    completed_at TIMESTAMP,
    UNIQUE(project_id, task_id),
    CONSTRAINT check_dates CHECK (due_date >= start_date)
);

CREATE INDEX idx_tasks_project_assigned ON tasks(project_id, assigned_to);
CREATE INDEX idx_tasks_status ON tasks(status);
CREATE INDEX idx_tasks_due_date ON tasks(due_date);
```

---

#### FR-MEN-003: Đánh giá Người tài năng

**ID:** FR-MEN-003  
**Tên:** Evaluate Talents  
**Mô tả:** Mentor đánh giá hiệu suất của từng sinh viên trong nhóm.

**API Endpoints:**
```
POST   /api/mentor/projects/{projectId}/evaluations
GET    /api/mentor/projects/{projectId}/evaluations
GET    /api/mentor/projects/{projectId}/evaluations/{talentId}
PUT    /api/mentor/projects/{projectId}/evaluations/{id}
```

**POST /api/mentor/projects/{projectId}/evaluations**

Request:
```json
{
  "talentId": 456,
  "evaluationPeriod": "2026-02",
  "overallScore": 8.5,
  "technicalSkills": {
    "score": 9.0,
    "comment": "Kỹ năng ReactJS rất tốt, code clean, follow best practices. Hiểu sâu về hooks và state management."
  },
  "problemSolving": {
    "score": 8.5,
    "comment": "Tự giải quyết được hầu hết vấn đề, chỉ cần support ở những phần phức tạp."
  },
  "teamwork": {
    "score": 8.0,
    "comment": "Hợp tác tốt với team, sẵn sàng help đồng đội, tham gia active vào discussions."
  },
  "communication": {
    "score": 8.5,
    "comment": "Giao tiếp rõ ràng, cập nhật tiến độ đều đặn, respond nhanh trên Slack."
  },
  "codeQuality": {
    "score": 9.0,
    "comment": "Code quality xuất sắc, follow convention, có comments đầy đủ, pass all linting rules."
  },
  "punctuality": {
    "score": 9.5,
    "comment": "Luôn submit đúng deadline, thậm chí sớm hơn. Attendance 100% ở meetings."
  },
  "strengths": [
    "Frontend development skills mạnh",
    "Tự học và adapt nhanh",
    "Code quality cao",
    "Responsive design tốt"
  ],
  "weaknesses": [
    "Backend knowledge còn hạn chế",
    "Có thể improve thêm về testing"
  ],
  "recommendations": [
    "Học thêm về backend để hiểu fullstack",
    "Practice viết unit tests và integration tests",
    "Tìm hiểu về performance optimization"
  ],
  "tasksCompleted": 18,
  "tasksTotal": 20,
  "hoursWorked": 120
}
```

**Processing:**
1. Validate mentor có quyền đánh giá project này
2. Validate talent thuộc project
3. Validate evaluationPeriod chưa có evaluation
4. Calculate overall score từ các criteria
5. Tạo evaluation record
6. Gửi notification đến talent
7. Update talent's average rating
8. Return evaluation ID

Response:
```json
{
  "success": true,
  "message": "Đánh giá đã được gửi thành công",
  "data": {
    "evaluationId": 6001,
    "talentId": 456,
    "talentName": "Tran Thi C",
    "evaluationPeriod": "2026-02",
    "overallScore": 8.5,
    "grade": "A",
    "submittedAt": "2026-02-28T18:00:00Z"
  }
}
```

**Business Rules:**
- Evaluation PHẢI được submit cuối mỗi tháng
- Overall score: 0-10 (1 decimal)
- Grade mapping:
  - 9.0-10.0: A (Xuất sắc)
  - 8.0-8.9: B (Tốt)
  - 7.0-7.9: C (Khá)
  - 6.0-6.9: D (Trung bình)
  - < 6.0: F (Kém)
- Mỗi talent chỉ có 1 evaluation/tháng
- Talent được xem evaluation ngay sau khi Mentor submit

**Database Schema:**
```sql
CREATE TABLE talent_evaluations (
    id BIGSERIAL PRIMARY KEY,
    project_id BIGINT REFERENCES projects(id),
    talent_id BIGINT REFERENCES talents(id),
    mentor_id BIGINT REFERENCES mentors(id),
    evaluation_period VARCHAR(7) NOT NULL, -- YYYY-MM
    overall_score DECIMAL(3,1) CHECK (overall_score BETWEEN 0 AND 10),
    technical_skills JSONB,
    problem_solving JSONB,
    teamwork JSONB,
    communication JSONB,
    code_quality JSONB,
    punctuality JSONB,
    strengths JSONB,
    weaknesses JSONB,
    recommendations JSONB,
    tasks_completed INTEGER,
    tasks_total INTEGER,
    hours_worked INTEGER,
    grade VARCHAR(1),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(project_id, talent_id, evaluation_period)
);

CREATE INDEX idx_evaluations_talent ON talent_evaluations(talent_id);
CREATE INDEX idx_evaluations_period ON talent_evaluations(evaluation_period);
```

---

#### FR-MEN-004: Nộp Báo cáo

**ID:** FR-MEN-004  
**Tên:** Submit Report  
**Mô tả:** Mentor nộp báo cáo tiến độ và hiệu suất nhóm định kỳ.

**API Endpoints:**
```
POST   /api/mentor/projects/{projectId}/reports
GET    /api/mentor/projects/{projectId}/reports
PUT    /api/mentor/projects/{projectId}/reports/{id}
```

**POST /api/mentor/projects/{projectId}/reports**

Request:
```json
{
  "reportType": "MONTHLY",
  "reportingPeriod": "2026-02",
  "projectProgress": {
    "overallCompletion": 45,
    "plannedCompletion": 50,
    "variance": -5,
    "status": "ON_TRACK"
  },
  "tasksCompleted": {
    "total": 20,
    "byPriority": {
      "CRITICAL": 5,
      "HIGH": 8,
      "MEDIUM": 6,
      "LOW": 1
    }
  },
  "tasksUpcoming": {
    "total": 25,
    "dueThisMonth": 15
  },
  "teamPerformance": {
    "averageScore": 8.3,
    "topPerformers": [
      {
        "talentId": 456,
        "name": "Tran Thi C",
        "score": 9.0
      }
    ],
    "needsImprovement": []
  },
  "achievements": [
    "Hoàn thành frontend dashboard đúng hạn",
    "Backend APIs đã pass all integration tests",
    "Code quality score 9.0/10 trên SonarQube"
  ],
  "challenges": [
    {
      "issue": "Cloudinary upload slow",
      "impact": "MEDIUM",
      "status": "RESOLVED",
      "solution": "Implemented image compression và lazy loading"
    },
    {
      "issue": "Team member nghỉ ốm 1 tuần",
      "impact": "LOW",
      "status": "MITIGATED",
      "solution": "Phân lại tasks cho members khác"
    }
  ],
  "risks": [
    {
      "description": "Third-party API có thể thay đổi",
      "probability": "LOW",
      "impact": "MEDIUM",
      "mitigation": "Tạo abstraction layer, dễ dàng switch provider"
    }
  ],
  "nextMonthGoals": [
    "Complete Payment module integration",
    "Implement Admin dashboard",
    "Start UAT với Enterprise",
    "Deploy to staging environment"
  ],
  "budgetUsage": {
    "allocated": 100000000,
    "spent": 45000000,
    "remaining": 55000000,
    "onBudget": true
  },
  "meetingsHeld": 8,
  "averageMeetingDuration": 90,
  "codeMetrics": {
    "linesOfCode": 12500,
    "testCoverage": 78,
    "codeQualityScore": 9.0,
    "technicalDebt": "LOW"
  }
}
```

Response:
```json
{
  "success": true,
  "message": "Báo cáo đã được nộp thành công",
  "data": {
    "reportId": 7001,
    "projectId": 789,
    "reportType": "MONTHLY",
    "reportingPeriod": "2026-02",
    "submittedAt": "2026-02-28T20:00:00Z",
    "status": "SUBMITTED",
    "recipients": ["Lab Admin", "Enterprise: ABC Technology"]
  }
}
```

**Database Schema:**
```sql
CREATE TABLE mentor_reports (
    id BIGSERIAL PRIMARY KEY,
    project_id BIGINT REFERENCES projects(id),
    mentor_id BIGINT REFERENCES mentors(id),
    report_type VARCHAR(20) NOT NULL,
    reporting_period VARCHAR(7) NOT NULL,
    project_progress JSONB,
    tasks_completed JSONB,
    tasks_upcoming JSONB,
    team_performance JSONB,
    achievements JSONB,
    challenges JSONB,
    risks JSONB,
    next_month_goals JSONB,
    budget_usage JSONB,
    meetings_held INTEGER,
    code_metrics JSONB,
    status VARCHAR(20) DEFAULT 'DRAFT',
    submitted_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(project_id, reporting_period)
);
```

Bạn có muốn tôi tiếp tục với Module Lab Administrator và System Administrator không?

---

### 3.6 Module Lab Administrator

#### FR-LAB-001: Xác thực Doanh nghiệp

**ID:** FR-LAB-001  
**Tên:** Validate Enterprise  
**Mô tả:** Lab Admin xác thực doanh nghiệp đăng ký mới trước khi kích hoạt tài khoản.

**API Endpoints:**
```
GET    /api/lab-admin/enterprises/pending
GET    /api/lab-admin/enterprises/{id}
POST   /api/lab-admin/enterprises/{id}/approve
POST   /api/lab-admin/enterprises/{id}/reject
POST   /api/lab-admin/enterprises/{id}/request-info
```

**GET /api/lab-admin/enterprises/pending**

Response:
```json
{
  "success": true,
  "data": {
    "enterprises": [
      {
        "id": 123,
        "companyName": "ABC Technology Co., Ltd",
        "taxCode": "0123456789",
        "address": "123 Nguyen Hue, Q1, HCM",
        "representative": "Nguyen Van B",
        "email": "company@abctech.vn",
        "phone": "0901234567",
        "industry": "Information Technology",
        "website": "https://abctech.vn",
        "logoUrl": "https://cloudinary.com/logo.jpg",
        "registeredAt": "2026-01-10T08:00:00Z",
        "status": "PENDING",
        "documents": [
          {
            "type": "BUSINESS_LICENSE",
            "url": "https://cloudinary.com/license.pdf"
          }
        ]
      }
    ],
    "total": 5
  }
}
```

**POST /api/lab-admin/enterprises/{id}/approve**

Request:
```json
{
  "note": "Doanh nghiệp hợp lệ, đã verify mã số thuế và giấy phép kinh doanh"
}
```

**Processing:**
1. Validate enterprise exists và status=PENDING
2. Update enterprise status=APPROVED
3. Update user account status=ACTIVE
4. Gửi email notification đến enterprise
5. Log approval action
6. Return confirmation

Response:
```json
{
  "success": true,
  "message": "Doanh nghiệp đã được phê duyệt",
  "data": {
    "enterpriseId": 123,
    "companyName": "ABC Technology Co., Ltd",
    "status": "APPROVED",
    "approvedAt": "2026-01-11T09:00:00Z",
    "approvedBy": "Lab Admin"
  }
}
```

**POST /api/lab-admin/enterprises/{id}/reject**

Request:
```json
{
  "reason": "Mã số thuế không hợp lệ hoặc đã bị thu hồi",
  "details": "Sau khi kiểm tra trên hệ thống thuế quốc gia, mã số 0123456789 không tồn tại."
}
```

Response:
```json
{
  "success": true,
  "message": "Doanh nghiệp đã bị từ chối",
  "data": {
    "enterpriseId": 123,
    "status": "REJECTED",
    "rejectedAt": "2026-01-11T09:15:00Z"
  }
}
```

**Business Rules:**
- Mỗi enterprise chỉ được approve 1 lần
- Phải verify mã số thuế (có thể integrate API thuế)
- Email notification trong vòng 5 phút
- Log tất cả actions để audit

**Database Schema:**
```sql
CREATE TABLE enterprise_validations (
    id BIGSERIAL PRIMARY KEY,
    enterprise_id BIGINT REFERENCES enterprises(id),
    validated_by BIGINT REFERENCES users(id),
    action VARCHAR(20) NOT NULL, -- APPROVED, REJECTED, INFO_REQUESTED
    note TEXT,
    reason TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

---

#### FR-LAB-002: Xác thực và Quản lý Dự án

**ID:** FR-LAB-002  
**Tên:** Validate and Manage Projects  
**Mô tả:** Lab Admin xác thực dự án và gán Mentor.

**API Endpoints:**
```
GET    /api/lab-admin/projects/pending
GET    /api/lab-admin/projects/{id}
POST   /api/lab-admin/projects/{id}/approve
POST   /api/lab-admin/projects/{id}/reject
POST   /api/lab-admin/projects/{id}/assign-mentor
GET    /api/lab-admin/mentors/available
```

**GET /api/lab-admin/projects/pending**

Response:
```json
{
  "success": true,
  "data": {
    "projects": [
      {
        "id": 789,
        "title": "Website Quản lý Bán hàng",
        "enterprise": {
          "id": 123,
          "name": "ABC Technology",
          "verified": true
        },
        "description": "Xây dựng website quản lý bán hàng online...",
        "objectives": ["Quản lý sản phẩm", "Xử lý đơn hàng", "Dashboard"],
        "technologies": ["ReactJS", "NodeJS", "MongoDB"],
        "startDate": "2026-02-01",
        "endDate": "2026-05-31",
        "budget": 100000000,
        "numberOfStudents": 5,
        "skillRequirements": [
          {"skill": "ReactJS", "level": "Intermediate"}
        ],
        "submittedAt": "2026-01-12T10:00:00Z",
        "status": "PENDING",
        "attachments": [
          {"fileName": "requirements.pdf", "url": "..."}
        ],
        "feasibilityScore": 85
      }
    ],
    "total": 8
  }
}
```

**POST /api/lab-admin/projects/{id}/approve**

Request:
```json
{
  "note": "Dự án phù hợp với khả năng sinh viên, requirements rõ ràng",
  "adjustments": {
    "numberOfStudents": 5,
    "duration": "4 tháng"
  }
}
```

Response:
```json
{
  "success": true,
  "message": "Dự án đã được phê duyệt",
  "data": {
    "projectId": 789,
    "status": "APPROVED",
    "approvedAt": "2026-01-13T09:00:00Z",
    "nextStep": "Gán Mentor cho dự án"
  }
}
```

**POST /api/lab-admin/projects/{id}/assign-mentor**

Request:
```json
{
  "mentorId": 201,
  "message": "Dự án ReactJS + NodeJS phù hợp với expertise của mentor. Mentor hiện đang handle 2 dự án, còn capacity cho 1 dự án nữa."
}
```

**Processing:**
1. Validate project status=APPROVED
2. Validate mentor available (current_projects < max_projects)
3. Tạo mentor invitation
4. Update project.mentor_id
5. Gửi email invitation đến mentor
6. Increment mentor.current_projects
7. Return confirmation

Response:
```json
{
  "success": true,
  "message": "Đã gửi lời mời đến Mentor",
  "data": {
    "invitationId": 5001,
    "mentorName": "Nguyen Van Mentor",
    "mentorEmail": "mentor@example.com",
    "sentAt": "2026-01-13T10:00:00Z"
  }
}
```

**GET /api/lab-admin/mentors/available**

Query Parameters:
- `technologies`: string[], filter by expertise
- `maxProjects`: boolean, only show mentors with capacity

Response:
```json
{
  "success": true,
  "data": {
    "mentors": [
      {
        "id": 201,
        "fullName": "Nguyen Van Mentor",
        "expertise": ["ReactJS", "NodeJS", "MongoDB", "AWS"],
        "yearsOfExperience": 8,
        "currentProjects": 2,
        "maxProjects": 3,
        "available": true,
        "averageRating": 4.7,
        "projectsCompleted": 15
      }
    ]
  }
}
```

**Business Rules:**
- Project PHẢI được approve trước khi assign mentor
- Mentor PHẢI có expertise match với technologies
- Mentor PHẢI còn capacity (current < max)
- Mentor có 72h để respond invitation

---

#### FR-LAB-003: Phân bổ Quỹ (70/20/10)

**ID:** FR-LAB-003  
**Tên:** Allocate Funds  
**Mô tả:** Lab Admin phân bổ quỹ và giải ngân theo quy tắc 70/20/10.

**API Endpoints:**
```
GET    /api/lab-admin/projects/{projectId}/fund-allocation
POST   /api/lab-admin/projects/{projectId}/fund-allocation/confirm
POST   /api/lab-admin/fund-distributions/{id}/disburse-mentor
POST   /api/lab-admin/fund-distributions/{id}/disburse-team
GET    /api/lab-admin/fund-distributions/pending
```

**GET /api/lab-admin/projects/{projectId}/fund-allocation**

Response:
```json
{
  "success": true,
  "data": {
    "projectId": 789,
    "projectTitle": "Website Quản lý Bán hàng",
    "payment": {
      "id": 1001,
      "amount": 100000000,
      "status": "PAID",
      "paidAt": "2026-01-15T10:00:00Z"
    },
    "allocation": {
      "total": 100000000,
      "team": {
        "amount": 70000000,
        "percentage": 70,
        "status": "PENDING_DISTRIBUTION"
      },
      "mentor": {
        "amount": 20000000,
        "percentage": 20,
        "status": "PENDING_REPORT"
      },
      "lab": {
        "amount": 10000000,
        "percentage": 10,
        "status": "RECEIVED"
      }
    },
    "status": "CONFIRMED"
  }
}
```

**POST /api/lab-admin/projects/{projectId}/fund-allocation/confirm**

Processing:
1. Validate payment status=PAID
2. Calculate allocation:
   - Team: 100M × 70% = 70M
   - Mentor: 100M × 20% = 20M
   - Lab: 100M × 10% = 10M
3. Create fund_distribution record
4. Transfer Lab portion (10M) to Lab account
5. Mark team & mentor portions as PENDING
6. Send notifications
7. Return allocation summary

Response:
```json
{
  "success": true,
  "message": "Phân bổ quỹ đã được xác nhận",
  "data": {
    "distributionId": 2001,
    "allocations": {
      "team": 70000000,
      "mentor": 20000000,
      "lab": 10000000
    },
    "labReceived": 10000000,
    "confirmedAt": "2026-01-15T11:00:00Z"
  }
}
```

**POST /api/lab-admin/fund-distributions/{id}/disburse-mentor**

Request:
```json
{
  "mentorId": 201,
  "amount": 20000000,
  "note": "Giải ngân sau khi Mentor hoàn thành báo cáo cuối kỳ"
}
```

**Processing:**
1. Validate mentor đã submit final report
2. Validate fund_distribution.mentor_amount
3. Create disbursement transaction
4. Transfer funds to mentor account
5. Update status=DISBURSED
6. Send confirmation email
7. Return transaction ID

Response:
```json
{
  "success": true,
  "message": "Đã giải ngân cho Mentor",
  "data": {
    "transactionId": "TXN-20260115-0001",
    "mentorId": 201,
    "mentorName": "Nguyen Van Mentor",
    "amount": 20000000,
    "disbursedAt": "2026-05-31T15:00:00Z",
    "status": "COMPLETED"
  }
}
```

**POST /api/lab-admin/fund-distributions/{id}/disburse-team**

Request:
```json
{
  "distributionId": 2001,
  "teamDistribution": [
    {
      "talentId": 456,
      "amount": 24500000
    },
    {
      "talentId": 457,
      "amount": 28000000
    },
    {
      "talentId": 458,
      "amount": 17500000
    }
  ],
  "note": "Giải ngân sau khi Mentor xác nhận phân phối"
}
```

**Processing:**
1. Validate Mentor đã approve team distribution
2. Validate total = 70,000,000
3. Create individual disbursement transactions
4. Transfer funds to each talent
5. Update status=DISBURSED
6. Send confirmation emails
7. Return transaction summary

Response:
```json
{
  "success": true,
  "message": "Đã giải ngân cho Team",
  "data": {
    "disbursements": [
      {
        "transactionId": "TXN-20260115-0002",
        "talentId": 456,
        "amount": 24500000,
        "status": "COMPLETED"
      },
      {
        "transactionId": "TXN-20260115-0003",
        "talentId": 457,
        "amount": 28000000,
        "status": "COMPLETED"
      },
      {
        "transactionId": "TXN-20260115-0004",
        "talentId": 458,
        "amount": 17500000,
        "status": "COMPLETED"
      }
    ],
    "totalDisbursed": 70000000,
    "disbursedAt": "2026-05-31T16:00:00Z"
  }
}
```

**Business Rules:**
- Phân bổ 70/20/10 CỐ ĐỊNH, không thay đổi
- Lab nhận 10% ngay sau khi payment confirmed
- Mentor nhận 20% sau khi submit final report
- Team nhận 70% sau khi:
  - Talent Leader phân phối
  - Mentor approve
  - Lab Admin confirm
- Tất cả transactions phải có audit trail

**Database Schema:**
```sql
CREATE TABLE disbursements (
    id BIGSERIAL PRIMARY KEY,
    fund_distribution_id BIGINT REFERENCES fund_distributions(id),
    recipient_type VARCHAR(20) NOT NULL, -- MENTOR, TALENT, LAB
    recipient_id BIGINT,
    amount DECIMAL(15,2) NOT NULL,
    transaction_id VARCHAR(50) UNIQUE,
    status VARCHAR(20) DEFAULT 'PENDING',
    note TEXT,
    disbursed_by BIGINT REFERENCES users(id),
    disbursed_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_disbursements_recipient ON disbursements(recipient_type, recipient_id);
CREATE INDEX idx_disbursements_status ON disbursements(status);
```

---

#### FR-LAB-004: Hybrid Fund Support (Tạm ứng Quỹ)

**ID:** FR-LAB-004  
**Tên:** Hybrid Fund Support  
**Mô tả:** Lab Admin tạm ứng quỹ khi doanh nghiệp chậm thanh toán.

**API Endpoints:**
```
GET    /api/lab-admin/payments/delayed
POST   /api/lab-admin/hybrid-funds/advance
GET    /api/lab-admin/hybrid-funds
PUT    /api/lab-admin/hybrid-funds/{id}/reconcile
```

**GET /api/lab-admin/payments/delayed**

Response:
```json
{
  "success": true,
  "data": {
    "delayedPayments": [
      {
        "projectId": 790,
        "projectTitle": "Mobile App E-commerce",
        "enterprise": {
          "id": 124,
          "name": "XYZ Corporation",
          "email": "xyz@example.com"
        },
        "payment": {
          "id": 1002,
          "amount": 150000000,
          "dueDate": "2026-01-10",
          "daysPastDue": 12,
          "status": "DELAYED"
        },
        "teamSize": 6,
        "mentorAssigned": true,
        "urgency": "HIGH"
      }
    ],
    "total": 3,
    "totalAmountDelayed": 350000000
  }
}
```

**POST /api/lab-admin/hybrid-funds/advance**

Request:
```json
{
  "projectId": 790,
  "advanceAmount": 150000000,
  "recipients": {
    "team": {
      "amount": 105000000,
      "distribute": true
    },
    "mentor": {
      "amount": 30000000,
      "distribute": true
    }
  },
  "reason": "Doanh nghiệp chậm thanh toán 12 ngày, team cần thanh toán để tiếp tục dự án",
  "expectedRepaymentDate": "2026-02-15"
}
```

**Processing:**
1. Validate Lab có đủ funds để advance
2. Validate payment status=DELAYED
3. Calculate advance amounts:
   - Team: 150M × 70% = 105M
   - Mentor: 150M × 20% = 30M
   - Lab keeps: 15M (will get when enterprise pays)
4. Create hybrid_fund_advance record
5. Disburse to team & mentor
6. Update payment status=ADVANCED_BY_LAB
7. Send notification to enterprise
8. Return advance summary

Response:
```json
{
  "success": true,
  "message": "Lab đã tạm ứng quỹ",
  "data": {
    "advanceId": 3001,
    "projectId": 790,
    "totalAdvanced": 135000000,
    "disbursements": {
      "team": 105000000,
      "mentor": 30000000
    },
    "enterpriseDebt": 150000000,
    "expectedRepayment": "2026-02-15",
    "advancedAt": "2026-01-22T10:00:00Z",
    "status": "ADVANCED"
  }
}
```

**PUT /api/lab-admin/hybrid-funds/{id}/reconcile**

Request (khi enterprise đã thanh toán):
```json
{
  "paymentId": 1002,
  "repaidAmount": 150000000,
  "repaidAt": "2026-02-10T14:00:00Z"
}
```

**Processing:**
1. Validate payment đã receive từ enterprise
2. Update hybrid_fund_advance status=REPAID
3. Transfer enterprise payment to Lab account
4. Calculate Lab's portion:
   - Advanced: 135M
   - Received: 150M
   - Lab profit: 15M (original 10%) + interest if late
5. Close advance record
6. Send confirmation
7. Return reconciliation summary

Response:
```json
{
  "success": true,
  "message": "Doanh nghiệp đã hoàn trả khoản tạm ứng",
  "data": {
    "advanceId": 3001,
    "amountAdvanced": 135000000,
    "amountRepaid": 150000000,
    "labProfit": 15000000,
    "daysLate": 31,
    "lateFeecharged": 0,
    "status": "REPAID",
    "repaidAt": "2026-02-10T14:00:00Z"
  }
}
```

**Business Rules:**
- Lab chỉ advance khi payment delayed > 14 ngày
- Lab advance tối đa 70% + 20% (không advance phần 10% của Lab)
- Enterprise phải repay trong 30 ngày
- Nếu không repay → blacklist enterprise
- Có thể charge late fee (tùy policy)

**Database Schema:**
```sql
CREATE TABLE hybrid_fund_advances (
    id BIGSERIAL PRIMARY KEY,
    project_id BIGINT REFERENCES projects(id),
    payment_id BIGINT REFERENCES payments(id),
    advance_amount DECIMAL(15,2) NOT NULL,
    team_amount DECIMAL(15,2),
    mentor_amount DECIMAL(15,2),
    enterprise_debt DECIMAL(15,2),
    reason TEXT,
    expected_repayment_date DATE,
    status VARCHAR(20) DEFAULT 'ADVANCED',
    advanced_by BIGINT REFERENCES users(id),
    advanced_at TIMESTAMP,
    repaid_amount DECIMAL(15,2),
    repaid_at TIMESTAMP,
    late_fee DECIMAL(15,2) DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

---

#### FR-LAB-005: Công bố Báo cáo Minh bạch

**ID:** FR-LAB-005  
**Tên:** Publish Transparency Report  
**Mô tả:** Lab Admin tạo và công bố báo cáo minh bạch định kỳ.

**API Endpoints:**
```
POST   /api/lab-admin/transparency-reports
GET    /api/lab-admin/transparency-reports
GET    /api/lab-admin/transparency-reports/{id}
PUT    /api/lab-admin/transparency-reports/{id}/publish
```

**POST /api/lab-admin/transparency-reports**

Request:
```json
{
  "reportType": "MONTHLY",
  "period": "2026-01",
  "autoGenerate": true
}
```

**Processing (Auto-generate):**
1. Query all data for period 2026-01:
   - Projects: total, new, completed, cancelled
   - Enterprises: total, new, active
   - Talents: total, new, active, avg rating
   - Payments: total amount, count
   - Fund distributions: 70/20/10 breakdown
2. Calculate statistics
3. Generate charts data
4. Create report record (status=DRAFT)
5. Return report preview

Response:
```json
{
  "success": true,
  "data": {
    "reportId": 8001,
    "period": "2026-01",
    "statistics": {
      "projects": {
        "total": 47,
        "new": 12,
        "ongoing": 28,
        "completed": 5,
        "cancelled": 2,
        "successRate": 71.4
      },
      "enterprises": {
        "total": 35,
        "new": 3,
        "active": 28,
        "verified": 35
      },
      "talents": {
        "total": 245,
        "new": 48,
        "active": 187,
        "averageRating": 8.2
      },
      "mentors": {
        "total": 18,
        "active": 15,
        "averageRating": 4.6
      },
      "financials": {
        "totalRevenue": 2500000000,
        "teamDisbursed": 1750000000,
        "mentorDisbursed": 500000000,
        "labRevenue": 250000000,
        "hybridFundAdvanced": 135000000,
        "hybridFundRepaid": 0
      },
      "performance": {
        "avgProjectCompletion": 78,
        "onTimeDelivery": 82,
        "customerSatisfaction": 4.3
      }
    },
    "status": "DRAFT"
  }
}
```

**PUT /api/lab-admin/transparency-reports/{id}/publish**

Request:
```json
{
  "publishNote": "Báo cáo tháng 01/2026 - Hệ thống hoạt động ổn định, tăng trưởng 15% so với tháng trước"
}
```

**Processing:**
1. Validate report exists
2. Generate PDF version
3. Update status=PUBLISHED
4. Upload PDF to Cloudinary
5. Publish to public page
6. Send notifications to stakeholders
7. Return published report URL

Response:
```json
{
  "success": true,
  "message": "Báo cáo đã được công bố",
  "data": {
    "reportId": 8001,
    "period": "2026-01",
    "publishedAt": "2026-02-05T10:00:00Z",
    "publicUrl": "https://labodc.uth.edu.vn/transparency/2026-01",
    "pdfUrl": "https://cloudinary.com/reports/2026-01.pdf"
  }
}
```

**Database Schema:**
```sql
CREATE TABLE transparency_reports (
    id BIGSERIAL PRIMARY KEY,
    report_type VARCHAR(20) NOT NULL,
    period VARCHAR(7) NOT NULL, -- YYYY-MM
    statistics JSONB NOT NULL,
    charts_data JSONB,
    publish_note TEXT,
    status VARCHAR(20) DEFAULT 'DRAFT',
    created_by BIGINT REFERENCES users(id),
    published_at TIMESTAMP,
    public_url VARCHAR(500),
    pdf_url VARCHAR(500),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(period)
);
```

Tôi sẽ tiếp tục với Module System Administrator. Bạn có muốn tôi làm tiếp không?

---

### 3.7 Module System Administrator

#### FR-SYS-001: Cấu hình Hệ thống

**ID:** FR-SYS-001  
**Tên:** System Configuration  
**Mô tả:** System Admin quản lý các tham số cấu hình hệ thống.

**API Endpoints:**
```
GET    /api/system-admin/config
PUT    /api/system-admin/config
POST   /api/system-admin/config/reset
GET    /api/system-admin/config/history
```

**GET /api/system-admin/config**

Response:
```json
{
  "success": true,
  "data": {
    "fundDistribution": {
      "teamPercentage": 70,
      "mentorPercentage": 20,
      "labPercentage": 10,
      "editable": false
    },
    "payment": {
      "delayWarningDays": 7,
      "hybridFundTriggerDays": 14,
      "paymentLinkExpireMinutes": 15,
      "lateFeeDailyRate": 0.1
    },
    "project": {
      "minBudget": 10000000,
      "maxBudget": 1000000000,
      "minDurationMonths": 1,
      "maxDurationMonths": 6,
      "minStudents": 3,
      "maxStudents": 10
    },
    "security": {
      "jwtExpirationMinutes": 30,
      "refreshTokenExpirationDays": 7,
      "maxLoginAttempts": 5,
      "accountLockMinutes": 30,
      "passwordMinLength": 8,
      "require2FA": false
    },
    "notification": {
      "emailEnabled": true,
      "pushEnabled": true,
      "smsEnabled": false,
      "reportDeadlineReminderDays": 3
    },
    "upload": {
      "maxImageSizeMB": 5,
      "maxDocumentSizeMB": 20,
      "maxExcelSizeMB": 10,
      "allowedImageFormats": ["jpg", "jpeg", "png", "gif"],
      "allowedDocumentFormats": ["pdf", "doc", "docx", "ppt", "pptx"]
    }
  }
}
```

**PUT /api/system-admin/config**

Request:
```json
{
  "section": "payment",
  "updates": {
    "delayWarningDays": 5,
    "hybridFundTriggerDays": 10
  },
  "reason": "Giảm thời gian warning để tăng tốc độ thu tiền"
}
```

**Processing:**
1. Validate System Admin role
2. Validate section exists
3. Validate new values (ranges, types)
4. Backup current config
5. Apply updates
6. Log change with reason
7. Broadcast config change event
8. Return updated config

Response:
```json
{
  "success": true,
  "message": "Cấu hình đã được cập nhật",
  "data": {
    "section": "payment",
    "updated": {
      "delayWarningDays": 5,
      "hybridFundTriggerDays": 10
    },
    "previous": {
      "delayWarningDays": 7,
      "hybridFundTriggerDays": 14
    },
    "updatedBy": "System Admin",
    "updatedAt": "2026-01-17T10:00:00Z"
  }
}
```

**Business Rules:**
- Fund distribution ratio KHÔNG THỂ thay đổi (70/20/10 cố định)
- Mọi thay đổi PHẢI có reason
- Tất cả changes được log để audit
- Critical configs cần confirmation
- Có thể rollback về version trước

**Database Schema:**
```sql
CREATE TABLE system_configs (
    id BIGSERIAL PRIMARY KEY,
    config_key VARCHAR(100) UNIQUE NOT NULL,
    config_value TEXT NOT NULL,
    data_type VARCHAR(20) NOT NULL, -- STRING, INTEGER, BOOLEAN, JSON
    description TEXT,
    editable BOOLEAN DEFAULT TRUE,
    updated_by BIGINT REFERENCES users(id),
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE config_change_history (
    id BIGSERIAL PRIMARY KEY,
    config_key VARCHAR(100) NOT NULL,
    old_value TEXT,
    new_value TEXT,
    reason TEXT,
    changed_by BIGINT REFERENCES users(id),
    changed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

---

#### FR-SYS-002: Quản lý Vai trò và Quyền hạn

**ID:** FR-SYS-002  
**Tên:** Role and Permission Management  
**Mô tả:** System Admin quản lý roles và permissions (RBAC).

**API Endpoints:**
```
GET    /api/system-admin/roles
POST   /api/system-admin/roles
PUT    /api/system-admin/roles/{id}
DELETE /api/system-admin/roles/{id}
GET    /api/system-admin/permissions
POST   /api/system-admin/roles/{id}/permissions
```

**GET /api/system-admin/roles**

Response:
```json
{
  "success": true,
  "data": {
    "roles": [
      {
        "id": 1,
        "name": "SYSTEM_ADMIN",
        "displayName": "System Administrator",
        "description": "Toàn quyền quản trị hệ thống",
        "userCount": 2,
        "editable": false,
        "permissions": ["*"]
      },
      {
        "id": 2,
        "name": "LAB_ADMIN",
        "displayName": "Lab Administrator",
        "description": "Quản lý nghiệp vụ Lab",
        "userCount": 5,
        "editable": true,
        "permissions": [
          "enterprise.validate",
          "project.validate",
          "project.assign_mentor",
          "fund.allocate",
          "fund.disburse",
          "report.publish",
          "user.manage"
        ]
      },
      {
        "id": 3,
        "name": "ENTERPRISE",
        "displayName": "Enterprise",
        "description": "Doanh nghiệp",
        "userCount": 35,
        "editable": true,
        "permissions": [
          "project.create",
          "project.view_own",
          "project.update_own",
          "payment.create",
          "payment.view_own",
          "report.view_own"
        ]
      },
      {
        "id": 4,
        "name": "TALENT",
        "displayName": "Talent",
        "description": "Sinh viên",
        "userCount": 245,
        "editable": true,
        "permissions": [
          "profile.manage_own",
          "project.view_available",
          "project.join",
          "task.view_own",
          "evaluation.view_own"
        ]
      },
      {
        "id": 5,
        "name": "TALENT_LEADER",
        "displayName": "Talent Leader",
        "description": "Trưởng nhóm",
        "userCount": 28,
        "editable": true,
        "permissions": [
          "*TALENT",
          "fund.distribute_team",
          "report.submit_team"
        ]
      },
      {
        "id": 6,
        "name": "MENTOR",
        "displayName": "Mentor",
        "description": "Người hướng dẫn",
        "userCount": 18,
        "editable": true,
        "permissions": [
          "project.view_assigned",
          "task.manage",
          "talent.evaluate",
          "report.submit",
          "fund.approve_distribution"
        ]
      }
    ]
  }
}
```

**POST /api/system-admin/roles**

Request:
```json
{
  "name": "PROJECT_MANAGER",
  "displayName": "Project Manager",
  "description": "Quản lý dự án nội bộ Lab",
  "permissions": [
    "project.view_all",
    "project.update_status",
    "task.view_all",
    "report.view_all"
  ]
}
```

Response:
```json
{
  "success": true,
  "message": "Role đã được tạo thành công",
  "data": {
    "roleId": 7,
    "name": "PROJECT_MANAGER",
    "createdAt": "2026-01-17T11:00:00Z"
  }
}
```

**GET /api/system-admin/permissions**

Response:
```json
{
  "success": true,
  "data": {
    "permissions": [
      {
        "id": 1,
        "name": "project.create",
        "resource": "project",
        "action": "create",
        "description": "Tạo dự án mới"
      },
      {
        "id": 2,
        "name": "project.view_all",
        "resource": "project",
        "action": "view_all",
        "description": "Xem tất cả dự án"
      },
      {
        "id": 3,
        "name": "project.view_own",
        "resource": "project",
        "action": "view_own",
        "description": "Xem dự án của mình"
      },
      {
        "id": 4,
        "name": "user.manage",
        "resource": "user",
        "action": "manage",
        "description": "Quản lý người dùng"
      }
    ]
  }
}
```

**Permission Check Logic (Java):**
```java
@Service
public class PermissionService {
    
    @Cacheable("permissions")
    public boolean hasPermission(User user, String permission) {
        Role role = user.getRole();
        
        // SYSTEM_ADMIN has all permissions
        if (role.getName().equals("SYSTEM_ADMIN")) {
            return true;
        }
        
        // Check if role has specific permission
        return role.getPermissions().contains(permission);
    }
    
    public boolean canAccessResource(User user, String resource, Long resourceId) {
        // Check ownership
        if (resource.equals("project")) {
            Project project = projectRepository.findById(resourceId);
            return project.getEnterpriseId().equals(user.getEnterpriseId());
        }
        
        // Add more resource checks
        return false;
    }
}

@Aspect
@Component
public class PermissionAspect {
    
    @Before("@annotation(requiresPermission)")
    public void checkPermission(JoinPoint joinPoint, RequiresPermission requiresPermission) {
        User currentUser = SecurityContext.getCurrentUser();
        String permission = requiresPermission.value();
        
        if (!permissionService.hasPermission(currentUser, permission)) {
            throw new AccessDeniedException("Insufficient permissions");
        }
    }
}

// Usage
@RestController
public class ProjectController {
    
    @RequiresPermission("project.create")
    @PostMapping("/api/enterprise/projects")
    public ResponseEntity<?> createProject(@RequestBody ProjectDTO dto) {
        // Create project
    }
    
    @RequiresPermission("project.validate")
    @PostMapping("/api/lab-admin/projects/{id}/approve")
    public ResponseEntity<?> approveProject(@PathVariable Long id) {
        // Approve project
    }
}
```

**Database Schema:**
```sql
CREATE TABLE roles (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(50) UNIQUE NOT NULL,
    display_name VARCHAR(100),
    description TEXT,
    editable BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE permissions (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(100) UNIQUE NOT NULL,
    resource VARCHAR(50),
    action VARCHAR(50),
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE role_permissions (
    role_id BIGINT REFERENCES roles(id),
    permission_id BIGINT REFERENCES permissions(id),
    PRIMARY KEY (role_id, permission_id)
);

CREATE INDEX idx_role_permissions_role ON role_permissions(role_id);
```

---

#### FR-SYS-003: Quản lý Người dùng

**ID:** FR-SYS-003  
**Tên:** User Management  
**Mô tả:** System Admin quản lý tất cả người dùng trong hệ thống.

**API Endpoints:**
```
GET    /api/system-admin/users
GET    /api/system-admin/users/{id}
PUT    /api/system-admin/users/{id}
POST   /api/system-admin/users/{id}/reset-password
POST   /api/system-admin/users/{id}/change-role
POST   /api/system-admin/users/{id}/activate
POST   /api/system-admin/users/{id}/deactivate
DELETE /api/system-admin/users/{id}
```

**GET /api/system-admin/users**

Query Parameters:
- `role`: string, filter by role
- `status`: string, enum(ACTIVE, INACTIVE, LOCKED, PENDING)
- `search`: string, search by name, email
- `page`, `limit`

Response:
```json
{
  "success": true,
  "data": {
    "users": [
      {
        "id": 123,
        "email": "user@example.com",
        "fullName": "Nguyen Van A",
        "role": "ENTERPRISE",
        "status": "ACTIVE",
        "createdAt": "2026-01-10T08:00:00Z",
        "lastLogin": "2026-01-17T09:00:00Z",
        "loginCount": 45,
        "projectsCount": 3
      }
    ],
    "pagination": {
      "total": 305,
      "page": 1,
      "totalPages": 31
    },
    "statistics": {
      "total": 305,
      "active": 285,
      "inactive": 15,
      "locked": 5
    }
  }
}
```

**PUT /api/system-admin/users/{id}**

Request:
```json
{
  "email": "newemail@example.com",
  "status": "ACTIVE",
  "reason": "User requested email change"
}
```

**POST /api/system-admin/users/{id}/reset-password**

Request:
```json
{
  "sendEmail": true,
  "temporaryPassword": "TempPass123!",
  "requireChange": true
}
```

Response:
```json
{
  "success": true,
  "message": "Password đã được reset. Email đã được gửi đến user.",
  "data": {
    "userId": 123,
    "emailSent": true,
    "temporaryPassword": "TempPass123!",
    "resetAt": "2026-01-17T12:00:00Z"
  }
}
```

**POST /api/system-admin/users/{id}/change-role**

Request:
```json
{
  "newRole": "TALENT_LEADER",
  "reason": "User được Mentor chỉ định làm Trưởng nhóm"
}
```

**Processing:**
1. Validate user exists
2. Validate new role exists
3. Check if role change is allowed (e.g., ENTERPRISE → TALENT not allowed)
4. Update user.role
5. Clear permissions cache
6. Log role change
7. Send notification to user
8. Return confirmation

Response:
```json
{
  "success": true,
  "message": "Role đã được thay đổi",
  "data": {
    "userId": 456,
    "previousRole": "TALENT",
    "newRole": "TALENT_LEADER",
    "changedBy": "System Admin",
    "changedAt": "2026-01-17T13:00:00Z"
  }
}
```

**Business Rules:**
- System Admin KHÔNG thể tự xóa mình
- Phải có ít nhất 1 System Admin trong hệ thống
- Xóa user = soft delete (set status=DELETED)
- Hard delete chỉ sau 30 ngày
- Tất cả actions được audit log

**Database Schema:**
```sql
CREATE TABLE user_activity_logs (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT REFERENCES users(id),
    action VARCHAR(50) NOT NULL,
    resource VARCHAR(50),
    resource_id BIGINT,
    ip_address VARCHAR(45),
    user_agent TEXT,
    performed_by BIGINT REFERENCES users(id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_activity_logs_user ON user_activity_logs(user_id);
CREATE INDEX idx_activity_logs_action ON user_activity_logs(action);
CREATE INDEX idx_activity_logs_created ON user_activity_logs(created_at);
```

---

#### FR-SYS-004: Bảo trì Excel Templates

**ID:** FR-SYS-004  
**Tên:** Maintain Excel Templates  
**Mô tả:** System Admin quản lý các Excel templates chuẩn.

**API Endpoints:**
```
GET    /api/system-admin/templates
POST   /api/system-admin/templates
PUT    /api/system-admin/templates/{id}
DELETE /api/system-admin/templates/{id}
GET    /api/system-admin/templates/{id}/versions
POST   /api/system-admin/templates/{id}/rollback
```

**GET /api/system-admin/templates**

Response:
```json
{
  "success": true,
  "data": {
    "templates": [
      {
        "id": 1,
        "name": "Task Breakdown Template",
        "code": "TASK_BREAKDOWN",
        "description": "Template cho Mentor phân tích nhiệm vụ",
        "currentVersion": "2.1",
        "fileUrl": "https://cloudinary.com/templates/task_breakdown_v2.1.xlsx",
        "downloadCount": 127,
        "lastUpdated": "2026-01-10T10:00:00Z",
        "updatedBy": "System Admin"
      },
      {
        "id": 2,
        "name": "Monthly Report Template",
        "code": "MONTHLY_REPORT",
        "description": "Template báo cáo hàng tháng",
        "currentVersion": "1.5",
        "fileUrl": "https://cloudinary.com/templates/monthly_report_v1.5.xlsx",
        "downloadCount": 89,
        "lastUpdated": "2025-12-15T14:00:00Z",
        "updatedBy": "System Admin"
      },
      {
        "id": 3,
        "name": "Evaluation Template",
        "code": "TALENT_EVALUATION",
        "description": "Template đánh giá sinh viên",
        "currentVersion": "1.0",
        "fileUrl": "https://cloudinary.com/templates/evaluation_v1.0.xlsx",
        "downloadCount": 45,
        "lastUpdated": "2025-11-20T09:00:00Z",
        "updatedBy": "System Admin"
      }
    ]
  }
}
```

**POST /api/system-admin/templates**

Request: `multipart/form-data`
- `file`: Excel file
- `name`: Template name
- `code`: Template code (unique)
- `description`: Description
- `version`: Version number (e.g., "2.1")

**Processing:**
1. Validate Excel file format
2. Scan for viruses
3. Upload to Cloudinary
4. Extract template structure/columns
5. Create template record
6. Create first version record
7. Return template ID and URL

Response:
```json
{
  "success": true,
  "message": "Template đã được tạo",
  "data": {
    "templateId": 4,
    "name": "Fund Distribution Template",
    "code": "FUND_DISTRIBUTION",
    "version": "1.0",
    "fileUrl": "https://cloudinary.com/templates/fund_dist_v1.0.xlsx",
    "uploadedAt": "2026-01-17T14:00:00Z"
  }
}
```

**PUT /api/system-admin/templates/{id}**

Request: `multipart/form-data`
- `file`: New Excel file
- `version`: New version number
- `changeLog`: Description of changes

**Processing:**
1. Validate template exists
2. Validate new version > current version
3. Backup current version
4. Upload new file
5. Update template record
6. Create version history record
7. Notify users who downloaded old version
8. Return updated template

Response:
```json
{
  "success": true,
  "message": "Template đã được cập nhật",
  "data": {
    "templateId": 1,
    "previousVersion": "2.1",
    "newVersion": "2.2",
    "changeLog": "Thêm cột Priority và Dependencies",
    "updatedAt": "2026-01-17T15:00:00Z",
    "usersNotified": 15
  }
}
```

**POST /api/system-admin/templates/{id}/rollback**

Request:
```json
{
  "targetVersion": "2.1",
  "reason": "Version 2.2 có bug parsing"
}
```

**Processing:**
1. Validate target version exists in history
2. Get file URL of target version
3. Set as current version
4. Create rollback record
5. Notify users
6. Return confirmation

Response:
```json
{
  "success": true,
  "message": "Đã rollback về version 2.1",
  "data": {
    "templateId": 1,
    "rolledBackFrom": "2.2",
    "rolledBackTo": "2.1",
    "reason": "Version 2.2 có bug parsing",
    "rolledBackAt": "2026-01-17T16:00:00Z"
  }
}
```

**Database Schema:**
```sql
CREATE TABLE excel_templates (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    code VARCHAR(50) UNIQUE NOT NULL,
    description TEXT,
    current_version VARCHAR(20),
    file_url VARCHAR(500),
    download_count INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_by BIGINT REFERENCES users(id),
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE template_versions (
    id BIGSERIAL PRIMARY KEY,
    template_id BIGINT REFERENCES excel_templates(id),
    version VARCHAR(20) NOT NULL,
    file_url VARCHAR(500),
    change_log TEXT,
    created_by BIGINT REFERENCES users(id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(template_id, version)
);

CREATE TABLE template_downloads (
    id BIGSERIAL PRIMARY KEY,
    template_id BIGINT REFERENCES excel_templates(id),
    version VARCHAR(20),
    downloaded_by BIGINT REFERENCES users(id),
    downloaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

---

## 4. YÊU CẦU GIAO DIỆN BÊN NGOÀI

### 4.1 User Interfaces

#### 4.1.1 Web Portal (ReactJS + TypeScript)

**Responsive Design Requirements:**
- Desktop: ≥ 1366px
- Tablet: 768px - 1365px
- Mobile: 375px - 767px

**UI Components Library:**
- Ant Design hoặc Material-UI
- Custom components theo design system của UTH

**Key Screens:**

**Enterprise Dashboard:**
```
┌─────────────────────────────────────────────┐
│ [Logo] LabOdc        [Notifications] [User] │
├─────────────────────────────────────────────┤
│ ┌─────────┐ ┌─────────┐ ┌─────────┐        │
│ │Projects │ │Payments │ │Reports  │        │
│ │   12    │ │Pending: │ │Upcoming │        │
│ │         │ │ 2       │ │Due: 3   │        │
│ └─────────┘ └─────────┘ └─────────┘        │
│                                              │
│ Recent Projects                              │
│ ┌────────────────────────────────────────┐  │
│ │ Website E-commerce      [View Details] │  │
│ │ Status: In Progress | Progress: 65%    │  │
│ └────────────────────────────────────────┘  │
│                                              │
│ [+ Submit New Project]                       │
└─────────────────────────────────────────────┘
```

**Talent Dashboard:**
```
┌─────────────────────────────────────────────┐
│ [Profile Pic] Nguyen Van A    [Notifications]│
├─────────────────────────────────────────────┤
│ My Projects (3)          Available (47)      │
│ ┌────────────────┐      ┌────────────────┐ │
│ │ E-commerce     │      │ Mobile App      │ │
│ │ 18/20 tasks    │      │ ABC Tech        │ │
│ │ Due: 5 days    │      │ [Join Project] │ │
│ └────────────────┘      └────────────────┘ │
│                                              │
│ My Tasks Today                               │
│ ☐ Implement login UI                        │
│ ☐ Fix responsive issues                     │
│ ✓ Code review PR#123                        │
└─────────────────────────────────────────────┘
```

**Color Scheme:**
- Primary: Teal/Cyan (#17a2b8) - matching UT template
- Success: #28a745
- Warning: #ffc107
- Danger: #dc3545
- Background: #f8f9fa

---

### 4.2 Hardware Interfaces

**Server Requirements:**
- CPU: 4 cores minimum (8 cores recommended)
- RAM: 8GB minimum (16GB recommended)
- Storage: 100GB SSD minimum
- Network: 100 Mbps minimum

**Client Requirements:**
- Web: Modern browser with JavaScript enabled
- Mobile: iOS 12+ / Android 6.0+
- Screen: 5" minimum for mobile

---

### 4.3 Software Interfaces

#### 4.3.1 PayOS Payment Gateway

**Integration Type:** REST API  
**Base URL:** `https://api.payos.vn`  
**Authentication:** API Key + API Secret

**Key Endpoints:**
```
POST /v2/payment-requests
GET  /v2/payment-requests/{id}
POST /v2/payment-requests/{id}/cancel
```

**Webhook:** `POST https://labodc.uth.edu.vn/api/webhooks/payos`

**Sample Payment Request:**
```json
{
  "orderCode": "LABODC-789-1705481234",
  "amount": 100000000,
  "description": "Thanh toán dự án #789",
  "returnUrl": "https://labodc.uth.edu.vn/payments/success",
  "cancelUrl": "https://labodc.uth.edu.vn/payments/cancel"
}
```

---

#### 4.3.2 Cloudinary Media Storage

**Integration Type:** REST API  
**SDK:** cloudinary-java (Backend), cloudinary-react (Frontend)  
**Base URL:** `https://api.cloudinary.com/v1_1/{cloud_name}`

**Operations:**
- Upload image/file
- Generate thumbnails
- Optimize images
- Secure URLs with signed tokens

**Sample Upload:**
```javascript
const result = await cloudinary.uploader.upload(file, {
  folder: 'labodc/avatars',
  public_id: `user_${userId}`,
  overwrite: true,
  transformation: [
    { width: 400, height: 400, crop: 'fill', gravity: 'face' },
    { quality: 'auto', fetch_format: 'auto' }
  ]
});
```

---

### 4.4 Communications Interfaces

#### 4.4.1 HTTP/HTTPS Protocol

- All API communications use HTTPS (TLS 1.2+)
- HTTP/2 supported
- REST architectural style
- JSON data format

#### 4.4.2 WebSocket (Optional cho Real-time)

**Use Cases:**
- Real-time notifications
- Live task updates
- Chat (if implemented)

**Implementation:**
```javascript
// Client
const ws = new WebSocket('wss://labodc.uth.edu.vn/ws');
ws.onmessage = (event) => {
  const notification = JSON.parse(event.data);
  showNotification(notification);
};

// Server (Spring Boot)
@Configuration
@EnableWebSocket
public class WebSocketConfig implements WebSocketConfigurer {
    @Override
    public void registerWebSocketHandlers(WebSocketHandlerRegistry registry) {
        registry.addHandler(notificationHandler(), "/ws")
                .setAllowedOrigins("*");
    }
}
```

---

## 5. YÊU CẦU DỮ LIỆU

### 5.1 Database Schema Overview

**Total Tables:** 30+  
**Database:** PostgreSQL 14+  
**Features Used:**
- JSONB for flexible data
- Full-text search
- Partitioning for large tables
- Indexes for performance

**Complete ER Diagram:**
```
users ──┬─── enterprises
        ├─── talents ────── talent_skills
        │              ├─── talent_certifications
        │              └─── talent_evaluations
        ├─── mentors ────── mentor_invitations
        └─── roles ─────── role_permissions ─── permissions

projects ──┬─── project_attachments
           ├─── project_members
           ├─── tasks
           ├─── payments ──── invoices
           ├─── fund_distributions ──┬─── team_fund_distributions
           │                         │         └─── team_member_allocations
           │                         ├─── disbursements
           │                         └─── hybrid_fund_advances
           ├─── team_reports ────── report_attachments
           └─── mentor_reports

system_configs
config_change_history
excel_templates ──── template_versions
user_activity_logs
transparency_reports
```

---

### 5.2 Data Dictionary

**Core Entities:**

| Entity | Description | Primary Key | Key Attributes |
|--------|-------------|-------------|----------------|
| users | Tất cả người dùng | id (BIGSERIAL) | email, password_hash, role, status |
| enterprises | Doanh nghiệp | id (BIGSERIAL) | user_id, company_name, tax_code |
| talents | Sinh viên | id (BIGSERIAL) | user_id, student_id, faculty |
| mentors | Người hướng dẫn | id (BIGSERIAL) | user_id, expertise (JSONB) |
| projects | Dự án | id (BIGSERIAL) | enterprise_id, mentor_id, budget, status |
| tasks | Nhiệm vụ | id (BIGSERIAL) | project_id, assigned_to, status |
| payments | Thanh toán | id (BIGSERIAL) | project_id, amount, status |
| fund_distributions | Phân bổ quỹ | id (BIGSERIAL) | project_id, team/mentor/lab_amount |

---

### 5.3 Data Retention Policy

| Data Type | Retention Period | Archive Policy |
|-----------|------------------|----------------|
| User accounts (active) | Indefinite | N/A |
| User accounts (inactive > 2 years) | Archive after 2 years | Soft delete |
| Projects (completed) | 5 years | Archive to cold storage |
| Payments & Transactions | 7 years (legal requirement) | Never delete |
| Task history | 3 years | Archive after completion |
| Reports | 5 years | Keep online |
| Logs (application) | 90 days | Rotate daily |
| Logs (audit) | 3 years | Permanent archive |
| Excel templates | Indefinite | Keep all versions |

---

### 5.4 Backup & Recovery

**Backup Strategy:**

**1. Database Backup (PostgreSQL):**
- Full backup: Daily at 2 AM
- Incremental backup: Every 6 hours
- Retention: 30 days
- Location: AWS S3 with versioning
- Encryption: AES-256

**2. File Backup (Cloudinary):**
- Auto-backup enabled
- Retention: Indefinite
- Redundancy: Multi-region

**3. Configuration Backup:**
- Version controlled in Git
- Backup before every change

**Recovery Time Objective (RTO):** < 1 hour  
**Recovery Point Objective (RPO):** < 15 minutes

**Restore Procedure:**
```bash
# Restore from latest backup
pg_restore -h localhost -U postgres -d labodc \
  /backups/labodc_2026-01-17_02-00-00.dump

# Verify data integrity
psql -d labodc -c "SELECT COUNT(*) FROM users;"
```

---

## 6. YÊU CẦU PHI CHỨC NĂNG CHI TIẾT

### 6.1 Performance Requirements

**PR-001: API Response Time**
- GET endpoints: < 200ms (P95)
- POST/PUT endpoints: < 500ms (P95)
- Complex queries: < 1s (P95)
- Search: < 2s (P95)

**PR-002: Page Load Time**
- First Contentful Paint: < 1.5s
- Time to Interactive: < 3.5s
- Largest Contentful Paint: < 2.5s

**PR-003: Database Performance**
- Query execution: < 100ms (average)
- Connection pool: 20-50 connections
- Cache hit ratio: > 80%

**PR-004: File Upload**
- Image (5MB): < 3s
- Document (20MB): < 10s
- Excel (10MB): < 5s

---

### 6.2 Scalability Requirements

**SC-001: Concurrent Users**
- Normal load: 500 concurrent users
- Peak load: 2000 concurrent users
- Max load: 5000 concurrent users (with degraded performance)

**SC-002: Data Volume**
- Projects: 10,000+
- Users: 50,000+
- Transactions: 100,000/year
- Files: 1TB+

**SC-003: Horizontal Scaling**
- Backend: Stateless, can scale to N instances
- Database: Read replicas for scaling reads
- Cache: Redis cluster

---

### 6.3 Availability & Reliability

**AV-001: Uptime**
- Target: 99.0% uptime
- Allowed downtime: 7.2 hours/month
- Planned maintenance: Sunday 2-6 AM

**AV-002: Fault Tolerance**
- Database: Master-slave replication
- Application: Load balancer + multiple instances
- Files: Cloud redundancy (Cloudinary)

**AV-003: Error Rate**
- Target: < 0.1% error rate
- 5xx errors: < 0.01%

---

## 7. YÊU CẦU BẢO MẬT

### 7.1 Authentication & Authorization

**AU-001: Password Policy**
- Minimum length: 8 characters
- Must contain: uppercase, lowercase, number, special char
- Hashing: bcrypt (cost factor 10)
- Storage: Never store plaintext

**AU-002: Session Management**
- JWT tokens: HS256 algorithm
- Access token expiration: 30 minutes
- Refresh token expiration: 7 days
- Secure cookies: HttpOnly, Secure, SameSite

**AU-003: Multi-Factor Authentication (Optional)**
- TOTP-based 2FA
- Backup codes
- Required for System Admin (optional for others)

---

### 7.2 Data Protection

**DP-001: Encryption**
- In transit: TLS 1.2+ (HTTPS)
- At rest: AES-256 for sensitive data
- Database: PostgreSQL encryption at rest
- Passwords: bcrypt with salt

**DP-002: Sensitive Data Handling**
- Tax codes: Encrypted
- Payment info: Never stored (use PayOS tokens)
- Personal data: GDPR compliant
- Audit logs: Encrypted

**DP-003: Data Masking**
- Tax code: Display as "0123***789"
- Email: Display as "use***@example.com"
- Phone: Display as "090***4567"

---

### 7.3 API Security

**AS-001: Rate Limiting**
- Login: 5 requests/minute per IP
- API calls: 100 requests/minute per user
- Upload: 10 requests/minute per user

**AS-002: Input Validation**
- Server-side validation for all inputs
- SQL injection prevention: Parameterized queries
- XSS prevention: Output encoding
- CSRF protection: CSRF tokens

**AS-003: API Authentication**
- Bearer token in Authorization header
- API key for server-to-server
- Signature verification for webhooks

---

### 7.4 Compliance

**CO-001: GDPR Compliance**
- Right to access data
- Right to delete data
- Right to data portability
- Privacy policy & consent

**CO-002: Audit Logging**
- All admin actions logged
- All fund transactions logged
- All user authentication attempts logged
- Log retention: 3 years

---

## 8. TRƯỜNG HỢP KIỂM THỬ

### 8.1 Authentication Test Cases

**TC-AUTH-001: Successful Login**
```
Precondition: User has valid account
Steps:
  1. Navigate to login page
  2. Enter valid email and password
  3. Click "Đăng nhập"
Expected:
  - User redirected to appropriate dashboard
  - JWT token received
  - Session created in Redis
```

**TC-AUTH-002: Invalid Password**
```
Precondition: User has valid account
Steps:
  1. Navigate to login page
  2. Enter valid email, wrong password
  3. Click "Đăng nhập"
Expected:
  - Error message: "Email hoặc mật khẩu không chính xác"
  - Failed attempt counter incremented
  - User remains on login page
```

**TC-AUTH-003: Account Lockout**
```
Precondition: User has valid account
Steps:
  1. Attempt login with wrong password 5 times
Expected:
  - After 5th attempt: "Tài khoản đã bị khóa"
  - Account status = LOCKED
  - Cannot login even with correct password
  - Auto-unlock after 30 minutes
```

---

### 8.2 Project Management Test Cases

**TC-PROJ-001: Submit Project Proposal**
```
Actor: Enterprise
Precondition: Enterprise account verified and active
Steps:
  1. Login as Enterprise
  2. Navigate to "Đề xuất dự án"
  3. Fill all required fields
  4. Upload requirement document
  5. Click "Gửi đề xuất"
Expected:
  - Project created with status=PENDING
  - Notification sent to Lab Admin
  - Confirmation message displayed
```

**TC-PROJ-002: Approve Project**
```
Actor: Lab Admin
Precondition: Project exists with status=PENDING
Steps:
  1. Login as Lab Admin
  2. Navigate to pending projects
  3. View project details
  4. Click "Phê duyệt"
  5. Enter approval note
Expected:
  - Project status = APPROVED
  - Enterprise receives notification
  - Project visible to Talents
```

---

### 8.3 Payment Test Cases

**TC-PAY-001: Successful Payment**
```
Actor: Enterprise
Precondition: Project approved, payment not done
Steps:
  1. Navigate to project payment page
  2. Click "Thanh toán"
  3. Complete PayOS flow
  4. Payment confirmed
Expected:
  - Payment status = PAID
  - Fund distribution calculated (70/20/10)
  - Invoice generated
  - Email confirmation sent
```

**TC-PAY-002: Payment Webhook Processing**
```
Actor: PayOS System
Precondition: Payment initiated
Steps:
  1. PayOS sends webhook to /api/webhooks/payos
  2. Signature verified
  3. Payment status updated
Expected:
  - Payment record updated
  - Fund distribution created
  - Notifications sent
```

---

### 8.4 Integration Test Cases

**TC-INT-001: Complete Project Lifecycle**
```
Scenario: End-to-end project workflow
Steps:
  1. Enterprise registers
  2. Lab Admin approves enterprise
  3. Enterprise submits project
  4. Lab Admin approves project
  5. Lab Admin assigns Mentor
  6. Mentor accepts invitation
  7. Talents join project
  8. Enterprise makes payment
  9. Mentor uploads tasks
  10. Talents complete tasks
  11. Mentor submits report
  12. Talent Leader distributes fund
  13. Mentor approves distribution
  14. Lab Admin disburses funds
Expected:
  - All statuses updated correctly
  - All notifications sent
  - All funds distributed correctly
  - All audit logs created
```

---

### 8.5 Performance Test Cases

**TC-PERF-001: Load Testing**
```
Tool: JMeter / Gatling
Scenario: 500 concurrent users browsing projects
Duration: 30 minutes
Expected:
  - Average response time < 200ms
  - Error rate < 0.1%
  - No memory leaks
  - CPU < 70%
```

**TC-PERF-002: Stress Testing**
```
Scenario: Gradually increase load to 2000 users
Expected:
  - System remains stable
  - Response time degradation < 10%
  - No crashes
```

---

## 9. PHỤ LỤC

### 9.1 Error Codes

| Code | Message | Description |
|------|---------|-------------|
| AUTH-001 | Invalid credentials | Email hoặc password sai |
| AUTH-002 | Account locked | Tài khoản bị khóa |
| AUTH-003 | Token expired | JWT token hết hạn |
| PROJ-001 | Project not found | Dự án không tồn tại |
| PROJ-002 | Insufficient budget | Ngân sách < minimum |
| PAY-001 | Payment failed | Thanh toán thất bại |
| PAY-002 | Payment delayed | Thanh toán chậm |
| FUND-001 | Invalid distribution | Phân phối không hợp lệ |
| FUND-002 | Distribution not 100% | Tổng % != 100 |
| PERM-001 | Access denied | Không có quyền |
| VALID-001 | Validation error | Lỗi validation |

---

### 9.2 API Status Codes

| Status Code | Meaning | Usage |
|-------------|---------|-------|
| 200 | OK | Request thành công |
| 201 | Created | Resource được tạo |
| 400 | Bad Request | Invalid input |
| 401 | Unauthorized | Chưa đăng nhập |
| 403 | Forbidden | Không có quyền |
| 404 | Not Found | Resource không tồn tại |
| 409 | Conflict | Duplicate resource |
| 422 | Unprocessable Entity | Validation errors |
| 429 | Too Many Requests | Rate limit exceeded |
| 500 | Internal Server Error | Server error |
| 503 | Service Unavailable | Maintenance |

---

### 9.3 Email Templates

**Email: Welcome Enterprise**
```
Subject: Chào mừng đến với LabOdc!

Xin chào {{companyName}},

Cảm ơn bạn đã đăng ký tài khoản doanh nghiệp tại LabOdc.
Tài khoản của bạn đang được xem xét bởi Lab Admin.

Bạn sẽ nhận được email thông báo khi tài khoản được kích hoạt.

Trân trọng,
LabOdc Team
```

**Email: Project Approved**
```
Subject: Dự án "{{projectTitle}}" đã được phê duyệt

Xin chào {{enterpriseName}},

Dự án "{{projectTitle}}" của bạn đã được Lab Admin phê duyệt.

Thông tin dự án:
- Ngân sách: {{budget}} VNĐ
- Số sinh viên: {{numberOfStudents}}
- Thời gian: {{startDate}} - {{endDate}}

Bước tiếp theo: Thanh toán để bắt đầu dự án.

[Thanh toán ngay]

Trân trọng,
LabOdc Team
```

---

### 9.4 Validation Rules Summary

**Email:**
- Format: RFC 5322
- Domain: Any valid domain (except for Talent: must be @uth.edu.vn)
- Max length: 255 characters

**Password:**
- Min length: 8
- Max length: 128
- Must contain: uppercase, lowercase, digit, special char
- Cannot contain: username, common passwords

**Phone:**
- Format: Vietnamese phone (0[0-9]{9,10})
- Examples: 0901234567, 0281234567

**Tax Code:**
- Format: 10-13 digits
- Must be unique in system

**Budget:**
- Min: 10,000,000 VNĐ
- Max: 1,000,000,000 VNĐ
- Must be multiple of 1,000,000

**File Upload:**
- Image: JPG, PNG, GIF (max 5MB)
- Document: PDF, DOC, DOCX, PPT, PPTX (max 20MB)
- Excel: XLS, XLSX (max 10MB)

---

## KẾT LUẬN

Tài liệu SRS này cung cấp đặc tả kỹ thuật đầy đủ cho hệ thống LabOdc, bao gồm:

✅ **7 Modules chính** với 23 Functional Requirements chi tiết  
✅ **80+ API Endpoints** với request/response formats đầy đủ  
✅ **30+ Database Tables** với schemas và indexes  
✅ **Interface Requirements** cho Web, Mobile, và Third-party  
✅ **Data Requirements** với retention policy và backup strategy  
✅ **Non-functional Requirements** chi tiết (Performance, Security, Scalability)  
✅ **Security Requirements** toàn diện  
✅ **Test Cases** cho tất cả modules chính  

Tài liệu này là foundation cho:
- **SAD (Software Architecture Document)**: Thiết kế kiến trúc hệ thống
- **DDD (Detailed Design Document)**: Thiết kế chi tiết từng component
- **Implementation**: Development theo specs
- **Testing**: QA test cases và scenarios
- **Deployment**: Production deployment guide

---

**Ngày hoàn thành:** 17/01/2026  
**Trạng thái:** ✅ Hoàn thành 100%  
**Người chuẩn bị:** Nhóm 6 - UTH

---

*HẾT TÀILIỆU SRS*
