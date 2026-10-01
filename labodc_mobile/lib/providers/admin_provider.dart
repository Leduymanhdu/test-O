import 'package:flutter/foundation.dart';
import 'package:labodc_mobile/services/admin/dashboard_service.dart';
import 'package:labodc_mobile/services/admin/enterprise_service.dart' as enterprise_svc;
import 'package:labodc_mobile/services/admin/project_service.dart';
import 'package:logger/logger.dart';

/// Provider quản lý state cho Lab Admin
class AdminProvider with ChangeNotifier {
  final _logger = Logger();
  final DashboardService _dashboardService = DashboardService();
  final enterprise_svc.EnterpriseAdminService _enterpriseService = enterprise_svc.EnterpriseAdminService();
  final ProjectAdminService _projectService = ProjectAdminService();

  // ============= DASHBOARD STATE =============
  
  DashboardStats? _stats;
  List<RecentActivity> _activities = [];
  List<PendingApproval> _approvals = [];
  List<RevenueChart> _revenueData = [];
  
  bool _loadingDashboard = false;
  String? _dashboardError;

  DashboardStats? get stats => _stats;
  List<RecentActivity> get activities => _activities;
  List<PendingApproval> get approvals => _approvals;
  List<RevenueChart> get revenueData => _revenueData;
  bool get loadingDashboard => _loadingDashboard;
  String? get dashboardError => _dashboardError;

  // ============= ENTERPRISE STATE =============
  
  List<enterprise_svc.EnterpriseListItem> _enterprises = [];
  enterprise_svc.EnterpriseDetail? _selectedEnterprise;
  enterprise_svc.EnterpriseStats? _enterpriseStats;
  
  bool _loadingEnterprises = false;
  String? _enterpriseError;
  String _enterpriseStatusFilter = 'ALL'; // ALL, PENDING, APPROVED, REJECTED
  String _enterpriseSearchText = '';

  List<enterprise_svc.EnterpriseListItem> get enterprises => _enterprises;
  enterprise_svc.EnterpriseDetail? get selectedEnterprise => _selectedEnterprise;
  enterprise_svc.EnterpriseStats? get enterpriseStats => _enterpriseStats;
  bool get loadingEnterprises => _loadingEnterprises;
  String? get enterpriseError => _enterpriseError;
  String get enterpriseStatusFilter => _enterpriseStatusFilter;
  String get enterpriseSearchText => _enterpriseSearchText;

  // ============= PROJECT STATE =============
  
  List<ProjectItem> _projects = [];
  ProjectDetail? _selectedProject;
  Map<String, int> _projectStats = {};
  List<Mentor> _mentors = [];
  
  bool _loadingProjects = false;
  String? _projectError;
  String _projectStatusFilter = 'PENDING'; // PENDING, VALIDATED, REJECTED, etc
  String _projectSearchText = '';

  List<ProjectItem> get projects => _projects;
  ProjectDetail? get selectedProject => _selectedProject;
  Map<String, int> get projectStats => _projectStats;
  List<Mentor> get mentors => _mentors;
  bool get loadingProjects => _loadingProjects;
  String? get projectError => _projectError;
  String get projectStatusFilter => _projectStatusFilter;
  String get projectSearchText => _projectSearchText;

  // ============= DASHBOARD METHODS =============

  /// Load dashboard data
  Future<void> loadDashboard() async {
    _loadingDashboard = true;
    _dashboardError = null;
    notifyListeners();

    try {
      _logger.i('Loading dashboard data...');
      
      // Load all dashboard data in parallel
      final results = await Future.wait([
        _dashboardService.getStats(),
        _dashboardService.getRecentActivities(),
        _dashboardService.getPendingApprovals(10),
        _dashboardService.getRevenueChart(6),
      ]);

      _stats = results[0] as DashboardStats;
      _activities = results[1] as List<RecentActivity>;
      _approvals = results[2] as List<PendingApproval>;
      _revenueData = results[3] as List<RevenueChart>;

      _logger.i('Dashboard loaded: ${_stats?.projects.total} projects');
      _dashboardError = null;
    } catch (e, stackTrace) {
      _logger.e('Error loading dashboard', error: e, stackTrace: stackTrace);
      _dashboardError = e.toString().replaceAll('Exception: ', '');
    } finally {
      _loadingDashboard = false;
      notifyListeners();
    }
  }

  /// Approve enterprise from dashboard
  Future<void> approveEnterpriseFromDashboard(int id) async {
    try {
      await _dashboardService.approveEnterprise(id);
      // Remove from pending approvals
      _approvals.removeWhere((a) => a.type == 'ENTERPRISE' && a.id == id);
      notifyListeners();
      // Reload dashboard to get updated stats
      await loadDashboard();
    } catch (e) {
      _logger.e('Error approving enterprise', error: e);
      rethrow;
    }
  }

  /// Reject enterprise from dashboard
  Future<void> rejectEnterpriseFromDashboard(int id, String? reason) async {
    try {
      await _dashboardService.rejectEnterprise(id, reason);
      _approvals.removeWhere((a) => a.type == 'ENTERPRISE' && a.id == id);
      notifyListeners();
      await loadDashboard();
    } catch (e) {
      _logger.e('Error rejecting enterprise', error: e);
      rethrow;
    }
  }

  /// Approve project from dashboard
  Future<void> approveProjectFromDashboard(int id) async {
    try {
      await _dashboardService.approveProject(id);
      _approvals.removeWhere((a) => a.type == 'PROJECT' && a.id == id);
      notifyListeners();
      await loadDashboard();
    } catch (e) {
      _logger.e('Error approving project', error: e);
      rethrow;
    }
  }

  /// Reject project from dashboard
  Future<void> rejectProjectFromDashboard(int id, String? reason) async {
    try {
      await _dashboardService.rejectProject(id, reason);
      _approvals.removeWhere((a) => a.type == 'PROJECT' && a.id == id);
      notifyListeners();
      await loadDashboard();
    } catch (e) {
      _logger.e('Error rejecting project', error: e);
      rethrow;
    }
  }

  // ============= ENTERPRISE METHODS =============

  /// Load enterprises with filter
  Future<void> loadEnterprises() async {
    _loadingEnterprises = true;
    _enterpriseError = null;
    notifyListeners();

    try {
      _logger.i('Loading enterprises: filter=$_enterpriseStatusFilter, search=$_enterpriseSearchText');
      
      final params = <String, dynamic>{};
      if (_enterpriseStatusFilter != 'ALL') {
        params['status'] = _enterpriseStatusFilter;
      }
      if (_enterpriseSearchText.isNotEmpty) {
        params['search'] = _enterpriseSearchText;
      }

      final result = await _enterpriseService.getEnterprises(params);
      _enterprises = result['enterprises'] as List<enterprise_svc.EnterpriseListItem>;
      
      // Load stats
      _enterpriseStats = await _enterpriseService.getStats();

      _logger.i('Loaded ${_enterprises.length} enterprises');
      _enterpriseError = null;
    } catch (e, stackTrace) {
      _logger.e('Error loading enterprises', error: e, stackTrace: stackTrace);
      _enterpriseError = 'Không thể tải danh sách doanh nghiệp: ${e.toString()}';
    } finally {
      _loadingEnterprises = false;
      notifyListeners();
    }
  }

  /// Set enterprise status filter
  void setEnterpriseStatusFilter(String status) {
    if (_enterpriseStatusFilter != status) {
      _enterpriseStatusFilter = status;
      notifyListeners();
      loadEnterprises();
    }
  }

  /// Set enterprise search text
  void setEnterpriseSearchText(String text) {
    _enterpriseSearchText = text;
    notifyListeners();
  }

  /// Search enterprises (debounced)
  Future<void> searchEnterprises() async {
    await loadEnterprises();
  }

  /// Load enterprise detail
  Future<void> loadEnterpriseDetail(int id) async {
    try {
      _logger.i('Loading enterprise detail: $id');
      _selectedEnterprise = await _enterpriseService.getEnterpriseById(id);
      notifyListeners();
    } catch (e) {
      _logger.e('Error loading enterprise detail', error: e);
      rethrow;
    }
  }

  /// Verify/Approve enterprise
  Future<void> verifyEnterprise(int id) async {
    try {
      await _enterpriseService.verifyEnterprise(id);
      // Reload list
      await loadEnterprises();
    } catch (e) {
      _logger.e('Error verifying enterprise', error: e);
      rethrow;
    }
  }

  /// Reject enterprise
  Future<void> rejectEnterprise(int id, String? reason) async {
    try {
      await _enterpriseService.rejectEnterprise(id, reason);
      await loadEnterprises();
    } catch (e) {
      _logger.e('Error rejecting enterprise', error: e);
      rethrow;
    }
  }

  // ============= PROJECT METHODS =============

  /// Load projects with filter
  Future<void> loadProjects() async {
    _loadingProjects = true;
    _projectError = null;
    notifyListeners();

    try {
      _logger.i('Loading projects: status=$_projectStatusFilter, search=$_projectSearchText');
      
      final params = <String, dynamic>{};
      
      // Only add validated filter if not ALL
      if (_projectStatusFilter != 'ALL') {
        params['validated'] = _projectStatusFilter;
      }
      
      if (_projectSearchText.isNotEmpty) {
        params['search'] = _projectSearchText;
      }

      final allProjects = await _projectService.getProjects(params);
      
      // Deduplicate by project ID
      final seen = <int>{};
      _projects = allProjects.where((project) {
        if (seen.contains(project.id)) {
          return false;
        }
        seen.add(project.id);
        return true;
      }).toList();
      
      // Load stats
      _projectStats = await _projectService.getStats();

      _logger.i('Loaded ${_projects.length} unique projects');
      _projectError = null;
    } catch (e, stackTrace) {
      _logger.e('Error loading projects', error: e, stackTrace: stackTrace);
      _projectError = 'Không thể tải danh sách dự án: ${e.toString()}';
    } finally {
      _loadingProjects = false;
      notifyListeners();
    }
  }

  /// Load available mentors
  Future<void> loadMentors() async {
    try {
      _mentors = await _projectService.getMentors();
      notifyListeners();
    } catch (e) {
      _logger.e('Error loading mentors', error: e);
      rethrow;
    }
  }

  /// Set project status filter
  void setProjectStatusFilter(String status) {
    if (_projectStatusFilter != status) {
      _projectStatusFilter = status;
      notifyListeners();
      loadProjects();
    }
  }

  /// Set project search text
  void setProjectSearchText(String text) {
    _projectSearchText = text;
    notifyListeners();
  }

  /// Search projects
  Future<void> searchProjects() async {
    await loadProjects();
  }

  /// Load project detail
  Future<void> loadProjectDetail(int id) async {
    try {
      _logger.i('Loading project detail: $id');
      _selectedProject = await _projectService.getProjectById(id);
      notifyListeners();
    } catch (e) {
      _logger.e('Error loading project detail', error: e);
      rethrow;
    }
  }

  /// Validate project
  Future<void> validateProject(int id, {
    String? note,
    int? adjustedStudents,
    String? adjustedDuration,
  }) async {
    try {
      await _projectService.validateProject(
        id,
        note: note,
        adjustedStudents: adjustedStudents,
        adjustedDuration: adjustedDuration,
      );
      await loadProjects();
    } catch (e) {
      _logger.e('Error validating project', error: e);
      rethrow;
    }
  }

  /// Reject project
  Future<void> rejectProject(int id, {
    required String reason,
    String? details,
  }) async {
    try {
      await _projectService.rejectProject(id, reason: reason, details: details);
      await loadProjects();
    } catch (e) {
      _logger.e('Error rejecting project', error: e);
      rethrow;
    }
  }

  /// Assign mentor to project
  Future<void> assignMentor(int projectId, int mentorId, String message) async {
    try {
      await _projectService.assignMentor(projectId, mentorId, message);
      await loadProjectDetail(projectId);
    } catch (e) {
      _logger.e('Error assigning mentor', error: e);
      rethrow;
    }
  }

  /// Clear selections
  void clearSelectedEnterprise() {
    _selectedEnterprise = null;
    notifyListeners();
  }

  void clearSelectedProject() {
    _selectedProject = null;
    notifyListeners();
  }
}
