// Authentication Service
import axiosInstance from './api/axios.config';
import {
  ILoginRequest,
  IRegisterRequest,
  IAuthResponse,
  IForgotPasswordRequest,
  IResetPasswordRequest,
} from '@/types/auth.types';

const AUTH_ENDPOINTS = {
  LOGIN: '/auth/login',
  REGISTER: '/auth/register',
  LOGOUT: '/auth/logout',
  REFRESH: '/auth/refresh',
  FORGOT_PASSWORD: '/auth/forgot-password',
  RESET_PASSWORD: '/auth/reset-password',
  VERIFY_EMAIL: '/auth/verify-email',
};

export const authService = {
  /**
   * Login
   */
  login: async (data: ILoginRequest): Promise<IAuthResponse> => {
    const response = await axiosInstance.post<IAuthResponse>(AUTH_ENDPOINTS.LOGIN, data);
    return response.data;
  },

  /**
   * Register
   */
  register: async (data: IRegisterRequest): Promise<IAuthResponse> => {
    // Phase1/2 backend returns empty body for register, so we auto-login right after.
    await axiosInstance.post(AUTH_ENDPOINTS.REGISTER, {
      email: data.email,
      password: data.password,
      confirmPassword: data.confirmPassword,
      role: data.role,
    });

    const loginResponse = await axiosInstance.post<IAuthResponse>(AUTH_ENDPOINTS.LOGIN, {
      email: data.email,
      password: data.password,
    });
    return loginResponse.data;
  },

  /**
   * Logout
   */
  logout: async (): Promise<void> => {
    await axiosInstance.post(AUTH_ENDPOINTS.LOGOUT);
  },

  /**
   * Refresh token
   */
  refreshToken: async (refreshToken: string): Promise<IAuthResponse> => {
    const response = await axiosInstance.post<IAuthResponse>(AUTH_ENDPOINTS.REFRESH, {
      refreshToken,
    });
    return response.data;
  },

  /**
   * Forgot password
   */
  forgotPassword: async (data: IForgotPasswordRequest): Promise<void> => {
    await axiosInstance.post(AUTH_ENDPOINTS.FORGOT_PASSWORD, data);
  },

  /**
   * Reset password
   */
  resetPassword: async (data: IResetPasswordRequest): Promise<void> => {
    await axiosInstance.post(AUTH_ENDPOINTS.RESET_PASSWORD, data);
  },

  /**
   * Verify email
   */
  verifyEmail: async (token: string): Promise<void> => {
    await axiosInstance.post(`${AUTH_ENDPOINTS.VERIFY_EMAIL}/${token}`);
  },
};
