import 'package:flutter/material.dart';
import 'package:labodc_mobile/core/theme/app_colors.dart';
import 'package:labodc_mobile/core/theme/app_text_styles.dart';
import 'package:labodc_mobile/widgets/common_widgets.dart';
import 'package:labodc_mobile/widgets/app_button.dart';

class FundAllocationScreen extends StatefulWidget {
  const FundAllocationScreen({super.key});

  @override
  State<FundAllocationScreen> createState() => _FundAllocationScreenState();
}

class _FundAllocationScreenState extends State<FundAllocationScreen> {
  String _selectedTab = 'pending';
  
  // Mock data
  final List<Map<String, dynamic>> _pendingAllocations = [
    {
      'id': 301,
      'projectTitle': 'Website Quản lý Bán hàng',
      'enterprise': 'ABC Technology Co., Ltd',
      'totalBudget': 100000000,
      'allocation': {
        'team': 70000000, // 70%
        'mentor': 20000000, // 20%
        'lab': 10000000, // 10%
      },
      'mentor': 'Nguyễn Văn Mentor',
      'teamSize': 5,
      'paidAt': '2026-01-20',
      'status': 'PENDING_ALLOCATION',
    },
    {
      'id': 302,
      'projectTitle': 'Mobile App E-commerce',
      'enterprise': 'XYZ Corporation',
      'totalBudget': 150000000,
      'allocation': {
        'team': 105000000,
        'mentor': 30000000,
        'lab': 15000000,
      },
      'mentor': 'Trần Thị Mentor 2',
      'teamSize': 6,
      'paidAt': '2026-01-21',
      'status': 'PENDING_ALLOCATION',
    },
  ];
  
  final List<Map<String, dynamic>> _disbursedAllocations = [
    {
      'id': 300,
      'projectTitle': 'Hệ thống CRM',
      'totalBudget': 80000000,
      'disbursedAt': '2026-01-10',
      'status': 'DISBURSED',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Phân bổ Kinh phí'),
      ),
      body: Column(
        children: [
          // Tab Bar
          Container(
            color: AppColors.white,
            child: Row(
              children: [
                _buildTab('Chờ phân bổ', 'pending', _pendingAllocations.length),
                _buildTab('Đã giải ngân', 'disbursed', _disbursedAllocations.length),
                _buildTab('Ứng trước', 'advance', 0),
              ],
            ),
          ),
          const Divider(height: 1),
          
          // Content
          Expanded(
            child: _buildContent(),
          ),
        ],
      ),
    );
  }
  
  Widget _buildTab(String label, String value, int count) {
    final isSelected = _selectedTab == value;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _selectedTab = value),
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
          child: Column(
            children: [
              Text(
                label,
                style: AppTextStyles.subtitle2.copyWith(
                  color: isSelected ? AppColors.primary : AppColors.textSecondary,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              if (count > 0) ...[
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.error,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '$count',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildContent() {
    if (_selectedTab == 'pending' && _pendingAllocations.isNotEmpty) {
      return _buildPendingList();
    } else if (_selectedTab == 'disbursed' && _disbursedAllocations.isNotEmpty) {
      return _buildDisbursedList();
    } else {
      return const Center(
        child: EmptyState(
          icon: Icons.account_balance_wallet,
          message: 'Không có dữ liệu',
        ),
      );
    }
  }
  
  Widget _buildPendingList() {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _pendingAllocations.length,
      separatorBuilder: (_, separatorIndex) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final allocation = _pendingAllocations[index];
        return _buildAllocationCard(allocation);
      },
    );
  }
  
  Widget _buildDisbursedList() {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _disbursedAllocations.length,
      separatorBuilder: (_, separatorIndex) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final allocation = _disbursedAllocations[index];
        return AppCard(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(allocation['projectTitle'], style: AppTextStyles.heading3),
                      const SizedBox(height: 8),
                      Text(
                        'Tổng: ${allocation['totalBudget'] ~/ 1000000}M VNĐ',
                        style: AppTextStyles.body2.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Text(
                        'Giải ngân: ${allocation['disbursedAt']}',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                StatusBadge(label: 'Đã giải ngân', color: AppColors.success),
              ],
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildAllocationCard(Map<String, dynamic> allocation) {
    final totalBudget = allocation['totalBudget'] as int;
    final teamAmount = allocation['allocation']['team'] as int;
    final mentorAmount = allocation['allocation']['mentor'] as int;
    final labAmount = allocation['allocation']['lab'] as int;
    
    return AppCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(allocation['projectTitle'], style: AppTextStyles.heading3),
                      const SizedBox(height: 4),
                      Text(
                        allocation['enterprise'],
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                StatusBadge(label: 'Chờ phân bổ', color: AppColors.warning),
              ],
            ),
            const SizedBox(height: 16),
            
            // Total Budget
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Tổng kinh phí:', style: AppTextStyles.subtitle1),
                  Text(
                    '${totalBudget ~/ 1000000}M VNĐ',
                    style: AppTextStyles.heading3.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            
            // Allocation Breakdown
            Text('Phân bổ theo quy định 70/20/10:', style: AppTextStyles.subtitle2),
            const SizedBox(height: 12),
            
            _buildAllocationRow(
              icon: Icons.groups,
              label: 'Nhóm SV (70%)',
              amount: teamAmount,
              color: AppColors.success,
              detail: '${allocation['teamSize']} sinh viên',
            ),
            const SizedBox(height: 8),
            _buildAllocationRow(
              icon: Icons.person,
              label: 'Mentor (20%)',
              amount: mentorAmount,
              color: AppColors.info,
              detail: allocation['mentor'],
            ),
            const SizedBox(height: 8),
            _buildAllocationRow(
              icon: Icons.business,
              label: 'Phòng LAB (10%)',
              amount: labAmount,
              color: AppColors.warning,
              detail: 'Vận hành LAB',
            ),
            
            const SizedBox(height: 16),
            Text(
              'Doanh nghiệp đã thanh toán: ${allocation['paidAt']}',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            
            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 16),
            
            // Actions
            AppButton(
              text: 'Xác nhận Phân bổ & Giải ngân',
              onPressed: () => _showConfirmDialog(allocation),
              icon: Icons.check_circle,
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildAllocationRow({
    required IconData icon,
    required String label,
    required int amount,
    required Color color,
    required String detail,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: color.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AppTextStyles.subtitle2),
                Text(
                  detail,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${amount ~/ 1000000}M',
            style: AppTextStyles.heading3.copyWith(color: color),
          ),
        ],
      ),
    );
  }
  
  void _showConfirmDialog(Map<String, dynamic> allocation) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận Phân bổ Kinh phí'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Xác nhận phân bổ và giải ngân kinh phí cho:'),
            const SizedBox(height: 16),
            Text(
              allocation['projectTitle'],
              style: AppTextStyles.subtitle1,
            ),
            const SizedBox(height: 16),
            Text('Sau khi xác nhận, kinh phí sẽ được chuyển vào:'),
            const SizedBox(height: 8),
            Text('• Tài khoản nhóm SV: ${allocation['allocation']['team'] ~/ 1000000}M VNĐ'),
            Text('• Tài khoản Mentor: ${allocation['allocation']['mentor'] ~/ 1000000}M VNĐ'),
            Text('• Quỹ LAB: ${allocation['allocation']['lab'] ~/ 1000000}M VNĐ'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: Call API
              Navigator.pop(context);
              _showSuccessSnackBar('Đã phân bổ và giải ngân kinh phí thành công');
              setState(() {
                _pendingAllocations.removeWhere((a) => a['id'] == allocation['id']);
                _disbursedAllocations.insert(0, {
                  'id': allocation['id'],
                  'projectTitle': allocation['projectTitle'],
                  'totalBudget': allocation['totalBudget'],
                  'disbursedAt': '2026-01-22',
                  'status': 'DISBURSED',
                });
              });
            },
            child: const Text('Xác nhận Giải ngân'),
          ),
        ],
      ),
    );
  }
  
  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.success),
    );
  }
}



