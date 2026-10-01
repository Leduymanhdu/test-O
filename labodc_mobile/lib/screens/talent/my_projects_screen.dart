import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:labodc_mobile/core/enums/app_enums.dart';
import 'package:labodc_mobile/core/theme/app_colors.dart';
import 'package:labodc_mobile/core/theme/app_text_styles.dart';
import 'package:labodc_mobile/models/project_model.dart';
import 'package:labodc_mobile/providers/project_provider.dart';
import 'package:labodc_mobile/widgets/app_button.dart';
import 'package:labodc_mobile/widgets/common_widgets.dart';

class MyProjectsScreen extends StatefulWidget {
  const MyProjectsScreen({super.key});

  @override
  State<MyProjectsScreen> createState() => _MyProjectsScreenState();
}

class _MyProjectsScreenState extends State<MyProjectsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (_initialized) return;
      _initialized = true;
      await context.read<ProjectProvider>().ensureLoaded(
        scope: ProjectDataScope.my,
      );
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProjectProvider>();
    final scopeReady = provider.currentScope == ProjectDataScope.my;
    final hasMyData = scopeReady && provider.hasData;
    final isBlockingLoading = !scopeReady || (provider.isLoading && !hasMyData);
    final hasBlockingError = scopeReady && provider.error != null && !hasMyData;
    final errorMessage = provider.error ?? 'Khong the tai du an cua ban.';

    final activeProjects = scopeReady
        ? provider.activeTalentProjects
        : const <ProjectModel>[];
    final completedProjects = scopeReady
        ? provider.completedTalentProjects
        : const <ProjectModel>[];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Du an cua toi'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.white,
          unselectedLabelColor: AppColors.white,
          indicatorColor: AppColors.white,
          tabs: const [
            Tab(text: 'Dang thuc hien'),
            Tab(text: 'Da hoan thanh'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTabContent(
            provider: provider,
            projects: activeProjects,
            emptyMessage: 'Chua co du an dang thuc hien',
            cardBuilder: _buildActiveProjectCard,
            isLoading: isBlockingLoading,
            hasError: hasBlockingError,
            errorMessage: errorMessage,
          ),
          _buildTabContent(
            provider: provider,
            projects: completedProjects,
            emptyMessage: 'Chua co du an hoan thanh',
            cardBuilder: _buildCompletedProjectCard,
            isLoading: isBlockingLoading,
            hasError: hasBlockingError,
            errorMessage: errorMessage,
          ),
        ],
      ),
    );
  }

  Widget _buildTabContent({
    required ProjectProvider provider,
    required List<ProjectModel> projects,
    required String emptyMessage,
    required Widget Function(ProjectModel, ProjectProvider) cardBuilder,
    required bool isLoading,
    required bool hasError,
    required String errorMessage,
  }) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (hasError) {
      return Center(
        child: EmptyState(icon: Icons.error_outline, message: errorMessage),
      );
    }

    if (projects.isEmpty) {
      return Center(
        child: EmptyState(icon: Icons.folder_open, message: emptyMessage),
      );
    }

    return RefreshIndicator(
      onRefresh: () => provider.loadMyProjects(status: provider.currentFilter),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: projects.length,
        itemBuilder: (context, index) => Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: cardBuilder(projects[index], provider),
        ),
      ),
    );
  }

  Widget _buildActiveProjectCard(
    ProjectModel project,
    ProjectProvider provider,
  ) {
    final progress = _projectProgress(project);
    final progressPercent = (progress * 100).clamp(0, 100).toStringAsFixed(0);
    final remaining = _remainingDays(project);
    final isLeaving =
        provider.isLeavingProject && provider.leavingProjectId == project.id;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.05),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        project.name,
                        style: AppTextStyles.subtitle1.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.business,
                            size: 14,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Doanh nghiep #${project.enterpriseId}',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                _buildStatusChip(project.status),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Tien do du an',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      '$progressPercent%',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                LinearProgressIndicator(
                  value: progress,
                  minHeight: 6,
                  backgroundColor: AppColors.backgroundGrey,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    _statusColor(project.status),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoTile(
                        icon: Icons.calendar_today,
                        label: 'Bat dau',
                        value: _formatDate(project.startDate),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildInfoTile(
                        icon: Icons.event_available,
                        label: 'Ket thuc',
                        value: _formatDate(project.endDate),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoTile(
                        icon: Icons.schedule,
                        label: 'Thoi luong',
                        value: _projectDuration(project),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildInfoTile(
                        icon: Icons.av_timer,
                        label: 'Con lai',
                        value: remaining,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: project.technologies
                      .map(
                        (tech) => Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.info.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            tech,
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.info,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: AppButton(
                        text: 'Xem chi tiet',
                        isOutlined: true,
                        borderColor: AppColors.primary,
                        textColor: AppColors.primary,
                        onPressed: () => _showProjectDetail(project),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AppButton(
                        text: 'Roi du an',
                        backgroundColor: AppColors.error,
                        isLoading: isLeaving,
                        onPressed: () => _confirmLeave(project),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompletedProjectCard(ProjectModel project, ProjectProvider _) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        project.name,
                        style: AppTextStyles.subtitle1.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Hoan thanh: ${_formatDate(project.endDate)}',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                _buildStatusChip(project.status),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              project.description,
              style: AppTextStyles.body2.copyWith(
                color: AppColors.textSecondary,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildInfoTile(
                    icon: Icons.attach_money,
                    label: 'Ngan sach',
                    value: _formatCurrency(project.budget),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildInfoTile(
                    icon: Icons.wallet,
                    label: 'Quy doi 70%',
                    value: _formatCurrency(project.teamFund),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: project.requiredSkills
                  .map(
                    (skill) => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.backgroundGrey,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(skill, style: AppTextStyles.caption),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: AppButton(
                text: 'Xem chi tiet',
                isOutlined: true,
                borderColor: AppColors.primary,
                textColor: AppColors.primary,
                onPressed: () => _showProjectDetail(project),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showProjectDetail(ProjectModel project) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalContext) {
        final progress = _projectProgress(project);
        final progressPercent = (progress * 100)
            .clamp(0, 100)
            .toStringAsFixed(0);
        return DraggableScrollableSheet(
          initialChildSize: 0.85,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (_, controller) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: SingleChildScrollView(
                controller: controller,
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: AppColors.backgroundGrey,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(project.name, style: AppTextStyles.heading5),
                              const SizedBox(height: 4),
                              Text(
                                'Doanh nghiep #${project.enterpriseId}',
                                style: AppTextStyles.caption.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        _buildStatusChip(project.status),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      project.description,
                      style: AppTextStyles.body2.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Muc tieu',
                      style: AppTextStyles.subtitle2.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(project.objective, style: AppTextStyles.body2),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Tien do hien tai',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        Text(
                          '$progressPercent%',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    LinearProgressIndicator(
                      value: progress,
                      minHeight: 6,
                      backgroundColor: AppColors.backgroundGrey,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _statusColor(project.status),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildInfoTile(
                            icon: Icons.calendar_today,
                            label: 'Bat dau',
                            value: _formatDate(project.startDate),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildInfoTile(
                            icon: Icons.event_available,
                            label: 'Ket thuc',
                            value: _formatDate(project.endDate),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildInfoTile(
                            icon: Icons.schedule,
                            label: 'Thoi luong',
                            value: _projectDuration(project),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildInfoTile(
                            icon: Icons.attach_money,
                            label: 'Tong ngan sach',
                            value: _formatCurrency(project.budget),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildInfoTile(
                            icon: Icons.group,
                            label: 'Quy doi 70%',
                            value: _formatCurrency(project.teamFund),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildInfoTile(
                            icon: Icons.school,
                            label: 'Quy mentor 20%',
                            value: _formatCurrency(project.mentorFund),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildInfoTile(
                      icon: Icons.account_balance,
                      label: 'Quy lab 10%',
                      value: _formatCurrency(project.labFund),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Ky nang yeu cau',
                      style: AppTextStyles.subtitle2.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: project.requiredSkills
                          .map(
                            (skill) => Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.backgroundGrey,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Text(skill, style: AppTextStyles.caption),
                            ),
                          )
                          .toList(),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Cong nghe su dung',
                      style: AppTextStyles.subtitle2.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: project.technologies
                          .map(
                            (tech) => Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.info.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                tech,
                                style: AppTextStyles.caption.copyWith(
                                  color: AppColors.info,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: AppButton(
                        text: 'Dong',
                        isOutlined: true,
                        borderColor: AppColors.textSecondary,
                        textColor: AppColors.textSecondary,
                        onPressed: () => Navigator.pop(modalContext),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _confirmLeave(ProjectModel project) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return Consumer<ProjectProvider>(
          builder: (_, provider, __) {
            final isLeaving =
                provider.isLeavingProject &&
                provider.leavingProjectId == project.id;
            return AlertDialog(
              title: const Text('Roi du an?'),
              content: Text(
                'Ban se khong con truy cap tai nguyen va diem thuong cua du an "${project.name}". Xac nhan tiep tuc?',
                style: AppTextStyles.body2.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isLeaving
                      ? null
                      : () => Navigator.pop(dialogContext),
                  child: const Text('Huy'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.error,
                    foregroundColor: AppColors.white,
                  ),
                  onPressed: isLeaving
                      ? null
                      : () async {
                          final success = await provider.leaveProject(
                            project.id,
                          );
                          if (!mounted) return;
                          Navigator.pop(dialogContext);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              backgroundColor: success
                                  ? AppColors.success
                                  : AppColors.error,
                              content: Text(
                                success
                                    ? 'Da roi khoi du an'
                                    : 'Khong the roi du an, vui long thu lai',
                              ),
                            ),
                          );
                        },
                  child: isLeaving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Xac nhan'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.backgroundGrey,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.textSecondary),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 10,
                ),
              ),
              Text(
                value,
                style: AppTextStyles.caption.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(ProjectStatus status) {
    final color = _statusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.displayName,
        style: AppTextStyles.caption.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  double _projectProgress(ProjectModel project) {
    final totalSeconds = project.endDate
        .difference(project.startDate)
        .inSeconds;
    if (totalSeconds <= 0) return 1;
    final elapsedSeconds = DateTime.now()
        .difference(project.startDate)
        .inSeconds;
    final ratio = elapsedSeconds / totalSeconds;
    return ratio.clamp(0.0, 1.0);
  }

  String _remainingDays(ProjectModel project) {
    final now = DateTime.now();
    if (project.endDate.isBefore(now)) {
      return '0 ngay';
    }
    final days = project.endDate.difference(now).inDays;
    return '$days ngay';
  }

  String _projectDuration(ProjectModel project) {
    final days = project.endDate.difference(project.startDate).inDays;
    if (days <= 0) return 'Khong xac dinh';
    final months = (days / 30).round();
    if (months <= 1) return '$days ngay';
    return '$months thang';
  }

  String _formatDate(DateTime dateTime) {
    final day = dateTime.day.toString().padLeft(2, '0');
    final month = dateTime.month.toString().padLeft(2, '0');
    return '$day/$month/${dateTime.year}';
  }

  String _formatCurrency(double amount) {
    if (amount >= 1000000000) {
      return '${(amount / 1000000000).toStringAsFixed(1)}B';
    }
    return '${(amount / 1000000).toStringAsFixed(0)}M';
  }

  Color _statusColor(ProjectStatus status) {
    switch (status) {
      case ProjectStatus.pending:
        return AppColors.warning;
      case ProjectStatus.approved:
      case ProjectStatus.inProgress:
        return AppColors.success;
      case ProjectStatus.completed:
        return AppColors.primary;
      case ProjectStatus.rejected:
      case ProjectStatus.cancelled:
        return AppColors.error;
      case ProjectStatus.draft:
        return AppColors.textSecondary;
    }
  }
}
