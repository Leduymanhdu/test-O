# Cấu trúc chi tiết thư mục Backend

## Tầng Controller

### admin/
- `LabAdminController.java` - Quản lý các chức năng Lab Admin
- `EnterpriseManagementController.java` - Quản lý doanh nghiệp
- `ProjectValidationController.java` - Xác thực dự án
- `FundAllocationController.java` - Phân bổ quỹ
- `ReportController.java` - Báo cáo minh bạch

### enterprise/
- `EnterpriseController.java` - Dashboard và hồ sơ
- `ProjectProposalController.java` - Đề xuất dự án
- `PaymentController.java` - Thanh toán
- `ProjectRequestController.java` - Yêu cầu thay đổi/hủy

### mentor/
- `MentorController.java` - Dashboard và hồ sơ
- `TaskManagementController.java` - Quản lý nhiệm vụ
- `TalentEvaluationController.java` - Đánh giá người tài năng
- `ReportSubmissionController.java` - Nộp báo cáo

### talent/
- `TalentController.java` - Dashboard và hồ sơ
- `ProjectParticipationController.java` - Tham gia dự án
- `TaskViewController.java` - Xem nhiệm vụ
- `PerformanceController.java` - Xem đánh giá

## Tầng Model

### entity/
- `User.java` - Entity người dùng cơ bản
- `Enterprise.java` - Doanh nghiệp
- `Talent.java` - Người tài năng (sinh viên)
- `Mentor.java` - Mentor
- `Project.java` - Dự án
- `ProjectProposal.java` - Đề xuất dự án
- `Payment.java` - Thanh toán
- `FundDistribution.java` - Phân phối quỹ
- `Task.java` - Nhiệm vụ
- `Report.java` - Báo cáo
- `Evaluation.java` - Đánh giá

### enums/
- `UserRole.java` - SYSTEM_ADMIN, LAB_ADMIN, ENTERPRISE, TALENT, MENTOR
- `ProjectStatus.java` - PROPOSED, APPROVED, IN_PROGRESS, COMPLETED, CANCELLED
- `PaymentStatus.java` - PENDING, PAID, DELAYED, REFUNDED
- `TaskStatus.java` - TODO, IN_PROGRESS, COMPLETED

## Tầng Service

### impl/
- `AuthServiceImpl.java` - Triển khai dịch vụ xác thực
- `ProjectServiceImpl.java` - Triển khai dịch vụ dự án
- `PaymentServiceImpl.java` - Triển khai dịch vụ thanh toán
- `FundServiceImpl.java` - Triển khai dịch vụ quỹ
- `ReportServiceImpl.java` - Triển khai dịch vụ báo cáo
- `StorageServiceImpl.java` - Triển khai dịch vụ lưu trữ
- `NotificationServiceImpl.java` - Triển khai dịch vụ thông báo
