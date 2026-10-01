import 'package:flutter/material.dart';
import 'package:labodc_mobile/core/theme/app_colors.dart';
import 'package:labodc_mobile/core/theme/app_text_styles.dart';
import 'package:labodc_mobile/widgets/app_button.dart';

class TalentProfileScreen extends StatefulWidget {
  const TalentProfileScreen({super.key});

  @override
  State<TalentProfileScreen> createState() => _TalentProfileScreenState();
}

class _TalentProfileScreenState extends State<TalentProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isEditing = false;

  // Controllers
  final _fullNameController = TextEditingController(text: 'Trần Thị C');
  final _studentIdController = TextEditingController(text: '2021600001');
  final _facultyController = TextEditingController(text: 'Công nghệ Thông tin');
  final _yearOfStudyController = TextEditingController(text: '3');
  final _emailController = TextEditingController(text: 'student@uth.edu.vn');
  final _phoneController = TextEditingController(text: '0901234567');
  final _portfolioController = TextEditingController(
    text: 'https://github.com/tranthic',
  );

  final Map<String, dynamic> _profileData = {
    'avatarUrl': 'https://ui-avatars.com/api/?name=Tran+Thi+C&size=200',
    'projectsCompleted': 3,
    'averageRating': 4.5,
    'totalEarnings': 35000000,
    'status': 'ACTIVE',
  };

  final List<Map<String, dynamic>> _skills = [
    {'id': 1, 'name': 'ReactJS', 'level': 'Intermediate', 'years': 1.5},
    {'id': 2, 'name': 'NodeJS', 'level': 'Beginner', 'years': 0.5},
    {'id': 3, 'name': 'MongoDB', 'level': 'Beginner', 'years': 0.5},
    {'id': 4, 'name': 'Flutter', 'level': 'Intermediate', 'years': 1.0},
  ];

  final List<Map<String, dynamic>> _certifications = [
    {
      'id': 1,
      'name': 'AWS Cloud Practitioner',
      'issuer': 'Amazon Web Services',
      'issueDate': '2025-06-15',
      'credentialUrl': 'https://aws.amazon.com/cert/123',
    },
    {
      'id': 2,
      'name': 'Google UX Design Certificate',
      'issuer': 'Google',
      'issueDate': '2025-03-20',
      'credentialUrl': 'https://grow.google/certificates/ux-design',
    },
  ];

  @override
  void dispose() {
    _fullNameController.dispose();
    _studentIdController.dispose();
    _facultyController.dispose();
    _yearOfStudyController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _portfolioController.dispose();
    super.dispose();
  }

  void _toggleEdit() {
    setState(() => _isEditing = !_isEditing);
  }

  void _saveProfile() {
    if (_formKey.currentState!.validate()) {
      setState(() => _isEditing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cập nhật hồ sơ thành công'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  void _showAddSkillDialog() {
    final nameController = TextEditingController();
    String selectedLevel = 'Beginner';
    final yearsController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Thêm kỹ năng'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Tên kỹ năng *',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: selectedLevel,
              decoration: const InputDecoration(
                labelText: 'Trình độ *',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'Beginner', child: Text('Beginner')),
                DropdownMenuItem(
                  value: 'Intermediate',
                  child: Text('Intermediate'),
                ),
                DropdownMenuItem(value: 'Advanced', child: Text('Advanced')),
              ],
              onChanged: (value) => selectedLevel = value!,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: yearsController,
              decoration: const InputDecoration(
                labelText: 'Số năm kinh nghiệm *',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
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
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Đã thêm kỹ năng mới'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            child: const Text('Thêm'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hồ sơ của tôi'),
        actions: [
          if (!_isEditing)
            IconButton(icon: const Icon(Icons.edit), onPressed: _toggleEdit)
          else
            IconButton(icon: const Icon(Icons.close), onPressed: _toggleEdit),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile header
              Center(
                child: Column(
                  children: [
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 60,
                          backgroundColor: AppColors.primary.withValues(
                            alpha: 0.1,
                          ),
                          child: Text(
                            _fullNameController.text[0],
                            style: AppTextStyles.heading1.copyWith(
                              color: AppColors.primary,
                              fontSize: 48,
                            ),
                          ),
                        ),
                        if (_isEditing)
                          Positioned(
                            right: 0,
                            bottom: 0,
                            child: CircleAvatar(
                              radius: 20,
                              backgroundColor: AppColors.primary,
                              child: IconButton(
                                icon: const Icon(Icons.camera_alt, size: 20),
                                color: AppColors.white,
                                onPressed: () {
                                  // TODO: Upload avatar
                                },
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _fullNameController.text,
                      style: AppTextStyles.heading2.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _studentIdController.text,
                      style: AppTextStyles.body2.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Stats cards
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      'Dự án',
                      '${_profileData['projectsCompleted']}',
                      Icons.folder_outlined,
                      AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      'Đánh giá',
                      '${_profileData['averageRating']}/5',
                      Icons.star_outline,
                      AppColors.warning,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      'Thu nhập',
                      '${(_profileData['totalEarnings'] / 1000000).toStringAsFixed(0)}M',
                      Icons.attach_money,
                      AppColors.success,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Personal information
              Text('Thông tin cá nhân', style: AppTextStyles.heading3),
              const SizedBox(height: 16),

              TextFormField(
                controller: _fullNameController,
                decoration: const InputDecoration(
                  labelText: 'Họ và tên *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                enabled: _isEditing,
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _studentIdController,
                      decoration: const InputDecoration(
                        labelText: 'MSSV *',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.badge),
                      ),
                      enabled: false,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _yearOfStudyController,
                      decoration: const InputDecoration(
                        labelText: 'Năm học *',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.school),
                      ),
                      enabled: _isEditing,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _facultyController,
                decoration: const InputDecoration(
                  labelText: 'Khoa *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.apartment),
                ),
                enabled: false,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                ),
                enabled: false,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Số điện thoại *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.phone),
                ),
                enabled: _isEditing,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _portfolioController,
                decoration: const InputDecoration(
                  labelText: 'Portfolio URL',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.link),
                ),
                enabled: _isEditing,
              ),

              const SizedBox(height: 24),

              // Skills
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Kỹ năng', style: AppTextStyles.heading3),
                  if (_isEditing)
                    TextButton.icon(
                      onPressed: _showAddSkillDialog,
                      icon: const Icon(Icons.add),
                      label: const Text('Thêm'),
                    ),
                ],
              ),
              const SizedBox(height: 16),

              ..._skills.map(
                (skill) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.divider),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                skill['name'],
                                style: AppTextStyles.subtitle2.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.info.withValues(
                                        alpha: 0.1,
                                      ),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      skill['level'],
                                      style: AppTextStyles.caption.copyWith(
                                        color: AppColors.info,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '${skill['years']} năm',
                                    style: AppTextStyles.caption.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        if (_isEditing)
                          IconButton(
                            icon: const Icon(
                              Icons.delete,
                              color: AppColors.error,
                            ),
                            onPressed: () {
                              // TODO: Delete skill
                            },
                          ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Certifications
              Text('Chứng chỉ', style: AppTextStyles.heading3),
              const SizedBox(height: 16),

              ..._certifications.map(
                (cert) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.divider),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          cert['name'],
                          style: AppTextStyles.subtitle2.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              Icons.business,
                              size: 14,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              cert['issuer'],
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.calendar_today,
                              size: 14,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              cert['issueDate'],
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              if (_isEditing) ...[
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: AppButton(
                    text: 'Lưu thay đổi',
                    onPressed: _saveProfile,
                    icon: Icons.save,
                  ),
                ),
              ],

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppTextStyles.subtitle1.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(color: color, fontSize: 10),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
