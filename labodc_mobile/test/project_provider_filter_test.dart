import 'package:flutter_test/flutter_test.dart';
import 'package:labodc_mobile/core/enums/app_enums.dart';
import 'package:labodc_mobile/models/project_model.dart';
import 'package:labodc_mobile/providers/project_provider.dart';
import 'package:labodc_mobile/services/project_service.dart';

class _FakeProjectService extends ProjectService {
  _FakeProjectService();

  ProjectStatus? receivedStatus;
  int? receivedEnterpriseId;
  int lastPage = 1;
  int fetchCount = 0;

  @override
  Future<List<ProjectModel>> fetchEnterpriseProjects(
    int enterpriseId, {
    ProjectStatus? status,
    int page = 1,
    int pageSize = 20,
    String? query,
    String? sort,
  }) async {
    receivedStatus = status;
    receivedEnterpriseId = enterpriseId;
    lastPage = page;
    fetchCount++;
    return _sampleProjects(page);
  }

  @override
  Future<List<ProjectModel>> fetchProjects({
    ProjectStatus? status,
    int page = 1,
    int pageSize = 20,
    String? query,
    String? sort,
  }) async {
    receivedStatus = status;
    lastPage = page;
    fetchCount++;
    return _sampleProjects(page);
  }

  @override
  Future<List<ProjectModel>> fetchMyProjects({
    ProjectStatus? status,
    int page = 1,
    int pageSize = 20,
    String? query,
    String? sort,
  }) async {
    receivedStatus = status;
    lastPage = page;
    fetchCount++;
    return _sampleProjects(page);
  }

  List<ProjectModel> _sampleProjects(int page) {
    if (page > 1) return [];

    return List.generate(20, (index) {
      return ProjectModel(
        id: index + 1,
        name: 'Demo ${index + 1}',
        description: 'desc',
        objective: 'obj',
        status: ProjectStatus.pending,
        startDate: DateTime(2026, 1, 1),
        endDate: DateTime(2026, 2, 1),
        budget: 1000000,
        requiredTalents: 3,
        enterpriseId: 10,
        technologies: const ['Flutter'],
        requiredSkills: const ['Flutter'],
        mentorId: null,
        attachments: const [],
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 2),
      );
    });
  }
}

void main() {
  group('ProjectProvider filters', () {
    test('loadEnterpriseProjects truyền status vào service và cập nhật state', () async {
      final fakeService = _FakeProjectService();
      final provider = ProjectProvider(projectService: fakeService);

      await provider.loadEnterpriseProjects(99, status: ProjectStatus.pending);

      expect(fakeService.receivedEnterpriseId, 99);
      expect(fakeService.receivedStatus, ProjectStatus.pending);
      expect(provider.projects.length, 20);
      expect(provider.currentScope, ProjectDataScope.enterprise);
      expect(provider.currentFilter, ProjectStatus.pending);
    });

    test('loadMyProjects truyền status vào service', () async {
      final fakeService = _FakeProjectService();
      final provider = ProjectProvider(projectService: fakeService);

      await provider.loadMyProjects(status: ProjectStatus.approved);

      expect(fakeService.receivedStatus, ProjectStatus.approved);
      expect(provider.currentScope, ProjectDataScope.my);
    });

    test('loadMore tăng page và dừng khi hết dữ liệu', () async {
      final fakeService = _FakeProjectService();
      final provider = ProjectProvider(projectService: fakeService);

      await provider.loadProjects();
      expect(provider.hasMore, isTrue);

      await provider.loadMore();
      expect(fakeService.lastPage, 2);
      expect(provider.currentPage, 2);
      expect(provider.hasMore, isFalse);
    });
  });
}
