// Upload Service
import axiosInstance from './api/axios.config';
import { IApiResponse } from '@/types/api.types';

const UPLOAD_ENDPOINTS = {
  IMAGE: '/upload/image',
  FILE: '/upload/file',
  MULTIPLE: '/upload/multiple',
};

interface IUploadResponse {
  url: string;
  publicId: string;
  filename: string;
  size: number;
}

export const uploadService = {
  /**
   * Upload single image
   */
  uploadImage: async (file: File): Promise<IUploadResponse> => {
    const formData = new FormData();
    formData.append('image', file);

    const response = await axiosInstance.post<IApiResponse<IUploadResponse>>(
      UPLOAD_ENDPOINTS.IMAGE,
      formData,
      {
        headers: {
          'Content-Type': 'multipart/form-data',
        },
      }
    );
    return response.data.data;
  },

  /**
   * Upload single file (document, excel, etc.)
   */
  uploadFile: async (file: File): Promise<IUploadResponse> => {
    const formData = new FormData();
    formData.append('file', file);

    const response = await axiosInstance.post<IApiResponse<IUploadResponse>>(
      UPLOAD_ENDPOINTS.FILE,
      formData,
      {
        headers: {
          'Content-Type': 'multipart/form-data',
        },
      }
    );
    return response.data.data;
  },

  /**
   * Upload multiple files
   */
  uploadMultiple: async (files: File[]): Promise<IUploadResponse[]> => {
    const formData = new FormData();
    files.forEach((file) => {
      formData.append('files', file);
    });

    const response = await axiosInstance.post<IApiResponse<IUploadResponse[]>>(
      UPLOAD_ENDPOINTS.MULTIPLE,
      formData,
      {
        headers: {
          'Content-Type': 'multipart/form-data',
        },
      }
    );
    return response.data.data;
  },
};
