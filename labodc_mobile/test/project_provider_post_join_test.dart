import 'package:flutter_test/flutter_test.dart';
import 'package:labodc_mobile/core/enums/app_enums.dart';
import 'package:labodc_mobile/models/project_model.dart';
import 'package:labodc_mobile/providers/project_provider.dart';
import 'package:labodc_mobile/services/project_service.dart';

class FakeProjectService extends ProjectService {
  FakeProjectService();

  int fetchMyProjectsCalls = 0;
  int leaveProjectCalls = 0;
  List<ProjectModel> _projects = [
    _buildProject(id: 1, status: ProjectStatus.inProgress),
    _buildProject(id: 2, status: ProjectStatus.completed),
  ];

  @override
  Future<List<ProjectModel>> fetchMyProjects({ProjectStatus? status}) async {
    fetchMyProjectsCalls++;
    final list = status == null
        ? _projects
        : _projects.where((p) => p.status == status).toList();
    return List<ProjectModel>.from(list);
  }

  @override
  Future<bool> leaveProject(int projectId) async {
    leaveProjectCalls++;
    _projects = _projects.where((p) => p.id != projectId).toList();
    return true;
  }
}

ProjectModel _buildProject({required int id, required ProjectStatus status}) {
  final start = DateTime(2025, 1, 1).add(Duration(days: id));
  final end = start.add(const Duration(days: 60));
  return ProjectModel(
    id: id,
    name: 'Project $id',
    description: 'Mo ta du an $id',
    objective: 'Muc tieu $id',
    technologies: const ['Flutter', 'Dart'],
    startDate: start,
    endDate: end,
    budget: 150000000,
    requiredTalents: 5,
    requiredSkills: const ['Flutter', 'REST'],
    status: status,
    enterpriseId: 10,
    mentorId: null,
    attachments: const [],
    createdAt: start,
    updatedAt: end,
  );
}

void main() {
  test('leaveProject triggers refresh for my scope', () async {
    final service = FakeProjectService();
    final provider = ProjectProvider(projectService: service);

    await provider.loadMyProjects();
    expect(provider.allProjects.length, 2);
    expect(service.fetchMyProjectsCalls, 1);

    final result = await provider.leaveProject(1);

    expect(result, isTrue);
    expect(service.leaveProjectCalls, 1);
    expect(service.fetchMyProjectsCalls, 2);
    expect(provider.allProjects.length, 1);
    expect(provider.allProjects.first.id, 2);
  });
}
