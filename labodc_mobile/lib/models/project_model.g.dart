// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'project_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProjectModel _$ProjectModelFromJson(Map<String, dynamic> json) => ProjectModel(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String,
  description: json['description'] as String,
  objective: json['objective'] as String,
  technologies: (json['technologies'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  startDate: DateTime.parse(json['startDate'] as String),
  endDate: DateTime.parse(json['endDate'] as String),
  budget: (json['budget'] as num).toDouble(),
  requiredTalents: (json['requiredTalents'] as num).toInt(),
  requiredSkills: (json['requiredSkills'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  status: $enumDecode(_$ProjectStatusEnumMap, json['status']),
  enterpriseId: (json['enterpriseId'] as num).toInt(),
  mentorId: (json['mentorId'] as num?)?.toInt(),
  attachments: (json['attachments'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$ProjectModelToJson(ProjectModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'objective': instance.objective,
      'technologies': instance.technologies,
      'startDate': instance.startDate.toIso8601String(),
      'endDate': instance.endDate.toIso8601String(),
      'budget': instance.budget,
      'requiredTalents': instance.requiredTalents,
      'requiredSkills': instance.requiredSkills,
      'status': _$ProjectStatusEnumMap[instance.status]!,
      'enterpriseId': instance.enterpriseId,
      'mentorId': instance.mentorId,
      'attachments': instance.attachments,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };

const _$ProjectStatusEnumMap = {
  ProjectStatus.draft: 'draft',
  ProjectStatus.pending: 'pending',
  ProjectStatus.approved: 'approved',
  ProjectStatus.rejected: 'rejected',
  ProjectStatus.inProgress: 'inProgress',
  ProjectStatus.completed: 'completed',
  ProjectStatus.cancelled: 'cancelled',
};

ProjectApplicationModel _$ProjectApplicationModelFromJson(
  Map<String, dynamic> json,
) => ProjectApplicationModel(
  id: (json['id'] as num).toInt(),
  projectId: (json['projectId'] as num).toInt(),
  talentId: (json['talentId'] as num).toInt(),
  motivationLetter: json['motivationLetter'] as String,
  status: json['status'] as String,
  appliedAt: DateTime.parse(json['appliedAt'] as String),
  respondedAt: json['respondedAt'] == null
      ? null
      : DateTime.parse(json['respondedAt'] as String),
);

Map<String, dynamic> _$ProjectApplicationModelToJson(
  ProjectApplicationModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'projectId': instance.projectId,
  'talentId': instance.talentId,
  'motivationLetter': instance.motivationLetter,
  'status': instance.status,
  'appliedAt': instance.appliedAt.toIso8601String(),
  'respondedAt': instance.respondedAt?.toIso8601String(),
};

ProjectTeamModel _$ProjectTeamModelFromJson(Map<String, dynamic> json) =>
    ProjectTeamModel(
      id: (json['id'] as num).toInt(),
      projectId: (json['projectId'] as num).toInt(),
      talentId: (json['talentId'] as num).toInt(),
      role: json['role'] as String,
      joinedAt: DateTime.parse(json['joinedAt'] as String),
    );

Map<String, dynamic> _$ProjectTeamModelToJson(ProjectTeamModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'projectId': instance.projectId,
      'talentId': instance.talentId,
      'role': instance.role,
      'joinedAt': instance.joinedAt.toIso8601String(),
    };
