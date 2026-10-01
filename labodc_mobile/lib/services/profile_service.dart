import 'package:dio/dio.dart';
import 'package:labodc_mobile/models/user_model.dart';
import 'package:labodc_mobile/services/api_service.dart';
import 'package:logger/logger.dart';

/// Service chuyên xử lý thông tin hồ sơ người dùng (sử dụng /users/me hiện có).
class ProfileService {
  ProfileService({ApiService? apiService}) : _api = apiService ?? ApiService();

  final ApiService _api;
  final _logger = Logger();

  Future<UserModel?> fetchCurrentUser() async {
    try {
      final response = await _api.get('/users/me');
      final data = response.data['data'] ?? response.data;
      return UserModel.fromJson(data as Map<String, dynamic>);
    } on DioException catch (e) {
      _logger.e('ProfileService.fetchCurrentUser Dio error: ${e.message}');
      rethrow;
    } catch (e) {
      _logger.e('ProfileService.fetchCurrentUser unexpected error: $e');
      rethrow;
    }
  }

  Future<UserModel?> updateProfile(Map<String, dynamic> payload) async {
    try {
      final response = await _api.put('/users/me', data: payload);
      final data = response.data['data'] ?? response.data;
      return UserModel.fromJson(data as Map<String, dynamic>);
    } on DioException catch (e) {
      _logger.e('ProfileService.updateProfile Dio error: ${e.message}');
      rethrow;
    } catch (e) {
      _logger.e('ProfileService.updateProfile unexpected error: $e');
      rethrow;
    }
  }
}
