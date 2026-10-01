import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:labodc_mobile/core/enums/app_enums.dart';
import 'package:labodc_mobile/core/routes/app_router.dart';
import 'package:labodc_mobile/core/theme/app_colors.dart';
import 'package:labodc_mobile/core/theme/app_text_styles.dart';
import 'package:labodc_mobile/models/project_model.dart';
import 'package:labodc_mobile/providers/auth_provider.dart';
import 'package:labodc_mobile/providers/project_provider.dart';
import 'package:labodc_mobile/widgets/app_button.dart';
import 'package:labodc_mobile/widgets/common_widgets.dart';

class _TabConfig {
  final String label;
  final ProjectStatus? status;

  const _TabConfig(this.label, this.status);
}

class EnterpriseProjectListScreen extends StatefulWidget {
  const EnterpriseProjectListScreen({super.key});

  @override
  State<EnterpriseProjectListScreen> createState() =>
      _EnterpriseProjectListScreenState();
}

class _EnterpriseProjectListScreenState
    extends State<EnterpriseProjectListScreen> {
  final ScrollController _scrollController = ScrollController();
  final ScrollController _listController = ScrollController();
  final List<_TabConfig> _tabs = const [
    _TabConfig('Tat ca', null),
    _TabConfig('Cho duyet', ProjectStatus.pending),
    _TabConfig('Dang thuc hien', ProjectStatus.inProgress),
    _TabConfig('Hoan thanh', ProjectStatus.completed),
    _TabConfig('Da tu choi', ProjectStatus.rejected),
  ];
  ProjectStatus? _selectedStatus;
  int? _enterpriseUserId;
  bool _initialized = false;
  String? _lastLoadMoreError;
  String _searchTerm = '';
  String _sortBy = 'newest';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
    _listController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _listController.removeListener(_onScroll);
    _listController.dispose();
    _scrollController.dispose();
    super.dispose();
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

  void _selectTab(ProjectStatus? status) {
    setState(() => _selectedStatus = status);
    final provider = context.read<ProjectProvider>();
    provider.setFilter(status);

    if (_enterpriseUserId != null) {
      provider.loadEnterpriseProjects(_enterpriseUserId!, status: status);
    } else {
      provider.loadProjects(status: status);
    }

    final index = _tabs.indexWhere((tab) => tab.status == status);
    if (index != -1 && _scrollController.hasClients) {
      const tabWidth = 140.0;
      final screenWidth = MediaQuery.of(context).size.width;
      final target = (index * tabWidth) - (screenWidth / 2) + (tabWidth / 2);

      _scrollController.animateTo(
        target.clamp(0.0, _scrollController.position.maxScrollExtent),
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeInOut,
      );
    }
  }

  void _onScroll() {
    final provider = context.read<ProjectProvider>();
    if (!provider.hasMore || provider.isLoadingMore) return;
    if (_listController.position.extentAfter < 200) {
      provider.loadMore(enterpriseId: _enterpriseUserId);
    }
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

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProjectProvider>();
    _maybeShowLoadMoreError(provider.loadMoreError);
    final projects = provider.projects;
    final isLoading = provider.isLoading && projects.isEmpty;
    final hasError = provider.error != null && projects.isEmpty;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Du an cua toi'),
        actions: [
          PopupMenuButton<String>(
            initialValue: _sortBy,
            icon: const Icon(Icons.sort),
            onSelected: (value) {
              setState(() => _sortBy = value);
              context.read<ProjectProvider>().setSort(value);
            },
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'newest', child: Text('Moi nhat')),
              PopupMenuItem(value: 'budget', child: Text('Ngan sach cao')),
              PopupMenuItem(value: 'deadline', child: Text('Han gan')),
            ],
          ),
          PopupMenuButton<int>(
            initialValue: provider.pageSize,
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
                hintText: 'Tim kiem theo ten du an',
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
          Container(
            color: AppColors.white,
            height: 56,
            child: ListView(
              controller: _scrollController,
              scrollDirection: Axis.horizontal,
              children: _tabs.map((tab) {
                final count = tab.status == null
                    ? provider.totalCount()
                    : provider.countByStatus(tab.status!);
                return _buildTab(tab.label, tab.status, count);
              }).toList(),
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : hasError
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        'Khong the tai danh sach du an. Keo xuong de thu lai.',
                        style: AppTextStyles.body2,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                : _buildContent(projects),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(AppRoutes.projectProposal),
        icon: const Icon(Icons.add),
        label: const Text('De xuat du an'),
      ),
    );
  }

  Widget _buildTab(String label, ProjectStatus? value, int count) {
    final isSelected = _selectedStatus == value;
    return InkWell(
      onTap: () => _selectTab(value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isSelected ? AppColors.primary : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Row(
          children: [
            Text(
              label,
              style: AppTextStyles.subtitle2.copyWith(
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            if (count > 0) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
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
    );
  }

  Widget _buildContent(List<ProjectModel> projects) {
    final provider = context.watch<ProjectProvider>();
    final filtered = _searchTerm.trim().isEmpty
        ? projects
        : projects
            .where(
              (p) => p.name.toLowerCase().contains(
                    _searchTerm.toLowerCase(),
                  ),
            )
            .toList();

    _sortProjects(filtered);
    if (projects.isEmpty) {
      return RefreshIndicator(
        onRefresh: () => context.read<ProjectProvider>().refresh(
          enterpriseId: _enterpriseUserId,
        ),
        child: ListView(
          children: const [
            SizedBox(height: 120),
            EmptyState(icon: Icons.folder_open, message: 'Chua co du an nao'),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => context.read<ProjectProvider>().refresh(
        enterpriseId: _enterpriseUserId,
      ),
      child: ListView.separated(
        controller: _listController,
        padding: const EdgeInsets.all(16),
        itemCount: filtered.length + (provider.hasMore ? 1 : 0),
        separatorBuilder: (_, __) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          if (index >= filtered.length) {
            if (provider.isLoadingMore) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: CircularProgressIndicator(),
                ),
              );
            }
            if (provider.loadMoreError != null) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  children: [
                    Text(
                      'Tải thêm thất bại. Chạm để thử lại.',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.error,
                      ),
                    ),
                    const SizedBox(height: 8),
                    AppButton(
                      text: 'Thử lại',
                      height: 40,
                      onPressed: () => context
                          .read<ProjectProvider>()
                          .loadMore(enterpriseId: _enterpriseUserId),
                      isOutlined: true,
                      borderColor: AppColors.error,
                      textColor: AppColors.error,
                      backgroundColor: AppColors.white,
                    ),
                  ],
                ),
              );
            }
            return const SizedBox.shrink();
          }
          return _buildProjectCard(filtered[index]);
        },
      ),
    );
  }

  void _sortProjects(List<ProjectModel> items) {
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
  }

  Widget _buildProjectCard(ProjectModel project) {
    final statusColor = _statusColor(project.status);
    final statusLabel = _statusLabel(project.status);

    return AppCard(
      padding: EdgeInsets.zero,
      child: InkWell(
        onTap: () => _viewProjectDetail(project),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(project.name, style: AppTextStyles.heading4),
                  ),
                  StatusBadge(label: statusLabel, color: statusColor),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                project.objective,
                style: AppTextStyles.body2.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 16,
                runSpacing: 8,
                children: [
                  _buildInfoRow(
                    Icons.event,
                    '${_formatDate(project.startDate)} - ${_formatDate(project.endDate)}',
                  ),
                  _buildInfoRow(
                    Icons.people,
                    '${project.requiredTalents} sinh vien',
                  ),
                  _buildInfoRow(
                    Icons.payments,
                    '${project.budget ~/ 1000000}M VND',
                  ),
                ],
              ),
              if (project.technologies.isNotEmpty) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: project.technologies
                      .map(
                        (tech) => Chip(
                          label: Text(
                            tech,
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.primary,
                            ),
                          ),
                          backgroundColor: AppColors.primary.withValues(
                            alpha: 0.08,
                          ),
                        ),
                      )
                      .toList(),
                ),
              ],
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 12),
              _buildActions(project),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: AppColors.textSecondary),
        const SizedBox(width: 6),
        Text(
          text,
          style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
        ),
      ],
    );
  }

  Widget _buildActions(ProjectModel project) {
    switch (project.status) {
      case ProjectStatus.pending:
      case ProjectStatus.approved:
        return _primaryActionRow(
          primaryLabel: 'Xem chi tiet',
          primaryOnTap: () => _viewProjectDetail(project),
          outlined: true,
        );
      case ProjectStatus.inProgress:
        return Row(
          children: [
            Expanded(
              child: AppButton(
                text: 'Xem bao cao',
                onPressed: () => context.push(AppRoutes.enterpriseReports),
                backgroundColor: AppColors.white,
                textColor: AppColors.primary,
                borderColor: AppColors.primary,
                height: 42,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: AppButton(
                text: 'Chi tiet',
                onPressed: () => _viewProjectDetail(project),
                height: 42,
              ),
            ),
          ],
        );
      case ProjectStatus.completed:
        return _primaryActionRow(
          primaryLabel: 'Xem ket qua',
          primaryOnTap: () => _viewProjectDetail(project),
        );
      case ProjectStatus.rejected:
      case ProjectStatus.cancelled:
        return _primaryActionRow(
          primaryLabel: 'De xuat lai',
          primaryOnTap: () => context.push(AppRoutes.projectProposal),
        );
      case ProjectStatus.draft:
        return _primaryActionRow(
          primaryLabel: 'Tiep tuc chinh sua',
          primaryOnTap: () => _viewProjectDetail(project),
        );
    }
  }

  Widget _primaryActionRow({
    required String primaryLabel,
    required VoidCallback primaryOnTap,
    bool outlined = false,
  }) {
    return Row(
      children: [
        Expanded(
          child: AppButton(
            text: primaryLabel,
            onPressed: primaryOnTap,
            isOutlined: outlined,
            backgroundColor: outlined ? AppColors.white : null,
            textColor: outlined ? AppColors.primary : null,
            borderColor: outlined ? AppColors.primary : null,
            height: 42,
          ),
        ),
      ],
    );
  }

  void _viewProjectDetail(ProjectModel project) {
    context.push('${AppRoutes.enterpriseProjects}/${project.id}');
  }

  Color _statusColor(ProjectStatus status) {
    switch (status) {
      case ProjectStatus.inProgress:
        return AppColors.info;
      case ProjectStatus.pending:
      case ProjectStatus.approved:
        return AppColors.warning;
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
      case ProjectStatus.inProgress:
        return 'Dang thuc hien';
      case ProjectStatus.pending:
        return 'Cho duyet';
      case ProjectStatus.approved:
        return 'Da duyet';
      case ProjectStatus.completed:
        return 'Hoan thanh';
      case ProjectStatus.rejected:
        return 'Da tu choi';
      case ProjectStatus.cancelled:
        return 'Da huy';
      case ProjectStatus.draft:
        return 'Ban nhap';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}
