import 'package:dio/dio.dart';
import 'package:labodc_mobile/core/enums/app_enums.dart';
import 'package:labodc_mobile/models/project_model.dart';
import 'package:labodc_mobile/services/api_service.dart';
import 'package:labodc_mobile/services/mocks/mock_project_data.dart';
import 'package:logger/logger.dart';

/// Service lớp trung gian giữa UI và project-service backend.
///
/// - Khi gateway cung cấp đầy đủ endpoint, class này chỉ cần giữ nguyên chữ ký
///   và thay đổi logic parse response.
/// - Hiện tại vẫn trả mock data khi gặp lỗi/404 để UI có thể hoạt động.
class ProjectService {
  ProjectService({ApiService? apiService, this.enableMockFallback = false})
    : _api = apiService ?? ApiService();

  final ApiService _api;
  final _logger = Logger();
  final bool enableMockFallback;

  Future<List<ProjectModel>> fetchProjects({
    ProjectStatus? status,
    int page = 1,
  }) async {
    try {
      final response = await _api.get('/projects/my');
      return _mapProjects(response);
    } on DioException catch (e) {
      _logger.e('ProjectService.fetchProjects error: ${e.message}');
      if (enableMockFallback) {
        return MockProjectData.list(status: status)
            .map((json) => ProjectModel.fromJson(json))
            .toList();
      }
      if (enableMockFallback) {
        return MockProjectData.list(status: status)
            .map((json) => ProjectModel.fromJson(json))
            .toList();
      }
      rethrow;
    }
  }

  Future<List<ProjectModel>> fetchEnterpriseProjects(int enterpriseId) async {
    return fetchProjects();
  }

  Future<List<ProjectTeamModel>> fetchProjectMembers(int projectId) async {
    try {
      final response = await _api.get('/projects/$projectId/members');
      final items = _extractList(response.data);
      return items
          .map(
            (json) => ProjectTeamModel.fromJson(json as Map<String, dynamic>),
          )
          .toList();
    } on DioException catch (e) {
      _logger.e('ProjectService.fetchProjectMembers error: ${e.message}');
      if (enableMockFallback) {
        return MockProjectData.members(projectId)
            .map(
              (json) => ProjectTeamModel.fromJson(
                json as Map<String, dynamic>,
              ),
            )
            .toList();
      }
      rethrow;
    }
  }

  Future<bool> leaveProject(int projectId) async {
    _logger.w('ProjectService.leaveProject is not supported by backend yet');
    return false;
  }

  Future<List<ProjectModel>> fetchMyProjects({ProjectStatus? status}) async {
    try {
      final response = await _api.get(
        '/projects/my',
        queryParameters: {if (status != null) 'status': status.name},
      );
      return _mapProjects(response);
    } on DioException catch (e) {
      _logger.e('ProjectService.fetchMyProjects error: ${e.message}');
      if (enableMockFallback) {
        return MockProjectData.list(status: status)
            .map((json) => ProjectModel.fromJson(json))
            .toList();
      }
      rethrow;
    }
  }

  Future<bool> submitTalentApplication({
    required int projectId,
    String? motivation,
  }) async {
    try {
      final response = await _api.post(
        '/projects/$projectId/join',
        data: {
          if (motivation != null && motivation.isNotEmpty)
            'motivationLetter': motivation,
        },
      );
      return response.statusCode == 200;
    } on DioException catch (e) {
      _logger.e('ProjectService.submitTalentApplication error: ${e.message}');
      if (enableMockFallback) {
        return true;
      }
      rethrow;
    }
  }

  Future<bool> createProject({required Map<String, dynamic> payload}) async {
    try {
      final response = await _api.post('/projects', data: payload);
      return response.statusCode == 200 || response.statusCode == 201;
    } on DioException catch (e) {
      _logger.w('ProjectService.createProject error: ${e.message}');
      if (enableMockFallback) {
        return true;
      }
      rethrow;
    }
  }

  List<ProjectModel> _mapProjects(Response response) {
    final items = _extractList(response.data);
    return items
        .map((json) => ProjectModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  List<dynamic> _extractList(dynamic payload) {
    if (payload is Map<String, dynamic>) {
      final data = payload['data'];
      if (data is List) {
        return data;
      }
      if (data is Map<String, dynamic>) {
        return [data];
      }
    }
    if (payload is List) {
      return payload;
    }
    return const [];
  }
}
