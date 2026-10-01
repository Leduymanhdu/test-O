import 'package:json_annotation/json_annotation.dart';
import 'package:labodc_mobile/core/enums/app_enums.dart';

part 'task_model.g.dart';

@JsonSerializable()
class TaskModel {
  final int id;
  final int projectId;
  final String title;
  final String description;
  final TaskStatus status;
  final int? assignedToId;
  final DateTime? dueDate;
  final int? estimatedHours;
  final int? actualHours;
  final String? notes;
  final DateTime createdAt;
  final DateTime? updatedAt;
  
  TaskModel({
    required this.id,
    required this.projectId,
    required this.title,
    required this.description,
    required this.status,
    this.assignedToId,
    this.dueDate,
    this.estimatedHours,
    this.actualHours,
    this.notes,
    required this.createdAt,
    this.updatedAt,
  });
  
  factory TaskModel.fromJson(Map<String, dynamic> json) => _$TaskModelFromJson(json);
  Map<String, dynamic> toJson() => _$TaskModelToJson(this);
  
  bool get isOverdue {
    if (dueDate == null) return false;
    return DateTime.now().isAfter(dueDate!) && status != TaskStatus.done;
  }
}

@JsonSerializable()
class TaskCommentModel {
  final int id;
  final int taskId;
  final int userId;
  final String content;
  final DateTime createdAt;
  
  TaskCommentModel({
    required this.id,
    required this.taskId,
    required this.userId,
    required this.content,
    required this.createdAt,
  });
  
  factory TaskCommentModel.fromJson(Map<String, dynamic> json) => 
      _$TaskCommentModelFromJson(json);
  Map<String, dynamic> toJson() => _$TaskCommentModelToJson(this);
}
