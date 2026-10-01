import 'dart:io';

import 'package:dio/dio.dart';
import 'package:labodc_mobile/core/constants/app_constants.dart';
import 'package:labodc_mobile/services/storage_service.dart';
import 'package:logger/logger.dart';

/// HTTP Client Service using Dio
class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  
  late Dio _dio;
  final _logger = Logger();
  final _storage = StorageService();
  
  ApiService._internal() {
    final resolvedBaseUrl = _resolveBaseUrl();
    _dio = Dio(
      BaseOptions(
        baseUrl: resolvedBaseUrl,
        connectTimeout: const Duration(milliseconds: AppConstants.connectionTimeout),
        receiveTimeout: const Duration(milliseconds: AppConstants.receiveTimeout),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );
    
    _setupInterceptors();
  }
  
  void _setupInterceptors() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Skip adding token for auth endpoints (login, register)
          final isAuthEndpoint = options.path.contains('/auth/login') ||
              options.path.contains('/auth/register');
          
          if (!isAuthEndpoint) {
            // Add auth token for protected endpoints
            final token = await _storage.getAccessToken();
            if (token != null) {
              options.headers['Authorization'] = 'Bearer $token';
            }
          }
          
          _logger.d('📤 Request: ${options.method} ${options.baseUrl}${options.path}');
          _logger.d('Headers: ${options.headers}');
          if (options.data != null) {
            _logger.d('Data: ${options.data}');
          }
          
          return handler.next(options);
        },
        onResponse: (response, handler) {
          _logger.d('✅ Response: ${response.statusCode}');
          _logger.d('Data: ${response.data}');
          return handler.next(response);
        },
        onError: (error, handler) async {
          _logger.e('❌ Error: ${error.type} - ${error.message}');
          _logger.e('Status: ${error.response?.statusCode}');
          _logger.e('Response: ${error.response?.data}');
          
          // Handle 401 - Token expired
          if (error.response?.statusCode == 401) {
            // Try to refresh token
            final refreshed = await _refreshToken();
            if (refreshed) {
              // Retry the request
              final opts = error.requestOptions;
              final token = await _storage.getAccessToken();
              opts.headers['Authorization'] = 'Bearer $token';
              
              try {
                final response = await _dio.fetch(opts);
                return handler.resolve(response);
              } catch (e) {
                return handler.reject(error);
              }
            }
          }
          
          return handler.next(error);
        },
      ),
    );
  }
  
  Future<bool> _refreshToken() async {
    if (!AppConstants.enableRefreshTokenEndpoint) {
      return false;
    }
    try {
      final refreshToken = await _storage.getRefreshToken();
      if (refreshToken == null) return false;
      
      final response = await _dio.post(
        '/auth/refresh-token',
        data: {'refreshToken': refreshToken},
      );
      
      if (response.statusCode == 200 && response.data['success'] == true) {
        final newToken = response.data['data']['token'];
        final newRefreshToken = response.data['data']['refreshToken'];
        
        await _storage.saveAccessToken(newToken);
        await _storage.saveRefreshToken(newRefreshToken);
        
        return true;
      }
      
      return false;
    } catch (e) {
      _logger.e('Error refreshing token: $e');
      return false;
    }
  }
  
  // GET request
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
      );
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
  
  // POST request
  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
  
  // PUT request
  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
  
  // DELETE request
  Future<Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
  
  // Upload file
  Future<Response> uploadFile(
    String path,
    String filePath, {
    Map<String, dynamic>? data,
    ProgressCallback? onSendProgress,
  }) async {
    try {
      final formData = FormData.fromMap({
        ...?data,
        'file': await MultipartFile.fromFile(filePath),
      });
      
      final response = await _dio.post(
        path,
        data: formData,
        onSendProgress: onSendProgress,
      );
      
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
  
  Exception _handleError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return Exception('Kết nối timeout. Vui lòng thử lại.');
      
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final message = error.response?.data['message'] ?? 
                       error.response?.data['error'] ??
                       'Lỗi không xác định';
        
        switch (statusCode) {
          case 400:
            return Exception('Dữ liệu không hợp lệ: $message');
          case 401:
            return Exception('Phiên đăng nhập hết hạn. Vui lòng đăng nhập lại.');
          case 403:
            return Exception('Bạn không có quyền thực hiện hành động này.');
          case 404:
            return Exception('Không tìm thấy dữ liệu.');
          case 500:
            return Exception('Lỗi server. Vui lòng thử lại sau.');
          default:
            return Exception(message);
        }
      
      case DioExceptionType.cancel:
        return Exception('Yêu cầu đã bị hủy.');
      
      default:
        return Exception('Không có kết nối internet. Vui lòng kiểm tra lại.');
    }
  }

  String _resolveBaseUrl() {
    // Nếu chạy trên Android emulator và dùng localhost thì chuyển sang 10.0.2.2:8080/api.
    final raw = AppConstants.baseUrl;
    final isLocal = raw.contains('localhost') || raw.contains('127.0.0.1');
    if (isLocal && Platform.isAndroid) {
      return AppConstants.emulatorBaseUrl;
    }
    return raw;
  }
}
