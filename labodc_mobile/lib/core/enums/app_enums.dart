/// User Roles in the system
enum UserRole {
  systemAdmin,
  labAdmin,
  enterprise,
  talent,
  talentLeader,
  mentor;
  
  String get displayName {
    switch (this) {
      case UserRole.systemAdmin:
        return 'Quản trị viên hệ thống';
      case UserRole.labAdmin:
        return 'Quản trị viên Lab';
      case UserRole.enterprise:
        return 'Doanh nghiệp';
      case UserRole.talent:
        return 'Sinh viên';
      case UserRole.talentLeader:
        return 'Trưởng nhóm';
      case UserRole.mentor:
        return 'Mentor';
    }
  }
  
  String get apiValue {
    switch (this) {
      case UserRole.systemAdmin:
        return 'SYSTEM_ADMIN';
      case UserRole.labAdmin:
        return 'LAB_ADMIN';
      case UserRole.enterprise:
        return 'ENTERPRISE';
      case UserRole.talent:
        return 'TALENT';
      case UserRole.talentLeader:
        return 'TALENT_LEADER';
      case UserRole.mentor:
        return 'MENTOR';
    }
  }
  
  static UserRole fromString(String value) {
    switch (value.toUpperCase()) {
      case 'SYSTEM_ADMIN':
        return UserRole.systemAdmin;
      case 'LAB_ADMIN':
        return UserRole.labAdmin;
      case 'ENTERPRISE':
        return UserRole.enterprise;
      case 'TALENT':
        return UserRole.talent;
      case 'TALENT_LEADER':
        return UserRole.talentLeader;
      case 'MENTOR':
        return UserRole.mentor;
      default:
        throw Exception('Invalid user role: $value');
    }
  }
}

/// Project Status
enum ProjectStatus {
  draft,
  pending,
  approved,
  rejected,
  inProgress,
  completed,
  cancelled;
  
  String get displayName {
    switch (this) {
      case ProjectStatus.draft:
        return 'Bản nháp';
      case ProjectStatus.pending:
        return 'Chờ duyệt';
      case ProjectStatus.approved:
        return 'Đã duyệt';
      case ProjectStatus.rejected:
        return 'Từ chối';
      case ProjectStatus.inProgress:
        return 'Đang thực hiện';
      case ProjectStatus.completed:
        return 'Hoàn thành';
      case ProjectStatus.cancelled:
        return 'Đã hủy';
    }
  }
}

/// Account Status
enum AccountStatus {
  pending,
  active,
  inactive,
  locked;
  
  String get displayName {
    switch (this) {
      case AccountStatus.pending:
        return 'Chờ kích hoạt';
      case AccountStatus.active:
        return 'Hoạt động';
      case AccountStatus.inactive:
        return 'Ngừng hoạt động';
      case AccountStatus.locked:
        return 'Bị khóa';
    }
  }
}

/// Payment Status
enum PaymentStatus {
  pending,
  processing,
  completed,
  failed,
  refunded;
  
  String get displayName {
    switch (this) {
      case PaymentStatus.pending:
        return 'Chờ thanh toán';
      case PaymentStatus.processing:
        return 'Đang xử lý';
      case PaymentStatus.completed:
        return 'Hoàn thành';
      case PaymentStatus.failed:
        return 'Thất bại';
      case PaymentStatus.refunded:
        return 'Đã hoàn tiền';
    }
  }
}

/// Task Status
enum TaskStatus {
  todo,
  inProgress,
  review,
  done;
  
  String get displayName {
    switch (this) {
      case TaskStatus.todo:
        return 'Cần làm';
      case TaskStatus.inProgress:
        return 'Đang làm';
      case TaskStatus.review:
        return 'Đang review';
      case TaskStatus.done:
        return 'Hoàn thành';
    }
  }
}
