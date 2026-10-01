import 'package:flutter/material.dart';
import 'package:labodc_mobile/core/theme/app_colors.dart';
import 'package:labodc_mobile/core/theme/app_text_styles.dart';
import 'package:labodc_mobile/widgets/common_widgets.dart';
import 'package:labodc_mobile/widgets/app_button.dart';

class ReportSubmissionScreen extends StatefulWidget {
  const ReportSubmissionScreen({super.key});

  @override
  State<ReportSubmissionScreen> createState() => _ReportSubmissionScreenState();
}

class _ReportSubmissionScreenState extends State<ReportSubmissionScreen> {
  final _formKey = GlobalKey<FormState>();

  String _reportType = 'MONTHLY';
  String _reportingPeriod = '2026-02';
  String? _selectedProject;

  // Controllers
  final _overallCompletionController = TextEditingController(text: '45');
  final _plannedCompletionController = TextEditingController(text: '50');
  final _tasksCompletedController = TextEditingController(text: '20');
  final _tasksUpcomingController = TextEditingController(text: '25');
  final _achievementsController = TextEditingController();
  final _challengesController = TextEditingController();
  final _risksController = TextEditingController();
  final _nextMonthGoalsController = TextEditingController();

  // Mock projects
  final List<Map<String, dynamic>> _projects = [
    {'id': 789, 'title': 'Website Quản lý Bán hàng'},
    {'id': 788, 'title': 'Mobile App E-commerce'},
  ];

  // Previous reports
  final List<Map<String, dynamic>> _previousReports = [
    {
      'id': 1001,
      'reportType': 'MONTHLY',
      'period': '2026-01',
      'projectTitle': 'Website Quản lý Bán hàng',
      'submittedAt': '2026-01-31T18:00:00Z',
      'status': 'SUBMITTED',
      'progress': 35,
    },
    {
      'id': 1000,
      'reportType': 'PHASE',
      'period': 'Phase 1',
      'projectTitle': 'Mobile App E-commerce',
      'submittedAt': '2026-01-15T17:30:00Z',
      'status': 'SUBMITTED',
      'progress': 25,
    },
  ];

  @override
  void dispose() {
    _overallCompletionController.dispose();
    _plannedCompletionController.dispose();
    _tasksCompletedController.dispose();
    _tasksUpcomingController.dispose();
    _achievementsController.dispose();
    _challengesController.dispose();
    _risksController.dispose();
    _nextMonthGoalsController.dispose();
    super.dispose();
  }

  void _submitReport() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedProject == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng chọn dự án'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận nộp báo cáo'),
        content: Text(
          'Nộp báo cáo $_reportType cho dự án "$_selectedProject"\nKỳ báo cáo: $_reportingPeriod?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Call API to submit report
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Báo cáo đã được nộp thành công!'),
                  backgroundColor: AppColors.success,
                ),
              );
              _resetForm();
            },
            child: const Text('Xác nhận'),
          ),
        ],
      ),
    );
  }

  void _saveDraft() {
    // TODO: Save draft
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Đã lưu bản nháp'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  void _resetForm() {
    _formKey.currentState?.reset();
    setState(() {
      _selectedProject = null;
      _reportType = 'MONTHLY';
    });
    _overallCompletionController.text = '0';
    _plannedCompletionController.text = '0';
    _tasksCompletedController.text = '0';
    _tasksUpcomingController.text = '0';
    _achievementsController.clear();
    _challengesController.clear();
    _risksController.clear();
    _nextMonthGoalsController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nộp Báo cáo')),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Previous reports section
            _buildPreviousReportsSection(),

            const Divider(height: 1),

            // New report form
            Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Tạo báo cáo mới', style: AppTextStyles.heading3),
                    const SizedBox(height: 16),

                    // Report type
                    DropdownButtonFormField<String>(
                      initialValue: _reportType,
                      decoration: const InputDecoration(
                        labelText: 'Loại báo cáo *',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.category),
                      ),
                      items: const [
                        DropdownMenuItem<String>(
                          value: 'MONTHLY',
                          child: Text('Báo cáo tháng'),
                        ),
                        DropdownMenuItem<String>(
                          value: 'PHASE',
                          child: Text('Báo cáo giai đoạn'),
                        ),
                      ],
                      onChanged: (value) =>
                          setState(() => _reportType = value!),
                    ),
                    const SizedBox(height: 16),

                    // Project selection
                    DropdownButtonFormField<String>(
                      initialValue: _selectedProject,
                      decoration: const InputDecoration(
                        labelText: 'Dự án *',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.folder),
                      ),
                      items: _projects.map((project) {
                        return DropdownMenuItem<String>(
                          value: project['title'] as String,
                          child: Text(project['title']),
                        );
                      }).toList(),
                      onChanged: (value) =>
                          setState(() => _selectedProject = value),
                    ),
                    const SizedBox(height: 16),

                    // Reporting period
                    TextFormField(
                      initialValue: _reportingPeriod,
                      decoration: const InputDecoration(
                        labelText: 'Kỳ báo cáo (YYYY-MM) *',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.calendar_month),
                      ),
                      onChanged: (value) => _reportingPeriod = value,
                    ),
                    const SizedBox(height: 24),

                    // Progress section
                    Text('Tiến độ dự án', style: AppTextStyles.heading3),
                    const SizedBox(height: 16),

                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _overallCompletionController,
                            decoration: const InputDecoration(
                              labelText: 'Hoàn thành thực tế (%)',
                              border: OutlineInputBorder(),
                              suffixText: '%',
                            ),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Vui lòng nhập';
                              }
                              final num = int.tryParse(value);
                              if (num == null || num < 0 || num > 100) {
                                return 'Từ 0-100';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: _plannedCompletionController,
                            decoration: const InputDecoration(
                              labelText: 'Kế hoạch (%)',
                              border: OutlineInputBorder(),
                              suffixText: '%',
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Tasks section
                    Text('Nhiệm vụ', style: AppTextStyles.heading3),
                    const SizedBox(height: 16),

                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _tasksCompletedController,
                            decoration: const InputDecoration(
                              labelText: 'Hoàn thành',
                              border: OutlineInputBorder(),
                              suffixText: 'tasks',
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: _tasksUpcomingController,
                            decoration: const InputDecoration(
                              labelText: 'Sắp tới',
                              border: OutlineInputBorder(),
                              suffixText: 'tasks',
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Achievements
                    Text('Thành tựu', style: AppTextStyles.heading3),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _achievementsController,
                      decoration: const InputDecoration(
                        labelText: 'Danh sách thành tựu',
                        hintText:
                            'Mỗi thành tựu một dòng...\nVD:\n- Hoàn thành frontend dashboard\n- Backend APIs pass tests',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 5,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Vui lòng nhập ít nhất 1 thành tựu';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    // Challenges
                    Text(
                      'Thách thức & Giải pháp',
                      style: AppTextStyles.heading3,
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _challengesController,
                      decoration: const InputDecoration(
                        labelText: 'Thách thức gặp phải và cách giải quyết',
                        hintText:
                            'VD:\n- Issue: Cloudinary upload slow\n  Solution: Image compression + lazy loading',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 5,
                    ),
                    const SizedBox(height: 24),

                    // Risks
                    Text('Rủi ro tiềm ẩn', style: AppTextStyles.heading3),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _risksController,
                      decoration: const InputDecoration(
                        labelText: 'Rủi ro và biện pháp phòng ngừa',
                        hintText:
                            'VD:\n- Third-party API có thể thay đổi\n  Mitigation: Tạo abstraction layer',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 4,
                    ),
                    const SizedBox(height: 24),

                    // Next month goals
                    Text('Mục tiêu tháng tới', style: AppTextStyles.heading3),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _nextMonthGoalsController,
                      decoration: const InputDecoration(
                        labelText: 'Kế hoạch tháng tới',
                        hintText:
                            'Mỗi mục tiêu một dòng...\nVD:\n- Complete Payment module\n- Deploy to staging',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 5,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Vui lòng nhập kế hoạch';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 32),

                    // Action buttons
                    Row(
                      children: [
                        Expanded(
                          child: AppButton(
                            text: 'Lưu nháp',
                            onPressed: _saveDraft,
                            backgroundColor: AppColors.white,
                            textColor: AppColors.textSecondary,
                            borderColor: AppColors.divider,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: AppButton(
                            text: 'Nộp báo cáo',
                            onPressed: _submitReport,
                            icon: Icons.send,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreviousReportsSection() {
    if (_previousReports.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(16),
      color: AppColors.backgroundGrey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Báo cáo đã nộp', style: AppTextStyles.heading3),
              TextButton(
                onPressed: () {
                  // TODO: View all reports
                },
                child: const Text('Xem tất cả'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ..._previousReports
              .take(2)
              .map(
                (report) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _buildReportCard(report),
                ),
              ),
        ],
      ),
    );
  }

  Widget _buildReportCard(Map<String, dynamic> report) {
    return AppCard(
      onTap: () {
        // TODO: View report detail
      },
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              report['reportType'] == 'MONTHLY'
                  ? Icons.calendar_month
                  : Icons.flag,
              color: AppColors.success,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  report['projectTitle'],
                  style: AppTextStyles.subtitle2.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${report['reportType']} - ${report['period']}',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              StatusBadge(
                label: '${report['progress']}%',
                color: AppColors.primary,
              ),
              const SizedBox(height: 4),
              Text(
                _formatDate(report['submittedAt']),
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

  String _formatDate(String dateString) {
    final date = DateTime.parse(dateString);
    return '${date.day}/${date.month}/${date.year}';
  }
}
