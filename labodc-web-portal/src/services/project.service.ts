// Project Service
import axiosInstance from './api/axios.config';
import {
  IProject,
  IProjectProposal,
  IProjectDetail,
} from '@/types/project.types';
import { IApiResponse, IPaginatedResponse, IPaginationParams, IFilterParams } from '@/types/api.types';

const PROJECT_ENDPOINTS = {
  BASE: '/projects',
  PROPOSALS: '/projects/proposals',
  VALIDATE: '/projects/validate',
  JOIN: '/projects/join',
  LEAVE: '/projects/leave',
};

export const projectService = {
  /**
   * Get all projects with pagination and filters
   */
  getProjects: async (
    params: IPaginationParams & IFilterParams
  ): Promise<IPaginatedResponse<IProject>> => {
    const response = await axiosInstance.get<IApiResponse<IPaginatedResponse<IProject>>>(
      PROJECT_ENDPOINTS.BASE,
      { params }
    );
    return response.data.data;
  },

  /**
   * Get project by ID
   */
  getProjectById: async (id: string): Promise<IProjectDetail> => {
    const response = await axiosInstance.get<IApiResponse<IProjectDetail>>(
      `${PROJECT_ENDPOINTS.BASE}/${id}`
    );
    return response.data.data;
  },

  /**
   * Create project proposal
   */
  createProposal: async (data: IProjectProposal): Promise<IProject> => {
    const response = await axiosInstance.post<IApiResponse<IProject>>(
      PROJECT_ENDPOINTS.PROPOSALS,
      data
    );
    return response.data.data;
  },

  /**
   * Update project
   */
  updateProject: async (id: string, data: Partial<IProjectProposal>): Promise<IProject> => {
    const response = await axiosInstance.put<IApiResponse<IProject>>(
      `${PROJECT_ENDPOINTS.BASE}/${id}`,
      data
    );
    return response.data.data;
  },

  /**
   * Delete project
   */
  deleteProject: async (id: string): Promise<void> => {
    await axiosInstance.delete(`${PROJECT_ENDPOINTS.BASE}/${id}`);
  },

  /**
   * Validate project (Admin)
   */
  validateProject: async (
    id: string,
    data: { status: 'APPROVED' | 'REJECTED'; comments: string }
  ): Promise<IProject> => {
    const response = await axiosInstance.post<IApiResponse<IProject>>(
      `${PROJECT_ENDPOINTS.VALIDATE}/${id}`,
      data
    );
    return response.data.data;
  },

  /**
   * Join project (Talent)
   */
  joinProject: async (projectId: string): Promise<void> => {
    await axiosInstance.post(`${PROJECT_ENDPOINTS.JOIN}/${projectId}`);
  },

  /**
   * Leave project (Talent)
   */
  leaveProject: async (projectId: string): Promise<void> => {
    await axiosInstance.post(`${PROJECT_ENDPOINTS.LEAVE}/${projectId}`);
  },

  /**
   * Get my projects
   */
  getMyProjects: async (): Promise<IProject[]> => {
    const response = await axiosInstance.get<IApiResponse<IProject[]>>(
      `${PROJECT_ENDPOINTS.BASE}/my-projects`
    );
    return response.data.data;
  },

  /**
   * Get projects by enterprise
   */
  getEnterpriseProjects: async (enterpriseId: string): Promise<IProject[]> => {
    const response = await axiosInstance.get<IApiResponse<IProject[]>>(
      `${PROJECT_ENDPOINTS.BASE}/enterprise/${enterpriseId}`
    );
    return response.data.data;
  },
};
