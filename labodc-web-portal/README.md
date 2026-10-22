# LabOdc Web Portal - ReactJS + TypeScript

## 📁 Cấu trúc thư mục

```
labodc-web-portal/
├── public/                    # Tài sản tĩnh
├── src/
│   ├── assets/               # Hình ảnh, fonts, icons
│   ├── components/           # Các component tái sử dụng
│   │   ├── common/          # Components chung (Button, Input, v.v.)
│   │   ├── forms/           # Các form components
│   │   └── layout/          # Layout components (Header, Footer, Sidebar)
│   ├── hooks/               # Custom React hooks
│   ├── pages/               # Các trang components
│   │   ├── admin/          # Trang Lab Admin
│   │   ├── auth/           # Trang đăng nhập, đăng ký
│   │   ├── enterprise/     # Trang dashboard doanh nghiệp
│   │   ├── mentor/         # Trang dashboard mentor
│   │   ├── system-admin/   # Trang System Admin
│   │   └── talent/         # Trang cổng người tài năng
│   ├── services/            # Các dịch vụ API
│   ├── store/               # Quản lý state (Redux/Context)
│   ├── styles/              # Styles toàn cục, themes
│   ├── types/               # TypeScript types và interfaces
│   ├── utils/               # Hàm tiện ích
│   ├── App.tsx              # Component App chính
│   └── index.tsx            # Điểm vào
├── package.json
├── tsconfig.json
└── README.md
```

## 🎨 Các trang chính

### Xác thực
- Đăng nhập
- Đăng ký (Doanh nghiệp, Người tài năng, Mentor)
- Quên mật khẩu
- Thiết lập hồ sơ

### Dashboard doanh nghiệp
- Tổng quan Dashboard
- Nộp đề xuất dự án
- Quản lý dự án
- Thanh toán
- Xem báo cáo và đánh giá
- Yêu cầu thay đổi/hủy

### Cổng thông tin người tài năng
- Dashboard
- Duyệt dự án có sẵn
- Dự án của tôi
- Xem nhiệm vụ và phân công
- Báo cáo hiệu suất
- Quản lý hồ sơ và kỹ năng

### Dashboard Mentor
- Tổng quan Dashboard
- Chấp nhận lời mời dự án
- Quản lý nhiệm vụ (Excel templates)
- Đánh giá người tài năng
- Nộp báo cáo
- Chỉ định Trưởng nhóm

### Dashboard Lab Admin
- Quản lý doanh nghiệp
- Xác thực dự án
- Quản lý Mentors và người tài năng
- Phân bổ quỹ (70/20/10)
- Báo cáo minh bạch
- Phê duyệt/Từ chối thay đổi

### Dashboard System Admin
- Cấu hình hệ thống
- Quản lý vai trò và quyền
- Quản lý người dùng
- Quản lý Excel Template

## 🚀 Bắt đầu

### Yêu cầu
- Node.js 18+
- npm hoặc yarn

### Cài đặt

```bash
cd labodc-web-portal

# Cài đặt dependencies
npm install
# hoặc
yarn install

# Chạy development server
npm run dev
# hoặc
yarn dev
```

### Biến môi trường

Tạo file `.env.local`:

```env
REACT_APP_API_BASE_URL=http://localhost:8080/api
REACT_APP_CLOUDINARY_CLOUD_NAME=your_cloud_name
REACT_APP_CLOUDINARY_UPLOAD_PRESET=your_preset
```

## 📦 Ngăn xếp công nghệ

- **React 18**: Thư viện UI
- **TypeScript**: An toàn kiểu
- **React Router v6**: Điều hướng
- **Redux Toolkit**: Quản lý state
- **Axios**: HTTP client
- **Ant Design / Material-UI**: Các thành phần UI
- **React Hook Form**: Xử lý form
- **Chart.js / Recharts**: Trực quan hóa dữ liệu
- **TailwindCSS**: CSS tiện ích

## 🧪 Kiểm thử

```bash
# Chạy tests
npm test

# Chạy tests với coverage
npm run test:coverage
```

## 🏗️ Build

```bash
# Build cho production
npm run build

# Xem trước production build
npm run preview
```

## 📱 Responsive Design

Website được thiết kế responsive cho:
- Desktop (1920px+)
- Laptop (1366px+)
- Tablet (768px+)
- Mobile (375px+)
