import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:labodc_mobile/core/enums/app_enums.dart';
import 'package:labodc_mobile/core/routes/app_router.dart';
import 'package:labodc_mobile/core/theme/app_colors.dart';
import 'package:labodc_mobile/core/theme/app_text_styles.dart';
import 'package:labodc_mobile/providers/auth_provider.dart';
import 'package:labodc_mobile/widgets/common_widgets.dart';
import 'package:labodc_mobile/widgets/app_button.dart';
import 'package:labodc_mobile/models/project_model.dart';
import 'package:labodc_mobile/providers/project_provider.dart';

class EnterpriseDashboardScreen extends StatefulWidget {
  const EnterpriseDashboardScreen({super.key});

  @override
  State<EnterpriseDashboardScreen> createState() => _EnterpriseDashboardScreenState();
}

class _EnterpriseDashboardScreenState extends State<EnterpriseDashboardScreen> {
  bool _initialized = false;
  int? _enterpriseUserId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
  }

  Future<void> _loadData() async {
    if (_initialized) return;
    _initialized = true;
    final auth = context.read<AuthProvider>();
    _enterpriseUserId = auth.currentAuthData?.userId;
    final projectProvider = context.read<ProjectProvider>();

    if (auth.userRole == UserRole.enterprise && _enterpriseUserId != null) {
      await projectProvider.loadEnterpriseProjects(_enterpriseUserId!);
    } else {
      await projectProvider.loadProjects();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Doanh nghiệp'),
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
      body: Consumer<ProjectProvider>(
        builder: (context, provider, _) {
          final projects = provider.projects;
          final stats = _computeStats(projects);
          final recent = _recentProjects(projects);

          if (provider.isLoading && projects.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null && projects.isEmpty) {
            return RefreshIndicator(
              onRefresh: _handleRefresh,
              child: ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  EmptyState(
                    icon: Icons.error_outline,
                    message: provider.error ?? 'Không thể tải dữ liệu',
                  ),
                  const SizedBox(height: 12),
                  AppButton(
                    text: 'Thử lại',
                    onPressed: _handleRefresh,
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _handleRefresh,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text('Tổng quan', style: AppTextStyles.heading4),
                const SizedBox(height: 12),
                _buildStats(stats),
                const SizedBox(height: 20),
                Text('Hành động nhanh', style: AppTextStyles.heading5),
                const SizedBox(height: 12),
                _buildQuickActions(),
                const SizedBox(height: 20),
                Text('Dự án gần đây', style: AppTextStyles.heading5),
                const SizedBox(height: 12),
                _buildRecentProjects(recent),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStats(_DashboardStats stats) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                label: 'Tổng dự án',
                value: stats.total.toString(),
                color: AppColors.primary,
                icon: Icons.folder_copy,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                label: 'Đang hoạt động',
                value: stats.active.toString(),
                color: AppColors.info,
                icon: Icons.play_circle_fill,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                label: 'Hoàn thành',
                value: stats.completed.toString(),
                color: AppColors.success,
                icon: Icons.check_circle,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                label: 'Ngân sách (M)',
                value: stats.totalBudgetM.toStringAsFixed(1),
                color: AppColors.warning,
                icon: Icons.payments,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String label,
    required String value,
    required Color color,
    required IconData icon,
  }) {
    return AppCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: AppTextStyles.caption),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: AppTextStyles.heading4.copyWith(color: color),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Row(
      children: [
        Expanded(
          child: AppButton(
            text: 'Đề xuất\nDự án',
            icon: Icons.add_business,
            onPressed: () => context.push(AppRoutes.projectProposal),
            height: 80,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: AppButton(
            text: 'Dự án\ncủa tôi',
            icon: Icons.folder_open,
            onPressed: () => context.push(AppRoutes.enterpriseProjects),
            backgroundColor: AppColors.white,
            textColor: AppColors.primary,
            borderColor: AppColors.primary,
            height: 80,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: AppButton(
            text: 'Báo cáo\ntiến độ',
            icon: Icons.assessment,
            onPressed: () => context.push(AppRoutes.enterpriseReports),
            backgroundColor: AppColors.white,
            textColor: AppColors.primary,
            borderColor: AppColors.primary,
            height: 80,
          ),
        ),
      ],
    );
  }

  Widget _buildRecentProjects(List<ProjectModel> projects) {
    if (projects.isEmpty) {
      return const EmptyState(
        icon: Icons.folder_open,
        message: 'Chưa có dự án nào',
      );
    }

    return Column(
      children: projects
          .map(
            (project) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildProjectCard(project),
            ),
          )
          .toList(),
    );
  }

  Widget _buildProjectCard(ProjectModel project) {
    final statusColor = _statusColor(project.status);
    final statusLabel = _statusLabel(project.status);

    return AppCard(
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      project.name,
                      style: AppTextStyles.heading4,
                    ),
                  ),
                  StatusBadge(label: statusLabel, color: statusColor),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 16,
                runSpacing: 8,
                children: [
                  _buildMeta(
                    Icons.calendar_today,
                    '${_formatDate(project.startDate)} - ${_formatDate(project.endDate)}',
                  ),
                  _buildMeta(
                    Icons.people,
                    '${project.requiredTalents} sinh viên',
                  ),
                  _buildMeta(
                    Icons.payments,
                    '${(project.budget / 1000000).toStringAsFixed(1)}M VND',
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: AppButton(
                      text: 'Xem chi tiết',
                      onPressed: () {},
                      backgroundColor: AppColors.white,
                      textColor: AppColors.primary,
                      borderColor: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AppButton(
                      text: 'Báo cáo',
                      onPressed: () {},
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMeta(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppColors.textSecondary),
        const SizedBox(width: 6),
        Text(
          text,
          style: AppTextStyles.caption.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Future<void> _handleRefresh() async {
    final projectProvider = context.read<ProjectProvider>();
    if (_enterpriseUserId != null) {
      await projectProvider.loadEnterpriseProjects(_enterpriseUserId!);
    } else {
      await projectProvider.loadProjects();
    }
  }

  _DashboardStats _computeStats(List<ProjectModel> projects) {
    final total = projects.length;
    final active = projects
        .where(
          (p) =>
              p.status == ProjectStatus.pending ||
              p.status == ProjectStatus.approved ||
              p.status == ProjectStatus.inProgress,
        )
        .length;
    final completed = projects
        .where((p) => p.status == ProjectStatus.completed)
        .length;
    final totalBudget = projects.fold<double>(0, (sum, p) => sum + p.budget);
    return _DashboardStats(
      total: total,
      active: active,
      completed: completed,
      totalBudgetM: totalBudget / 1000000,
    );
  }

  List<ProjectModel> _recentProjects(List<ProjectModel> projects) {
    final sorted = [...projects];
    sorted.sort((a, b) => _effectiveUpdatedAt(b).compareTo(_effectiveUpdatedAt(a)));
    return sorted.take(5).toList();
  }

  DateTime _effectiveUpdatedAt(ProjectModel project) {
    return project.updatedAt ?? project.createdAt;
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '--/--/----';
    final d = date.day.toString().padLeft(2, '0');
    final m = date.month.toString().padLeft(2, '0');
    return '$d/$m/${date.year}';
  }

  Color _statusColor(ProjectStatus status) {
    switch (status) {
      case ProjectStatus.pending:
        return AppColors.warning;
      case ProjectStatus.approved:
      case ProjectStatus.inProgress:
        return AppColors.info;
      case ProjectStatus.completed:
        return AppColors.success;
      case ProjectStatus.rejected:
      case ProjectStatus.cancelled:
        return AppColors.error;
      case ProjectStatus.draft:
        return AppColors.textSecondary;
    }
  }

  String _statusLabel(ProjectStatus status) {
    switch (status) {
      case ProjectStatus.pending:
        return 'Chờ duyệt';
      case ProjectStatus.approved:
        return 'Đã duyệt';
      case ProjectStatus.inProgress:
        return 'Đang thực hiện';
      case ProjectStatus.completed:
        return 'Hoàn thành';
      case ProjectStatus.rejected:
        return 'Từ chối';
      case ProjectStatus.cancelled:
        return 'Đã hủy';
      case ProjectStatus.draft:
        return 'Nháp';
    }
  }
}

class _DashboardStats {
  final int total;
  final int active;
  final int completed;
  final double totalBudgetM;

  const _DashboardStats({
    required this.total,
    required this.active,
    required this.completed,
    required this.totalBudgetM,
  });
}


