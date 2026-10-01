import 'package:flutter/material.dart';
import 'package:labodc_mobile/core/theme/app_colors.dart';
import 'package:labodc_mobile/core/theme/app_text_styles.dart';
import 'package:labodc_mobile/widgets/common_widgets.dart';
import 'package:labodc_mobile/widgets/app_button.dart';

class EnterprisePaymentScreen extends StatefulWidget {
  const EnterprisePaymentScreen({super.key});

  @override
  State<EnterprisePaymentScreen> createState() => _EnterprisePaymentScreenState();
}

class _EnterprisePaymentScreenState extends State<EnterprisePaymentScreen> {
  String _selectedTab = 'pending';
  
  // Mock data
  final List<Map<String, dynamic>> _pendingPayments = [
    {
      'id': 1001,
      'projectId': 788,
      'projectTitle': 'Mobile App E-commerce',
      'amount': 150000000,
      'status': 'PENDING',
      'distribution': {
        'team': 105000000,
        'mentor': 30000000,
        'lab': 15000000,
      },
      'createdAt': '2026-01-20',
    },
  ];
  
  final List<Map<String, dynamic>> _paidPayments = [
    {
      'id': 1000,
      'projectId': 789,
      'projectTitle': 'Website Quản lý Bán hàng',
      'amount': 100000000,
      'status': 'PAID',
      'distribution': {
        'team': 70000000,
        'mentor': 20000000,
        'lab': 10000000,
      },
      'paidAt': '2026-01-15T10:30:00Z',
      'paymentMethod': 'Chuyển khoản',
      'invoiceUrl': 'https://cloudinary.com/invoice-1000.pdf',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thanh toán'),
      ),
      body: Column(
        children: [
          // Tab Bar
          Container(
            color: AppColors.white,
            child: Row(
              children: [
                _buildTab('Chờ thanh toán', 'pending', _pendingPayments.length),
                _buildTab('Đã thanh toán', 'paid', _paidPayments.length),
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
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: AppTextStyles.subtitle2.copyWith(
                  color: isSelected ? AppColors.primary : AppColors.textSecondary,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              if (count > 0) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary : AppColors.textSecondary,
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
    if (_selectedTab == 'pending') {
      return _buildPendingList();
    } else {
      return _buildPaidList();
    }
  }
  
  Widget _buildPendingList() {
    if (_pendingPayments.isEmpty) {
      return const Center(
        child: EmptyState(
          icon: Icons.check_circle,
          message: 'Không có thanh toán đang chờ',
        ),
      );
    }
    
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _pendingPayments.length,
      separatorBuilder: (_, separatorIndex) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final payment = _pendingPayments[index];
        return _buildPendingPaymentCard(payment);
      },
    );
  }
  
  Widget _buildPaidList() {
    if (_paidPayments.isEmpty) {
      return const Center(
        child: EmptyState(
          icon: Icons.payment,
          message: 'Chưa có thanh toán nào',
        ),
      );
    }
    
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _paidPayments.length,
      separatorBuilder: (_, separatorIndex) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final payment = _paidPayments[index];
        return _buildPaidPaymentCard(payment);
      },
    );
  }
  
  Widget _buildPendingPaymentCard(Map<String, dynamic> payment) {
    final amount = payment['amount'] as int;
    final distribution = payment['distribution'] as Map<String, dynamic>;
    
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
                      Text(payment['projectTitle'], style: AppTextStyles.heading4),
                      const SizedBox(height: 4),
                      Text(
                        'Mã dự án: #${payment['projectId']}',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                StatusBadge(label: 'Chờ thanh toán', color: AppColors.warning),
              ],
            ),
            const SizedBox(height: 16),
            
            // Total Amount
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Tổng số tiền:', style: AppTextStyles.subtitle1),
                  Text(
                    '${amount ~/ 1000000}M VNĐ',
                    style: AppTextStyles.heading3.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            
            // Fund Distribution
            Text('Phân bổ kinh phí 70/20/10:', style: AppTextStyles.subtitle2),
            const SizedBox(height: 12),
            
            _buildDistributionRow(
              'Nhóm Sinh viên (70%)',
              distribution['team'] as int,
              AppColors.success,
              Icons.groups,
            ),
            const SizedBox(height: 8),
            _buildDistributionRow(
              'Mentor (20%)',
              distribution['mentor'] as int,
              AppColors.info,
              Icons.person,
            ),
            const SizedBox(height: 8),
            _buildDistributionRow(
              'Phòng LAB (10%)',
              distribution['lab'] as int,
              AppColors.warning,
              Icons.business,
            ),
            
            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 16),
            
            // Payment Info
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.info.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: AppColors.info, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Thanh toán qua PayOS. Link thanh toán có hiệu lực 15 phút.',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.info,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Payment Button
            AppButton(
              text: 'Thanh toán ngay',
              onPressed: () => _initiatePayment(payment),
              icon: Icons.payment,
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildPaidPaymentCard(Map<String, dynamic> payment) {
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
                      Text(payment['projectTitle'], style: AppTextStyles.heading4),
                      const SizedBox(height: 4),
                      Text(
                        'Mã thanh toán: #${payment['id']}',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                StatusBadge(label: 'Đã thanh toán', color: AppColors.success),
              ],
            ),
            const SizedBox(height: 16),
            
            // Amount
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Số tiền:', style: AppTextStyles.body2),
                Text(
                  '${payment['amount'] ~/ 1000000}M VNĐ',
                  style: AppTextStyles.heading4.copyWith(
                    color: AppColors.success,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            
            // Payment Info
            _buildPaymentInfo(Icons.event, 'Ngày thanh toán', payment['paidAt'].substring(0, 10)),
            const SizedBox(height: 8),
            _buildPaymentInfo(Icons.payment, 'Phương thức', payment['paymentMethod']),
            
            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 16),
            
            // Actions
            Row(
              children: [
                Expanded(
                  child: AppButton(
                    text: 'Xem chi tiết',
                    onPressed: () => _viewPaymentDetail(payment),
                    backgroundColor: AppColors.white,
                    textColor: AppColors.primary,
                    borderColor: AppColors.primary,
                    height: 40,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AppButton(
                    text: 'Tải hóa đơn',
                    onPressed: () => _downloadInvoice(payment),
                    icon: Icons.download,
                    height: 40,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildDistributionRow(String label, int amount, Color color, IconData icon) {
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
            child: Text(label, style: AppTextStyles.body2),
          ),
          Text(
            '${amount ~/ 1000000}M',
            style: AppTextStyles.subtitle1.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildPaymentInfo(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.textSecondary),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: AppTextStyles.body2.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        Text(value, style: AppTextStyles.body2),
      ],
    );
  }
  
  void _initiatePayment(Map<String, dynamic> payment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận Thanh toán'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Dự án: ${payment['projectTitle']}'),
            const SizedBox(height: 8),
            Text('Số tiền: ${payment['amount'] ~/ 1000000}M VNĐ'),
            const SizedBox(height: 16),
            Text(
              'Bạn sẽ được chuyển đến trang PayOS để thanh toán.',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Call API to create payment link
              _showSuccessSnackBar('Đang tạo link thanh toán...');
            },
            child: const Text('Tiếp tục'),
          ),
        ],
      ),
    );
  }
  
  void _viewPaymentDetail(Map<String, dynamic> payment) {
    _showSuccessSnackBar('Xem chi tiết thanh toán #${payment['id']}');
  }
  
  void _downloadInvoice(Map<String, dynamic> payment) {
    _showSuccessSnackBar('Đang tải hóa đơn #${payment['id']}...');
    // TODO: Download invoice
  }
  
  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.info),
    );
  }
}



