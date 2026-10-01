# LabODC - Lab Kết Nối Doanh Nghiệp

Hệ thống kết nối sinh viên, mentor và doanh nghiệp trong môi trường thực tập/dự án thực tế.

---

## Kiến trúc hệ thống

```
ODC_SoftwareTesting_UTH/
├── labodc-backend/      # API Server (Spring Boot)
├── labodc-web-portal/   # Web App (React + Vite)
└── docs/                # Tài liệu dự án
```

---

## Yêu cầu cài đặt

| Công cụ | Phiên bản tối thiểu | Tải về |
|---------|---------------------|--------|
| Java JDK | 17+ | https://adoptium.net |
| Maven | 3.8+ | https://maven.apache.org |
| Node.js | 18+ | https://nodejs.org |
| Docker Desktop | 24+ | https://www.docker.com/products/docker-desktop |

Kiểm tra môi trường:

```bash
java -version      # >= 17
mvn -version
node -version      # >= 18
npm -version
docker -version
```

---

## 1. Khởi động Database (PostgreSQL)

Database chạy qua Docker. Mở terminal tại thư mục `labodc-backend/`:

```bash
cd labodc-backend
docker-compose up -d
```

Docker sẽ tự động:
- Khởi động PostgreSQL 16 tại cổng **5432**
- Chạy các file SQL trong `src/database/` để tạo schema và seed data
- Khởi động pgAdmin tại **http://localhost:5050**

Kiểm tra database đã sẵn sàng:

```bash
docker-compose ps
# STATUS của postgres phải là: healthy
```

> **Thông tin kết nối:**
> - Host: `localhost:5432` | Database: `labodc`
> - Username: `root` | Password: `123123`
>
> **pgAdmin:** http://localhost:5050 — Email: `admin@labodc.com` / Password: `admin123`

### Execute / Khởi tạo lại Database

**Cách 1 — Dùng `psql` trong container (khuyên dùng):**

```bash
# Mở psql bên trong container PostgreSQL
docker exec -it labodc-postgres psql -U root -d labodc

# Chạy file SQL từ bên trong psql
\i /docker-entrypoint-initdb.d/schema.sql

# Thoát psql
\q
```

**Cách 2 — Chạy lệnh một dòng không cần vào psql:**

```bash
docker exec -i labodc-postgres psql -U root -d labodc < src/database/schema.sql
```

**Cách 3 — Dùng pgAdmin (giao diện web):**

1. Mở http://localhost:5050
2. Đăng nhập: `admin@labodc.com` / `admin123`
3. Kết nối server: **Add New Server** → tab *Connection* → Host: `postgres`, Port: `5432`, Username: `root`, Password: `123123`
4. Chọn database `labodc` → menu **Tools → Query Tool**
5. Mở file SQL bằng nút **Open File** (biểu tượng thư mục) → chọn `schema.sql`
6. Nhấn **F5** hoặc nút **Execute** để chạy

> **Lưu ý:** Các file SQL chỉ tự động chạy lần đầu khi container được tạo mới. Nếu container đã tồn tại (chỉ bị stop), cần dùng một trong ba cách trên để chạy lại.

Dừng database:

```bash
docker-compose down
```

Reset toàn bộ data về trạng thái ban đầu:

```bash
docker-compose down -v   # xóa volume (toàn bộ data)
docker-compose up -d     # tạo lại container, SQL tự chạy lại từ đầu
```

---

## 2. Khởi động Backend (Spring Boot)

Mở terminal tại thư mục `labodc-backend/`:

```bash
cd labodc-backend
mvn spring-boot:run
```

Server khởi động tại: **http://localhost:8080**

Kiểm tra server đang chạy, mở trình duyệt hoặc dùng curl:

```bash
curl http://localhost:8080/api/auth/health
```

### Tài khoản mặc định

| Role | Email | Password |
|------|-------|----------|
| System Admin | `admin@labodc.com` | `admin123` |
| Lab Admin | `labadmin1@labodc.com` | `admin123` |
| Enterprise | `contact@techcorp.vn` | `admin123` |
| Mentor | `mentor.nguyenquang@uth.edu.vn` | `admin123` |
| Talent | `nguyenvana@student.uth.edu.vn` | `admin123` |

---

## 3. Khởi động Web App (React)

Mở terminal tại thư mục `labodc-web-portal/`:

```bash
cd labodc-web-portal
```

**Lần đầu — cài dependencies:**

```bash
npm install
```

**Chạy development server:**

```bash
npm run dev
```

Web app khởi động tại: **http://localhost:3000**

Mở trình duyệt và truy cập http://localhost:3000, đăng nhập bằng một trong các tài khoản ở bảng trên.

**Build production (tùy chọn):**

```bash
npm run build
npm run preview   # xem bản build tại http://localhost:4173
```

---

## 4. Chạy Tests

### Backend Tests

```bash
cd labodc-backend

# Chạy tất cả unit tests
mvn test

# Chạy một test class cụ thể
mvn test -Dtest=TenClassTest

# Chạy tests và sinh báo cáo HTML
mvn test surefire-report:report
# Xem báo cáo tại: target/site/surefire-report.html
```

### Frontend Tests

```bash
cd labodc-web-portal

# Chạy tất cả tests
npm test

# Chạy ở chế độ watch (tự động re-run khi thay đổi code)
npm run test -- --watch

# Chạy với coverage report
npm run test -- --coverage
# Xem báo cáo tại: coverage/index.html
```

---

## Thứ tự khởi động đúng

```
1. Docker Desktop       →  phải đang chạy
2. docker-compose up    →  khởi động PostgreSQL
3. mvn spring-boot:run  →  Backend kết nối DB tại :8080
4. npm run dev          →  Web App gọi API tại :3000
```

---

## Xử lý lỗi thường gặp

**`Connection refused` khi Backend kết nối DB:**
- Kiểm tra Docker đang chạy: `docker-compose ps`
- Đợi 15-20 giây sau `docker-compose up` để PostgreSQL khởi động xong

**`Port 8080 already in use`:**
```bash
# Windows
netstat -ano | findstr :8080
taskkill /PID <pid> /F
```

**`Port 5432 already in use` (PostgreSQL port bị chiếm):**
```bash
# Đổi port trong docker-compose.yml: "5433:5432"
# Cập nhật application.properties: jdbc:postgresql://localhost:5433/labodc
```

**`Port 3000 already in use`:**
```bash
# Vite tự động thử port 3001, 3002... hoặc đổi trong vite.config.ts:
# server: { port: 3001 }
```

**`npm install` lỗi:**
```bash
npm cache clean --force
npm install
```

**Backend lỗi `JAVA_HOME not set`:**
```bash
# Windows — thêm vào System Environment Variables:
JAVA_HOME=C:\Program Files\Java\jdk-17
PATH=%JAVA_HOME%\bin;%PATH%
```
