// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserModel _$UserModelFromJson(Map<String, dynamic> json) => UserModel(
  id: (json['id'] as num).toInt(),
  email: json['email'] as String,
  name: json['name'] as String,
  role: $enumDecode(_$UserRoleEnumMap, json['role']),
  status: $enumDecode(_$AccountStatusEnumMap, json['status']),
  avatar: json['avatar'] as String?,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$UserModelToJson(UserModel instance) => <String, dynamic>{
  'id': instance.id,
  'email': instance.email,
  'name': instance.name,
  'role': _$UserRoleEnumMap[instance.role]!,
  'status': _$AccountStatusEnumMap[instance.status]!,
  'avatar': instance.avatar,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt?.toIso8601String(),
};

const _$UserRoleEnumMap = {
  UserRole.systemAdmin: 'systemAdmin',
  UserRole.labAdmin: 'labAdmin',
  UserRole.enterprise: 'enterprise',
  UserRole.talent: 'talent',
  UserRole.talentLeader: 'talentLeader',
  UserRole.mentor: 'mentor',
};

const _$AccountStatusEnumMap = {
  AccountStatus.pending: 'pending',
  AccountStatus.active: 'active',
  AccountStatus.inactive: 'inactive',
  AccountStatus.locked: 'locked',
};

EnterpriseModel _$EnterpriseModelFromJson(Map<String, dynamic> json) =>
    EnterpriseModel(
      id: (json['id'] as num).toInt(),
      userId: (json['userId'] as num).toInt(),
      companyName: json['companyName'] as String,
      taxCode: json['taxCode'] as String,
      address: json['address'] as String,
      representative: json['representative'] as String,
      phone: json['phone'] as String,
      industry: json['industry'] as String,
      logoUrl: json['logoUrl'] as String?,
      verified: json['verified'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$EnterpriseModelToJson(EnterpriseModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'companyName': instance.companyName,
      'taxCode': instance.taxCode,
      'address': instance.address,
      'representative': instance.representative,
      'phone': instance.phone,
      'industry': instance.industry,
      'logoUrl': instance.logoUrl,
      'verified': instance.verified,
      'createdAt': instance.createdAt.toIso8601String(),
    };

TalentModel _$TalentModelFromJson(Map<String, dynamic> json) => TalentModel(
  id: (json['id'] as num).toInt(),
  userId: (json['userId'] as num).toInt(),
  fullName: json['fullName'] as String,
  studentId: json['studentId'] as String,
  faculty: json['faculty'] as String,
  yearOfStudy: (json['yearOfStudy'] as num).toInt(),
  phone: json['phone'] as String,
  avatarUrl: json['avatarUrl'] as String?,
  skills: (json['skills'] as List<dynamic>?)?.map((e) => e as String).toList(),
  certifications: (json['certifications'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  portfolioUrl: json['portfolioUrl'] as String?,
  cvUrl: json['cvUrl'] as String?,
  createdAt: DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$TalentModelToJson(TalentModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'fullName': instance.fullName,
      'studentId': instance.studentId,
      'faculty': instance.faculty,
      'yearOfStudy': instance.yearOfStudy,
      'phone': instance.phone,
      'avatarUrl': instance.avatarUrl,
      'skills': instance.skills,
      'certifications': instance.certifications,
      'portfolioUrl': instance.portfolioUrl,
      'cvUrl': instance.cvUrl,
      'createdAt': instance.createdAt.toIso8601String(),
    };

MentorModel _$MentorModelFromJson(Map<String, dynamic> json) => MentorModel(
  id: (json['id'] as num).toInt(),
  userId: (json['userId'] as num).toInt(),
  fullName: json['fullName'] as String,
  expertise: json['expertise'] as String,
  yearsOfExperience: (json['yearsOfExperience'] as num).toInt(),
  company: json['company'] as String?,
  bio: json['bio'] as String?,
  linkedinUrl: json['linkedinUrl'] as String?,
  createdAt: DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$MentorModelToJson(MentorModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'fullName': instance.fullName,
      'expertise': instance.expertise,
      'yearsOfExperience': instance.yearsOfExperience,
      'company': instance.company,
      'bio': instance.bio,
      'linkedinUrl': instance.linkedinUrl,
      'createdAt': instance.createdAt.toIso8601String(),
    };
