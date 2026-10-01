import 'package:dio/dio.dart';
import 'package:labodc_mobile/core/constants/api_endpoints.dart';
import 'package:labodc_mobile/core/constants/app_constants.dart';
import 'package:labodc_mobile/services/api_service.dart';
import 'package:logger/logger.dart';

/// Talent Service: dành cho Talent (sinh viên) duyệt/ứng tuyển dự án.
class TalentService {
  TalentService({ApiService? apiService, bool? enableMockFallback})
      : _api = apiService ?? ApiService(),
        enableMockFallback = enableMockFallback ?? AppConstants.enableMockServices;

  final ApiService _api;
  final _logger = Logger();
  final bool enableMockFallback;

  Future<List<Map<String, dynamic>>> browseProjects() async {
    try {
      final response = await _api.get(ApiEndpoints.browseProjects);
      return _extractList(response.data);
    } on DioException catch (e) {
      _logger.w('TalentService.browseProjects error: ${e.message}');
      if (enableMockFallback) {
        return _mockProjects;
      }
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> fetchMyProjects() async {
    try {
      final response = await _api.get(ApiEndpoints.myProjects);
      return _extractList(response.data);
    } on DioException catch (e) {
      _logger.w('TalentService.fetchMyProjects error: ${e.message}');
      if (enableMockFallback) {
        return _mockProjects;
      }
      rethrow;
    }
  }

  Future<bool> applyProject(int projectId, {String? motivation}) async {
    try {
      final response = await _api.post(
        ApiEndpoints.applyProject,
        data: {
          'projectId': projectId,
          if (motivation != null && motivation.isNotEmpty)
            'motivationLetter': motivation,
        },
      );
      return response.statusCode == 200;
    } on DioException catch (e) {
      _logger.w('TalentService.applyProject error: ${e.message}');
      if (enableMockFallback) {
        return true;
      }
      rethrow;
    }
  }

  List<Map<String, dynamic>> _extractList(dynamic payload) {
    if (payload is List) return payload.cast<Map<String, dynamic>>();
    if (payload is Map<String, dynamic>) {
      final data = payload['data'];
      if (data is List) return data.cast<Map<String, dynamic>>();
    }
    return <Map<String, dynamic>>[];
  }

  List<Map<String, dynamic>> get _mockProjects => const [
        {
          'id': 501,
          'name': 'AI Document Scanner',
          'status': 'pending',
          'skills': ['Flutter', 'ML'],
        },
        {
          'id': 502,
          'name': 'Smart Logistics Dashboard',
          'status': 'inProgress',
          'skills': ['Flutter', 'API'],
        },
      ];
}
