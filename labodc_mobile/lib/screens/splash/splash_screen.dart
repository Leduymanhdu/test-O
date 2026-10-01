import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:labodc_mobile/core/theme/app_colors.dart';
import 'package:labodc_mobile/core/theme/app_text_styles.dart';
import 'package:labodc_mobile/core/routes/app_router.dart';
import 'package:labodc_mobile/providers/auth_provider.dart';

/// Splash Screen - First screen when app launches
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNext();
  }

  Future<void> _navigateToNext() async {
    // Wait for splash screen animation
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    // Check authentication status
    final authProvider = context.read<AuthProvider>();
    // Ensure auth state initialized (tokens from storage)
    await authProvider.init();

    if (authProvider.isAuthenticated && authProvider.currentAuthData != null) {
      // User is logged in - navigate to appropriate dashboard
      final role = authProvider.userRole;
      switch (role?.apiValue) {
        case 'ENTERPRISE':
          context.go(AppRoutes.enterpriseDashboard);
          break;
        case 'TALENT':
        case 'TALENT_LEADER':
          context.go(AppRoutes.talentDashboard);
          break;
        case 'MENTOR':
          context.go(AppRoutes.mentorDashboard);
          break;
        case 'LAB_ADMIN':
        case 'SYSTEM_ADMIN':
          context.go(AppRoutes.adminDashboard);
          break;
        default:
          context.go(AppRoutes.login);
      }
    } else {
      // User not logged in - go to login
      context.go(AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // TODO: Add app logo
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.school,
                size: 60,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'LabOdc',
              style: AppTextStyles.heading1.copyWith(
                color: AppColors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Kết nối doanh nghiệp - Tài năng UTH',
              style: AppTextStyles.body2.copyWith(
                color: AppColors.white.withValues(alpha: 0.9),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 48),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
            ),
          ],
        ),
      ),
    );
  }
}
