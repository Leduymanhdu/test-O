/// App Constants
class AppConstants {
  // App Info
  static const String appName = 'LabOdc';
  static const String appVersion = '1.0.0';
  
  // API Configuration
  static const String baseUrl = 'http://localhost:8080/api';
  static const String emulatorBaseUrl = 'http://10.0.2.2:8080/api';
  static const bool enableRefreshTokenEndpoint = false;
  static const bool enableOptionalAuthEndpoints = false;
  static const bool enableMockServices = true;
  static const String apiVersion = 'v1';
  
  // Timeouts
  static const int connectionTimeout = 30000; // 30 seconds
  static const int receiveTimeout = 30000;
  
  // Storage Keys
  static const String keyAccessToken = 'access_token';
  static const String keyRefreshToken = 'refresh_token';
  static const String keyUserData = 'user_data';
  static const String keyUserRole = 'user_role';
  static const String keyIsFirstTime = 'is_first_time';
  
  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;
  
  // File Upload
  static const int maxFileSize = 20 * 1024 * 1024; // 20MB
  static const List<String> allowedImageExtensions = ['jpg', 'jpeg', 'png'];
  static const List<String> allowedDocExtensions = ['pdf', 'doc', 'docx'];
  
  // Fund Distribution (70/20/10)
  static const double teamFundPercentage = 70.0;
  static const double mentorFundPercentage = 20.0;
  static const double labFundPercentage = 10.0;
  
  // Email Domain
  static const String uthEmailDomain = '@uth.edu.vn';
  
  // Date Formats
  static const String dateFormat = 'dd/MM/yyyy';
  static const String dateTimeFormat = 'dd/MM/yyyy HH:mm';
  static const String timeFormat = 'HH:mm';
}
