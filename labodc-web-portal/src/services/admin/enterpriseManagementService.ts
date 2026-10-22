// Enterprise Management Service
import axios from 'axios';
import { STORAGE_KEYS } from '@/utils/constants';

const api = axios.create({
  baseURL: '/api',
  headers: {
    'Content-Type': 'application/json',
  },
});

// Request interceptor
api.interceptors.request.use(
  (config) => {
    const token = localStorage.getItem(STORAGE_KEYS.ACCESS_TOKEN);
    console.log('🚀 [EnterpriseManagement] API Request:', {
      url: config.url,
      baseURL: config.baseURL,
      fullURL: `${config.baseURL}${config.url}`,
      method: config.method?.toUpperCase(),
      hasToken: !!token,
      tokenPreview: token ? `${token.substring(0, 30)}...` : '❌ NO TOKEN',
      headers: config.headers
    });
    if (token) {
      config.headers.Authorization = `Bearer ${token}`;
    }
    return config;
  },
  (error) => {
    console.error('❌ Request Error:', error);
    return Promise.reject(error);
  }
);

// Response interceptor
api.interceptors.response.use(
  (response) => {
    console.log('✅ [EnterpriseManagement] API Response:', {
      url: response.config.url,
      status: response.status,
      statusText: response.statusText,
      data: response.data,
      dataType: typeof response.data,
      hasData: !!response.data?.data
    });
    return response;
  },
  (error) => {
    console.error('❌ [EnterpriseManagement] API Error:', {
      url: error.config?.url,
      status: error.response?.status,
      statusText: error.response?.statusText,
      message: error.message,
      responseData: error.response?.data,
      fullError: error
    });
    return Promise.reject(error);
  }
);

export interface EnterpriseStats {
  total: number;
  verified: number;
  unverified: number;
  active: number;
  thisMonth: number;
}

export interface EnterpriseListItem {
  id: number;
  userId: number;
  companyName: string;
  taxCode: string;
  contactEmail: string;
  contactPhone: string;
  industry: string;
  companySize: string;
  status: 'PENDING' | 'APPROVED' | 'REJECTED';
  verifiedAt?: string;
  createdAt: string;
  totalProjects: number;
  activeProjects: number;
  totalBudget: number;
}

export interface EnterpriseDetail {
  id: number;
  userId: number;
  companyName: string;
  taxCode: string;
  businessLicenseNumber: string;
  address: string;
  city: string;
  district: string;
  ward: string;
  representativeName: string;
  representativePosition: string;
  contactEmail: string;
  contactPhone: string;
  website: string;
  industry: string;
  companySize: string;
  yearEstablished: number;
  description: string;
  status: 'PENDING' | 'APPROVED' | 'REJECTED';
  verifiedAt?: string;
  verifiedBy?: number;
  createdAt: string;
  updatedAt: string;
  rejectionReason?: string;
  rejectedAt?: string;
  rejectedBy?: number;
}

class EnterpriseManagementService {
  async getStats(): Promise<EnterpriseStats> {
    const response = await api.get('/enterprises/stats');
    return response.data.data;
  }

  async getEnterprises(params?: any): Promise<{ enterprises: EnterpriseListItem[], pagination: any }> {
    console.log('🏢 [EnterpriseService] getEnterprises called with params:', params);
    console.log('🏢 [EnterpriseService] API baseURL:', api.defaults.baseURL);
    console.log('🏢 [EnterpriseService] Full URL will be:', `${api.defaults.baseURL}/enterprises/management`);
    
    try {
      console.log('🏢 [EnterpriseService] Making API call...');
      const response = await api.get('/enterprises/management', { params });
      console.log('🏢 [EnterpriseService] Response received:', response);
      console.log('🏢 [EnterpriseService] Response status:', response.status);
      console.log('🏢 [EnterpriseService] Response data:', response.data);
      console.log('🏢 [EnterpriseService] Response data.data:', response.data.data);
      
      // Backend trả về array trực tiếp trong data.data
      const enterprises = response.data.data || [];
      return {
        enterprises,
        pagination: {
          total: enterprises.length,
          page: 1,
          limit: enterprises.length
        }
      };
    } catch (error: any) {
      console.error('🏢 [EnterpriseService] ❌ ERROR CAUGHT');
      console.error('🏢 [EnterpriseService] Error type:', error.constructor.name);
      console.error('🏢 [EnterpriseService] Error message:', error.message);
      console.error('🏢 [EnterpriseService] Error code:', error.code);
      console.error('🏢 [EnterpriseService] Error response:', error.response);
      console.error('🏢 [EnterpriseService] Error response status:', error.response?.status);
      console.error('🏢 [EnterpriseService] Error response data:', error.response?.data);
      console.error('🏢 [EnterpriseService] Full error object:', JSON.stringify(error, Object.getOwnPropertyNames(error), 2));
      throw error;
    }
  }

  async getEnterpriseById(id: number): Promise<EnterpriseDetail> {
    const response = await api.get(`/enterprises/${id}`);
    return response.data.data;
  }

  async verifyEnterprise(id: number): Promise<void> {
    await api.put(`/enterprises/${id}/verify`);
  }

  async rejectEnterprise(id: number, reason?: string): Promise<void> {
    await api.delete(`/enterprises/${id}`, {
      data: { reason },
    });
  }
}

export const enterpriseManagementService = new EnterpriseManagementService();
