// Enterprise Management Page
import { useState, useEffect } from 'react';
import {
  Card,
  Table,
  Tag,
  Button,
  Space,
  Statistic,
  Row,
  Col,
  Input,
  Select,
  Modal,
  Descriptions,
  message,
  Tooltip,
  Badge,
} from 'antd';
import {
  ShopOutlined,
  CheckCircleOutlined,
  ClockCircleOutlined,
  EyeOutlined,
  CheckOutlined,
  CloseOutlined,
  SearchOutlined,
  ReloadOutlined,
} from '@ant-design/icons';
import { enterpriseManagementService, EnterpriseListItem, EnterpriseDetail, EnterpriseStats } from '@/services/admin/enterpriseManagementService';
import styles from './EnterpriseManagement.module.css';

const { TextArea } = Input;

const EnterpriseManagement = () => {
  const [loading, setLoading] = useState(false);
  const [stats, setStats] = useState<EnterpriseStats | null>(null);
  const [enterprises, setEnterprises] = useState<EnterpriseListItem[]>([]);
  const [filteredEnterprises, setFilteredEnterprises] = useState<EnterpriseListItem[]>([]);
  const [searchText, setSearchText] = useState('');
  const [verifiedFilter, setVerifiedFilter] = useState<'all' | 'verified' | 'unverified'>('all');
  
  const [detailModalOpen, setDetailModalOpen] = useState(false);
  const [selectedEnterprise, setSelectedEnterprise] = useState<EnterpriseDetail | null>(null);
  
  const [rejectModalOpen, setRejectModalOpen] = useState(false);
  const [rejectReason, setRejectReason] = useState('');
  const [actionLoading, setActionLoading] = useState(false);

  useEffect(() => {
    loadData();
  }, []);

  useEffect(() => {
    filterEnterprises();
  }, [searchText, verifiedFilter, enterprises]);

  const loadData = async () => {
    setLoading(true);
    try {
      const [statsData, enterprisesData] = await Promise.all([
        enterpriseManagementService.getStats(),
        enterpriseManagementService.getEnterprises(),
      ]);
      setStats(statsData);
      setEnterprises(enterprisesData);
    } catch (error: any) {
      message.error(error.response?.data?.message || 'Failed to load data');
      console.error('Load error:', error);
    } finally {
      setLoading(false);
    }
  };

  const filterEnterprises = () => {
    let filtered = [...enterprises];

    // Verified filter
    if (verifiedFilter === 'verified') {
      filtered = filtered.filter(e => e.verified);
    } else if (verifiedFilter === 'unverified') {
      filtered = filtered.filter(e => !e.verified);
    }

    // Search filter
    if (searchText) {
      const search = searchText.toLowerCase();
      filtered = filtered.filter(e =>
        e.companyName.toLowerCase().includes(search) ||
        e.taxCode.toLowerCase().includes(search) ||
        e.contactEmail.toLowerCase().includes(search)
      );
    }

    setFilteredEnterprises(filtered);
  };

  const handleView = async (id: number) => {
    try {
      const detail = await enterpriseManagementService.getEnterpriseById(id);
      setSelectedEnterprise(detail);
      setDetailModalOpen(true);
    } catch (error: any) {
      message.error('Failed to load enterprise details');
    }
  };

  const handleVerify = async (id: number, companyName: string) => {
    setActionLoading(true);
    try {
      await enterpriseManagementService.verifyEnterprise(id);
      message.success(`Đã xác minh doanh nghiệp "${companyName}"`);
      setDetailModalOpen(false);
      loadData();
    } catch (error: any) {
      message.error(error.response?.data?.message || 'Failed to verify enterprise');
    } finally {
      setActionLoading(false);
    }
  };

  const handleRejectClick = () => {
    setDetailModalOpen(false);
    setRejectModalOpen(true);
  };

  const handleRejectConfirm = async () => {
    if (!selectedEnterprise) return;
    
    setActionLoading(true);
    try {
      await enterpriseManagementService.rejectEnterprise(selectedEnterprise.id, rejectReason);
      message.success(`Đã từ chối doanh nghiệp "${selectedEnterprise.companyName}"`);
      setRejectModalOpen(false);
      setRejectReason('');
      setSelectedEnterprise(null);
      loadData();
    } catch (error: any) {
      message.error(error.response?.data?.message || 'Failed to reject enterprise');
    } finally {
      setActionLoading(false);
    }
  };

  const columns = [
    {
      title: 'ID',
      dataIndex: 'id',
      key: 'id',
      width: 70,
    },
    {
      title: 'Tên công ty',
      dataIndex: 'companyName',
      key: 'companyName',
      width: 250,
      render: (text: string, record: EnterpriseListItem) => (
        <Space direction="vertical" size={0}>
          <strong>{text}</strong>
          <span style={{ fontSize: '12px', color: '#888' }}>{record.taxCode}</span>
        </Space>
      ),
    },
    {
      title: 'Ngành nghề',
      dataIndex: 'industry',
      key: 'industry',
      width: 150,
    },
    {
      title: 'Quy mô',
      dataIndex: 'companySize',
      key: 'companySize',
      width: 120,
    },
    {
      title: 'Liên hệ',
      dataIndex: 'contactEmail',
      key: 'contactEmail',
      width: 200,
      render: (text: string, record: EnterpriseListItem) => (
        <Space direction="vertical" size={0}>
          <span style={{ fontSize: '12px' }}>{text}</span>
          <span style={{ fontSize: '12px', color: '#888' }}>{record.contactPhone}</span>
        </Space>
      ),
    },
    {
      title: 'Dự án',
      key: 'projects',
      width: 120,
      render: (record: EnterpriseListItem) => (
        <Space direction="vertical" size={0}>
          <span>Tổng: <strong>{record.totalProjects}</strong></span>
          <span style={{ fontSize: '12px', color: '#1890ff' }}>
            Hoạt động: {record.activeProjects}
          </span>
        </Space>
      ),
    },
    {
      title: 'Tổng ngân sách',
      dataIndex: 'totalBudget',
      key: 'totalBudget',
      width: 150,
      render: (value: number) => (
        <span>{value.toLocaleString()} VND</span>
      ),
    },
    {
      title: 'Trạng thái',
      dataIndex: 'verified',
      key: 'verified',
      width: 120,
      render: (verified: boolean) => (
        <Tag color={verified ? 'success' : 'warning'} icon={verified ? <CheckCircleOutlined /> : <ClockCircleOutlined />}>
          {verified ? 'Đã xác minh' : 'Chờ xác minh'}
        </Tag>
      ),
    },
    {
      title: 'Ngày tạo',
      dataIndex: 'createdAt',
      key: 'createdAt',
      width: 150,
      render: (date: string) => new Date(date).toLocaleDateString('vi-VN'),
    },
    {
      title: 'Thao tác',
      key: 'actions',
      width: 100,
      fixed: 'right' as const,
      render: (record: EnterpriseListItem) => (
        <Space>
          <Tooltip title="Xem chi tiết">
            <Button
              type="primary"
              icon={<EyeOutlined />}
              size="small"
              onClick={() => handleView(record.id)}
            />
          </Tooltip>
        </Space>
      ),
    },
  ];

  return (
    <div className={styles.container}>
      <div className={styles.header}>
        <h1><ShopOutlined /> Quản lý Doanh nghiệp</h1>
      </div>

      {/* Statistics */}
      <Row gutter={16} style={{ marginBottom: 24 }}>
        <Col span={4}>
          <Card>
            <Statistic
              title="Tổng số"
              value={stats?.total || 0}
              prefix={<ShopOutlined />}
            />
          </Card>
        </Col>
        <Col span={5}>
          <Card>
            <Statistic
              title="Đã xác minh"
              value={stats?.verified || 0}
              valueStyle={{ color: '#3f8600' }}
              prefix={<CheckCircleOutlined />}
            />
          </Card>
        </Col>
        <Col span={5}>
          <Card>
            <Statistic
              title="Chờ xác minh"
              value={stats?.unverified || 0}
              valueStyle={{ color: '#faad14' }}
              prefix={<ClockCircleOutlined />}
            />
          </Card>
        </Col>
        <Col span={5}>
          <Card>
            <Statistic
              title="Hoạt động"
              value={stats?.active || 0}
              valueStyle={{ color: '#1890ff' }}
            />
          </Card>
        </Col>
        <Col span={5}>
          <Card>
            <Statistic
              title="Tháng này"
              value={stats?.thisMonth || 0}
              prefix={<Badge status="processing" />}
            />
          </Card>
        </Col>
      </Row>

      {/* Filters */}
      <Card style={{ marginBottom: 16 }}>
        <Space size="middle" style={{ width: '100%', justifyContent: 'space-between' }}>
          <Space>
            <Input
              placeholder="Tìm kiếm theo tên, mã số thuế, email..."
              prefix={<SearchOutlined />}
              style={{ width: 350 }}
              value={searchText}
              onChange={(e) => setSearchText(e.target.value)}
              allowClear
            />
            <Select
              style={{ width: 180 }}
              value={verifiedFilter}
              onChange={setVerifiedFilter}
            >
              <Select.Option value="all">Tất cả trạng thái</Select.Option>
              <Select.Option value="verified">Đã xác minh</Select.Option>
              <Select.Option value="unverified">Chờ xác minh</Select.Option>
            </Select>
          </Space>
          <Button icon={<ReloadOutlined />} onClick={loadData}>
            Làm mới
          </Button>
        </Space>
      </Card>

      {/* Table */}
      <Card>
        <Table
          columns={columns}
          dataSource={filteredEnterprises}
          rowKey="id"
          loading={loading}
          pagination={{
            pageSize: 10,
            showTotal: (total) => `Tổng ${total} doanh nghiệp`,
            showSizeChanger: true,
          }}
          scroll={{ x: 1500 }}
        />
      </Card>

      {/* Detail Modal */}
      <Modal
        title={<span><ShopOutlined /> Chi tiết Doanh nghiệp</span>}
        open={detailModalOpen}
        onCancel={() => setDetailModalOpen(false)}
        width={900}
        footer={selectedEnterprise && !selectedEnterprise.verified ? [
          <Button key="close" onClick={() => setDetailModalOpen(false)}>
            Đóng
          </Button>,
          <Button
            key="reject"
            danger
            icon={<CloseOutlined />}
            onClick={handleRejectClick}
            loading={actionLoading}
          >
            Từ chối
          </Button>,
          <Button
            key="verify"
            type="primary"
            icon={<CheckOutlined />}
            onClick={() => handleVerify(selectedEnterprise.id, selectedEnterprise.companyName)}
            loading={actionLoading}
          >
            Xác minh
          </Button>,
        ] : [
          <Button key="close" type="primary" onClick={() => setDetailModalOpen(false)}>
            Đóng
          </Button>,
        ]}
      >
        {selectedEnterprise && (
          <Descriptions bordered column={2} size="small">
            <Descriptions.Item label="Trạng thái" span={2}>
              <Tag color={selectedEnterprise.verified ? 'success' : 'warning'}>
                {selectedEnterprise.verified ? 'Đã xác minh' : 'Chờ xác minh'}
              </Tag>
            </Descriptions.Item>
            <Descriptions.Item label="Tên công ty" span={2}>
              <strong>{selectedEnterprise.companyName}</strong>
            </Descriptions.Item>
            <Descriptions.Item label="Mã số thuế">
              {selectedEnterprise.taxCode}
            </Descriptions.Item>
            <Descriptions.Item label="Số GPKD">
              {selectedEnterprise.businessLicenseNumber}
            </Descriptions.Item>
            <Descriptions.Item label="Địa chỉ" span={2}>
              {selectedEnterprise.address}, {selectedEnterprise.ward}, {selectedEnterprise.district}, {selectedEnterprise.city}
            </Descriptions.Item>
            <Descriptions.Item label="Người đại diện">
              {selectedEnterprise.representativeName}
            </Descriptions.Item>
            <Descriptions.Item label="Chức vụ">
              {selectedEnterprise.representativePosition}
            </Descriptions.Item>
            <Descriptions.Item label="Email">
              {selectedEnterprise.contactEmail}
            </Descriptions.Item>
            <Descriptions.Item label="Điện thoại">
              {selectedEnterprise.contactPhone}
            </Descriptions.Item>
            <Descriptions.Item label="Website" span={2}>
              {selectedEnterprise.website ? (
                <a href={selectedEnterprise.website} target="_blank" rel="noopener noreferrer">
                  {selectedEnterprise.website}
                </a>
              ) : 'Chưa cập nhật'}
            </Descriptions.Item>
            <Descriptions.Item label="Ngành nghề">
              {selectedEnterprise.industry}
            </Descriptions.Item>
            <Descriptions.Item label="Quy mô">
              {selectedEnterprise.companySize}
            </Descriptions.Item>
            <Descriptions.Item label="Năm thành lập" span={2}>
              {selectedEnterprise.yearEstablished}
            </Descriptions.Item>
            <Descriptions.Item label="Mô tả" span={2}>
              {selectedEnterprise.description || 'Chưa có mô tả'}
            </Descriptions.Item>
            <Descriptions.Item label="Ngày đăng ký">
              {new Date(selectedEnterprise.createdAt).toLocaleString('vi-VN')}
            </Descriptions.Item>
            <Descriptions.Item label="Cập nhật lần cuối">
              {new Date(selectedEnterprise.updatedAt).toLocaleString('vi-VN')}
            </Descriptions.Item>
            {selectedEnterprise.verified && (
              <Descriptions.Item label="Ngày xác minh" span={2}>
                {selectedEnterprise.verifiedAt ? new Date(selectedEnterprise.verifiedAt).toLocaleString('vi-VN') : 'N/A'}
              </Descriptions.Item>
            )}
          </Descriptions>
        )}
      </Modal>

      {/* Reject Modal */}
      <Modal
        title={<span style={{ color: '#ff4d4f' }}><CloseOutlined /> Từ chối Doanh nghiệp</span>}
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
      >
        <Space direction="vertical" style={{ width: '100%' }} size="large">
          <div>
            <p><strong>Lý do từ chối (tùy chọn):</strong></p>
            <TextArea
              rows={4}
              placeholder="Nhập lý do từ chối để thông báo cho doanh nghiệp..."
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
  );
};

export default EnterpriseManagement;
