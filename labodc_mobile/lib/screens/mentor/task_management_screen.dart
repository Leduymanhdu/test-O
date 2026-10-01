import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:labodc_mobile/core/theme/app_colors.dart';
import 'package:labodc_mobile/core/theme/app_text_styles.dart';
import 'package:labodc_mobile/widgets/common_widgets.dart';
import 'package:labodc_mobile/widgets/app_button.dart';

class TaskManagementScreen extends StatefulWidget {
  const TaskManagementScreen({super.key});

  @override
  State<TaskManagementScreen> createState() => _TaskManagementScreenState();
}

class _TaskManagementScreenState extends State<TaskManagementScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedFilter = 'ALL';

  // Mock data
  final List<Map<String, dynamic>> _tasks = [
    {
      'id': 'T001',
      'name': 'Setup project structure',
      'description': 'Initialize React project, configure ESLint, Prettier',
      'assignedTo': 'Tran Thi C',
      'priority': 'HIGH',
      'startDate': '2026-02-01',
      'dueDate': '2026-02-03',
      'estimatedHours': 8,
      'status': 'COMPLETED',
      'completedAt': '2026-02-02',
      'tags': ['setup', 'frontend'],
    },
    {
      'id': 'T002',
      'name': 'Design database schema',
      'description': 'Create ERD, define tables, relationships',
      'assignedTo': 'Nguyen Van D',
      'priority': 'HIGH',
      'startDate': '2026-02-01',
      'dueDate': '2026-02-05',
      'estimatedHours': 16,
      'status': 'IN_PROGRESS',
      'completedAt': null,
      'tags': ['database', 'backend'],
    },
    {
      'id': 'T003',
      'name': 'Implement user authentication',
      'description': 'JWT auth, login/register endpoints',
      'assignedTo': 'Le Thi E',
      'priority': 'CRITICAL',
      'startDate': '2026-02-03',
      'dueDate': '2026-02-08',
      'estimatedHours': 20,
      'status': 'TODO',
      'completedAt': null,
      'tags': ['security', 'backend'],
    },
    {
      'id': 'T004',
      'name': 'Create product listing page',
      'description': 'Responsive product grid with filters',
      'assignedTo': 'Tran Thi C',
      'priority': 'MEDIUM',
      'startDate': '2026-02-05',
      'dueDate': '2026-02-10',
      'estimatedHours': 12,
      'status': 'TODO',
      'completedAt': null,
      'tags': ['frontend', 'ui'],
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

  Future<void> _uploadExcelFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx', 'xls'],
      );

      if (result != null) {
        // TODO: Call API to upload and parse Excel file
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Đã upload file: ${result.files.first.name}'),
              backgroundColor: AppColors.success,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Lỗi khi upload file'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _downloadTemplate() {
    // TODO: Download Excel template
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Đang tải template...'),
        backgroundColor: AppColors.info,
      ),
    );
  }

  List<Map<String, dynamic>> _getFilteredTasks() {
    if (_selectedFilter == 'ALL') return _tasks;
    return _tasks.where((task) => task['status'] == _selectedFilter).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý Nhiệm vụ'),
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
          // Upload/Download section
          Container(
            padding: const EdgeInsets.all(16),
            color: AppColors.backgroundGrey,
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: AppButton(
                        text: 'Upload Excel',
                        onPressed: _uploadExcelFile,
                        icon: Icons.upload_file,
                        backgroundColor: AppColors.success,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AppButton(
                        text: 'Tải Template',
                        onPressed: _downloadTemplate,
                        icon: Icons.download,
                        backgroundColor: AppColors.white,
                        textColor: AppColors.primary,
                        borderColor: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Hỗ trợ file Excel (.xlsx, .xls). Tối đa 10MB',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          // Task statistics
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: _buildStatChip('Tổng', _tasks.length, AppColors.primary),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildStatChip('Cần làm', _tasks.where((t) => t['status'] == 'TODO').length, AppColors.warning),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildStatChip('Đang làm', _tasks.where((t) => t['status'] == 'IN_PROGRESS').length, AppColors.info),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildStatChip('Xong', _tasks.where((t) => t['status'] == 'COMPLETED').length, AppColors.success),
                ),
              ],
            ),
          ),

          // Task list
          Expanded(
            child: _getFilteredTasks().isEmpty
                ? Center(
                    child: EmptyState(
                      icon: Icons.task_outlined,
                      message: 'Chưa có nhiệm vụ nào',
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _getFilteredTasks().length,
                    itemBuilder: (context, index) {
                      final task = _getFilteredTasks()[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _buildTaskCard(task),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Add new task manually
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Tính năng thêm task thủ công đang phát triển')),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildStatChip(String label, int count, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
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
    final statusColor = _getStatusColor(task['status']);
    final priorityColor = _getPriorityColor(task['priority']);

    return AppCard(
      onTap: () {
        _showTaskDetail(task);
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.backgroundGrey,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  task['id'],
                  style: AppTextStyles.caption.copyWith(
                    fontWeight: FontWeight.bold,
                    fontFamily: 'monospace',
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
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Spacer(),
              StatusBadge(
                label: _getStatusLabel(task['status']),
                color: statusColor,
              ),
            ],
          ),
          const SizedBox(height: 12),

          Text(
            task['name'],
            style: AppTextStyles.subtitle2.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),

          Text(
            task['description'],
            style: AppTextStyles.body2.copyWith(
              color: AppColors.textSecondary,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              Icon(Icons.person_outline, size: 14, color: AppColors.textSecondary),
              const SizedBox(width: 4),
              Text(
                task['assignedTo'],
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(width: 16),
              Icon(Icons.schedule, size: 14, color: AppColors.textSecondary),
              const SizedBox(width: 4),
              Text(
                '${task['estimatedHours']}h',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(width: 16),
              Icon(Icons.event, size: 14, color: AppColors.textSecondary),
              const SizedBox(width: 4),
              Text(
                task['dueDate'],
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),

          if ((task['tags'] as List).isNotEmpty) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 4,
              runSpacing: 4,
              children: (task['tags'] as List).map((tag) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    tag,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.primary,
                      fontSize: 10,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'TODO':
        return AppColors.warning;
      case 'IN_PROGRESS':
        return AppColors.info;
      case 'COMPLETED':
        return AppColors.success;
      default:
        return AppColors.textSecondary;
    }
  }

  String _getStatusLabel(String status) {
    switch (status) {
      case 'TODO':
        return 'Cần làm';
      case 'IN_PROGRESS':
        return 'Đang làm';
      case 'COMPLETED':
        return 'Hoàn thành';
      default:
        return status;
    }
  }

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'CRITICAL':
        return AppColors.error;
      case 'HIGH':
        return AppColors.warning;
      case 'MEDIUM':
        return AppColors.info;
      case 'LOW':
        return AppColors.textSecondary;
      default:
        return AppColors.textSecondary;
    }
  }

  void _showTaskDetail(Map<String, dynamic> task) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
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
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task['name'],
                        style: AppTextStyles.heading2.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildDetailRow('Mô tả', task['description']),
                      _buildDetailRow('Người thực hiện', task['assignedTo']),
                      _buildDetailRow('Độ ưu tiên', task['priority']),
                      _buildDetailRow('Trạng thái', _getStatusLabel(task['status'])),
                      _buildDetailRow('Ngày bắt đầu', task['startDate']),
                      _buildDetailRow('Ngày hết hạn', task['dueDate']),
                      _buildDetailRow('Thời gian ước tính', '${task['estimatedHours']} giờ'),
                      if (task['completedAt'] != null)
                        _buildDetailRow('Hoàn thành lúc', task['completedAt']),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
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
            style: AppTextStyles.body1.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}


