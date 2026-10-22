// Task Types
export type TTaskStatus = 
  | 'TODO'
  | 'IN_PROGRESS'
  | 'REVIEW'
  | 'DONE'
  | 'BLOCKED';

export type TTaskPriority = 'LOW' | 'MEDIUM' | 'HIGH' | 'URGENT';

export interface ITask {
  id: string;
  projectId: string;
  projectName: string;
  title: string;
  description: string;
  status: TTaskStatus;
  priority: TTaskPriority;
  assigneeId?: string;
  assigneeName?: string;
  assigneeAvatar?: string;
  startDate: string;
  dueDate: string;
  completedAt?: string;
  estimatedHours: number;
  actualHours?: number;
  tags: string[];
  attachments: string[];
  createdBy: string;
  createdAt: string;
  updatedAt: string;
}

export interface ICreateTaskRequest {
  projectId: string;
  title: string;
  description: string;
  priority: TTaskPriority;
  assigneeId?: string;
  startDate: string;
  dueDate: string;
  estimatedHours: number;
  tags?: string[];
}

export interface IUpdateTaskRequest {
  title?: string;
  description?: string;
  status?: TTaskStatus;
  priority?: TTaskPriority;
  assigneeId?: string;
  dueDate?: string;
  actualHours?: number;
}

export interface ITaskExcelData {
  taskName: string;
  description: string;
  assignee: string;
  priority: string;
  startDate: string;
  dueDate: string;
  estimatedHours: number;
}
