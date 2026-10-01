# TÀI LIỆU YÊU CẦU NGƯỜI DÙNG (URD)
## LabOdc - Hệ thống Quản lý Kết nối Doanh nghiệp với Sinh viên UTH

---

## THÔNG TIN TÀI LIỆU

| Mục | Chi tiết |
|-----|----------|
| **Tên dự án** | LabOdc - Hệ thống quản lý kết nối doanh nghiệp với sinh viên UTH trong dự án thực tế |
| **Tên tiếng Anh** | LabOdc - A System for Managing Enterprise-Student Collaborations at UTH on Real-World Projects |
| **Phiên bản** | 1.0 |
| **Ngày** | 17/01/2026 |
| **Người lập** | Nhóm 6 - Đại học Giao thông Vận tải TP.HCM |
| **Trạng thái** | Bản nháp |

---

## LỊCH SỬ THAY ĐỔI

| Phiên bản | Ngày | Người thực hiện | Nội dung thay đổi |
|-----------|------|----------------|-------------------|
| 1.0 | 17/01/2026 | Nhóm 6 | Tạo tài liệu URD ban đầu |

---

## MỤC LỤC

1. [GIỚI THIỆU](#1-giới-thiệu)
2. [TỔNG QUAN HỆ THỐNG](#2-tổng-quan-hệ-thống)
3. [CÁC ACTOR VÀ VAI TRÒ](#3-các-actor-và-vai-trò)
4. [YÊU CẦU CHỨC NĂNG](#4-yêu-cầu-chức-năng)
5. [YÊU CẦU PHI CHỨC NĂNG](#5-yêu-cầu-phi-chức-năng)
6. [RÀNG BUỘC VÀ GIẢ ĐỊNH](#6-ràng-buộc-và-giả-định)
7. [PHỤ LỤC](#7-phụ-lục)

---

## 1. GIỚI THIỆU

### 1.1 Mục đích

Tài liệu Yêu cầu Người dùng (URD) này xác định các yêu cầu nghiệp vụ và chức năng của hệ thống **LabOdc** - một nền tảng phi lợi nhuận kết nối doanh nghiệp với sinh viên Đại học Giao thông Vận tải TP.HCM (UTH) trong các dự án thực tế.

### 1.2 Phạm vi

Hệ thống LabOdc cung cấp:
- **Cho Doanh nghiệp**: Đề xuất dự án, thanh toán, theo dõi tiến độ, đánh giá kết quả
- **Cho Sinh viên**: Tham gia dự án, phát triển kỹ năng, nhận trợ cấp, được hướng dẫn
- **Cho Mentor**: Hướng dẫn nhóm, phân công nhiệm vụ, đánh giá hiệu suất
- **Cho Lab Admin**: Xác thực dự án, quản lý quỹ, đảm bảo minh bạch
- **Cho System Admin**: Quản lý cấu hình hệ thống

### 1.3 Đối tượng sử dụng tài liệu

- Đội ngũ phát triển phần mềm
- Kiểm thử viên (QA/QC)
- Quản lý dự án
- Các bên liên quan (stakeholders)
- Người dùng cuối

### 1.4 Quy ước

- **PHẢI**: Yêu cầu bắt buộc
- **NÊN**: Yêu cầu khuyến nghị
- **CÓ THỂ**: Yêu cầu tùy chọn

---

## 2. TỔNG QUAN HỆ THỐNG

### 2.1 Bối cảnh

Trong thời đại chuyển đổi số, nhu cầu nhân tài CNTT tăng cao. Tuy nhiên:

**Vấn đề của Doanh nghiệp (đặc biệt SME/Startup):**
- Nguồn lực hạn chế (ngân sách, nhân lực)
- Chi phí thuê ODC truyền thống quá cao
- Khó tìm nhân tài có kinh nghiệm với giá hợp lý
- Rủi ro dự án cao do thiếu minh bạch

**Vấn đề của Sinh viên:**
- Có kiến thức lý thuyết nhưng thiếu kinh nghiệm thực tế
- Khó tiếp cận dự án thực tế khi còn học
- Không đáp ứng yêu cầu của doanh nghiệp khi mới ra trường

**Vấn đề của Hệ sinh thái:**
- Không có nền tảng kết nối minh bạch
- Thiếu cơ chế giám sát và đảm bảo chất lượng

### 2.2 Giải pháp LabOdc

LabOdc là hệ thống Lab-based ODC phi lợi nhuận, cung cấp:

**1. Kết nối & Xác thực**
- Doanh nghiệp đề xuất dự án
- Lab xác thực trước khi công bố
- Đảm bảo tính khả thi

**2. Hình thành Nhóm**
- Sinh viên tự nguyện tham gia
- Có Mentor hướng dẫn
- Vai trò rõ ràng (Talent, Talent Leader)

**3. Giám sát Minh bạch**
- Mentor giám sát tiến độ
- Báo cáo định kỳ
- Task tracking bằng Excel chuẩn (không dùng Jira/Trello)

**4. Phân phối Quỹ 70/20/10**
- 70% cho Nhóm sinh viên
- 20% cho Mentor
- 10% cho Lab (vận hành)
- Minh bạch, công khai

**5. Hybrid Fund Support**
- Lab tạm ứng khi doanh nghiệp chậm thanh toán
- Đảm bảo sinh viên/Mentor nhận tiền đúng hạn

### 2.3 Lợi ích

**Doanh nghiệp:**
- ✅ Chi phí hiệu quả
- ✅ Tiếp cận nhân tài trẻ
- ✅ Minh bạch 100%
- ✅ Giảm rủi ro

**Sinh viên:**
- ✅ Kinh nghiệm thực tế
- ✅ Nhận trợ cấp
- ✅ Hướng dẫn từ chuyên gia
- ✅ Xây dựng portfolio

**Mentor:**
- ✅ Thu nhập bổ sung
- ✅ Đóng góp cho giáo dục
- ✅ Mở rộng network

**UTH Lab:**
- ✅ Nâng cao chất lượng đào tạo
- ✅ Kết nối thị trường
- ✅ Nguồn thu duy trì hệ thống

---

## 3. CÁC ACTOR VÀ VAI TRÒ

### 3.1 System Administrator (Quản trị viên Hệ thống)

**Trách nhiệm:**
- Quản lý cấu hình hệ thống
- Quản lý vai trò và quyền hạn
- Quản lý người dùng kỹ thuật
- Bảo trì mẫu Excel/template

**Quyền hạn:**
- Toàn quyền hệ thống
- Thay đổi cấu hình
- Tạo/sửa/xóa vai trò
- Reset mật khẩu bất kỳ user

### 3.2 Lab Administrator (Quản trị viên Lab)

**Trách nhiệm:**
- Xác thực doanh nghiệp và dự án
- Phân bổ quỹ theo quy tắc 70/20/10
- Gán Mentor cho dự án
- Công bố báo cáo minh bạch
- Xử lý yêu cầu thay đổi/hủy
- Tạm ứng quỹ (Hybrid Fund Support)

**Quyền hạn:**
- Phê duyệt/từ chối doanh nghiệp
- Phê duyệt/từ chối dự án
- Quản lý tất cả users (trừ System Admin)
- Xem tất cả báo cáo
- Giải ngân quỹ

### 3.3 Enterprise (Doanh nghiệp)

**Trách nhiệm:**
- Đăng ký tài khoản
- Đề xuất dự án
- Thanh toán đúng hạn
- Đánh giá kết quả

**Quyền hạn:**
- Quản lý hồ sơ công ty
- Đề xuất dự án mới
- Thanh toán qua PayOS
- Xem báo cáo tiến độ
- Yêu cầu thay đổi/hủy dự án

### 3.4 Talent (Sinh viên/Người tài năng)

**Trách nhiệm:**
- Đăng ký tham gia dự án
- Hoàn thành nhiệm vụ được giao
- Cập nhật tiến độ

**Quyền hạn:**
- Quản lý hồ sơ cá nhân (kỹ năng, CV, portfolio)
- Duyệt dự án có sẵn
- Đăng ký tham gia dự án
- Xem nhiệm vụ và đánh giá

### 3.5 Talent Leader (Trưởng nhóm)

**Kế thừa:** Tất cả quyền của Talent

**Trách nhiệm thêm:**
- Phân phối 70% quỹ cho nhóm
- Nộp báo cáo nhóm
- Điều phối công việc

**Quyền hạn thêm:**
- Quản lý phân phối quỹ nhóm
- Nộp báo cáo tiến độ
- Đại diện giao tiếp với Mentor/Lab

### 3.6 Mentor

**Trách nhiệm:**
- Chấp nhận/từ chối lời mời dự án
- Phân tích nhiệm vụ (Task Breakdown)
- Hướng dẫn nhóm
- Đánh giá sinh viên
- Nộp báo cáo định kỳ
- Xác nhận phân phối quỹ

**Quyền hạn:**
- Xem lời mời dự án
- Upload Excel task breakdown
- Phân công nhiệm vụ
- Đánh giá hiệu suất
- Bổ nhiệm Talent Leader
- Yêu cầu điều chỉnh quỹ

### 3.7 Sơ đồ Mối quan hệ

```
System Admin
    ↓ (quản lý hệ thống)
Lab Admin
    ↓ (xác thực, giám sát)
    ├→ Enterprise → Đề xuất dự án → Thanh toán
    ├→ Mentor → Hướng dẫn → Đánh giá
    └→ Talent → Tham gia → Thực hiện
         ↑
    Talent Leader (extends Talent)
```

---

## 4. YÊU CẦU CHỨC NĂNG

### 4.1 Module Xác thực (Authentication)

#### FR-AUTH-001: Đăng nhập
**Mô tả:** Người dùng PHẢI đăng nhập để sử dụng hệ thống.

**Chi tiết:**
- Input: Email + Password
- Sử dụng JWT token
- Token expire: 30 phút
- Lock account sau 5 lần sai
- Tự động logout sau 30 phút idle

**Actor:** Tất cả  
**Ưu tiên:** Cao

---

#### FR-AUTH-002: Đăng ký
**Mô tả:** Người dùng mới PHẢI có thể đăng ký tài khoản.

**Chi tiết:**
- **Enterprise**: Cần mã số thuế, thông tin công ty
- **Talent**: Chỉ chấp nhận email @uth.edu.vn
- **Mentor**: Được Lab Admin mời/tạo
- Xác thực email bắt buộc
- Tài khoản chờ kích hoạt (Enterprise, Mentor)

**Actor:** Enterprise, Talent  
**Ưu tiên:** Cao

---

#### FR-AUTH-003: Quên mật khẩu
**Mô tả:** Người dùng NÊN có thể khôi phục mật khẩu.

**Chi tiết:**
- Gửi link reset qua email
- Link valid 1 giờ
- Yêu cầu mật khẩu mạnh khi reset

**Actor:** Tất cả  
**Ưu tiên:** Trung bình

---

### 4.2 Module Enterprise (Doanh nghiệp)

#### FR-ENT-001: Quản lý Hồ sơ
**Mô tả:** Enterprise PHẢI quản lý được hồ sơ công ty.

**Chi tiết:**
- Tên công ty, MST, địa chỉ
- Lĩnh vực hoạt động
- Người đại diện
- Email, SĐT liên hệ
- Logo công ty (upload Cloudinary)

**Actor:** Enterprise  
**Ưu tiên:** Cao

---

#### FR-ENT-002: Đề xuất Dự án
**Mô tả:** Enterprise PHẢI có thể đề xuất dự án mới.

**Chi tiết:**
- Form nhập: Tên, mô tả, mục tiêu, công nghệ, thời gian, ngân sách
- Số lượng sinh viên cần
- Yêu cầu kỹ năng
- Upload tài liệu đính kèm (max 20MB)
- Lưu bản nháp
- Gửi đến Lab Admin xác thực

**Actor:** Enterprise  
**Ưu tiên:** Cao

---

#### FR-ENT-003: Thanh toán
**Mô tả:** Enterprise PHẢI thanh toán qua PayOS.

**Chi tiết:**
- Tích hợp PayOS API
- Hiển thị phân bổ 70/20/10
- Hỗ trợ: Chuyển khoản, Ví điện tử, Thẻ
- Tạo hóa đơn tự động
- Email xác nhận
- Lịch sử giao dịch

**Actor:** Enterprise  
**Ưu tiên:** Rất cao

---

#### FR-ENT-004: Xem Báo cáo
**Mô tả:** Enterprise PHẢI xem được báo cáo tiến độ.

**Chi tiết:**
- Báo cáo từ Mentor (hàng tháng/giai đoạn)
- Tiến độ % hoàn thành
- Nhiệm vụ đã/đang làm
- Vấn đề và rủi ro
- Đánh giá nhóm
- Download PDF

**Actor:** Enterprise  
**Ưu tiên:** Trung bình

---

#### FR-ENT-005: Yêu cầu Thay đổi/Hủy
**Mô tả:** Enterprise CÓ THỂ yêu cầu thay đổi hoặc hủy dự án.

**Chi tiết:**
- Loại yêu cầu: Thay đổi phạm vi, Thay đổi timeline, Hủy dự án
- Nhập lý do chi tiết
- Gửi đến Lab Admin phê duyệt
- Theo dõi trạng thái: Pending/Approved/Rejected
- Tính toán hoàn tiền (nếu hủy)

**Actor:** Enterprise  
**Ưu tiên:** Trung bình

---

### 4.3 Module Talent (Sinh viên)

#### FR-TAL-001: Quản lý Hồ sơ
**Mô tả:** Talent PHẢI quản lý được hồ sơ cá nhân.

**Chi tiết:**
- Thông tin cơ bản: Họ tên, MSSV, Khoa, Năm học
- Kỹ năng (ngôn ngữ lập trình, framework, tools)
- Chứng chỉ
- Portfolio (GitHub, website cá nhân)
- Upload CV (PDF)
- Avatar

**Actor:** Talent  
**Ưu tiên:** Cao

---

#### FR-TAL-002: Duyệt Dự án
**Mô tả:** Talent PHẢI xem danh sách dự án có sẵn.

**Chi tiết:**
- Hiển thị: Tên dự án, công ty, công nghệ, thời gian, số chỗ trống
- Tìm kiếm theo tên, công nghệ
- Lọc theo: Công nghệ, Thời gian, Trạng thái
- Sắp xếp: Mới nhất, Deadline gần
- Phân trang

**Actor:** Talent  
**Ưu tiên:** Cao

---

#### FR-TAL-003: Tham gia Dự án
**Mô tả:** Talent PHẢI có thể đăng ký tham gia dự án.

**Chi tiết:**
- Click "Tham gia dự án"
- Xác nhận đăng ký
- Thông báo kết quả
- Xem danh sách dự án đã tham gia

**Actor:** Talent  
**Ưu tiên:** Cao

---

#### FR-TAL-004: Xem Nhiệm vụ
**Mô tả:** Talent PHẢI xem nhiệm vụ được phân công.

**Chi tiết:**
- Danh sách nhiệm vụ cá nhân
- Thông tin: Tên, Mô tả, Deadline, Trạng thái, Độ ưu tiên
- Cập nhật trạng thái (To Do → In Progress → Completed)
- Thêm ghi chú
- Upload file kết quả
- Thông báo khi có task mới

**Actor:** Talent  
**Ưu tiên:** Cao

---

#### FR-TAL-005: Xem Đánh giá
**Mô tả:** Talent PHẢI xem đánh giá từ Mentor.

**Chi tiết:**
- Điểm số (1-10 hoặc A-F)
- Nhận xét chi tiết
- Điểm mạnh / Cần cải thiện
- Biểu đồ tiến bộ theo thời gian
- Lịch sử đánh giá

**Actor:** Talent  
**Ưu tiên:** Trung bình

---

### 4.4 Module Talent Leader (Trưởng nhóm)

#### FR-TL-001: Phân phối Quỹ
**Mô tả:** Talent Leader PHẢI phân phối 70% quỹ cho nhóm.

**Chi tiết:**
- Xem tổng quỹ nhóm (70% của total)
- Danh sách thành viên
- Nhập % hoặc số tiền cho từng người
- Kiểm tra tổng = 100%
- Gửi đến Mentor xác nhận
- Lịch sử phân phối

**Actor:** Talent Leader  
**Ưu tiên:** Cao

---

#### FR-TL-002: Nộp Báo cáo Nhóm
**Mô tả:** Talent Leader PHẢI nộp báo cáo tiến độ nhóm.

**Chi tiết:**
- Form báo cáo: Tiến độ %, Task hoàn thành, Vấn đề, Kế hoạch
- Đính kèm file (ảnh, tài liệu)
- Lưu bản nháp
- Gửi đến Mentor và Lab Admin
- Nhắc nhở khi đến hạn

**Actor:** Talent Leader  
**Ưu tiên:** Cao

---

### 4.5 Module Mentor

#### FR-MEN-001: Chấp nhận Lời mời
**Mô tả:** Mentor PHẢI có thể xem và phản hồi lời mời dự án.

**Chi tiết:**
- Thông báo khi được mời
- Xem thông tin dự án đầy đủ
- Thù lao (20% của total)
- Chấp nhận / Từ chối (với lý do)
- Yêu cầu thêm thông tin

**Actor:** Mentor  
**Ưu tiên:** Cao

---

#### FR-MEN-002: Task Breakdown
**Mô tả:** Mentor PHẢI phân tích nhiệm vụ bằng Excel.

**Chi tiết:**
- Tải mẫu Excel chuẩn LabOdc
- Điền: Tên task, Mô tả, Deadline, Người phụ trách, Độ ưu tiên
- Upload file Excel
- Hệ thống parse và hiển thị tasks
- Gửi thông báo cho sinh viên
- Chỉnh sửa tasks sau khi upload

**Actor:** Mentor  
**Ưu tiên:** Rất cao

---

#### FR-MEN-003: Đánh giá Sinh viên
**Mô tả:** Mentor PHẢI đánh giá hiệu suất từng sinh viên.

**Chi tiết:**
- Form đánh giá: Điểm tổng thể, Kỹ năng kỹ thuật, Teamwork, Thái độ
- Nhận xét chi tiết
- Điểm mạnh / Cần cải thiện
- Đánh giá theo giai đoạn (tháng, quý)
- Gửi đến sinh viên và Lab Admin

**Actor:** Mentor  
**Ưu tiên:** Cao

---

#### FR-MEN-004: Nộp Báo cáo
**Mô tả:** Mentor PHẢI nộp báo cáo định kỳ.

**Chi tiết:**
- Form báo cáo: Tiến độ, Tasks hoàn thành, Kế hoạch, Vấn đề, Hiệu suất nhóm
- Đính kèm file
- Gửi đến Lab Admin và Enterprise
- Nhắc nhở tự động

**Actor:** Mentor  
**Ưu tiên:** Cao

---

#### FR-MEN-005: Xác nhận Phân phối Quỹ
**Mô tả:** Mentor PHẢI xác nhận phân phối do Talent Leader đề xuất.

**Chi tiết:**
- Nhận thông báo khi có đề xuất
- Xem chi tiết phân phối
- Chấp nhận / Yêu cầu điều chỉnh / Tự điều chỉnh
- Gửi đến Lab Admin để giải ngân

**Actor:** Mentor  
**Ưu tiên:** Cao

---

#### FR-MEN-006: Chỉ định Trưởng nhóm
**Mô tả:** Mentor CÓ THỂ chỉ định Talent Leader.

**Chi tiết:**
- Xem danh sách thành viên nhóm
- Chọn một người làm Leader
- Xác nhận chỉ định
- Thông báo đến người được chọn
- Có thể thay đổi Leader

**Actor:** Mentor  
**Ưu tiên:** Trung bình

---

### 4.6 Module Lab Administrator

#### FR-LAB-001: Xác thực Doanh nghiệp
**Mô tả:** Lab Admin PHẢI xác thực doanh nghiệp đăng ký.

**Chi tiết:**
- Danh sách doanh nghiệp chờ xác thực
- Xem đầy đủ thông tin: Tên, MST, Lĩnh vực, Người đại diện
- Phê duyệt / Từ chối (lý do) / Yêu cầu bổ sung
- Email thông báo tự động
- Lịch sử xác thực

**Actor:** Lab Admin  
**Ưu tiên:** Cao

---

#### FR-LAB-002: Xác thực Dự án
**Mô tả:** Lab Admin PHẢI xác thực dự án do Enterprise đề xuất.

**Chi tiết:**
- Danh sách dự án chờ xác thực
- Xem thông tin: Dự án, Doanh nghiệp, Ngân sách, Timeline, Kỹ năng
- Phê duyệt / Từ chối / Yêu cầu chỉnh sửa
- Gán Mentor cho dự án
- Công bố dự án sau khi phê duyệt
- Thông báo tự động

**Actor:** Lab Admin  
**Ưu tiên:** Cao

---

#### FR-LAB-003: Quản lý Users
**Mô tả:** Lab Admin PHẢI quản lý Mentor và Talent.

**Chi tiết:**
- Danh sách tất cả Mentor, Talent
- Xem: Trạng thái, Dự án tham gia, Đánh giá
- Thêm/Sửa/Vô hiệu hóa
- Tìm kiếm, lọc
- Export Excel

**Actor:** Lab Admin  
**Ưu tiên:** Trung bình

---

#### FR-LAB-004: Phân bổ Quỹ (70/20/10)
**Mô tả:** Lab Admin PHẢI phân bổ quỹ theo quy tắc cố định.

**Chi tiết:**
- Tự động tính: 70% Team, 20% Mentor, 10% Lab
- Xem chi tiết phân bổ
- Xác nhận phân bổ
- Giải ngân cho Mentor (sau báo cáo cuối)
- Giải ngân cho Talent (sau Talent Leader phân phối)
- Lịch sử giao dịch đầy đủ

**Actor:** Lab Admin  
**Ưu tiên:** Rất cao

---

#### FR-LAB-005: Báo cáo Minh bạch
**Mô tả:** Lab Admin PHẢI công bố báo cáo minh bạch.

**Chi tiết:**
- Tạo báo cáo hàng tháng/quý: Số dự án, Doanh nghiệp, Sinh viên, Quỹ
- Phân bổ 70/20/10
- Dự án thành công/thất bại
- Biểu đồ, thống kê
- Công bố công khai
- Export PDF

**Actor:** Lab Admin  
**Ưu tiên:** Trung bình

---

#### FR-LAB-006: Phê duyệt Thay đổi
**Mô tả:** Lab Admin PHẢI xử lý yêu cầu thay đổi/hủy dự án.

**Chi tiết:**
- Danh sách yêu cầu chờ
- Xem: Loại yêu cầu, Lý do, Ảnh hưởng
- Phê duyệt / Từ chối / Thảo luận
- Tính toán hoàn tiền (nếu hủy)
- Thông báo tất cả bên

**Actor:** Lab Admin  
**Ưu tiên:** Cao

---

#### FR-LAB-007: Tạm ứng Quỹ
**Mô tả:** Lab Admin CÓ THỂ tạm ứng khi doanh nghiệp chậm thanh toán.

**Chi tiết:**
- Cảnh báo khi chậm > 7 ngày
- Quyết định tạm ứng
- Nhập số tiền, chọn đối tượng (Mentor/Talent)
- Ghi nhận: Số tiền, Ngày, Lý do, Trạng thái hoàn trả
- Tự động cập nhật khi doanh nghiệp trả
- Thông báo đến doanh nghiệp

**Actor:** Lab Admin  
**Ưu tiên:** Cao

---

### 4.7 Module System Administrator

#### FR-SYS-001: Cấu hình Hệ thống
**Mô tả:** System Admin PHẢI cấu hình tham số hệ thống.

**Chi tiết:**
- Tỷ lệ phân bổ quỹ (mặc định 70/20/10)
- Thời gian cảnh báo thanh toán
- Giới hạn dự án/doanh nghiệp
- Email templates
- Notification settings
- Log thay đổi
- Xác nhận trước khi lưu

**Actor:** System Admin  
**Ưu tiên:** Trung bình

---

#### FR-SYS-002: Quản lý Vai trò
**Mô tả:** System Admin PHẢI quản lý vai trò và quyền hạn.

**Chi tiết:**
- Vai trò: SYSTEM_ADMIN, LAB_ADMIN, ENTERPRISE, TALENT, TALENT_LEADER, MENTOR
- Tạo vai trò mới
- Chỉnh sửa quyền
- Gán vai trò cho user
- Ma trận quyền (Role-Permission Matrix)
- Log thay đổi

**Actor:** System Admin  
**Ưu tiên:** Cao

---

#### FR-SYS-003: Quản lý Users
**Mô tả:** System Admin PHẢI quản lý tất cả users.

**Chi tiết:**
- Danh sách tất cả users
- Tìm kiếm, lọc theo vai trò, trạng thái
- Kích hoạt/Vô hiệu hóa
- Reset mật khẩu
- Thay đổi vai trò
- Log mọi thao tác
- Export danh sách

**Actor:** System Admin  
**Ưu tiên:** Cao

---

#### FR-SYS-004: Bảo trì Template Excel
**Mô tả:** System Admin PHẢI quản lý mẫu Excel chuẩn.

**Chi tiết:**
- Lưu trữ templates: Task Breakdown, Report, Evaluation
- Upload mẫu mới
- Cập nhật mẫu hiện có
- Xóa mẫu cũ
- Version control
- Rollback về phiên bản cũ
- Mentor/Lab tải được mẫu mới nhất

**Actor:** System Admin  
**Ưu tiên:** Trung bình

---

### 4.8 Chức năng Chung

#### FR-COM-001: Thông báo
**Mô tả:** Hệ thống PHẢI gửi thông báo đa kênh.

**Chi tiết:**
- Kênh: In-app, Email, Push (mobile)
- Loại: Dự án phê duyệt, Thanh toán, Task mới, Đánh giá, Deadline
- User có thể bật/tắt từng loại
- Lịch sử thông báo

**Actor:** Tất cả  
**Ưu tiên:** Cao

---

#### FR-COM-002: Tìm kiếm
**Mô tả:** Hệ thống PHẢI hỗ trợ tìm kiếm nhanh.

**Chi tiết:**
- Elasticsearch cho full-text search
- Tìm: Dự án, Users, Báo cáo
- Lọc đa tiêu chí
- Autocomplete
- Kết quả < 2 giây

**Actor:** Tất cả  
**Ưu tiên:** Cao

---

#### FR-COM-003: Upload File
**Mô tả:** Hệ thống PHẢI cho phép upload file.

**Chi tiết:**
- Loại file: Ảnh (JPG/PNG, max 5MB), Tài liệu (PDF/DOC, max 20MB), Excel (max 10MB)
- Lưu trữ: Cloudinary
- Scan virus
- Thumbnail cho ảnh
- Quản lý file đã upload

**Actor:** Tất cả  
**Ưu tiên:** Cao

---

#### FR-COM-004: Export Dữ liệu
**Mô tả:** Hệ thống PHẢI hỗ trợ export.

**Chi tiết:**
- Định dạng: Excel, PDF, CSV
- Nội dung: Dự án, Users, Báo cáo, Giao dịch
- Bao gồm filters hiện tại
- Tạo file < 10 giây
- Tên file rõ ràng (có ngày)

**Actor:** Lab Admin, System Admin  
**Ưu tiên:** Trung bình

---

## 5. YÊU CẦU PHI CHỨC NĂNG

### 5.1 Performance (Hiệu suất)

**NFR-PERF-001: Tốc độ tải trang**
- Trang chủ: < 3 giây
- Danh sách dự án: < 5 giây
- Dashboard: < 4 giây
- Login/Register: < 2 giây

**NFR-PERF-002: API Response Time**
- GET requests: < 200ms
- POST/PUT requests: < 500ms
- Search (Elasticsearch): < 1 giây

**NFR-PERF-003: Thanh toán**
- PayOS transaction: < 3 giây
- Tạo hóa đơn: < 2 giây
- Gửi email xác nhận: < 5 giây

---

### 5.2 Scalability (Khả năng mở rộng)

**NFR-SCAL-001: Concurrent Users**
- Hỗ trợ tối thiểu: 500 concurrent users
- Hỗ trợ peak: 2000 concurrent users
- Performance degradation < 10% ở 2000 users

**NFR-SCAL-002: Data Volume**
- 10,000+ dự án
- 50,000+ users
- 100,000+ giao dịch/năm

---

### 5.3 Reliability (Độ tin cậy)

**NFR-REL-001: Uptime**
- Uptime: 99.0% (cho phép downtime 7.2 giờ/tháng)
- Maintenance: 2-6 AM Chủ nhật
- Zero data loss

**NFR-REL-002: Error Handling**
- Tất cả lỗi được log
- Thông báo lỗi thân thiện (không hiện stack trace)
- Auto retry khi lỗi tạm thời
- Fallback khi service bên thứ ba fail

---

### 5.4 Security (Bảo mật)

**NFR-SEC-001: Data Encryption**
- Mật khẩu: bcrypt/argon2
- Thông tin thanh toán: AES-256
- HTTPS cho tất cả connections
- Database encryption at-rest

**NFR-SEC-002: Authentication**
- JWT với expiration 30 phút
- Refresh token: 7 ngày
- Lock account sau 5 lần sai
- 2FA (optional) cho Admin
- Role-based access control (RBAC)

**NFR-SEC-003: Data Privacy**
- Tuân thủ GDPR (nếu có user EU)
- User có thể xóa dữ liệu cá nhân
- Không share với bên thứ ba (trừ PayOS, Cloudinary)
- Log access to sensitive data

---

### 5.5 Usability (Dễ sử dụng)

**NFR-USA-001: UI/UX**
- Responsive (desktop, tablet, mobile)
- WCAG 2.1 Level AA
- Đa ngôn ngữ (Tiếng Việt, English)
- Tooltips, help center

**NFR-USA-002: Learning Curve**
- Đăng ký mới: < 5 phút
- Đề xuất dự án đầu tiên: < 15 phút
- Tham gia dự án: < 10 phút
- System Usability Scale (SUS) score > 70

---

### 5.6 Maintainability (Bảo trì)

**NFR-MAIN-001: Code Quality**
- Code coverage > 80%
- Coding standards (Java: Google Style, TS: Airbnb)
- Tất cả functions có documentation
- Pass SonarQube quality gate

**NFR-MAIN-002: Documentation**
- API: Swagger/OpenAPI
- Inline comments cho logic phức tạp
- User Manual, Admin Manual
- Deployment Guide

---

### 5.7 Compatibility (Tương thích)

**NFR-COMP-001: Browser Support**
- Chrome (latest 2 versions)
- Firefox (latest 2 versions)
- Safari (latest 2 versions)
- Edge (latest 2 versions)

**NFR-COMP-002: Mobile Support**
- iOS 12.0+
- Android 6.0+ (API 23+)

---

## 6. RÀNG BUỘC VÀ GIẢ ĐỊNH

### 6.1 Ràng buộc Công nghệ

- Backend: PHẢI dùng Spring Boot
- Database: PHẢI dùng PostgreSQL, Redis, Elasticsearch
- Frontend Web: PHẢI dùng ReactJS + TypeScript
- Mobile: PHẢI dùng Flutter
- Payment: PHẢI dùng PayOS
- Storage: PHẢI dùng Cloudinary
- Deployment: PHẢI dùng Docker, AWS
- KHÔNG dùng Jira/Trello (dùng Excel templates)

### 6.2 Ràng buộc Thời gian

- Hoàn thành: 5 tuần (35 ngày)
- Maintenance window: 2-6 AM Chủ nhật (max 4 giờ)

### 6.3 Ràng buộc Ngân sách

- KHÔNG mua license PM tools
- AWS < $100/tháng (sau free tier)
- Sử dụng RDS free tier, EC2 t2.micro

### 6.4 Ràng buộc Pháp lý

- CHỈ sinh viên UTH (@uth.edu.vn) mới đăng ký Talent
- Doanh nghiệp PHẢI có MST hợp lệ
- Mentor PHẢI được Lab Admin xác thực

### 6.5 Giả định

**Về Người dùng:**
- Có Internet ổn định (>= 1 Mbps)
- Có thiết bị phù hợp (smartphone/laptop)
- Sinh viên có kỹ năng CNTT cơ bản
- Hiểu tiếng Việt hoặc tiếng Anh

**Về Hệ thống:**
- AWS infrastructure luôn available
- PayOS uptime > 99%
- Cloudinary không bị outage
- Email server hoạt động bình thường

**Về Nghiệp vụ:**
- Dự án: 1-6 tháng
- Doanh nghiệp thanh toán đúng hạn (>80%)
- Tỷ lệ hủy dự án < 10%
- Quy tắc 70/20/10 áp dụng cho TẤT CẢ dự án
- Lab có đủ quỹ tạm ứng
- Mentor nộp báo cáo đúng hạn (>80%)

---

## 7. PHỤ LỤC

### 7.1 Từ điển Thuật ngữ

| Thuật ngữ | Định nghĩa |
|-----------|-----------|
| **LabOdc** | Lab-based ODC phi lợi nhuận của UTH |
| **Enterprise** | Doanh nghiệp đề xuất dự án |
| **Talent** | Sinh viên UTH tham gia dự án |
| **Talent Leader** | Trưởng nhóm sinh viên |
| **Mentor** | Người hướng dẫn dự án |
| **Lab Admin** | Quản trị viên Lab (đại diện UTH) |
| **System Admin** | Quản trị viên Hệ thống |
| **Task Breakdown** | Phân tích nhiệm vụ thành công việc nhỏ |
| **Fund Distribution** | Phân phối quỹ 70/20/10 |
| **Hybrid Fund Support** | Cơ chế tạm ứng khi chậm thanh toán |
| **Transparency Report** | Báo cáo minh bạch |

### 7.2 Viết tắt

| Viết tắt | Đầy đủ |
|----------|--------|
| URD | User Requirements Document |
| SRS | Software Requirements Specification |
| SAD | Software Architecture Document |
| DDD | Detailed Design Document |
| ODC | Offshore Development Center |
| UTH | University of Transport and Communications HCMC |
| SME | Small and Medium-sized Enterprises |
| JWT | JSON Web Token |
| API | Application Programming Interface |
| RBAC | Role-Based Access Control |

### 7.3 Trạng thái

| Trạng thái | Áp dụng cho |
|------------|-------------|
| Pending | Doanh nghiệp, Dự án, Thanh toán, Yêu cầu |
| Approved | Doanh nghiệp, Dự án, Yêu cầu |
| Rejected | Doanh nghiệp, Dự án, Yêu cầu |
| In Progress | Dự án, Task |
| Completed | Dự án, Task |
| Cancelled | Dự án |
| Paid | Thanh toán |
| Delayed | Thanh toán |
| Active | User, Dự án |
| Inactive | User |

### 7.4 Quy tắc Nghiệp vụ

**BR-001: Fund Distribution (70/20/10)**
- 70% → Nhóm (Talent Leader phân phối, Mentor xác nhận)
- 20% → Mentor (giải ngân sau báo cáo cuối)
- 10% → Lab (vận hành, tạm ứng)

**BR-002: Payment Delay**
- Chậm < 7 ngày: Email nhắc
- Chậm 7-14 ngày: Lab Admin can thiệp
- Chậm > 14 ngày: Hybrid Fund Support (Lab tạm ứng)

**BR-003: Project Cancellation**
- Hủy trước bắt đầu: Hoàn 100%
- Hủy sau bắt đầu: Tính theo % hoàn thành
- Hủy do lỗi doanh nghiệp: Không hoàn tiền

---

## KẾT LUẬN

Tài liệu URD này mô tả đầy đủ:
- ✅ 6 actors với vai trò rõ ràng
- ✅ 32 yêu cầu chức năng chi tiết
- ✅ 19 yêu cầu phi chức năng
- ✅ Ràng buộc và giả định
- ✅ Quy tắc nghiệp vụ cốt lõi

**Bước tiếp theo:** Phát triển tài liệu SRS (Software Requirements Specification)

---

**Ngày hoàn thành:** 17/01/2026  
**Trạng thái:** Draft - Chờ xem xét  
**Người lập:** Nhóm 6 - UTH

---

*HẾT TÀI LIỆU URD*
