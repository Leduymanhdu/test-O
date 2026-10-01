import 'package:json_annotation/json_annotation.dart';
import 'package:labodc_mobile/core/enums/app_enums.dart';

part 'project_model.g.dart';

@JsonSerializable()
class ProjectModel {
  final int id;
  final String name;
  final String description;
  final String objective;
  final List<String> technologies;
  final DateTime startDate;
  final DateTime endDate;
  final double budget;
  final int requiredTalents;
  final List<String> requiredSkills;
  final ProjectStatus status;
  final int enterpriseId;
  final int? mentorId;
  final List<String>? attachments;
  final DateTime createdAt;
  final DateTime? updatedAt;
  
  ProjectModel({
    required this.id,
    required this.name,
    required this.description,
    required this.objective,
    required this.technologies,
    required this.startDate,
    required this.endDate,
    required this.budget,
    required this.requiredTalents,
    required this.requiredSkills,
    required this.status,
    required this.enterpriseId,
    this.mentorId,
    this.attachments,
    required this.createdAt,
    this.updatedAt,
  });
  
  factory ProjectModel.fromJson(Map<String, dynamic> json) => _$ProjectModelFromJson(json);
  Map<String, dynamic> toJson() => _$ProjectModelToJson(this);
  
  // Fund distribution calculation
  double get teamFund => budget * 0.70;
  double get mentorFund => budget * 0.20;
  double get labFund => budget * 0.10;
}

@JsonSerializable()
class ProjectApplicationModel {
  final int id;
  final int projectId;
  final int talentId;
  final String motivationLetter;
  final String status; // pending, approved, rejected
  final DateTime appliedAt;
  final DateTime? respondedAt;
  
  ProjectApplicationModel({
    required this.id,
    required this.projectId,
    required this.talentId,
    required this.motivationLetter,
    required this.status,
    required this.appliedAt,
    this.respondedAt,
  });
  
  factory ProjectApplicationModel.fromJson(Map<String, dynamic> json) => 
      _$ProjectApplicationModelFromJson(json);
  Map<String, dynamic> toJson() => _$ProjectApplicationModelToJson(this);
}

@JsonSerializable()
class ProjectTeamModel {
  final int id;
  final int projectId;
  final int talentId;
  final String role; // member, leader
  final DateTime joinedAt;
  
  ProjectTeamModel({
    required this.id,
    required this.projectId,
    required this.talentId,
    required this.role,
    required this.joinedAt,
  });
  
  factory ProjectTeamModel.fromJson(Map<String, dynamic> json) => 
      _$ProjectTeamModelFromJson(json);
  Map<String, dynamic> toJson() => _$ProjectTeamModelToJson(this);
}
