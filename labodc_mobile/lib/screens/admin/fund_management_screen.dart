import 'package:flutter/material.dart';
import 'package:labodc_mobile/core/theme/app_colors.dart';
import 'package:labodc_mobile/core/theme/app_text_styles.dart';
import 'package:labodc_mobile/widgets/common_widgets.dart';
import 'package:labodc_mobile/services/admin/fund_service.dart';
import 'package:intl/intl.dart';

class FundManagementScreen extends StatefulWidget {
  const FundManagementScreen({super.key});

  @override
  State<FundManagementScreen> createState() => _FundManagementScreenState();
}

class _FundManagementScreenState extends State<FundManagementScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _fundService = FundAdminService();
  List<FundAllocation> _allocations = [];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        _loadData();
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    try {
      final status = _getStatusFromTab();
      _allocations = await _fundService.getAllocations(status: status);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e'), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String? _getStatusFromTab() {
    switch (_tabController.index) {
      case 0: return null; // ALL
      case 1: return 'ALLOCATED';
      case 2: return 'DISTRIBUTED';
      default: return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Phân Bổ Kinh Phí'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.white,
          labelColor: AppColors.white,
          unselectedLabelColor: AppColors.white.withOpacity(0.7),
          tabs: const [
            Tab(text: 'Tất cả'),
            Tab(text: 'Đã phân bổ'),
            Tab(text: 'Đã giải ngân'),
          ],
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _buildList(),
    );
  }

  Widget _buildList() {
    if (_allocations.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.account_balance_wallet, size: 64, color: AppColors.textSecondary.withOpacity(0.5)),
            const SizedBox(height: 16),
            Text('Không có dữ liệu', style: AppTextStyles.body1.copyWith(color: AppColors.textSecondary)),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _allocations.length,
        itemBuilder: (context, index) => _buildCard(_allocations[index]),
      ),
    );
  }

  Widget _buildCard(FundAllocation allocation) {
    return AppCard(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.account_balance, color: AppColors.primary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(allocation.projectTitle, style: AppTextStyles.subtitle1),
                      const SizedBox(height: 4),
                      Text(allocation.enterpriseName, style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
                    ],
                  ),
                ),
                _buildStatusBadge(allocation.status),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildInfoColumn('Tổng', _formatCurrency(allocation.allocation.total)),
                ),
                Expanded(
                  child: _buildInfoColumn('Team (${allocation.allocation.team.percentage}%)', _formatCurrency(allocation.allocation.team.amount)),
                ),
                Expanded(
                  child: _buildInfoColumn('Mentor (${allocation.allocation.mentor.percentage}%)', _formatCurrency(allocation.allocation.mentor.amount)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Lab: ${_formatCurrency(allocation.allocation.lab.amount)}', style: AppTextStyles.caption),
                if (allocation.payment.paidAt != null)
                  Text('Thanh toán: ${_formatDate(allocation.payment.paidAt!)}', style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoColumn(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
        const SizedBox(height: 4),
        Text(value, style: AppTextStyles.body2.copyWith(fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildStatusBadge(String status) {
    final data = status == 'ALLOCATED'
        ? (AppColors.info, 'Đã phân bổ')
        : status == 'DISTRIBUTED'
            ? (AppColors.success, 'Đã giải ngân')
            : (AppColors.warning, status);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: data.$1.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: data.$1),
      ),
      child: Text(data.$2, style: AppTextStyles.caption.copyWith(color: data.$1, fontWeight: FontWeight.bold)),
    );
  }

  String _formatCurrency(double amount) => NumberFormat.currency(locale: 'vi_VN', symbol: '₫', decimalDigits: 0).format(amount);
  String _formatDate(DateTime date) => DateFormat('dd/MM/yyyy').format(date);
}
