// Report Types
export type TReportType = 
  | 'PROGRESS'
  | 'MILESTONE'
  | 'FINAL'
  | 'TRANSPARENCY';

export type TReportStatus = 
  | 'DRAFT'
  | 'SUBMITTED'
  | 'REVIEWED'
  | 'APPROVED'
  | 'REJECTED';

export interface IReport {
  id: string;
  projectId: string;
  projectName: string;
  type: TReportType;
  title: string;
  content: string;
  status: TReportStatus;
  submittedBy: string;
  submittedByName: string;
  submittedAt?: string;
  reviewedBy?: string;
  reviewedByName?: string;
  reviewedAt?: string;
  attachments: string[];
  createdAt: string;
  updatedAt: string;
}

export interface ICreateReportRequest {
  projectId: string;
  type: TReportType;
  title: string;
  content: string;
  attachments?: string[];
}

export interface IReviewReportRequest {
  status: 'APPROVED' | 'REJECTED';
  comments: string;
}

export interface IEvaluation {
  id: string;
  projectId: string;
  talentId: string;
  talentName: string;
  evaluatedBy: string;
  evaluatorName: string;
  technicalSkills: number; // 1-5
  communication: number; // 1-5
  teamwork: number; // 1-5
  problemSolving: number; // 1-5
  productivity: number; // 1-5
  overallRating: number; // 1-5
  comments: string;
  createdAt: string;
}

export interface ICreateEvaluationRequest {
  projectId: string;
  talentId: string;
  technicalSkills: number;
  communication: number;
  teamwork: number;
  problemSolving: number;
  productivity: number;
  comments: string;
}
