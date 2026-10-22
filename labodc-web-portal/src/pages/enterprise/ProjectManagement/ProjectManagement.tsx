import React, { useCallback, useEffect, useState } from 'react';
import {
  Row,
  Col,
  Card,
  Statistic,
  Tag,
  Button,
  Select,
  Progress,
  Modal,
  Form,
  Input,
  DatePicker,
  InputNumber,
  message,
  Space,
  Popconfirm,
  Descriptions,
  List,
  Empty,
} from 'antd';
import {
  ProjectOutlined,
  CheckCircleOutlined,
  RiseOutlined,
  DollarOutlined,
} from '@ant-design/icons';
import {
  getProjectSummary,
  getProjects,
  Project,
  createProject,
  getProjectById,
  updateProject,
  deleteProject,
  getMentors,
  assignMentor,
  startProject,
  MentorOption,
} from '@/services/enterprise/project.service';
import { getFeedbacks, EnterpriseFeedback } from '@/services/enterprise/feedback.service';
import { getEnterpriseDashboardSummary } from '@/services/enterprise/dashboard.service';
import { formatCurrencyVND } from '@/utils/formatters';
import { useNavigate } from 'react-router-dom';
import '../enterprise-modern.css';
import dayjs from 'dayjs';

const ProjectManagement: React.FC = () => {
  const navigate = useNavigate();
  const [form] = Form.useForm();

  const [status, setStatus] = useState<string>('ALL');
  const [loading, setLoading] = useState(false);
  const [createOpen, setCreateOpen] = useState(false);
  const [creating, setCreating] = useState(false);
  const [editOpen, setEditOpen] = useState(false);
  const [editing, setEditing] = useState(false);
  const [editId, setEditId] = useState<string | null>(null);
  const [detailOpen, setDetailOpen] = useState(false);
  const [detailLoading, setDetailLoading] = useState(false);
  const [detailData, setDetailData] = useState<any>(null);
  const [detailProjectId, setDetailProjectId] = useState<string | null>(null);
  const [detailFeedback, setDetailFeedback] = useState<EnterpriseFeedback | null>(null);
  const [mentorModalOpen, setMentorModalOpen] = useState(false);
  const [mentors, setMentors] = useState<MentorOption[]>([]);
  const [mentorLoading, setMentorLoading] = useState(false);
  const [assigningMentor, setAssigningMentor] = useState(false);
  const [selectedMentorId, setSelectedMentorId] = useState<number | undefined>();
  const [mentorMessage, setMentorMessage] = useState('');
  const [notifications, setNotifications] = useState<string[]>([]);

  const [summary, setSummary] = useState({
    total: 0,
    inProgress: 0,
    completed: 0,
    totalBudget: 0,
  });

  const [projects, setProjects] = useState<Project[]>([]);

  const refreshProjects = useCallback(async () => {
    setLoading(true);
    try {
      const summaryRes = await getProjectSummary();
      const projectsRes = await getProjects(status);
      const dashboardRes = await getEnterpriseDashboardSummary();

      setSummary(
        summaryRes ?? {
          total: 0,
          inProgress: 0,
          completed: 0,
          totalBudget: 0,
        }
      );
      setProjects(Array.isArray(projectsRes) ? projectsRes : []);
      setNotifications(
        Array.isArray(dashboardRes?.notifications) ? dashboardRes.notifications : []
      );
    } catch (err) {
      console.error('Load project data failed:', err);
    } finally {
      setLoading(false);
    }
  }, [status]);

  useEffect(() => {
    refreshProjects();
  }, [refreshProjects]);

  const openMentorModal = async () => {
    try {
      setMentorLoading(true);
      const data = await getMentors();
      setMentors(Array.isArray(data) ? data : []);
      setMentorModalOpen(true);
    } catch (err: any) {
      message.error(err?.message || 'Không thể tải danh sách mentor');
    } finally {
      setMentorLoading(false);
    }
  };

  const handleAssignMentor = async () => {
    if (!detailData?.id || !selectedMentorId) return;
    try {
      setAssigningMentor(true);
      await assignMentor(detailData.id, selectedMentorId, mentorMessage);
      message.success('Đã gửi lời mời mentor');
      setMentorModalOpen(false);
      setSelectedMentorId(undefined);
      setMentorMessage('');
      await refreshProjects();
      const detail = await getProjectById(detailData.id);
      setDetailData(detail ?? detailData);
    } catch (err: any) {
      message.error(err?.message || 'Không thể gửi lời mời mentor');
    } finally {
      setAssigningMentor(false);
    }
  };

  const handleStartProject = async (projectId: string) => {
    try {
      await startProject(projectId);
      message.success('Đã chuyển dự án sang trạng thái đang thực hiện');
      await refreshProjects();
    } catch (err: any) {
      message.error(err?.message || 'Không thể chuyển trạng thái dự án');
    }
  };
  const getStatusColor = (status: string) => {
    switch (status) {
      case 'COMPLETED':
        return 'green';
      case 'IN_PROGRESS':
        return 'blue';
      case 'RECRUITING':
        return 'orange';
      case 'PENDING_VALIDATION':
        return 'gold';
      default:
        return 'default';
    }
  };

  const getStatusLabel = (status: string) => {
    switch (status) {
      case 'PENDING_VALIDATION':
        return 'Chờ duyệt';
      case 'VALIDATED':
        return 'Đã duyệt';
      case 'RECRUITING':
        return 'Đang tuyển';
      case 'IN_PROGRESS':
        return 'Đang thực hiện';
      case 'COMPLETED':
        return 'Hoàn thành';
      case 'ON_HOLD':
        return 'Tạm dừng';
      case 'REJECTED':
        return 'Từ chối';
      default:
        return status || '-';
    }
  };

  return (
    <div className="page-wrapper">
      {/* HEADER */}
      <div className="page-header">
        <h1>Quản lý dự án</h1>
        <Button type="primary" icon={<ProjectOutlined />} onClick={() => setCreateOpen(true)}>
          Tạo dự án mới
        </Button>
      </div>

      {/* SUMMARY */}
      <Row gutter={[16, 16]} className="stat-row">
        <Col xs={24} sm={12} lg={6}>
          <Card className="modern-card stat-card">
            <Statistic title="Tổng dự án" value={summary.total} prefix={<ProjectOutlined />} valueStyle={{ color: '#17a2b8' }} />
          </Card>
        </Col>
        <Col xs={24} sm={12} lg={6}>
          <Card className="modern-card stat-card">
            <Statistic
              title="Đang thực hiện"
              value={summary.inProgress}
              prefix={<RiseOutlined />}
              valueStyle={{ color: '#faad14' }}
            />
          </Card>
        </Col>
        <Col xs={24} sm={12} lg={6}>
          <Card className="modern-card stat-card">
            <Statistic
              title="Hoàn thành"
              value={summary.completed}
              prefix={<CheckCircleOutlined />}
              valueStyle={{ color: '#52c41a' }}
            />
          </Card>
        </Col>
        <Col xs={24} sm={12} lg={6}>
          <Card className="modern-card stat-card">
            <Statistic
              title="Tổng ngân sách"
              value={summary.totalBudget}
              prefix={<DollarOutlined />}
              formatter={(v) => formatCurrencyVND(Number(v))}
            />
          </Card>
        </Col>
      </Row>

      <Card title="Thông báo" className="table-card">
        {notifications.length > 0 ? (
          <List
            dataSource={notifications}
            renderItem={(item: string) => <List.Item>{item}</List.Item>}
          />
        ) : (
          <Empty description="Chưa có thông báo" image={Empty.PRESENTED_IMAGE_SIMPLE} />
        )}
      </Card>

      {/* FILTER */}
      <div className="filter-bar">
        <Select value={status} onChange={setStatus} style={{ width: 220 }}>
          <Select.Option value="ALL">Tất cả</Select.Option>
          <Select.Option value="PENDING_VALIDATION">Chờ duyệt</Select.Option>
          <Select.Option value="RECRUITING">Đang tuyển</Select.Option>
          <Select.Option value="IN_PROGRESS">Đang thực hiện</Select.Option>
          <Select.Option value="COMPLETED">Hoàn thành</Select.Option>
          <Select.Option value="ON_HOLD">Tạm dừng</Select.Option>
        </Select>
      </div>

      {/* PROJECT CARDS */}
      <div className="project-grid">
        {projects.map((record) => (
          <Card key={record.key} className="project-card">
            <div className="project-card-header">
              <div>
                <div className="project-title">{record.name}</div>
                <div className="project-subtitle">
                  Thành viên: {(record as any)?.members ?? '-'}
                </div>
              </div>
              <Tag color={getStatusColor(record.status)}>{getStatusLabel(record.status)}</Tag>
            </div>

            <div className="project-metrics">
              <div>
                <div className="metric-label">Ngân sách</div>
                <div className="metric-value">{formatCurrencyVND(record.budget)}</div>
              </div>
              <div>
                <div className="metric-label">Đã chi</div>
                <div className="metric-value">{formatCurrencyVND(record.spent)}</div>
              </div>
              <div>
                <div className="metric-label">Thời gian</div>
                <div className="metric-value">
                  <span className="date-start">{(record as any)?.startDate ?? '-'}</span>
                  <br />
                  <span className="date-end">{(record as any)?.endDate ?? '-'}</span>
                </div>
              </div>
            </div>

            <div className="project-progress">
              <div className="metric-label">Tiến độ</div>
              <Progress percent={record.progress} />
            </div>

            <div className="project-actions">
              <Button
                type="link"
                onClick={async () => {
                  try {
                    setDetailLoading(true);
                    const detail = await getProjectById(record.key);
                    setDetailData(detail ?? null);
                    setDetailProjectId(String(record.key));
                    const feedbackList = await getFeedbacks();
                    const feedback = Array.isArray(feedbackList)
                      ? feedbackList.find((f: any) => Number(f.projectId) === Number(record.key))
                      : null;
                    setDetailFeedback(feedback ?? null);
                    setDetailOpen(true);
                  } catch (err: any) {
                    message.error(err?.message || 'Không thể tải chi tiết dự án');
                  } finally {
                    setDetailLoading(false);
                  }
                }}
              >
                Chi tiết
              </Button>
              {record.status === 'RECRUITING' && Number((record as any)?.members ?? 0) > 0 && (
                <Popconfirm
                  title="Bắt đầu dự án"
                  description="Dự án sẽ chuyển sang trạng thái đang thực hiện."
                  okText="Bắt đầu"
                  cancelText="Hủy"
                  onConfirm={() => handleStartProject(String(record.key))}
                >
                  <Button type="link">Bắt đầu</Button>
                </Popconfirm>
              )}{' '}
              {record.status === 'PENDING_VALIDATION' && (
                <>
                  <Button
                    type="link"
                    onClick={async () => {
                      try {
                        const detail = await getProjectById(record.key);
                        setEditId(String(record.key));
                        form.setFieldsValue({

                          name: detail?.name ?? record.name,
                          description: detail?.description ?? '',
                          objectives: Array.isArray(detail?.objectives)
                            ? detail.objectives.join('\n')
                            : (detail?.objective ?? ''),
                          requirements: detail?.requirements ?? '',
                          startDate: detail?.startDate ? dayjs(detail.startDate) : undefined,
                          endDate: detail?.endDate ? dayjs(detail.endDate) : undefined,
                          budget: detail?.budget ?? record.budget,
                          requiredTalents: detail?.requiredTalents ?? undefined,
                          technologies: Array.isArray(detail?.technologies)
                            ? detail.technologies.join(', ')
                            : '',
                          requiredSkills: Array.isArray(detail?.requiredSkills)
                            ? detail.requiredSkills.join(', ')
                            : '',
                          allowApplications: detail?.allowApplications ?? true,
                        });
                        setEditOpen(true);
                      } catch (err: any) {
                        message.error(err?.message || 'Không thể tải dự án');
                      }
                    }}
                  >
                    Sửa
                  </Button>
                  <Popconfirm
                    title="Xóa dự án"
                    description="Chỉ dự án chờ duyệt mới được xóa."
                    okText="Xóa"
                    cancelText="Hủy"
                    onConfirm={async () => {
                      try {
                        await deleteProject(record.key);
                        message.success('Đã xóa dự án');
                        await refreshProjects();
                      } catch (err: any) {
                        message.error(err?.message || 'Không thể xóa dự án');
                      }
                    }}
                  >
                    <Button type="link" danger>
                      Xóa
                    </Button>
                  </Popconfirm>
                </>
              )}
            </div>
          </Card>
        ))}
      </div>

      <Modal
        title="Chi tiết dự án"
        open={detailOpen}
        onCancel={() => {
          setDetailOpen(false);
          setDetailData(null);
          setDetailProjectId(null);
          setDetailFeedback(null);
        }}
        footer={
          (detailData?.status === 'RECRUITING' || detailData?.status === 'approved') &&
          !detailData?.mentorId ? (
            <Button type="primary" onClick={openMentorModal}>
              Chọn mentor
            </Button>
          ) : null
        }
      >
        <Descriptions bordered size="small" column={1} labelStyle={{ width: 160 }}>
          <Descriptions.Item label="Tên dự án">{detailData?.name ?? '-'}</Descriptions.Item>
          <Descriptions.Item label="Trạng thái">{detailData?.status ?? '-'}</Descriptions.Item>
          <Descriptions.Item label="Ngân sách">
            {typeof detailData?.budget === 'number' ? formatCurrencyVND(detailData.budget) : '-'}
          </Descriptions.Item>
          <Descriptions.Item label="Mô tả">{detailData?.description ?? '-'}</Descriptions.Item>
          <Descriptions.Item label="Yêu cầu">{detailData?.requirements ?? '-'}</Descriptions.Item>
          <Descriptions.Item label="Mục tiêu">
            {Array.isArray(detailData?.objectives)
              ? detailData.objectives.join(', ')
              : (detailData?.objective ?? '-')}
          </Descriptions.Item>
          <Descriptions.Item label="Công nghệ">
            {Array.isArray(detailData?.technologies) ? detailData.technologies.join(', ') : '-'}
          </Descriptions.Item>
          <Descriptions.Item label="Kỹ năng yêu cầu">
            {Array.isArray(detailData?.requiredSkills) ? detailData.requiredSkills.join(', ') : '-'}
          </Descriptions.Item>
          <Descriptions.Item label="Mentor">
            {detailData?.mentorName
              ? detailData.mentorName
              : detailData?.mentorId
                ? `ID: ${detailData.mentorId}`
                : 'Chưa có'}
          </Descriptions.Item>
          <Descriptions.Item label="Bắt đầu">{detailData?.startDate ?? '-'}</Descriptions.Item>
          <Descriptions.Item label="Kết thúc">{detailData?.endDate ?? '-'}</Descriptions.Item>
          <Descriptions.Item label="Đánh giá">
            {detailFeedback ? (
              <div style={{ display: 'flex', gap: 8, alignItems: 'center' }}>
                <Tag color="blue">{detailFeedback.overallRating ?? '-'} / 5</Tag>
                <Button
                  type="link"
                  onClick={() =>
                    detailProjectId && navigate(`/enterprise/feedback?projectId=${detailProjectId}`)
                  }
                >
                  Xem đánh giá
                </Button>
              </div>
            ) : (
              <span>Chưa đánh giá</span>
            )}
          </Descriptions.Item>
        </Descriptions>
      </Modal>
      <Modal
        title="Chọn mentor"
        open={mentorModalOpen}
        onCancel={() => {
          setMentorModalOpen(false);
        }}
        onOk={handleAssignMentor}
        okText="Gửi lời mời"
        cancelText="Hủy"
        confirmLoading={assigningMentor}
        destroyOnHidden
      >
        <Form layout="vertical">
          <Form.Item label="Mentor">
            <Select
              placeholder="Chọn mentor"
              loading={mentorLoading}
              value={selectedMentorId}
              onChange={(value) => setSelectedMentorId(value)}
              options={mentors.map((mentor) => ({
                label: `${mentor.fullName}${mentor.title ? ` (${mentor.title})` : mentor.currentCompany ? ` (${mentor.currentCompany})` : ''}`,
                value: mentor.id,
              }))}
            />
          </Form.Item>
          <Form.Item label="Ghi chú (tùy chọn)">
            <Input.TextArea
              rows={3}
              value={mentorMessage}
              onChange={(event) => setMentorMessage(event.target.value)}
              placeholder="Nội dung lời mời..."
            />
          </Form.Item>
        </Form>
      </Modal>
      <Modal
        title="Tạo dự án mới"
        open={createOpen}
        maskClosable={false}
        onCancel={() => {
          setCreateOpen(false);
          form.resetFields();
        }}
        onOk={async () => {
          try {
            const values = await form.validateFields();
            setCreating(true);

            const objectives = values.objectives
              ? String(values.objectives)
                  .split('\n')
                  .map((s: string) => s.trim())
                  .filter(Boolean)
              : undefined;

            await createProject({
              name: values.name,
              description: values.description,
              requirements: values.requirements,
              objectives,
              startDate: dayjs(values.startDate).format('YYYY-MM-DD'),
              endDate: dayjs(values.endDate).format('YYYY-MM-DD'),
              budget: Number(values.budget),
              requiredTalents: Number(values.requiredTalents),
              technologies: values.technologies
                ? String(values.technologies)
                    .split(',')
                    .map((s: string) => s.trim())
                    .filter(Boolean)
                : undefined,
              requiredSkills: values.requiredSkills
                ? String(values.requiredSkills)
                    .split(',')
                    .map((s: string) => s.trim())
                    .filter(Boolean)
                : undefined,
              allowApplications: values.allowApplications ?? true,
            });

            message.success('Tạo dự án thành công');
            setCreateOpen(false);
            form.resetFields();
            await refreshProjects();
          } catch (err: any) {
            if (err?.errorFields) return;
            message.error(err?.message || 'Không thể tạo dự án');
          } finally {
            setCreating(false);
          }
        }}
        confirmLoading={creating}
        okText="Tạo"
        cancelText="Hủy"
      >
        <Form form={form} layout="vertical">
          <Form.Item
            label="Tên dự án"
            name="name"
            rules={[{ required: true, message: 'Vui lòng nhập tên dự án' }]}
          >
            <Input placeholder="Ví dụ: Hệ thống quản lý kho" />
          </Form.Item>
          <Form.Item
            label="Mô tả"
            name="description"
            rules={[{ required: true, message: 'Vui lòng nhập mô tả' }]}
          >
            <Input.TextArea rows={3} placeholder="Mô tả ngắn về dự án" />
          </Form.Item>
          <Form.Item label="Mục tiêu (mỗi dòng một mục)" name="objectives">
            <Input.TextArea rows={3} placeholder="Ví dụ: Xây API\nTạo giao diện\nTriển khai" />
          </Form.Item>
          <Form.Item label="Yêu cầu" name="requirements">
            <Input.TextArea rows={3} placeholder="Yêu cầu kỹ thuật / quy trình" />
          </Form.Item>
          <Form.Item label="Thời gian" style={{ marginBottom: 0 }}>
            <Form.Item
              name="startDate"
              rules={[{ required: true, message: 'Chọn ngày bắt đầu' }]}
              style={{ display: 'inline-block', width: 'calc(50% - 8px)' }}
            >
              <DatePicker
                style={{ width: '100%' }}
                getPopupContainer={(trigger) => trigger.parentElement as HTMLElement}
              />
            </Form.Item>
            <Form.Item
              name="endDate"
              dependencies={['startDate']}
              rules={[
                { required: true, message: 'Chọn ngày kết thúc' },
                ({ getFieldValue }) => ({
                  validator(_, value) {
                    const start = getFieldValue('startDate');
                    if (!start || !value) {
                      return Promise.resolve();
                    }
                    if (dayjs(value).isAfter(start, 'day')) {
                      return Promise.resolve();
                    }
                    return Promise.reject(new Error('Ngày kết thúc phải sau ngày bắt đầu'));
                  },
                }),
              ]}
              style={{ display: 'inline-block', width: 'calc(50% - 8px)', marginLeft: 16 }}
            >
              <DatePicker
                style={{ width: '100%' }}
                getPopupContainer={(trigger) => trigger.parentElement as HTMLElement}
                disabledDate={(current) => {
                  const start = form.getFieldValue('startDate');
                  if (!start || !current) return false;
                  return (
                    dayjs(current).isBefore(dayjs(start), 'day') ||
                    dayjs(current).isSame(dayjs(start), 'day')
                  );
                }}
              />
            </Form.Item>
          </Form.Item>
          <Form.Item
            label="Ngân sách (VND)"
            name="budget"
            rules={[{ required: true, message: 'Nhập ngân sách' }]}
          >
            <InputNumber style={{ width: '100%' }} min={0} />
          </Form.Item>
          <Form.Item
            label="Số lượng sinh viên"
            name="requiredTalents"
            rules={[{ required: true, message: 'Nhập số lượng sinh viên' }]}
          >
            <InputNumber style={{ width: '100%' }} min={1} max={50} />
          </Form.Item>
          <Form.Item label="Công nghệ (cách nhau bằng dấu phẩy)" name="technologies">
            <Input placeholder="React, Node.js, PostgreSQL" />
          </Form.Item>
          <Form.Item label="Kỹ năng yêu cầu (cách nhau bằng dấu phẩy)" name="requiredSkills">
            <Input placeholder="React.js, SQL, Docker" />
          </Form.Item>
        </Form>
      </Modal>

      <Modal
        title="Chỉnh sửa dự án"
        open={editOpen}
        maskClosable={false}
        onCancel={() => {
          setEditOpen(false);
          setEditId(null);
          form.resetFields();
        }}
        onOk={async () => {
          if (!editId) return;
          try {
            const values = await form.validateFields();
            setEditing(true);

            const objectives = values.objectives
              ? String(values.objectives)
                  .split('\n')
                  .map((s: string) => s.trim())
                  .filter(Boolean)
              : undefined;

            await updateProject(editId, {
              name: values.name,
              description: values.description,
              requirements: values.requirements,
              objectives,
              startDate: dayjs(values.startDate).format('YYYY-MM-DD'),
              endDate: dayjs(values.endDate).format('YYYY-MM-DD'),
              budget: Number(values.budget),
              requiredTalents: Number(values.requiredTalents),
              technologies: values.technologies
                ? String(values.technologies)
                    .split(',')
                    .map((s: string) => s.trim())
                    .filter(Boolean)
                : undefined,
              requiredSkills: values.requiredSkills
                ? String(values.requiredSkills)
                    .split(',')
                    .map((s: string) => s.trim())
                    .filter(Boolean)
                : undefined,
              allowApplications: values.allowApplications ?? true,
            });

            message.success('Cập nhật dự án thành công');
            setEditOpen(false);
            setEditId(null);
            form.resetFields();
            await refreshProjects();
          } catch (err: any) {
            if (err?.errorFields) return;
            message.error(err?.message || 'Không thể cập nhật dự án');
          } finally {
            setEditing(false);
          }
        }}
        confirmLoading={editing}
        okText="Lưu"
        cancelText="Hủy"
      >
        <Form form={form} layout="vertical">
          <Form.Item
            label="Tên dự án"
            name="name"
            rules={[{ required: true, message: 'Vui lòng nhập tên dự án' }]}
          >
            <Input />
          </Form.Item>
          <Form.Item
            label="Mô tả"
            name="description"
            rules={[{ required: true, message: 'Vui lòng nhập mô tả' }]}
          >
            <Input.TextArea rows={3} />
          </Form.Item>
          <Form.Item label="Mục tiêu (mỗi dòng một mục)" name="objectives">
            <Input.TextArea rows={3} />
          </Form.Item>
          <Form.Item label="Yêu cầu" name="requirements">
            <Input.TextArea rows={3} />
          </Form.Item>
          <Form.Item label="Thời gian" style={{ marginBottom: 0 }}>
            <Form.Item
              name="startDate"
              rules={[{ required: true, message: 'Chọn ngày bắt đầu' }]}
              style={{ display: 'inline-block', width: 'calc(50% - 8px)' }}
            >
              <DatePicker
                style={{ width: '100%' }}
                getPopupContainer={(trigger) => trigger.parentElement as HTMLElement}
              />
            </Form.Item>
            <Form.Item
              name="endDate"
              dependencies={['startDate']}
              rules={[
                { required: true, message: 'Chọn ngày kết thúc' },
                ({ getFieldValue }) => ({
                  validator(_, value) {
                    const start = getFieldValue('startDate');
                    if (!start || !value) {
                      return Promise.resolve();
                    }
                    if (dayjs(value).isAfter(start, 'day')) {
                      return Promise.resolve();
                    }
                    return Promise.reject(new Error('Ngày kết thúc phải sau ngày bắt đầu'));
                  },
                }),
              ]}
              style={{ display: 'inline-block', width: 'calc(50% - 8px)', marginLeft: 16 }}
            >
              <DatePicker
                style={{ width: '100%' }}
                getPopupContainer={(trigger) => trigger.parentElement as HTMLElement}
                disabledDate={(current) => {
                  const start = form.getFieldValue('startDate');
                  if (!start || !current) return false;
                  return (
                    dayjs(current).isBefore(dayjs(start), 'day') ||
                    dayjs(current).isSame(dayjs(start), 'day')
                  );
                }}
              />
            </Form.Item>
          </Form.Item>
          <Form.Item
            label="Ngân sách (VND)"
            name="budget"
            rules={[{ required: true, message: 'Nhập ngân sách' }]}
          >
            <InputNumber style={{ width: '100%' }} min={0} />
          </Form.Item>
          <Form.Item
            label="Số lượng sinh viên"
            name="requiredTalents"
            rules={[{ required: true, message: 'Nhập số lượng sinh viên' }]}
          >
            <InputNumber style={{ width: '100%' }} min={1} max={50} />
          </Form.Item>
          <Form.Item label="Công nghệ (cách nhau bằng dấu phẩy)" name="technologies">
            <Input />
          </Form.Item>
          <Form.Item label="Kỹ năng yêu cầu (cách nhau bằng dấu phẩy)" name="requiredSkills">
            <Input />
          </Form.Item>
        </Form>
      </Modal>
    </div>
  );
};

export default ProjectManagement;
