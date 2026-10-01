# LabOdc Mobile App - Flutter

## 📁 Cấu trúc thư mục

```
labodc-mobile/
├── android/                 # Tập tin nền tảng Android
├── ios/                    # Tập tin nền tảng iOS
├── lib/
│   ├── core/              # Chức năng cốt lõi
│   │   ├── constants/    # Hằng số ứng dụng
│   │   ├── network/      # API client, interceptors
│   │   ├── theme/        # Theme và màu sắc ứng dụng
│   │   └── routes/       # Định nghĩa routes
│   ├── models/           # Các data models
│   ├── providers/        # Quản lý state (Provider/Riverpod)
│   ├── screens/          # Các màn hình UI
│   │   ├── auth/        # Màn hình xác thực
│   │   ├── enterprise/  # Màn hình doanh nghiệp
│   │   ├── mentor/      # Màn hình mentor
│   │   └── talent/      # Màn hình người tài năng
│   ├── services/         # Các dịch vụ API
│   ├── utils/            # Hàm tiện ích
│   ├── widgets/          # Các widgets tái sử dụng
│   └── main.dart         # Điểm vào
├── assets/
│   ├── fonts/           # Fonts tùy chỉnh
│   └── images/          # Hình ảnh và icons
├── test/                # Unit và widget tests
├── pubspec.yaml         # Dependencies
└── README.md
```

## 📱 Tính năng chính

### Dành cho người tài năng
- 📋 Duyệt các dự án có sẵn
- ✅ Tham gia dự án
- 📊 Xem nhiệm vụ và tiến độ
- 💬 Trò chuyện với mentor
- 📈 Báo cáo hiệu suất
- 👤 Quản lý hồ sơ

### Dành cho doanh nghiệp
- 🏢 Nộp đề xuất dự án
- 💰 Thanh toán
- 📑 Xem báo cáo dự án
- ⭐ Đánh giá hiệu suất nhóm
- 🔔 Thông báo

### Dành cho Mentor
- 👥 Quản lý nhóm
- ✏️ Phân công nhiệm vụ
- 📝 Nộp báo cáo
- 💯 Đánh giá người tài năng
- 📊 Theo dõi tiến độ

## 🚀 Bắt đầu

### Yêu cầu
- Flutter SDK 3.0+
- Dart 3.0+
- Android Studio / Xcode
- VS Code với Flutter extension

### Cài đặt

```bash
cd labodc-mobile

# Lấy dependencies
flutter pub get

# Chạy ứng dụng
flutter run
```

### Biến môi trường

Tạo file `lib/core/config/env.dart`:

```dart
class Environment {
  static const String apiBaseUrl = 'http://localhost:8080/api';
  static const String cloudinaryCloudName = 'your_cloud_name';
  static const String cloudinaryUploadPreset = 'your_preset';
}
```

## 📦 Dependencies

Các packages chính:
- **http / dio**: Gọi API
- **provider / riverpod**: Quản lý state
- **shared_preferences**: Lưu trữ local
- **flutter_secure_storage**: Lưu trữ bảo mật
- **image_picker**: Chọn hình ảnh
- **cached_network_image**: Cache hình ảnh
- **flutter_local_notifications**: Push notifications
- **charts_flutter**: Biểu đồ và đồ thị
- **intl**: Đa ngôn ngữ

## 🎨 Thiết kế

- Material Design 3
- Màu sắc tùy chỉnh
- Hỗ trợ chế độ tối/sáng
- Bố cục responsive

## 🧪 Kiểm thử

```bash
# Chạy tất cả tests
flutter test

# Chạy test cụ thể
flutter test test/widget_test.dart

# Chạy với coverage
flutter test --coverage
```

## 🏗️ Build

```bash
# Build Android APK
flutter build apk --release

# Build Android App Bundle
flutter build appbundle --release

# Build iOS
flutter build ios --release
```

## 📱 Nền tảng hỗ trợ

- Android 6.0+ (API 23+)
- iOS 12.0+

## 🌐 Đa ngôn ngữ

Ứng dụng hỗ trợ:
- Tiếng Việt (vi)
- English (en)
