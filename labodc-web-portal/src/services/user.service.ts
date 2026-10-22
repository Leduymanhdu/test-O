// User Service
import axiosInstance from './api/axios.config';
import { IUser, IUserProfile, IUpdateProfileRequest } from '@/types/user.types';
import { IApiResponse } from '@/types/api.types';

const USER_ENDPOINTS = {
  BASE: '/users',
  PROFILE: '/users/profile',
  AVATAR: '/users/avatar',
};

export const userService = {
  /**
   * Get current user profile
   */
  getProfile: async (): Promise<IUserProfile> => {
    const response = await axiosInstance.get<IApiResponse<IUserProfile>>(
      USER_ENDPOINTS.PROFILE
    );
    return response.data.data;
  },

  /**
   * Update profile
   */
  updateProfile: async (data: IUpdateProfileRequest): Promise<IUserProfile> => {
    const response = await axiosInstance.put<IApiResponse<IUserProfile>>(
      USER_ENDPOINTS.PROFILE,
      data
    );
    return response.data.data;
  },

  /**
   * Upload avatar
   */
  uploadAvatar: async (file: File): Promise<string> => {
    const formData = new FormData();
    formData.append('avatar', file);

    const response = await axiosInstance.post<IApiResponse<{ url: string }>>(
      USER_ENDPOINTS.AVATAR,
      formData,
      {
        headers: {
          'Content-Type': 'multipart/form-data',
        },
      }
    );
    return response.data.data.url;
  },

  /**
   * Get user by ID
   */
  getUserById: async (id: string): Promise<IUser> => {
    const response = await axiosInstance.get<IApiResponse<IUser>>(
      `${USER_ENDPOINTS.BASE}/${id}`
    );
    return response.data.data;
  },

  /**
   * Get all users (Admin only)
   */
  getAllUsers: async (): Promise<IUser[]> => {
    const response = await axiosInstance.get<IApiResponse<IUser[]>>(
      USER_ENDPOINTS.BASE
    );
    return response.data.data;
  },

  /**
   * Change password
   */
  changePassword: async (data: {
    currentPassword: string;
    newPassword: string;
  }): Promise<void> => {
    await axiosInstance.post(`${USER_ENDPOINTS.PROFILE}/change-password`, data);
  },
};
