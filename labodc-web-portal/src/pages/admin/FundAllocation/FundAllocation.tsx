import { useState, useEffect } from 'react';
import {
  Card,
  Table,
  Tag,
  Button,
  Space,
  Typography,
  message,
  Tabs,
  Badge,
  Drawer,
  Alert,
  Descriptions,
  Modal,
  InputNumber,
  Row,
  Col,
  Statistic,
  List,
  Input,
  Form
} from 'antd';
import {
  DollarOutlined,
  TeamOutlined,
  UserOutlined,
  BankOutlined,
  EyeOutlined,
  SendOutlined,
  SearchOutlined,
  PlusOutlined,
  EditOutlined,
  DeleteOutlined
} from '@ant-design/icons';
import type { ColumnsType } from 'antd/es/table';
import { fundService } from "@/services/admin/fundService";
import type { FundAllocation, FundAllocationDetail, DelayedPayment, HybridFundAdvance, TeamMemberAllocation } from '@/services/admin/fundService';

const { Title, Text } = Typography;
const { TextArea } = Input;

export default function FundAllocationPage() {
  const [loading, setLoading] = useState(false);
  const [allocations, setAllocations] = useState<FundAllocation[]>([]);
  const [filteredAllocations, setFilteredAllocations] = useState<FundAllocation[]>([]);
  const [searchText, setSearchText] = useState('');
  const [selectedAllocation, setSelectedAllocation] = useState<FundAllocationDetail | null>(null);
  const [detailVisible, setDetailVisible] = useState(false);
  const [activeTab, setActiveTab] = useState('ALL');
  
  // Modals
  const [mentorDisburseVisible, setMentorDisburseVisible] = useState(false);
  const [teamDisburseVisible, setTeamDisburseVisible] = useState(false);
  const [hybridFundVisible, setHybridFundVisible] = useState(false);
  const [editModalVisible, setEditModalVisible] = useState(false);
  const [editingAllocation, setEditingAllocation] = useState<FundAllocation | null>(null);
  
  // Delayed payments & Hybrid funds
  const [delayedPayments, setDelayedPayments] = useState<DelayedPayment[]>([]);
  const [hybridFunds, setHybridFunds] = useState<HybridFundAdvance[]>([]);
  
  // Form states
  const [mentorNote, setMentorNote] = useState('');
  const [teamNote, setTeamNote] = useState('');
  const [hybridReason, setHybridReason] = useState('');
  const [hybridTeamAmount, setHybridTeamAmount] = useState<number>(0);
  const [hybridMentorAmount, setHybridMentorAmount] = useState<number>(0);

  // Statistics
  const [statistics, setStatistics] = useState<any>(null);

  // Filter allocations when search changes
  useEffect(() => {
    if (!searchText.trim()) {
      setFilteredAllocations(allocations);
      return;
    }

    const filtered = allocations.filter(allocation => {
      const searchLower = searchText.toLowerCase();
      return (
        allocation.projectTitle?.toLowerCase().includes(searchLower) ||
        allocation.enterpriseName?.toLowerCase().includes(searchLower) ||
        allocation.status?.toLowerCase().includes(searchLower)
      );
    });
    setFilteredAllocations(filtered);
  }, [searchText, allocations]);

  // Load delayed payments count on mount for badge display
  useEffect(() => {
    loadDelayedCount();
  }, []);

  useEffect(() => {
    loadData();
  }, [activeTab]);

  const loadDelayedCount = async () => {
    try {
      const delayed = await fundService.getDelayedPayments();
      setDelayedPayments(delayed);
    } catch (error) {
      console.error('Error loading delayed payments count:', error);
    }
  };

  const loadData = async () => {
    console.log('🔄 [FundAllocation] Loading data for tab:', activeTab);
    setLoading(true);
    try {
      if (activeTab === 'DELAYED') {
        console.log('📊 [FundAllocation] Fetching delayed payments...');
        const delayed = await fundService.getDelayedPayments();
        console.log('✅ [FundAllocation] Delayed payments:', delayed);
        setDelayedPayments(delayed);
      } else if (activeTab === 'HYBRID') {
        console.log('📊 [FundAllocation] Fetching hybrid funds...');
        const hybrid = await fundService.getHybridFunds();
        console.log('✅ [FundAllocation] Hybrid funds:', hybrid);
        setHybridFunds(hybrid);
      } else {
        // Pass null/undefined for 'ALL' to get all records
        const statusFilter = activeTab === 'ALL' ? undefined : activeTab;
        console.log('📊 [FundAllocation] Fetching allocations with filter:', statusFilter);
        const data = await fundService.getAllocations(statusFilter);
        console.log('✅ [FundAllocation] Allocations received:', data);
        console.log('📈 [FundAllocation] Number of allocations:', data?.length || 0);
        setAllocations(data);
      }
      
      console.log('📊 [FundAllocation] Fetching statistics...');
      const stats = await fundService.getFundStatistics();
      console.log('✅ [FundAllocation] Statistics:', stats);
      setStatistics(stats);
    } catch (error: any) {
      console.error('❌ [FundAllocation] Error loading data:', error);
      console.error('❌ [FundAllocation] Error response:', error.response);
      console.error('❌ [FundAllocation] Error message:', error.message);
      message.error(error.response?.data?.message || 'Không thể tải dữ liệu');
    } finally {
      setLoading(false);
    }
  };

  const handleViewDetail = async (projectId: number) => {
    console.log('🔍 [FundAllocation] Loading detail for project:', projectId);
    try {
      const detail = await fundService.getAllocationByProject(projectId);
      console.log('✅ [FundAllocation] Detail received:', detail);
      setSelectedAllocation(detail);
      setDetailVisible(true);
    } catch (error: any) {
      console.error('❌ [FundAllocation] Error loading detail:', error);
      message.error('Không thể tải chi tiết phân bổ');
    }
  };

  const handleConfirmAllocation = async (projectId: number) => {
    try {
      await fundService.confirmAllocation(projectId);
      message.success('Đã xác nhận phân bổ quỹ');
      loadData();
    } catch (error: any) {
      message.error(error.response?.data?.message || 'Không thể xác nhận');
    }
  };

  const handleDisburseMentor = async () => {
    if (!selectedAllocation || !mentorNote.trim()) {
      message.warning('Vui lòng nhập ghi chú');
      return;
    }

    try {
      await fundService.disburseMentor(selectedAllocation.projectId, {
        mentorId: selectedAllocation.mentorInfo!.id,
        amount: selectedAllocation.allocation.mentor.amount,
        note: mentorNote
      });
      message.success('Đã giải ngân cho Mentor');
      setMentorDisburseVisible(false);
      setMentorNote('');
      setDetailVisible(false);
      loadData();
    } catch (error: any) {
      message.error(error.response?.data?.message || 'Không thể giải ngân');
    }
  };

  const handleDisburseTeam = async () => {
    if (!selectedAllocation || !selectedAllocation.teamDistribution || !teamNote.trim()) {
      message.warning('Vui lòng nhập ghi chú');
      return;
    }

    try {
      await fundService.disburseTeam(selectedAllocation.projectId, {
        distributionId: selectedAllocation.teamDistribution.distributionId,
        teamDistribution: selectedAllocation.teamDistribution.members.map((m: TeamMemberAllocation) => ({
          talentId: m.talentId,
          amount: m.amount
        })),
        note: teamNote
      });
      message.success('Đã giải ngân cho Team');
      setTeamDisburseVisible(false);
      setTeamNote('');
      setDetailVisible(false);
      loadData();
    } catch (error: any) {
      message.error(error.response?.data?.message || 'Không thể giải ngân');
    }
  };

  const handleCreateHybridFund = async (projectId: number) => {
    if (!hybridReason.trim()) {
      message.warning('Vui lòng nhập lý do tạm ứng');
      return;
    }

    try {
      await fundService.createHybridFund({
        projectId,
        advanceAmount: hybridTeamAmount + hybridMentorAmount,
        recipients: {
          team: {
            amount: hybridTeamAmount,
            distribute: true
          },
          mentor: {
            amount: hybridMentorAmount,
            distribute: true
          }
        },
        reason: hybridReason,
        expectedRepaymentDate: new Date(Date.now() + 30 * 24 * 60 * 60 * 1000).toISOString()
      });
      message.success('Đã tạo tạm ứng Hybrid Fund');
      setHybridFundVisible(false);
      setHybridReason('');
      setHybridTeamAmount(0);
      setHybridMentorAmount(0);
      loadData();
    } catch (error: any) {
      message.error(error.response?.data?.message || 'Không thể tạo tạm ứng');
    }
  };

  const handleEdit = (record: FundAllocation) => {
    setEditingAllocation(record);
    setEditModalVisible(true);
  };

  const handleDelete = (projectId: number) => {
    Modal.confirm({
      title: 'Xác nhận xóa',
      content: 'Bạn có chắc chắn muốn xóa phân bổ quỹ này?',
      okText: 'Xóa',
      okType: 'danger',
      cancelText: 'Hủy',
      onOk: async () => {
        try {
          await fundService.deleteAllocation(projectId);
          message.success('Xóa phân bổ quỹ thành công');
          loadData();
        } catch (error: any) {
          message.error(error.response?.data?.message || 'Không thể xóa phân bổ quỹ');
        }
      }
    });
  };

  const handleUpdateAllocation = async (values: any) => {
    if (!editingAllocation) return;

    try {
      await fundService.updateAllocation(editingAllocation.projectId, values);
      message.success('Cập nhật phân bổ quỹ thành công');
      setEditModalVisible(false);
      setEditingAllocation(null);
      loadData();
    } catch (error: any) {
      message.error(error.response?.data?.message || 'Không thể cập nhật phân bổ quỹ');
    }
  };

  const formatCurrency = (value: number) => {
    return new Intl.NumberFormat('vi-VN', { style: 'currency', currency: 'VND' }).format(value);
  };

  const getStatusTag = (status: string) => {
    const statusMap: Record<string, { color: string; text: string }> = {
      ALLOCATED: { color: 'blue', text: 'Đã phân bổ' },
      CONFIRMED: { color: 'success', text: 'Đã xác nhận' },
      PENDING: { color: 'processing', text: 'Chờ xác nhận' },
      COMPLETED: { color: 'default', text: 'Hoàn tất' },
      PENDING_DISTRIBUTION: { color: 'orange', text: 'Chờ phân phối' },
      DISTRIBUTED: { color: 'cyan', text: 'Đã phân phối' },
      DISBURSED: { color: 'green', text: 'Đã giải ngân' },
      PENDING_REPORT: { color: 'gold', text: 'Chờ báo cáo' },
      READY: { color: 'blue', text: 'Sẵn sàng' },
      RECEIVED: { color: 'success', text: 'Đã nhận' }
    };
    const config = statusMap[status] || { color: 'default', text: status };
    return <Tag color={config.color}>{config.text}</Tag>;
  };

  const columns: ColumnsType<FundAllocation> = [
    {
      title: 'Dự án',
      dataIndex: 'projectTitle',
      key: 'projectTitle',
      render: (text, record) => (
        <div>
          <Text strong>{text}</Text>
          <br />
          <Text type="secondary" style={{ fontSize: 12 }}>{record.enterpriseName}</Text>
        </div>
      ),
    },
    {
      title: 'Tổng quỹ',
      dataIndex: ['allocation', 'total'],
      key: 'total',
      width: 150,
      render: (amount) => <Text strong>{formatCurrency(amount)}</Text>,
    },
    {
      title: 'Team (70%)',
      key: 'team',
      width: 180,
      render: (_, record) => (
        <div>
          <div>{formatCurrency(record.allocation.team.amount)}</div>
          {getStatusTag(record.allocation.team.status)}
        </div>
      ),
    },
    {
      title: 'Mentor (20%)',
      key: 'mentor',
      width: 180,
      render: (_, record) => (
        <div>
          <div>{formatCurrency(record.allocation.mentor.amount)}</div>
          {getStatusTag(record.allocation.mentor.status)}
        </div>
      ),
    },
    {
      title: 'Lab (10%)',
      key: 'lab',
      width: 180,
      render: (_, record) => (
        <div>
          <div>{formatCurrency(record.allocation.lab.amount)}</div>
          {getStatusTag(record.allocation.lab.status)}
        </div>
      ),
    },
    {
      title: 'Ngày thanh toán',
      dataIndex: ['payment', 'paidAt'],
      key: 'paidAt',
      width: 160,
      render: (date) => new Date(date).toLocaleString('vi-VN'),
    },
    {
      title: 'Hành động',
      key: 'action',
      width: 180,
      fixed: 'right',
      render: (_, record) => (
        <Space size="small">
          <Button 
            type="link" 
            icon={<EyeOutlined />} 
            onClick={() => handleViewDetail(record.projectId)}
          >
            Chi tiết
          </Button>
          <Button 
            type="link" 
            icon={<EditOutlined />} 
            onClick={() => handleEdit(record)}
          >
            Sửa
          </Button>
          <Button 
            type="link" 
            danger
            icon={<DeleteOutlined />} 
            onClick={() => handleDelete(record.projectId)}
          >
            Xóa
          </Button>
        </Space>
      ),
    },
  ];

  const delayedColumns: ColumnsType<DelayedPayment> = [
    {
      title: 'Dự án',
      dataIndex: 'projectTitle',
      key: 'projectTitle',
      render: (text, record) => (
        <div>
          <Text strong>{text}</Text>
          <br />
          <Text type="secondary">{record.enterprise.name}</Text>
        </div>
      ),
    },
    {
      title: 'Số tiền',
      dataIndex: ['payment', 'amount'],
      key: 'amount',
      render: (amount) => formatCurrency(amount),
    },
    {
      title: 'Quá hạn',
      dataIndex: ['payment', 'daysPastDue'],
      key: 'daysPastDue',
      render: (days) => <Tag color="red">{days} ngày</Tag>,
    },
    {
      title: 'Mức độ',
      dataIndex: 'urgency',
      key: 'urgency',
      render: (urgency) => {
        const color = urgency === 'HIGH' ? 'red' : urgency === 'MEDIUM' ? 'orange' : 'blue';
        return <Tag color={color}>{urgency}</Tag>;
      },
    },
    {
      title: 'Hành động',
      key: 'action',
      render: (_, record) => (
        <Button type="primary" size="small" onClick={() => {
          setHybridFundVisible(true);
          // Set default amounts based on 70/20 split
          setHybridTeamAmount(record.payment.amount * 0.7);
          setHybridMentorAmount(record.payment.amount * 0.2);
        }}>
          Tạm ứng
        </Button>
      ),
    },
  ];

  const hybridColumns: ColumnsType<HybridFundAdvance> = [
    {
      title: 'Dự án',
      dataIndex: 'projectTitle',
      key: 'projectTitle',
    },
    {
      title: 'Số tiền tạm ứng',
      dataIndex: 'advanceAmount',
      key: 'advanceAmount',
      render: (amount) => formatCurrency(amount),
    },
    {
      title: 'Công nợ DN',
      dataIndex: 'enterpriseDebt',
      key: 'enterpriseDebt',
      render: (debt) => <Text type="danger">{formatCurrency(debt)}</Text>,
    },
    {
      title: 'Ngày tạm ứng',
      dataIndex: 'advancedAt',
      key: 'advancedAt',
      render: (date) => new Date(date).toLocaleDateString('vi-VN'),
    },
    {
      title: 'Trạng thái',
      dataIndex: 'status',
      key: 'status',
      render: (status) => {
        const color = status === 'REPAID' ? 'success' : status === 'OVERDUE' ? 'error' : 'warning';
        return <Tag color={color}>{status}</Tag>;
      },
    },
  ];

  return (
    <div style={{ padding: '24px' }}>
      <Title level={2}>
        <DollarOutlined /> Phân bổ Quỹ
      </Title>

      {/* Search and Actions */}
      <Card style={{ marginBottom: 16 }}>
        <Row gutter={16} align="middle">
          <Col flex="auto">
            <Input
              placeholder="Tìm kiếm theo tên dự án, doanh nghiệp..."
              prefix={<SearchOutlined />}
              value={searchText}
              onChange={(e) => setSearchText(e.target.value)}
              allowClear
              size="large"
            />
          </Col>
        </Row>
      </Card>

      {/* Statistics */}
      {statistics && (
        <Row gutter={16} style={{ marginBottom: 24 }}>
          <Col span={6}>
            <Card>
              <Statistic
                title="Tổng doanh thu"
                value={statistics.totalRevenue}
                formatter={(val) => formatCurrency(val as number)}
                prefix={<DollarOutlined />}
              />
            </Card>
          </Col>
          <Col span={6}>
            <Card>
              <Statistic
                title="Đã giải ngân Team"
                value={statistics.teamDisbursed}
                formatter={(val) => formatCurrency(val as number)}
                prefix={<TeamOutlined />}
                valueStyle={{ color: '#3f8600' }}
              />
            </Card>
          </Col>
          <Col span={6}>
            <Card>
              <Statistic
                title="Đã giải ngân Mentor"
                value={statistics.mentorDisbursed}
                formatter={(val) => formatCurrency(val as number)}
                prefix={<UserOutlined />}
                valueStyle={{ color: '#1890ff' }}
              />
            </Card>
          </Col>
          <Col span={6}>
            <Card>
              <Statistic
                title="Quỹ Lab"
                value={statistics.labRevenue}
                formatter={(val) => formatCurrency(val as number)}
                prefix={<BankOutlined />}
                valueStyle={{ color: '#722ed1' }}
              />
            </Card>
          </Col>
        </Row>
      )}

      <Card>
        <Tabs
          activeKey={activeTab}
          onChange={setActiveTab}
          items={[
            { key: 'ALL', label: 'Tất cả' },
            { key: 'DISTRIBUTED', label: 'Đã phân phối' },
            { key: 'COMPLETED', label: 'Hoàn tất' },
            { key: 'ALLOCATED', label: 'Đã phân bổ' },
            { key: 'DELAYED', label: <Badge count={delayedPayments.length} offset={[10, 0]} status="error"><span>Thanh toán chậm</span></Badge> },
            { key: 'HYBRID', label: 'Hybrid Fund' }
          ]}
        />

        {activeTab === 'DELAYED' ? (
          <Table
            columns={delayedColumns}
            dataSource={delayedPayments}
            rowKey="projectId"
            loading={loading}
          />
        ) : activeTab === 'HYBRID' ? (
          <Table
            columns={hybridColumns}
            dataSource={hybridFunds}
            rowKey="id"
            loading={loading}
          />
        ) : (
          <Table
            columns={columns}
            dataSource={filteredAllocations}
            rowKey="projectId"
            loading={loading}
            scroll={{ x: 1200 }}
          />
        )}
      </Card>

      {/* Detail Drawer */}
      <Drawer
        title="Chi tiết Phân bổ Quỹ"
        placement="right"
        width={720}
        open={detailVisible}
        onClose={() => setDetailVisible(false)}
      >
        {selectedAllocation && (
          <Space direction="vertical" style={{ width: '100%' }} size="large">
            {/* Summary */}
            <Card title="Tổng quan" size="small">
              <Descriptions column={1} bordered>
                <Descriptions.Item label="Dự án">{selectedAllocation.projectTitle}</Descriptions.Item>
                <Descriptions.Item label="Doanh nghiệp">{selectedAllocation.enterpriseName}</Descriptions.Item>
                <Descriptions.Item label="Tổng quỹ">
                  <Text strong style={{ fontSize: 16 }}>{formatCurrency(selectedAllocation.allocation.total)}</Text>
                </Descriptions.Item>
                <Descriptions.Item label="Ngày thanh toán">
                  {new Date(selectedAllocation.payment.paidAt).toLocaleString('vi-VN')}
                </Descriptions.Item>
              </Descriptions>
            </Card>

            {/* Fund Distribution 70/20/10 */}
            <Card title="Phân bổ Quỹ (70/20/10)" size="small">
              <Space direction="vertical" style={{ width: '100%' }} size="middle">
                {/* Team 70% */}
                <Card type="inner" size="small">
                  <Space direction="vertical" style={{ width: '100%' }}>
                    <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
                      <Text strong><TeamOutlined /> Team (70%)</Text>
                      {getStatusTag(selectedAllocation.allocation.team.status)}
                    </div>
                    <Text style={{ fontSize: 18 }}>{formatCurrency(selectedAllocation.allocation.team.amount)}</Text>
                    
                    {selectedAllocation.teamDistribution && (
                      <>
                        <List
                          size="small"
                          dataSource={selectedAllocation.teamDistribution.members}
                          renderItem={(member: TeamMemberAllocation) => (
                            <List.Item>
                              <List.Item.Meta
                                title={
                                  <Space>
                                    <Text>{member.fullName}</Text>
                                    <Tag>{member.percentage}%</Tag>
                                  </Space>
                                }
                                description={
                                  <div>
                                    <div>{formatCurrency(member.amount)}</div>
                                    <Text type="secondary" style={{ fontSize: 12 }}>{member.reason}</Text>
                                  </div>
                                }
                              />
                            </List.Item>
                          )}
                        />
                        {selectedAllocation.allocation.team.status !== 'DISBURSED' && (
                          <Button type="primary" block icon={<SendOutlined />} onClick={() => setTeamDisburseVisible(true)}>
                            Giải ngân cho Team
                          </Button>
                        )}
                      </>
                    )}
                  </Space>
                </Card>

                {/* Mentor 20% */}
                <Card type="inner" size="small">
                  <Space direction="vertical" style={{ width: '100%' }}>
                    <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
                      <Text strong><UserOutlined /> Mentor (20%)</Text>
                      {getStatusTag(selectedAllocation.allocation.mentor.status)}
                    </div>
                    <Text style={{ fontSize: 18 }}>{formatCurrency(selectedAllocation.allocation.mentor.amount)}</Text>
                    
                    {selectedAllocation.mentorInfo && (
                      <>
                        <Descriptions size="small" column={1}>
                          <Descriptions.Item label="Tên">{selectedAllocation.mentorInfo.name}</Descriptions.Item>
                          <Descriptions.Item label="Email">{selectedAllocation.mentorInfo.email}</Descriptions.Item>
                          <Descriptions.Item label="Báo cáo">
                            {selectedAllocation.mentorInfo.reportSubmitted ? (
                              <Tag color="success">Đã nộp</Tag>
                            ) : (
                              <Tag color="warning">Chưa nộp</Tag>
                            )}
                          </Descriptions.Item>
                        </Descriptions>
                        {selectedAllocation.allocation.mentor.status === 'READY' && (
                          <Button type="primary" block icon={<SendOutlined />} onClick={() => setMentorDisburseVisible(true)}>
                            Giải ngân cho Mentor
                          </Button>
                        )}
                      </>
                    )}
                  </Space>
                </Card>

                {/* Lab 10% */}
                <Card type="inner" size="small">
                  <Space direction="vertical" style={{ width: '100%' }}>
                    <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
                      <Text strong><BankOutlined /> Lab (10%)</Text>
                      {getStatusTag(selectedAllocation.allocation.lab.status)}
                    </div>
                    <Text style={{ fontSize: 18 }}>{formatCurrency(selectedAllocation.allocation.lab.amount)}</Text>
                  </Space>
                </Card>
              </Space>
            </Card>
          </Space>
        )}
      </Drawer>

      {/* Disburse Mentor Modal */}
      <Modal
        title="Giải ngân cho Mentor"
        open={mentorDisburseVisible}
        onCancel={() => { setMentorDisburseVisible(false); setMentorNote(''); }}
        onOk={handleDisburseMentor}
      >
        <Space direction="vertical" style={{ width: '100%' }} size="middle">
          <Alert
            message="Xác nhận giải ngân"
            description={`Số tiền: ${formatCurrency(selectedAllocation?.allocation.mentor.amount || 0)}`}
            type="info"
            showIcon
          />
          <div>
            <div style={{ marginBottom: 8 }}>Ghi chú *</div>
            <TextArea rows={3} value={mentorNote} onChange={(e) => setMentorNote(e.target.value)} placeholder="Giải ngân sau khi Mentor hoàn thành báo cáo cuối kỳ" />
          </div>
        </Space>
      </Modal>

      {/* Disburse Team Modal */}
      <Modal
        title="Giải ngân cho Team"
        open={teamDisburseVisible}
        onCancel={() => { setTeamDisburseVisible(false); setTeamNote(''); }}
        onOk={handleDisburseTeam}
        width={600}
      >
        <Space direction="vertical" style={{ width: '100%' }} size="middle">
          <Alert
            message="Xác nhận giải ngân"
            description={`Tổng số tiền: ${formatCurrency(selectedAllocation?.allocation.team.amount || 0)}`}
            type="info"
            showIcon
          />
          {selectedAllocation?.teamDistribution && (
            <List
              size="small"
              bordered
              dataSource={selectedAllocation.teamDistribution.members}
              renderItem={(member: TeamMemberAllocation) => (
                <List.Item>
                  <Space style={{ width: '100%', justifyContent: 'space-between' }}>
                    <Text>{member.fullName}</Text>
                    <Text strong>{formatCurrency(member.amount)}</Text>
                  </Space>
                </List.Item>
              )}
            />
          )}
          <div>
            <div style={{ marginBottom: 8 }}>Ghi chú *</div>
            <TextArea rows={3} value={teamNote} onChange={(e) => setTeamNote(e.target.value)} placeholder="Giải ngân sau khi Mentor xác nhận phân phối" />
          </div>
        </Space>
      </Modal>

      {/* Hybrid Fund Modal */}
      <Modal
        title="Tạm ứng Hybrid Fund"
        open={hybridFundVisible}
        onCancel={() => { setHybridFundVisible(false); setHybridReason(''); }}
        onOk={() => handleCreateHybridFund(delayedPayments[0]?.projectId)}
        width={600}
      >
        <Space direction="vertical" style={{ width: '100%' }} size="middle">
          <Alert
            message="Tạm ứng khi doanh nghiệp chậm thanh toán"
            description="Lab sẽ tạm ứng 70% + 20% cho Team và Mentor. Doanh nghiệp phải hoàn trả trong 30 ngày."
            type="warning"
            showIcon
          />
          
          <div>
            <div style={{ marginBottom: 8 }}>Tạm ứng Team (70%)</div>
            <InputNumber
              style={{ width: '100%' }}
              value={hybridTeamAmount}
              onChange={(val) => setHybridTeamAmount(val || 0)}
              formatter={value => `${value}`.replace(/\B(?=(\d{3})+(?!\d))/g, ',')}
              parser={value => Number(value!.replace(/\$\s?|(,*)/g, ''))}
            />
          </div>

          <div>
            <div style={{ marginBottom: 8 }}>Tạm ứng Mentor (20%)</div>
            <InputNumber
              style={{ width: '100%' }}
              value={hybridMentorAmount}
              onChange={(val) => setHybridMentorAmount(val || 0)}
              formatter={value => `${value}`.replace(/\B(?=(\d{3})+(?!\d))/g, ',')}
              parser={value => Number(value!.replace(/\$\s?|(,*)/g, ''))}
            />
          </div>

          <div>
            <Text strong>Tổng tạm ứng: {formatCurrency(hybridTeamAmount + hybridMentorAmount)}</Text>
          </div>

          <div>
            <div style={{ marginBottom: 8 }}>Lý do tạm ứng *</div>
            <TextArea rows={3} value={hybridReason} onChange={(e) => setHybridReason(e.target.value)} placeholder="Doanh nghiệp chậm thanh toán 14 ngày, team cần thanh toán để tiếp tục dự án" />
          </div>
        </Space>
      </Modal>

      {/* Edit Allocation Modal */}
      <Modal
        title="Chỉnh sửa Phân bổ Quỹ"
        open={editModalVisible}
        onCancel={() => {
          setEditModalVisible(false);
          setEditingAllocation(null);
        }}
        onOk={() => {
          const form = document.getElementById('edit-form') as HTMLFormElement;
          if (form) {
            const formData = new FormData(form);
            const status = formData.get('status') as string;
            handleUpdateAllocation({ status });
          }
        }}
        okText="Lưu"
        cancelText="Hủy"
        width={800}
      >
        {editingAllocation && (
          <>
            <Descriptions bordered column={2} size="small" style={{ marginBottom: 16 }}>
              <Descriptions.Item label="Dự án" span={2}>
                <Text strong>{editingAllocation.projectTitle}</Text>
              </Descriptions.Item>
              <Descriptions.Item label="Doanh nghiệp" span={2}>
                {editingAllocation.enterpriseName}
              </Descriptions.Item>
              <Descriptions.Item label="Tổng quỹ">
                <Text strong>{formatCurrency(editingAllocation.allocation.total)}</Text>
              </Descriptions.Item>
              <Descriptions.Item label="Trạng thái hiện tại">
                {getStatusTag(editingAllocation.status)}
              </Descriptions.Item>
              <Descriptions.Item label="Team (70%)">
                {formatCurrency(editingAllocation.allocation.team.amount)}
              </Descriptions.Item>
              <Descriptions.Item label="Trạng thái Team">
                {getStatusTag(editingAllocation.allocation.team.status)}
              </Descriptions.Item>
              <Descriptions.Item label="Mentor (20%)">
                {formatCurrency(editingAllocation.allocation.mentor.amount)}
              </Descriptions.Item>
              <Descriptions.Item label="Trạng thái Mentor">
                {getStatusTag(editingAllocation.allocation.mentor.status)}
              </Descriptions.Item>
              <Descriptions.Item label="Lab (10%)">
                {formatCurrency(editingAllocation.allocation.lab.amount)}
              </Descriptions.Item>
              <Descriptions.Item label="Trạng thái Lab">
                {getStatusTag(editingAllocation.allocation.lab.status)}
              </Descriptions.Item>
            </Descriptions>
            
            <Form id="edit-form" layout="vertical">
              <Form.Item label="Cập nhật Trạng thái">
                <Input.Group compact>
                  <select 
                    name="status" 
                    defaultValue={editingAllocation.status}
                    style={{ width: '100%', padding: '4px 11px', border: '1px solid #d9d9d9', borderRadius: '6px' }}
                  >
                    <option value="ALLOCATED">Đã phân bổ</option>
                    <option value="DISTRIBUTED">Đã phân phối</option>
                    <option value="COMPLETED">Hoàn tất</option>
                  </select>
                </Input.Group>
              </Form.Item>
            </Form>
          </>
        )}
      </Modal>
    </div>
  );
}