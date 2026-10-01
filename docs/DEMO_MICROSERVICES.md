# Demo Backend API (LabODC)

<!-- updated: Viết lại hoàn toàn — tài liệu cũ mô tả kiến trúc microservices không tồn tại.
     Thực tế: một Spring Boot monolith duy nhất, không có API Gateway riêng. -->

Tài liệu này hướng dẫn demo nhanh backend API hiện có trong repo.

## 1) Kiến trúc hiện tại

Backend là **một ứng dụng Spring Boot monolithic** duy nhất (`labodc-backend/`), kết nối trực tiếp với PostgreSQL.

```
Client (Web Portal React)
       │
       ▼
Spring Boot App  ←→  PostgreSQL (5432)
(port 8080)      ←→  Cloudinary (file storage)
```

**Các module chính (Controllers):**

| Base path | Controller | Role được phép |
|-----------|-----------|----------------|
| `/api/auth` | AuthController | Public |
| `/api/user` | UserController | Tất cả (authenticated) |
| `/api/projects` | ProjectController | Tất cả |
| `/api/enterprise` | EnterprisePortalController | ENTERPRISE |
| `/api/enterprises` | EnterpriseController | LAB_ADMIN, SYSTEM_ADMIN |
| `/api/mentor` | MentorPortalController | MENTOR |
| `/api/talent` | TalentController | TALENT |
| `/api/dashboard` | DashboardController | LAB_ADMIN, SYSTEM_ADMIN |
| `/api/lab-admin/fund-allocation` | FundAllocationController | LAB_ADMIN, SYSTEM_ADMIN |
| `/api/lab-admin/enterprises` | EnterpriseAdminController | LAB_ADMIN, SYSTEM_ADMIN |
| `/api/lab-admin/mentors` | MentorAdminController | LAB_ADMIN, SYSTEM_ADMIN |
| `/api/lab-admin/talents` | TalentAdminController | LAB_ADMIN, SYSTEM_ADMIN |
| `/api/lab-admin/projects` | ProjectAdminController | LAB_ADMIN, SYSTEM_ADMIN |
| `/api/transparency-reports` | TransparencyReportController | LAB_ADMIN, SYSTEM_ADMIN |

## 2) Cách chạy

### Khởi động database (Docker):

```bash
cd labodc-backend
docker compose up -d
```

Chạy PostgreSQL trên port `5432`, pgAdmin trên port `5050`.

### Khởi động Spring Boot app:

```bash
cd labodc-backend
mvn spring-boot:run
```

App chạy tại: `http://localhost:8080`

## 3) Kịch bản demo nhanh (curl / PowerShell)

### Bước A: Test API hoạt động

```bash
curl http://localhost:8080/api/auth/test
```

Kết quả: `{"success":true,"message":"API is working!"}`

### Bước B: Đăng ký tài khoản Talent

```bash
curl -X POST http://localhost:8080/api/auth/register \
  -H "Content-Type: application/json" \
  -d "{\"email\":\"sv1@uth.edu.vn\",\"password\":\"SecurePass123!\",\"role\":\"TALENT\"}"
```

### Bước C: Đăng nhập → lấy JWT

```bash
curl -X POST http://localhost:8080/api/auth/login \
  -H "Content-Type: application/json" \
  -d "{\"email\":\"sv1@uth.edu.vn\",\"password\":\"SecurePass123!\"}"
```

Kết quả trả về:

```json
{
  "success": true,
  "data": {
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "refreshToken": "...",
    "tokenType": "Bearer",
    "userId": 1,
    "email": "sv1@uth.edu.vn",
    "role": "TALENT",
    "status": "PENDING",
    "emailVerified": false
  }
}
```

Copy token vào biến môi trường (PowerShell):

```powershell
$TOKEN = "<PASTE_JWT_HERE>"
```

### Bước D: Xem profile người dùng

```powershell
curl http://localhost:8080/api/user/profile -H "Authorization: Bearer $TOKEN"
```

### Bước E: Xem danh sách dự án (Talent)

```powershell
curl "http://localhost:8080/api/talent/projects/available" -H "Authorization: Bearer $TOKEN"
```

### Bước F: Tham gia dự án

```powershell
curl -X POST http://localhost:8080/api/talent/projects/1/join `
  -H "Content-Type: application/json" `
  -H "Authorization: Bearer $TOKEN" `
  -d "{\"motivationLetter\":\"Tôi muốn tham gia dự án này\"}"
```

### Bước G: Xem nhiệm vụ được giao

```powershell
curl http://localhost:8080/api/talent/tasks -H "Authorization: Bearer $TOKEN"
```

## 4) Demo với Lab Admin

### Đăng nhập admin:

```powershell
$ADMIN_TOKEN = "<ADMIN_JWT>"
```

### Xem dashboard stats:

```powershell
curl http://localhost:8080/api/dashboard/stats -H "Authorization: Bearer $ADMIN_TOKEN"
```

### Xem danh sách doanh nghiệp chờ xác thực:

```powershell
curl "http://localhost:8080/api/enterprises/management?status=PENDING" -H "Authorization: Bearer $ADMIN_TOKEN"
```

### Xác thực doanh nghiệp:

```powershell
curl -X PUT http://localhost:8080/api/enterprises/1/verify -H "Authorization: Bearer $ADMIN_TOKEN"
```

### Xem Fund Allocation:

```powershell
curl http://localhost:8080/api/lab-admin/fund-allocation/stats -H "Authorization: Bearer $ADMIN_TOKEN"
```

## 5) Mẹo demo thuyết phục

- Gọi thiếu token → nhận `403 Forbidden` (chứng minh authentication hoạt động)
- Dùng role TALENT gọi `/api/dashboard/stats` → nhận `403 Forbidden` (chứng minh RBAC)
- Xem log Spring Boot khi gọi API để thấy request được xử lý

## 6) Trạng thái hiện tại của hệ thống

| Thành phần | Trạng thái | Ghi chú |
|-----------|-----------|---------|
| Spring Boot Backend | ✅ Hoàn thành | Monolith, port 8080 |
| PostgreSQL | ✅ Hoàn thành | Docker Compose |
| JWT Authentication | ✅ Hoàn thành | JJWT 0.12.3 |
| Cloudinary (file storage) | ✅ Tích hợp | Avatar, CV, báo cáo |
| Web Portal (React + TS) | ✅ Có code | `labodc-web-portal/` |
| Redis (cache/session) | ⏳ Chưa tích hợp | Trong pom.xml chưa có |
| Elasticsearch (search) | ⏳ Chưa tích hợp | Trong pom.xml chưa có |
| PayOS (thanh toán) | ⏳ Chưa tích hợp | Model có, API chưa tích hợp |
| AWS Deployment | ⏳ Chưa deploy | Docker có sẵn |
