import 'package:flutter/material.dart';
import 'package:labodc_mobile/core/theme/app_colors.dart';
import 'package:labodc_mobile/core/theme/app_text_styles.dart';
import 'package:labodc_mobile/widgets/common_widgets.dart';
import 'package:labodc_mobile/widgets/app_button.dart';

class EnterpriseReportsScreen extends StatefulWidget {
  const EnterpriseReportsScreen({super.key});

  @override
  State<EnterpriseReportsScreen> createState() => _EnterpriseReportsScreenState();
}

class _EnterpriseReportsScreenState extends State<EnterpriseReportsScreen> {
  // Mock data
  final List<Map<String, dynamic>> _reports = [
    {
      'id': 501,
      'projectId': 789,
      'projectTitle': 'Website Quản lý Bán hàng',
      'reportType': 'MONTHLY',
      'period': 'Tháng 1/2026',
      'progress': 65,
      'completedTasks': 13,
      'totalTasks': 20,
      'mentorName': 'Nguyễn Văn Mentor',
      'mentorRating': 4.5,
      'summary': 'Nhóm đã hoàn thành giao diện chính và tích hợp API cơ bản. Một số vấn đề về authentication đã được giải quyết.',
      'achievements': [
        'Hoàn thành giao diện quản lý sản phẩm',
        'Tích hợp API đăng nhập/đăng ký',
        'Setup database và migration',
      ],
      'issues': [
        'Cần tối ưu performance khi load danh sách lớn',
        '1 thành viên có vấn đề sức khỏe, tiến độ chậm 1 tuần',
      ],
      'nextPlan': 'Hoàn thành module quản lý đơn hàng và thanh toán',
      'attachments': [
        {
          'name': 'screenshot-dashboard.png',
          'url': 'https://cloudinary.com/screenshot.png',
          'type': 'image',
        },
      ],
      'createdAt': '2026-01-25',
      'status': 'SUBMITTED',
    },
    {
      'id': 500,
      'projectId': 789,
      'projectTitle': 'Website Quản lý Bán hàng',
      'reportType': 'PHASE',
      'period': 'Giai đoạn 1',
      'progress': 40,
      'completedTasks': 8,
      'totalTasks': 20,
      'mentorName': 'Nguyễn Văn Mentor',
      'mentorRating': 4.3,
      'summary': 'Hoàn thành thiết kế và setup môi trường. Bắt đầu coding các module cơ bản.',
      'achievements': [
        'Thiết kế database schema',
        'Setup project structure',
        'Implement authentication',
      ],
      'issues': [],
      'nextPlan': 'Phát triển các tính năng CRUD cơ bản',
      'attachments': [],
      'createdAt': '2026-01-01',
      'status': 'SUBMITTED',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Báo cáo Tiến độ'),
      ),
      body: _reports.isEmpty
          ? const Center(
              child: EmptyState(
                icon: Icons.assessment,
                message: 'Chưa có báo cáo nào',
              ),
            )
          : RefreshIndicator(
              onRefresh: _handleRefresh,
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: _reports.length,
                separatorBuilder: (_, separatorIndex) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final report = _reports[index];
                  return _buildReportCard(report);
                },
              ),
            ),
    );
  }
  
  Widget _buildReportCard(Map<String, dynamic> report) {
    final reportType = report['reportType'] as String;
    final typeLabel = reportType == 'MONTHLY' ? 'Báo cáo tháng' : 'Báo cáo giai đoạn';
    
    return AppCard(
      child: InkWell(
        onTap: () => _viewReportDetail(report),
        borderRadius: BorderRadius.circular(8),
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
                        Text(report['projectTitle'], style: AppTextStyles.heading4),
                        const SizedBox(height: 4),
                        Text(
                          '$typeLabel - ${report['period']}',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.chevron_right,
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Progress
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.backgroundGrey,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Tiến độ dự án', style: AppTextStyles.subtitle2),
                        Text(
                          '${report['progress']}%',
                          style: AppTextStyles.heading4.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: report['progress'] / 100,
                      backgroundColor: AppColors.white,
                      valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              
              // Tasks
              Row(
                children: [
                  Expanded(
                    child: _buildStatItem(
                      Icons.check_circle_outline,
                      'Hoàn thành',
                      '${report['completedTasks']}/${report['totalTasks']}',
                      AppColors.success,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatItem(
                      Icons.person,
                      'Mentor',
                      report['mentorName'],
                      AppColors.info,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              
              // Summary
              Text('Tóm tắt:', style: AppTextStyles.subtitle2),
              const SizedBox(height: 8),
              Text(
                report['summary'],
                style: AppTextStyles.body2,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              
              // Achievements
              if ((report['achievements'] as List).isNotEmpty) ...[
                const SizedBox(height: 12),
                Text('Thành tựu:', style: AppTextStyles.subtitle2),
                const SizedBox(height: 8),
                ...(report['achievements'] as List<String>).take(2).map(
                  (achievement) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.check_circle,
                          size: 16,
                          color: AppColors.success,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            achievement,
                            style: AppTextStyles.body2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              
              // Issues
              if ((report['issues'] as List).isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.warning_amber, color: AppColors.warning, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${(report['issues'] as List).length} vấn đề cần lưu ý',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.warning,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              
              const SizedBox(height: 16),
              const Divider(height: 1),
              const SizedBox(height: 16),
              
              // Footer
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Ngày báo cáo: ${report['createdAt']}',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  AppButton(
                    text: 'Xem chi tiết',
                    onPressed: () => _viewReportDetail(report),
                    backgroundColor: AppColors.white,
                    textColor: AppColors.primary,
                    borderColor: AppColors.primary,
                    height: 32,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildStatItem(IconData icon, String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: color.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 4),
              Text(
                label,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppTextStyles.subtitle2,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
  
  void _viewReportDetail(Map<String, dynamic> report) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => _buildReportDetailSheet(
          report,
          scrollController,
        ),
      ),
    );
  }
  
  Widget _buildReportDetailSheet(Map<String, dynamic> report, ScrollController controller) {
    return Column(
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
        
        // Title
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Expanded(
                child: Text('Chi tiết Báo cáo', style: AppTextStyles.heading3),
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
          child: ListView(
            controller: controller,
            padding: const EdgeInsets.all(16),
            children: [
              Text(report['projectTitle'], style: AppTextStyles.heading4),
              const SizedBox(height: 4),
              Text(
                '${report['reportType'] == 'MONTHLY' ? 'Báo cáo tháng' : 'Báo cáo giai đoạn'} - ${report['period']}',
                style: AppTextStyles.body2.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 24),
              
              _buildDetailSection('Tóm tắt', report['summary']),
              const SizedBox(height: 16),
              
              _buildDetailSection('Thành tựu', null,
                children: (report['achievements'] as List<String>)
                    .map((a) => _buildBulletPoint(a, AppColors.success))
                    .toList(),
              ),
              const SizedBox(height: 16),
              
              if ((report['issues'] as List).isNotEmpty) ...[
                _buildDetailSection('Vấn đề', null,
                  children: (report['issues'] as List<String>)
                      .map((i) => _buildBulletPoint(i, AppColors.warning))
                      .toList(),
                ),
                const SizedBox(height: 16),
              ],
              
              _buildDetailSection('Kế hoạch tiếp theo', report['nextPlan']),
              const SizedBox(height: 24),
              
              // Download PDF
              AppButton(
                text: 'Tải PDF',
                onPressed: () => _downloadReport(report),
                icon: Icons.download,
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildDetailSection(String title, String? content, {List<Widget>? children}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTextStyles.subtitle1),
        const SizedBox(height: 8),
        if (content != null)
          Text(content, style: AppTextStyles.body2)
        else if (children != null)
          ...children,
      ],
    );
  }
  
  Widget _buildBulletPoint(String text, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.circle, size: 6, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text, style: AppTextStyles.body2),
          ),
        ],
      ),
    );
  }
  
  void _downloadReport(Map<String, dynamic> report) {
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Đang tải báo cáo #${report['id']}...'),
        backgroundColor: AppColors.info,
      ),
    );
    // TODO: Download PDF
  }
  
  Future<void> _handleRefresh() async {
    // TODO: Fetch data from API
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) {
      setState(() {});
    }
  }
}



