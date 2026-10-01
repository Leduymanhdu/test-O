# Demo Microservices (LabODC)

Tài liệu này giúp demo nhanh kiến trúc microservices hiện có trong repo.

## 1) Kiến trúc hiện tại

Bạn đang có các service tách riêng (mỗi service là một Spring Boot app + pom.xml + Dockerfile):

- `api-gateway` (Spring Cloud Gateway)
- `auth-service`
- `user-service`
- `project-service`
- PostgreSQL dùng chung (chạy bằng Docker)

Luồng request:

- Client -> API Gateway -> service tương ứng
- Auth dùng JWT (login trả token), Gateway + các service validate JWT

## 2) Cách chạy (Docker Compose - microservices)

Tại thư mục `LabODC_UTH/labodc`:

```bash
docker compose up -d --build
```

Các port quan trọng (từ file compose):

- PostgreSQL: `localhost:5432`
- Gateway: `localhost:8085` (map vào port 8080 trong container)
- Auth service: `localhost:8081`
- User service: `localhost:8082`
- Project service: `localhost:8083`

> Demo với thầy nên gọi qua Gateway để chứng minh API Gateway hoạt động.

## 3) Routing qua Gateway

Gateway route cấu hình theo path:

- `/auth/**` -> `auth-service:8081`
- `/users/**` -> `user-service:8082`
- `/projects/**` -> `project-service:8083`

## 4) Kịch bản demo nhanh (curl)

Dùng PowerShell hoặc cmd đều được.

### Bước A: Register

```bash
curl -X POST http://localhost:8085/auth/register \
  -H "Content-Type: application/json" \
  -d "{\"email\":\"sv1@uth.edu.vn\",\"password\":\"123456\",\"fullName\":\"Sinh Vien 1\",\"role\":\"TALENT\"}"
```

### Bước B: Login -> lấy JWT

```bash
curl -X POST http://localhost:8085/auth/login \
  -H "Content-Type: application/json" \
  -d "{\"email\":\"sv1@uth.edu.vn\",\"password\":\"123456\"}"
```

Kết quả trả về sẽ có token (ví dụ field `token`). Copy token ra biến môi trường (PowerShell):

```powershell
$TOKEN = "<PASTE_JWT_HERE>"
```

### Bước C: Gọi service Users (đi qua gateway)

```powershell
curl http://localhost:8085/users/me -H "Authorization: Bearer $TOKEN"
```

Update profile:

```powershell
curl -X PUT http://localhost:8085/users/me \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d "{\"fullName\":\"Sinh Vien 1 (updated)\",\"skills\":\"Java,Spring\",\"portfolioUrl\":\"https://example.com\"}"
```

### Bước D: Tạo project (Projects service qua gateway)

```powershell
curl -X POST http://localhost:8085/projects \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d "{\"title\":\"Demo Microservices\",\"description\":\"Tao project qua gateway\"}"
```

Xem project của tôi:

```powershell
curl http://localhost:8085/projects/my -H "Authorization: Bearer $TOKEN"
```

Join project (thay `<ID>` theo kết quả):

```powershell
curl -X POST http://localhost:8085/projects/<ID>/join -H "Authorization: Bearer $TOKEN"
```

## 5) Mẹo demo thuyết phục

- Mở 2 cửa sổ terminal:
  - `docker compose logs -f api-gateway`
  - `docker compose logs -f auth-service` (hoặc user/project)
- Khi bạn gọi `curl` qua `localhost:8085/...`, thầy sẽ thấy log ở gateway và log ở service đích.
- Có thể thử gọi thiếu token để chứng minh gateway chặn `401`.

## 6) Những điểm “microservices mức cơ bản” (để giải thích nếu thầy hỏi)

Hiện tại repo thể hiện microservices theo kiểu:

- Deploy độc lập theo service + API Gateway
- Routing tách biệt theo path
- Auth dùng JWT, gateway validate sớm

Nhưng chưa có (nếu thầy kỳ vọng "chuẩn" hơn):

- Service Discovery (Eureka/Consul) -> hiện gateway đang route tĩnh theo host/container name
- Config Server -> config đang nằm trong từng service
- Database-per-service (mỗi service một DB/schema riêng) -> hiện đang dùng chung một Postgres
- Distributed tracing/metrics (Zipkin/Jaeger/OpenTelemetry)
