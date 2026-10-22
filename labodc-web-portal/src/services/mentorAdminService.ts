import axiosInstance from './api/axios-admin.config';
import { STORAGE_KEYS } from '@/utils/constants';

const API_URL = import.meta.env.VITE_API_URL || 'http://localhost:8080';

export interface MentorDTO {
  id: number;
  userId: number;
  userEmail?: string;
  fullName: string;
  title?: string;
  avatar?: string;
  currentPosition?: string;
  currentCompany?: string;
  yearsOfExperience?: number;
  bio?: string;
  linkedinUrl?: string;
  portfolioUrl?: string;
  expertise?: string[];
  topExpertise?: string;
  hourlyRate?: number;
  currency?: string;
  maxConcurrentProjects?: number;
  currentProjects?: number;
  ratingAverage?: number;
  totalRatings?: number;
  totalProjects?: number;
  completedProjects?: number;
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

export const mentorAdminService = {
  getAllMentors: async (page = 0, size = 10) => {
    const response = await axiosInstance.get<PageResponse<MentorDTO>>(
      `/lab-admin/mentors?page=${page}&size=${size}`
    );
    return response.data;
  },

  getMentorById: async (id: number) => {
    const response = await axiosInstance.get<MentorDTO>(
      `/lab-admin/mentors/${id}`
    );
    return response.data;
  },

  createMentor: async (data: Partial<MentorDTO>) => {
    const response = await axiosInstance.post<MentorDTO>(
      `/lab-admin/mentors`,
      data
    );
    return response.data;
  },

  updateMentor: async (id: number, data: MentorDTO) => {
    const response = await axiosInstance.put<MentorDTO>(
      `/lab-admin/mentors/${id}`,
      data
    );
    return response.data;
  },

  deleteMentor: async (id: number) => {
    const response = await axiosInstance.delete(
      `/lab-admin/mentors/${id}`
    );
    return response.data;
  },

  searchUsers: async (query: string) => {
    const response = await axiosInstance.get(
      `/lab-admin/enterprises/search-users?query=${encodeURIComponent(query)}`
    );
    return response.data;
  },

  getAllExpertise: async () => {
    const response = await axiosInstance.get<string[]>(
      `/lab-admin/mentors/expertise/all`
    );
    return response.data;
  }
};
