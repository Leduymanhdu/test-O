import 'package:dio/dio.dart';
import 'package:labodc_mobile/services/api_service.dart';
import 'package:logger/logger.dart';

/// Dashboard Service for Lab Admin
class DashboardService {
  final ApiService _api = ApiService();
  final _logger = Logger();

  /// Get dashboard statistics
  Future<DashboardStats> getStats() async {
    try {
      _logger.i('📊 Loading dashboard stats...');
      final response = await _api.get('/dashboard/stats');
      
      final data = response.data['data'];
      _logger.i('✅ Dashboard stats loaded');
      
      return DashboardStats.fromJson(data);
    } catch (e) {
      _logger.e('❌ Error loading dashboard stats', error: e);
      throw Exception('Không thể kết nối đến server. Vui lòng kiểm tra:\n- Backend có đang chạy ở http://localhost:8080\n- Kết nối mạng của bạn');
    }
  }

  /// Get recent activities
  Future<List<RecentActivity>> getRecentActivities() async {
    try {
      _logger.i('📋 Loading recent activities...');
      final response = await _api.get('/dashboard/activities');
      
      final data = response.data['data'] as List;
      _logger.i('✅ Loaded ${data.length} activities');
      
      return data.map((json) => RecentActivity.fromJson(json)).toList();
    } catch (e) {
      _logger.e('❌ Error loading activities', error: e);
      rethrow;
    }
  }

  /// Get pending approvals
  Future<List<PendingApproval>> getPendingApprovals(int limit) async {
    try {
      _logger.i('⏳ Loading pending approvals...');
      final response = await _api.get('/dashboard/approvals', queryParameters: {'limit': limit});
      
      final data = response.data['data'] as List;
      _logger.i('✅ Loaded ${data.length} pending approvals');
      
      return data.map((json) => PendingApproval.fromJson(json)).toList();
    } catch (e) {
      _logger.e('❌ Error loading pending approvals', error: e);
      rethrow;
    }
  }

  /// Get revenue chart data
  Future<List<RevenueChart>> getRevenueChart(int months) async {
    try {
      _logger.i('📈 Loading revenue chart...');
      final response = await _api.get('/dashboard/revenue', queryParameters: {'months': months});
      
      final data = response.data['data'] as List;
      _logger.i('✅ Loaded revenue data for $months months');
      
      return data.map((json) => RevenueChart.fromJson(json)).toList();
    } catch (e) {
      _logger.e('❌ Error loading revenue chart', error: e);
      rethrow;
    }
  }

  /// Approve enterprise
  Future<void> approveEnterprise(int id) async {
    try {
      await _api.put('/enterprises/$id/verify');
      _logger.i('✅ Enterprise $id approved');
    } catch (e) {
      _logger.e('❌ Error approving enterprise', error: e);
      rethrow;
    }
  }

  /// Reject enterprise
  Future<void> rejectEnterprise(int id, String? reason) async {
    try {
      await _api.delete('/enterprises/$id', data: {'reason': reason});
      _logger.i('✅ Enterprise $id rejected');
    } catch (e) {
      _logger.e('❌ Error rejecting enterprise', error: e);
      rethrow;
    }
  }

  /// Approve project
  Future<void> approveProject(int id) async {
    try {
      await _api.put('/projects/$id/validate');
      _logger.i('✅ Project $id approved');
    } catch (e) {
      _logger.e('❌ Error approving project', error: e);
      rethrow;
    }
  }

  /// Reject project
  Future<void> rejectProject(int id, String? reason) async {
    try {
      await _api.put('/projects/$id/reject', data: {'reason': reason});
      _logger.i('✅ Project $id rejected');
    } catch (e) {
      _logger.e('❌ Error rejecting project', error: e);
      rethrow;
    }
  }
}

// ============= MODELS =============

class DashboardStats {
  final ProjectStats projects;
  final EnterpriseStats enterprises;
  final TalentStats talents;
  final MentorStats mentors;
  final double totalRevenue;

  DashboardStats({
    required this.projects,
    required this.enterprises,
    required this.talents,
    required this.mentors,
    required this.totalRevenue,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    return DashboardStats(
      projects: ProjectStats.fromJson(json['projects']),
      enterprises: EnterpriseStats.fromJson(json['enterprises']),
      talents: TalentStats.fromJson(json['talents']),
      mentors: MentorStats.fromJson(json['mentors']),
      totalRevenue: (json['totalRevenue'] ?? 0).toDouble(),
    );
  }
}

class ProjectStats {
  final int total;
  final int newCount;
  final int ongoing;
  final int completed;
  final int cancelled;
  final double successRate;

  ProjectStats({
    required this.total,
    required this.newCount,
    required this.ongoing,
    required this.completed,
    required this.cancelled,
    required this.successRate,
  });

  factory ProjectStats.fromJson(Map<String, dynamic> json) {
    return ProjectStats(
      total: json['total'] ?? 0,
      newCount: json['newCount'] ?? 0,
      ongoing: json['ongoing'] ?? 0,
      completed: json['completed'] ?? 0,
      cancelled: json['cancelled'] ?? 0,
      successRate: (json['successRate'] ?? 0).toDouble(),
    );
  }
}

class EnterpriseStats {
  final int total;
  final int pending;
  final int verified;
  final int rejected;

  EnterpriseStats({
    required this.total,
    required this.pending,
    required this.verified,
    required this.rejected,
  });

  factory EnterpriseStats.fromJson(Map<String, dynamic> json) {
    return EnterpriseStats(
      total: json['total'] ?? 0,
      pending: json['pending'] ?? 0,
      verified: json['verified'] ?? 0,
      rejected: json['rejected'] ?? 0,
    );
  }
}

class TalentStats {
  final int total;
  final int active;
  final int available;
  final int working;

  TalentStats({
    required this.total,
    required this.active,
    required this.available,
    required this.working,
  });

  factory TalentStats.fromJson(Map<String, dynamic> json) {
    return TalentStats(
      total: json['total'] ?? 0,
      active: json['active'] ?? 0,
      available: json['available'] ?? 0,
      working: json['working'] ?? 0,
    );
  }
}

class MentorStats {
  final int total;
  final int active;
  final int available;
  final int mentoring;

  MentorStats({
    required this.total,
    required this.active,
    required this.available,
    required this.mentoring,
  });

  factory MentorStats.fromJson(Map<String, dynamic> json) {
    return MentorStats(
      total: json['total'] ?? 0,
      active: json['active'] ?? 0,
      available: json['available'] ?? 0,
      mentoring: json['mentoring'] ?? 0,
    );
  }
}

class RecentActivity {
  final int id;
  final String type;
  final String action;
  final String description;
  final String? userName;
  final DateTime timestamp;

  RecentActivity({
    required this.id,
    required this.type,
    required this.action,
    required this.description,
    this.userName,
    required this.timestamp,
  });

  factory RecentActivity.fromJson(Map<String, dynamic> json) {
    return RecentActivity(
      id: json['id'] ?? 0,
      type: json['type'] ?? '',
      action: json['action'] ?? '',
      description: json['description'] ?? '',
      userName: json['userName'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}

class PendingApproval {
  final int id;
  final String type; // ENTERPRISE, PROJECT
  final String name;
  final String? submittedBy;
  final DateTime submittedAt;
  final String? priority; // HIGH, NORMAL, LOW
  final String? status;

  PendingApproval({
    required this.id,
    required this.type,
    required this.name,
    this.submittedBy,
    required this.submittedAt,
    this.priority,
    this.status,
  });

  factory PendingApproval.fromJson(Map<String, dynamic> json) {
    return PendingApproval(
      id: json['id'] ?? 0,
      type: json['type'] ?? '',
      name: json['name'] ?? '',
      submittedBy: json['submittedBy'],
      submittedAt: DateTime.parse(json['submittedAt']),
      priority: json['priority'],
      status: json['status'],
    );
  }
}

class RevenueChart {
  final String month;
  final double revenue;
  final double expenses;
  final double profit;

  RevenueChart({
    required this.month,
    required this.revenue,
    required this.expenses,
    required this.profit,
  });

  factory RevenueChart.fromJson(Map<String, dynamic> json) {
    return RevenueChart(
      month: json['month'] ?? '',
      revenue: (json['revenue'] ?? 0).toDouble(),
      expenses: (json['expenses'] ?? 0).toDouble(),
      profit: (json['profit'] ?? 0).toDouble(),
    );
  }
}
