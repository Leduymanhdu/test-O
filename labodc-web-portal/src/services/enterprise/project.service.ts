import axios from '@/services/api/axios.config';

export interface Project {
  key: string;
  name: string;
  budget: number;
  spent: number;
  progress: number;
  members?: number;
  startDate?: string;
  endDate?: string;
  status:
    | 'PENDING_VALIDATION'
    | 'VALIDATED'
    | 'RECRUITING'
    | 'IN_PROGRESS'
    | 'COMPLETED'
    | 'ON_HOLD'
    | string;
}

export interface CreateProjectRequest {
  name: string;
  description: string;
  requirements?: string;
  objectives?: string[];
  startDate: string; // YYYY-MM-DD
  endDate: string;   // YYYY-MM-DD
  budget: number;
  requiredTalents: number;
  technologies?: string[];
  requiredSkills?: string[];
  mentorId?: number | null;
  allowApplications?: boolean;
}

export interface UpdateProjectRequest {
  name?: string;
  description?: string;
  requirements?: string;
  objectives?: string[];
  startDate?: string; // YYYY-MM-DD
  endDate?: string;   // YYYY-MM-DD
  budget?: number;
  requiredTalents?: number;
  technologies?: string[];
  requiredSkills?: string[];
  allowApplications?: boolean;
}

export interface MentorOption {
  id: number;
  fullName: string;
  title?: string;
  currentCompany?: string;
  ratingAverage?: number;
  available?: boolean;
}

export const getProjectSummary = async () => {
  const res = await axios.get('/enterprise/projects/summary');
  return res.data?.data ?? res.data ?? null;
};

export const getProjects = async (status: string) => {
  const res = await axios.get('/enterprise/projects', {
    params: status !== 'ALL' ? { status } : {},
  });
  return res.data?.data ?? res.data ?? [];
};

export const createProject = async (payload: CreateProjectRequest) => {
  const res = await axios.post('/projects', payload);
  return res.data?.data ?? res.data ?? null;
};

export const getProjectById = async (id: string | number) => {
  const res = await axios.get(`/projects/${id}`);
  return res.data?.data ?? res.data ?? null;
};

export const updateProject = async (id: string | number, payload: UpdateProjectRequest) => {
  const res = await axios.put(`/enterprise/projects/${id}`, payload);
  return res.data?.data ?? res.data ?? null;
};

export const deleteProject = async (id: string | number) => {
  const res = await axios.delete(`/enterprise/projects/${id}`);
  return res.data?.data ?? res.data ?? null;
};

export const getMentors = async (): Promise<MentorOption[]> => {
  const res = await axios.get('/enterprise/mentors');
  return res.data?.data ?? res.data ?? [];
};

export const assignMentor = async (
  projectId: string | number,
  mentorId: number,
  message?: string
) => {
  const res = await axios.post(`/enterprise/projects/${projectId}/assign-mentor`, {
    mentorId,
    message,
  });
  return res.data?.data ?? res.data ?? null;
};

export const startProject = async (projectId: string | number) => {
  const res = await axios.post(`/enterprise/projects/${projectId}/start`);
  return res.data?.data ?? res.data ?? null;
};
