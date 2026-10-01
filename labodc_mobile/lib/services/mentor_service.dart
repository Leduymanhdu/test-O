import 'package:dio/dio.dart';
import 'package:labodc_mobile/core/constants/api_endpoints.dart';
import 'package:labodc_mobile/core/constants/app_constants.dart';
import 'package:labodc_mobile/services/api_service.dart';
import 'package:logger/logger.dart';

/// Mentor Service: quản lý lời mời và nhiệm vụ cho mentor.
class MentorService {
  MentorService({ApiService? apiService, bool? enableMockFallback})
      : _api = apiService ?? ApiService(),
        enableMockFallback = enableMockFallback ?? AppConstants.enableMockServices;

  final ApiService _api;
  final _logger = Logger();
  final bool enableMockFallback;

  Future<List<Map<String, dynamic>>> fetchInvitations() async {
    try {
      final response = await _api.get(ApiEndpoints.projectInvitations);
      return _extractList(response.data);
    } on DioException catch (e) {
      _logger.w('MentorService.fetchInvitations error: ${e.message}');
      if (enableMockFallback) {
        return _mockInvitations;
      }
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> fetchTasks() async {
    try {
      final response = await _api.get(ApiEndpoints.taskManagement);
      return _extractList(response.data);
    } on DioException catch (e) {
      _logger.w('MentorService.fetchTasks error: ${e.message}');
      if (enableMockFallback) {
        return _mockTasks;
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

  List<Map<String, dynamic>> get _mockInvitations => const [
        {
          'projectId': 301,
          'projectName': 'Smart Logistics Dashboard',
          'role': 'mentor',
          'status': 'pending',
          'sentAt': '2026-01-21T08:00:00Z',
        },
      ];

  List<Map<String, dynamic>> get _mockTasks => const [
        {
          'taskId': 4001,
          'projectId': 301,
          'title': 'Review backlog',
          'status': 'todo',
          'dueDate': '2026-02-05T00:00:00Z',
        },
        {
          'taskId': 4002,
          'projectId': 301,
          'title': 'Sprint planning',
          'status': 'inProgress',
          'dueDate': '2026-02-10T00:00:00Z',
        },
      ];
}
