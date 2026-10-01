import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:labodc_mobile/core/theme/app_colors.dart';
import 'package:labodc_mobile/core/theme/app_text_styles.dart';
import 'package:labodc_mobile/widgets/common_widgets.dart';
import 'package:labodc_mobile/providers/admin_provider.dart';
import 'package:labodc_mobile/services/admin/project_service.dart' as project_svc;
import 'package:intl/intl.dart';

class ProjectValidationScreen extends StatefulWidget {
  const ProjectValidationScreen({super.key});

  @override
  State<ProjectValidationScreen> createState() => _ProjectValidationScreenState();
}

class _ProjectValidationScreenState extends State<ProjectValidationScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadData();
    
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        _loadData();
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final provider = context.read<AdminProvider>();
    String status = _getStatusFromTab();
    provider.setProjectStatusFilter(status);
    provider.setProjectSearchText(_searchQuery);
    await provider.loadProjects();
  }

  String _getStatusFromTab() {
    switch (_tabController.index) {
      case 0: return 'ALL';
      case 1: return 'pending';
      case 2: return 'approved';
      case 3: return 'rejected';
      default: return 'ALL';
    }
  }

  @override
  Widget build(BuildContext context) {
    final adminProvider = context.watch<AdminProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Duyệt Dự Án'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: Column(
            children: [
              TabBar(
                controller: _tabController,
                indicatorColor: AppColors.white,
                labelColor: AppColors.white,
                unselectedLabelColor: AppColors.white.withOpacity(0.7),
                tabs: const [
                  Tab(text: 'Tất cả'),
                  Tab(text: 'Chờ duyệt'),
                  Tab(text: 'Đã duyệt'),
                  Tab(text: 'Từ chối'),
                ],
              ),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Tìm kiếm dự án...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _searchController.clear();
                            _searchQuery = '';
                          });
                          _loadData();
                        },
                      )
                    : null,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onSubmitted: (value) {
                setState(() => _searchQuery = value);
                _loadData();
              },
            ),
          ),
          Expanded(
            child: adminProvider.loadingProjects
                ? const Center(child: CircularProgressIndicator())
                : _buildProjectsList(adminProvider),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, int value, Color color) {
    return Column(
      children: [
        Text(value.toString(), style: AppTextStyles.heading2.copyWith(color: color)),
        const SizedBox(height: 4),
        Text(label, style: AppTextStyles.caption.copyWith(color: AppColors.white)),
      ],
    );
  }

  Widget _buildProjectsList(AdminProvider provider) {
    if (provider.projects.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.folder_open, size: 64, color: AppColors.textSecondary.withOpacity(0.5)),
            const SizedBox(height: 16),
            Text('Không có dự án', style: AppTextStyles.body1.copyWith(color: AppColors.textSecondary)),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: provider.projects.length,
        itemBuilder: (context, index) => _buildProjectCard(provider.projects[index]),
      ),
    );
  }

  Widget _buildProjectCard(project_svc.ProjectItem project) {
    return AppCard(
      onTap: () => _showProjectDetail(project.id),
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.assignment, color: AppColors.primary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(project.title, style: AppTextStyles.subtitle1),
                      if (project.enterpriseName != null) ...[
                        const SizedBox(height: 4),
                        Text(project.enterpriseName!, style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
                      ],
                    ],
                  ),
                ),
                _buildValidationBadge(project.validated ?? 'pending'),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(child: _buildInfoRow(Icons.people, '${project.requiredStudents} sinh viên')),
                Expanded(child: _buildInfoRow(Icons.access_time, project.duration)),
              ],
            ),
            const SizedBox(height: 8),
            _buildInfoRow(Icons.attach_money, _formatCurrency(project.budget)),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (project.submittedAt != null)
                  Text('Gửi: ${_formatDate(project.submittedAt!)}', style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
                _buildStatusBadge(project.status),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.textSecondary),
        const SizedBox(width: 4),
        Expanded(child: Text(text, style: AppTextStyles.caption, overflow: TextOverflow.ellipsis)),
      ],
    );
  }

  Widget _buildValidationBadge(String validated) {
    final data = validated.toLowerCase() == 'pending' 
        ? (AppColors.warning, 'Chờ duyệt')
        : validated.toLowerCase() == 'approved'
            ? (AppColors.success, 'Đã duyệt')
            : (AppColors.error, 'Từ chối');
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: data.$1.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: data.$1),
      ),
      child: Text(data.$2, style: AppTextStyles.caption.copyWith(color: data.$1, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildStatusBadge(String status) {
    final data = status == 'RECRUITING'
        ? (AppColors.info, 'Tuyển dụng')
        : status == 'IN_PROGRESS'
            ? (AppColors.primary, 'Đang thực hiện')
            : status == 'COMPLETED'
                ? (AppColors.success, 'Hoàn thành')
                : (AppColors.error, 'Đã hủy');
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: data.$1.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
      child: Text(data.$2, style: AppTextStyles.caption.copyWith(color: data.$1, fontWeight: FontWeight.bold)),
    );
  }

  Future<void> _showProjectDetail(int id) async {
    final adminProvider = context.read<AdminProvider>();
    showDialog(context: context, barrierDismissible: false, builder: (context) => const Center(child: CircularProgressIndicator()));
    try {
      await adminProvider.loadProjectDetail(id);
      if (!mounted) return;
      Navigator.pop(context);
      final project = adminProvider.selectedProject;
      if (project == null) throw Exception('Project data not loaded');
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        builder: (context) => DraggableScrollableSheet(
          initialChildSize: 0.9,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) => _buildDetailSheet(project, scrollController),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi: $e'), backgroundColor: AppColors.error));
    }
  }

  Widget _buildDetailSheet(project_svc.ProjectDetail project, ScrollController scrollController) {
    return Container(
      decoration: const BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      child: Column(
        children: [
          Container(margin: const EdgeInsets.symmetric(vertical: 12), width: 40, height: 4, decoration: BoxDecoration(color: AppColors.divider, borderRadius: BorderRadius.circular(2))),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(child: Text('Chi tiết Dự án', style: AppTextStyles.heading3)),
                IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
              ],
            ),
          ),
          const Divider(),
          Expanded(
            child: SingleChildScrollView(
              controller: scrollController,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(project.title, style: AppTextStyles.heading2),
                  const SizedBox(height: 8),
                  Row(children: [Text('Trạng thái: ', style: AppTextStyles.body2), _buildValidationBadge(project.validated ?? 'pending')]),
                  const SizedBox(height: 24),
                  if (project.description != null) ...[
                    Text('Mô tả', style: AppTextStyles.subtitle1),
                    const SizedBox(height: 8),
                    Text(project.description!, style: AppTextStyles.body2),
                    const SizedBox(height: 16),
                  ],
                  Text('Yêu cầu', style: AppTextStyles.subtitle1),
                  const SizedBox(height: 8),
                  _buildDetailItem('Số sinh viên', '${project.requiredStudents} người'),
                  _buildDetailItem('Thời gian', project.duration),
                  _buildDetailItem('Ngân sách', _formatCurrency(project.budget)),
                  const SizedBox(height: 24),
                  if (project.validated == 'pending') _buildActions(project.id),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 120, child: Text('$label:', style: AppTextStyles.body2.copyWith(color: AppColors.textSecondary))),
          Expanded(child: Text(value, style: AppTextStyles.body2)),
        ],
      ),
    );
  }

  Widget _buildActions(int id) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => _handleApprove(id),
            icon: const Icon(Icons.check_circle),
            label: const Text('Phê duyệt'),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.success, padding: const EdgeInsets.symmetric(vertical: 16)),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => _handleReject(id),
            icon: const Icon(Icons.cancel),
            label: const Text('Từ chối'),
            style: OutlinedButton.styleFrom(foregroundColor: AppColors.error, side: const BorderSide(color: AppColors.error), padding: const EdgeInsets.symmetric(vertical: 16)),
          ),
        ),
      ],
    );
  }

  Future<void> _handleApprove(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận'),
        content: const Text('Phê duyệt dự án này?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Hủy')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Phê duyệt')),
        ],
      ),
    );
    if (confirm != true) return;
    try {
      await context.read<AdminProvider>().validateProject(id);
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã phê duyệt dự án'), backgroundColor: AppColors.success));
      _loadData();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi: $e'), backgroundColor: AppColors.error));
    }
  }

  Future<void> _handleReject(int id) async {
    final reasonController = TextEditingController();
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Từ chối dự án'),
        content: TextField(
          controller: reasonController,
          decoration: const InputDecoration(labelText: 'Lý do từ chối', hintText: 'Nhập lý do...', border: OutlineInputBorder()),
          maxLines: 3,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Hủy')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Từ chối'),
          ),
        ],
      ),
    );
    if (confirm != true || reasonController.text.trim().isEmpty) return;
    try {
      await context.read<AdminProvider>().rejectProject(id, reason: reasonController.text);
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã từ chối dự án'), backgroundColor: AppColors.success));
      _loadData();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi: $e'), backgroundColor: AppColors.error));
    }
  }

  String _formatCurrency(double amount) => NumberFormat.currency(locale: 'vi_VN', symbol: '₫', decimalDigits: 0).format(amount);
  String _formatDate(DateTime date) => DateFormat('dd/MM/yyyy').format(date);
}
