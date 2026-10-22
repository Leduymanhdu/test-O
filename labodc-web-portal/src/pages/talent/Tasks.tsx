import React, { useEffect, useMemo, useState } from 'react';
import { Card, Typography, Tag, Progress, Select, Empty, Spin, Alert, Upload, Button, message } from 'antd';
import { CalendarOutlined } from '@ant-design/icons';
import { useSearchParams } from 'react-router-dom';
import { talentService, TalentProject, TalentTask } from '@/services/talent/talentService';

const { Title } = Typography;

const Tasks: React.FC = () => {
  const [searchParams] = useSearchParams();
  const projectIdParam = searchParams.get('projectId');
  const [projectId, setProjectId] = useState<number | undefined>(
    projectIdParam ? Number(projectIdParam) : undefined
  );
  const [projects, setProjects] = useState<TalentProject[]>([]);
  const [tasks, setTasks] = useState<TalentTask[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [uploadingTaskId, setUploadingTaskId] = useState<number | null>(null);

  useEffect(() => {
    void loadProjects();
  }, []);

  useEffect(() => {
    void loadTasks(projectId);
  }, [projectId]);

  const loadProjects = async () => {
    try {
      const data = await talentService.getMyProjects();
      setProjects(data);
    } catch (err) {
      console.error('Failed to load my projects', err);
    }
  };

  const loadTasks = async (pid?: number) => {
    setLoading(true);
    setError(null);
    try {
      const data = await talentService.getMyTasks(pid);
      setTasks(Array.isArray(data) ? data : []);
    } catch (err) {
      console.error('Failed to load tasks', err);
      setError('Không thể tải nhiệm vụ được giao.');
    } finally {
      setLoading(false);
    }
  };

  const statusColor = (status?: string) => {
    switch (status) {
      case 'completed':
        return 'green';
      case 'in-progress':
        return 'orange';
      case 'pending':
        return 'default';
      default:
        return 'default';
    }
  };

  const statusLabel = (status?: string) => {
    switch (status) {
      case 'completed':
        return 'Hoàn thành';
      case 'in-progress':
        return 'Đang làm';
      case 'pending':
        return 'Chưa bắt đầu';
      default:
        return status || 'Không rõ';
    }
  };

  const tasksByProject = useMemo(() => {
    if (!projectId) return tasks;
    return tasks.filter((t) => Number(t.projectId) === Number(projectId));
  }, [tasks, projectId]);

  const uploadProps = (taskId: number) => ({
    showUploadList: false,
    accept: '.pdf,.doc,.docx,.zip',
    customRequest: async (options: any) => {
      const { file, onSuccess, onError } = options;
      setUploadingTaskId(taskId);
      try {
        await talentService.submitTaskReport(taskId, file as File);
        message.success('Đã nộp báo cáo nhiệm vụ');
        onSuccess?.(null);
        void loadTasks(projectId);
      } catch (err) {
        console.error('Failed to submit task report', err);
        message.error('Không thể nộp báo cáo');
        onError?.(err);
      } finally {
        setUploadingTaskId(null);
      }
    },
  });

  if (loading) {
    return (
      <div style={{ padding: '24px' }}>
        <Spin size="large" />
      </div>
    );
  }

  return (
    <div style={{ padding: '24px' }}>
      <Card style={{ marginBottom: 16 }}>
        <Title level={2} style={{ marginBottom: 12 }}>Nhiệm vụ được giao</Title>
        <Select
          allowClear
          placeholder="Lọc theo dự án"
          style={{ minWidth: 280 }}
          value={projectId}
          onChange={(value) => setProjectId(value)}
          options={projects.map((p) => ({ value: p.id, label: p.title }))}
        />
      </Card>

      {error && (
        <Alert type="error" message={error} showIcon style={{ marginBottom: 16 }} />
      )}

      {tasksByProject.length === 0 ? (
        <Card>
          <Empty description="Chưa có nhiệm vụ được giao" />
        </Card>
      ) : (
        tasksByProject.map((task) => (
          <Card key={task.id} style={{ marginBottom: 16 }}>
            <div style={{ display: 'flex', justifyContent: 'space-between', gap: 16 }}>
              <div>
                <Title level={4} style={{ margin: 0 }}>{task.title}</Title>
                <div style={{ color: '#666', marginBottom: 8 }}>
                  {task.projectName || `Project #${task.projectId ?? ''}`}
                </div>
              </div>
              <Tag color={statusColor(task.status)}>{statusLabel(task.status)}</Tag>
            </div>

            {task.description && <p>{task.description}</p>}

            <div style={{ display: 'flex', gap: 16, flexWrap: 'wrap', alignItems: 'center' }}>
              <div>
                <CalendarOutlined />{' '}
                {task.dueDate ? new Date(task.dueDate).toLocaleDateString('vi-VN') : 'Chưa có hạn'}
              </div>
              {typeof task.progress === 'number' && (
                <div style={{ minWidth: 220 }}>
                  <Progress percent={task.progress} size="small" />
                </div>
              )}
            </div>

            <div style={{ marginTop: 12 }}>
              <Upload {...uploadProps(task.id)}>
                <Button loading={uploadingTaskId === task.id}>Nộp báo cáo</Button>
              </Upload>
            </div>
          </Card>
        ))
      )}
    </div>
  );
};

export default Tasks;
