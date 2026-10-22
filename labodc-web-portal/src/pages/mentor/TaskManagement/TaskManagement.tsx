import React, { useEffect, useMemo, useState } from 'react';
import {
  CheckCircleOutlined,
  ClockCircleOutlined,
  ExclamationCircleOutlined,
  PlusOutlined,
  EditOutlined,
  DeleteOutlined,
  ReloadOutlined,
  CalendarOutlined,
} from '@ant-design/icons';
import {
  Alert,
  Button,
  Card,
  Col,
  DatePicker,
  Divider,
  Form,
  Input,
  InputNumber,
  message,
  Modal,
  Row,
  Select,
  Spin,
  Tag,
  Popconfirm,
  Table,
} from 'antd';
import TextArea from 'antd/es/input/TextArea';
import dayjs from 'dayjs';
import { mentorService } from '@/services/mentor/mentorService';
import { IMentorProjectOption, IMentorTask, IMentorTalentOption, IMentorTaskSubmission } from '@/types/mentor.types';
import styles from './TaskManagement.module.css';

const getStatusInfo = (status: IMentorTask['status']) => {
  switch (status) {
    case 'completed':
      return { icon: <CheckCircleOutlined />, text: 'Hoàn thành', color: '#52c41a' };
    case 'in-progress':
      return { icon: <ClockCircleOutlined />, text: 'Đang làm', color: '#faad14' };
    case 'pending':
      return { icon: <ExclamationCircleOutlined />, text: 'Chưa bắt đầu', color: '#8c8c8c' };
    default:
      return { icon: null, text: '', color: '' };
  }
};

const getPriorityColor = (priority: IMentorTask['priority']) => {
  switch (priority) {
    case 'high':
      return '#ff4d4f';
    case 'medium':
      return '#faad14';
    case 'low':
      return '#52c41a';
    default:
      return '#d9d9d9';
  }
};

const TaskManagement: React.FC = () => {
  const [tasks, setTasks] = useState<IMentorTask[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [filter, setFilter] = useState<string>('all');
  const [projects, setProjects] = useState<IMentorProjectOption[]>([]);
  const [projectId, setProjectId] = useState<string | undefined>(undefined);
  const [projectsLoading, setProjectsLoading] = useState(false);
  const [projectProgress, setProjectProgress] = useState<number>(0);
  const [progressSaving, setProgressSaving] = useState(false);
  const [talents, setTalents] = useState<IMentorTalentOption[]>([]);
  const [talentsLoading, setTalentsLoading] = useState(false);
  const [modalProjectId, setModalProjectId] = useState<string | undefined>(undefined);
  const [modalVisible, setModalVisible] = useState(false);
  const [submissionModalVisible, setSubmissionModalVisible] = useState(false);
  const [submissionsLoading, setSubmissionsLoading] = useState(false);
  const [taskSubmissions, setTaskSubmissions] = useState<IMentorTaskSubmission[]>([]);
  const [submissionTask, setSubmissionTask] = useState<IMentorTask | null>(null);
  const [editingTask, setEditingTask] = useState<IMentorTask | null>(null);
  const [form] = Form.useForm();

  useEffect(() => {
    void loadProjects();
    void loadTasks();
  }, []);

  useEffect(() => {
    if (!projectId) {
      setTalents([]);
      return;
    }
    void loadTalents(projectId);
  }, [projectId]);

  useEffect(() => {
    if (!projectId) {
      setProjectProgress(0);
      return;
    }
    const selected = projects.find((p) => String(p.id) === String(projectId));
    setProjectProgress(typeof selected?.progressPercentage === 'number' ? selected.progressPercentage : 0);
  }, [projectId, projects]);

  useEffect(() => {
    if (!modalVisible) {
      return;
    }
    if (!modalProjectId) {
      setTalents([]);
      return;
    }
    void loadTalents(modalProjectId);
  }, [modalProjectId, modalVisible]);

  const loadProjects = async () => {
    setProjectsLoading(true);
    try {
      const data = await mentorService.getProjects();
      setProjects(data);
      if (projectId) {
        const selected = data.find((p) => String(p.id) === String(projectId));
        if (typeof selected?.progressPercentage === 'number') {
          setProjectProgress(selected.progressPercentage);
        }
      }
    } catch (err) {
      console.error('Failed to load mentor projects', err);
    } finally {
      setProjectsLoading(false);
    }
  };

  const handleUpdateProjectProgress = async () => {
    if (!projectId) {
      message.warning('Vui lòng chọn dự án trước');
      return;
    }
    setProgressSaving(true);
    try {
      const updated = await mentorService.updateProjectProgress(projectId, projectProgress);
      setProjectProgress(updated);
      setProjects((prev) =>
        prev.map((p) =>
          String(p.id) === String(projectId) ? { ...p, progressPercentage: updated } : p
        )
      );
      message.success('Đã cập nhật tiến độ dự án');
    } catch (err) {
      console.error('Failed to update project progress', err);
      message.error('Không thể cập nhật tiến độ dự án');
    } finally {
      setProgressSaving(false);
    }
  };

  const loadTalents = async (selectedProjectId: string) => {
    setTalentsLoading(true);
    try {
      const data = await mentorService.getProjectTalents(selectedProjectId);
      setTalents(data);
    } catch (err) {
      console.error('Failed to load project talents', err);
      setTalents([]);
    } finally {
      setTalentsLoading(false);
    }
  };

  const loadTasks = async (selectedProjectId?: string) => {
    setLoading(true);
    setError(null);
    try {
      const data = await mentorService.getTasks(selectedProjectId);
      setTasks(data);
    } catch (err) {
      console.error('Failed to load tasks', err);
      setError('Không thể tải công việc hiện tại.');
    } finally {
      setLoading(false);
    }
  };

  const handleCreateTask = () => {
    setEditingTask(null);
    setModalProjectId(projectId);
    form.resetFields();
    form.setFieldsValue({
      projectId: projectId ? Number(projectId) : undefined,
      status: 'pending',
      priority: 'medium',
      progress: 0,
      assignedTo: [],
      dueDate: null,
    });
    setModalVisible(true);
  };

  const handleEditTask = (task: IMentorTask) => {
    setEditingTask(task);
    setModalProjectId(task.projectId ? String(task.projectId) : undefined);
    if (task.projectId) {
      void loadTalents(String(task.projectId));
    }
    form.setFieldsValue({
      ...task,
      dueDate: task.dueDate ? dayjs(task.dueDate) : null,
    });
    setModalVisible(true);
  };

  const handleDeleteTask = async (task: IMentorTask) => {
    if (!task.projectId) {
      message.error('Không tìm thấy projectId');
      return;
    }
    try {
      await mentorService.deleteTask(task.projectId, task.id);
      message.success('Đã xóa công việc');
      setTasks((prev) => prev.filter((t) => t.id !== task.id));
    } catch (err) {
      console.error('Failed to delete task', err);
      message.error('Không thể xóa công việc');
    }
  };

  const handleOpenSubmissions = async (task: IMentorTask) => {
    setSubmissionTask(task);
    setSubmissionModalVisible(true);
    setSubmissionsLoading(true);
    try {
      const data = await mentorService.getTaskSubmissions(task.id);
      setTaskSubmissions(data);
    } catch (err) {
      console.error('Failed to load task submissions', err);
      message.error('Không thể tải báo cáo nhiệm vụ');
      setTaskSubmissions([]);
    } finally {
      setSubmissionsLoading(false);
    }
  };

  const handleDownloadSubmission = async (taskId: string, submission: IMentorTaskSubmission) => {
    try {
      const response = await mentorService.downloadTaskSubmissionFile(taskId, submission.id);
      const url = window.URL.createObjectURL(response.data);
      const link = document.createElement('a');
      link.href = url;
      link.download = submission.fileName || `submission-${submission.id}`;
      document.body.appendChild(link);
      link.click();
      link.remove();
      window.URL.revokeObjectURL(url);
    } catch (err) {
      console.error('Failed to download submission', err);
      message.error('Không thể tải file báo cáo');
    }
  };

  const handleSubmit = async () => {
    try {
      const values = await form.validateFields();
      const taskData = {
        ...values,
        dueDate: values.dueDate ? values.dueDate.toISOString() : null,
      };

      if (editingTask) {
        // Update existing task
        if (!editingTask.projectId) {
          message.error('Không tìm thấy projectId');
          return;
        }
        const updated = await mentorService.updateTask(editingTask.projectId, editingTask.id, {
          title: taskData.title,
          description: taskData.description,
          status: taskData.status,
          priority: taskData.priority,
          progress: taskData.progress,
          dueDate: taskData.dueDate,
          assignedTo: taskData.assignedTo,
        });
        message.success('Đã cập nhật công việc');
        setTasks((prev) => prev.map((t) => (t.id === editingTask.id ? updated : t)));
      } else {
        // Create new task
        const createProjectId = values.projectId ? String(values.projectId) : null;
        if (!createProjectId) {
          message.error('Vui lòng chọn dự án');
          return;
        }
        const created = await mentorService.createTask(createProjectId, taskData);
        message.success('Đã tạo công việc mới');
        setTasks((prev) => [...prev, created]);
      }

      setModalVisible(false);
      form.resetFields();
    } catch (err) {
      console.error('Failed to save task', err);
      message.error('Không thể lưu công việc');
    }
  };

  const filteredTasks = useMemo(() => {
    if (filter === 'all') return tasks;
    return tasks.filter((task) => task.status === filter);
  }, [filter, tasks]);

  const stats = useMemo(() => {
    if (!tasks.length) {
      return { total: 0, completed: 0, inProgress: 0, pending: 0, avgProgress: 0 };
    }
    return {
      total: tasks.length,
      completed: tasks.filter((t) => t.status === 'completed').length,
      inProgress: tasks.filter((t) => t.status === 'in-progress').length,
      pending: tasks.filter((t) => t.status === 'pending').length,
      avgProgress: Math.round(tasks.reduce((sum, t) => sum + t.progress, 0) / tasks.length),
    };
  }, [tasks]);

  if (loading) {
    return (
      <div className={styles.loadingContainer}>
        <Spin size="large" />
      </div>
    );
  }

  return (
    <div className={styles.pageWrapper}>
      <div className={styles.dashboardContainer}>
        <div className={styles.header}>
          <div>
            <h1 className={styles.title}>
              Quản lý công việc
              <span className={styles.subtitle}>
                Theo dõi tiến độ nhóm và đề xuất hỗ trợ kịp thời
              </span>
            </h1>
          </div>
          <div style={{ display: 'flex', gap: '12px', alignItems: 'center', flexWrap: 'wrap' }}>
            <Select
              allowClear
              showSearch
              placeholder="Tất cả dự án"
              style={{ minWidth: 260 }}
              loading={projectsLoading}
              value={projectId}
              optionFilterProp="label"
              options={projects.map((p) => ({ value: String(p.id), label: p.title }))}
              onChange={(value) => {
                const next = value || undefined;
                setProjectId(next);
                void loadTasks(next);
              }}
            />
            <Button icon={<ReloadOutlined />} onClick={() => loadTasks(projectId)}>
              Làm mới
            </Button>
            <Button type="primary" icon={<PlusOutlined />} onClick={handleCreateTask}>
              Tạo công việc
            </Button>
          </div>
        </div>

        <Divider className={styles.divider} />

        {error && (
          <Alert
            type="error"
            message="Lỗi tải công việc"
            description={error}
            showIcon
            style={{ marginBottom: 24 }}
          />
        )}

        {/* Stats Row */}
        <Row gutter={[16, 16]} className={styles.statsRow}>
          <Col xs={24} sm={12} lg={6}>
            <Card className={styles.statCard}>
              <div className={styles.statIcon}>📋</div>
              <div className={styles.statLabel}>Tổng công việc</div>
              <div className={styles.statValue}>{stats.total}</div>
            </Card>
          </Col>
          <Col xs={24} sm={12} lg={6}>
            <Card className={styles.statCard}>
              <div className={styles.statIcon}>✅</div>
              <div className={styles.statLabel}>Hoàn thành</div>
              <div className={styles.statValue}>{stats.completed}</div>
            </Card>
          </Col>
          <Col xs={24} sm={12} lg={6}>
            <Card className={styles.statCard}>
              <div className={styles.statIcon}>🔄</div>
              <div className={styles.statLabel}>Đang làm</div>
              <div className={styles.statValue}>{stats.inProgress}</div>
            </Card>
          </Col>
          <Col xs={24} sm={12} lg={6}>
            <Card className={styles.statCard}>
              <div className={styles.statIcon}>📊</div>
              <div className={styles.statLabel}>Tiến độ TB</div>
              <div className={styles.statValue}>{stats.avgProgress}%</div>
            </Card>
          </Col>
        </Row>

        {/* Filter Buttons */}
        <div className={styles.filterRow}>
          <Button type={filter === 'all' ? 'primary' : 'default'} onClick={() => setFilter('all')}>
            Tất cả ({stats.total})
          </Button>
          <Button
            type={filter === 'completed' ? 'primary' : 'default'}
            onClick={() => setFilter('completed')}
          >
            Hoàn thành ({stats.completed})
          </Button>
          <Button
            type={filter === 'in-progress' ? 'primary' : 'default'}
            onClick={() => setFilter('in-progress')}
          >
            Đang làm ({stats.inProgress})
          </Button>
          <Button
            type={filter === 'pending' ? 'primary' : 'default'}
            onClick={() => setFilter('pending')}
          >
            Chưa bắt đầu ({stats.pending})
          </Button>
        </div>

        {/* Tasks Grid */}
        <div className={styles.taskGrid}>
          {!filteredTasks.length && (
            <Alert type="info" message="Không có công việc phù hợp" showIcon />
          )}

          {filteredTasks.map((task) => {
            const statusInfo = getStatusInfo(task.status);
            const priorityColor = getPriorityColor(task.priority);
            return (
              <Card key={task.id} className={styles.taskCard}>
                <div className={styles.cardHeader}>
                  <div>
                    <h3 className={styles.taskTitle}>{task.title}</h3>
                    <p className={styles.projectName}>{task.projectName}</p>
                  </div>
                  <Tag color={priorityColor}>{task.priority.toUpperCase()}</Tag>
                </div>

                <p className={styles.description}>{task.description}</p>

                <div style={{ marginBottom: '12px' }}>
                  <Tag icon={statusInfo.icon} color={statusInfo.color}>
                    {statusInfo.text}
                  </Tag>
                </div>

                <div className={styles.progressWrapper}>
                  <div className={styles.progressLabel}>Tiến độ: {task.progress}%</div>
                  <div className={styles.progressBarContainer}>
                    <div className={styles.progressBar} style={{ width: `${task.progress}%` }} />
                  </div>
                </div>

                <div className={styles.metaRow}>
                  <span>
                    <CalendarOutlined />{' '}
                    {task.dueDate
                      ? new Date(task.dueDate).toLocaleDateString('vi-VN')
                      : 'Chưa có hạn'}
                  </span>
                </div>

                <div className={styles.actionRow}>
                  <Button icon={<EditOutlined />} size="small" onClick={() => handleEditTask(task)}>
                    Sửa
                  </Button>
                  <Button size="small" onClick={() => handleOpenSubmissions(task)}>
                    Báo cáo
                  </Button>
                  <Popconfirm
                    title="Xóa công việc này?"
                    description="Bạn có chắc muốn xóa công việc này không?"
                    onConfirm={() => handleDeleteTask(task)}
                    okText="Xóa"
                    cancelText="Hủy"
                    okButtonProps={{ danger: true }}
                  >
                    <Button icon={<DeleteOutlined />} size="small" danger>
                      Xóa
                    </Button>
                  </Popconfirm>
                </div>
              </Card>
            );
          })}
        </div>

        <Divider className={styles.divider} />

        <Card>
          <div style={{ display: 'flex', alignItems: 'flex-start', justifyContent: 'space-between', gap: 16 }}>
            <div>
              <h3 style={{ marginBottom: 8 }}>Cập nhật tiến độ dự án</h3>
              <div style={{ color: '#6b7280' }}>
                Chọn dự án ở phía trên để cập nhật tiến độ tổng thể.
              </div>
            </div>
            <Tag color={projectId ? 'blue' : 'default'}>
              {projectId ? 'Đã chọn dự án' : 'Chưa chọn dự án'}
            </Tag>
          </div>
          <div style={{ marginTop: 16, display: 'flex', gap: 12, flexWrap: 'wrap' }}>
            <InputNumber
              min={0}
              max={100}
              value={projectProgress}
              onChange={(value) => setProjectProgress(typeof value === 'number' ? value : 0)}
              disabled={!projectId}
              style={{ width: 160 }}
              addonAfter="%"
            />
            <Button
              type="primary"
              onClick={handleUpdateProjectProgress}
              loading={progressSaving}
              disabled={!projectId}
            >
              Cập nhật
            </Button>
          </div>
        </Card>

        {/* Create/Edit Modal */}
        <Modal
          title={editingTask ? 'Chỉnh sửa công việc' : 'Tạo công việc mới'}
          open={modalVisible}
          onOk={handleSubmit}
          onCancel={() => {
            setModalVisible(false);
            form.resetFields();
            setModalProjectId(undefined);
          }}
          okText={editingTask ? 'Cập nhật' : 'Tạo'}
          cancelText="Hủy"
          width={600}
        >
          <Form form={form} layout="vertical">
            {!editingTask && (
              <Form.Item
                name="projectId"
                label="Dự án"
                rules={[{ required: true, message: 'Vui lòng chọn dự án' }]}
              >
                <Select
                  showSearch
                  placeholder="Chọn dự án"
                  optionFilterProp="label"
                  loading={projectsLoading}
                  options={projects.map((p) => ({ value: Number(p.id), label: p.title }))}
                  onChange={(value) => {
                    const next = value ? String(value) : undefined;
                    setModalProjectId(next);
                  }}
                  notFoundContent="Không tìm thấy dự án"
                />
              </Form.Item>
            )}

            <Form.Item
              name="title"
              label="Tên công việc"
              rules={[{ required: true, message: 'Vui lòng nhập tên công việc' }]}
            >
              <Input placeholder="Nhập tên công việc" />
            </Form.Item>

            <Form.Item name="description" label="Mô tả">
              <TextArea rows={4} placeholder="Mô tả chi tiết công việc" />
            </Form.Item>

            <Row gutter={16}>
              <Col span={12}>
                <Form.Item name="priority" label="Ưu tiên" rules={[{ required: true }]}>
                  <Select placeholder="Chọn mức ưu tiên">
                    <Select.Option value="low">Thấp</Select.Option>
                    <Select.Option value="medium">Trung bình</Select.Option>
                    <Select.Option value="high">Cao</Select.Option>
                  </Select>
                </Form.Item>
              </Col>
              <Col span={12}>
                <Form.Item name="status" label="Trạng thái" rules={[{ required: true }]}>
                  <Select placeholder="Chọn trạng thái">
                    <Select.Option value="pending">Chưa bắt đầu</Select.Option>
                    <Select.Option value="in-progress">Đang làm</Select.Option>
                    <Select.Option value="completed">Hoàn thành</Select.Option>
                  </Select>
                </Form.Item>
              </Col>
            </Row>

            <Row gutter={16}>
              <Col span={12}>
                <Form.Item
                  name="progress"
                  label="Tiến độ (%)"
                  rules={[{ required: true, type: 'number', min: 0, max: 100 }]}
                >
                  <InputNumber style={{ width: '100%' }} min={0} max={100} placeholder="0-100" />
                </Form.Item>
              </Col>
              <Col span={12}>
                <Form.Item name="dueDate" label="Hạn chót">
                  <DatePicker style={{ width: '100%' }} format="DD/MM/YYYY" />
                </Form.Item>
              </Col>
            </Row>

            <Form.Item name="assignedTo" label="Người được giao">
              <Select
                mode="tags"
                placeholder="Nhập tên/MSSV (enter để thêm)"
                tokenSeparators={[',']}
                loading={talentsLoading}
                optionFilterProp="label"
                options={talents.map((t) => ({
                  value: t.studentId ? `${t.fullName} (${t.studentId})` : t.fullName,
                  label: t.studentId ? `${t.fullName} (${t.studentId})` : t.fullName,
                }))}
                notFoundContent={projectId ? 'Không tìm thấy thành viên' : 'Hãy chọn dự án'}
              />
            </Form.Item>
          </Form>
        </Modal>

        <Modal
          title={`Báo cáo nhiệm vụ${submissionTask ? `: ${submissionTask.title}` : ''}`}
          open={submissionModalVisible}
          onCancel={() => {
            setSubmissionModalVisible(false);
            setTaskSubmissions([]);
            setSubmissionTask(null);
          }}
          footer={null}
          width={720}
        >
          <Table
            rowKey="id"
            loading={submissionsLoading}
            dataSource={taskSubmissions}
            pagination={false}
            locale={{ emptyText: 'Chưa có báo cáo nào' }}
            columns={[
              {
                title: 'Sinh viên',
                dataIndex: 'talentName',
                render: (value: string, record: IMentorTaskSubmission) =>
                  record.studentId ? `${value || ''} (${record.studentId})` : value || record.studentId,
              },
              {
                title: 'Tên file',
                dataIndex: 'fileName',
              },
              {
                title: 'Ngày nộp',
                dataIndex: 'submittedAt',
                render: (value: string) =>
                  value ? new Date(value).toLocaleString('vi-VN') : '',
              },
              {
                title: 'Tải',
                render: (_: unknown, record: IMentorTaskSubmission) => (
                  <Button
                    size="small"
                    onClick={() => handleDownloadSubmission(String(submissionTask?.id || ''), record)}
                  >
                    Tải file
                  </Button>
                ),
              },
            ]}
          />
        </Modal>
      </div>
    </div>
  );
};

export default TaskManagement;
