// src/services/admin/reportService.ts

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

// Interceptor
api.interceptors.request.use((config) => {
  const token = localStorage.getItem(STORAGE_KEYS.ACCESS_TOKEN);
  if (token) {
    config.headers.Authorization = `Bearer ${token}`;
  }
  return config;
});

// Types
export interface TransparencyReport {
  reportId: number;
  reportType: 'MONTHLY' | 'QUARTERLY' | 'YEARLY';
  period: string; // YYYY-MM format
  statistics: ReportStatistics;
  chartsData?: any;
  status: 'DRAFT' | 'PUBLISHED' | 'ARCHIVED';
  createdBy: number;
  publishedAt?: string;
  publicUrl?: string;
  pdfUrl?: string;
  createdAt: string;
}

export interface ReportStatistics {
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

export interface CreateReportRequest {
  reportType: 'MONTHLY' | 'QUARTERLY' | 'YEARLY';
  period: string;
  autoGenerate: boolean;
}

export interface PublishReportRequest {
  publishNote: string;
}

// API Service
class ReportService {
  // Lấy danh sách báo cáo
  async getReports(status?: string): Promise<TransparencyReport[]> {
    const response = await api.get('/lab-admin/transparency-reports', {
      params: { status }
    });
    return response.data.data;
  }

  // Lấy chi tiết báo cáo
  async getReportById(id: number): Promise<TransparencyReport> {
    const response = await api.get(`/lab-admin/transparency-reports/${id}`);
    return response.data.data;
  }

  // Tạo báo cáo mới
  async createReport(data: CreateReportRequest): Promise<TransparencyReport> {
    const response = await api.post('/lab-admin/transparency-reports', data);
    return response.data.data;
  }

  // Công bố báo cáo
  async publishReport(id: number, data: PublishReportRequest): Promise<any> {
    const response = await api.post(`/lab-admin/transparency-reports/${id}/publish`, data);
    return response.data.data;
  }

  // Lưu trữ báo cáo (published only)
  async archiveReport(id: number): Promise<any> {
    const response = await api.post(`/lab-admin/transparency-reports/${id}/archive`);
    return response.data.data;
  }

  // Xóa báo cáo (draft only)
  async deleteReport(id: number): Promise<void> {
    await api.delete(`/lab-admin/transparency-reports/${id}`);
  }

  // Export PDF
  async exportPDF(id: number): Promise<Blob> {
    const response = await api.get(`/lab-admin/transparency-reports/${id}/export-pdf`, {
      responseType: 'blob'
    });
    return response.data;
  }

  // Lấy thống kê cho một khoảng thời gian
  async getStatisticsForPeriod(period: string): Promise<ReportStatistics> {
    const response = await api.get('/lab-admin/statistics', {
      params: { period }
    });
    return response.data.data;
  }
}

export const reportService = new ReportService();
