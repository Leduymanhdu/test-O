import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:labodc_mobile/core/enums/app_enums.dart';
import 'package:labodc_mobile/core/theme/app_colors.dart';
import 'package:labodc_mobile/core/theme/app_text_styles.dart';
import 'package:labodc_mobile/models/project_model.dart';
import 'package:labodc_mobile/providers/project_provider.dart';
import 'package:labodc_mobile/widgets/app_button.dart';
import 'package:labodc_mobile/widgets/common_widgets.dart';

class BrowseProjectsScreen extends StatefulWidget {
  const BrowseProjectsScreen({super.key});

  @override
  State<BrowseProjectsScreen> createState() => _BrowseProjectsScreenState();
}

class _BrowseProjectsScreenState extends State<BrowseProjectsScreen> {
  String _selectedTech = 'ALL';
  String _sortBy = 'newest';
  String _searchTerm = '';
  String _statusFilter = 'active';
  bool _initialized = false;
  String? _lastLoadMoreError;
  final ScrollController _listController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (_initialized) return;
      _initialized = true;
      await context.read<ProjectProvider>().ensureLoaded();
    });
    _listController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _listController.removeListener(_onScroll);
    _listController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProjectProvider>();
    _maybeShowLoadMoreError(provider.loadMoreError);
    final techFilters = _buildTechnologyFilters(provider);
    final projects = _filteredProjects(provider);
    final isLoading = provider.isLoading && !provider.hasData;
    final hasError = provider.error != null && !provider.hasData;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Duyệt Dự án'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort),
            onSelected: (value) {
              setState(() => _sortBy = value);
              context.read<ProjectProvider>().setSort(value);
            },
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'newest', child: Text('Mới nhất')),
              PopupMenuItem(value: 'budget', child: Text('Ngân sách cao')),
              PopupMenuItem(value: 'deadline', child: Text('Hạn chót gần')),
            ],
          ),
          PopupMenuButton<int>(
            initialValue: context.watch<ProjectProvider>().pageSize,
            icon: const Icon(Icons.tune),
            onSelected: (size) =>
                context.read<ProjectProvider>().setPageSize(size),
            itemBuilder: (context) => const [
              PopupMenuItem(value: 10, child: Text('10 / trang')),
              PopupMenuItem(value: 20, child: Text('20 / trang')),
              PopupMenuItem(value: 50, child: Text('50 / trang')),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Tìm kiếm dự án theo tên',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
                isDense: true,
              ),
              onChanged: (value) => setState(() => _searchTerm = value),
              onSubmitted: (value) => context
                  .read<ProjectProvider>()
                  .setSearchTerm(value),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ChoiceChip(
                  label: const Text('Đang mở'),
                  selected: _statusFilter == 'active',
                  onSelected: (_) => _onStatusChanged('active'),
                ),
                ChoiceChip(
                  label: const Text('Hoàn thành'),
                  selected: _statusFilter == 'completed',
                  onSelected: (_) => _onStatusChanged('completed'),
                ),
                ChoiceChip(
                  label: const Text('Tất cả'),
                  selected: _statusFilter == 'all',
                  onSelected: (_) => _onStatusChanged('all'),
                ),
              ],
            ),
          ),
          Container(
            height: 50,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: techFilters.length,
              itemBuilder: (context, index) {
                final tech = techFilters[index];
                final isSelected = tech == _selectedTech;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(tech),
                    selected: isSelected,
                    onSelected: (_) => setState(() => _selectedTech = tech),
                    backgroundColor: AppColors.white,
                    selectedColor: AppColors.primary.withValues(alpha: 0.2),
                    checkmarkColor: AppColors.primary,
                    labelStyle: TextStyle(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.textPrimary,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                  ),
                );
              },
            ),
          ),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : hasError
                ? const Center(
                    child: EmptyState(
                      icon: Icons.error_outline,
                      message:
                          'Không thể tải danh sách dự án. Kéo xuống để thử lại.',
                    ),
                  )
                : projects.isEmpty
                ? const Center(
                    child: EmptyState(
                      icon: Icons.search_off,
                      message: 'Không tìm thấy dự án phù hợp',
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: () => provider.refresh(),
                    child: ListView.builder(
                      controller: _listController,
                      padding: const EdgeInsets.all(16),
                      itemCount: projects.length + (provider.hasMore ? 1 : 0),
                      itemBuilder: (context, index) => Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: index >= projects.length
                            ? _buildLoadMoreStatus(provider)
                            : _buildProjectCard(projects[index], provider),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadMoreStatus(ProjectProvider provider) {
    if (provider.isLoadingMore) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 12),
          child: CircularProgressIndicator(),
        ),
      );
    }
    if (provider.loadMoreError != null) {
      return Column(
        children: [
          Text(
            'Tải thêm thất bại. Chạm để thử lại.',
            style: AppTextStyles.caption.copyWith(color: AppColors.error),
          ),
          const SizedBox(height: 8),
          AppButton(
            text: 'Thử lại',
            height: 40,
            onPressed: () => provider.loadMore(),
            isOutlined: true,
            borderColor: AppColors.error,
            textColor: AppColors.error,
            backgroundColor: AppColors.white,
          ),
        ],
      );
    }
    return const SizedBox.shrink();
  }

  void _onScroll() {
    final provider = context.read<ProjectProvider>();
    if (!provider.hasMore || provider.isLoadingMore) return;
    if (_listController.position.extentAfter < 200) {
      provider.loadMore();
    }
  }

  void _onStatusChanged(String value) {
    setState(() => _statusFilter = value);
    final status = value == 'completed' ? ProjectStatus.completed : null;
    context.read<ProjectProvider>().loadProjects(status: status);
  }

  void _maybeShowLoadMoreError(String? message) {
    if (message == null) {
      _lastLoadMoreError = null;
      return;
    }
    if (_lastLoadMoreError == message) return;
    _lastLoadMoreError = message;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Tai them that bai, vui long thu lai.'),
          backgroundColor: AppColors.error,
          duration: const Duration(seconds: 3),
        ),
      );
    });
  }

  List<ProjectModel> _filteredProjects(ProjectProvider provider) {
    List<ProjectModel> items = provider.allProjects;
    items = items.where((project) {
      switch (_statusFilter) {
        case 'completed':
          return project.status == ProjectStatus.completed;
        case 'all':
          return true;
        default:
          return project.status == ProjectStatus.pending ||
              project.status == ProjectStatus.approved ||
              project.status == ProjectStatus.inProgress;
      }
    }).toList();

    if (_selectedTech != 'ALL') {
      items = items
          .where((project) => project.technologies.contains(_selectedTech))
          .toList();
    }

    if (_searchTerm.trim().isNotEmpty) {
      final term = _searchTerm.toLowerCase();
      items = items
          .where((project) => project.name.toLowerCase().contains(term))
          .toList();
    }

    switch (_sortBy) {
      case 'budget':
        items.sort((a, b) => b.budget.compareTo(a.budget));
        break;
      case 'deadline':
        items.sort((a, b) => a.endDate.compareTo(b.endDate));
        break;
      default:
        items.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }

    return items;
  }

  List<String> _buildTechnologyFilters(ProjectProvider provider) {
    final techs = provider.availableTechnologies;
    if (techs.isEmpty) {
      return const ['ALL'];
    }
    return ['ALL', ...techs];
  }

  void _showJoinDialog(ProjectModel project) {
    final scaffoldContext = context;
    final messageController = TextEditingController();
    final provider = context.read<ProjectProvider>();
    bool isSubmitting = false;

    showDialog(
      context: scaffoldContext,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Đăng ký tham gia dự án'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    project.name,
                    style: AppTextStyles.subtitle1.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: messageController,
                    decoration: const InputDecoration(
                      labelText: 'Lời nhắn tới doanh nghiệp',
                      hintText: 'Giới thiệu ngắn về bản thân và lý do tham gia',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 4,
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: isSubmitting
                      ? null
                      : () => Navigator.pop(dialogContext),
                  child: const Text('Hủy'),
                ),
                ElevatedButton(
                  onPressed: isSubmitting
                      ? null
                      : () async {
                          setState(() => isSubmitting = true);
                          final success = await provider.submitTalentApplication(
                            projectId: project.id,
                            message: messageController.text.trim(),
                          );

                          if (!mounted || !dialogContext.mounted) return;

                          Navigator.pop(dialogContext);
                          ScaffoldMessenger.of(scaffoldContext).showSnackBar(
                            SnackBar(
                              backgroundColor: success
                                  ? AppColors.success
                                  : AppColors.error,
                              content: Text(
                                success
                                    ? 'Đã gửi yêu cầu tham gia dự án'
                                    : 'Gửi yêu cầu thất bại, vui lòng thử lại',
                              ),
                            ),
                          );
                        },
                  child: isSubmitting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Gửi yêu cầu'),
                ),
              ],
            );
          },
        );
      },
    ).whenComplete(() => messageController.dispose());
  }

  Widget _buildProjectCard(ProjectModel project, ProjectProvider provider) {
    final isSubmitting =
        provider.isSubmittingApplication &&
        provider.submittingProjectId == project.id;
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
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                  child: Text(
                    'D${project.enterpriseId}',
                    style: AppTextStyles.subtitle1.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
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
                        'Doanh nghiệp #${project.enterpriseId}',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textSecondary,
                        ),
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
                    color: AppColors.success.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.people, size: 14, color: AppColors.success),
                      const SizedBox(width: 4),
                      Text(
                        '${project.requiredTalents} chỗ',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.success,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  project.description,
                  style: AppTextStyles.body2.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
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
                            color: AppColors.info.withValues(alpha: 0.1),
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
                      child: _buildInfoItem(
                        Icons.calendar_today,
                        'Thời gian',
                        _projectDuration(project),
                      ),
                    ),
                    Expanded(
                      child: _buildInfoItem(
                        Icons.attach_money,
                        'Ngân sách',
                        _formatCurrency(project.budget),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoItem(
                        Icons.people,
                        'Số thành viên',
                        '${project.requiredTalents} sinh viên',
                      ),
                    ),
                    Expanded(
                      child: _buildInfoItem(
                        Icons.event,
                        'Bắt đầu',
                        _formatDate(project.startDate),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: AppButton(
                    text: 'Đăng ký tham gia',
                    isLoading: isSubmitting,
                    onPressed: () => _showJoinDialog(project),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.textSecondary),
        const SizedBox(width: 4),
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
    );
  }

  String _projectDuration(ProjectModel project) {
    final days = project.endDate.difference(project.startDate).inDays;
    if (days <= 0) return 'Không xác định';
    final months = (days / 30).round();
    if (months <= 1) {
      return '$days ngày';
    }
    return '$months tháng';
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
}
