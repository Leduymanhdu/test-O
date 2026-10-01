import 'package:flutter/material.dart';
import 'package:labodc_mobile/core/theme/app_colors.dart';
import 'package:labodc_mobile/core/theme/app_text_styles.dart';
import 'package:labodc_mobile/services/project_service.dart';
import 'package:labodc_mobile/widgets/common_widgets.dart';
import 'package:labodc_mobile/widgets/app_button.dart';

class ProjectProposalScreen extends StatefulWidget {
  const ProjectProposalScreen({super.key});

  @override
  State<ProjectProposalScreen> createState() => _ProjectProposalScreenState();
}

class _ProjectProposalScreenState extends State<ProjectProposalScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _objectivesController = TextEditingController();
  final _budgetController = TextEditingController();
  final _studentCountController = TextEditingController();

  final _projectService = ProjectService();
  bool _isSubmitting = false;

  DateTime? _startDate;
  DateTime? _endDate;

  final List<String> _selectedTechnologies = [];
  final List<String> _availableTechnologies = [
    'ReactJS',
    'NodeJS',
    'Flutter',
    'React Native',
    'Java',
    'Spring Boot',
    'Python',
    'Django',
    'MongoDB',
    'PostgreSQL',
    'MySQL',
    'Redis',
    'Docker',
    'Kubernetes',
    'AWS',
    'Azure',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _objectivesController.dispose();
    _budgetController.dispose();
    _studentCountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Đề xuất Dự án'),
        actions: [
          TextButton(
            onPressed: () => _saveDraft(),
            child: const Text('Lưu nháp'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Introduction
            AppCard(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline, color: AppColors.info),
                        const SizedBox(width: 8),
                        Text('Hướng dẫn', style: AppTextStyles.subtitle1),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Vui lòng điền đầy đủ thông tin dự án. Lab sẽ xem xét trong vòng 48 giờ.',
                      style: AppTextStyles.body2.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Basic Information
            Text('Thông tin cơ bản', style: AppTextStyles.heading4),
            const SizedBox(height: 12),

            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Tên dự án *',
                hintText: 'VD: Website Quản lý Bán hàng',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Vui lòng nhập tên dự án';
                }
                if (value.trim().length < 10) {
                  return 'Tên dự án phải có ít nhất 10 ký tự';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Mô tả dự án *',
                hintText: 'Mô tả chi tiết về dự án, yêu cầu, tính năng...',
                border: OutlineInputBorder(),
              ),
              maxLines: 5,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Vui lòng nhập mô tả dự án';
                }
                if (value.trim().length < 50) {
                  return 'Mô tả phải có ít nhất 50 ký tự';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _objectivesController,
              decoration: const InputDecoration(
                labelText: 'Mục tiêu dự án *',
                hintText: 'Mỗi mục tiêu trên một dòng',
                border: OutlineInputBorder(),
              ),
              maxLines: 4,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Vui lòng nhập mục tiêu dự án';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),

            // Technologies
            Text('Công nghệ sử dụng', style: AppTextStyles.heading4),
            const SizedBox(height: 12),

            AppCard(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Chọn công nghệ (${_selectedTechnologies.length})',
                      style: AppTextStyles.subtitle2,
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _availableTechnologies.map((tech) {
                        final isSelected = _selectedTechnologies.contains(tech);
                        return FilterChip(
                          label: Text(tech),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              if (selected) {
                                _selectedTechnologies.add(tech);
                              } else {
                                _selectedTechnologies.remove(tech);
                              }
                            });
                          },
                          selectedColor: AppColors.primary.withValues(
                            alpha: 0.2,
                          ),
                          checkmarkColor: AppColors.primary,
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Timeline & Budget
            Text('Thời gian & Ngân sách', style: AppTextStyles.heading4),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => _selectStartDate(),
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Ngày bắt đầu *',
                        border: OutlineInputBorder(),
                      ),
                      child: Text(
                        _startDate != null
                            ? '${_startDate!.day}/${_startDate!.month}/${_startDate!.year}'
                            : 'Chọn ngày',
                        style: TextStyle(
                          color: _startDate != null
                              ? AppColors.textPrimary
                              : AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: InkWell(
                    onTap: () => _selectEndDate(),
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Ngày kết thúc *',
                        border: OutlineInputBorder(),
                      ),
                      child: Text(
                        _endDate != null
                            ? '${_endDate!.day}/${_endDate!.month}/${_endDate!.year}'
                            : 'Chọn ngày',
                        style: TextStyle(
                          color: _endDate != null
                              ? AppColors.textPrimary
                              : AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _budgetController,
              decoration: const InputDecoration(
                labelText: 'Ngân sách (VNĐ) *',
                hintText: 'VD: 100000000',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.payments),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Vui lòng nhập ngân sách';
                }
                final budget = int.tryParse(value.trim());
                if (budget == null) {
                  return 'Ngân sách phải là số';
                }
                if (budget < 10000000) {
                  return 'Ngân sách tối thiểu 10,000,000 VNĐ';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Budget Distribution Info
            if (_budgetController.text.isNotEmpty &&
                int.tryParse(_budgetController.text) != null) ...[
              AppCard(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Phân bổ kinh phí theo quy định 70/20/10',
                        style: AppTextStyles.subtitle2,
                      ),
                      const SizedBox(height: 12),
                      _buildBudgetDistribution(
                        'Nhóm Sinh viên (70%)',
                        int.parse(_budgetController.text) * 0.7,
                        AppColors.success,
                      ),
                      const SizedBox(height: 8),
                      _buildBudgetDistribution(
                        'Mentor (20%)',
                        int.parse(_budgetController.text) * 0.2,
                        AppColors.info,
                      ),
                      const SizedBox(height: 8),
                      _buildBudgetDistribution(
                        'Phòng LAB (10%)',
                        int.parse(_budgetController.text) * 0.1,
                        AppColors.warning,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            TextFormField(
              controller: _studentCountController,
              decoration: const InputDecoration(
                labelText: 'Số lượng sinh viên *',
                hintText: 'VD: 5',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.people),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Vui lòng nhập số lượng sinh viên';
                }
                final count = int.tryParse(value.trim());
                if (count == null) {
                  return 'Số lượng phải là số';
                }
                if (count < 3 || count > 10) {
                  return 'Số lượng từ 3-10 sinh viên';
                }
                return null;
              },
            ),
            const SizedBox(height: 32),

            // Submit Buttons
            Row(
              children: [
                Expanded(
                  child: AppButton(
                    text: 'Hủy',
                    onPressed: () => Navigator.pop(context),
                    backgroundColor: AppColors.white,
                    textColor: AppColors.textSecondary,
                    borderColor: AppColors.divider,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: AppButton(
                    text: _isSubmitting ? 'Đang gửi...' : 'Gửi đề xuất',
                    onPressed: _isSubmitting ? () {} : () => _submitProposal(),
                    isLoading: _isSubmitting,
                    icon: Icons.send,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildBudgetDistribution(String label, double amount, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTextStyles.body2.copyWith(color: AppColors.textSecondary),
        ),
        Text(
          '${amount ~/ 1000000}M VNĐ',
          style: AppTextStyles.subtitle2.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Future<void> _selectStartDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null) {
      setState(() => _startDate = date);
    }
  }

  Future<void> _selectEndDate() async {
    final initialDate =
        _startDate?.add(const Duration(days: 30)) ??
        DateTime.now().add(const Duration(days: 60));
    final date = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: _startDate ?? DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null) {
      setState(() => _endDate = date);
    }
  }

  void _saveDraft() {
    // TODO: Save to local storage or API
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Đã lưu bản nháp'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  void _submitProposal() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_startDate == null || _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng chọn ngày bắt đầu và kết thúc'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (_selectedTechnologies.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng chọn ít nhất 1 công nghệ'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final objectives = _objectivesController.text
        .split('\n')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    final payload = {
      'name': _titleController.text.trim(),
      'description': _descriptionController.text.trim(),
      'objectives': objectives,
      'startDate': _startDate!.toIso8601String().split('T').first,
      'endDate': _endDate!.toIso8601String().split('T').first,
      'budget': double.parse(_budgetController.text.trim()),
      'requiredTalents': int.parse(_studentCountController.text.trim()),
      'technologies': _selectedTechnologies,
      'allowApplications': true,
    };

    setState(() => _isSubmitting = true);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    _projectService.createProject(payload: payload).then((success) {
      if (!mounted) return;
      Navigator.pop(context); // close loading

      if (success) {
        Navigator.pop(context); // back
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Đã gửi đề xuất dự án thành công!'),
            backgroundColor: AppColors.success,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gửi đề xuất thất bại, vui lòng thử lại'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }).catchError((_) {
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gửi đề xuất thất bại, vui lòng thử lại'),
          backgroundColor: AppColors.error,
        ),
      );
    }).whenComplete(() {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    });
  }
}
