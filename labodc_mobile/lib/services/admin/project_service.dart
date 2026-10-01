import 'package:dio/dio.dart';
import 'package:labodc_mobile/services/api_service.dart';
import 'package:logger/logger.dart';

/// Project Management Service for Lab Admin
class ProjectAdminService {
  final ApiService _api = ApiService();
  final _logger = Logger();

  /// Get project statistics
  Future<Map<String, int>> getStats() async {
    try {
      _logger.i('📊 Loading project stats...');
      final response = await _api.get('/projects/stats');
      
      final data = response.data['data'] as Map<String, dynamic>;
      _logger.i('✅ Project stats loaded');
      
      return data.map((key, value) => MapEntry(key, value as int));
    } catch (e) {
      _logger.e('❌ Error loading project stats', error: e);
      rethrow;
    }
  }

  /// Get list of projects for management
  Future<List<ProjectItem>> getProjects(Map<String, dynamic> params) async {
    try {
      _logger.i('📋 Loading projects with params: $params');
      final response = await _api.get('/projects/management', queryParameters: params);
      
      final data = response.data['data'] as List;
      final projects = data.map((json) => ProjectItem.fromJson(json)).toList();
      
      _logger.i('✅ Loaded ${projects.length} projects');
      return projects;
    } catch (e) {
      _logger.e('❌ Error loading projects', error: e);
      rethrow;
    }
  }

  /// Get project by ID
  Future<ProjectDetail> getProjectById(int id) async {
    try {
      _logger.i('📋 Loading project detail: $id');
      final response = await _api.get('/projects/$id');
      
      final data = response.data['data'];
      _logger.i('✅ Project detail loaded');
      
      return ProjectDetail.fromJson(data);
    } catch (e) {
      _logger.e('❌ Error loading project detail', error: e);
      rethrow;
    }
  }

  /// Get available mentors
  Future<List<Mentor>> getMentors() async {
    try {
      _logger.i('👨‍🏫 Loading mentors...');
      final response = await _api.get('/mentors/available');
      
      final data = response.data['data'] as List;
      final mentors = data.map((json) => Mentor.fromJson(json)).toList();
      
      _logger.i('✅ Loaded ${mentors.length} mentors');
      return mentors;
    } catch (e) {
      _logger.e('❌ Error loading mentors', error: e);
      rethrow;
    }
  }

  /// Validate/Approve project
  Future<void> validateProject(
    int id, {
    String? note,
    int? adjustedStudents,
    String? adjustedDuration,
  }) async {
    try {
      _logger.i('✅ Validating project: $id');
      final data = <String, dynamic>{};
      if (note != null) data['note'] = note;
      if (adjustedStudents != null) data['adjustedStudents'] = adjustedStudents;
      if (adjustedDuration != null) data['adjustedDuration'] = adjustedDuration;
      
      await _api.put('/projects/$id/validate', data: data);
      _logger.i('✅ Project validated successfully');
    } catch (e) {
      _logger.e('❌ Error validating project', error: e);
      rethrow;
    }
  }

  /// Reject project
  Future<void> rejectProject(
    int id, {
    required String reason,
    String? details,
  }) async {
    try {
      _logger.i('❌ Rejecting project: $id');
      await _api.put('/projects/$id/reject', data: {
        'reason': reason,
        'details': details,
      });
      _logger.i('✅ Project rejected successfully');
    } catch (e) {
      _logger.e('❌ Error rejecting project', error: e);
      rethrow;
    }
  }

  /// Assign mentor to project
  Future<void> assignMentor(int projectId, int mentorId, String message) async {
    try {
      _logger.i('👨‍🏫 Assigning mentor $mentorId to project $projectId');
      await _api.post('/projects/$projectId/assign-mentor', data: {
        'mentorId': mentorId,
        'message': message,
      });
      _logger.i('✅ Mentor assigned successfully');
    } catch (e) {
      _logger.e('❌ Error assigning mentor', error: e);
      rethrow;
    }
  }
}

// ============= MODELS =============

class ProjectItem {
  final int id;
  final int enterpriseId;
  final String title;
  final String? description;
  final String status;
  final String validated;
  final DateTime? validatedAt;
  final double budget;
  final int numberOfStudents;
  final int currentMembersCount;
  final int progressPercentage;
  final String startDate;
  final String endDate;
  final DateTime createdAt;

  ProjectItem({
    required this.id,
    required this.enterpriseId,
    required this.title,
    this.description,
    required this.status,
    required this.validated,
    this.validatedAt,
    required this.budget,
    required this.numberOfStudents,
    required this.currentMembersCount,
    required this.progressPercentage,
    required this.startDate,
    required this.endDate,
    required this.createdAt,
  });

  // For UI display
  String? get enterpriseName => null; // Backend doesn't return this
  int get requiredStudents => numberOfStudents;
  String get duration => '$startDate đến $endDate';
  DateTime? get submittedAt => createdAt;

  factory ProjectItem.fromJson(Map<String, dynamic> json) {
    return ProjectItem(
      id: json['id'] ?? 0,
      enterpriseId: json['enterpriseId'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'],
      status: json['status'] ?? '',
      validated: json['validated'] ?? 'pending',
      validatedAt: json['validatedAt'] != null ? DateTime.parse(json['validatedAt']) : null,
      budget: (json['budget'] ?? 0).toDouble(),
      numberOfStudents: json['numberOfStudents'] ?? 0,
      currentMembersCount: json['currentMembersCount'] ?? 0,
      progressPercentage: json['progressPercentage'] ?? 0,
      startDate: json['startDate'] ?? '',
      endDate: json['endDate'] ?? '',
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
    );
  }
}

class ProjectDetail {
  final int id;
  final String title;
  final String? description;
  final String? objectives;
  final String? technicalRequirements;
  final int requiredStudents;
  final String duration;
  final double budget;
  final String status;
  final String? validated;
  final DateTime? submittedAt;
  final DateTime? validatedAt;
  final String? validatedBy;
  final String? rejectionReason;
  final EnterpriseInfo? enterprise;
  final MentorInfo? mentor;
  final List<String>? requiredSkills;
  final List<ProjectDocument>? documents;

  ProjectDetail({
    required this.id,
    required this.title,
    this.description,
    this.objectives,
    this.technicalRequirements,
    required this.requiredStudents,
    required this.duration,
    required this.budget,
    required this.status,
    this.validated,
    this.submittedAt,
    this.validatedAt,
    this.validatedBy,
    this.rejectionReason,
    this.enterprise,
    this.mentor,
    this.requiredSkills,
    this.documents,
  });

  factory ProjectDetail.fromJson(Map<String, dynamic> json) {
    return ProjectDetail(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'],
      objectives: json['objectives'],
      technicalRequirements: json['technicalRequirements'],
      requiredStudents: json['requiredStudents'] ?? 0,
      duration: json['duration'] ?? '',
      budget: (json['budget'] ?? 0).toDouble(),
      status: json['status'] ?? '',
      validated: json['validated'],
      submittedAt: json['submittedAt'] != null ? DateTime.parse(json['submittedAt']) : null,
      validatedAt: json['validatedAt'] != null ? DateTime.parse(json['validatedAt']) : null,
      validatedBy: json['validatedBy'],
      rejectionReason: json['rejectionReason'],
      enterprise: json['enterprise'] != null ? EnterpriseInfo.fromJson(json['enterprise']) : null,
      mentor: json['mentor'] != null ? MentorInfo.fromJson(json['mentor']) : null,
      requiredSkills: json['requiredSkills'] != null
          ? List<String>.from(json['requiredSkills'])
          : null,
      documents: json['documents'] != null
          ? (json['documents'] as List).map((d) => ProjectDocument.fromJson(d)).toList()
          : null,
    );
  }
}

class EnterpriseInfo {
  final int id;
  final String name;
  final String? representative;
  final String? email;
  final String? phone;

  EnterpriseInfo({
    required this.id,
    required this.name,
    this.representative,
    this.email,
    this.phone,
  });

  factory EnterpriseInfo.fromJson(Map<String, dynamic> json) {
    return EnterpriseInfo(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      representative: json['representative'],
      email: json['email'],
      phone: json['phone'],
    );
  }
}

class MentorInfo {
  final int id;
  final String name;
  final String? email;
  final String? expertise;

  MentorInfo({
    required this.id,
    required this.name,
    this.email,
    this.expertise,
  });

  factory MentorInfo.fromJson(Map<String, dynamic> json) {
    return MentorInfo(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'],
      expertise: json['expertise'],
    );
  }
}

class Mentor {
  final int id;
  final String name;
  final String? email;
  final String? expertise;
  final int currentProjects;
  final int maxProjects;
  final bool available;

  Mentor({
    required this.id,
    required this.name,
    this.email,
    this.expertise,
    required this.currentProjects,
    required this.maxProjects,
    required this.available,
  });

  factory Mentor.fromJson(Map<String, dynamic> json) {
    return Mentor(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'],
      expertise: json['expertise'],
      currentProjects: json['currentProjects'] ?? 0,
      maxProjects: json['maxProjects'] ?? 0,
      available: json['available'] ?? false,
    );
  }
}

class ProjectDocument {
  final int id;
  final String name;
  final String type;
  final String url;
  final DateTime uploadedAt;

  ProjectDocument({
    required this.id,
    required this.name,
    required this.type,
    required this.url,
    required this.uploadedAt,
  });

  factory ProjectDocument.fromJson(Map<String, dynamic> json) {
    return ProjectDocument(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      type: json['type'] ?? '',
      url: json['url'] ?? '',
      uploadedAt: DateTime.parse(json['uploadedAt']),
    );
  }
}
