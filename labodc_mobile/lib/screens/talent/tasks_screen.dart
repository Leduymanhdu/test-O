import 'package:flutter/material.dart';
import 'package:labodc_mobile/core/theme/app_colors.dart';
import 'package:labodc_mobile/core/theme/app_text_styles.dart';
import 'package:labodc_mobile/widgets/common_widgets.dart';

class TalentTasksScreen extends StatefulWidget {
  const TalentTasksScreen({super.key});

  @override
  State<TalentTasksScreen> createState() => _TalentTasksScreenState();
}

class _TalentTasksScreenState extends State<TalentTasksScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedFilter = 'ALL';

  final List<Map<String, dynamic>> _tasks = [
    {
      'id': 'TASK-101',
      'title': 'Hoàn thiện Dashboard UI',
      'project': 'Website Quản lý Bán hàng',
      'description': 'Implement responsive dashboard với charts và statistics',
      'dueDate': '2026-02-15',
      'priority': 'HIGH',
      'status': 'IN_PROGRESS',
      'estimatedHours': 8,
      'actualHours': 5,
      'assignedDate': '2026-02-08',
    },
    {
      'id': 'TASK-102',
      'title': 'Review code Backend API',
      'project': 'Website Quản lý Bán hàng',
      'description': 'Code review cho các API endpoints: authentication, products, orders',
      'dueDate': '2026-02-18',
      'priority': 'MEDIUM',
      'status': 'TODO',
      'estimatedHours': 4,
      'actualHours': 0,
      'assignedDate': '2026-02-10',
    },
    {
      'id': 'TASK-103',
      'title': 'Thiết kế Product Detail screen',
      'project': 'Mobile App E-commerce',
      'description': 'Design product detail page với image carousel, ratings, reviews',
      'dueDate': '2026-02-20',
      'priority': 'HIGH',
      'status': 'TODO',
      'estimatedHours': 6,
      'actualHours': 0,
      'assignedDate': '2026-02-12',
    },
    {
      'id': 'TASK-104',
      'title': 'Unit testing cho Auth module',
      'project': 'Website Quản lý Bán hàng',
      'description': 'Viết unit tests cho login, register, forgot password',
      'dueDate': '2026-02-12',
      'priority': 'LOW',
      'status': 'COMPLETED',
      'estimatedHours': 3,
      'actualHours': 3.5,
      'assignedDate': '2026-02-05',
      'completedDate': '2026-02-11',
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _filteredTasks {
    if (_selectedFilter == 'ALL') return _tasks;
    return _tasks.where((t) => t['status'] == _selectedFilter).toList();
  }

  void _showTaskDetail(Map<String, dynamic> task) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) => Container(
          padding: const EdgeInsets.all(24),
          child: ListView(
            controller: scrollController,
            children: [
              Row(
                children: [
                  Text(task['id'], style: AppTextStyles.heading3),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(height: 24),
              
              Text(
                task['title'],
                style: AppTextStyles.heading2.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                task['project'],
                style: AppTextStyles.body2.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),

              const SizedBox(height: 24),
              Text('Mô tả', style: AppTextStyles.subtitle1),
              const SizedBox(height: 8),
              Text(
                task['description'],
                style: AppTextStyles.body2,
              ),

              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: _buildDetailItem('Độ ưu tiên', task['priority']),
                  ),
                  Expanded(
                    child: _buildDetailItem('Trạng thái', task['status']),
                  ),
                ],
              ),

              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildDetailItem('Thời gian ước tính', '${task['estimatedHours']}h'),
                  ),
                  Expanded(
                    child: _buildDetailItem('Thời gian thực tế', '${task['actualHours']}h'),
                  ),
                ],
              ),

              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildDetailItem('Giao việc', task['assignedDate']),
                  ),
                  Expanded(
                    child: _buildDetailItem('Hạn chót', task['dueDate']),
                  ),
                ],
              ),

              if (task['status'] == 'COMPLETED') ...[
                const SizedBox(height: 16),
                _buildDetailItem('Hoàn thành', task['completedDate']),
              ],

              const SizedBox(height: 24),
              if (task['status'] != 'COMPLETED')
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Đã đánh dấu nhiệm vụ hoàn thành'),
                        backgroundColor: AppColors.success,
                      ),
                    );
                  },
                  icon: const Icon(Icons.check_circle),
                  label: const Text('Đánh dấu hoàn thành'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nhiệm vụ của tôi'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.white,
          unselectedLabelColor: AppColors.white,
          indicatorColor: AppColors.white,
          tabs: const [
            Tab(text: 'Tất cả'),
            Tab(text: 'Cần làm'),
            Tab(text: 'Đang làm'),
            Tab(text: 'Hoàn thành'),
          ],
          onTap: (index) {
            setState(() {
              _selectedFilter = ['ALL', 'TODO', 'IN_PROGRESS', 'COMPLETED'][index];
            });
          },
        ),
      ),
      body: Column(
        children: [
          // Task statistics
          Container(
            padding: const EdgeInsets.all(16),
            color: AppColors.backgroundGrey,
            child: Row(
              children: [
                Expanded(
                  child: _buildStatChip(
                    'Tổng',
                    _tasks.length,
                    AppColors.primary,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildStatChip(
                    'Cần làm',
                    _tasks.where((t) => t['status'] == 'TODO').length,
                    AppColors.warning,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildStatChip(
                    'Đang làm',
                    _tasks.where((t) => t['status'] == 'IN_PROGRESS').length,
                    AppColors.info,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildStatChip(
                    'Xong',
                    _tasks.where((t) => t['status'] == 'COMPLETED').length,
                    AppColors.success,
                  ),
                ),
              ],
            ),
          ),

          // Task list
          Expanded(
            child: _filteredTasks.isEmpty
                ? const Center(
                    child: EmptyState(
                      icon: Icons.task_outlined,
                      message: 'Chưa có nhiệm vụ nào',
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _filteredTasks.length,
                    itemBuilder: (context, index) {
                      final task = _filteredTasks[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _buildTaskCard(task),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip(String label, int count, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            '$count',
            style: AppTextStyles.heading3.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: color,
            ),
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

    final statusColor = task['status'] == 'COMPLETED'
        ? AppColors.success
        : task['status'] == 'IN_PROGRESS'
            ? AppColors.info
            : AppColors.textSecondary;

    return InkWell(
      onTap: () => _showTaskDetail(task),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: task['status'] == 'COMPLETED'
                ? AppColors.success.withValues(alpha: 0.3)
                : AppColors.divider,
          ),
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
                const SizedBox(width: 8),
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
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    task['status'],
                    style: AppTextStyles.caption.copyWith(
                      color: statusColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              task['title'],
              style: AppTextStyles.subtitle2.copyWith(
                fontWeight: FontWeight.w600,
                decoration: task['status'] == 'COMPLETED'
                    ? TextDecoration.lineThrough
                    : null,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              task['project'],
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.calendar_today, size: 14, color: AppColors.textSecondary),
                const SizedBox(width: 4),
                Text(
                  'Hạn: ${task['dueDate']}',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const Spacer(),
                Icon(Icons.access_time, size: 14, color: AppColors.textSecondary),
                const SizedBox(width: 4),
                Text(
                  '${task['actualHours']}/${task['estimatedHours']}h',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTextStyles.body2.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

