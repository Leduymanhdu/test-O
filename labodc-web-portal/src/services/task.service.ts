// Task Service
import axiosInstance from './api/axios.config';
import {
  ITask,
  ICreateTaskRequest,
  IUpdateTaskRequest,
  ITaskExcelData,
} from '@/types/task.types';
import { IApiResponse, IPaginatedResponse, IPaginationParams } from '@/types/api.types';

const TASK_ENDPOINTS = {
  BASE: '/tasks',
  UPLOAD_EXCEL: '/tasks/upload-excel',
  TEMPLATE: '/tasks/template',
};

export const taskService = {
  /**
   * Get tasks with pagination
   */
  getTasks: async (
    params: IPaginationParams & { projectId?: string; assigneeId?: string }
  ): Promise<IPaginatedResponse<ITask>> => {
    const response = await axiosInstance.get<IApiResponse<IPaginatedResponse<ITask>>>(
      TASK_ENDPOINTS.BASE,
      { params }
    );
    return response.data.data;
  },

  /**
   * Get task by ID
   */
  getTaskById: async (id: string): Promise<ITask> => {
    const response = await axiosInstance.get<IApiResponse<ITask>>(
      `${TASK_ENDPOINTS.BASE}/${id}`
    );
    return response.data.data;
  },

  /**
   * Create task
   */
  createTask: async (data: ICreateTaskRequest): Promise<ITask> => {
    const response = await axiosInstance.post<IApiResponse<ITask>>(
      TASK_ENDPOINTS.BASE,
      data
    );
    return response.data.data;
  },

  /**
   * Update task
   */
  updateTask: async (id: string, data: IUpdateTaskRequest): Promise<ITask> => {
    const response = await axiosInstance.put<IApiResponse<ITask>>(
      `${TASK_ENDPOINTS.BASE}/${id}`,
      data
    );
    return response.data.data;
  },

  /**
   * Delete task
   */
  deleteTask: async (id: string): Promise<void> => {
    await axiosInstance.delete(`${TASK_ENDPOINTS.BASE}/${id}`);
  },

  /**
   * Upload Excel file with tasks
   */
  uploadExcel: async (projectId: string, file: File): Promise<ITask[]> => {
    const formData = new FormData();
    formData.append('file', file);
    formData.append('projectId', projectId);

    const response = await axiosInstance.post<IApiResponse<ITask[]>>(
      TASK_ENDPOINTS.UPLOAD_EXCEL,
      formData,
      {
        headers: {
          'Content-Type': 'multipart/form-data',
        },
      }
    );
    return response.data.data;
  },

  /**
   * Download Excel template
   */
  downloadTemplate: async (): Promise<Blob> => {
    const response = await axiosInstance.get(TASK_ENDPOINTS.TEMPLATE, {
      responseType: 'blob',
    });
    return response.data;
  },

  /**
   * Get my tasks
   */
  getMyTasks: async (): Promise<ITask[]> => {
    const response = await axiosInstance.get<IApiResponse<ITask[]>>(
      `${TASK_ENDPOINTS.BASE}/my-tasks`
    );
    return response.data.data;
  },

  /**
   * Assign task
   */
  assignTask: async (taskId: string, assigneeId: string): Promise<ITask> => {
    const response = await axiosInstance.post<IApiResponse<ITask>>(
      `${TASK_ENDPOINTS.BASE}/${taskId}/assign`,
      { assigneeId }
    );
    return response.data.data;
  },
};
