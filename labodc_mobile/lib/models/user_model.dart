import 'package:json_annotation/json_annotation.dart';
import 'package:labodc_mobile/core/enums/app_enums.dart';

part 'user_model.g.dart';

@JsonSerializable()
class UserModel {
  final int id;
  final String email;
  final String name;
  final UserRole role;
  final AccountStatus status;
  final String? avatar;
  final DateTime createdAt;
  final DateTime? updatedAt;
  
  UserModel({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    required this.status,
    this.avatar,
    required this.createdAt,
    this.updatedAt,
  });
  
  factory UserModel.fromJson(Map<String, dynamic> json) => _$UserModelFromJson(json);
  Map<String, dynamic> toJson() => _$UserModelToJson(this);
  
  UserModel copyWith({
    int? id,
    String? email,
    String? name,
    UserRole? role,
    AccountStatus? status,
    String? avatar,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      role: role ?? this.role,
      status: status ?? this.status,
      avatar: avatar ?? this.avatar,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

@JsonSerializable()
class EnterpriseModel {
  final int id;
  final int userId;
  final String companyName;
  final String taxCode;
  final String address;
  final String representative;
  final String phone;
  final String industry;
  final String? logoUrl;
  final bool verified;
  final DateTime createdAt;
  
  EnterpriseModel({
    required this.id,
    required this.userId,
    required this.companyName,
    required this.taxCode,
    required this.address,
    required this.representative,
    required this.phone,
    required this.industry,
    this.logoUrl,
    required this.verified,
    required this.createdAt,
  });
  
  factory EnterpriseModel.fromJson(Map<String, dynamic> json) => _$EnterpriseModelFromJson(json);
  Map<String, dynamic> toJson() => _$EnterpriseModelToJson(this);
}

@JsonSerializable()
class TalentModel {
  final int id;
  final int userId;
  final String fullName;
  final String studentId;
  final String faculty;
  final int yearOfStudy;
  final String phone;
  final String? avatarUrl;
  final List<String>? skills;
  final List<String>? certifications;
  final String? portfolioUrl;
  final String? cvUrl;
  final DateTime createdAt;
  
  TalentModel({
    required this.id,
    required this.userId,
    required this.fullName,
    required this.studentId,
    required this.faculty,
    required this.yearOfStudy,
    required this.phone,
    this.avatarUrl,
    this.skills,
    this.certifications,
    this.portfolioUrl,
    this.cvUrl,
    required this.createdAt,
  });
  
  factory TalentModel.fromJson(Map<String, dynamic> json) => _$TalentModelFromJson(json);
  Map<String, dynamic> toJson() => _$TalentModelToJson(this);
}

@JsonSerializable()
class MentorModel {
  final int id;
  final int userId;
  final String fullName;
  final String expertise;
  final int yearsOfExperience;
  final String? company;
  final String? bio;
  final String? linkedinUrl;
  final DateTime createdAt;
  
  MentorModel({
    required this.id,
    required this.userId,
    required this.fullName,
    required this.expertise,
    required this.yearsOfExperience,
    this.company,
    this.bio,
    this.linkedinUrl,
    required this.createdAt,
  });
  
  factory MentorModel.fromJson(Map<String, dynamic> json) => _$MentorModelFromJson(json);
  Map<String, dynamic> toJson() => _$MentorModelToJson(this);
}
