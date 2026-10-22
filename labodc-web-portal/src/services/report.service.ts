// Report Service
import axiosInstance from './api/axios.config';
import {
  IReport,
  ICreateReportRequest,
  IReviewReportRequest,
  IEvaluation,
  ICreateEvaluationRequest,
} from '@/types/report.types';
import { IApiResponse, IPaginatedResponse, IPaginationParams } from '@/types/api.types';

const REPORT_ENDPOINTS = {
  BASE: '/reports',
  EVALUATION: '/evaluations',
};

export const reportService = {
  /**
   * Get reports with pagination
   */
  getReports: async (
    params: IPaginationParams & { projectId?: string; type?: string }
  ): Promise<IPaginatedResponse<IReport>> => {
    const response = await axiosInstance.get<IApiResponse<IPaginatedResponse<IReport>>>(
      REPORT_ENDPOINTS.BASE,
      { params }
    );
    return response.data.data;
  },

  /**
   * Get report by ID
   */
  getReportById: async (id: string): Promise<IReport> => {
    const response = await axiosInstance.get<IApiResponse<IReport>>(
      `${REPORT_ENDPOINTS.BASE}/${id}`
    );
    return response.data.data;
  },

  /**
   * Create report
   */
  createReport: async (data: ICreateReportRequest): Promise<IReport> => {
    const response = await axiosInstance.post<IApiResponse<IReport>>(
      REPORT_ENDPOINTS.BASE,
      data
    );
    return response.data.data;
  },

  /**
   * Update report
   */
  updateReport: async (id: string, data: Partial<ICreateReportRequest>): Promise<IReport> => {
    const response = await axiosInstance.put<IApiResponse<IReport>>(
      `${REPORT_ENDPOINTS.BASE}/${id}`,
      data
    );
    return response.data.data;
  },

  /**
   * Delete report
   */
  deleteReport: async (id: string): Promise<void> => {
    await axiosInstance.delete(`${REPORT_ENDPOINTS.BASE}/${id}`);
  },

  /**
   * Review report (Admin)
   */
  reviewReport: async (id: string, data: IReviewReportRequest): Promise<IReport> => {
    const response = await axiosInstance.post<IApiResponse<IReport>>(
      `${REPORT_ENDPOINTS.BASE}/${id}/review`,
      data
    );
    return response.data.data;
  },

  /**
   * Create evaluation
   */
  createEvaluation: async (data: ICreateEvaluationRequest): Promise<IEvaluation> => {
    const response = await axiosInstance.post<IApiResponse<IEvaluation>>(
      REPORT_ENDPOINTS.EVALUATION,
      data
    );
    return response.data.data;
  },

  /**
   * Get evaluations for a talent
   */
  getTalentEvaluations: async (talentId: string): Promise<IEvaluation[]> => {
    const response = await axiosInstance.get<IApiResponse<IEvaluation[]>>(
      `${REPORT_ENDPOINTS.EVALUATION}/talent/${talentId}`
    );
    return response.data.data;
  },

  /**
   * Get evaluations for a project
   */
  getProjectEvaluations: async (projectId: string): Promise<IEvaluation[]> => {
    const response = await axiosInstance.get<IApiResponse<IEvaluation[]>>(
      `${REPORT_ENDPOINTS.EVALUATION}/project/${projectId}`
    );
    return response.data.data;
  },
};
