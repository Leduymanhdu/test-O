import axios from '@/services/api/axios.config';

// Dashboard summary
export const getEnterpriseDashboardSummary = async () => {
  const res = await axios.get('/enterprise/dashboard/summary');
  return res.data?.data ?? res.data ?? null;
};

// Recent projects
export const getRecentProjects = async () => {
  const res = await axios.get('/enterprise/dashboard/recent-projects');
  return res.data?.data ?? res.data ?? [];
};
