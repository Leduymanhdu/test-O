import 'package:flutter/material.dart';
import 'package:labodc_mobile/core/theme/app_colors.dart';
import 'package:labodc_mobile/core/theme/app_text_styles.dart';
import 'package:labodc_mobile/widgets/app_button.dart';

class EvaluationScreen extends StatefulWidget {
  const EvaluationScreen({super.key});

  @override
  State<EvaluationScreen> createState() => _EvaluationScreenState();
}

class _EvaluationScreenState extends State<EvaluationScreen> {
  final _formKey = GlobalKey<FormState>();

  // Selected talent
  String? _selectedTalent;
  String _evaluationPeriod = '2026-02';

  // Evaluation scores
  double _technicalSkills = 7.0;
  double _problemSolving = 7.0;
  double _teamwork = 7.0;
  double _communication = 7.0;
  double _codeQuality = 7.0;
  double _punctuality = 7.0;

  // Text controllers
  final _technicalCommentController = TextEditingController();
  final _problemSolvingCommentController = TextEditingController();
  final _teamworkCommentController = TextEditingController();
  final _communicationCommentController = TextEditingController();
  final _codeQualityCommentController = TextEditingController();
  final _punctualityCommentController = TextEditingController();
  final _strengthsController = TextEditingController();
  final _weaknessesController = TextEditingController();
  final _recommendationsController = TextEditingController();
  final _tasksCompletedController = TextEditingController(text: '0');
  final _tasksTotalController = TextEditingController(text: '0');
  final _hoursWorkedController = TextEditingController(text: '0');

  // Mock data
  final List<Map<String, dynamic>> _talents = [
    {'id': 456, 'name': 'Tran Thi C', 'role': 'Frontend Developer'},
    {'id': 457, 'name': 'Nguyen Van D', 'role': 'Backend Developer'},
    {'id': 458, 'name': 'Le Thi E', 'role': 'Full Stack Developer'},
  ];

  @override
  void dispose() {
    _technicalCommentController.dispose();
    _problemSolvingCommentController.dispose();
    _teamworkCommentController.dispose();
    _communicationCommentController.dispose();
    _codeQualityCommentController.dispose();
    _punctualityCommentController.dispose();
    _strengthsController.dispose();
    _weaknessesController.dispose();
    _recommendationsController.dispose();
    _tasksCompletedController.dispose();
    _tasksTotalController.dispose();
    _hoursWorkedController.dispose();
    super.dispose();
  }

  double get _overallScore {
    return (_technicalSkills +
            _problemSolving +
            _teamwork +
            _communication +
            _codeQuality +
            _punctuality) /
        6;
  }

  String get _grade {
    if (_overallScore >= 9.0) return 'A';
    if (_overallScore >= 8.0) return 'B';
    if (_overallScore >= 7.0) return 'C';
    if (_overallScore >= 6.0) return 'D';
    return 'F';
  }

  void _submitEvaluation() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedTalent == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng chọn sinh viên để đánh giá'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận gửi đánh giá'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Gửi đánh giá cho $_selectedTalent?'),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Điểm tổng:'),
                Text(
                  '${_overallScore.toStringAsFixed(1)}/10',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Xếp loại:'),
                Text(
                  _grade,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Call API to submit evaluation
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Đánh giá đã được gửi thành công!'),
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

  void _resetForm() {
    setState(() {
      _selectedTalent = null;
      _technicalSkills = 7.0;
      _problemSolving = 7.0;
      _teamwork = 7.0;
      _communication = 7.0;
      _codeQuality = 7.0;
      _punctuality = 7.0;
    });
    _technicalCommentController.clear();
    _problemSolvingCommentController.clear();
    _teamworkCommentController.clear();
    _communicationCommentController.clear();
    _codeQualityCommentController.clear();
    _punctualityCommentController.clear();
    _strengthsController.clear();
    _weaknessesController.clear();
    _recommendationsController.clear();
    _tasksCompletedController.text = '0';
    _tasksTotalController.text = '0';
    _hoursWorkedController.text = '0';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Đánh giá Sinh viên')),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Talent selection
              Text('Thông tin đánh giá', style: AppTextStyles.heading3),
              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                initialValue: _selectedTalent,
                decoration: const InputDecoration(
                  labelText: 'Chọn sinh viên *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                items: _talents.map((talent) {
                  return DropdownMenuItem<String>(
                    value: talent['name'] as String,
                    child: Text('${talent['name']} - ${talent['role']}'),
                  );
                }).toList(),
                onChanged: (value) => setState(() => _selectedTalent = value),
              ),
              const SizedBox(height: 16),

              TextFormField(
                initialValue: _evaluationPeriod,
                decoration: const InputDecoration(
                  labelText: 'Kỳ đánh giá (YYYY-MM) *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.calendar_month),
                ),
                onChanged: (value) => _evaluationPeriod = value,
              ),
              const SizedBox(height: 24),

              // Overall score display
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary.withValues(alpha: 0.1),
                      AppColors.primary.withValues(alpha: 0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        Text(
                          _overallScore.toStringAsFixed(1),
                          style: AppTextStyles.heading1.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Điểm tổng',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    Container(width: 1, height: 40, color: AppColors.divider),
                    Column(
                      children: [
                        Text(
                          _grade,
                          style: AppTextStyles.heading1.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Xếp loại',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Evaluation criteria
              Text('Tiêu chí đánh giá', style: AppTextStyles.heading3),
              const SizedBox(height: 16),

              _buildCriteriaSlider(
                'Kỹ năng kỹ thuật',
                _technicalSkills,
                _technicalCommentController,
                (value) => setState(() => _technicalSkills = value),
              ),

              _buildCriteriaSlider(
                'Giải quyết vấn đề',
                _problemSolving,
                _problemSolvingCommentController,
                (value) => setState(() => _problemSolving = value),
              ),

              _buildCriteriaSlider(
                'Làm việc nhóm',
                _teamwork,
                _teamworkCommentController,
                (value) => setState(() => _teamwork = value),
              ),

              _buildCriteriaSlider(
                'Giao tiếp',
                _communication,
                _communicationCommentController,
                (value) => setState(() => _communication = value),
              ),

              _buildCriteriaSlider(
                'Chất lượng code',
                _codeQuality,
                _codeQualityCommentController,
                (value) => setState(() => _codeQuality = value),
              ),

              _buildCriteriaSlider(
                'Đúng giờ & Cam kết',
                _punctuality,
                _punctualityCommentController,
                (value) => setState(() => _punctuality = value),
              ),

              const SizedBox(height: 24),

              // Additional feedback
              Text('Nhận xét chi tiết', style: AppTextStyles.heading3),
              const SizedBox(height: 16),

              TextFormField(
                controller: _strengthsController,
                decoration: const InputDecoration(
                  labelText: 'Điểm mạnh',
                  hintText:
                      'VD: Frontend development skills mạnh, tự học nhanh...',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _weaknessesController,
                decoration: const InputDecoration(
                  labelText: 'Điểm cần cải thiện',
                  hintText: 'VD: Backend knowledge còn hạn chế...',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _recommendationsController,
                decoration: const InputDecoration(
                  labelText: 'Gợi ý phát triển',
                  hintText: 'VD: Học thêm về backend, practice viết tests...',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 24),

              // Performance metrics
              Text('Số liệu hiệu suất', style: AppTextStyles.heading3),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _tasksCompletedController,
                      decoration: const InputDecoration(
                        labelText: 'Tasks hoàn thành',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _tasksTotalController,
                      decoration: const InputDecoration(
                        labelText: 'Tổng tasks',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _hoursWorkedController,
                decoration: const InputDecoration(
                  labelText: 'Số giờ làm việc',
                  border: OutlineInputBorder(),
                  suffixText: 'giờ',
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 32),

              // Submit button
              AppButton(
                text: 'Gửi đánh giá',
                onPressed: _submitEvaluation,
                icon: Icons.send,
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCriteriaSlider(
    String label,
    double value,
    TextEditingController commentController,
    ValueChanged<double> onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: AppTextStyles.subtitle2.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: _getScoreColor(value).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  value.toStringAsFixed(1),
                  style: AppTextStyles.subtitle2.copyWith(
                    color: _getScoreColor(value),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          Slider(
            value: value,
            min: 0,
            max: 10,
            divisions: 20,
            label: value.toStringAsFixed(1),
            onChanged: onChanged,
          ),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '0',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                '5',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                '10',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          TextField(
            controller: commentController,
            decoration: InputDecoration(
              hintText: 'Nhận xét về $label...',
              border: const OutlineInputBorder(),
              isDense: true,
            ),
            maxLines: 2,
          ),
        ],
      ),
    );
  }

  Color _getScoreColor(double score) {
    if (score >= 9.0) return AppColors.success;
    if (score >= 7.0) return AppColors.info;
    if (score >= 5.0) return AppColors.warning;
    return AppColors.error;
  }
}
