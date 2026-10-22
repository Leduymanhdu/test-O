// Mock TalentService for testing UI without backend
export interface TalentProfile {
  id: string;
  fullName: string;
  email: string;
  skills: string[];
  experience: number;
  bio: string;
  avatarUrl?: string;
  status: 'active' | 'inactive';
  rating: number;
  joinedAt: string;
}

export interface Project {
  id: string;
  title: string;
  description: string;
  status: 'open' | 'in_progress' | 'completed';
  budget: number;
  deadline: string;
  requiredSkills: string[];
  enterpriseName: string;
  applicationsCount: number;
}

export interface Task {
  id: string;
  title: string;
  description: string;
  projectId: string;
  projectTitle: string;
  status: 'todo' | 'in_progress' | 'completed';
  priority: 'low' | 'medium' | 'high';
  dueDate: string;
  assignedTo?: string;
}

// Mock data
const mockTalents: TalentProfile[] = [
  {
    id: '1',
    fullName: 'Nguyễn Văn A',
    email: 'nguyenvana@email.com',
    skills: ['React', 'Node.js', 'TypeScript'],
    experience: 3,
    bio: 'Frontend developer với 3 năm kinh nghiệm',
    status: 'active',
    rating: 4.5,
    joinedAt: '2023-01-15',
  },
  {
    id: '2',
    fullName: 'Trần Thị B',
    email: 'tranthib@email.com',
    skills: ['Java', 'Spring Boot', 'PostgreSQL'],
    experience: 5,
    bio: 'Backend developer chuyên về Spring Boot',
    status: 'active',
    rating: 4.8,
    joinedAt: '2022-06-20',
  },
];

const mockProjects: Project[] = [
  {
    id: '1',
    title: 'Website thương mại điện tử',
    description: 'Xây dựng website bán hàng online với đầy đủ chức năng',
    status: 'open',
    budget: 50000000,
    deadline: '2024-06-30',
    requiredSkills: ['React', 'Node.js', 'PostgreSQL'],
    enterpriseName: 'Công ty ABC',
    applicationsCount: 5,
  },
  {
    id: '2',
    title: 'Ứng dụng quản lý kho',
    description: 'Phát triển hệ thống quản lý kho hàng cho doanh nghiệp',
    status: 'in_progress',
    budget: 80000000,
    deadline: '2024-08-15',
    requiredSkills: ['Java', 'Spring Boot', 'MySQL'],
    enterpriseName: 'Công ty XYZ',
    applicationsCount: 3,
  },
];

const mockTasks: Task[] = [
  {
    id: '1',
    title: 'Thiết kế UI homepage',
    description: 'Tạo mockup và implement UI cho trang chủ',
    projectId: '1',
    projectTitle: 'Website thương mại điện tử',
    status: 'in_progress',
    priority: 'high',
    dueDate: '2024-03-15',
    assignedTo: 'Nguyễn Văn A',
  },
  {
    id: '2',
    title: 'Phát triển API đăng nhập',
    description: 'Implement authentication API với JWT',
    projectId: '1',
    projectTitle: 'Website thương mại điện tử',
    status: 'completed',
    priority: 'medium',
    dueDate: '2024-03-10',
    assignedTo: 'Trần Thị B',
  },
];

// Mock API functions with delay to simulate real API
const delay = (ms: number) => new Promise((resolve) => setTimeout(resolve, ms));

export const talentService = {
  // Dashboard
  getDashboardStats: async () => {
    await delay(300);
    return {
      totalTalents: mockTalents.length,
      activeProjects: mockProjects.filter((p) => p.status !== 'completed').length,
      completedTasks: mockTasks.filter((t) => t.status === 'completed').length,
      averageRating: mockTalents.reduce((sum, t) => sum + t.rating, 0) / mockTalents.length,
    };
  },

  // Projects
  getAvailableProjects: async () => {
    await delay(500);
    return mockProjects.filter((p) => p.status === 'open');
  },

  getMyProjects: async () => {
    await delay(400);
    return mockProjects.filter((p) => p.status === 'in_progress');
  },

  applyToProject: async (projectId: string) => {
    await delay(600);
    console.log(`Applied to project ${projectId}`);
    return { success: true, message: 'Đã gửi đơn ứng tuyển thành công!' };
  },

  // Tasks
  getMyTasks: async () => {
    await delay(400);
    return mockTasks;
  },

  updateTaskStatus: async (taskId: string, status: 'todo' | 'in_progress' | 'completed') => {
    await delay(300);
    const task = mockTasks.find((t) => t.id === taskId);
    if (task) {
      task.status = status;
    }
    return { success: true, message: 'Cập nhật trạng thái task thành công!' };
  },

  // Profile
  getTalentProfile: async (talentId?: string) => {
    await delay(400);
    return talentId ? mockTalents.find((t) => t.id === talentId) : mockTalents[0];
  },

  updateProfile: async (profile: Partial<TalentProfile>) => {
    await delay(500);
    console.log('Profile updated:', profile);
    return { success: true, message: 'Cập nhật profile thành công!' };
  },
};
