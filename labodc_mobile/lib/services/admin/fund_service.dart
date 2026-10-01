import 'package:dio/dio.dart';
import 'package:labodc_mobile/services/api_service.dart';
import 'package:logger/logger.dart';

/// Fund Allocation Service for Lab Admin
class FundAdminService {
  final ApiService _api = ApiService();
  final _logger = Logger();

  /// Get list of fund allocations
  Future<List<FundAllocation>> getAllocations({String? status}) async {
    try {
      _logger.i('💰 Loading fund allocations: status=$status');
      final params = status != null ? {'status': status} : null;
      final response = await _api.get('/lab-admin/fund-allocation/allocations', queryParameters: params);
      
      final data = response.data['data'] as List;
      final allocations = data.map((json) => FundAllocation.fromJson(json)).toList();
      
      _logger.i('✅ Loaded ${allocations.length} fund allocations');
      return allocations;
    } catch (e) {
      _logger.e('❌ Error loading fund allocations', error: e);
      rethrow;
    }
  }

  /// Get fund allocation detail by project
  Future<FundAllocationDetail> getAllocationByProject(int projectId) async {
    try {
      _logger.i('💰 Loading fund allocation detail: project=$projectId');
      final response = await _api.get('/lab-admin/fund-allocation/projects/$projectId');
      
      final data = response.data['data'];
      _logger.i('✅ Fund allocation detail loaded');
      
      return FundAllocationDetail.fromJson(data);
    } catch (e) {
      _logger.e('❌ Error loading fund allocation detail', error: e);
      rethrow;
    }
  }
}

// ============= MODELS =============

class FundAllocation {
  final int projectId;
  final String projectTitle;
  final String enterpriseName;
  final Payment payment;
  final Allocation allocation;
  final String status;

  FundAllocation({
    required this.projectId,
    required this.projectTitle,
    required this.enterpriseName,
    required this.payment,
    required this.allocation,
    required this.status,
  });

  factory FundAllocation.fromJson(Map<String, dynamic> json) {
    return FundAllocation(
      projectId: json['projectId'] ?? 0,
      projectTitle: json['projectTitle'] ?? '',
      enterpriseName: json['enterpriseName'] ?? '',
      payment: Payment.fromJson(json['payment'] ?? {}),
      allocation: Allocation.fromJson(json['allocation'] ?? {}),
      status: json['status'] ?? '',
    );
  }
}

class Payment {
  final int id;
  final double amount;
  final String status;
  final DateTime? paidAt;

  Payment({
    required this.id,
    required this.amount,
    required this.status,
    this.paidAt,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: json['id'] ?? 0,
      amount: (json['amount'] ?? 0).toDouble(),
      status: json['status'] ?? '',
      paidAt: json['paidAt'] != null ? DateTime.parse(json['paidAt']) : null,
    );
  }
}

class Allocation {
  final double total;
  final AllocationPart team;
  final AllocationPart mentor;
  final AllocationPart lab;

  Allocation({
    required this.total,
    required this.team,
    required this.mentor,
    required this.lab,
  });

  factory Allocation.fromJson(Map<String, dynamic> json) {
    return Allocation(
      total: (json['total'] ?? 0).toDouble(),
      team: AllocationPart.fromJson(json['team'] ?? {}),
      mentor: AllocationPart.fromJson(json['mentor'] ?? {}),
      lab: AllocationPart.fromJson(json['lab'] ?? {}),
    );
  }
}

class AllocationPart {
  final double amount;
  final int percentage;
  final String status;

  AllocationPart({
    required this.amount,
    required this.percentage,
    required this.status,
  });

  factory AllocationPart.fromJson(Map<String, dynamic> json) {
    return AllocationPart(
      amount: (json['amount'] ?? 0).toDouble(),
      percentage: json['percentage'] ?? 0,
      status: json['status'] ?? '',
    );
  }
}

class FundAllocationDetail extends FundAllocation {
  FundAllocationDetail({
    required super.projectId,
    required super.projectTitle,
    required super.enterpriseName,
    required super.payment,
    required super.allocation,
    required super.status,
  });

  factory FundAllocationDetail.fromJson(Map<String, dynamic> json) {
    return FundAllocationDetail(
      projectId: json['projectId'] ?? 0,
      projectTitle: json['projectTitle'] ?? '',
      enterpriseName: json['enterpriseName'] ?? '',
      payment: Payment.fromJson(json['payment'] ?? {}),
      allocation: Allocation.fromJson(json['allocation'] ?? {}),
      status: json['status'] ?? '',
    );
  }
}
