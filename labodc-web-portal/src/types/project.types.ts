// Project Types
export type TProjectStatus = 
  | 'DRAFT'
  | 'PENDING_APPROVAL'
  | 'APPROVED'
  | 'REJECTED'
  | 'IN_PROGRESS'
  | 'COMPLETED'
  | 'CANCELLED';

export type TProjectPriority = 'LOW' | 'MEDIUM' | 'HIGH' | 'URGENT';

export interface IProject {
  id: string;
  title: string;
  description: string;
  status: TProjectStatus;
  priority: TProjectPriority;
  budget: number;
  startDate: string;
  endDate: string;
  enterpriseId: string;
  enterpriseName: string;
  mentorId?: string;
  mentorName?: string;
  teamSize: number;
  requiredSkills: string[];
  technologies: string[];
  progress: number;
  createdAt: string;
  updatedAt: string;
}

export interface IProjectProposal {
  title: string;
  description: string;
  objectives: string;
  scope: string;
  budget: number;
  duration: number; // in months
  startDate: string;
  requiredSkills: string[];
  technologies: string[];
  teamSize: number;
  expectedOutcomes: string;
  attachments?: string[];
}

export interface IProjectDetail extends IProject {
  objectives: string;
  scope: string;
  expectedOutcomes: string;
  attachments: string[];
  teamMembers: ITeamMember[];
  tasks: any[];
  reports: any[];
}

export interface ITeamMember {
  id: string;
  userId: string;
  userName: string;
  userAvatar?: string;
  role: 'LEADER' | 'MEMBER';
  joinedAt: string;
  performance?: number;
}
