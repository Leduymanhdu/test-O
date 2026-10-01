import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:labodc_mobile/core/routes/app_router.dart';
import 'package:labodc_mobile/core/theme/app_colors.dart';
import 'package:labodc_mobile/core/theme/app_text_styles.dart';

class TalentDashboardScreen extends StatefulWidget {
  const TalentDashboardScreen({super.key});

  @override
  State<TalentDashboardScreen> createState() => _TalentDashboardScreenState();
}

class _TalentDashboardScreenState extends State<TalentDashboardScreen> {
  // Mock data
  final Map<String, dynamic> _stats = {
    'currentProjects': 2,
    'completedProjects': 3,
    'tasksInProgress': 8,
    'upcomingDeadlines': 3,
    'totalEarnings': 35000000,
    'averageRating': 4.5,
  };

  final List<Map<String, dynamic>> _activeProjects = [
    {
      'id': 789,
      'title': 'Website Quản lý Bán hàng',
      'company': 'ABC Technology',
      'role': 'Frontend Developer',
      'progress': 65,
      'daysLeft': 45,
      'myTasks': 5,
      'completedTasks': 3,
    },
    {
      'id': 788,
      'title': 'Mobile App E-commerce',
      'company': 'XYZ Corp',
      'role': 'UI/UX Designer',
      'progress': 35,
      'daysLeft': 90,
      'myTasks': 4,
      'completedTasks': 1,
    },
  ];

  final List<Map<String, dynamic>> _upcomingTasks = [
    {
      'id': 'TASK-101',
      'title': 'Hoàn thiện Dashboard UI',
      'project': 'Website Quản lý Bán hàng',
      'dueDate': '2026-02-15',
      'priority': 'HIGH',
      'status': 'IN_PROGRESS',
    },
    {
      'id': 'TASK-102',
      'title': 'Review code Backend API',
      'project': 'Website Quản lý Bán hàng',
      'dueDate': '2026-02-18',
      'priority': 'MEDIUM',
      'status': 'TODO',
    },
    {
      'id': 'TASK-103',
      'title': 'Thiết kế Product Detail screen',
      'project': 'Mobile App E-commerce',
      'dueDate': '2026-02-20',
      'priority': 'HIGH',
      'status': 'TODO',
    },
  ];

  Future<void> _refreshData() async {
    await Future.delayed(const Duration(seconds: 1));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Talent Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              context.go('/login');
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Stats Cards
              Text('Tổng quan', style: AppTextStyles.heading3),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      'Dự án',
                      '${_stats['currentProjects']}',
                      Icons.folder_outlined,
                      AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      'Nhiệm vụ',
                      '${_stats['tasksInProgress']}',
                      Icons.task_outlined,
                      AppColors.warning,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      'Hoàn thành',
                      '${_stats['completedProjects']}',
                      Icons.check_circle_outline,
                      AppColors.success,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      'Đánh giá',
                      '${_stats['averageRating']}/5',
                      Icons.star_outline,
                      AppColors.info,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Quick actions
              Text('Hành động nhanh', style: AppTextStyles.heading3),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildQuickActionButton(
                      'Duyệt dự án',
                      Icons.search,
                      AppColors.primary,
                      () => context.push(AppRoutes.browseProjects),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildQuickActionButton(
                      'Nhiệm vụ',
                      Icons.task_outlined,
                      AppColors.warning,
                      () => context.push(AppRoutes.talentTasks),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildQuickActionButton(
                      'Hồ sơ',
                      Icons.person_outline,
                      AppColors.success,
                      () => context.push(AppRoutes.talentProfile),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Active projects
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Dự án đang tham gia', style: AppTextStyles.heading3),
                  TextButton(
                    onPressed: () => context.push(AppRoutes.myProjects),
                    child: const Text('Xem tất cả'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ..._activeProjects.map(
                (project) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildProjectCard(project),
                ),
              ),

              const SizedBox(height: 24),

              // Upcoming tasks
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Nhiệm vụ sắp tới', style: AppTextStyles.heading3),
                  TextButton(
                    onPressed: () => context.push(AppRoutes.talentTasks),
                    child: const Text('Xem tất cả'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ..._upcomingTasks.map(
                (task) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildTaskCard(task),
                ),
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
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
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: AppTextStyles.heading2.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: AppTextStyles.body2.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionButton(
    String label,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              label,
              style: AppTextStyles.caption.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProjectCard(Map<String, dynamic> project) {
    return Container(
      padding: const EdgeInsets.all(16),
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
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      project['title'],
                      style: AppTextStyles.subtitle1.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.business,
                          size: 14,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          project['company'],
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  project['role'],
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tiến độ',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    LinearProgressIndicator(
                      value: project['progress'] / 100,
                      backgroundColor: AppColors.backgroundGrey,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        project['progress'] >= 70
                            ? AppColors.success
                            : project['progress'] >= 40
                            ? AppColors.warning
                            : AppColors.error,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${project['progress']}%',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 24),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${project['daysLeft']} ngày',
                    style: AppTextStyles.subtitle2.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'còn lại',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.task_alt, size: 16, color: AppColors.success),
              const SizedBox(width: 4),
              Text(
                '${project['completedTasks']}/${project['myTasks']} nhiệm vụ hoàn thành',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTaskCard(Map<String, dynamic> task) {
    final priorityColor = task['priority'] == 'HIGH'
        ? AppColors.error
        : task['priority'] == 'MEDIUM'
        ? AppColors.warning
        : AppColors.info;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: priorityColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  task['id'],
                  style: AppTextStyles.caption.copyWith(
                    color: priorityColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: priorityColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  task['priority'],
                  style: AppTextStyles.caption.copyWith(
                    color: priorityColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            task['title'],
            style: AppTextStyles.subtitle2.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            task['project'],
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.calendar_today,
                size: 14,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 4),
              Text(
                'Hạn: ${task['dueDate']}',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
