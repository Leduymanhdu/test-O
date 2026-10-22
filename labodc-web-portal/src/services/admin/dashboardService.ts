// src/services/admin/dashboardService.ts

import axios from 'axios';

// Use relative URL to leverage Vite proxy configuration
const API_BASE_URL = '/api';

// Axios instance với config
const api = axios.create({
  baseURL: API_BASE_URL,
  headers: {
    'Content-Type': 'application/json',
  },
});

// Interceptor để thêm token
api.interceptors.request.use((config) => {
  const token = localStorage.getItem('access_token');
  if (token) {
    config.headers.Authorization = `Bearer ${token}`;
    console.log('🔑 Request with token:', token.substring(0, 30) + '...');
  } else {
    console.warn('⚠️ No token found in localStorage!');
  }
  return config;
});

// Response interceptor for debugging
api.interceptors.response.use(
  (response) => {
    console.log('📥 Response received:', {
      url: response.config.url,
      status: response.status,
      data: response.data,
    });
    return response;
  },
  (error) => {
    console.error('❌ API Error:', {
      url: error.config?.url,
      status: error.response?.status,
      data: error.response?.data,
    });
    return Promise.reject(error);
  }
);

// Types theo SRS document
export interface DashboardStats {
  projects: {
    total: number;
    new: number;
    ongoing: number;
    completed: number;
    cancelled: number;
    successRate: number;
  };
  enterprises: {
    total: number;
    new: number;
    active: number;
    verified: number;
  };
  talents: {
    total: number;
    new: number;
    active: number;
    averageRating: number;
  };
  mentors: {
    total: number;
    active: number;
    averageRating: number;
  };
  financials: {
    totalRevenue: number;
    teamDisbursed: number;
    mentorDisbursed: number;
    labRevenue: number;
    hybridFundAdvanced: number;
    hybridFundRepaid: number;
  };
  performance: {
    avgProjectCompletion: number;
    onTimeDelivery: number;
    customerSatisfaction: number;
  };
}

export interface RecentActivity {
  id: number;
  type: 'project' | 'payment' | 'enterprise' | 'report';
  title: string;
  description: string;
  timestamp: string;
  status: 'success' | 'warning' | 'info' | 'error';
}

export interface PendingApproval {
  id: number;
  type: 'enterprise' | 'project';
  title: string;
  submittedAt: string;
  priority: 'high' | 'medium' | 'low';
  
  // Enterprise specific fields
  companyName?: string;
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
  
  // Project specific fields
  slug?: string;
  requirements?: string;
  startDate?: string;
  endDate?: string;
  budget?: number;
  currency?: string;
  numberOfStudents?: number;
  status?: string;
  enterpriseName?: string;
}

// API Service
class DashboardService {
  // Lấy thống kê tổng quan
  async getStats(): Promise<DashboardStats> {
    console.log('📊 Loading dashboard stats from backend...');
    
    const response = await api.get('/dashboard/stats');
    console.log('✅ Full response:', response);
    console.log('✅ response.data:', response.data);
    console.log('✅ response.data.data:', response.data.data);
    
    // Map backend response to frontend format
    const data = response.data.data;
    
    if (!data) {
      console.error('❌ Backend response missing data field!');
      throw new Error('Invalid backend response structure');
    }
    
    return {
      projects: {
        total: data.projects.total,
        new: data.projects.newCount,
        ongoing: data.projects.ongoing,
        completed: data.projects.completed,
        cancelled: data.projects.cancelled,
        successRate: data.projects.successRate,
      },
      enterprises: {
        total: data.enterprises.total,
        new: data.enterprises.newCount,
        active: data.enterprises.active,
        verified: data.enterprises.verified,
      },
      talents: {
        total: data.talents.total,
        new: data.talents.newCount,
        active: data.talents.active,
        averageRating: data.talents.averageRating,
      },
      mentors: {
        total: data.mentors.total,
        active: data.mentors.active,
        averageRating: data.mentors.averageRating,
      },
      financials: {
        totalRevenue: data.financials.totalRevenue,
        teamDisbursed: data.financials.teamDisbursed,
        mentorDisbursed: data.financials.mentorDisbursed,
        labRevenue: data.financials.labRevenue,
        hybridFundAdvanced: data.financials.hybridFundAdvanced,
        hybridFundRepaid: data.financials.hybridFundRepaid,
      },
      performance: {
        avgProjectCompletion: data.performance.avgProjectCompletion,
        onTimeDelivery: data.performance.onTimeDelivery,
        customerSatisfaction: data.performance.customerSatisfaction,
      },
    };
  }

  // Lấy hoạt động gần đây
  async getRecentActivities(): Promise<RecentActivity[]> {
    console.log('📝 Loading recent activities from backend...');
    
    const response = await api.get('/dashboard/activities?limit=10');
    console.log('✅ Activities loaded from backend:', response.data.data.length);
    
    // Map backend response to frontend format
    return response.data.data.map((activity: any) => ({
      id: activity.id,
      type: activity.activityType,
      title: activity.title,
      description: activity.description,
      timestamp: activity.timestamp,
      status: activity.status,
    }));
  }

  // Lấy danh sách chờ phê duyệt
  async getPendingApprovals(limit: number = 10): Promise<PendingApproval[]> {
    console.log('⏳ Loading pending approvals from backend...');
    
    const response = await api.get(`/dashboard/approvals?limit=${limit}`);
    console.log('✅ Approvals loaded from backend:', response.data.data);
    
    // Return full data from backend (already matches interface)
    return response.data.data;
  }

  // Approve enterprise
  async approveEnterprise(id: number): Promise<void> {
    const response = await api.put(`/enterprises/${id}/verify`);
    return response.data;
  }

  // Reject enterprise
  async rejectEnterprise(id: number, reason?: string): Promise<void> {
    const response = await api.delete(`/enterprises/${id}`, {
      data: { reason }
    });
    return response.data;
  }

  // Approve project
  async approveProject(id: number): Promise<void> {
    const response = await api.put(`/projects/${id}/validate`);
    return response.data;
  }

  // Reject project
  async rejectProject(id: number, reason?: string): Promise<void> {
    const response = await api.delete(`/projects/${id}`, {
      data: { reason }
    });
    return response.data;
  }

  // Lấy dữ liệu biểu đồ doanh thu theo tháng
  async getRevenueChart(months: number = 6): Promise<any[]> {
    console.log('📈 Loading revenue chart from backend...');
    
    const response = await api.get(`/dashboard/revenue?months=${months}`);
    console.log('✅ Chart data loaded from backend:', response.data.data.length);
    
    // Map backend response to frontend format
    return response.data.data.map((item: any) => ({
      month: item.month,
      revenue: item.revenue,
      teamDisbursed: item.teamDisbursed,
      mentorDisbursed: item.mentorDisbursed,
      labRevenue: item.labRevenue,
    }));
  }
}

export const dashboardService = new DashboardService();