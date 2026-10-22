// Validation Functions
import { FILE_UPLOAD } from './constants';

/**
 * Validate email format
 */
export const isValidEmail = (email: string): boolean => {
  const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
  return emailRegex.test(email);
};

/**
 * Validate phone number (Vietnamese format)
 */
export const isValidPhone = (phone: string): boolean => {
  const phoneRegex = /(84|0[3|5|7|8|9])+([0-9]{8})\b/;
  return phoneRegex.test(phone);
};

/**
 * Validate password strength
 * - At least 8 characters
 * - Contains uppercase, lowercase, number, and special character
 */
export const isValidPassword = (password: string): boolean => {
  const passwordRegex = /^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$/;
  return passwordRegex.test(password);
};

/**
 * Get password strength level
 */
export const getPasswordStrength = (password: string): { level: number; label: string } => {
  if (!password) return { level: 0, label: 'Rất yếu' };
  
  let strength = 0;
  
  // Length check
  if (password.length >= 8) strength++;
  if (password.length >= 12) strength++;
  
  // Character variety
  if (/[a-z]/.test(password)) strength++;
  if (/[A-Z]/.test(password)) strength++;
  if (/[0-9]/.test(password)) strength++;
  if (/[@$!%*?&]/.test(password)) strength++;
  
  if (strength <= 2) return { level: 1, label: 'Yếu' };
  if (strength <= 4) return { level: 2, label: 'Trung bình' };
  if (strength <= 5) return { level: 3, label: 'Mạnh' };
  return { level: 4, label: 'Rất mạnh' };
};

/**
 * Validate username format
 * - Only alphanumeric and underscore
 * - 3-20 characters
 */
export const isValidUsername = (username: string): boolean => {
  const usernameRegex = /^[a-zA-Z0-9_]{3,20}$/;
  return usernameRegex.test(username);
};

/**
 * Validate URL format
 */
export const isValidURL = (url: string): boolean => {
  try {
    new URL(url);
    return true;
  } catch {
    return false;
  }
};

/**
 * Validate file type
 */
export const isValidFileType = (file: File, allowedTypes: string[]): boolean => {
  return allowedTypes.includes(file.type);
};

/**
 * Validate file size
 */
export const isValidFileSize = (file: File, maxSize: number = FILE_UPLOAD.MAX_SIZE): boolean => {
  return file.size <= maxSize;
};

/**
 * Validate image file
 */
export const isValidImage = (file: File): boolean => {
  return isValidFileType(file, [...FILE_UPLOAD.ALLOWED_IMAGE_TYPES]) &&
         isValidFileSize(file);
};

/**
 * Validate document file
 */
export const isValidDocument = (file: File): boolean => {
  return isValidFileType(file, [...FILE_UPLOAD.ALLOWED_DOCUMENT_TYPES]) &&
         isValidFileSize(file);
};

/**
 * Validate number range
 */
export const isInRange = (value: number, min: number, max: number): boolean => {
  return value >= min && value <= max;
};

/**
 * Validate required field
 */
export const isRequired = (value: any): boolean => {
  if (value === null || value === undefined) return false;
  if (typeof value === 'string') return value.trim().length > 0;
  if (Array.isArray(value)) return value.length > 0;
  return true;
};

/**
 * Validate min length
 */
export const hasMinLength = (value: string, minLength: number): boolean => {
  return value.length >= minLength;
};

/**
 * Validate max length
 */
export const hasMaxLength = (value: string, maxLength: number): boolean => {
  return value.length <= maxLength;
};

/**
 * Validate date range
 */
export const isValidDateRange = (startDate: Date | string, endDate: Date | string): boolean => {
  const start = new Date(startDate);
  const end = new Date(endDate);
  return start <= end;
};

/**
 * Validate future date
 */
export const isFutureDate = (date: Date | string): boolean => {
  const inputDate = new Date(date);
  const today = new Date();
  today.setHours(0, 0, 0, 0);
  return inputDate >= today;
};

/**
 * Validate past date
 */
export const isPastDate = (date: Date | string): boolean => {
  const inputDate = new Date(date);
  const today = new Date();
  today.setHours(0, 0, 0, 0);
  return inputDate < today;
};
