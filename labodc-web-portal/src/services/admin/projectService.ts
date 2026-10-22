// src/services/admin/projectService.ts

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
export interface Project {
  id: number;
  enterpriseId: number;
  title: string;
  description: string;
  status: 'DRAFT' | 'PENDING_VALIDATION' | 'VALIDATED' | 'RECRUITING' | 'IN_PROGRESS' | 'COMPLETED' | 'CANCELLED';
  validated: 'pending' | 'approved' | 'rejected';
  validatedAt?: string;
  budget: number;
  numberOfStudents: number;
  currentMembersCount: number;
  progressPercentage: number;
  startDate: string;
  endDate: string;
  createdAt: string;
  // Aggregated data
  totalTeamMembers: number;
  totalApplications: number;
  
  // Optional enterprise info (may need separate call)
  enterprise?: {
    id: number;
    name: string;
    verified: boolean;
  };
}

export interface SkillRequirement {
  skill: string;
  level: 'Beginner' | 'Intermediate' | 'Advanced';
  required: boolean;
}

export interface ProjectAttachment {
  fileName: string;
  url: string;
  fileSize?: number;
}

export interface ProjectDetail extends Project {
  // Additional detail fields
  slug: string;
  objectives?: string;
  requirements?: string;
  technologies?: string[];
  requiredSkills?: string[];
  attachments?: string[];
  mentorId?: number;
  currency: string;
  isPublic: boolean;
  allowApplications: boolean;
  updatedAt?: string;
  duration?: string;
  
  // Rejection info (if rejected)
  rejectionReason?: string;
  rejectedAt?: string;
  rejectedBy?: number;
  
  // Related data (may need separate calls)
  mentor?: {
    id: number;
    name: string;
    email: string;
    expertise: string[];
  };
}

export interface Mentor {
  id: number;
  fullName: string;
  expertise: string[];
  yearsOfExperience: number;
  currentProjects: number;
  maxProjects: number;
  available: boolean;
  averageRating: number;
  projectsCompleted: number;
}

export interface ApproveProjectRequest {
  note: string;
  adjustments?: {
    numberOfStudents?: number;
    duration?: string;
  };
}

export interface RejectProjectRequest {
  reason: string;
  details: string;
}

export interface AssignMentorRequest {
  mentorId: number;
  message: string;
}

export interface ProjectListParams {
  status?: string;
  search?: string;
  page?: number;
  limit?: number;
}

export interface ProjectListResponse {
  projects: Project[];
  pagination: {
    total: number;
    page: number;
    totalPages: number;
  };
}

// API Service
class ProjectService {
  // Lấy danh sách dự án (dùng cho project validation/management)
  async getProjects(params: ProjectListParams): Promise<ProjectListResponse> {
    try {
      // Map frontend params to backend params
      const backendParams: any = {};
      
      if (params.search) {
        backendParams.search = params.search;
      }
      
      // Map status filter to appropriate backend params
      if (params.status === 'PENDING') {
        backendParams.validated = 'pending';
      } else if (params.status === 'APPROVED') {
        backendParams.validated = 'approved';
      } else if (params.status === 'REJECTED') {
        backendParams.validated = 'rejected';
      } else if (params.status === 'RECRUITING' || params.status === 'IN_PROGRESS' || params.status === 'COMPLETED') {
        // For status-based filters, we'll filter client-side after getting all data
        // Or we need a different backend endpoint that supports status filter
        // For now, get all and filter client-side
      }
      // For 'ALL' or other statuses, don't send validated param (get all)
      
      const response = await api.get('/projects/management', { params: backendParams });
      
      // Backend returns List<ProjectListDTO>, wrap in pagination structure
      let projects = response.data.data || [];
      
      // Client-side filter for status-based tabs (RECRUITING, IN_PROGRESS, etc.)
      if (params.status === 'RECRUITING' || params.status === 'IN_PROGRESS' || params.status === 'COMPLETED') {
        projects = projects.filter((p: Project) => p.status === params.status);
      }
      
      return {
        projects: projects,
        pagination: {
          total: projects.length,
          page: params.page || 1,
          totalPages: Math.ceil(projects.length / (params.limit || 10))
        }
      };
    } catch (error: any) {
      console.error('[ProjectService] Error fetching projects:', error);
      throw error;
    }
  }

  // Lấy thống kê validation cho badge counts
  async getValidationStats(): Promise<Record<string, number>> {
    try {
      const response = await api.get('/projects/management');
      const projects = response.data.data || [];
      
      const stats = {
        pending: 0,
        approved: 0,
        rejected: 0,
        recruiting: 0,
        inProgress: 0,
      };
      
      projects.forEach((project: Project) => {
        // Count by validation status
        if (project.validated === 'pending') {
          stats.pending++;
        } else if (project.validated === 'approved') {
          stats.approved++;
        } else if (project.validated === 'rejected') {
          stats.rejected++;
        }
        
        // Count by project status
        if (project.status === 'RECRUITING') {
          stats.recruiting++;
        } else if (project.status === 'IN_PROGRESS') {
          stats.inProgress++;
        }
      });
      
      return stats;
    } catch (error: any) {
      console.error('[ProjectService] Error fetching validation stats:', error);
      return { pending: 0, approved: 0, rejected: 0, recruiting: 0, inProgress: 0 };
    }
  }

  // Lấy danh sách dự án chờ xác thực
  async getPendingProjects(): Promise<Project[]> {
    const response = await api.get('/lab-admin/projects/pending');
    return response.data.data.projects;
  }

  // Lấy chi tiết dự án
  async getProjectById(id: number): Promise<ProjectDetail> {
    const response = await api.get(`/projects/${id}`);
    const data = response.data.data;
    
    // Map backend response to frontend interface
    // Backend uses: name, objective, requiredTalents
    // Frontend uses: title, objectives, numberOfStudents
    return {
      ...data,
      title: data.name || data.title,
      objectives: data.objective || data.objectives,
      numberOfStudents: data.requiredTalents || data.numberOfStudents,
      validated: data.validated || 'pending',
    } as ProjectDetail;
  }
  
  // Phê duyệt dự án (approve)
  async approveProject(id: number, data: ApproveProjectRequest): Promise<void> {
    await api.put(`/projects/${id}/approve`);
  }
  
  // Từ chối dự án (reject)
  async rejectProject(id: number, data: RejectProjectRequest): Promise<void> {
    await api.put(`/projects/${id}/reject`, {
      reason: data.reason + ': ' + data.details
    });
  }

  // Lấy danh sách mentor có sẵn
  async getAvailableMentors(technologies?: string[]): Promise<Mentor[]> {
    const response = await api.get('/lab-admin/mentors/available', {
      params: { technologies: technologies?.join(',') }
    });
    return response.data.data.mentors;
  }

  // Gán mentor cho dự án
  async assignMentor(projectId: number, data: AssignMentorRequest): Promise<void> {
    await api.post(`/lab-admin/project-validation/projects/${projectId}/assign-mentor`, data);
  }

  // Tìm kiếm dự án
  async searchProjects(keyword: string): Promise<Project[]> {
    const response = await api.get('/lab-admin/projects/search', {
      params: { q: keyword }
    });
    return response.data.data;
  }
}

export const projectService = new ProjectService();
