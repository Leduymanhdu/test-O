// Enterprise Management Page
import React, { useState, useEffect } from 'react';
import {
  Card,
  Table,
  Tag,
  Button,
  Input,
  Space,
  Modal,
  Form,
  Select,
  Typography,
  Descriptions,
  message,
  Tabs,
  Row,
  Col,
  Statistic,
} from 'antd';
import {
  SearchOutlined,
  CheckCircleOutlined,
  CloseCircleOutlined,
  ExclamationCircleOutlined,
  EyeOutlined,
  ShopOutlined,
  PhoneOutlined,
  MailOutlined,
  GlobalOutlined,
  EnvironmentOutlined,
} from '@ant-design/icons';
import type { ColumnsType } from 'antd/es/table';
import { enterpriseManagementService } from '@/services/admin/enterpriseManagementService';
import type { EnterpriseListItem, EnterpriseDetail } from '@/services/admin/enterpriseManagementService';
import styles from './EnterpriseManagement.module.css';

const { Title, Text, Paragraph } = Typography;
const { TextArea } = Input;
const { TabPane } = Tabs;

const EnterpriseManagement: React.FC = () => {
  const [loading, setLoading] = useState(false);
  const [enterprises, setEnterprises] = useState<EnterpriseListItem[]>([]);
  const [selectedEnterprise, setSelectedEnterprise] = useState<EnterpriseDetail | null>(null);
  const [detailModalVisible, setDetailModalVisible] = useState(false);
  const [approveModalVisible, setApproveModalVisible] = useState(false);
  const [rejectModalVisible, setRejectModalVisible] = useState(false);
  const [searchText, setSearchText] = useState('');
  const [statusFilter, setStatusFilter] = useState<'ALL' | 'PENDING' | 'APPROVED' | 'REJECTED'>('ALL');
  const [statsData, setStatsData] = useState({
    total: 0,
    pending: 0,
    approved: 0,
    rejected: 0,
  });

  const [approveForm] = Form.useForm();
  const [rejectForm] = Form.useForm();

  useEffect(() => {
    fetchEnterprises();
  }, [statusFilter, searchText]);

  const fetchEnterprises = async () => {
    try {
      setLoading(true);
      const params: any = {};
      
      // Send status param for filtering
      if (statusFilter !== 'ALL') {
        params.status = statusFilter; // PENDING, APPROVED, or REJECTED
      }
      
      if (searchText && searchText.trim()) {
        params.search = searchText.trim();
      }

      console.log('[EnterpriseManagement] Fetching enterprises with params:', params);
      const response = await enterpriseManagementService.getEnterprises(params);
      console.log('[EnterpriseManagement] Response:', response);
      setEnterprises(response.enterprises);

      // Calculate stats from status field
      const all = response.enterprises;
      setStatsData({
        total: response.pagination.total,
        pending: all.filter(e => e.status === 'PENDING').length,
        approved: all.filter(e => e.status === 'APPROVED').length,
        rejected: all.filter(e => e.status === 'REJECTED').length,
      });
    } catch (error: any) {
      console.error('[EnterpriseManagement] Error fetching enterprises:', {
        error,
        message: error.message,
        response: error.response,
        status: error.response?.status,
        data: error.response?.data
      });
      message.error(`Không thể tải danh sách doanh nghiệp: ${error.response?.data?.message || error.message}`);
    } finally {
      setLoading(false);
    }
  };

  const handleViewDetail = async (id: number) => {
    try {
      setLoading(true);
      const detail = await enterpriseManagementService.getEnterpriseById(id);
      setSelectedEnterprise(detail);
      setDetailModalVisible(true);
    } catch (error) {
      message.error('Không thể tải chi tiết doanh nghiệp');
    } finally {
      setLoading(false);
    }
  };

  const handleApprove = async () => {
    if (!selectedEnterprise) return;

    try {
      await enterpriseManagementService.verifyEnterprise(selectedEnterprise.id);
      message.success('Đã phê duyệt doanh nghiệp thành công');
      setApproveModalVisible(false);
      setDetailModalVisible(false);
      approveForm.resetFields();
      fetchEnterprises();
    } catch (error) {
      message.error('Không thể phê duyệt doanh nghiệp');
    }
  };

  const handleReject = async (values: any) => {
    if (!selectedEnterprise) return;

    try {
      await enterpriseManagementService.rejectEnterprise(selectedEnterprise.id, values.reason);
      message.success('Đã từ chối doanh nghiệp');
      setRejectModalVisible(false);
      setDetailModalVisible(false);
      rejectForm.resetFields();
      fetchEnterprises();
    } catch (error) {
      message.error('Không thể từ chối doanh nghiệp');
    }
  };

  const getStatusTag = (status: 'PENDING' | 'APPROVED' | 'REJECTED') => {
    switch (status) {
      case 'PENDING':
        return <Tag icon={<ExclamationCircleOutlined />} color="warning">Chờ xác thực</Tag>;
      case 'APPROVED':
        return <Tag icon={<CheckCircleOutlined />} color="success">Đã duyệt</Tag>;
      case 'REJECTED':
        return <Tag icon={<CloseCircleOutlined />} color="error">Từ chối</Tag>;
      default:
        return <Tag>{status}</Tag>;
    }
  };

  const columns: ColumnsType<EnterpriseListItem> = [
    {
      title: 'Tên doanh nghiệp',
      dataIndex: 'companyName',
      key: 'companyName',
      render: (text: string) => (
        <Space>
          <Text strong>{text}</Text>
        </Space>
      ),
    },
    {
      title: 'Mã số thuế',
      dataIndex: 'taxCode',
      key: 'taxCode',
    },
    {
      title: 'Lĩnh vực',
      dataIndex: 'industry',
      key: 'industry',
    },
    {
      title: 'Ngày đăng ký',
      dataIndex: 'createdAt',
      key: 'createdAt',
      render: (date: string) => new Date(date).toLocaleDateString('vi-VN'),
    },
    {
      title: 'Trạng thái',
      dataIndex: 'status',
      key: 'status',
      render: (status: 'PENDING' | 'APPROVED' | 'REJECTED') => getStatusTag(status),
    },
    {
      title: 'Thao tác',
      key: 'action',
      render: (_, record: EnterpriseListItem) => (
        <Button
          type="link"
          icon={<EyeOutlined />}
          onClick={() => handleViewDetail(record.id)}
        >
          Xem chi tiết
        </Button>
      ),
    },
  ];

  return (
    <div className={styles.pageWrapper}>
      <div className={styles.header}>
        <div>
          <Title level={2} className={styles.pageTitle}>
            <ShopOutlined /> Quản lý Doanh nghiệp
          </Title>
          <Paragraph className={styles.pageDescription}>
            Xác thực và quản lý các doanh nghiệp đăng ký hợp tác
          </Paragraph>
        </div>
      </div>

      {/* Statistics */}
      <Row gutter={16} className={styles.statsRow}>
        <Col xs={24} sm={12} lg={6}>
          <Card>
            <Statistic
              title="Tổng số doanh nghiệp"
              value={statsData.total}
              valueStyle={{ color: '#1890ff' }}
              prefix={<ShopOutlined />}
            />
          </Card>
        </Col>
        <Col xs={24} sm={12} lg={6}>
          <Card>
            <Statistic
              title="Chờ xác thực"
              value={statsData.pending}
              valueStyle={{ color: '#faad14' }}
              prefix={<ExclamationCircleOutlined />}
            />
          </Card>
        </Col>
        <Col xs={24} sm={12} lg={6}>
          <Card>
            <Statistic
              title="Đã duyệt"
              value={statsData.approved}
              valueStyle={{ color: '#52c41a' }}
              prefix={<CheckCircleOutlined />}
            />
          </Card>
        </Col>
        <Col xs={24} sm={12} lg={6}>
          <Card>
            <Statistic
              title="Từ chối"
              value={statsData.rejected}
              valueStyle={{ color: '#ff4d4f' }}
              prefix={<CloseCircleOutlined />}
            />
          </Card>
        </Col>
      </Row>

      {/* Filters */}
      <Card className={styles.filterCard}>
        <Space size="large" wrap>
          <Input
            placeholder="Tìm kiếm theo tên, mã số thuế..."
            prefix={<SearchOutlined />}
            value={searchText}
            onChange={(e) => setSearchText(e.target.value)}
            onPressEnter={fetchEnterprises}
            style={{ width: 300 }}
          />
          <Select
            value={statusFilter}
            onChange={setStatusFilter}
            style={{ width: 180 }}
          >
            <Select.Option value="ALL">Tất cả trạng thái</Select.Option>
            <Select.Option value="PENDING">Chờ xác thực</Select.Option>
            <Select.Option value="APPROVED">Đã duyệt</Select.Option>
            <Select.Option value="REJECTED">Từ chối</Select.Option>
          </Select>
          <Button type="primary" icon={<SearchOutlined />} onClick={fetchEnterprises}>
            Tìm kiếm
          </Button>
        </Space>
      </Card>

      {/* Table */}
      <Card>
        <Table
          columns={columns}
          dataSource={enterprises}
          rowKey="id"
          loading={loading}
          pagination={{
            pageSize: 10,
            showSizeChanger: true,
            showTotal: (total) => `Tổng số ${total} doanh nghiệp`,
          }}
        />
      </Card>

      {/* Detail Modal */}
      <Modal
        title="Chi tiết Doanh nghiệp"
        open={detailModalVisible}
        onCancel={() => setDetailModalVisible(false)}
        width={800}
        footer={
          selectedEnterprise?.status === 'PENDING' ? [
            <Button key="close" onClick={() => setDetailModalVisible(false)}>
              Đóng
            </Button>,
            <Button key="reject" danger onClick={() => setRejectModalVisible(true)}>
              <CloseCircleOutlined /> Từ chối
            </Button>,
            <Button key="approve" type="primary" onClick={() => setApproveModalVisible(true)}>
              <CheckCircleOutlined /> Phê duyệt
            </Button>,
          ] : [
            <Button key="close" type="primary" onClick={() => setDetailModalVisible(false)}>
              Đóng
            </Button>,
          ]
        }
      >
        {selectedEnterprise && (
          <Tabs defaultActiveKey="info">
            <TabPane tab="Thông tin chung" key="info">
              <Descriptions column={2} bordered>
                <Descriptions.Item label="Tên doanh nghiệp" span={2}>
                  {selectedEnterprise.companyName}
                </Descriptions.Item>
                <Descriptions.Item label="Mã số thuế">
                  {selectedEnterprise.taxCode}
                </Descriptions.Item>
                <Descriptions.Item label="Lĩnh vực">
                  {selectedEnterprise.industry}
                </Descriptions.Item>
                <Descriptions.Item label="Người đại diện" span={2}>
                  {selectedEnterprise.representativeName}
                </Descriptions.Item>
                <Descriptions.Item label="Email" span={2}>
                  <MailOutlined /> {selectedEnterprise.contactEmail}
                </Descriptions.Item>
                <Descriptions.Item label="Điện thoại">
                  <PhoneOutlined /> {selectedEnterprise.contactPhone}
                </Descriptions.Item>
                <Descriptions.Item label="Website">
                  {selectedEnterprise.website && (
                    <a href={selectedEnterprise.website} target="_blank" rel="noopener noreferrer">
                      <GlobalOutlined /> {selectedEnterprise.website}
                    </a>
                  )}
                </Descriptions.Item>
                <Descriptions.Item label="Địa chỉ" span={2}>
                  <EnvironmentOutlined /> {selectedEnterprise.address}
                </Descriptions.Item>
                <Descriptions.Item label="Trạng thái">
                  {getStatusTag(selectedEnterprise.status)}
                </Descriptions.Item>
                <Descriptions.Item label="Ngày đăng ký">
                  {new Date(selectedEnterprise.createdAt).toLocaleDateString('vi-VN')}
                </Descriptions.Item>
                {selectedEnterprise.status === 'REJECTED' && selectedEnterprise.rejectionReason && (
                  <>
                    <Descriptions.Item label="Lý do từ chối" span={2}>
                      <Text type="danger">{selectedEnterprise.rejectionReason}</Text>
                    </Descriptions.Item>
                    <Descriptions.Item label="Ngày từ chối" span={2}>
                      {selectedEnterprise.rejectedAt && new Date(selectedEnterprise.rejectedAt).toLocaleString('vi-VN')}
                    </Descriptions.Item>
                  </>
                )}
                <Descriptions.Item label="Mô tả" span={2}>
                  {selectedEnterprise.description || 'Chưa có mô tả'}
                </Descriptions.Item>
              </Descriptions>
            </TabPane>

            <TabPane tab="Thông tin bổ sung" key="additional">
              <Descriptions column={2} bordered>
                <Descriptions.Item label="Quy mô công ty">
                  {selectedEnterprise.companySize}
                </Descriptions.Item>
                <Descriptions.Item label="Năm thành lập">
                  {selectedEnterprise.yearEstablished}
                </Descriptions.Item>
                <Descriptions.Item label="Số giấy phép kinh doanh" span={2}>
                  {selectedEnterprise.businessLicenseNumber}
                </Descriptions.Item>
                <Descriptions.Item label="Chức vụ người đại diện">
                  {selectedEnterprise.representativePosition}
                </Descriptions.Item>
              </Descriptions>
            </TabPane>
          </Tabs>
        )}
      </Modal>

      {/* Approve Modal */}
      <Modal
        title="Phê duyệt Doanh nghiệp"
        open={approveModalVisible}
        onCancel={() => setApproveModalVisible(false)}
        onOk={() => approveForm.submit()}
        okText="Phê duyệt"
        cancelText="Hủy"
      >
        <Form form={approveForm} onFinish={handleApprove} layout="vertical">
          <Form.Item label="Ghi chú" name="note">
            <TextArea rows={4} placeholder="Nhập ghi chú (không bắt buộc)" />
          </Form.Item>
        </Form>
      </Modal>

      {/* Reject Modal */}
      <Modal
        title="Từ chối Doanh nghiệp"
        open={rejectModalVisible}
        onCancel={() => setRejectModalVisible(false)}
        onOk={() => rejectForm.submit()}
        okText="Từ chối"
        okButtonProps={{ danger: true }}
        cancelText="Hủy"
      >
        <Form form={rejectForm} onFinish={handleReject} layout="vertical">
          <Form.Item
            label="Lý do"
            name="reason"
            rules={[{ required: true, message: 'Vui lòng chọn lý do' }]}
          >
            <Select placeholder="Chọn lý do từ chối">
              <Select.Option value="INVALID_DOCUMENTS">Giấy tờ không hợp lệ</Select.Option>
              <Select.Option value="NOT_ELIGIBLE">Không đủ điều kiện</Select.Option>
              <Select.Option value="DUPLICATE">Trùng lặp</Select.Option>
              <Select.Option value="OTHER">Khác</Select.Option>
            </Select>
          </Form.Item>
          <Form.Item
            label="Chi tiết"
            name="details"
            rules={[{ required: true, message: 'Vui lòng nhập chi tiết' }]}
          >
            <TextArea rows={4} placeholder="Nhập chi tiết lý do từ chối" />
          </Form.Item>
        </Form>
      </Modal>
    </div>
  );
};

export default EnterpriseManagement;
