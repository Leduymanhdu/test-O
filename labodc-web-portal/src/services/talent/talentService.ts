import axiosInstance from '../api/axios.config';
import { mockDashboard, mockProjects } from './talentService.mock';

export interface TalentProfile {
  id: number;
  fullName: string;
  studentId: string;
  faculty: string;
  major: string;
  yearOfStudy: number;
  email: string;
  phone?: string;
  avatarUrl?: string;
  cvUrl?: string;
  portfolioUrl?: string;
  githubUrl?: string;
  linkedinUrl?: string;
  bio?: string;
  gpa?: number;
  dateOfBirth?: string;
  expectedGraduation?: string;
  availableForProjects: boolean;
  workAvailability?: string;
  hoursPerWeek?: number;
  skills: TalentSkill[];
  certifications: TalentCertification[];
  projectsCompleted: number;
  averageRating: number;
  status: string;
}

export interface TalentSkill {
  id: number;
  skillName: string;
  skillCategory?: string;
  proficiencyLevel: 'BEGINNER' | 'INTERMEDIATE' | 'ADVANCED' | 'EXPERT';
  yearsOfExperience: number;
}

export interface TalentCertification {
  id: number;
  name: string;
  issuer?: string;
  issueDate?: string;
  expiryDate?: string;
  credentialUrl?: string;
  description?: string;
}

export interface TalentProject {
  id: number;
  title: string;
  description: string;
  company?: {
    name: string;
    logoUrl?: string;
  };
  technologies: string[];
  startDate: string;
  endDate: string;
  duration: string;
  budget: number;
  allowancePerStudent?: string;
  numberOfStudents: number;
  spotsAvailable?: number;
  skillRequirements: string[];
  status: string;
  memberStatus?: string;
  memberRole?: string;
}

export interface TalentDashboard {
  stats: {
    totalProjects: number;
    completedProjects: number;
    ongoingProjects: number;
    averageRating: number;
    totalSkills: number;
    totalCertifications: number;
  };
  recentProjects: TalentProject[];
  upcomingTasks?: any[];
  notifications?: string[];
  profileCompletion: {
    percentage: number;
    missingFields: string[];
  };
}

export interface TalentTask {
  id: number;
  projectId?: number;
  title: string;
  description?: string;
  status: string;
  progress?: number;
  dueDate?: string;
  priority?: string;
  projectName?: string;
  assignedTo?: string[];
}

export interface JoinProjectRequest {
  message: string;
}

class TalentService {
  private basePath = '/talent';

  // Profile Management
  async getProfile(): Promise<TalentProfile> {
    const response = await axiosInstance.get(`${this.basePath}/profile`);
    return response.data.data;
  }

  async updateProfile(profile: Partial<TalentProfile>): Promise<TalentProfile> {
    const response = await axiosInstance.put(`${this.basePath}/profile`, profile);
    return response.data.data;
  }

  async uploadAvatar(file: File): Promise<string> {
    const formData = new FormData();
    formData.append('file', file);
    const response = await axiosInstance.post(`${this.basePath}/profile/avatar`, formData);
    return response.data.data;
  }

  async uploadCV(file: File): Promise<string> {
    const formData = new FormData();
    formData.append('file', file);
    const response = await axiosInstance.post(`${this.basePath}/profile/cv`, formData);
    return response.data.data;
  }

  // Skills Management
  async addSkill(skill: Omit<TalentSkill, 'id'>): Promise<TalentSkill> {
    const response = await axiosInstance.post(`${this.basePath}/skills`, skill);
    return response.data.data;
  }

  async removeSkill(skillId: number): Promise<void> {
    await axiosInstance.delete(`${this.basePath}/skills/${skillId}`);
  }

  // Certifications Management
  async addCertification(cert: Omit<TalentCertification, 'id'>): Promise<TalentCertification> {
    const response = await axiosInstance.post(`${this.basePath}/certifications`, cert);
    return response.data.data;
  }

  async removeCertification(certId: number): Promise<void> {
    await axiosInstance.delete(`${this.basePath}/certifications/${certId}`);
  }

  // Project Management
  async getAvailableProjects(params?: {
    page?: number;
    size?: number;
    technology?: string;
    minBudget?: number;
    maxBudget?: number;
    sort?: string;
  }): Promise<{
    content: TalentProject[];
    totalElements: number;
    totalPages: number;
    size: number;
    number: number;
  }> {
    const response = await axiosInstance.get(`${this.basePath}/projects/available`, { params });
    return response.data.data;
  }

  // Alias for browseProjects
  async browseProjects(params?: {
    page?: number;
    size?: number;
    technology?: string;
    minBudget?: number;
    maxBudget?: number;
    sort?: string;
  }): Promise<{
    content: TalentProject[];
    totalElements: number;
    totalPages: number;
    size: number;
    number: number;
  }> {
    try {
      return await this.getAvailableProjects(params);
    } catch (error: any) {
      console.log('🔍 Browse projects error details:', {
        status: error.response?.status,
        code: error.code,
        message: error.message,
      });
      // Axios interceptor transforms error - check for backend unavailability
      const isBackendUnavailable =
        error.message?.includes('No static resource') ||
        error.message?.includes('500') ||
        error.response?.status === 500 ||
        error.code === 'ERR_NETWORK';

      if (isBackendUnavailable) {
        console.warn('⚠️ Backend unavailable, using mock projects data');
        return {
          content: mockProjects,
          totalElements: mockProjects.length,
          totalPages: 1,
          size: params?.size || 50,
          number: params?.page || 0,
        };
      }
      throw error;
    }
  }

  async getProjectDetail(projectId: number): Promise<TalentProject> {
    const response = await axiosInstance.get(`${this.basePath}/projects/${projectId}`);
    return response.data.data;
  }

  async joinProject(projectId: number, request: JoinProjectRequest): Promise<string> {
    const response = await axiosInstance.post(
      `${this.basePath}/projects/${projectId}/join`,
      request
    );
    return response.data.data;
  }

  async getMyProjects(): Promise<TalentProject[]> {
    const response = await axiosInstance.get(`${this.basePath}/projects/my-projects`);
    return response.data.data;
  }

  async getMyTasks(projectId?: number): Promise<TalentTask[]> {
    const response = await axiosInstance.get(`${this.basePath}/tasks`, {
      params: projectId ? { projectId } : {},
    });
    return response.data.data;
  }

  async submitTaskReport(taskId: number, file: File): Promise<{ id: number; fileName: string }> {
    const formData = new FormData();
    formData.append('file', file);
    const response = await axiosInstance.post(`${this.basePath}/tasks/${taskId}/submit`, formData);
    return response.data.data;
  }

  // Dashboard
  async getDashboard(): Promise<TalentDashboard> {
    try {
      const response = await axiosInstance.get(`${this.basePath}/dashboard`);
      return response.data.data;
    } catch (error: any) {
      console.log('🔍 Dashboard error details:', {
        status: error.response?.status,
        code: error.code,
        message: error.message,
        fullError: error,
      });
      // Axios interceptor transforms error - check for backend unavailability
      // Error message contains "No static resource" when talent endpoints disabled
      const isBackendUnavailable =
        error.message?.includes('No static resource') ||
        error.message?.includes('500') ||
        error.response?.status === 500 ||
        error.code === 'ERR_NETWORK';

      if (isBackendUnavailable) {
        console.warn('⚠️ Backend unavailable, using mock dashboard data');
        return mockDashboard;
      }
      throw error;
    }
  }

  // Leader-specific methods
  async distributeFunds(projectId: number, distributions: any[]): Promise<void> {
    await axiosInstance.post(
      `${this.basePath}/leader/${projectId}/distribute-funds`,
      distributions
    );
  }

  async submitTeamReport(projectId: number, report: any): Promise<void> {
    await axiosInstance.post(`${this.basePath}/leader/${projectId}/submit-report`, report);
  }

  async getFundDistributions(projectId: number): Promise<any[]> {
    const response = await axiosInstance.get(
      `${this.basePath}/leader/${projectId}/fund-distributions`
    );
    return response.data.data;
  }

  async getTeamReports(projectId: number): Promise<any[]> {
    const response = await axiosInstance.get(`${this.basePath}/leader/${projectId}/reports`);
    return response.data.data;
  }

  async getTeamMembers(projectId: number): Promise<any[]> {
    const response = await axiosInstance.get(`${this.basePath}/leader/${projectId}/team-members`);
    return response.data.data;
  }
}

export const talentService = new TalentService();
