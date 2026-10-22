// Axios Configuration
import axios, { AxiosInstance, AxiosRequestConfig, AxiosResponse, AxiosError } from 'axios';
import { API_BASE_URL, API_TIMEOUT, STORAGE_KEYS } from '@/utils/constants';
import { IApiResponse, IApiError } from '@/types/api.types';

// Create axios instance
const axiosInstance: AxiosInstance = axios.create({
  baseURL: API_BASE_URL,
  timeout: API_TIMEOUT,
  headers: {
    'Content-Type': 'application/json',
  },
});

// Request interceptor
axiosInstance.interceptors.request.use(
  (config: any) => {
    // Add access token to request headers
    const token = localStorage.getItem(STORAGE_KEYS.ACCESS_TOKEN);
    if (token) {
      config.headers.Authorization = `Bearer ${token}`;
    }

    // Add timestamp to request
    config.metadata = { startTime: new Date().getTime() };

    // If sending FormData, let the browser set the multipart boundary
    if (config.data instanceof FormData) {
      if (config.headers) {
        delete config.headers['Content-Type'];
        delete config.headers['content-type'];
      }
    }

    return config;
  },
  (error: AxiosError) => {
    return Promise.reject(error);
  }
);

// Response interceptor
axiosInstance.interceptors.response.use(
  (response: AxiosResponse<IApiResponse>) => {
    // Calculate request duration
    const duration = new Date().getTime() - (response.config as any).metadata.startTime;
    console.log(`Request to ${response.config.url} took ${duration}ms`);

    return response;
  },
  async (error: AxiosError<IApiError>) => {
    // Phase1/2 microservices do not implement refresh-token yet.
    // If we get 401, clear tokens and let the caller handle UI.
    if (error.response?.status === 401) {
      localStorage.removeItem(STORAGE_KEYS.ACCESS_TOKEN);
      localStorage.removeItem(STORAGE_KEYS.REFRESH_TOKEN);
      localStorage.removeItem(STORAGE_KEYS.USER_INFO);
    }

    // Handle other errors
    const errorResponse: IApiError = {
      success: false,
      message: error.response?.data?.message || 'Đã xảy ra lỗi. Vui lòng thử lại!',
      errors: error.response?.data?.errors,
      timestamp: new Date().toISOString(),
    };

    return Promise.reject(errorResponse);
  }
);

export default axiosInstance;
