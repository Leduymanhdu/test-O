import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:labodc_mobile/core/theme/app_colors.dart';
import 'package:labodc_mobile/core/theme/app_text_styles.dart';
import 'package:labodc_mobile/providers/admin_provider.dart';
import 'package:labodc_mobile/services/admin/enterprise_service.dart' as enterprise_svc;
import 'package:labodc_mobile/widgets/common_widgets.dart';

class EnterpriseManagementScreen extends StatefulWidget {
  const EnterpriseManagementScreen({super.key});

  @override
  State<EnterpriseManagementScreen> createState() => _EnterpriseManagementScreenState();
}

class _EnterpriseManagementScreenState extends State<EnterpriseManagementScreen> {
  final TextEditingController _searchController = TextEditingController();
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().loadEnterprises();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý Doanh nghiệp'),
      ),
      body: Consumer<AdminProvider>(
        builder: (context, adminProvider, _) {
          return Column(
            children: [
              // Search Bar
              Padding(
                padding: const EdgeInsets.all(12),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Tìm kiếm doanh nghiệp...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              adminProvider.setEnterpriseSearchText('');
                              adminProvider.searchEnterprises();
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: AppColors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onChanged: (value) {
                    adminProvider.setEnterpriseSearchText(value);
                  },
                  onSubmitted: (_) {
                    adminProvider.searchEnterprises();
                  },
                ),
              ),
            
              
              // Tab Bar
              _buildTabBar(adminProvider),
              const Divider(height: 1),
              
              // Content
              Expanded(
                child: _buildContent(adminProvider),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatItem(String label, int value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Text(
              '$value',
              style: AppTextStyles.heading3.copyWith(color: color),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: AppTextStyles.caption,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildTabBar(AdminProvider adminProvider) {
    return Container(
      color: AppColors.white,
      child: Row(
        children: [
          _buildTab('Tất cả', 'ALL', adminProvider),
          _buildTab('Chờ duyệt', 'PENDING', adminProvider),
          _buildTab('Đã duyệt', 'APPROVED', adminProvider),
          _buildTab('Từ chối', 'REJECTED', adminProvider),
        ],
      ),
    );
  }
  
  Widget _buildTab(String label, String value, AdminProvider adminProvider) {
    final isSelected = adminProvider.enterpriseStatusFilter == value;
    return Expanded(
      child: InkWell(
        onTap: () => adminProvider.setEnterpriseStatusFilter(value),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isSelected ? AppColors.primary : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: AppTextStyles.subtitle2.copyWith(
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildContent(AdminProvider adminProvider) {
    if (adminProvider.loadingEnterprises) {
      return const Center(child: CircularProgressIndicator());
    }

    if (adminProvider.enterpriseError != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: AppColors.error),
            const SizedBox(height: 16),
            Text('Lỗi tải dữ liệu', style: AppTextStyles.subtitle1),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                adminProvider.enterpriseError!,
                style: AppTextStyles.caption,
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => adminProvider.loadEnterprises(),
              icon: const Icon(Icons.refresh),
              label: const Text('Thử lại'),
            ),
          ],
        ),
      );
    }

    if (adminProvider.enterprises.isEmpty) {
      return const Center(
        child: EmptyState(
          icon: Icons.business,
          message: 'Không có doanh nghiệp nào',
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => adminProvider.loadEnterprises(),
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: adminProvider.enterprises.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final enterprise = adminProvider.enterprises[index];
          return _buildEnterpriseCard(enterprise);
        },
      ),
    );
  }
  
  Widget _buildEnterpriseCard(enterprise_svc.EnterpriseListItem enterprise) {
    return AppCard(
      onTap: () => _showEnterpriseDetail(enterprise.id),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.business, color: AppColors.primary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(enterprise.companyName, style: AppTextStyles.subtitle1),
                      const SizedBox(height: 4),
                      Text(
                        '${enterprise.industry} • ${enterprise.companySize}',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                _buildStatusBadge(enterprise.status),
              ],
            ),
            
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 8),
            
            // Info
            _buildInfoRow(Icons.numbers, 'MST', enterprise.taxCode),
            _buildInfoRow(Icons.email, 'Email', enterprise.contactEmail),
            _buildInfoRow(Icons.phone, 'ĐT', enterprise.contactPhone),
            
            const SizedBox(height: 8),
            
            // Footer
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Đăng ký: ${_formatDate(enterprise.createdAt)}',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                if (enterprise.totalProjects > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.info.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '${enterprise.totalProjects} dự án',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.info,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    String label;
    
    switch (status) {
      case 'PENDING':
        color = AppColors.warning;
        label = 'Chờ duyệt';
        break;
      case 'VERIFIED':
      case 'APPROVED':
        color = AppColors.success;
        label = 'Đã duyệt';
        break;
      case 'REJECTED':
        color = AppColors.error;
        label = 'Từ chối';
        break;
      default:
        color = AppColors.textSecondary;
        label = status;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: AppTextStyles.caption.copyWith(
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
  
  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.textSecondary),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: AppTextStyles.body2.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          Expanded(
            child: Text(value, style: AppTextStyles.body2),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  Future<void> _showEnterpriseDetail(int id) async {
    final adminProvider = context.read<AdminProvider>();
    
    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );
    
    try {
      await adminProvider.loadEnterpriseDetail(id);
      if (!mounted) return;
      
      Navigator.pop(context); // Close loading
      
      final enterprise = adminProvider.selectedEnterprise;
      if (enterprise == null) {
        throw Exception('Enterprise data not loaded');
      }
      
      // Show detail
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (context) => DraggableScrollableSheet(
          initialChildSize: 0.9,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return _buildDetailSheet(enterprise, scrollController);
          },
        ),
      );
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context); // Close loading
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Widget _buildDetailSheet(enterprise_svc.EnterpriseDetail enterprise, ScrollController scrollController) {
    // Debug log
    print('🔍 Building detail sheet for: ${enterprise.companyName}');
    print('   ID: ${enterprise.id}, Status: ${enterprise.status}');
    
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.divider,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: Text('Chi tiết Doanh nghiệp', style: AppTextStyles.heading3),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          
          const Divider(),
          
          // Content
          Expanded(
            child: SingleChildScrollView(
              controller: scrollController,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Thông tin cơ bản', style: AppTextStyles.subtitle1),
                  const SizedBox(height: 12),
                  _buildDetailItem('Tên công ty', enterprise.companyName),
                  _buildDetailItem('Mã số thuế', enterprise.taxCode),
                  if (enterprise.businessLicenseNumber != null)
                    _buildDetailItem('Số GPKD', enterprise.businessLicenseNumber!),
                  if (enterprise.representativeName != null)
                    _buildDetailItem('Người đại diện', enterprise.representativeName!),
                  if (enterprise.representativePosition != null)
                    _buildDetailItem('Chức vụ', enterprise.representativePosition!),
                  _buildDetailItem('Email', enterprise.contactEmail),
                  _buildDetailItem('Điện thoại', enterprise.contactPhone),
                  if (enterprise.website != null)
                    _buildDetailItem('Website', enterprise.website!),
                  _buildDetailItem('Ngành', enterprise.industry),
                  _buildDetailItem('Quy mô', enterprise.companySize),
                  if (enterprise.yearEstablished != null)
                    _buildDetailItem('Năm thành lập', enterprise.yearEstablished.toString()),
                  
                  const SizedBox(height: 16),
                  
                  if (enterprise.address != null) ...[
                    Text('Địa chỉ', style: AppTextStyles.subtitle1),
                    const SizedBox(height: 8),
                    Text(
                      [
                        enterprise.address,
                        if (enterprise.ward != null) enterprise.ward,
                        if (enterprise.district != null) enterprise.district,
                        if (enterprise.city != null) enterprise.city,
                      ].where((e) => e != null).join(', '),
                      style: AppTextStyles.body2,
                    ),
                    const SizedBox(height: 16),
                  ],
                  
                  if (enterprise.description != null) ...[
                    Text('Mô tả', style: AppTextStyles.subtitle1),
                    const SizedBox(height: 8),
                    Text(enterprise.description!, style: AppTextStyles.body2),
                    const SizedBox(height: 16),
                  ],
                  
                  // Status
                  Text('Trạng thái', style: AppTextStyles.subtitle1),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Text('Trạng thái: ', style: AppTextStyles.body2),
                      _buildStatusBadge(enterprise.status),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Đăng ký: ${_formatDate(enterprise.createdAt)}',
                    style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                  ),
                  if (enterprise.verifiedAt != null)
                    Text(
                      'Duyệt: ${_formatDate(enterprise.verifiedAt!)}',
                      style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                    ),
                  if (enterprise.rejectionReason != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Lý do từ chối: ${enterprise.rejectionReason}',
                      style: AppTextStyles.body2.copyWith(color: AppColors.error),
                    ),
                  ],
                  
                  const SizedBox(height: 24),
                  
                  // Actions
                  if (enterprise.status == 'PENDING')
                    _buildActions(enterprise.id),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: AppTextStyles.body2.copyWith(color: AppColors.textSecondary),
            ),
          ),
          Expanded(
            child: Text(value, style: AppTextStyles.body2),
          ),
        ],
      ),
    );
  }

  Widget _buildActions(int id) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => _handleVerify(id),
            icon: const Icon(Icons.check_circle),
            label: const Text('Phê duyệt'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.success,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => _handleReject(id),
            icon: const Icon(Icons.cancel),
            label: const Text('Từ chối'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.error,
              side: const BorderSide(color: AppColors.error),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _handleVerify(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận'),
        content: const Text('Phê duyệt doanh nghiệp này?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Phê duyệt'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await context.read<AdminProvider>().verifyEnterprise(id);
      if (!mounted) return;
      
      Navigator.pop(context); // Close sheet
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Phê duyệt thành công'),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _handleReject(int id) async {
    final controller = TextEditingController();
    
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Từ chối'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Nhập lý do:'),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                hintText: 'Lý do từ chối...',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Từ chối'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await context.read<AdminProvider>().rejectEnterprise(
        id,
        controller.text.trim().isEmpty ? null : controller.text.trim(),
      );
      if (!mounted) return;
      
      Navigator.pop(context); // Close sheet
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đã từ chối'),
          backgroundColor: AppColors.info,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      controller.dispose();
    }
  }
}
