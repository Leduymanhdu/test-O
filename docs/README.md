# Tài liệu

Thư mục này chứa tất cả tài liệu của dự án LabOdc theo chuẩn UML 2.0 và quy trình phát triển phần mềm.

## 📋 Trạng thái tài liệu hiện có

<!-- updated: Thêm bảng trạng thái để phân biệt tài liệu đã có và chưa có. -->

| File | Loại | Trạng thái |
|------|------|-----------|
| `URD_LabOdc.md` | Yêu cầu người dùng (URD) | ✅ Có |
| `SRS_LabOdc.md` | Đặc tả yêu cầu phần mềm (SRS) | ✅ Có |
| `DEMO_MICROSERVICES.md` | Hướng dẫn demo API backend | ✅ Có |
| `Problem.txt` | Context & Problem Statement | ✅ Có |
| `SAD_LabOdc.md` | Kiến trúc phần mềm (SAD) | ⏳ Chưa tạo |
| `DDD_LabOdc.md` | Thiết kế chi tiết (DDD) | ⏳ Chưa tạo |
| `TestDoc_LabOdc.md` | Tài liệu kiểm thử | ⏳ Chưa tạo |
| `InstallGuide_LabOdc.md` | Hướng dẫn cài đặt | ⏳ Chưa tạo |
| `DeploymentDoc_LabOdc.md` | Tài liệu triển khai | ⏳ Chưa tạo |

---

## 📁 Cấu trúc tài liệu

### 1. URD (User Requirements Document)
Tài liệu yêu cầu người dùng - Mô tả chi tiết các yêu cầu từ phía người dùng.

**Nội dung:**
- Giới thiệu hệ thống
- Các actor và vai trò
- Yêu cầu chức năng
- Yêu cầu phi chức năng
- Use Case tổng quan

### 2. SRS (Software Requirements Specification)
Đặc tả yêu cầu phần mềm - Mô tả chi tiết các yêu cầu kỹ thuật.

**Nội dung:**
- Yêu cầu chức năng (Functional Requirements)
- Yêu cầu phi chức năng (Non-functional Requirements)
- Yêu cầu giao diện (Interface Requirements)
- Yêu cầu dữ liệu (Data Requirements)
- Đặc tả Use Case (Use Case Specifications)
- Quy tắc nghiệp vụ (Business Rules)

### 3. SAD (Software Architecture Document)
Tài liệu kiến trúc phần mềm - Mô tả kiến trúc tổng thể của hệ thống.

**Nội dung:**
- Mục tiêu kiến trúc (Architectural Goals)
- Tổng quan kiến trúc hệ thống (System Architecture Overview)
- Biểu đồ thành phần (Component Diagrams)
- Biểu đồ triển khai (Deployment Diagrams)
- Ngăn xếp công nghệ (Technology Stack)
- Mẫu thiết kế (Design Patterns)
- Kiến trúc bảo mật (Security Architecture)
- Kiến trúc dữ liệu (Data Architecture)

### 4. DDD (Detailed Design Document)
Tài liệu thiết kế chi tiết - Mô tả thiết kế cụ thể của từng module.

**Nội dung:**
- Biểu đồ lớp (Class Diagrams)
- Biểu đồ tuần tự (Sequence Diagrams)
- Biểu đồ hoạt động (Activity Diagrams)
- Biểu đồ máy trạng thái (State Machine Diagrams)
- Lược đồ database (Database Schema)
- Đặc tả API (API Specifications)
- Thiết kế UI/UX (UI/UX Design)

### 5. Implementation Documentation
Tài liệu triển khai - Hướng dẫn cài đặt và cấu hình.

**Nội dung:**
- Chuẩn code (Coding Standards)
- Hướng dẫn triển khai (Implementation Guidelines)
- Cấu trúc code (Code Structure)
- Triển khai module (Module Implementation)
- Tích hợp bên thứ ba (Third-party Integration)

### 6. Testing Documentation
Tài liệu kiểm thử - Kế hoạch và báo cáo kiểm thử.

**Nội dung:**
- Kế hoạch kiểm thử (Test Plan)
- Ca kiểm thử (Test Cases)
- Kịch bản kiểm thử (Test Scenarios)
- Kết quả kiểm thử (Test Results)
- Báo cáo lỗi (Bug Reports)
- Kiểm thử hiệu suất (Performance Testing)
- Kiểm thử bảo mật (Security Testing)

### 7. Installation Guide
Hướng dẫn cài đặt hệ thống.

**Nội dung:**
- Yêu cầu hệ thống (System Requirements)
- Các bước cài đặt (Installation Steps)
- Hướng dẫn cấu hình (Configuration Guide)
- Khắc phục sự cố (Troubleshooting)
- Câu hỏi thường gặp (FAQ)

### 8. Source Code Documentation
Tài liệu mã nguồn - Tài liệu API, comments trong code.

**Nội dung:**
- Tài liệu API (API Documentation) (Swagger/OpenAPI)
- Comments trong code (Code Comments)
- Tài liệu module (Module Documentation)
- Tham chiếu hàm/phương thức (Function/Method References)

### 9. Deployment Package Documentation
Tài liệu gói triển khai.

**Nội dung:**
- Danh sách kiểm tra triển khai (Deployment Checklist)
- Thiết lập môi trường (Environment Setup)
- Các bước triển khai (Deployment Steps)
- Quy trình rollback (Rollback Procedures)
- Thiết lập giám sát (Monitoring Setup)

### 10. UML Diagrams
Thư mục chứa các sơ đồ UML 2.0.

**Bao gồm:**
- Biểu đồ Use Case (Use Case Diagrams)
- Biểu đồ lớp (Class Diagrams)
- Biểu đồ tuần tự (Sequence Diagrams)
- Biểu đồ hoạt động (Activity Diagrams)
- Biểu đồ máy trạng thái (State Machine Diagrams)
- Biểu đồ thành phần (Component Diagrams)
- Biểu đồ triển khai (Deployment Diagrams)
- Biểu đồ package (Package Diagrams)

## 📝 Template tài liệu

Tất cả tài liệu tuân theo format:

```
1. Trang bìa (Cover Page)
2. Lịch sử tài liệu (Document History)
3. Mục lục (Table of Contents)
4. Giới thiệu (Introduction)
5. Nội dung chính (Main Content)
6. Phụ lục (Appendices)
7. Tham khảo (References)
```

## 🔧 Công cụ

- **Sơ đồ UML**: Enterprise Architect, Visual Paradigm, PlantUML
- **Tài liệu**: Microsoft Word, Markdown, LaTeX
- **Quản lý phiên bản**: Git (theo dõi thay đổi tài liệu)

## ✅ Quy trình xem xét

1. Bản nháp (Draft) → Xem xét (Review) → Phê duyệt (Approve) → Công bố (Publish)
2. Mỗi tài liệu cần ít nhất 2 người xem xét
3. Quản lý phiên bản cho mọi thay đổi

## 📅 Lịch cập nhật

- URD, SRS: Cập nhật trong giai đoạn Phân tích (Analysis)
- SAD, DDD: Cập nhật trong giai đoạn Thiết kế (Design)
- Tài liệu triển khai (Implementation Docs): Cập nhật trong quá trình Phát triển (Development)
- Tài liệu kiểm thử (Test Docs): Cập nhật trong giai đoạn Kiểm thử (Testing)
- Tài liệu triển khai (Deployment Docs): Cập nhật trước khi Triển khai (Deployment)
