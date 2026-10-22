// Routes Configuration
import React, { Suspense, lazy } from 'react';
import { Routes, Route, Navigate } from 'react-router-dom';
import { Spin } from 'antd';
import { useAuth } from '@/hooks/useAuth';
import MainLayout from '@/components/layout/MainLayout';
import { ROUTES } from '@/utils/constants';

// Lazy load pages
const Login = lazy(() => import('@/pages/auth/Login'));
const Register = lazy(() => import('@/pages/auth/Register'));
const HomePage = lazy(() => import('@/pages/home/HomePage'));

// Enterprise pages
const EnterpriseDashboard = lazy(() => import('@/pages/enterprise/Dashboard'));
const ProjectManagement = lazy(() => import('@/pages/enterprise/ProjectManagement'));
const Payment = lazy(() => import('@/pages/enterprise/Payment'));
const Reports = lazy(() => import('@/pages/enterprise/Reports'));
const Feedback = lazy(() => import('@/pages/enterprise/Feedback'));

// Talent pages
const TalentDashboard = lazy(() => import('@/pages/talent/TalentDashboard'));
const BrowseProjects = lazy(() => import('@/pages/talent/ProjectsBrowse'));
const MyProjects = lazy(() => import('@/pages/talent/MyProjects'));
const Tasks = lazy(() => import('@/pages/talent/Tasks'));
const Profile = lazy(() => import('@/pages/talent/TalentProfile'));

// Mentor pages
const MentorDashboard = lazy(() => import('@/pages/mentor/Dashboard'));
const ProjectInvitations = lazy(() => import('@/pages/mentor/ProjectInvitations'));
const TaskManagement = lazy(() => import('@/pages/mentor/TaskManagement'));
const Evaluation = lazy(() => import('@/pages/mentor/Evaluation'));
const ReportSubmission = lazy(() => import('@/pages/mentor/ReportSubmission'));
const MentorReports = lazy(() => import('@/pages/mentor/Reports'));
const MentorApplications = lazy(() => import('@/pages/mentor/Applications'));

// Admin pages
const AdminDashboard = lazy(() => import('@/pages/admin/Dashboard'));
const PendingApprovals = lazy(() => import('@/pages/admin/Approvals/PendingApprovals'));
const EnterpriseManagement = lazy(() => import('@/pages/admin/EnterpriseManagement'));
const ProjectValidation = lazy(() => import('@/pages/admin/ProjectValidation'));
const FundAllocation = lazy(() => import('@/pages/admin/FundAllocation'));
const TransparencyReports = lazy(() => import('@/pages/admin/TransparencyReports'));
const Enterprises = lazy(() => import('@/pages/admin/Enterprises'));
const Talents = lazy(() => import('@/pages/admin/Talents'));
const Mentors = lazy(() => import('@/pages/admin/Mentors'));
const Projects = lazy(() => import('@/pages/admin/Projects'));

// Loading component
const LoadingFallback = () => (
  <div style={{ display: 'flex', justifyContent: 'center', alignItems: 'center', height: '100vh' }}>
    <Spin size="large" />
  </div>
);

// Protected Route Component
interface ProtectedRouteProps {
  children: React.ReactElement;
  allowedRoles?: string[];
}

const ProtectedRoute: React.FC<ProtectedRouteProps> = ({ children, allowedRoles }) => {
  const { isAuthenticated, user } = useAuth();

  if (!isAuthenticated) {
    return <Navigate to={ROUTES.LOGIN} replace />;
  }

  if (allowedRoles && user && !allowedRoles.includes(user.role)) {
    return <Navigate to="/" replace />;
  }

  return children;
};

const AppRoutes: React.FC = () => {
  return (
    <Suspense fallback={<LoadingFallback />}>
      <Routes>
        {/* Public Routes */}
        <Route path={ROUTES.HOME} element={<HomePage />} />
        <Route path={ROUTES.LOGIN} element={<Login />} />
        <Route path={ROUTES.REGISTER} element={<Register />} />

        {/* Enterprise Routes */}
        <Route
          path="/enterprise/*"
          element={
            <ProtectedRoute allowedRoles={['ENTERPRISE']}>
              <MainLayout />
            </ProtectedRoute>
          }
        >
          <Route path="dashboard" element={<EnterpriseDashboard />} />
          <Route path="projects" element={<ProjectManagement />} />
          <Route path="payment" element={<Payment />} />
          <Route path="reports" element={<Reports />} />
          <Route path="feedback" element={<Feedback />} />
        </Route>

        {/* Talent Routes */}
        <Route
          path="/talent/*"
          element={
            <ProtectedRoute allowedRoles={['TALENT', 'TALENT_LEADER']}>
              <MainLayout />
            </ProtectedRoute>
          }
        >
          <Route path="dashboard" element={<TalentDashboard />} />
          <Route path="projects/browse" element={<BrowseProjects />} />
          <Route path="projects" element={<BrowseProjects />} />
          <Route path="my-projects" element={<MyProjects />} />
          <Route path="tasks" element={<Tasks />} />
          <Route path="profile" element={<Profile />} />
        </Route>

        {/* Mentor Routes */}
        <Route
          path="/mentor/*"
          element={
            <ProtectedRoute allowedRoles={['MENTOR']}>
              <MainLayout />
            </ProtectedRoute>
          }
        >
          <Route path="dashboard" element={<MentorDashboard />} />
          <Route path="invitations" element={<ProjectInvitations />} />
          <Route path="applications" element={<MentorApplications />} />
          {/* Aliases for current UI navigation */}
          <Route path="tasks" element={<TaskManagement />} />
          <Route path="evaluation" element={<Evaluation />} />

          {/* Backward/route-param versions */}
          <Route path="projects/:id/tasks" element={<TaskManagement />} />
          <Route path="projects/:id/team" element={<Evaluation />} />
          <Route path="reports" element={<MentorReports />} />
          <Route path="reports/new" element={<ReportSubmission />} />
        </Route>

        {/* Admin Routes */}
        <Route
          path="/admin/*"
          element={
            <ProtectedRoute allowedRoles={['LAB_ADMIN']}>
              <MainLayout />
            </ProtectedRoute>
          }
        >
          <Route path="dashboard" element={<AdminDashboard />} />
          <Route path="approvals" element={<PendingApprovals />} />
          <Route path="enterprises" element={<EnterpriseManagement />} />
          <Route path="enterprises-crud" element={<Enterprises />} />
          <Route path="talents" element={<Talents />} />
          <Route path="mentors" element={<Mentors />} />
          <Route path="projects" element={<Projects />} />
          <Route path="projects/validate" element={<ProjectValidation />} />
          <Route path="funds" element={<FundAllocation />} />
          <Route path="reports" element={<TransparencyReports />} />
        </Route>
        <Route path="*" element={<Navigate to="/" replace />} />
      </Routes>
    </Suspense>
  );
};

export default AppRoutes;
