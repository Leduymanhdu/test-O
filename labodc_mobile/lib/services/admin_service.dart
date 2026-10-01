import 'package:dio/dio.dart';
import 'package:labodc_mobile/core/constants/api_endpoints.dart';
import 'package:labodc_mobile/core/constants/app_constants.dart';
import 'package:labodc_mobile/services/api_service.dart';
import 'package:logger/logger.dart';

/// Admin Service: tách riêng các call dành cho Lab/System Admin.
///
/// - Mặc định bật mock fallback để UI không gãy khi backend chưa có API.
class AdminService {
  AdminService({ApiService? apiService, bool? enableMockFallback})
      : _api = apiService ?? ApiService(),
        enableMockFallback = enableMockFallback ?? AppConstants.enableMockServices;

  final ApiService _api;
  final _logger = Logger();
  final bool enableMockFallback;

  Future<List<Map<String, dynamic>>> fetchPendingEnterprises() async {
    try {
      final response = await _api.get(ApiEndpoints.enterpriseManagement);
      return _extractList(response.data);
    } on DioException catch (e) {
      _logger.w('AdminService.fetchPendingEnterprises error: ${e.message}');
      if (enableMockFallback) {
        return _mockEnterprises;
      }
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> fetchPendingProjects() async {
    try {
      final response = await _api.get(ApiEndpoints.projectValidation);
      return _extractList(response.data);
    } on DioException catch (e) {
      _logger.w('AdminService.fetchPendingProjects error: ${e.message}');
      if (enableMockFallback) {
        return _mockProjects;
      }
      rethrow;
    }
  }

  Future<bool> approveProject(int projectId) async {
    try {
      final response = await _api.post(
        '${ApiEndpoints.projectValidation}/$projectId/approve',
      );
      return response.statusCode == 200;
    } on DioException catch (e) {
      _logger.w('AdminService.approveProject error: ${e.message}');
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

  List<Map<String, dynamic>> get _mockEnterprises => const [
        {
          'id': 11,
          'name': 'Acme Logistics',
          'status': 'pending',
          'submittedAt': '2026-01-20T10:00:00Z',
        },
        {
          'id': 12,
          'name': 'UTH Innovation',
          'status': 'pending',
          'submittedAt': '2026-01-21T09:30:00Z',
        },
      ];

  List<Map<String, dynamic>> get _mockProjects => const [
        {
          'id': 101,
          'name': 'Smart Logistics Dashboard',
          'status': 'pending',
          'enterpriseId': 11,
          'submittedAt': '2026-01-22T07:00:00Z',
        },
        {
          'id': 102,
          'name': 'AI Document Scanner',
          'status': 'pending',
          'enterpriseId': 12,
          'submittedAt': '2026-01-23T08:15:00Z',
        },
      ];
}
