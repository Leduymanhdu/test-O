// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PaymentModel _$PaymentModelFromJson(Map<String, dynamic> json) => PaymentModel(
  id: (json['id'] as num).toInt(),
  projectId: (json['projectId'] as num).toInt(),
  enterpriseId: (json['enterpriseId'] as num).toInt(),
  amount: (json['amount'] as num).toDouble(),
  status: $enumDecode(_$PaymentStatusEnumMap, json['status']),
  paymentMethod: json['paymentMethod'] as String,
  transactionId: json['transactionId'] as String?,
  teamFund: (json['teamFund'] as num).toDouble(),
  mentorFund: (json['mentorFund'] as num).toDouble(),
  labFund: (json['labFund'] as num).toDouble(),
  paidAt: json['paidAt'] == null
      ? null
      : DateTime.parse(json['paidAt'] as String),
  createdAt: DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$PaymentModelToJson(PaymentModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'projectId': instance.projectId,
      'enterpriseId': instance.enterpriseId,
      'amount': instance.amount,
      'status': _$PaymentStatusEnumMap[instance.status]!,
      'paymentMethod': instance.paymentMethod,
      'transactionId': instance.transactionId,
      'teamFund': instance.teamFund,
      'mentorFund': instance.mentorFund,
      'labFund': instance.labFund,
      'paidAt': instance.paidAt?.toIso8601String(),
      'createdAt': instance.createdAt.toIso8601String(),
    };

const _$PaymentStatusEnumMap = {
  PaymentStatus.pending: 'pending',
  PaymentStatus.processing: 'processing',
  PaymentStatus.completed: 'completed',
  PaymentStatus.failed: 'failed',
  PaymentStatus.refunded: 'refunded',
};

FundDistributionModel _$FundDistributionModelFromJson(
  Map<String, dynamic> json,
) => FundDistributionModel(
  id: (json['id'] as num).toInt(),
  projectId: (json['projectId'] as num).toInt(),
  talentId: (json['talentId'] as num).toInt(),
  amount: (json['amount'] as num).toDouble(),
  distributedBy: json['distributedBy'] as String,
  status: json['status'] as String,
  disbursedAt: json['disbursedAt'] == null
      ? null
      : DateTime.parse(json['disbursedAt'] as String),
  createdAt: DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$FundDistributionModelToJson(
  FundDistributionModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'projectId': instance.projectId,
  'talentId': instance.talentId,
  'amount': instance.amount,
  'distributedBy': instance.distributedBy,
  'status': instance.status,
  'disbursedAt': instance.disbursedAt?.toIso8601String(),
  'createdAt': instance.createdAt.toIso8601String(),
};
