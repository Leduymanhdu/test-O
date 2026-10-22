import axiosInstance from './api/axios-admin.config';
import { STORAGE_KEYS } from '@/utils/constants';

const API_URL = import.meta.env.VITE_API_URL || 'http://localhost:8080';

export interface ProjectDTO {
  id: number;
  enterpriseId?: number;
  enterpriseName?: string;
  mentorId?: number;
  mentorName?: string;
  title: string;
  slug?: string;
  description?: string;
  objectives?: string;
  requirements?: string;
  startDate?: string;
  endDate?: string;
  durationWeeks?: number;
  budget?: number;
  currency?: string;
  numberOfStudents?: number;
  currentMembers?: number;
  talentIds?: number[];
  talentNames?: string[];
  technologies?: string[];
  primaryTechnology?: string;
  status?: string;
  progressPercentage?: number;
  validated?: boolean;
  validatedAt?: string;
  validatedBy?: number;
  validatedByName?: string;
  totalMilestones?: number;
  completedMilestones?: number;
  createdAt?: string;
  updatedAt?: string;
}

export interface PageResponse<T> {
  content: T[];
  totalElements: number;
  totalPages: number;
  size: number;
  number: number;
}

export const projectAdminService = {
  getAllProjects: async (page = 0, size = 10) => {
    const response = await axiosInstance.get<PageResponse<ProjectDTO>>(
      `/lab-admin/projects?page=${page}&size=${size}`
    );
    return response.data;
  },

  getProjectById: async (id: number) => {
    const response = await axiosInstance.get<ProjectDTO>(
      `/lab-admin/projects/${id}`
    );
    return response.data;
  },

  createProject: async (data: Partial<ProjectDTO>) => {
    const response = await axiosInstance.post<ProjectDTO>(
      `/lab-admin/projects`,
      data
    );
    return response.data;
  },

  updateProject: async (id: number, data: ProjectDTO) => {
    const response = await axiosInstance.put<ProjectDTO>(
      `/lab-admin/projects/${id}`,
      data
    );
    return response.data;
  },

  deleteProject: async (id: number) => {
    const response = await axiosInstance.delete(
      `/lab-admin/projects/${id}`
    );
    return response.data;
  },

  validateProject: async (id: number) => {
    const response = await axiosInstance.post<ProjectDTO>(
      `/lab-admin/projects/${id}/validate`,
      {}
    );
    return response.data;
  },
  
  rejectProject: async (id: number, reason: string) => {
    const response = await axiosInstance.post(
      `/lab-admin/projects/${id}/reject`,
      null,
      { params: { reason } }
    );
    return response.data;
  }
};
