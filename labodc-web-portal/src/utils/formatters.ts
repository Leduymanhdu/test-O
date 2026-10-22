// Data Formatters
import dayjs from 'dayjs';
import { DATE_FORMATS } from './constants';

/**
 * Format date for display
 */
export const formatDateDisplay = (date: string | Date | null | undefined): string => {
  if (!date) return '-';
  return dayjs(date).format(DATE_FORMATS.DISPLAY);
};

/**
 * Format datetime for display
 */
export const formatDateTimeDisplay = (date: string | Date | null | undefined): string => {
  if (!date) return '-';
  return dayjs(date).format(DATE_FORMATS.DISPLAY_WITH_TIME);
};

/**
 * Format date for API
 */
export const formatDateAPI = (date: string | Date | null | undefined): string => {
  if (!date) return '';
  return dayjs(date).format(DATE_FORMATS.API);
};

/**
 * Format datetime for API
 */
export const formatDateTimeAPI = (date: string | Date | null | undefined): string => {
  if (!date) return '';
  return dayjs(date).format(DATE_FORMATS.API_WITH_TIME);
};

/**
 * Format currency (VND)
 */
export const formatCurrencyVND = (amount: number | null | undefined): string => {
  if (amount === null || amount === undefined) return '-';
  return new Intl.NumberFormat('vi-VN', {
    style: 'currency',
    currency: 'VND',
  }).format(amount);
};

/**
 * Format percentage
 */
export const formatPercentage = (value: number, decimals: number = 0): string => {
  return `${value.toFixed(decimals)}%`;
};

/**
 * Format phone number
 */
export const formatPhoneNumber = (phone: string): string => {
  if (!phone) return '-';
  // Format: 0xxx xxx xxx
  const cleaned = phone.replace(/\D/g, '');
  const match = cleaned.match(/^(\d{4})(\d{3})(\d{3})$/);
  if (match) {
    return `${match[1]} ${match[2]} ${match[3]}`;
  }
  return phone;
};

/**
 * Format status badge
 */
export const formatStatusBadge = (status: string): { color: string; text: string } => {
  const statusMap: Record<string, { color: string; text: string }> = {
    // Project statuses
    DRAFT: { color: 'default', text: 'Bản nháp' },
    PENDING_APPROVAL: { color: 'warning', text: 'Chờ duyệt' },
    APPROVED: { color: 'success', text: 'Đã duyệt' },
    REJECTED: { color: 'error', text: 'Từ chối' },
    IN_PROGRESS: { color: 'processing', text: 'Đang thực hiện' },
    COMPLETED: { color: 'success', text: 'Hoàn thành' },
    CANCELLED: { color: 'default', text: 'Đã hủy' },
    
    // Task statuses
    TODO: { color: 'default', text: 'Cần làm' },
    REVIEW: { color: 'warning', text: 'Đang xem xét' },
    DONE: { color: 'success', text: 'Hoàn thành' },
    BLOCKED: { color: 'error', text: 'Bị chặn' },
    
    // Payment statuses
    PENDING: { color: 'warning', text: 'Chờ xử lý' },
    PROCESSING: { color: 'processing', text: 'Đang xử lý' },
    FAILED: { color: 'error', text: 'Thất bại' },
    REFUNDED: { color: 'default', text: 'Hoàn tiền' },
    
    // User statuses
    ACTIVE: { color: 'success', text: 'Hoạt động' },
    INACTIVE: { color: 'default', text: 'Không hoạt động' },
    SUSPENDED: { color: 'error', text: 'Tạm khóa' },
  };
  
  return statusMap[status] || { color: 'default', text: status };
};

/**
 * Format priority badge
 */
export const formatPriorityBadge = (priority: string): { color: string; text: string } => {
  const priorityMap: Record<string, { color: string; text: string }> = {
    LOW: { color: 'default', text: 'Thấp' },
    MEDIUM: { color: 'warning', text: 'Trung bình' },
    HIGH: { color: 'error', text: 'Cao' },
    URGENT: { color: 'error', text: 'Khẩn cấp' },
  };
  
  return priorityMap[priority] || { color: 'default', text: priority };
};

/**
 * Format role label
 */
export const formatRoleLabel = (role: string): string => {
  const roleMap: Record<string, string> = {
    LAB_ADMIN: 'Quản trị Lab',
    ENTERPRISE: 'Doanh nghiệp',
    MENTOR: 'Mentor',
    TALENT: 'Người tài năng',
    TALENT_LEADER: 'Trưởng nhóm',
  };
  
  return roleMap[role] || role;
};

/**
 * Format file size
 */
export const formatFileSizeDisplay = (bytes: number): string => {
  if (bytes === 0) return '0 Bytes';
  const k = 1024;
  const sizes = ['Bytes', 'KB', 'MB', 'GB'];
  const i = Math.floor(Math.log(bytes) / Math.log(k));
  return `${parseFloat((bytes / Math.pow(k, i)).toFixed(2))} ${sizes[i]}`;
};

/**
 * Format duration (minutes to hours/minutes)
 */
export const formatDuration = (minutes: number): string => {
  if (minutes < 60) return `${minutes} phút`;
  const hours = Math.floor(minutes / 60);
  const mins = minutes % 60;
  return mins > 0 ? `${hours} giờ ${mins} phút` : `${hours} giờ`;
};

/**
 * Format rating
 */
export const formatRating = (rating: number, maxRating: number = 5): string => {
  return `${rating.toFixed(1)}/${maxRating}`;
};
