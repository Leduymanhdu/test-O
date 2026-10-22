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
  upcomingTasks?: TaskSummary[];
  notifications?: string[];
  profileCompletion: {
    percentage: number;
    missingFields: string[];
  };
}

export interface TaskSummary {
  taskId: number;
  taskName: string;
  projectName: string;
  dueDate: string;
  priority: string;
  status: string;
}

export interface JoinProjectRequest {
  projectId: number;
  message: string;
}

// Leader-specific interfaces
export interface FundDistributionRequest {
  talentId: string;
  amount: number;
  description: string;
  justification?: string;
}

export interface TeamReportRequest {
  reportPeriod: string;
  progress: number;
  achievements: string;
  challenges?: string;
  nextSteps?: string;
  memberContributions?: { [talentId: string]: string };
  additionalNotes?: string;
}

export interface FundDistribution {
  id: number;
  projectId: number;
  talentId: string;
  amount: number;
  description: string;
  justification?: string;
  distributedBy: string;
  status: string;
  createdAt: string;
}

export interface TeamReport {
  id: number;
  projectId: number;
  submittedBy: string;
  reportPeriod: string;
  progress: number;
  achievements: string;
  challenges?: string;
  nextSteps?: string;
  memberContributions?: { [talentId: string]: string };
  status: string;
  mentorFeedback?: string;
  submittedAt: string;
  reviewedAt?: string;
  additionalNotes?: string;
}

export interface TeamMember {
  id: string;
  name: string;
  role: string;
  status: string;
  joinedAt: string;
  contribution?: number;
  skills: string[];
}

export interface ApiResponse<T> {
  success: boolean;
  message?: string;
  data?: T;
  error?: string;
}

export interface PaginationParams {
  page?: number;
  size?: number;
}

export interface ProjectFilters {
  technology?: string;
  minBudget?: number;
  maxBudget?: number;
  sort?: 'newest' | 'deadline' | 'budget';
}
