import axiosInstance from './api/axios-admin.config';
import { STORAGE_KEYS } from '@/utils/constants';

const API_URL = import.meta.env.VITE_API_URL || 'http://localhost:8080';

export interface EnterpriseDTO {
  id: number;
  userId: number;
  userEmail?: string;
  companyName: string;
  taxCode?: string;
  businessLicenseNumber?: string;
  address?: string;
  city?: string;
  district?: string;
  ward?: string;
  representativeName?: string;
  representativePosition?: string;
  contactEmail?: string;
  contactPhone?: string;
  website?: string;
  industry?: string;
  companySize?: string;
  yearEstablished?: number;
  description?: string;
  status?: string; // PENDING, APPROVED, REJECTED
  verifiedAt?: string;
  verifiedBy?: number;
  verifiedByName?: string;
  createdAt?: string;
  updatedAt?: string;
  totalProjects?: number;
  activeProjects?: number;
}

export interface PageResponse<T> {
  content: T[];
  totalElements: number;
  totalPages: number;
  size: number;
  number: number;
}

export const enterpriseAdminService = {
  getAllEnterprises: async (page = 0, size = 10) => {
    const response = await axiosInstance.get<PageResponse<EnterpriseDTO>>(
      `/lab-admin/enterprises?page=${page}&size=${size}`
    );
    console.log('✅ getAllEnterprises response:', response.data);
    return response.data;
  },

  searchUsers: async (query: string) => {
    const response = await axiosInstance.get<Array<{ id: number; email: string; role: string }>>(
      `/lab-admin/enterprises/search-users?query=${encodeURIComponent(query)}`
    );
    return response.data;
  },

  getEnterpriseById: async (id: number) => {
    const response = await axiosInstance.get<EnterpriseDTO>(
      `/lab-admin/enterprises/${id}`
    );
    return response.data;
  },

  createEnterprise: async (data: Partial<EnterpriseDTO>) => {
    const response = await axiosInstance.post<EnterpriseDTO>(
      `/lab-admin/enterprises`,
      data
    );
    return response.data;
  },

  updateEnterprise: async (id: number, data: EnterpriseDTO) => {
    const response = await axiosInstance.put<EnterpriseDTO>(
      `/lab-admin/enterprises/${id}`,
      data
    );
    return response.data;
  },

  verifyEnterprise: async (id: number) => {
    const response = await axiosInstance.post(
      `/lab-admin/enterprises/${id}/verify`,
      {}
    );
    return response.data;
  },

  deleteEnterprise: async (id: number, reason: string) => {
    const response = await axiosInstance.delete(
      `/lab-admin/enterprises/${id}?reason=${encodeURIComponent(reason)}`
    );
    return response.data;
  }
};
