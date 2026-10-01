# LabOdc Backend - Spring Boot

## 📁 Cấu trúc thư mục

```
labodc-backend/
├── src/
│   ├── main/
│   │   ├── java/com/uth/labodc/
│   │   │   ├── config/              # Configuration classes
│   │   │   ├── controller/          # REST Controllers
│   │   │   │   ├── admin/          # Lab Admin controllers
│   │   │   │   ├── enterprise/     # Enterprise controllers
│   │   │   │   ├── mentor/         # Mentor controllers
│   │   │   │   └── talent/         # Talent controllers
│   │   │   ├── dto/                # Data Transfer Objects
│   │   │   ├── exception/          # Custom exceptions
│   │   │   ├── model/              # Domain models
│   │   │   │   ├── entity/        # JPA entities
│   │   │   │   └── enums/         # Enumerations
│   │   │   ├── repository/         # Data repositories
│   │   │   ├── security/           # Security configs & JWT
│   │   │   ├── service/            # Business logic
│   │   │   │   └── impl/          # Service implementations
│   │   │   └── util/               # Utility classes
│   │   └── resources/
│   │       ├── application.yml     # Application configuration
│   │       ├── db/migration/       # Flyway migrations
│   │       └── templates/          # Excel templates
│   └── test/                       # Unit & Integration tests
├── pom.xml                         # Maven dependencies
└── Dockerfile                      # Docker configuration
```

## 🔑 Các module chính

### Controllers
- **Admin**: Quản lý dự án, doanh nghiệp, mentor, người tài năng
- **Enterprise**: Đăng ký, đề xuất dự án, thanh toán
- **Mentor**: Quản lý nhiệm vụ, đánh giá, báo cáo
- **Talent**: Tham gia dự án, xem nhiệm vụ, nhận phản hồi

### Services
- **AuthService**: Xác thực và phân quyền
- **ProjectService**: Quản lý dự án
- **PaymentService**: Xử lý thanh toán (PayOS)
- **FundService**: Phân phối quỹ 70/20/10
- **ReportService**: Báo cáo tiến độ
- **StorageService**: Lưu trữ file (Cloudinary)

## 🗄️ Database

- **PostgreSQL**: Primary database
- **Redis**: Cache & session
- **Elasticsearch**: Full-text search

## 🚀 Bắt đầu

### Yêu cầu
- JDK 17 trở lên
- Maven 3.8+
- PostgreSQL 14+
- Redis

### Cài đặt

```bash
# Di chuyển vào thư mục backend
cd labodc-backend

# Cài đặt dependencies
mvn clean install

# Chạy ứng dụng
mvn spring-boot:run
```

### Biến môi trường

Tạo file `application-local.yml` hoặc cấu hình biến môi trường:

```yaml
spring:
  datasource:
    url: jdbc:postgresql://localhost:5432/labodc
    username: your_username
    password: your_password
  
  redis:
    host: localhost
    port: 6379

jwt:
  secret: your_jwt_secret
  expiration: 86400000

payos:
  api-key: your_payos_key
  api-secret: your_payos_secret

cloudinary:
  cloud-name: your_cloud_name
  api-key: your_cloudinary_key
  api-secret: your_cloudinary_secret
```

## 📝 Tài liệu API

Tài liệu API có sẵn tại: `http://localhost:8080/swagger-ui.html`

## 🧪 Kiểm thử

```bash
# Chạy tất cả tests
mvn test

# Chạy test cụ thể
mvn test -Dtest=YourTestClass
```
