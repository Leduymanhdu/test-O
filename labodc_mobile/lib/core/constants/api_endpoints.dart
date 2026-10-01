/// API Endpoints
class ApiEndpoints {
  // Auth
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String forgotPassword = '/auth/forgot-password';
  static const String resetPassword = '/auth/reset-password';
  static const String verifyEmail = '/auth/verify-email';
  static const String refreshToken = '/auth/refresh-token';
  static const String logout = '/auth/logout';
  
  // Enterprise
  static const String enterpriseProfile = '/enterprise/profile';
  static const String enterpriseProjects = '/enterprise/projects';
  static const String projectProposal = '/enterprise/projects/proposal';
  static const String enterprisePayment = '/enterprise/payment';
  static const String enterpriseReports = '/enterprise/reports';
  
  // Talent
  static const String talentProfile = '/talent/profile';
  static const String browseProjects = '/talent/projects/browse';
  static const String myProjects = '/talent/projects/my';
  static const String applyProject = '/talent/projects/apply';
  static const String talentTasks = '/talent/tasks';
  static const String talentEvaluations = '/talent/evaluations';
  
  // Mentor
  static const String mentorProfile = '/mentor/profile';
  static const String mentorProjects = '/mentor/projects';
  static const String projectInvitations = '/mentor/invitations';
  static const String taskManagement = '/mentor/tasks';
  static const String evaluations = '/mentor/evaluations';
  static const String mentorReports = '/mentor/reports';
  
  // Admin
  static const String adminDashboard = '/admin/dashboard';
  static const String enterpriseManagement = '/admin/enterprises';
  static const String projectValidation = '/admin/projects/validation';
  static const String fundAllocation = '/admin/fund-allocation';
  static const String transparencyReports = '/admin/transparency-reports';
  static const String userManagement = '/admin/users';
  
  // System Admin
  static const String systemConfig = '/system-admin/config';
  static const String roleManagement = '/system-admin/roles';
  static const String templateManagement = '/system-admin/templates';
  
  // Common
  static const String uploadFile = '/upload';
  static const String downloadFile = '/download';
  static const String notifications = '/notifications';
}
