import 'package:go_router/go_router.dart';
import 'package:labodc_mobile/screens/auth/login_screen.dart';
import 'package:labodc_mobile/screens/auth/register_screen.dart';
import 'package:labodc_mobile/screens/auth/forgot_password_screen.dart';
import 'package:labodc_mobile/screens/home/home_screen.dart';
import 'package:labodc_mobile/screens/splash/splash_screen.dart';

// Enterprise Screens
import 'package:labodc_mobile/screens/enterprise/dashboard_screen.dart';
import 'package:labodc_mobile/screens/enterprise/project_proposal_screen.dart';
import 'package:labodc_mobile/screens/enterprise/project_list_screen.dart';
import 'package:labodc_mobile/screens/enterprise/payment_screen.dart';
import 'package:labodc_mobile/screens/enterprise/reports_screen.dart';

// Talent Screens
import 'package:labodc_mobile/screens/talent/dashboard_screen.dart';
import 'package:labodc_mobile/screens/talent/browse_projects_screen.dart';
import 'package:labodc_mobile/screens/talent/my_projects_screen.dart';
import 'package:labodc_mobile/screens/talent/tasks_screen.dart';
import 'package:labodc_mobile/screens/talent/profile_screen.dart';

// Mentor Screens
import 'package:labodc_mobile/screens/mentor/dashboard_screen.dart';
import 'package:labodc_mobile/screens/mentor/project_invitations_screen.dart';
import 'package:labodc_mobile/screens/mentor/task_management_screen.dart';
import 'package:labodc_mobile/screens/mentor/evaluation_screen.dart';
import 'package:labodc_mobile/screens/mentor/report_submission_screen.dart';

// Admin Screens
import 'package:labodc_mobile/screens/admin/dashboard_screen.dart';
import 'package:labodc_mobile/screens/admin/enterprise_management_screen.dart';
import 'package:labodc_mobile/screens/admin/project_validation_screen.dart';
import 'package:labodc_mobile/screens/admin/fund_management_screen.dart';

/// App Route Names
class AppRoutes {
  // Auth Routes
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';

  // Home
  static const String home = '/home';

  // Enterprise Routes
  static const String enterpriseDashboard = '/enterprise/dashboard';
  static const String projectProposal = '/enterprise/project-proposal';
  static const String enterpriseProjects = '/enterprise/projects';
  static const String enterprisePayment = '/enterprise/payment';
  static const String enterpriseReports = '/enterprise/reports';

  // Talent Routes
  static const String talentDashboard = '/talent/dashboard';
  static const String browseProjects = '/talent/browse-projects';
  static const String myProjects = '/talent/my-projects';
  static const String talentTasks = '/talent/tasks';
  static const String talentProfile = '/talent/profile';

  // Mentor Routes
  static const String mentorDashboard = '/mentor/dashboard';
  static const String projectInvitations = '/mentor/invitations';
  static const String taskManagement = '/mentor/task-management';
  static const String evaluation = '/mentor/evaluation';
  static const String reportSubmission = '/mentor/report-submission';

  // Admin Routes
  static const String adminDashboard = '/admin/dashboard';
  static const String adminEnterpriseManagement =
      '/admin/enterprise-management';
  static const String adminProjectValidation = '/admin/project-validation';
  static const String adminFundAllocation = '/admin/fund-allocation';
}

/// App Router Configuration
class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: AppRoutes.splash,
    routes: [
      // Splash
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashScreen(),
      ),

      // Auth Routes
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.register,
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        builder: (context, state) => const ForgotPasswordScreen(),
      ),

      // Home
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => const HomeScreen(),
      ),

      // Enterprise Routes
      GoRoute(
        path: AppRoutes.enterpriseDashboard,
        builder: (context, state) => const EnterpriseDashboardScreen(),
      ),
      GoRoute(
        path: AppRoutes.projectProposal,
        builder: (context, state) => const ProjectProposalScreen(),
      ),
      GoRoute(
        path: AppRoutes.enterpriseProjects,
        builder: (context, state) => const EnterpriseProjectListScreen(),
      ),
      GoRoute(
        path: AppRoutes.enterprisePayment,
        builder: (context, state) => const EnterprisePaymentScreen(),
      ),
      GoRoute(
        path: AppRoutes.enterpriseReports,
        builder: (context, state) => const EnterpriseReportsScreen(),
      ),

      // Talent Routes
      GoRoute(
        path: AppRoutes.talentDashboard,
        builder: (context, state) => const TalentDashboardScreen(),
      ),
      GoRoute(
        path: AppRoutes.browseProjects,
        builder: (context, state) => const BrowseProjectsScreen(),
      ),
      GoRoute(
        path: AppRoutes.myProjects,
        builder: (context, state) => const MyProjectsScreen(),
      ),
      GoRoute(
        path: AppRoutes.talentTasks,
        builder: (context, state) => const TalentTasksScreen(),
      ),
      GoRoute(
        path: AppRoutes.talentProfile,
        builder: (context, state) => const TalentProfileScreen(),
      ),

      // Mentor Routes
      GoRoute(
        path: AppRoutes.mentorDashboard,
        builder: (context, state) => const MentorDashboardScreen(),
      ),
      GoRoute(
        path: AppRoutes.projectInvitations,
        builder: (context, state) => const ProjectInvitationsScreen(),
      ),
      GoRoute(
        path: AppRoutes.taskManagement,
        builder: (context, state) => const TaskManagementScreen(),
      ),
      GoRoute(
        path: AppRoutes.evaluation,
        builder: (context, state) => const EvaluationScreen(),
      ),
      GoRoute(
        path: AppRoutes.reportSubmission,
        builder: (context, state) => const ReportSubmissionScreen(),
      ),

      // Admin Routes
      GoRoute(
        path: AppRoutes.adminDashboard,
        builder: (context, state) => const AdminDashboardScreen(),
      ),
      GoRoute(
        path: AppRoutes.adminEnterpriseManagement,
        builder: (context, state) => const EnterpriseManagementScreen(),
      ),
      GoRoute(
        path: AppRoutes.adminProjectValidation,
        builder: (context, state) => const ProjectValidationScreen(),
      ),
      GoRoute(
        path: AppRoutes.adminFundAllocation,
        builder: (context, state) => const FundManagementScreen(),
      ),
    ],
  );
}
