// App Constants

// API Configuration
export const API_BASE_URL = import.meta.env.VITE_API_BASE_URL || 'http://localhost:8080/api';
export const API_TIMEOUT = Number(import.meta.env.VITE_API_TIMEOUT) || 30000;

// App Information
export const APP_NAME = import.meta.env.VITE_APP_NAME || 'LabOdc Web Portal';
export const APP_VERSION = import.meta.env.VITE_APP_VERSION || '1.0.0';
export const APP_ENV = import.meta.env.VITE_APP_ENV || 'development';

// Storage Keys
export const STORAGE_KEYS = {
  ACCESS_TOKEN: 'access_token',
  REFRESH_TOKEN: 'refresh_token',
  USER_INFO: 'user_info',
  LANGUAGE: 'language',
  THEME: 'theme',
} as const;

// Routes
export const ROUTES = {
  HOME: '/',
  LOGIN: '/login',
  REGISTER: '/register',
  FORGOT_PASSWORD: '/forgot-password',
  RESET_PASSWORD: '/reset-password/:token',
  
  // Enterprise Routes
  ENTERPRISE_DASHBOARD: '/enterprise/dashboard',
  ENTERPRISE_PROJECTS: '/enterprise/projects',
  ENTERPRISE_PROJECT_DETAIL: '/enterprise/projects/:id',
  ENTERPRISE_PROJECT_EDIT: '/enterprise/projects/:id/edit',
  ENTERPRISE_PAYMENT: '/enterprise/payment',
  ENTERPRISE_PAYMENT_HISTORY: '/enterprise/payment/history',
  ENTERPRISE_PAYMENT_INVOICE: '/enterprise/payment/invoice/:id',
  ENTERPRISE_REPORTS: '/enterprise/reports',
  ENTERPRISE_REPORT_DETAIL: '/enterprise/reports/:id',
  ENTERPRISE_EVALUATION: '/enterprise/evaluation/:projectId',
  
  // Talent Routes
  TALENT_DASHBOARD: '/talent/dashboard',
  TALENT_BROWSE_PROJECTS: '/talent/projects/browse',
  TALENT_PROJECT_DETAIL: '/talent/projects/:id',
  TALENT_MY_PROJECTS: '/talent/my-projects',
  TALENT_TASKS: '/talent/tasks',
  TALENT_TASK_DETAIL: '/talent/tasks/:id',
  TALENT_PROFILE: '/talent/profile',
  TALENT_SKILLS: '/talent/profile/skills',
  TALENT_PERFORMANCE: '/talent/performance',
  
  // Mentor Routes
  MENTOR_DASHBOARD: '/mentor/dashboard',
  MENTOR_INVITATIONS: '/mentor/invitations',
  MENTOR_TASKS: '/mentor/projects/:id/tasks',
  MENTOR_EVALUATION: '/mentor/projects/:id/team',
  MENTOR_REPORT_NEW: '/mentor/reports/new',
  MENTOR_REPORTS: '/mentor/reports',
  
  // Lab Admin Routes
  ADMIN_DASHBOARD: '/admin/dashboard',
  ADMIN_ENTERPRISES: '/admin/enterprises',
  ADMIN_ENTERPRISE_VALIDATE: '/admin/enterprises/:id/validate',
  ADMIN_PROJECTS_VALIDATE: '/admin/projects/validate',
  ADMIN_PROJECT_REVIEW: '/admin/projects/:id/review',
  ADMIN_FUNDS: '/admin/funds',
  ADMIN_FUND_DETAIL: '/admin/funds/:projectId',
  ADMIN_REPORTS: '/admin/reports',
  ADMIN_REPORT_NEW: '/admin/reports/new',
  
} as const;

// Breakpoints
export const BREAKPOINTS = {
  mobile: '375px',
  tablet: '768px',
  laptop: '1366px',
  desktop: '1920px',
} as const;

export const MEDIA_QUERIES = {
  mobile: `(max-width: ${BREAKPOINTS.tablet})`,
  tablet: `(min-width: ${BREAKPOINTS.tablet}) and (max-width: ${BREAKPOINTS.laptop})`,
  laptop: `(min-width: ${BREAKPOINTS.laptop}) and (max-width: ${BREAKPOINTS.desktop})`,
  desktop: `(min-width: ${BREAKPOINTS.desktop})`,
} as const;

// Pagination
export const PAGINATION = {
  DEFAULT_PAGE: 1,
  DEFAULT_SIZE: 10,
  PAGE_SIZE_OPTIONS: [10, 20, 50, 100],
} as const;

// Date Formats
export const DATE_FORMATS = {
  DISPLAY: 'DD/MM/YYYY',
  DISPLAY_WITH_TIME: 'DD/MM/YYYY HH:mm',
  API: 'YYYY-MM-DD',
  API_WITH_TIME: 'YYYY-MM-DDTHH:mm:ss',
} as const;

// File Upload
export const FILE_UPLOAD = {
  MAX_SIZE: 10 * 1024 * 1024, // 10MB
  ALLOWED_IMAGE_TYPES: ['image/jpeg', 'image/png', 'image/gif'],
  ALLOWED_DOCUMENT_TYPES: [
    'application/pdf',
    'application/msword',
    'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
    'application/vnd.ms-excel',
    'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
  ],
} as const;

// Status Colors
export const STATUS_COLORS = {
  // Project Status
  DRAFT: 'default',
  PENDING_APPROVAL: 'warning',
  APPROVED: 'success',
  REJECTED: 'error',
  IN_PROGRESS: 'processing',
  COMPLETED: 'success',
  CANCELLED: 'default',
  
  // Task Status
  TODO: 'default',
  REVIEW: 'warning',
  DONE: 'success',
  BLOCKED: 'error',
  
  // Payment Status
  PENDING: 'warning',
  PROCESSING: 'processing',
  FAILED: 'error',
  REFUNDED: 'default',
  
  // User Status
  ACTIVE: 'success',
  INACTIVE: 'default',
  SUSPENDED: 'error',
} as const;

// Fund Distribution
export const FUND_DISTRIBUTION = {
  TEAM_PERCENTAGE: 70,
  MENTOR_PERCENTAGE: 20,
  LAB_PERCENTAGE: 10,
} as const;

// Roles
export const USER_ROLES = {
  LAB_ADMIN: 'LAB_ADMIN',
  ENTERPRISE: 'ENTERPRISE',
  MENTOR: 'MENTOR',
  TALENT: 'TALENT',
  TALENT_LEADER: 'TALENT_LEADER',
} as const;

// Role Labels
export const ROLE_LABELS = {
  LAB_ADMIN: 'Quản trị Lab',
  ENTERPRISE: 'Doanh nghiệp',
  MENTOR: 'Mentor',
  TALENT: 'Người tài năng',
  TALENT_LEADER: 'Trưởng nhóm',
} as const;
