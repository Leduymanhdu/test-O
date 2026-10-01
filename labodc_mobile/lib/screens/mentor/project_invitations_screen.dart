import 'package:flutter/material.dart';
import 'package:labodc_mobile/core/theme/app_colors.dart';
import 'package:labodc_mobile/core/theme/app_text_styles.dart';
import 'package:labodc_mobile/widgets/common_widgets.dart';
import 'package:labodc_mobile/widgets/app_button.dart';

class ProjectInvitationsScreen extends StatefulWidget {
  const ProjectInvitationsScreen({super.key});

  @override
  State<ProjectInvitationsScreen> createState() => _ProjectInvitationsScreenState();
}

class _ProjectInvitationsScreenState extends State<ProjectInvitationsScreen> {
  // Mock data
  final List<Map<String, dynamic>> _invitations = [
    {
      'id': 5001,
      'project': {
        'id': 789,
        'title': 'Website Quản lý Bán hàng',
        'description': 'Xây dựng website quản lý bán hàng online với đầy đủ tính năng quản lý sản phẩm, đơn hàng, khách hàng và báo cáo doanh thu.',
        'technologies': ['ReactJS', 'NodeJS', 'MongoDB', 'Docker'],
        'startDate': '2026-02-01',
        'endDate': '2026-05-31',
        'budget': 100000000,
        'numberOfStudents': 5,
      },
      'enterprise': {
        'name': 'ABC Technology Co., Ltd',
        'logo': 'https://via.placeholder.com/100',
      },
      'mentorCompensation': 20000000,
      'expectedEffort': '10-15 giờ/tuần',
      'responsibilities': [
        'Hướng dẫn team xây dựng architecture',
        'Code review định kỳ',
        'Phân tích và phân công tasks',
        'Đánh giá hiệu suất hàng tháng',
      ],
      'invitedBy': 'Lab Admin',
      'invitedAt': '2026-01-15T10:00:00Z',
      'status': 'PENDING',
    },
    {
      'id': 5002,
      'project': {
        'id': 788,
        'title': 'Mobile App E-commerce',
        'description': 'Phát triển ứng dụng di động cho nền tảng thương mại điện tử, hỗ trợ cả iOS và Android.',
        'technologies': ['Flutter', 'Firebase', 'REST API', 'Payment Gateway'],
        'startDate': '2026-03-01',
        'endDate': '2026-08-31',
        'budget': 150000000,
        'numberOfStudents': 6,
      },
      'enterprise': {
        'name': 'XYZ E-commerce Corp',
        'logo': 'https://via.placeholder.com/100',
      },
      'mentorCompensation': 30000000,
      'expectedEffort': '15-20 giờ/tuần',
      'responsibilities': [
        'Thiết kế kiến trúc ứng dụng mobile',
        'Hướng dẫn Flutter best practices',
        'Review và optimize performance',
        'Quản lý deployment process',
      ],
      'invitedBy': 'Lab Admin',
      'invitedAt': '2026-01-16T14:30:00Z',
      'status': 'PENDING',
    },
  ];

  void _acceptInvitation(Map<String, dynamic> invitation) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Chấp nhận lời mời'),
        content: Text('Bạn có chắc chắn muốn chấp nhận mentor dự án "${invitation['project']['title']}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Call API to accept invitation
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Đã chấp nhận lời mời thành công!'),
                  backgroundColor: AppColors.success,
                ),
              );
              setState(() {
                _invitations.removeWhere((inv) => inv['id'] == invitation['id']);
              });
            },
            child: const Text('Chấp nhận'),
          ),
        ],
      ),
    );
  }

  void _rejectInvitation(Map<String, dynamic> invitation) {
    final reasonController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Từ chối lời mời'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Vui lòng cho biết lý do từ chối mentor dự án "${invitation['project']['title']}":'),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                hintText: 'VD: Không đủ thời gian, chuyên môn không phù hợp...',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            onPressed: () {
              if (reasonController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Vui lòng nhập lý do từ chối'),
                    backgroundColor: AppColors.error,
                  ),
                );
                return;
              }
              
              Navigator.pop(context);
              // TODO: Call API to reject invitation with reason
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Đã từ chối lời mời'),
                  backgroundColor: AppColors.error,
                ),
              );
              setState(() {
                _invitations.removeWhere((inv) => inv['id'] == invitation['id']);
              });
            },
            child: const Text('Từ chối'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lời mời Mentor'),
      ),
      body: _invitations.isEmpty
          ? const Center(
              child: EmptyState(
                icon: Icons.mail_outline,
                message: 'Bạn chưa có lời mời mentor nào',
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _invitations.length,
              itemBuilder: (context, index) {
                final invitation = _invitations[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _buildInvitationCard(invitation),
                );
              },
            ),
    );
  }

  Widget _buildInvitationCard(Map<String, dynamic> invitation) {
    final project = invitation['project'];
    final enterprise = invitation['enterprise'];

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Enterprise info
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: AppColors.backgroundGrey,
                child: const Icon(Icons.business, color: AppColors.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      enterprise['name'],
                      style: AppTextStyles.subtitle2.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Mời bởi ${invitation['invitedBy']} - ${_formatDate(invitation['invitedAt'])}',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              StatusBadge(
                label: 'MỚI',
                color: AppColors.warning,
              ),
            ],
          ),
          const Divider(height: 24),

          // Project title
          Text(
            project['title'],
            style: AppTextStyles.heading3.copyWith(
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 12),

          // Description
          Text(
            project['description'],
            style: AppTextStyles.body2.copyWith(
              color: AppColors.textSecondary,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 16),

          // Technologies
          Text(
            'Công nghệ:',
            style: AppTextStyles.body2.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: (project['technologies'] as List).map((tech) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  tech,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),

          // Project info
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.backgroundGrey,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                _buildInfoRow(Icons.paid, 'Thù lao', '${invitation['mentorCompensation'] ~/ 1000000}M VNĐ'),
                const SizedBox(height: 8),
                _buildInfoRow(Icons.schedule, 'Thời gian cam kết', invitation['expectedEffort']),
                const SizedBox(height: 8),
                _buildInfoRow(Icons.people, 'Số sinh viên', '${project['numberOfStudents']} SV'),
                const SizedBox(height: 8),
                _buildInfoRow(Icons.event, 'Thời gian dự án', '${project['startDate']} - ${project['endDate']}'),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Responsibilities
          Text(
            'Trách nhiệm:',
            style: AppTextStyles.body2.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          ...(invitation['responsibilities'] as List).map((resp) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.check_circle_outline, size: 16, color: AppColors.success),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      resp,
                      style: AppTextStyles.body2.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 16),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: AppButton(
                  text: 'Từ chối',
                  onPressed: () => _rejectInvitation(invitation),
                  backgroundColor: AppColors.white,
                  textColor: AppColors.error,
                  borderColor: AppColors.error,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: AppButton(
                  text: 'Chấp nhận',
                  onPressed: () => _acceptInvitation(invitation),
                  icon: Icons.check,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.textSecondary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: AppTextStyles.body2.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
        Text(
          value,
          style: AppTextStyles.body2.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  String _formatDate(String dateString) {
    final date = DateTime.parse(dateString);
    return '${date.day}/${date.month}/${date.year}';
  }
}


