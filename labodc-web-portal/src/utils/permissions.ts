// Permission Utility Functions
import { TUserRole } from '@/types/user.types';
import { USER_ROLES } from './constants';

/**
 * Check if user has specific role
 */
export const hasRole = (userRole: TUserRole, requiredRole: TUserRole): boolean => {
  return userRole === requiredRole;
};

/**
 * Check if user has any of the specified roles
 */
export const hasAnyRole = (userRole: TUserRole, requiredRoles: TUserRole[]): boolean => {
  return requiredRoles.includes(userRole);
};

/**
 * Check if user has all of the specified roles
 */
export const hasAllRoles = (userRoles: TUserRole[], requiredRoles: TUserRole[]): boolean => {
  return requiredRoles.every((role) => userRoles.includes(role));
};

/**
 * Role hierarchy levels (higher number = more privileges)
 */
const ROLE_HIERARCHY: Record<TUserRole, number> = {
  LAB_ADMIN: 4,
  MENTOR: 3,
  TALENT_LEADER: 2,
  ENTERPRISE: 2,
  TALENT: 1,
};

/**
 * Check if user role is higher than or equal to required role
 */
export const hasRoleLevel = (userRole: TUserRole, requiredRole: TUserRole): boolean => {
  return ROLE_HIERARCHY[userRole] >= ROLE_HIERARCHY[requiredRole];
};

/**
 * Permission mappings for different actions
 */
export const PERMISSIONS = {
  // Project permissions
  PROJECT_CREATE: [USER_ROLES.ENTERPRISE],
  PROJECT_VIEW_ALL: [USER_ROLES.LAB_ADMIN],
  PROJECT_EDIT: [USER_ROLES.ENTERPRISE],
  PROJECT_DELETE: [USER_ROLES.ENTERPRISE],
  PROJECT_APPROVE: [USER_ROLES.LAB_ADMIN],
  PROJECT_JOIN: [USER_ROLES.TALENT],
  
  // Task permissions
  TASK_CREATE: [USER_ROLES.MENTOR, USER_ROLES.TALENT_LEADER],
  TASK_ASSIGN: [USER_ROLES.MENTOR, USER_ROLES.TALENT_LEADER],
  TASK_UPDATE: [USER_ROLES.MENTOR, USER_ROLES.TALENT_LEADER, USER_ROLES.TALENT],
  TASK_DELETE: [USER_ROLES.MENTOR, USER_ROLES.TALENT_LEADER],
  
  // Payment permissions
  PAYMENT_CREATE: [USER_ROLES.ENTERPRISE],
  PAYMENT_VIEW: [USER_ROLES.ENTERPRISE, USER_ROLES.LAB_ADMIN],
  
  // Report permissions
  REPORT_CREATE: [USER_ROLES.MENTOR, USER_ROLES.TALENT_LEADER],
  REPORT_VIEW: [USER_ROLES.ENTERPRISE, USER_ROLES.MENTOR, USER_ROLES.LAB_ADMIN],
  REPORT_APPROVE: [USER_ROLES.LAB_ADMIN],
  
  // Evaluation permissions
  EVALUATION_CREATE: [USER_ROLES.MENTOR, USER_ROLES.ENTERPRISE],
  EVALUATION_VIEW: [USER_ROLES.TALENT, USER_ROLES.MENTOR, USER_ROLES.ENTERPRISE],
  
  // User management permissions
  USER_VIEW_ALL: [USER_ROLES.LAB_ADMIN],
  USER_CREATE: [USER_ROLES.LAB_ADMIN],
  USER_EDIT: [USER_ROLES.LAB_ADMIN],
  USER_DELETE: [USER_ROLES.LAB_ADMIN],
  
  // Enterprise validation
  ENTERPRISE_VALIDATE: [USER_ROLES.LAB_ADMIN],
  
  // Fund management
  FUND_ALLOCATE: [USER_ROLES.LAB_ADMIN],
  FUND_VIEW: [USER_ROLES.LAB_ADMIN],
} as const;

/**
 * Check if user has permission for an action
 */
export const hasPermission = (
  userRole: TUserRole,
  permission: keyof typeof PERMISSIONS
): boolean => {
  const allowedRoles = [...PERMISSIONS[permission]] as TUserRole[];
  return allowedRoles.includes(userRole);
};

/**
 * Check if user can access a route
 */
export const canAccessRoute = (userRole: TUserRole, routePath: string): boolean => {
  // Public routes
  const publicRoutes = ['/', '/login', '/register', '/forgot-password'];
  if (publicRoutes.some((route) => routePath.startsWith(route))) {
    return true;
  }
  
  // Role-based route access
  const routeAccess: Record<string, TUserRole[]> = {
    '/enterprise': [USER_ROLES.ENTERPRISE],
    '/talent': [USER_ROLES.TALENT, USER_ROLES.TALENT_LEADER],
    '/mentor': [USER_ROLES.MENTOR],
    '/admin': [USER_ROLES.LAB_ADMIN],
  };
  
  for (const [prefix, roles] of Object.entries(routeAccess)) {
    if (routePath.startsWith(prefix)) {
      return roles.includes(userRole);
    }
  }
  
  return false;
};

/**
 * Get default route for user role
 */
export const getDefaultRoute = (userRole: TUserRole): string => {
  const roleRoutes: Record<TUserRole, string> = {
    LAB_ADMIN: '/admin/dashboard',
    ENTERPRISE: '/enterprise/dashboard',
    MENTOR: '/mentor/dashboard',
    TALENT: '/talent/dashboard',
    TALENT_LEADER: '/talent/dashboard',
  };
  
  return roleRoutes[userRole] || '/';
};

/**
 * Check if user can view project
 */
export const canViewProject = (userRole: TUserRole, projectOwnerId: string, userId: string): boolean => {
  // Admins can view all projects
  if (hasAnyRole(userRole, [USER_ROLES.LAB_ADMIN])) {
    return true;
  }
  
  // Enterprise can view their own projects
  if (userRole === USER_ROLES.ENTERPRISE && projectOwnerId === userId) {
    return true;
  }
  
  // Mentor and Talent can view projects they're involved in
  // This would require additional logic to check project membership
  return false;
};

/**
 * Check if user can edit project
 */
export const canEditProject = (userRole: TUserRole, projectOwnerId: string, userId: string): boolean => {
  return userRole === USER_ROLES.ENTERPRISE && projectOwnerId === userId;
};

/**
 * Check if user can delete project
 */
export const canDeleteProject = (userRole: TUserRole, projectOwnerId: string, userId: string): boolean => {
  // Only system admin or project owner can delete
  return userRole === USER_ROLES.ENTERPRISE && projectOwnerId === userId;
};
