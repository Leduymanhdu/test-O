import 'package:flutter/material.dart';
import 'package:labodc_mobile/core/theme/app_colors.dart';
import 'package:labodc_mobile/core/theme/app_text_styles.dart';
import 'package:labodc_mobile/widgets/common_widgets.dart';
import 'package:labodc_mobile/widgets/app_button.dart';

class AdminReportsScreen extends StatefulWidget {
  const AdminReportsScreen({super.key});

  @override
  State<AdminReportsScreen> createState() => _AdminReportsScreenState();
}

class _AdminReportsScreenState extends State<AdminReportsScreen> {
  String _selectedTab = 'published';

  // Mock data
  final List<Map<String, dynamic>> _publishedReports = [
    {
      'id': 401,
      'title': 'Báo cáo Minh bạch Q1/2026',
      'period': 'Q1/2026',
      'publishedAt': '2026-01-15',
      'totalProjects': 15,
      'totalFunds': 1500000000,
      'status': 'PUBLISHED',
      'downloads': 234,
    },
    {
      'id': 400,
      'title': 'Báo cáo Minh bạch Q4/2025',
      'period': 'Q4/2025',
      'publishedAt': '2025-10-15',
      'totalProjects': 12,
      'totalFunds': 1200000000,
      'status': 'PUBLISHED',
      'downloads': 456,
    },
  ];

  final List<Map<String, dynamic>> _draftReports = [];

  final Map<String, dynamic> _statistics = {
    'totalReports': 8,
    'totalProjects': 120,
    'totalFundsDisbursed': 12000000000,
    'averageProjectBudget': 100000000,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Báo cáo Minh bạch')),
      body: Column(
        children: [
          // Statistics Summary
          Container(
            color: AppColors.white,
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        'Tổng Báo cáo',
                        '${_statistics['totalReports']}',
                        Icons.description,
                        AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        'Tổng Dự án',
                        '${_statistics['totalProjects']}',
                        Icons.assignment,
                        AppColors.success,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        'Tổng Giải ngân',
                        '${_statistics['totalFundsDisbursed'] ~/ 1000000000}B',
                        Icons.account_balance_wallet,
                        AppColors.info,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        'TB/Dự án',
                        '${_statistics['averageProjectBudget'] ~/ 1000000}M',
                        Icons.trending_up,
                        AppColors.warning,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Tab Bar
          Container(
            color: AppColors.white,
            child: Row(
              children: [
                _buildTab('Đã xuất bản', 'published', _publishedReports.length),
                _buildTab('Bản nháp', 'draft', _draftReports.length),
              ],
            ),
          ),
          const Divider(height: 1),

          // Content
          Expanded(child: _buildContent()),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateReportDialog,
        icon: const Icon(Icons.add),
        label: const Text('Tạo Báo cáo'),
      ),
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return AppCard(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(value, style: AppTextStyles.heading2.copyWith(color: color)),
            const SizedBox(height: 4),
            Text(
              label,
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
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
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.textSecondary,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              if (count > 0) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.textSecondary,
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
    if (_selectedTab == 'published' && _publishedReports.isNotEmpty) {
      return _buildPublishedList();
    } else if (_selectedTab == 'draft' && _draftReports.isNotEmpty) {
      return _buildDraftList();
    } else {
      return const Center(
        child: EmptyState(icon: Icons.article, message: 'Chưa có báo cáo nào'),
      );
    }
  }

  Widget _buildPublishedList() {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _publishedReports.length,
      separatorBuilder: (_, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final report = _publishedReports[index];
        return _buildReportCard(report);
      },
    );
  }

  Widget _buildDraftList() {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _draftReports.length,
      separatorBuilder: (_, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final report = _draftReports[index];
        return _buildReportCard(report);
      },
    );
  }

  Widget _buildReportCard(Map<String, dynamic> report) {
    final isPublished = report['status'] == 'PUBLISHED';

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
                      Text(report['title'], style: AppTextStyles.heading3),
                      const SizedBox(height: 4),
                      Text(
                        'Kỳ báo cáo: ${report['period']}',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                StatusBadge(
                  label: isPublished ? 'Đã xuất bản' : 'Bản nháp',
                  color: isPublished ? AppColors.success : AppColors.warning,
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Statistics
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.backgroundGrey,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _buildReportStat(
                      Icons.assignment,
                      '${report['totalProjects']} dự án',
                    ),
                  ),
                  Container(width: 1, height: 30, color: AppColors.divider),
                  Expanded(
                    child: _buildReportStat(
                      Icons.payments,
                      '${report['totalFunds'] ~/ 1000000}M VNĐ',
                    ),
                  ),
                  if (isPublished) ...[
                    Container(width: 1, height: 30, color: AppColors.divider),
                    Expanded(
                      child: _buildReportStat(
                        Icons.download,
                        '${report['downloads']} lượt',
                      ),
                    ),
                  ],
                ],
              ),
            ),

            if (isPublished) ...[
              const SizedBox(height: 12),
              Text(
                'Xuất bản: ${report['publishedAt']}',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],

            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 16),

            // Actions
            Row(
              children: [
                Expanded(
                  child: AppButton(
                    text: 'Xem Chi tiết',
                    onPressed: () => _viewReportDetails(report),
                    backgroundColor: AppColors.white,
                    textColor: AppColors.primary,
                    borderColor: AppColors.primary,
                    height: 40,
                  ),
                ),
                const SizedBox(width: 12),
                if (isPublished)
                  Expanded(
                    child: AppButton(
                      text: 'Tải PDF',
                      onPressed: () => _downloadReport(report),
                      icon: Icons.download,
                      height: 40,
                    ),
                  )
                else
                  Expanded(
                    child: AppButton(
                      text: 'Xuất bản',
                      onPressed: () => _publishReport(report),
                      icon: Icons.publish,
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

  Widget _buildReportStat(IconData icon, String label) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 16, color: AppColors.textSecondary),
        const SizedBox(width: 4),
        Text(
          label,
          style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
        ),
      ],
    );
  }

  void _showCreateReportDialog() {
    final titleController = TextEditingController();
    final periodController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tạo Báo cáo Minh bạch Mới'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'Tiêu đề báo cáo *',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: periodController,
              decoration: const InputDecoration(
                labelText: 'Kỳ báo cáo (VD: Q1/2026) *',
                border: OutlineInputBorder(),
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
              if (titleController.text.trim().isEmpty ||
                  periodController.text.trim().isEmpty) {
                return;
              }
              // TODO: Call API
              Navigator.pop(context);
              _showSuccessSnackBar('Đã tạo báo cáo mới');
            },
            child: const Text('Tạo'),
          ),
        ],
      ),
    );
  }

  void _viewReportDetails(Map<String, dynamic> report) {
    _showSuccessSnackBar('Xem chi tiết báo cáo #${report['id']}');
    // TODO: Navigate to detail screen
  }

  void _downloadReport(Map<String, dynamic> report) {
    _showSuccessSnackBar('Đang tải báo cáo "${report['title']}"...');
    // TODO: Implement download
  }

  void _publishReport(Map<String, dynamic> report) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xuất bản Báo cáo'),
        content: Text('Xác nhận xuất bản báo cáo "${report['title']}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: Call API
              Navigator.pop(context);
              _showSuccessSnackBar('Đã xuất bản báo cáo');
            },
            child: const Text('Xuất bản'),
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
