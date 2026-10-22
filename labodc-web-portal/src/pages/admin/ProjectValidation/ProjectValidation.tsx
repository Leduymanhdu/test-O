import React, { useState, useEffect } from 'react';
import {
  Card,
  Table,
  Tag,
  Button,
  Space,
  Input,
  Modal,
  Typography,
  Descriptions,
  message,
  Tabs,
  Badge,
  Drawer,
  Alert,
  Select,
  Row,
  Col,
  Statistic,
  Progress,
  List,
  Avatar,
  InputNumber
} from 'antd';
import {
  SearchOutlined,
  CheckCircleOutlined,
  CloseCircleOutlined,
  EyeOutlined,
  ProjectOutlined,
  FileTextOutlined,
  TeamOutlined,
  DollarOutlined,
  CalendarOutlined,
  UserAddOutlined,
  TrophyOutlined
} from '@ant-design/icons';
import type { ColumnsType } from 'antd/es/table';
import { projectService } from "@/services/admin/projectService";
import type { Project, ProjectDetail, Mentor } from '@/services/admin/projectService';

const { Title, Text, Paragraph } = Typography;
const { TextArea } = Input;

export default function ProjectValidation() {
  const [loading, setLoading] = useState(false);
  const [projects, setProjects] = useState<Project[]>([]);
  const [selectedProject, setSelectedProject] = useState<ProjectDetail | null>(null);
  const [detailVisible, setDetailVisible] = useState(false);
  const [approveModalVisible, setApproveModalVisible] = useState(false);
  const [rejectModalVisible, setRejectModalVisible] = useState(false);
  const [mentorModalVisible, setMentorModalVisible] = useState(false);
  const [activeTab, setActiveTab] = useState<string>('PENDING');
  const [searchText, setSearchText] = useState('');
  const [pagination, setPagination] = useState({ current: 1, pageSize: 10, total: 0 });
  const [statistics, setStatistics] = useState<Record<string, number>>({});

  // Available mentors
  const [mentors, setMentors] = useState<Mentor[]>([]);
  const [selectedMentor, setSelectedMentor] = useState<number | null>(null);

  // Form states
  const [approveNote, setApproveNote] = useState('');
  const [adjustStudents, setAdjustStudents] = useState<number | undefined>();
  const [adjustDuration, setAdjustDuration] = useState('');
  const [rejectReason, setRejectReason] = useState('');
  const [rejectDetails, setRejectDetails] = useState('');
  const [mentorMessage, setMentorMessage] = useState('');

  useEffect(() => {
    loadStatistics();
  }, []);

  useEffect(() => {
    loadProjects();
  }, [activeTab, pagination.current, searchText]);

  const loadStatistics = async () => {
    try {
      const stats = await projectService.getValidationStats();
      setStatistics(stats);
    } catch (error: any) {
      console.error('Failed to load statistics:', error);
    }
  };

  const loadProjects = async () => {
    setLoading(true);
    try {
      const response = await projectService.getProjects({
        status: activeTab,
        page: pagination.current,
        limit: pagination.pageSize,
        search: searchText
      });
      setProjects(response.projects);
      setPagination(prev => ({ ...prev, total: response.pagination.total }));
    } catch (error: any) {
      message.error(error.response?.data?.message || 'Không thể tải danh sách dự án');
    } finally {
      setLoading(false);
    }
  };

  const handleViewDetail = async (id: number) => {
    try {
      const detail = await projectService.getProjectById(id);
      console.log('Project detail loaded:', detail);
      console.log('Validated status:', detail.validated);
      setSelectedProject(detail);
      setDetailVisible(true);
    } catch (error: any) {
      message.error('Không thể tải chi tiết dự án');
    }
  };

  const handleApprove = async () => {
    if (!selectedProject) {
      message.warning('Không tìm thấy dự án');
      return;
    }
    
    try {
      await projectService.approveProject(selectedProject.id, {
        note: approveNote,
        adjustments: adjustStudents || adjustDuration ? {
          numberOfStudents: adjustStudents,
          duration: adjustDuration
        } : undefined
      });
      message.success('Đã phê duyệt dự án thành công');
      setApproveModalVisible(false);
      setDetailVisible(false);
      resetApproveForms();
      loadProjects();
    } catch (error: any) {
      message.error(error.response?.data?.message || 'Không thể phê duyệt dự án');
    }
  };

  const handleReject = async () => {
    if (!selectedProject || !rejectReason || !rejectDetails.trim()) {
      message.warning('Vui lòng điền đầy đủ thông tin');
      return;
    }
    
    try {
      await projectService.rejectProject(selectedProject.id, {
        reason: rejectReason,
        details: rejectDetails
      });
      message.success('Đã từ chối dự án');
      setRejectModalVisible(false);
      setDetailVisible(false);
      resetRejectForms();
      loadProjects();
    } catch (error: any) {
      message.error(error.response?.data?.message || 'Không thể từ chối dự án');
    }
  };

  const handleShowMentorModal = async () => {
    if (!selectedProject) return;
    
    try {
      const mentorsList = await projectService.getAvailableMentors(selectedProject.technologies);
      setMentors(mentorsList);
      setMentorModalVisible(true);
    } catch (error: any) {
      message.error('Không thể tải danh sách mentor');
    }
  };

  const handleAssignMentor = async () => {
    if (!selectedProject || !selectedMentor || !mentorMessage.trim()) {
      message.warning('Vui lòng chọn mentor và nhập lời nhắn');
      return;
    }
    
    try {
      await projectService.assignMentor(selectedProject.id, {
        mentorId: selectedMentor,
        message: mentorMessage
      });
      message.success('Đã gửi lời mời đến mentor');
      setMentorModalVisible(false);
      resetMentorForms();
      loadProjects();
    } catch (error: any) {
      message.error(error.response?.data?.message || 'Không thể gán mentor');
    }
  };

  const resetApproveForms = () => {
    setApproveNote('');
    setAdjustStudents(undefined);
    setAdjustDuration('');
  };

  const resetRejectForms = () => {
    setRejectReason('');
    setRejectDetails('');
  };

  const resetMentorForms = () => {
    setSelectedMentor(null);
    setMentorMessage('');
  };

  const formatCurrency = (value: number) => {
    return new Intl.NumberFormat('vi-VN', { style: 'currency', currency: 'VND' }).format(value);
  };

  const getStatusTag = (status: string) => {
    if (!status) return <Tag color="default">Không xác định</Tag>;
    
    // Normalize status to uppercase for matching
    const normalizedStatus = status.toUpperCase();
    
    const statusMap: Record<string, { color: string; text: string }> = {
      // Validation statuses
      PENDING_VALIDATION: { color: 'processing', text: 'Chờ xác thực' },
      PENDING: { color: 'processing', text: 'Chờ xác thực' },
      VALIDATED: { color: 'success', text: 'Đã phê duyệt' },
      APPROVED: { color: 'success', text: 'Đã phê duyệt' },
      REJECTED: { color: 'error', text: 'Đã từ chối' },
      // Project lifecycle statuses
      RECRUITING: { color: 'cyan', text: 'Đang tuyển' },
      IN_PROGRESS: { color: 'blue', text: 'Đang thực hiện' },
      INPROGRESS: { color: 'blue', text: 'Đang thực hiện' },
      COMPLETED: { color: 'green', text: 'Hoàn thành' },
      CANCELLED: { color: 'error', text: 'Đã hủy' },
      CANCELED: { color: 'error', text: 'Đã hủy' }
    };
    
    const config = statusMap[normalizedStatus] || { color: 'default', text: status };
    return <Tag color={config.color}>{config.text}</Tag>;
  };

  const columns: ColumnsType<Project> = [
    {
      title: 'Dự án',
      dataIndex: 'title',
      key: 'title',
      render: (text, record) => (
        <div>
          <Text strong>{text}</Text>
          <br />
          <Text type="secondary" style={{ fontSize: 12 }}>
            Enterprise ID: {record.enterpriseId}
          </Text>
        </div>
      ),
    },
    {
      title: 'Mô tả',
      dataIndex: 'description',
      key: 'description',
      width: 250,
      ellipsis: true,
    },
    {
      title: 'Ngân sách',
      dataIndex: 'budget',
      key: 'budget',
      width: 150,
      render: (budget) => formatCurrency(budget),
    },
    {
      title: 'Thời gian',
      key: 'duration',
      width: 200,
      render: (_, record) => (
        <div>
          <div>{new Date(record.startDate).toLocaleDateString('vi-VN')}</div>
          <div>đến {new Date(record.endDate).toLocaleDateString('vi-VN')}</div>
        </div>
      ),
    },
    {
      title: 'SV cần',
      dataIndex: 'numberOfStudents',
      key: 'numberOfStudents',
      width: 80,
      align: 'center',
    },
    {
      title: 'Tiến độ',
      dataIndex: 'progressPercentage',
      key: 'progressPercentage',
      width: 100,
      render: (progress) => `${progress}%`,
    },
    {
      title: 'Ngày tạo',
      dataIndex: 'createdAt',
      key: 'createdAt',
      width: 160,
      render: (date) => new Date(date).toLocaleString('vi-VN'),
    },
    {
      title: 'Trạng thái',
      dataIndex: 'status',
      key: 'status',
      width: 130,
      render: (status) => getStatusTag(status),
    },
    {
      title: 'Hành động',
      key: 'action',
      width: 120,
      fixed: 'right',
      render: (_, record) => (
        <Button type="link" icon={<EyeOutlined />} onClick={() => handleViewDetail(record.id)}>
          Chi tiết
        </Button>
      ),
    },
  ];

  return (
    <div style={{ padding: '24px' }}>
      <Title level={2}>
        <ProjectOutlined /> Xác thực Dự án
      </Title>

      <Card>
        <Space direction="vertical" style={{ width: '100%' }} size="large">
          <Input.Search
            placeholder="Tìm kiếm dự án..."
            allowClear
            enterButton={<SearchOutlined />}
            size="large"
            onSearch={setSearchText}
            style={{ maxWidth: 500 }}
          />

          <Tabs
            activeKey={activeTab}
            onChange={(key) => {
              setActiveTab(key);
              setPagination(prev => ({ ...prev, current: 1 }));
            }}
            items={[
              { 
                key: 'PENDING', 
                label: <Badge count={statistics.pending || 0} offset={[10, 0]}><span>Chờ xác thực</span></Badge> 
              },
              { 
                key: 'APPROVED', 
                label: <Badge count={statistics.approved || 0} showZero={false} offset={[10, 0]}><span>Đã phê duyệt</span></Badge> 
              },
              { 
                key: 'REJECTED', 
                label: <Badge count={statistics.rejected || 0} showZero={false} offset={[10, 0]}><span>Đã từ chối</span></Badge> 
              },
              { 
                key: 'RECRUITING', 
                label: <Badge count={statistics.recruiting || 0} showZero={false} offset={[10, 0]}><span>Đang tuyển</span></Badge> 
              },
              { 
                key: 'IN_PROGRESS', 
                label: <Badge count={statistics.inProgress || 0} showZero={false} offset={[10, 0]}><span>Đang thực hiện</span></Badge> 
              }
            ]}
          />

          <Table
            columns={columns}
            dataSource={projects}
            rowKey="id"
            loading={loading}
            pagination={{
              ...pagination,
              onChange: (page, pageSize) => {
                setPagination(prev => ({ ...prev, current: page, pageSize }));
              },
              showSizeChanger: true,
              showTotal: (total) => `Tổng ${total} dự án`,
            }}
            scroll={{ x: 1400 }}
          />
        </Space>
      </Card>

      {/* Detail Drawer */}
      <Drawer
        title="Chi tiết Dự án"
        placement="right"
        width={800}
        open={detailVisible}
        onClose={() => setDetailVisible(false)}
      >
        {selectedProject && (
          <Space direction="vertical" style={{ width: '100%' }} size="large">
            {/* Overview Stats */}
            <Row gutter={16}>
              <Col span={8}>
                <Card size="small">
                  <Statistic
                    title="Ngân sách"
                    value={selectedProject.budget}
                    prefix={<DollarOutlined />}
                    formatter={(val) => formatCurrency(val as number)}
                    valueStyle={{ fontSize: 18 }}
                  />
                </Card>
              </Col>
              <Col span={8}>
                <Card size="small">
                  <Statistic
                    title="Thời gian"
                    value={`${new Date(selectedProject.startDate).toLocaleDateString('vi-VN')} - ${new Date(selectedProject.endDate).toLocaleDateString('vi-VN')}`}
                    prefix={<CalendarOutlined />}
                    valueStyle={{ fontSize: 14 }}
                  />
                </Card>
              </Col>
              <Col span={8}>
                <Card size="small">
                  <Statistic
                    title="Sinh viên"
                    value={selectedProject.numberOfStudents}
                    prefix={<TeamOutlined />}
                    suffix="người"
                    valueStyle={{ fontSize: 18 }}
                  />
                </Card>
              </Col>
            </Row>

            <Descriptions title="Thông tin dự án" column={1} bordered>
              <Descriptions.Item label="Tên dự án"><Text strong>{selectedProject.title}</Text></Descriptions.Item>
              <Descriptions.Item label="Enterprise ID">{selectedProject.enterpriseId}</Descriptions.Item>
              <Descriptions.Item label="Mô tả">
                <Paragraph>{selectedProject.description}</Paragraph>
              </Descriptions.Item>
              {selectedProject.objectives && (
                <Descriptions.Item label="Mục tiêu">
                  <Paragraph>{selectedProject.objectives}</Paragraph>
                </Descriptions.Item>
              )}
              {selectedProject.requirements && (
                <Descriptions.Item label="Yêu cầu">
                  <Paragraph>{selectedProject.requirements}</Paragraph>
                </Descriptions.Item>
              )}
              {selectedProject.technologies && selectedProject.technologies.length > 0 && (
                <Descriptions.Item label="Công nghệ">
                  {selectedProject.technologies.map((tech: string) => <Tag key={tech} color="blue">{tech}</Tag>)}
                </Descriptions.Item>
              )}
              {selectedProject.requiredSkills && selectedProject.requiredSkills.length > 0 && (
                <Descriptions.Item label="Kỹ năng yêu cầu">
                  {selectedProject.requiredSkills.map((skill: string) => <Tag key={skill} color="green">{skill}</Tag>)}
                </Descriptions.Item>
              )}
              <Descriptions.Item label="Trạng thái">{getStatusTag(selectedProject.status)}</Descriptions.Item>
              <Descriptions.Item label="Validation">
                <Tag color={selectedProject.validated === 'approved' ? 'green' : selectedProject.validated === 'rejected' ? 'red' : 'orange'}>
                  {selectedProject.validated === 'approved' ? 'Đã phê duyệt' : selectedProject.validated === 'rejected' ? 'Đã từ chối' : 'Chờ xác thực'}
                </Tag>
              </Descriptions.Item>
              <Descriptions.Item label="Tiến độ">
                <Progress percent={selectedProject.progressPercentage} />
              </Descriptions.Item>
              <Descriptions.Item label="Ngày tạo">
                {new Date(selectedProject.createdAt).toLocaleString('vi-VN')}
              </Descriptions.Item>
              {selectedProject.updatedAt && (
                <Descriptions.Item label="Cập nhật">
                  {new Date(selectedProject.updatedAt).toLocaleString('vi-VN')}
                </Descriptions.Item>
              )}
              {/* Action Buttons for Pending Projects */}
            {(selectedProject.validated === 'pending' || !selectedProject.validated) && (
              <Card size="small" style={{ background: '#f0f2f5' }}>
                <Space style={{ width: '100%', justifyContent: 'center' }}>
                  <Button 
                    type="primary" 
                    size="large"
                    icon={<CheckCircleOutlined />} 
                    onClick={() => setApproveModalVisible(true)}
                  >
                    Phê duyệt
                  </Button>
                  <Button 
                    danger 
                    size="large"
                    icon={<CloseCircleOutlined />} 
                    onClick={() => setRejectModalVisible(true)}
                  >
                    Từ chối
                  </Button>
                </Space>
              </Card>
            )}

            {(selectedProject.validated === 'approved' &&
              (selectedProject.status === 'RECRUITING' || selectedProject.status === 'VALIDATED' || selectedProject.status === 'PENDING_VALIDATION') &&
              !selectedProject.mentorId) && (
              <Card size="small" style={{ background: '#f0f2f5' }}>
                <Space style={{ width: '100%', justifyContent: 'center' }}>
                  <Button
                    type="primary"
                    size="large"
                    icon={<UserAddOutlined />}
                    onClick={handleShowMentorModal}
                  >
                    Gán Mentor
                  </Button>
                </Space>
              </Card>
            )}
            </Descriptions>

            {/* Attachments */}
            {selectedProject.attachments && selectedProject.attachments.length > 0 && (
              <Card title="Tài liệu đính kèm" size="small">
                {selectedProject.attachments.map((file: string, idx: number) => (
                  <Button key={idx} icon={<FileTextOutlined />} href={file} target="_blank" block style={{ marginBottom: 8 }}>
                    File {idx + 1}
                  </Button>
                ))}
              </Card>
            )}

            {/* Rejection Reason if rejected */}
            {selectedProject.validated === 'rejected' && selectedProject.rejectionReason && (
              <Alert
                type="error"
                message="Lý do từ chối"
                description={selectedProject.rejectionReason}
                showIcon
              />
            )}
          </Space>
        )}
      </Drawer>

      {/* Approve Modal */}
      <Modal
        title="Phê duyệt Dự án"
        open={approveModalVisible}
        onCancel={() => { setApproveModalVisible(false); resetApproveForms(); }}
        onOk={handleApprove}
        width={600}
      >
        <Space direction="vertical" style={{ width: '100%' }} size="middle">
          <Alert
            message="Xác nhận phê duyệt"
            description={`Phê duyệt dự án "${selectedProject?.title}"?`}
            type="info"
            showIcon
          />
        </Space>
      </Modal>

      {/* Reject Modal */}
      <Modal
        title="Từ chối Dự án"
        open={rejectModalVisible}
        onCancel={() => { setRejectModalVisible(false); resetRejectForms(); }}
        onOk={handleReject}
        okText="Từ chối"
        okButtonProps={{ danger: true }}
      >
        <Space direction="vertical" style={{ width: '100%' }} size="middle">
          <Alert message="Xác nhận từ chối" description={`Từ chối dự án "${selectedProject?.title}"?`} type="warning" showIcon />
          
          <div>
            <div style={{ marginBottom: 8 }}>Lý do *</div>
            <Select value={rejectReason} onChange={setRejectReason} style={{ width: '100%' }} placeholder="Chọn lý do">
              <Select.Option value="unrealistic_scope">Phạm vi không khả thi</Select.Option>
              <Select.Option value="insufficient_budget">Ngân sách không đủ</Select.Option>
              <Select.Option value="too_complex">Quá phức tạp cho sinh viên</Select.Option>
              <Select.Option value="unclear_requirements">Yêu cầu không rõ ràng</Select.Option>
              <Select.Option value="other">Lý do khác</Select.Option>
            </Select>
          </div>

          <div>
            <div style={{ marginBottom: 8 }}>Chi tiết *</div>
            <TextArea rows={4} value={rejectDetails} onChange={(e) => setRejectDetails(e.target.value)} placeholder="Mô tả chi tiết..." />
          </div>
        </Space>
      </Modal>

      {/* Assign Mentor Modal */}
      <Modal
        title="Gán Mentor cho Dự án"
        open={mentorModalVisible}
        onCancel={() => { setMentorModalVisible(false); resetMentorForms(); }}
        onOk={handleAssignMentor}
        width={700}
      >
        <Space direction="vertical" style={{ width: '100%' }} size="middle">
          <div>
            <div style={{ marginBottom: 8 }}>Chọn Mentor *</div>
            <List
              dataSource={mentors}
              renderItem={(mentor) => (
                <List.Item
                  onClick={() => setSelectedMentor(mentor.id)}
                  style={{
                    cursor: 'pointer',
                    border: selectedMentor === mentor.id ? '2px solid #1890ff' : '1px solid #f0f0f0',
                    padding: 12,
                    marginBottom: 8,
                    borderRadius: 4
                  }}
                >
                  <List.Item.Meta
                    avatar={<Avatar icon={<TrophyOutlined />} />}
                    title={
                      <Space>
                        <Text strong>{mentor.fullName}</Text>
                        <Tag color="blue">{mentor.yearsOfExperience} năm kinh nghiệm</Tag>
                        {!mentor.available && <Tag color="red">Đầy dự án</Tag>}
                      </Space>
                    }
                    description={
                      <Space direction="vertical" style={{ width: '100%' }}>
                        <div>
                          <Text type="secondary">Chuyên môn: </Text>
                          {mentor.expertise.map(exp => <Tag key={exp}>{exp}</Tag>)}
                        </div>
                        <div>
                          <Text type="secondary">Dự án: {mentor.currentProjects}/{mentor.maxProjects} | Đánh giá: {mentor.averageRating}/5.0</Text>
                        </div>
                      </Space>
                    }
                  />
                </List.Item>
              )}
            />
          </div>

          <div>
            <div style={{ marginBottom: 8 }}>Lời nhắn cho Mentor *</div>
            <TextArea
              rows={4}
              value={mentorMessage}
              onChange={(e) => setMentorMessage(e.target.value)}
              placeholder="Dự án ReactJS + NodeJS phù hợp với expertise của mentor..."
            />
          </div>
        </Space>
      </Modal>
    </div>
  );
}
