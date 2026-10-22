// src/services/admin/fundService.ts

import axios from 'axios';
import { STORAGE_KEYS } from '@/utils/constants';

const API_BASE_URL = import.meta.env.VITE_API_BASE_URL || 'http://localhost:8080/api';

console.log('🔧 [FundService] API_BASE_URL configured as:', API_BASE_URL);

// Axios instance
const api = axios.create({
  baseURL: API_BASE_URL,
  headers: {
    'Content-Type': 'application/json',
  },
});

// Interceptor
api.interceptors.request.use((config) => {
  const token = localStorage.getItem(STORAGE_KEYS.ACCESS_TOKEN);
  if (token) {
    config.headers.Authorization = `Bearer ${token}`;
  }
  console.log('🚀 [FundService] Request:', {
    method: config.method?.toUpperCase(),
    url: config.url,
    fullUrl: `${config.baseURL}${config.url}`,
    params: config.params,
    data: config.data,
    headers: config.headers
  });
  return config;
});

// Response interceptor
api.interceptors.response.use(
  (response) => {
    console.log('✅ [FundService] Response:', {
      status: response.status,
      url: response.config.url,
      data: response.data
    });
    return response;
  },
  (error) => {
    console.error('❌ [FundService] Response Error:', {
      message: error.message,
      url: error.config?.url,
      status: error.response?.status,
      statusText: error.response?.statusText,
      data: error.response?.data
    });
    return Promise.reject(error);
  }
);

// Types
export interface FundAllocation {
  projectId: number;
  projectTitle: string;
  enterpriseName: string;
  payment: {
    id: number;
    amount: number;
    status: 'PAID' | 'PENDING' | 'FAILED';
    paidAt: string;
  };
  allocation: {
    total: number;
    team: {
      amount: number;
      percentage: number;
      status: 'PENDING_DISTRIBUTION' | 'DISTRIBUTED' | 'DISBURSED';
    };
    mentor: {
      amount: number;
      percentage: number;
      status: 'PENDING_REPORT' | 'READY' | 'DISBURSED';
    };
    lab: {
      amount: number;
      percentage: number;
      status: 'RECEIVED' | 'PENDING';
    };
  };
  status: 'CONFIRMED' | 'PENDING' | 'COMPLETED';
}

export interface FundAllocationDetail extends FundAllocation {
  teamDistribution?: {
    distributionId: number;
    createdBy: string;
    members: TeamMemberAllocation[];
    status: 'PENDING_MENTOR_APPROVAL' | 'APPROVED' | 'DISBURSED';
    submittedAt: string;
  };
  mentorInfo?: {
    id: number;
    name: string;
    email: string;
    reportSubmitted: boolean;
    reportSubmittedAt?: string;
  };
}

export interface TeamMemberAllocation {
  talentId: number;
  fullName: string;
  percentage: number;
  amount: number;
  reason: string;
}

export interface DisburseMentorRequest {
  mentorId: number;
  amount: number;
  note: string;
}

export interface DisburseTeamRequest {
  distributionId: number;
  teamDistribution: {
    talentId: number;
    amount: number;
  }[];
  note: string;
}

export interface HybridFundAdvance {
  id: number;
  projectId: number;
  projectTitle: string;
  enterpriseName: string;
  advanceAmount: number;
  teamAmount: number;
  mentorAmount: number;
  enterpriseDebt: number;
  reason: string;
  expectedRepaymentDate: string;
  status: 'ADVANCED' | 'REPAID' | 'OVERDUE';
  advancedAt: string;
  repaidAt?: string;
  repaidAmount?: number;
  daysLate?: number;
}

export interface CreateHybridFundRequest {
  projectId: number;
  advanceAmount: number;
  recipients: {
    team: {
      amount: number;
      distribute: boolean;
    };
    mentor: {
      amount: number;
      distribute: boolean;
    };
  };
  reason: string;
  expectedRepaymentDate: string;
}

export interface ReconcileHybridFundRequest {
  paymentId: number;
  repaidAmount: number;
  repaidAt: string;
}

export interface DelayedPayment {
  projectId: number;
  projectTitle: string;
  enterprise: {
    id: number;
    name: string;
    email: string;
  };
  payment: {
    id: number;
    amount: number;
    dueDate: string;
    daysPastDue: number;
    status: 'DELAYED';
  };
  teamSize: number;
  mentorAssigned: boolean;
  urgency: 'HIGH' | 'MEDIUM' | 'LOW';
}

// API Service
class FundService {
  // Lấy danh sách phân bổ quỹ
  async getAllocations(status?: string): Promise<FundAllocation[]> {
    console.log('💰 [FundService] API Request - getAllocations, status:', status);
    console.log('💰 [FundService] URL:', `${API_BASE_URL}/lab-admin/fund-allocation/allocations`);
    try {
      const response = await api.get('/lab-admin/fund-allocation/allocations', {
        params: { status }
      });
      console.log('✅ [FundService] API Response - getAllocations:', response);
      console.log('✅ [FundService] Data:', response.data);
      return response.data.data || [];
    } catch (error: any) {
      console.error('❌ [FundService] API Error - getAllocations:', error);
      console.error('❌ [FundService] Error response:', error.response);
      throw error;
    }
  }

  // Lấy chi tiết phân bổ quỹ
  async getAllocationByProject(projectId: number): Promise<FundAllocationDetail> {
    console.log('💰 [FundService] API Request - getAllocationByProject, projectId:', projectId);
    const response = await api.get(`/lab-admin/fund-allocation/allocations/${projectId}`);
    console.log('✅ [FundService] API Response - getAllocationByProject:', response.data);
    return response.data.data;
  }

  // Xác nhận phân bổ quỹ
  async confirmAllocation(projectId: number): Promise<void> {
    console.log('💰 [FundService] API Request - confirmAllocation, projectId:', projectId);
    await api.post(`/lab-admin/projects/${projectId}/fund-allocation/confirm`);
  }

  // Giải ngân cho Mentor
  async disburseMentor(distributionId: number, data: DisburseMentorRequest): Promise<any> {
    const response = await api.post(`/lab-admin/fund-allocation/allocations/${distributionId}/disburse-mentor`, data);
    return response.data.data;
  }

  // Giải ngân cho Team
  async disburseTeam(distributionId: number, data: DisburseTeamRequest): Promise<any> {
    const response = await api.post(`/lab-admin/fund-allocation/allocations/${distributionId}/disburse-team`, data);
    return response.data.data;
  }

  // Lấy danh sách thanh toán chậm
  async getDelayedPayments(): Promise<DelayedPayment[]> {
    console.log('💰 [FundService] API Request - getDelayedPayments');
    try {
      const response = await api.get('/lab-admin/payments/delayed');
      console.log('✅ [FundService] API Response - getDelayedPayments:', response.data);
      return response.data?.data?.delayedPayments || [];
    } catch (error: any) {
      console.warn('⚠️ [FundService] Delayed payments endpoint not yet implemented:', error.message);
      return []; // Return empty array if endpoint not implemented
    }
  }

  // Tạo tạm ứng Hybrid Fund
  async createHybridFund(data: CreateHybridFundRequest): Promise<any> {
    console.log('💰 [FundService] API Request - createHybridFund:', data);
    const response = await api.post('/lab-admin/hybrid-funds/advance', data);
    return response.data.data;
  }

  // Lấy danh sách Hybrid Fund
  async getHybridFunds(status?: string): Promise<HybridFundAdvance[]> {
    console.log('💰 [FundService] API Request - getHybridFunds, status:', status);
    try {
      const response = await api.get('/lab-admin/hybrid-funds', {
        params: { status }
      });
      console.log('✅ [FundService] API Response - getHybridFunds:', response.data);
      return response.data?.data || [];
    } catch (error: any) {
      console.warn('⚠️ [FundService] Hybrid funds endpoint not yet implemented:', error.message);
      return []; // Return empty array if endpoint not implemented
    }
  }

  // Quyết toán Hybrid Fund
  async reconcileHybridFund(advanceId: number, data: ReconcileHybridFundRequest): Promise<any> {
    const response = await api.put(`/lab-admin/hybrid-funds/${advanceId}/reconcile`, data);
    return response.data.data;
  }

  // Lấy thống kê fund
  async getFundStatistics(): Promise<any> {
    console.log('💰 [FundService] API Request - getFundStatistics');
    try {
      const response = await api.get('/lab-admin/fund-allocation/stats');
      console.log('✅ [FundService] API Response - getFundStatistics:', response.data);
      return response.data.data;
    } catch (error: any) {
      console.error('❌ [FundService] API Error - getFundStatistics:', error);
      throw error;
    }
  }

  // Update fund allocation
  async updateAllocation(projectId: number, data: any): Promise<any> {
    const response = await api.put(`/lab-admin/fund-allocation/allocations/${projectId}`, data);
    return response.data;
  }

  // Delete fund allocation
  async deleteAllocation(projectId: number): Promise<void> {
    await api.delete(`/lab-admin/fund-allocation/allocations/${projectId}`);
  }
}

export const fundService = new FundService();
