export interface IMentorStatCard {
  id: string;
  title: string;
  value: string | number;
  color: string;
  trend?: {
    value: number;
    positive: boolean;
  };
}

export interface IMentorQuickAction {
  id: string;
  title: string;
  description: string;
  variant: 'primary' | 'success' | 'ghost';
}

export interface IMentorActivity {
  id: string;
  action: string;
  timeAgo: string;
  type: 'success' | 'info' | 'warning';
}

export interface IMentorDashboardPayload {
  stats: IMentorStatCard[];
  quickActions: IMentorQuickAction[];
  recentActivities: IMentorActivity[];
}

export interface IMentorInvitation {
  id: string;
  projectName: string;
  groupName: string;
  studentCount: number;
  description: string;
  deadline: string;
  skills: string[];
  receivedDate: string;
  priority: 'high' | 'medium' | 'low';
}

export interface IMentorProjectOption {
  id: string | number;
  title: string;
  progressPercentage?: number;
}

export interface IMentorTask {
  id: string;
  projectId?: string | number;
  title: string;
  description: string;
  status: 'completed' | 'in-progress' | 'pending';
  progress: number;
  assignedTo: string[];
  dueDate: string;
  priority: 'high' | 'medium' | 'low';
  projectName: string;
}

export interface IMentorTaskSubmission {
  id: number;
  taskId: number;
  talentId: number;
  talentName?: string;
  studentId?: string;
  fileName?: string;
  fileSize?: number;
  submittedAt?: string;
}

export interface IMentorTalentOption {
  talentId: string | number;
  fullName: string;
  studentId?: string;
}

export interface IMentorApplication {
  memberId: number;
  projectId: number;
  talentId: number;
  fullName?: string;
  studentId?: string;
  email?: string;
  status?: 'PENDING' | 'ACTIVE' | 'REJECTED' | 'INACTIVE';
  joinMessage?: string;
  createdAt?: string;
  skills?: string[];
}

export interface IMentorEvaluationCriterion {
  score?: number;
  comment?: string;
}

export interface IMentorTalentEvaluation {
  id: number;
  projectId: number;
  talentId: number;
  fullName?: string;
  studentId?: string;

  evaluationPeriod: string; // YYYY-MM
  overallScore?: number; // 0-10
  grade?: 'A' | 'B' | 'C' | 'D' | 'F';

  technicalSkills?: IMentorEvaluationCriterion;
  problemSolving?: IMentorEvaluationCriterion;
  teamwork?: IMentorEvaluationCriterion;
  communication?: IMentorEvaluationCriterion;
  codeQuality?: IMentorEvaluationCriterion;
  punctuality?: IMentorEvaluationCriterion;

  strengths?: string[];
  weaknesses?: string[];
  recommendations?: string[];

  tasksCompleted?: number;
  tasksTotal?: number;
  hoursWorked?: number;
  createdAt?: string;
}

export interface IMentorEvaluationProfile {
  id: string;
  name: string;
  status: 'excellent' | 'good' | 'average';
  statusText: string;
  technicalSkills: number;
  progress: number;
  attendance: number;
  teamwork: number;
  avatar: string;
  notes: string;
}

export interface IMentorReport {
  id: string;
  student: string;
  studentId: string;
  reportName: string;
  status: 'submitted' | 'pending' | 'late';
  submittedDate?: string;
  dueDate: string;
  score?: number;
  fileSize?: string;
  fileName?: string;
}
