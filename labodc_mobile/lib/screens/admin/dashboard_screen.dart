import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:labodc_mobile/core/theme/app_colors.dart';
import 'package:labodc_mobile/core/theme/app_text_styles.dart';
import 'package:labodc_mobile/core/routes/app_router.dart';
import 'package:labodc_mobile/providers/auth_provider.dart';
import 'package:labodc_mobile/providers/admin_provider.dart';
import 'package:labodc_mobile/services/admin/dashboard_service.dart';
import 'package:labodc_mobile/widgets/common_widgets.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  @override
  void initState() {
    super.initState();
    // Load dashboard data when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().loadDashboard();
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Admin'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Đăng xuất',
            onPressed: () async {
              final authProvider = context.read<AuthProvider>();
              await authProvider.logout();
              if (context.mounted) {
                context.go(AppRoutes.login);
              }
            },
          ),
        ],
      ),
      body: Consumer<AdminProvider>(
        builder: (context, adminProvider, _) {
          if (adminProvider.loadingDashboard) {
            return const Center(child: CircularProgressIndicator());
          }

          if (adminProvider.dashboardError != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: AppColors.error),
                  const SizedBox(height: 16),
                  Text(
                    'Không thể tải dữ liệu',
                    style: AppTextStyles.subtitle1,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    adminProvider.dashboardError!,
                    style: AppTextStyles.caption,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => adminProvider.loadDashboard(),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Thử lại'),
                  ),
                ],
              ),
            );
          }

          final stats = adminProvider.stats;
          if (stats == null) {
            return const Center(child: Text('Không có dữ liệu'));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Welcome Section
                Text(
                  'Chào mừng, Lab Admin',
                  style: AppTextStyles.heading2,
                ),
                const SizedBox(height: 8),
                Text(
                  'Quản lý và giám sát hệ thống LabOdc',
                  style: AppTextStyles.body2.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 24),
                
                // Statistics Cards - Real Data
                _buildStatisticsCards(stats),
                const SizedBox(height: 24),
                
                // Quick Actions
                Text(
                  'Chức năng chính',
                  style: AppTextStyles.heading3,
                ),
                const SizedBox(height: 16),
                _buildQuickActions(context),
                
                const SizedBox(height: 24),
                
                // Recent Activities
                if (adminProvider.activities.isNotEmpty) ...[
                  Text('Hoạt động gần đây', style: AppTextStyles.heading3),
                  const SizedBox(height: 16),
                  _buildRecentActivities(adminProvider),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
  
  Widget _buildStatisticsCards(DashboardStats stats) {
    return Column(
      children: [
        // Row 1: Projects and Enterprises
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Doanh nghiệp\nChờ duyệt',
                '${stats.enterprises.pending}',
                Icons.business,
                AppColors.warning,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'Tổng\nDự án',
                '${stats.projects.total}',
                Icons.assignment,
                AppColors.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'Dự án\nĐang chạy',
                '${stats.projects.ongoing}',
                Icons.play_arrow,
                AppColors.success,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Row 2: Talents and Mentors
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Talents\nHoạt động',
                '${stats.talents.active}',
                Icons.people,
                AppColors.info,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'Mentors\nSẵn sàng',
                '${stats.mentors.available}',
                Icons.school,
                AppColors.accent,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'Doanh thu',
                '${(stats.totalRevenue / 1000000).toStringAsFixed(0)}M',
                Icons.attach_money,
                AppColors.success,
              ),
            ),
          ],
        ),
      ],
    );
  }
  
  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Icon(icon, size: 32, color: color),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppTextStyles.heading1.copyWith(color: color),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: AppTextStyles.caption,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
  
  Widget _buildQuickActions(BuildContext context) {
    return Column(
      children: [
        _buildActionButton(
          context,
          'Duyệt Doanh nghiệp',
          'Xác thực doanh nghiệp đăng ký mới',
          Icons.business_center,
          AppColors.primary,
          AppRoutes.adminEnterpriseManagement,
        ),
        const SizedBox(height: 12),
        _buildActionButton(
          context,
          'Duyệt Dự án',
          'Xác thực dự án và gán Mentor',
          Icons.assignment_turned_in,
          AppColors.info,
          AppRoutes.adminProjectValidation,
        ),
        const SizedBox(height: 12),
        _buildActionButton(
          context,
          'Quản lý Quỹ',
          'Phân bổ và giải ngân quỹ (70/20/10)',
          Icons.account_balance_wallet,
          AppColors.success,
          AppRoutes.adminFundAllocation,
        ),
      ],
    );
  }
  
  Widget _buildActionButton(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    Color color,
    String route,
  ) {
    return AppCard(
      onTap: () => context.push(route),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTextStyles.subtitle1),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
  
  
  Widget _buildRecentActivities(AdminProvider adminProvider) {
    return AppCard(
      child: Column(
        children: adminProvider.activities
            .take(5)
            .map((activity) => _buildActivityItem(activity))
            .toList(),
      ),
    );
  }
  
  Widget _buildActivityItem(RecentActivity activity) {
    IconData icon;
    Color color;
    
    switch (activity.type) {
      case 'ENTERPRISE':
        icon = Icons.business;
        color = AppColors.info;
        break;
      case 'PROJECT':
        icon = Icons.assignment;
        color = AppColors.primary;
        break;
      case 'PAYMENT':
        icon = Icons.payment;
        color = AppColors.success;
        break;
      default:
        icon = Icons.notifications;
        color = AppColors.textSecondary;
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
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
                    Text(activity.description, style: AppTextStyles.body2),
                    const SizedBox(height: 4),
                    Text(
                      _formatTime(activity.timestamp),
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
      ],
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);

    if (diff.inMinutes < 1) {
      return 'Vừa xong';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes} phút trước';
    } else if (diff.inHours < 24) {
      return '${diff.inHours} giờ trước';
    } else if (diff.inDays < 7) {
      return '${diff.inDays} ngày trước';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }
}

