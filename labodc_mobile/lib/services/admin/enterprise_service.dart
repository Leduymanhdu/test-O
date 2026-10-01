import 'package:dio/dio.dart';
import 'package:labodc_mobile/services/api_service.dart';
import 'package:logger/logger.dart';

/// Enterprise Management Service for Lab Admin
class EnterpriseAdminService {
  final ApiService _api = ApiService();
  final _logger = Logger();

  /// Get enterprise statistics
  Future<EnterpriseStats> getStats() async {
    try {
      _logger.i('📊 Loading enterprise stats...');
      final response = await _api.get('/enterprises/stats');
      
      final data = response.data['data'];
      _logger.i('✅ Enterprise stats loaded');
      
      return EnterpriseStats.fromJson(data);
    } catch (e) {
      _logger.e('❌ Error loading enterprise stats', error: e);
      rethrow;
    }
  }

  /// Get list of enterprises
  Future<Map<String, dynamic>> getEnterprises(Map<String, dynamic> params) async {
    try {
      _logger.i('🏢 Loading enterprises with params: $params');
      final response = await _api.get('/enterprises/management', queryParameters: params);
      
      // Backend trả về data là array trực tiếp, không có enterprises và pagination wrapper
      final data = response.data['data'];
      if (data is! List) {
        throw Exception('Invalid response format: data is not a List');
      }
      
      final enterprises = (data as List)
          .map((json) => EnterpriseListItem.fromJson(json))
          .toList();
      
      _logger.i('✅ Loaded ${enterprises.length} enterprises');
      
      return {
        'enterprises': enterprises,
        'pagination': null, // Backend chưa implement pagination
      };
    } catch (e) {
      _logger.e('❌ Error loading enterprises', error: e);
      rethrow;
    }
  }

  /// Get enterprise by ID
  Future<EnterpriseDetail> getEnterpriseById(int id) async {
    try {
      _logger.i('🏢 Loading enterprise detail: $id');
      final response = await _api.get('/enterprises/$id');
      
      final data = response.data['data'];
      _logger.i('✅ Enterprise detail loaded');
      
      return EnterpriseDetail.fromJson(data);
    } catch (e) {
      _logger.e('❌ Error loading enterprise detail', error: e);
      rethrow;
    }
  }

  /// Verify/Approve enterprise
  Future<void> verifyEnterprise(int id) async {
    try {
      _logger.i('✅ Verifying enterprise: $id');
      await _api.put('/enterprises/$id/verify');
      _logger.i('✅ Enterprise verified successfully');
    } catch (e) {
      _logger.e('❌ Error verifying enterprise', error: e);
      rethrow;
    }
  }

  /// Reject enterprise
  Future<void> rejectEnterprise(int id, String? reason) async {
    try {
      _logger.i('❌ Rejecting enterprise: $id');
      await _api.delete('/enterprises/$id', data: {'reason': reason});
      _logger.i('✅ Enterprise rejected successfully');
    } catch (e) {
      _logger.e('❌ Error rejecting enterprise', error: e);
      rethrow;
    }
  }
}

// ============= MODELS =============

class EnterpriseStats {
  final int total;
  final int pending;
  final int verified;
  final int rejected;

  EnterpriseStats({
    required this.total,
    required this.pending,
    required this.verified,
    required this.rejected,
  });

  factory EnterpriseStats.fromJson(Map<String, dynamic> json) {
    return EnterpriseStats(
      total: json['total'] ?? 0,
      pending: json['pending'] ?? 0,
      verified: json['verified'] ?? 0,
      rejected: json['rejected'] ?? 0,
    );
  }
}

class EnterpriseListItem {
  final int id;
  final int userId;
  final String companyName;
  final String taxCode;
  final String contactEmail;
  final String contactPhone;
  final String industry;
  final String companySize;
  final String status;
  final DateTime? verifiedAt;
  final DateTime createdAt;
  final int totalProjects;
  final int activeProjects;
  final double totalBudget;

  EnterpriseListItem({
    required this.id,
    required this.userId,
    required this.companyName,
    required this.taxCode,
    required this.contactEmail,
    required this.contactPhone,
    required this.industry,
    required this.companySize,
    required this.status,
    this.verifiedAt,
    required this.createdAt,
    required this.totalProjects,
    required this.activeProjects,
    required this.totalBudget,
  });

  factory EnterpriseListItem.fromJson(Map<String, dynamic> json) {
    return EnterpriseListItem(
      id: json['id'] ?? 0,
      userId: json['userId'] ?? 0,
      companyName: json['companyName'] ?? '',
      taxCode: json['taxCode'] ?? '',
      contactEmail: json['contactEmail'] ?? '',
      contactPhone: json['contactPhone'] ?? '',
      industry: json['industry'] ?? '',
      companySize: json['companySize'] ?? '',
      status: json['status'] ?? 'PENDING',
      verifiedAt: json['verifiedAt'] != null ? DateTime.parse(json['verifiedAt']) : null,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
      totalProjects: json['totalProjects'] ?? 0,
      activeProjects: json['activeProjects'] ?? 0,
      totalBudget: (json['totalBudget'] ?? 0).toDouble(),
    );
  }
}

class EnterpriseDetail {
  final int id;
  final int userId;
  final String companyName;
  final String taxCode;
  final String? businessLicenseNumber;
  final String? address;
  final String? city;
  final String? district;
  final String? ward;
  final String? representativeName;
  final String? representativePosition;
  final String contactEmail;
  final String contactPhone;
  final String? website;
  final String industry;
  final String companySize;
  final int? yearEstablished;
  final String? description;
  final String status;
  final DateTime? verifiedAt;
  final int? verifiedBy;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? rejectionReason;
  final DateTime? rejectedAt;
  final int? rejectedBy;

  EnterpriseDetail({
    required this.id,
    required this.userId,
    required this.companyName,
    required this.taxCode,
    this.businessLicenseNumber,
    this.address,
    this.city,
    this.district,
    this.ward,
    this.representativeName,
    this.representativePosition,
    required this.contactEmail,
    required this.contactPhone,
    this.website,
    required this.industry,
    required this.companySize,
    this.yearEstablished,
    this.description,
    required this.status,
    this.verifiedAt,
    this.verifiedBy,
    required this.createdAt,
    required this.updatedAt,
    this.rejectionReason,
    this.rejectedAt,
    this.rejectedBy,
  });

  factory EnterpriseDetail.fromJson(Map<String, dynamic> json) {
    return EnterpriseDetail(
      id: json['id'] ?? 0,
      userId: json['userId'] ?? 0,
      companyName: json['companyName'] ?? '',
      taxCode: json['taxCode'] ?? '',
      businessLicenseNumber: json['businessLicenseNumber'],
      address: json['address'],
      city: json['city'],
      district: json['district'],
      ward: json['ward'],
      representativeName: json['representativeName'],
      representativePosition: json['representativePosition'],
      contactEmail: json['contactEmail'] ?? '',
      contactPhone: json['contactPhone'] ?? '',
      website: json['website'],
      industry: json['industry'] ?? '',
      companySize: json['companySize'] ?? '',
      yearEstablished: json['yearEstablished'],
      description: json['description'],
      status: json['status'] ?? 'PENDING',
      verifiedAt: json['verifiedAt'] != null ? DateTime.parse(json['verifiedAt']) : null,
      verifiedBy: json['verifiedBy'],
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : DateTime.now(),
      rejectionReason: json['rejectionReason'],
      rejectedAt: json['rejectedAt'] != null ? DateTime.parse(json['rejectedAt']) : null,
      rejectedBy: json['rejectedBy'],
    );
  }
}

class EnterpriseDocument {
  final int id;
  final String name;
  final String type;
  final String url;
  final DateTime uploadedAt;

  EnterpriseDocument({
    required this.id,
    required this.name,
    required this.type,
    required this.url,
    required this.uploadedAt,
  });

  factory EnterpriseDocument.fromJson(Map<String, dynamic> json) {
    return EnterpriseDocument(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      type: json['type'] ?? '',
      url: json['url'] ?? '',
      uploadedAt: DateTime.parse(json['uploadedAt']),
    );
  }
}
