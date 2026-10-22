// src/services/admin/enterpriseService.ts

import axios from 'axios';
import { STORAGE_KEYS } from '@/utils/constants';

const API_BASE_URL = import.meta.env.VITE_API_BASE_URL || 'http://localhost:8080/api';

// Axios instance
const api = axios.create({
  baseURL: API_BASE_URL,
  headers: {
    'Content-Type': 'application/json',
  },
});

// Interceptor để thêm token
api.interceptors.request.use((config) => {
  const token = localStorage.getItem('token');
  if (token) {
    config.headers.Authorization = `Bearer ${token}`;
  }
  return config;
});

// Types
export interface Enterprise {
  id: number;
  companyName: string;
  taxCode: string;
  address: string;
  representative: string;
  email: string;
  phone: string;
  industry: string;
  website?: string;
  logoUrl?: string;
  registeredAt: string;
  status: 'PENDING' | 'APPROVED' | 'REJECTED';
  documents?: EnterpriseDocument[];
}

export interface EnterpriseDocument {
  type: 'BUSINESS_LICENSE' | 'TAX_REGISTRATION' | 'OTHER';
  url: string;
  fileName: string;
}

export interface EnterpriseDetail extends Enterprise {
  verifiedBy?: number;
  verifiedAt?: string;
  rejectionReason?: string;
  projectsCount?: number;
  totalInvestment?: number;
}

export interface ApproveEnterpriseRequest {
  note: string;
}

export interface RejectEnterpriseRequest {
  reason: string;
  details: string;
}

export interface RequestInfoRequest {
  message: string;
  requiredDocuments: string[];
}

export interface EnterpriseListParams {
  status?: 'PENDING' | 'APPROVED' | 'REJECTED';
  search?: string;
  page?: number;
  limit?: number;
}

export interface EnterpriseListResponse {
  enterprises: Enterprise[];
  pagination: {
    total: number;
    page: number;
    totalPages: number;
  };
}

// API Service
class EnterpriseService {
  // Lấy danh sách doanh nghiệp
  async getEnterprises(params: EnterpriseListParams): Promise<EnterpriseListResponse> {
    const response = await api.get('/lab-admin/enterprises', { params });
    return response.data.data;
  }

  // Lấy danh sách doanh nghiệp chờ xác thực
  async getPendingEnterprises(): Promise<Enterprise[]> {
    const response = await api.get('/lab-admin/enterprises/pending');
    return response.data.data.enterprises;
  }

  // Lấy chi tiết doanh nghiệp
  async getEnterpriseById(id: number): Promise<EnterpriseDetail> {
    const response = await api.get(`/lab-admin/enterprises/${id}`);
    return response.data.data;
  }

  // Phê duyệt doanh nghiệp
  async approveEnterprise(id: number, data: ApproveEnterpriseRequest): Promise<void> {
    await api.post(`/lab-admin/enterprises/${id}/approve`, data);
  }

  // Từ chối doanh nghiệp
  async rejectEnterprise(id: number, data: RejectEnterpriseRequest): Promise<void> {
    await api.post(`/lab-admin/enterprises/${id}/reject`, data);
  }

  // Yêu cầu bổ sung thông tin
  async requestInfo(id: number, data: RequestInfoRequest): Promise<void> {
    await api.post(`/lab-admin/enterprises/${id}/request-info`, data);
  }

  // Tìm kiếm doanh nghiệp
  async searchEnterprises(keyword: string): Promise<Enterprise[]> {
    const response = await api.get('/lab-admin/enterprises/search', {
      params: { q: keyword }
    });
    return response.data.data;
  }
}

export const enterpriseService = new EnterpriseService();