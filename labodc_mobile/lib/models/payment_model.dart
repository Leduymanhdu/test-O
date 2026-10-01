import 'package:json_annotation/json_annotation.dart';
import 'package:labodc_mobile/core/enums/app_enums.dart';

part 'payment_model.g.dart';

@JsonSerializable()
class PaymentModel {
  final int id;
  final int projectId;
  final int enterpriseId;
  final double amount;
  final PaymentStatus status;
  final String paymentMethod;
  final String? transactionId;
  final double teamFund;
  final double mentorFund;
  final double labFund;
  final DateTime? paidAt;
  final DateTime createdAt;
  
  PaymentModel({
    required this.id,
    required this.projectId,
    required this.enterpriseId,
    required this.amount,
    required this.status,
    required this.paymentMethod,
    this.transactionId,
    required this.teamFund,
    required this.mentorFund,
    required this.labFund,
    this.paidAt,
    required this.createdAt,
  });
  
  factory PaymentModel.fromJson(Map<String, dynamic> json) => _$PaymentModelFromJson(json);
  Map<String, dynamic> toJson() => _$PaymentModelToJson(this);
}

@JsonSerializable()
class FundDistributionModel {
  final int id;
  final int projectId;
  final int talentId;
  final double amount;
  final String distributedBy; // talent_leader, lab_admin
  final String status; // pending, completed
  final DateTime? disbursedAt;
  final DateTime createdAt;
  
  FundDistributionModel({
    required this.id,
    required this.projectId,
    required this.talentId,
    required this.amount,
    required this.distributedBy,
    required this.status,
    this.disbursedAt,
    required this.createdAt,
  });
  
  factory FundDistributionModel.fromJson(Map<String, dynamic> json) => 
      _$FundDistributionModelFromJson(json);
  Map<String, dynamic> toJson() => _$FundDistributionModelToJson(this);
}
