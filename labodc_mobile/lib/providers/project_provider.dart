import 'package:flutter/foundation.dart';
import 'package:labodc_mobile/core/constants/app_constants.dart';
import 'package:labodc_mobile/services/storage_service.dart';
import 'package:labodc_mobile/core/enums/app_enums.dart';
import 'package:labodc_mobile/models/project_model.dart';
import 'package:labodc_mobile/services/project_service.dart';

enum ProjectDataScope { general, enterprise, my }

/// ChangeNotifier quản lý danh sách dự án cho mọi vai trò.
class ProjectProvider with ChangeNotifier {
  ProjectProvider({ProjectService? projectService})
    : _projectService = projectService ?? ProjectService();

  final ProjectService _projectService;

  final List<ProjectModel> _projects = [];
  bool _isLoading = false;
  String? _error;
  ProjectStatus? _currentFilter;
  ProjectDataScope _currentScope = ProjectDataScope.general;
  int? _currentEnterpriseId;
  int _currentPage = 1;
  bool _hasMore = true;
  bool _isLoadingMore = false;
  String? _loadMoreError;
  int _pageSize = AppConstants.defaultPageSize;
  String _searchTerm = '';
  String _sort = 'newest';
  final StorageService _storage = StorageService();
  bool _isSubmittingApplication = false;
  int? _submittingProjectId;
  bool _isLeavingProject = false;
  int? _leavingProjectId;

  List<ProjectModel> get projects {
    if (_currentFilter == null) return List.unmodifiable(_projects);
    return List.unmodifiable(
      _projects.where((p) => p.status == _currentFilter),
    );
  }

  List<ProjectModel> get allProjects => List.unmodifiable(_projects);

  bool get isLoading => _isLoading;
  String? get error => _error;
  ProjectStatus? get currentFilter => _currentFilter;
  bool get hasData => _projects.isNotEmpty;
  ProjectDataScope get currentScope => _currentScope;
  int? get currentEnterpriseId => _currentEnterpriseId;
  int get currentPage => _currentPage;
  bool get hasMore => _hasMore;
  bool get isLoadingMore => _isLoadingMore;
  String? get loadMoreError => _loadMoreError;
  int get pageSize => _pageSize;
  bool get isSubmittingApplication => _isSubmittingApplication;
  int? get submittingProjectId => _submittingProjectId;
  bool get isLeavingProject => _isLeavingProject;
  int? get leavingProjectId => _leavingProjectId;

  List<ProjectModel> get activeTalentProjects => List.unmodifiable(
    _projects.where(
      (p) =>
          p.status == ProjectStatus.pending ||
          p.status == ProjectStatus.approved ||
          p.status == ProjectStatus.inProgress,
    ),
  );

  List<ProjectModel> get completedTalentProjects => List.unmodifiable(
    _projects.where((p) => p.status == ProjectStatus.completed),
  );

  int countByStatus(ProjectStatus status) {
    return _projects.where((p) => p.status == status).length;
  }

  int totalCount({ProjectStatus? status}) {
    if (status == null) {
      return _projects.length;
    }
    return countByStatus(status);
  }

  List<String> get availableTechnologies {
    final set = <String>{};
    for (final project in _projects) {
      set.addAll(project.technologies);
    }
    final list = set.toList()..sort();
    return list;
  }

  Future<void> ensureLoaded({
    ProjectDataScope scope = ProjectDataScope.general,
    int? enterpriseId,
  }) async {
    await _storage.init();
    _pageSize = _storage.getInt('project_page_size') ?? _pageSize;
    if (_isLoading) return;
    final needsLoad = _projects.isEmpty || _currentScope != scope;
    if (!needsLoad) return;
    final inheritedFilter = _currentScope == scope ? _currentFilter : null;
    switch (scope) {
      case ProjectDataScope.general:
        await loadProjects(status: inheritedFilter);
        break;
      case ProjectDataScope.enterprise:
        final targetId = enterpriseId ?? _currentEnterpriseId;
        if (targetId != null) {
          await loadEnterpriseProjects(targetId, status: inheritedFilter);
        }
        break;
      case ProjectDataScope.my:
        await loadMyProjects(status: inheritedFilter);
        break;
    }
  }

  Future<void> loadProjects({ProjectStatus? status}) async {
    _currentEnterpriseId = null;
    _currentPage = 1;
    _hasMore = true;
    _loadMoreError = null;
    await _fetch(
      () => (_projectService as dynamic).fetchProjects(
        status: status,
        page: 1,
        pageSize: _pageSize,
        query: _searchTerm.isEmpty ? null : _searchTerm,
        sort: _mapSort(),
      ),
      scope: ProjectDataScope.general,
      filter: status,
    );
  }

  Future<void> loadEnterpriseProjects(
    int enterpriseId, {
    ProjectStatus? status,
  }) async {
    _currentEnterpriseId = enterpriseId;
    _currentPage = 1;
    _hasMore = true;
    _loadMoreError = null;
    await _fetch(
      () => (_projectService as dynamic).fetchEnterpriseProjects(
        enterpriseId,
        status: status,
        page: 1,
        pageSize: _pageSize,
        query: _searchTerm.isEmpty ? null : _searchTerm,
        sort: _mapSort(),
      ),
      filter: status,
      scope: ProjectDataScope.enterprise,
    );
  }

  Future<void> loadMyProjects({ProjectStatus? status}) async {
    _currentEnterpriseId = null;
    _currentPage = 1;
    _hasMore = true;
    _loadMoreError = null;
    await _fetch(
      () => (_projectService as dynamic).fetchMyProjects(
        status: status,
        page: 1,
        pageSize: _pageSize,
        query: _searchTerm.isEmpty ? null : _searchTerm,
        sort: _mapSort(),
      ),
      filter: status,
      scope: ProjectDataScope.my,
    );
  }

  Future<void> loadMore({int? enterpriseId}) async {
    if (_isLoadingMore || !_hasMore) return;
    _isLoadingMore = true;
    _error = null;
    _loadMoreError = null;
    notifyListeners();
    final nextPage = _currentPage + 1;

    try {
      List<ProjectModel> result;
      switch (_currentScope) {
        case ProjectDataScope.general:
          result = await (_projectService as dynamic).fetchProjects(
            status: _currentFilter,
            page: nextPage,
            pageSize: _pageSize,
            query: _searchTerm.isEmpty ? null : _searchTerm,
            sort: _mapSort(),
          );
          break;
        case ProjectDataScope.enterprise:
          final targetId = enterpriseId ?? _currentEnterpriseId;
          if (targetId == null) {
            _isLoadingMore = false;
            notifyListeners();
            return;
          }
          result = await (_projectService as dynamic).fetchEnterpriseProjects(
            targetId,
            status: _currentFilter,
            page: nextPage,
            pageSize: _pageSize,
            query: _searchTerm.isEmpty ? null : _searchTerm,
            sort: _mapSort(),
          );
          break;
        case ProjectDataScope.my:
          result = await (_projectService as dynamic).fetchMyProjects(
            status: _currentFilter,
            page: nextPage,
            pageSize: _pageSize,
            query: _searchTerm.isEmpty ? null : _searchTerm,
            sort: _mapSort(),
          );
          break;
      }

      if (result.isNotEmpty) {
        _projects.addAll(result);
      }

      _currentPage = nextPage;
        if (result.length < _pageSize) {
        _hasMore = false;
      }
    } catch (e) {
      _loadMoreError = e.toString();
      // Giữ hasMore để cho phép thử lại lần sau.
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  Future<void> refresh({int? enterpriseId}) async {
    if (enterpriseId != null) {
      await loadEnterpriseProjects(enterpriseId, status: _currentFilter);
      return;
    }
    switch (_currentScope) {
      case ProjectDataScope.enterprise:
        final targetId = _currentEnterpriseId;
        if (targetId != null) {
          await loadEnterpriseProjects(targetId, status: _currentFilter);
        }
        break;
      case ProjectDataScope.my:
        await loadMyProjects(status: _currentFilter);
        break;
      case ProjectDataScope.general:
        await loadProjects(status: _currentFilter);
        break;
    }
  }

  void setFilter(ProjectStatus? status) {
    _currentFilter = status;
    notifyListeners();
  }

  Future<bool> submitTalentApplication({
    required int projectId,
    String? message,
  }) async {
    if (_isSubmittingApplication) return false;
    _isSubmittingApplication = true;
    _submittingProjectId = projectId;
    _error = null;
    notifyListeners();
    try {
      final success = await _projectService.submitTalentApplication(
        projectId: projectId,
        motivation: message,
      );
      if (success) {
        await refresh();
      }
      return success;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isSubmittingApplication = false;
      _submittingProjectId = null;
      notifyListeners();
    }
  }

  Future<bool> leaveProject(int projectId) async {
    if (_isLeavingProject) return false;
    _isLeavingProject = true;
    _leavingProjectId = projectId;
    _error = null;
    notifyListeners();
    try {
      final success = await _projectService.leaveProject(projectId);
      if (success) {
        await refresh();
      }
      return success;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLeavingProject = false;
      _leavingProjectId = null;
      notifyListeners();
    }
  }

  Future<void> _fetch(
    Future<List<ProjectModel>> Function() task, {
    ProjectStatus? filter,
    required ProjectDataScope scope,
  }) async {
    _isLoading = true;
    _error = null;
    _loadMoreError = null;
    notifyListeners();
    try {
      final result = await task();
      _projects
        ..clear()
        ..addAll(result);
      _currentFilter = filter;
      _currentScope = scope;
      _currentPage = 1;
          _hasMore = result.length >= _pageSize;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> setPageSize(int size) async {
    if (size == _pageSize) return;
    await _storage.init();
    _pageSize = size;
    await _storage.setInt('project_page_size', size);
    _currentPage = 1;
    _hasMore = true;
    _loadMoreError = null;
    await _reloadCurrentScope();
  }

  Future<void> setSearchTerm(String term) async {
    final normalized = term.trim();
    if (normalized == _searchTerm) return;
    _searchTerm = normalized;
    _currentPage = 1;
    _hasMore = true;
    _loadMoreError = null;
    await _reloadCurrentScope();
  }

  Future<void> setSort(String sort) async {
    if (sort == _sort) return;
    _sort = sort;
    _currentPage = 1;
    _hasMore = true;
    _loadMoreError = null;
    await _reloadCurrentScope();
  }

  Future<void> _reloadCurrentScope() async {
    switch (_currentScope) {
      case ProjectDataScope.general:
        await loadProjects(status: _currentFilter);
        break;
      case ProjectDataScope.enterprise:
        final targetId = _currentEnterpriseId;
        if (targetId != null) {
          await loadEnterpriseProjects(targetId, status: _currentFilter);
        }
        break;
      case ProjectDataScope.my:
        await loadMyProjects(status: _currentFilter);
        break;
    }
  }

  String? _mapSort() {
    switch (_sort) {
      case 'budget':
        return 'budget,desc';
      case 'deadline':
        return 'endDate,asc';
      default:
        return 'createdAt,desc';
    }
  }
}
