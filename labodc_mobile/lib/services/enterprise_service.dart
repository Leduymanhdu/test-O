import 'package:dio/dio.dart';
import 'package:labodc_mobile/core/constants/api_endpoints.dart';
import 'package:labodc_mobile/core/constants/app_constants.dart';
import 'package:labodc_mobile/services/api_service.dart';
import 'package:logger/logger.dart';

/// Enterprise Service: gom các call dành cho doanh nghiệp.
class EnterpriseService {
  EnterpriseService({ApiService? apiService, bool? enableMockFallback})
      : _api = apiService ?? ApiService(),
        enableMockFallback = enableMockFallback ?? AppConstants.enableMockServices;

  final ApiService _api;
  final _logger = Logger();
  final bool enableMockFallback;

  Future<List<Map<String, dynamic>>> fetchMyProjects() async {
    try {
      final response = await _api.get(ApiEndpoints.enterpriseProjects);
      return _extractList(response.data);
    } on DioException catch (e) {
      _logger.w('EnterpriseService.fetchMyProjects error: ${e.message}');
      if (enableMockFallback) {
        return _mockProjects;
      }
      rethrow;
    }
  }

  Future<bool> submitProposal(Map<String, dynamic> payload) async {
    try {
      final response = await _api.post(ApiEndpoints.projectProposal, data: payload);
      return response.statusCode == 200 || response.statusCode == 201;
    } on DioException catch (e) {
      _logger.w('EnterpriseService.submitProposal error: ${e.message}');
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
          'id': 201,
          'name': 'Enterprise Onboarding Portal',
          'status': 'draft',
          'budget': 120000000,
          'submittedAt': '2026-01-18T10:00:00Z',
        },
        {
          'id': 202,
          'name': 'Supply Chain Visibility',
          'status': 'pending',
          'budget': 185000000,
          'submittedAt': '2026-01-22T13:30:00Z',
        },
      ];
}
