import { useState, useEffect } from 'react';
import {
  Card,
  Table,
  Tag,
  Button,
  Modal,
  Descriptions,
  message,
  Space,
  Typography,
  Spin,
  Alert,
  Input,
  Tooltip,
} from 'antd';
import {
  EyeOutlined,
  CheckCircleOutlined,
  CloseCircleOutlined,
  ReloadOutlined,
  InfoCircleOutlined,
} from '@ant-design/icons';
import { dashboardService } from '../../../services/admin/dashboardService';
import type { PendingApproval } from '../../../services/admin/dashboardService';

const { Title, Text } = Typography;
const { TextArea } = Input;

export default function PendingApprovals() {
  const [loading, setLoading] = useState(true);
  const [approvals, setApprovals] = useState<PendingApproval[]>([]);
  const [detailModalOpen, setDetailModalOpen] = useState(false);
  const [rejectModalOpen, setRejectModalOpen] = useState(false);
  const [selectedApproval, setSelectedApproval] = useState<PendingApproval | null>(null);
  const [rejectReason, setRejectReason] = useState('');
  const [actionLoading, setActionLoading] = useState(false);

  useEffect(() => {
    loadApprovals();
    document.title = 'Chờ Phê duyệt | LabODC UTH';
  }, []);

  const loadApprovals = async () => {
    setLoading(true);
    try {
      const data = await dashboardService.getPendingApprovals(100); // Load more items
      setApprovals(data);
    } catch (error: any) {
      message.error('Không thể tải danh sách chờ phê duyệt');
      console.error('Error loading approvals:', error);
    } finally {
      setLoading(false);
    }
  };

  const handleViewDetail = (record: PendingApproval) => {
    setSelectedApproval(record);
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
      loadApprovals(); // Reload list
      // Dispatch custom event to notify sidebar to refresh count
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
      loadApprovals(); // Reload list
      // Dispatch custom event to notify sidebar to refresh count
      window.dispatchEvent(new CustomEvent('approvalStatusChanged'));
    } catch (error: any) {
      message.error(error.response?.data?.message || 'Không thể từ chối');
      console.error('Reject error:', error);
    } finally {
      setActionLoading(false);
    }
  };

  const getPriorityColor = (priority: string) => {
    switch (priority) {
      case 'high': return 'red';
      case 'medium': return 'orange';
      default: return 'blue';
    }
  };

  const getPriorityLabel = (priority: string): string => {
    if (priority === 'high') return 'Cao';
    if (priority === 'medium') return 'Trung bình';
    return 'Thấp';
  };

  const formatCurrency = (value?: number, currency: string = 'VND'): string => {
    if (!value) return 'Chưa cập nhật';
    return new Intl.NumberFormat('vi-VN', {
      style: 'currency',
      currency: currency
    }).format(value);
  };

  const columns = [
    {
      title: 'ID',
      dataIndex: 'id',
      key: 'id',
      width: 80,
    },
    {
      title: 'Loại',
      dataIndex: 'type',
      key: 'type',
      width: 140,
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
      render: (text: string, record: PendingApproval) => (
        <Tooltip title={record.type === 'enterprise' ? record.companyName : record.title}>
          <Text strong>{record.type === 'enterprise' ? record.companyName : record.title}</Text>
        </Tooltip>
      ),
    },
    {
      title: 'Thông tin chính',
      key: 'mainInfo',
      ellipsis: true,
      render: (_: any, record: PendingApproval) => {
        if (record.type === 'enterprise') {
          return (
            <Space direction="vertical" size={0}>
              <Text type="secondary">MST: {record.taxCode}</Text>
              <Text type="secondary">ĐD: {record.representativeName}</Text>
            </Space>
          );
        } else {
          return (
            <Space direction="vertical" size={0}>
              <Text type="secondary">DN: {record.enterpriseName}</Text>
              <Text type="secondary">NS: {formatCurrency(record.budget, record.currency)}</Text>
            </Space>
          );
        }
      },
    },
    {
      title: 'Liên hệ',
      key: 'contact',
      ellipsis: true,
      render: (_: any, record: PendingApproval) => {
        if (record.type === 'enterprise') {
          return (
            <Space direction="vertical" size={0}>
              <Text copyable type="secondary">{record.contactEmail}</Text>
              <Text copyable type="secondary">{record.contactPhone}</Text>
            </Space>
          );
        } else {
          return (
            <Space direction="vertical" size={0}>
              <Text type="secondary">SV: {record.numberOfStudents || 'N/A'}</Text>
              <Text type="secondary">TT: {record.status}</Text>
            </Space>
          );
        }
      },
    },
    {
      title: 'Ngày nộp',
      dataIndex: 'submittedAt',
      key: 'submittedAt',
      width: 160,
      render: (date: string) => new Date(date).toLocaleString('vi-VN'),
    },
    {
      title: 'Ưu tiên',
      dataIndex: 'priority',
      key: 'priority',
      width: 110,
      render: (priority: string) => (
        <Tag color={getPriorityColor(priority)}>
          {getPriorityLabel(priority)}
        </Tag>
      ),
    },
    {
      title: 'Thao tác',
      key: 'action',
      width: 120,
      fixed: 'right' as const,
      render: (_: any, record: PendingApproval) => (
        <Button 
          type="primary"
          size="small" 
          icon={<EyeOutlined />}
          onClick={() => handleViewDetail(record)}
        >
          Chi tiết
        </Button>
      ),
    },
  ];

  return (
    <div style={{ padding: '24px' }}>
      <Card>
        <div style={{ marginBottom: 16, display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
          <div>
            <Title level={3} style={{ margin: 0 }}>
              Danh sách Chờ Phê duyệt
            </Title>
            <Text type="secondary">
              Tổng số: {approvals.length} mục ({approvals.filter(a => a.type === 'enterprise').length} DN, {approvals.filter(a => a.type === 'project').length} DA)
            </Text>
          </div>
          <Button
            type="primary"
            icon={<ReloadOutlined />}
            onClick={loadApprovals}
            loading={loading}
          >
            Làm mới
          </Button>
        </div>

        {loading ? (
          <div style={{ textAlign: 'center', padding: '40px' }}>
            <Spin size="large" />
          </div>
        ) : approvals.length === 0 ? (
          <Alert
            message="Không có mục nào chờ phê duyệt"
            description="Tất cả doanh nghiệp và dự án đã được xử lý."
            type="info"
            showIcon
          />
        ) : (
          <Table
            dataSource={approvals}
            columns={columns}
            rowKey="id"
            pagination={{
              pageSize: 20,
              showSizeChanger: true,
              showTotal: (total) => `Tổng ${total} mục`,
            }}
            scroll={{ x: 1200 }}
          />
        )}
      </Card>

      {/* Detail Modal */}
      <Modal
        title={
          <span>
            <InfoCircleOutlined /> Chi tiết {selectedApproval?.type === 'enterprise' ? 'Doanh nghiệp' : 'Dự án'}
          </span>
        }
        open={detailModalOpen}
        onCancel={() => setDetailModalOpen(false)}
        width={900}
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
            <Descriptions.Item label="ID">
              {selectedApproval.id}
            </Descriptions.Item>
            <Descriptions.Item label="Mức độ ưu tiên">
              <Tag color={getPriorityColor(selectedApproval.priority)}>
                {getPriorityLabel(selectedApproval.priority)}
              </Tag>
            </Descriptions.Item>
            <Descriptions.Item label="Tên công ty" span={2}>
              <Text strong style={{ fontSize: 16 }}>{selectedApproval.companyName}</Text>
            </Descriptions.Item>
            <Descriptions.Item label="Mã số thuế">
              <Text copyable>{selectedApproval.taxCode}</Text>
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
              <Text copyable>{selectedApproval.contactEmail}</Text>
            </Descriptions.Item>
            <Descriptions.Item label="Số điện thoại">
              <Text copyable>{selectedApproval.contactPhone}</Text>
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
              <Text>{selectedApproval.description || 'Chưa có mô tả'}</Text>
            </Descriptions.Item>
            <Descriptions.Item label="Ngày nộp">
              {new Date(selectedApproval.submittedAt).toLocaleString('vi-VN')}
            </Descriptions.Item>
            <Descriptions.Item label="Trạng thái">
              <Tag color="orange">Chờ phê duyệt</Tag>
            </Descriptions.Item>
          </Descriptions>
        )}
        
        {selectedApproval && selectedApproval.type === 'project' && (
          <Descriptions bordered column={2} size="small">
            <Descriptions.Item label="Loại" span={2}>
              <Tag color="green">Dự án</Tag>
            </Descriptions.Item>
            <Descriptions.Item label="ID">
              {selectedApproval.id}
            </Descriptions.Item>
            <Descriptions.Item label="Mức độ ưu tiên">
              <Tag color={getPriorityColor(selectedApproval.priority)}>
                {getPriorityLabel(selectedApproval.priority)}
              </Tag>
            </Descriptions.Item>
            <Descriptions.Item label="Tên dự án" span={2}>
              <Text strong style={{ fontSize: 16 }}>{selectedApproval.title}</Text>
            </Descriptions.Item>
            <Descriptions.Item label="Slug">
              <Text code>{selectedApproval.slug}</Text>
            </Descriptions.Item>
            <Descriptions.Item label="Doanh nghiệp">
              <Text strong>{selectedApproval.enterpriseName}</Text>
            </Descriptions.Item>
            <Descriptions.Item label="Ngày bắt đầu">
              {selectedApproval.startDate ? new Date(selectedApproval.startDate).toLocaleDateString('vi-VN') : 'Chưa xác định'}
            </Descriptions.Item>
            <Descriptions.Item label="Ngày kết thúc">
              {selectedApproval.endDate ? new Date(selectedApproval.endDate).toLocaleDateString('vi-VN') : 'Chưa xác định'}
            </Descriptions.Item>
            <Descriptions.Item label="Ngân sách">
              <Text strong>{formatCurrency(selectedApproval.budget, selectedApproval.currency)}</Text>
            </Descriptions.Item>
            <Descriptions.Item label="Số sinh viên">
              {selectedApproval.numberOfStudents || 'Chưa xác định'}
            </Descriptions.Item>
            <Descriptions.Item label="Trạng thái hiện tại" span={2}>
              <Tag color="orange">{selectedApproval.status || 'PENDING'}</Tag>
            </Descriptions.Item>
            <Descriptions.Item label="Mô tả" span={2}>
              <Text>{selectedApproval.description || 'Chưa có mô tả'}</Text>
            </Descriptions.Item>
            <Descriptions.Item label="Yêu cầu" span={2}>
              <Text>{selectedApproval.requirements || 'Chưa có yêu cầu cụ thể'}</Text>
            </Descriptions.Item>
            <Descriptions.Item label="Ngày nộp">
              {new Date(selectedApproval.submittedAt).toLocaleString('vi-VN')}
            </Descriptions.Item>
            <Descriptions.Item label="Trạng thái">
              <Tag color="orange">Chờ phê duyệt</Tag>
            </Descriptions.Item>
          </Descriptions>
        )}
      </Modal>

      {/* Reject Modal */}
      <Modal
        title={
          <span style={{ color: '#ff4d4f' }}>
            <CloseCircleOutlined /> Từ chối {selectedApproval?.type === 'enterprise' ? 'Doanh nghiệp' : 'Dự án'}
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
        width={600}
      >
        <Space direction="vertical" style={{ width: '100%' }} size="large">
          <Alert
            message="Cảnh báo"
            description={`Bạn đang từ chối ${selectedApproval?.type === 'enterprise' ? 'doanh nghiệp' : 'dự án'} "${selectedApproval?.type === 'enterprise' ? selectedApproval?.companyName : selectedApproval?.title}". Hành động này không thể hoàn tác.`}
            type="warning"
            showIcon
          />
          <div>
            <Text strong>Lý do từ chối (tùy chọn):</Text>
            <TextArea
              rows={4}
              placeholder="Nhập lý do từ chối để gửi thông báo cho người dùng..."
              value={rejectReason}
              onChange={(e) => setRejectReason(e.target.value)}
              style={{ marginTop: 8 }}
            />
          </div>
        </Space>
      </Modal>
    </div>
  );
}
