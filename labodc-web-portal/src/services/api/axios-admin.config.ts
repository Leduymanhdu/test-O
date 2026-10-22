// Axios Configuration for Lab Admin (Monolith Backend)
import axios, { AxiosInstance, AxiosResponse, AxiosError } from 'axios';
import { STORAGE_KEYS } from '@/utils/constants';
import { IApiResponse, IApiError } from '@/types/api.types';

// Lab Admin uses the monolith backend on port 8080
const ADMIN_API_BASE_URL = 'http://localhost:8080/api';
const API_TIMEOUT = 30000;

// Create axios instance for admin endpoints
const axiosAdminInstance: AxiosInstance = axios.create({
  baseURL: ADMIN_API_BASE_URL,
  timeout: API_TIMEOUT,
  headers: {
    'Content-Type': 'application/json',
  },
});

// Request interceptor
axiosAdminInstance.interceptors.request.use(
  (config: any) => {
    // Add access token to request headers
    const token = localStorage.getItem(STORAGE_KEYS.ACCESS_TOKEN);
    if (token) {
      config.headers.Authorization = `Bearer ${token}`;
    }

    // Add timestamp to request
    config.metadata = { startTime: new Date().getTime() };

    return config;
  },
  (error: AxiosError) => {
    return Promise.reject(error);
  }
);

// Response interceptor
axiosAdminInstance.interceptors.response.use(
  (response: AxiosResponse<IApiResponse>) => {
    // Calculate request duration
    const duration = new Date().getTime() - (response.config as any).metadata.startTime;
    console.log(`Admin API request to ${response.config.url} took ${duration}ms`);

    return response;
  },
  async (error: AxiosError<IApiError>) => {
    // Handle authentication errors
    if (error.response?.status === 401) {
      localStorage.removeItem(STORAGE_KEYS.ACCESS_TOKEN);
      localStorage.removeItem(STORAGE_KEYS.REFRESH_TOKEN);
      localStorage.removeItem(STORAGE_KEYS.USER_INFO);
      window.location.href = '/login';
    }

    return Promise.reject(error);
  }
);

export default axiosAdminInstance;
