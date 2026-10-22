import { useState, useEffect } from 'react';
import {
  Card,
  Row,
  Col,
  Statistic,
  Table,
  Tag,
  Timeline,
  Progress,
  Typography,
  Button,
  Alert,
  Spin,
  Divider,
  Badge,
  Tooltip as AntTooltip,
  Modal,
  Descriptions,
  message,
  Input,
  Space,
} from 'antd';

const { TextArea } = Input;
import { useNavigate } from 'react-router-dom';
import {
  ProjectOutlined,
  ShopOutlined,
  TeamOutlined,
  DollarOutlined,
  RiseOutlined,
  FallOutlined,
  ClockCircleOutlined,
  CheckCircleOutlined,
  CloseCircleOutlined,
  WarningOutlined,
  InfoCircleOutlined,
  ReloadOutlined,
  EyeOutlined,
  FileTextOutlined,
  WalletOutlined,
  TrophyOutlined,
} from '@ant-design/icons';
import {
  LineChart,
  Line,
  BarChart,
  Bar,
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip,
  Legend,
  ResponsiveContainer,
} from 'recharts';
import { dashboardService } from '../../../services/admin/dashboardService';
import type { DashboardStats, RecentActivity, PendingApproval } from '../../../services/admin/dashboardService';
import styles from './AdminDashboard.module.css';

const { Title, Text } = Typography;

export default function AdminDashboard() {
  const navigate = useNavigate();
  const [loading, setLoading] = useState(true);
  const [stats, setStats] = useState<DashboardStats | null>(null);
  const [activities, setActivities] = useState<RecentActivity[]>([]);
  const [pendingApprovals, setPendingApprovals] = useState<PendingApproval[]>([]);
  const [revenueData, setRevenueData] = useState<any[]>([]);
  const [error, setError] = useState<string | null>(null);
  const [detailModalOpen, setDetailModalOpen] = useState(false);
  const [rejectModalOpen, setRejectModalOpen] = useState(false);
  const [selectedApproval, setSelectedApproval] = useState<PendingApproval | null>(null);
  const [rejectReason, setRejectReason] = useState('');
  const [actionLoading, setActionLoading] = useState(false);

  useEffect(() => {
    loadDashboardData();
    // SEO Metadata
    document.title = 'Admin Dashboard | LabODC UTH';
    const metaDescription = document.querySelector('meta[name="description"]');
    if (metaDescription) {
      metaDescription.setAttribute('content', 'Lab Admin Dashboard - Quản trị dự án, doanh nghiệp, sinh viên và quỹ tại LabODC UTH');
    }
  }, []);

  const loadDashboardData = async () => {
    setLoading(true);
    setError(null);
    try {
      const [statsData, activitiesData, approvalsData, chartData] = await Promise.all([
        dashboardService.getStats(),
        dashboardService.getRecentActivities(),
        dashboardService.getPendingApprovals(),
        dashboardService.getRevenueChart(6),
      ]);
      
      console.log('✅ Dashboard data loaded:', { statsData, activitiesData, approvalsData, chartData });
      
      setStats(statsData);
      setActivities(activitiesData);
      setPendingApprovals(approvalsData);
      setRevenueData(chartData);
    } catch (err: any) {
      console.error('❌ Error loading dashboard:', err);
      // Không set error nữa vì service đã có mock data fallback
      // setError(err.response?.data?.message || 'Không thể tải dữ liệu dashboard');
    } finally {
      setLoading(false);
    }
  };

  const formatCurrency = (value: number): string => {
    return new Intl.NumberFormat('vi-VN', {
      style: 'currency',
      currency: 'VND',
    }).format(value);
  };

  const getStatusIcon = (status: string) => {
    switch (status) {
      case 'success':
        return <CheckCircleOutlined style={{ color: '#52c41a' }} />;
      case 'warning':
        return <WarningOutlined style={{ color: '#faad14' }} />;
      case 'error':
        return <ClockCircleOutlined style={{ color: '#f5222d' }} />;
      default:
        return <InfoCircleOutlined style={{ color: '#1890ff' }} />;
    }
  };

  const getPriorityColor = (priority: string) => {
    switch (priority) {
      case 'high':
        return 'red';
      case 'medium':
        return 'orange';
      default:
        return 'blue';
    }
  };

  const getPriorityLabel = (priority: string): string => {
    if (priority === 'high') return 'Cao';
    if (priority === 'medium') return 'TB';
    return 'Thấp';
  };

  const handleViewApproval = (approval: PendingApproval) => {
    setSelectedApproval(approval);
    setDetailModalOpen(true);
  };

  const handleApprove = async () => {
    if (!selectedApproval) return;
    
    setActionLoading(true);
    try {
      if (selectedApproval.type === 'enterprise') {
        await dashboardService.approveEnterprise(selectedApproval.id);
        message.success(`Đã phê duyệt doanh nghiệp "${selectedApproval.companyName}"`);
      } else {
        await dashboardService.approveProject(selectedApproval.id);
        message.success(`Đã phê duyệt dự án "${selectedApproval.title}"`);
      }
      setDetailModalOpen(false);
      loadDashboardData(); // Reload dashboard data
      window.dispatchEvent(new CustomEvent('approvalStatusChanged'));
    } catch (error: any) {
      message.error(error.response?.data?.message || 'Không thể phê duyệt');
      console.error('Approve error:', error);
    } finally {
      setActionLoading(false);
    }
  };

  const handleRejectClick = () => {
    setDetailModalOpen(false);
    setRejectModalOpen(true);
  };

  const handleRejectConfirm = async () => {
    if (!selectedApproval) return;
    
    setActionLoading(true);
    try {
      if (selectedApproval.type === 'enterprise') {
        await dashboardService.rejectEnterprise(selectedApproval.id, rejectReason);
        message.success(`Đã từ chối doanh nghiệp "${selectedApproval.companyName}"`);
      } else {
        await dashboardService.rejectProject(selectedApproval.id, rejectReason);
        message.success(`Đã từ chối dự án "${selectedApproval.title}"`);
      }
      setRejectModalOpen(false);
      setRejectReason('');
      loadDashboardData(); // Reload dashboard data
      window.dispatchEvent(new CustomEvent('approvalStatusChanged'));
    } catch (error: any) {
      message.error(error.response?.data?.message || 'Không thể từ chối');
      console.error('Reject error:', error);
    } finally {
      setActionLoading(false);
    }
  };



  const pendingColumns = [
    {
      title: 'Loại',
      dataIndex: 'type',
      key: 'type',
      render: (type: string) => (
        <Tag color={type === 'enterprise' ? 'blue' : 'green'}>
          {type === 'enterprise' ? 'Doanh nghiệp' : 'Dự án'}
        </Tag>
      ),
    },
    {
      title: 'Tên',
      dataIndex: 'title',
      key: 'title',
      ellipsis: true,
    },
    {
      title: 'Ngày',
      dataIndex: 'submittedAt',
      key: 'submittedAt',
      render: (date: string) => new Date(date).toLocaleDateString('vi-VN'),
      responsive: ['md'] as any,
    },
    {
      title: 'Ưu tiên',
      dataIndex: 'priority',
      key: 'priority',
      render: (priority: string) => (
        <Tag color={getPriorityColor(priority)}>
          {getPriorityLabel(priority)}
        </Tag>
      ),
    },
    {
      title: '',
      key: 'action',
      render: (_: any, record: PendingApproval) => (
        <Button 
          type="link" 
          size="small" 
          icon={<EyeOutlined />}
          onClick={() => handleViewApproval(record)}
        />
      ),
    },
  ];

  if (loading) {
    return (
      <div className={styles.loadingContainer}>
        <Spin size="large" />
      </div>
    );
  }

  if (error) {
    return (
      <div className={styles.errorContainer}>
        <Alert
          message="Lỗi tải dữ liệu"
          description={error}
          type="error"
          showIcon
          action={
            <Button size="small" danger onClick={loadDashboardData} icon={<ReloadOutlined />}>
              Thử lại
            </Button>
          }
        />
      </div>
    );
  }

  if (!stats) return null;

  return (
    <div className={styles.pageWrapper}>
      <div className={styles.dashboardContainer}>
        {/* Header */}
        <div className={styles.header}>
          <div>
            <Title level={2} className={styles.title}>
              Dashboard Quản trị
            </Title>
            <Text type="secondary" className={styles.subtitle}>
              Tổng quan hệ thống LabODC - {new Date().toLocaleString('vi-VN')}
            </Text>
          </div>
          <Button
            type="primary"
            icon={<ReloadOutlined />}
            onClick={loadDashboardData}
            className={styles.refreshBtn}
          >
            Làm mới
          </Button>
        </div>

        <Divider className={styles.divider} />

        {/* Main Stats Cards */}
        <Row gutter={[16, 16]} className={styles.statsRow}>
          <Col xs={24} sm={12} lg={6}>
            <Card className={styles.statCard} hoverable>
              <Statistic
                title={
                  <span className={styles.statTitle}>
                    <ProjectOutlined className={styles.statIcon} />
                    Tổng Dự án
                  </span>
                }
                value={stats.projects.total}
                valueStyle={{ color: '#17a2b8', fontWeight: 600 }}
                suffix={
                  <AntTooltip title={`${stats.projects.new} dự án mới`}>
                    <Badge count={`+${stats.projects.new}`} style={{ backgroundColor: '#52c41a' }} />
                  </AntTooltip>
                }
              />
              <Progress
                percent={stats.projects.successRate}
                size="small"
                strokeColor="#17a2b8"
                className={styles.statProgress}
              />
              <Text type="secondary" className={styles.statLabel}>
                Tỷ lệ thành công: {stats.projects.successRate}%
              </Text>
            </Card>
          </Col>

          <Col xs={24} sm={12} lg={6}>
            <Card className={styles.statCard} hoverable>
              <Statistic
                title={
                  <span className={styles.statTitle}>
                    <ShopOutlined className={styles.statIcon} />
                    Doanh nghiệp
                  </span>
                }
                value={stats.enterprises.total}
                valueStyle={{ color: '#138496', fontWeight: 600 }}
                suffix={
                  <AntTooltip title={`${stats.enterprises.new} DN mới`}>
                    <Badge count={`+${stats.enterprises.new}`} style={{ backgroundColor: '#1890ff' }} />
                  </AntTooltip>
                }
              />
              <div className={styles.statDetails}>
                <Text type="secondary">
                  Hoạt động: <Text strong>{stats.enterprises.active}</Text>
                </Text>
                <Text type="secondary">
                  Xác thực: <Text strong>{stats.enterprises.verified}</Text>
                </Text>
              </div>
            </Card>
          </Col>

          <Col xs={24} sm={12} lg={6}>
            <Card className={styles.statCard} hoverable>
              <Statistic
                title={
                  <span className={styles.statTitle}>
                    <TeamOutlined className={styles.statIcon} />
                    Sinh viên
                  </span>
                }
                value={stats.talents.total}
                valueStyle={{ color: '#0d6efd', fontWeight: 600 }}
                suffix={
                  <AntTooltip title={`${stats.talents.new} SV mới`}>
                    <Badge count={`+${stats.talents.new}`} style={{ backgroundColor: '#722ed1' }} />
                  </AntTooltip>
                }
              />
              <div className={styles.statDetails}>
                <Text type="secondary">
                  Đang học: <Text strong>{stats.talents.active}</Text>
                </Text>
                <Text type="secondary">
                  Đánh giá TB: <Text strong>{stats.talents.averageRating}/10</Text>
                </Text>
              </div>
            </Card>
          </Col>

          <Col xs={24} sm={12} lg={6}>
            <Card className={styles.statCard} hoverable>
              <Statistic
                title={
                  <span className={styles.statTitle}>
                    <DollarOutlined className={styles.statIcon} />
                    Tổng Doanh thu
                  </span>
                }
                value={stats.financials.totalRevenue}
                valueStyle={{ color: '#20c997', fontWeight: 600 }}
                formatter={(value) => formatCurrency(value as number)}
              />
              <div className={styles.statDetails}>
                <Text type="secondary" style={{ fontSize: 12 }}>
                  Lab: {formatCurrency(stats.financials.labRevenue)}
                </Text>
              </div>
            </Card>
          </Col>
        </Row>

        {/* Performance Metrics */}
        <Row gutter={[16, 16]} className={styles.metricsRow}>
          <Col xs={24} md={8}>
            <Card
              title={
                <span>
                  <TrophyOutlined /> Tiến độ Dự án
                </span>
              }
              className={styles.metricCard}
              size="small"
            >
              <Statistic
                title="Hoàn thành trung bình"
                value={stats.performance.avgProjectCompletion}
                suffix="%"
                prefix={
                  stats.performance.avgProjectCompletion >= 75 ? (
                    <RiseOutlined style={{ color: '#52c41a' }} />
                  ) : (
                    <FallOutlined style={{ color: '#f5222d' }} />
                  )
                }
                valueStyle={{
                  color: stats.performance.avgProjectCompletion >= 75 ? '#52c41a' : '#f5222d',
                }}
              />
              <Progress
                percent={stats.performance.avgProjectCompletion}
                strokeColor={{
                  '0%': '#17a2b8',
                  '100%': '#20c997',
                }}
                className={styles.metricProgress}
              />
            </Card>
          </Col>

          <Col xs={24} md={8}>
            <Card
              title={
                <span>
                  <ClockCircleOutlined /> Giao hàng Đúng hạn
                </span>
              }
              className={styles.metricCard}
              size="small"
            >
              <Statistic
                title="Tỷ lệ"
                value={stats.performance.onTimeDelivery}
                suffix="%"
                valueStyle={{ color: '#17a2b8' }}
              />
              <Progress
                percent={stats.performance.onTimeDelivery}
                status="active"
                strokeColor="#17a2b8"
                className={styles.metricProgress}
              />
            </Card>
          </Col>

          <Col xs={24} md={8}>
            <Card
              title={
                <span>
                  <CheckCircleOutlined /> Hài lòng Khách hàng
                </span>
              }
              className={styles.metricCard}
              size="small"
            >
              <Statistic
                title="Đánh giá"
                value={stats.performance.customerSatisfaction}
                suffix="/ 5.0"
                valueStyle={{ color: '#138496' }}
              />
              <Progress
                percent={(stats.performance.customerSatisfaction / 5) * 100}
                strokeColor="#20c997"
                className={styles.metricProgress}
              />
            </Card>
          </Col>
        </Row>

        {/* Charts Section */}
        <Row gutter={[16, 16]} className={styles.chartsRow}>
          <Col xs={24} lg={16}>
            <Card
              title={
                <span>
                  <FileTextOutlined /> Doanh thu 6 tháng gần đây
                </span>
              }
              className={styles.chartCard}
            >
              <ResponsiveContainer width="100%" height={320}>
                <LineChart data={revenueData}>
                  <CartesianGrid strokeDasharray="3 3" stroke="#f0f0f0" />
                  <XAxis
                    dataKey="month"
                    stroke="#8c8c8c"
                    tick={{ fontSize: 12 }}
                  />
                  <YAxis
                    stroke="#8c8c8c"
                    tickFormatter={(value: number) => `${(value / 1000000000).toFixed(1)}B`}
                    tick={{ fontSize: 12 }}
                  />
                  <Tooltip
                    formatter={(value: number | undefined) => {
                      if (value === undefined) return '';
                      return formatCurrency(value);
                    }}
                    contentStyle={{ borderRadius: 8 }}
                  />
                  <Legend wrapperStyle={{ fontSize: 13 }} />
                  <Line
                    type="monotone"
                    dataKey="revenue"
                    stroke="#17a2b8"
                    strokeWidth={3}
                    name="Doanh thu"
                    dot={{ fill: '#17a2b8', r: 4 }}
                    activeDot={{ r: 6 }}
                  />
                </LineChart>
              </ResponsiveContainer>
            </Card>
          </Col>

          <Col xs={24} lg={8}>
            <Card
              title={
                <span>
                  <WalletOutlined /> Phân bổ Quỹ (70/20/10)
                </span>
              }
              className={styles.chartCard}
            >
              <ResponsiveContainer width="100%" height={320}>
                <BarChart
                  data={[
                    {
                      name: 'Team 70%',
                      value: stats.financials.teamDisbursed,
                    },
                    {
                      name: 'Mentor 20%',
                      value: stats.financials.mentorDisbursed,
                    },
                    {
                      name: 'Lab 10%',
                      value: stats.financials.labRevenue,
                    },
                  ]}
                  layout="vertical"
                >
                  <CartesianGrid strokeDasharray="3 3" stroke="#f0f0f0" />
                  <XAxis
                    type="number"
                    tickFormatter={(value: number) => `${(value / 1000000000).toFixed(1)}B`}
                    tick={{ fontSize: 11 }}
                  />
                  <YAxis type="category" dataKey="name" width={90} tick={{ fontSize: 11 }} />
                  <Tooltip
                    formatter={(value: number | undefined) => {
                      if (value === undefined) return '';
                      return formatCurrency(value);
                    }}
                  />
                  <Bar dataKey="value" fill="#17a2b8" radius={[0, 8, 8, 0]} />
                </BarChart>
              </ResponsiveContainer>
            </Card>
          </Col>
        </Row>

        {/* Activities & Approvals */}
        <Row gutter={[16, 16]} className={styles.bottomRow}>
          <Col xs={24} lg={12}>
            <Card
              title={
                <span>
                  <ClockCircleOutlined /> Hoạt động gần đây
                </span>
              }
              className={styles.activityCard}
            >
              <Timeline className={styles.timeline}>
                {activities.slice(0, 8).map((activity) => (
                  <Timeline.Item
                    key={activity.id}
                    dot={getStatusIcon(activity.status)}
                  >
                    <div className={styles.activityItem}>
                      <Text strong className={styles.activityTitle}>
                        {activity.title}
                      </Text>
                      <Text type="secondary" className={styles.activityDesc}>
                        {activity.description}
                      </Text>
                      <Text type="secondary" className={styles.activityTime}>
                        <ClockCircleOutlined /> {activity.timestamp}
                      </Text>
                    </div>
                  </Timeline.Item>
                ))}
              </Timeline>
            </Card>
          </Col>

          <Col xs={24} lg={12}>
            <Card
              title={
                <span>
                  <WarningOutlined /> Chờ phê duyệt ({pendingApprovals.length})
                </span>
              }
              className={styles.approvalCard}
            >
              <Table
                dataSource={pendingApprovals}
                columns={pendingColumns}
                pagination={{ pageSize: 5, size: 'small' }}
                size="small"
                rowKey="id"
                className={styles.approvalTable}
              />
            </Card>
          </Col>
        </Row>

        {/* Approval Detail Modal */}
        <Modal
          title={
            <span>
              <InfoCircleOutlined /> Chi tiết {selectedApproval?.type === 'enterprise' ? 'Doanh nghiệp' : 'Dự án'}
            </span>
          }
          open={detailModalOpen}
          onCancel={() => setDetailModalOpen(false)}
          width={800}
          footer={[
            <Button key="close" onClick={() => setDetailModalOpen(false)}>
              Đóng
            </Button>,
            <Button 
              key="reject" 
              danger 
              icon={<CloseCircleOutlined />}
              onClick={handleRejectClick}
              loading={actionLoading}
            >
              Từ chối
            </Button>,
            <Button 
              key="approve" 
              type="primary" 
              icon={<CheckCircleOutlined />}
              onClick={handleApprove}
              loading={actionLoading}
            >
              Phê duyệt
            </Button>,
          ]}
        >
          {selectedApproval && selectedApproval.type === 'enterprise' && (
            <Descriptions bordered column={2} size="small">
              <Descriptions.Item label="Loại" span={2}>
                <Tag color="blue">Doanh nghiệp</Tag>
              </Descriptions.Item>
              <Descriptions.Item label="Tên công ty" span={2}>
                <Text strong>{selectedApproval.companyName}</Text>
              </Descriptions.Item>
              <Descriptions.Item label="Mã số thuế">
                {selectedApproval.taxCode}
              </Descriptions.Item>
              <Descriptions.Item label="Số GPKD">
                {selectedApproval.businessLicenseNumber || 'Chưa cập nhật'}
              </Descriptions.Item>
              <Descriptions.Item label="Người đại diện">
                {selectedApproval.representativeName}
              </Descriptions.Item>
              <Descriptions.Item label="Chức vụ">
                {selectedApproval.representativePosition || 'Chưa cập nhật'}
              </Descriptions.Item>
              <Descriptions.Item label="Email liên hệ">
                {selectedApproval.contactEmail}
              </Descriptions.Item>
              <Descriptions.Item label="Số điện thoại">
                {selectedApproval.contactPhone}
              </Descriptions.Item>
              <Descriptions.Item label="Ngành nghề">
                {selectedApproval.industry || 'Chưa cập nhật'}
              </Descriptions.Item>
              <Descriptions.Item label="Quy mô">
                {selectedApproval.companySize || 'Chưa cập nhật'}
              </Descriptions.Item>
              <Descriptions.Item label="Năm thành lập">
                {selectedApproval.yearEstablished || 'Chưa cập nhật'}
              </Descriptions.Item>
              <Descriptions.Item label="Website">
                {selectedApproval.website ? (
                  <a href={selectedApproval.website} target="_blank" rel="noopener noreferrer">
                    {selectedApproval.website}
                  </a>
                ) : 'Chưa cập nhật'}
              </Descriptions.Item>
              <Descriptions.Item label="Địa chỉ" span={2}>
                {[
                  selectedApproval.address,
                  selectedApproval.ward,
                  selectedApproval.district,
                  selectedApproval.city
                ].filter(Boolean).join(', ') || 'Chưa cập nhật'}
              </Descriptions.Item>
              <Descriptions.Item label="Mô tả" span={2}>
                {selectedApproval.description || 'Chưa có mô tả'}
              </Descriptions.Item>
              <Descriptions.Item label="Ngày nộp" span={1}>
                {new Date(selectedApproval.submittedAt).toLocaleString('vi-VN')}
              </Descriptions.Item>
              <Descriptions.Item label="Mức độ ưu tiên" span={1}>
                <Tag color={getPriorityColor(selectedApproval.priority)}>
                  {getPriorityLabel(selectedApproval.priority)}
                </Tag>
              </Descriptions.Item>
            </Descriptions>
          )}
          
          {selectedApproval && selectedApproval.type === 'project' && (
            <Descriptions bordered column={2} size="small">
              <Descriptions.Item label="Loại" span={2}>
                <Tag color="green">Dự án</Tag>
              </Descriptions.Item>
              <Descriptions.Item label="Tên dự án" span={2}>
                <Text strong>{selectedApproval.title}</Text>
              </Descriptions.Item>
              <Descriptions.Item label="Doanh nghiệp" span={2}>
                <Text>{selectedApproval.enterpriseName}</Text>
              </Descriptions.Item>
              <Descriptions.Item label="Ngày bắt đầu">
                {selectedApproval.startDate ? new Date(selectedApproval.startDate).toLocaleDateString('vi-VN') : 'Chưa xác định'}
              </Descriptions.Item>
              <Descriptions.Item label="Ngày kết thúc">
                {selectedApproval.endDate ? new Date(selectedApproval.endDate).toLocaleDateString('vi-VN') : 'Chưa xác định'}
              </Descriptions.Item>
              <Descriptions.Item label="Ngân sách">
                {selectedApproval.budget ? new Intl.NumberFormat('vi-VN', {
                  style: 'currency',
                  currency: selectedApproval.currency || 'VND'
                }).format(selectedApproval.budget) : 'Chưa cập nhật'}
              </Descriptions.Item>
              <Descriptions.Item label="Số sinh viên">
                {selectedApproval.numberOfStudents || 'Chưa xác định'}
              </Descriptions.Item>
              <Descriptions.Item label="Trạng thái" span={2}>
                <Tag color="orange">{selectedApproval.status || 'PENDING'}</Tag>
              </Descriptions.Item>
              <Descriptions.Item label="Mô tả" span={2}>
                {selectedApproval.description || 'Chưa có mô tả'}
              </Descriptions.Item>
              <Descriptions.Item label="Yêu cầu" span={2}>
                {selectedApproval.requirements || 'Chưa có yêu cầu cụ thể'}
              </Descriptions.Item>
              <Descriptions.Item label="Ngày nộp" span={1}>
                {new Date(selectedApproval.submittedAt).toLocaleString('vi-VN')}
              </Descriptions.Item>
              <Descriptions.Item label="Mức độ ưu tiên" span={1}>
                <Tag color={getPriorityColor(selectedApproval.priority)}>
                  {getPriorityLabel(selectedApproval.priority)}
                </Tag>
              </Descriptions.Item>
            </Descriptions>
          )}
        </Modal>

        {/* Reject Modal */}
        <Modal
          title={
            <span style={{ color: '#ff4d4f' }}>
              <CloseCircleOutlined /> Từ chối {selectedApproval?.type === 'enterprise' ? 'doanh nghiệp' : 'dự án'}
            </span>
          }
          open={rejectModalOpen}
          onCancel={() => {
            setRejectModalOpen(false);
            setRejectReason('');
          }}
          onOk={handleRejectConfirm}
          okText="Xác nhận từ chối"
          cancelText="Hủy"
          okButtonProps={{ danger: true, loading: actionLoading }}
          cancelButtonProps={{ disabled: actionLoading }}
          width={600}
          closable={!actionLoading}
          maskClosable={!actionLoading}
        >
          <Space direction="vertical" style={{ width: '100%' }} size="large">
            <Alert
              message="Cảnh báo"
              description={
                selectedApproval?.type === 'enterprise'
                  ? 'Bạn đang từ chối yêu cầu xác minh doanh nghiệp. Hành động này không thể hoàn tác.'
                  : 'Bạn đang từ chối yêu cầu xác thực dự án. Hành động này không thể hoàn tác.'
              }
              type="warning"
              showIcon
            />
            <div>
              <Typography.Text strong>Lý do từ chối (tùy chọn):</Typography.Text>
              <TextArea
                rows={4}
                placeholder="Nhập lý do từ chối để thông báo cho người dùng..."
                value={rejectReason}
                onChange={(e) => setRejectReason(e.target.value)}
                disabled={actionLoading}
                maxLength={500}
                showCount
              />
            </div>
          </Space>
        </Modal>
      </div>
    </div>
  );
}
