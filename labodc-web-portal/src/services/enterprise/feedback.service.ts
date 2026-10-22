import axios from '@/services/api/axios.config';

export interface EnterpriseFeedback {
  id: number;
  projectId: number;
  projectName: string;
  overallRating?: number;
  qualityRating?: number;
  communicationRating?: number;
  timelineRating?: number;
  professionalismRating?: number;
  positiveFeedback?: string;
  negativeFeedback?: string;
  suggestions?: string;
  wouldRecommend?: boolean;
  wouldWorkAgain?: boolean;
  status?: string;
  submittedAt?: string;
  createdAt?: string;
}

export interface CreateEnterpriseFeedbackRequest {
  projectId: number;
  overallRating: number;
  qualityRating?: number;
  communicationRating?: number;
  timelineRating?: number;
  professionalismRating?: number;
  positiveFeedback: string;
  negativeFeedback?: string;
  suggestions?: string;
  wouldRecommend?: boolean;
  wouldWorkAgain?: boolean;
}

export const getFeedbacks = async () => {
  const res = await axios.get('/enterprise/feedback');
  return res.data?.data ?? res.data ?? [];
};

export const createFeedback = async (payload: CreateEnterpriseFeedbackRequest) => {
  const res = await axios.post('/enterprise/feedback', payload);
  return res.data?.data ?? res.data ?? null;
};
