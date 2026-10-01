import 'package:labodc_mobile/core/enums/app_enums.dart';

/// Centralized mock data used while waiting for real project-service APIs.
class MockProjectData {
  static List<Map<String, dynamic>> list({ProjectStatus? status}) {
    final items = <Map<String, dynamic>>[
      {
        'id': 101,
        'name': 'Smart Logistics Dashboard',
        'description': 'Xây dựng dashboard giám sát vận hành kho thông minh.',
        'objective': 'Tối ưu hóa quy trình và trực quan hóa KPI',
        'technologies': ['Flutter', 'Spring Boot', 'PostgreSQL'],
        'startDate': DateTime(2026, 1, 15).toIso8601String(),
        'endDate': DateTime(2026, 5, 30).toIso8601String(),
        'budget': 180000000,
        'requiredTalents': 5,
        'requiredSkills': ['Flutter', 'REST API', 'UI/UX'],
        'status': _$status(ProjectStatus.inProgress),
        'enterpriseId': 11,
        'mentorId': 4,
        'attachments': ['https://example.com/brief.pdf'],
        'createdAt': DateTime(2025, 12, 20).toIso8601String(),
        'updatedAt': DateTime(2026, 1, 18).toIso8601String(),
      },
      {
        'id': 102,
        'name': 'UTH Career Portal',
        'description': 'Nền tảng kết nối doanh nghiệp với sinh viên thực tập.',
        'objective': 'Chuẩn hóa quy trình tiếp nhận & đánh giá talent',
        'technologies': ['React', 'NestJS', 'ElasticSearch'],
        'startDate': DateTime(2026, 2, 1).toIso8601String(),
        'endDate': DateTime(2026, 7, 1).toIso8601String(),
        'budget': 250000000,
        'requiredTalents': 6,
        'requiredSkills': ['React', 'Node.js', 'CI/CD'],
        'status': _$status(ProjectStatus.pending),
        'enterpriseId': 12,
        'mentorId': null,
        'attachments': null,
        'createdAt': DateTime(2026, 1, 10).toIso8601String(),
        'updatedAt': null,
      },
      {
        'id': 103,
        'name': 'AI Document Scanner',
        'description': 'Ứng dụng mobile nhận diện và phân loại chứng từ.',
        'objective': 'Tự động hóa nhập liệu kế toán',
        'technologies': ['Flutter', 'TensorFlow Lite', 'Firebase'],
        'startDate': DateTime(2025, 9, 1).toIso8601String(),
        'endDate': DateTime(2025, 12, 15).toIso8601String(),
        'budget': 120000000,
        'requiredTalents': 4,
        'requiredSkills': ['Flutter', 'ML', 'Cloud'],
        'status': _$status(ProjectStatus.completed),
        'enterpriseId': 13,
        'mentorId': 5,
        'attachments': ['https://example.com/result.pdf'],
        'createdAt': DateTime(2025, 7, 5).toIso8601String(),
        'updatedAt': DateTime(2025, 12, 20).toIso8601String(),
      },
    ];

    if (status == null) return items;
    return items.where((item) => item['status'] == _$status(status)).toList();
  }

  static List<Map<String, dynamic>> members(int projectId) {
    return <Map<String, dynamic>>[
      {
        'id': 9001,
        'projectId': projectId,
        'talentId': 201,
        'role': 'leader',
        'joinedAt': DateTime(2026, 1, 18).toIso8601String(),
      },
      {
        'id': 9002,
        'projectId': projectId,
        'talentId': 202,
        'role': 'member',
        'joinedAt': DateTime(2026, 1, 20).toIso8601String(),
      },
      {
        'id': 9003,
        'projectId': projectId,
        'talentId': 203,
        'role': 'member',
        'joinedAt': DateTime(2026, 1, 22).toIso8601String(),
      },
    ];
  }

  static String _$status(ProjectStatus status) {
    switch (status) {
      case ProjectStatus.draft:
        return 'draft';
      case ProjectStatus.pending:
        return 'pending';
      case ProjectStatus.approved:
        return 'approved';
      case ProjectStatus.rejected:
        return 'rejected';
      case ProjectStatus.inProgress:
        return 'inProgress';
      case ProjectStatus.completed:
        return 'completed';
      case ProjectStatus.cancelled:
        return 'cancelled';
    }
  }
}
