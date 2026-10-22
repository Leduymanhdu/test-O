import axiosInstance from './api/axios-admin.config';
import { STORAGE_KEYS } from '@/utils/constants';

const API_URL = import.meta.env.VITE_API_URL || 'http://localhost:8080';

export interface TalentDTO {
  id: number;
  userId: number;
  userEmail?: string;
  fullName: string;
  studentId?: string;
  dateOfBirth?: string;
  avatar?: string;
  faculty?: string;
  major?: string;
  yearOfStudy?: number;
  gpa?: number;
  githubUrl?: string;
  linkedinUrl?: string;
  portfolioUrl?: string;
  bio?: string;
  skills?: string[];
  topSkills?: string;
  ratingAverage?: number;
  totalRatings?: number;
  totalProjects?: number;
  completedProjects?: number;
  ongoingProjects?: number;
  available?: boolean;
  status?: string;
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

export const talentAdminService = {
  getAllTalents: async (page = 0, size = 10) => {
    const response = await axiosInstance.get<PageResponse<TalentDTO>>(
      `/lab-admin/talents?page=${page}&size=${size}`
    );
    return response.data;
  },

  getTalentById: async (id: number) => {
    const response = await axiosInstance.get<TalentDTO>(
      `/lab-admin/talents/${id}`
    );
    return response.data;
  },

  createTalent: async (data: Partial<TalentDTO>) => {
    const response = await axiosInstance.post<TalentDTO>(
      `/lab-admin/talents`,
      data
    );
    return response.data;
  },

  updateTalent: async (id: number, data: TalentDTO) => {
    const response = await axiosInstance.put<TalentDTO>(
      `/lab-admin/talents/${id}`,
      data
    );
    return response.data;
  },

  deleteTalent: async (id: number) => {
    const response = await axiosInstance.delete(
      `/lab-admin/talents/${id}`
    );
    return response.data;
  },

  searchUsers: async (query: string) => {
    const response = await axiosInstance.get(
      `/lab-admin/enterprises/search-users?query=${encodeURIComponent(query)}`
    );
    return response.data;
  }
};
