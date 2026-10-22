import React, { useState, useEffect } from 'react';
import {
  Card,
  Row,
  Col,
  Statistic,
  List,
  Button,
  Space,
  Tag,
  Typography,
  Table,
  Progress,
  Modal,
  Form,
  Input,
  InputNumber,
  Select,
  message,
} from 'antd';
import {
  TeamOutlined,
  DollarOutlined,
  FileTextOutlined,
  BarChartOutlined,
  UserOutlined,
  CalendarOutlined,
  CheckCircleOutlined,
  ClockCircleOutlined,
} from '@ant-design/icons';
import { talentService } from '../../services/talent/talentService';
import { useParams } from 'react-router-dom';

const { Title, Text } = Typography;
const { TextArea } = Input;
const { Option } = Select;

interface TeamMember {
  id: string;
  name: string;
  role: string;
  contribution: number;
}

interface FundDistribution {
  id: number;
  talentId: string;
  amount: number;
  description: string;
  status: string;
  createdAt: string;
}

const TalentLeaderDashboard: React.FC = () => {
  const { projectId } = useParams<{ projectId: string }>();
  const [loading, setLoading] = useState(true);
  const [teamMembers, setTeamMembers] = useState<TeamMember[]>([]);
  const [fundDistributions, setFundDistributions] = useState<FundDistribution[]>([]);
  const [showFundModal, setShowFundModal] = useState(false);
  const [showReportModal, setShowReportModal] = useState(false);
  const [form] = Form.useForm();
  const [reportForm] = Form.useForm();

  useEffect(() => {
    if (projectId) {
      fetchLeaderData();
    }
  }, [projectId]);

  const fetchLeaderData = async () => {
    try {
      setLoading(true);
      // Fetch team members, fund distributions, etc.
      // This would call actual API endpoints
      const mockTeamMembers = [
        { id: '1', name: 'Nguyễn Văn A', role: 'Frontend Developer', contribution: 85 },
        { id: '2', name: 'Trần Thị B', role: 'Backend Developer', contribution: 92 },
        { id: '3', name: 'Lê Văn C', role: 'UI/UX Designer', contribution: 78 },
      ];
      setTeamMembers(mockTeamMembers);
    } catch (error) {
      console.error('Failed to fetch leader data:', error);
    } finally {
      setLoading(false);
    }
  };

  const handleFundDistribution = async (values: any) => {
    try {
      // Call fund distribution API
      message.success('Fund distribution submitted successfully!');
      setShowFundModal(false);
      form.resetFields();
    } catch (error) {
      message.error('Failed to distribute funds');
    }
  };

  const handleReportSubmission = async (values: any) => {
    try {
      // Call team report submission API
      message.success('Team report submitted successfully!');
      setShowReportModal(false);
      reportForm.resetFields();
    } catch (error) {
      message.error('Failed to submit report');
    }
  };

  const teamColumns = [
    {
      title: 'Member',
      dataIndex: 'name',
      key: 'name',
      render: (name: string, record: TeamMember) => (
        <Space>
          <UserOutlined />
          <div>
            <div>{name}</div>
            <Text type="secondary">{record.role}</Text>
          </div>
        </Space>
      ),
    },
    {
      title: 'Contribution',
      dataIndex: 'contribution',
      key: 'contribution',
      render: (contribution: number) => <Progress percent={contribution} size="small" />,
    },
    {
      title: 'Actions',
      key: 'actions',
      render: (record: TeamMember) => (
        <Space>
          <Button size="small">View Details</Button>
          <Button size="small" type="link">
            Send Message
          </Button>
        </Space>
      ),
    },
  ];

  if (loading) {
    return <div>Loading leader dashboard...</div>;
  }

  return (
    <div style={{ padding: '24px' }}>
      <Title level={2}>Project Leadership Dashboard</Title>

      {/* Stats Cards */}
      <Row gutter={[16, 16]} style={{ marginBottom: '24px' }}>
        <Col xs={24} sm={12} lg={6}>
          <Card>
            <Statistic
              title="Team Members"
              value={teamMembers.length}
              prefix={<TeamOutlined />}
              valueStyle={{ color: '#1890ff' }}
            />
          </Card>
        </Col>
        <Col xs={24} sm={12} lg={6}>
          <Card>
            <Statistic
              title="Budget Distributed"
              value={65}
              suffix="%"
              prefix={<DollarOutlined />}
              valueStyle={{ color: '#52c41a' }}
            />
          </Card>
        </Col>
        <Col xs={24} sm={12} lg={6}>
          <Card>
            <Statistic
              title="Reports Submitted"
              value={4}
              prefix={<FileTextOutlined />}
              valueStyle={{ color: '#722ed1' }}
            />
          </Card>
        </Col>
        <Col xs={24} sm={12} lg={6}>
          <Card>
            <Statistic
              title="Project Progress"
              value={78}
              suffix="%"
              prefix={<BarChartOutlined />}
              valueStyle={{ color: '#fadb14' }}
            />
          </Card>
        </Col>
      </Row>

      <Row gutter={[16, 16]}>
        {/* Team Management */}
        <Col xs={24} lg={16}>
          <Card
            title="Team Management"
            extra={
              <Space>
                <Button type="primary" onClick={() => setShowReportModal(true)}>
                  Submit Report
                </Button>
                <Button onClick={() => setShowFundModal(true)}>Distribute Funds</Button>
              </Space>
            }
          >
            <Table dataSource={teamMembers} columns={teamColumns} pagination={false} rowKey="id" />
          </Card>
        </Col>

        {/* Quick Actions */}
        <Col xs={24} lg={8}>
          <Card title="Quick Actions">
            <Space direction="vertical" style={{ width: '100%' }}>
              <Button type="primary" block icon={<FileTextOutlined />}>
                Weekly Report
              </Button>
              <Button block icon={<DollarOutlined />}>
                Fund Management
              </Button>
              <Button block icon={<TeamOutlined />}>
                Team Performance
              </Button>
              <Button block icon={<CalendarOutlined />}>
                Schedule Meeting
              </Button>
            </Space>
          </Card>
        </Col>
      </Row>

      {/* Fund Distribution Modal */}
      <Modal
        title="Distribute Funds"
        open={showFundModal}
        onCancel={() => setShowFundModal(false)}
        footer={null}
      >
        <Form form={form} layout="vertical" onFinish={handleFundDistribution}>
          <Form.Item label="Team Member" name="talentId" rules={[{ required: true }]}>
            <Select placeholder="Select team member">
              {teamMembers.map((member) => (
                <Option key={member.id} value={member.id}>
                  {member.name}
                </Option>
              ))}
            </Select>
          </Form.Item>

          <Form.Item label="Amount (VND)" name="amount" rules={[{ required: true }]}>
            <InputNumber
              style={{ width: '100%' }}
              min={0}
              formatter={(value) => `${value}`.replace(/\B(?=(\d{3})+(?!\d))/g, ',')}
            />
          </Form.Item>

          <Form.Item label="Description" name="description">
            <TextArea rows={3} placeholder="Fund distribution purpose..." />
          </Form.Item>

          <Form.Item label="Justification" name="justification">
            <TextArea rows={2} placeholder="Justification for this distribution..." />
          </Form.Item>

          <Form.Item>
            <Space>
              <Button type="primary" htmlType="submit">
                Distribute
              </Button>
              <Button onClick={() => setShowFundModal(false)}>Cancel</Button>
            </Space>
          </Form.Item>
        </Form>
      </Modal>

      {/* Team Report Modal */}
      <Modal
        title="Submit Team Report"
        open={showReportModal}
        onCancel={() => setShowReportModal(false)}
        footer={null}
        width={800}
      >
        <Form form={reportForm} layout="vertical" onFinish={handleReportSubmission}>
          <Form.Item label="Report Period" name="reportPeriod" rules={[{ required: true }]}>
            <Input placeholder="e.g., Week 1, Month 1" />
          </Form.Item>

          <Form.Item label="Progress (%)" name="progress" rules={[{ required: true }]}>
            <InputNumber style={{ width: '100%' }} min={0} max={100} />
          </Form.Item>

          <Form.Item label="Achievements" name="achievements" rules={[{ required: true }]}>
            <TextArea rows={4} placeholder="What did the team accomplish this period?" />
          </Form.Item>

          <Form.Item label="Challenges" name="challenges">
            <TextArea rows={3} placeholder="What challenges did the team face?" />
          </Form.Item>

          <Form.Item label="Next Steps" name="nextSteps">
            <TextArea rows={3} placeholder="What are the plans for next period?" />
          </Form.Item>

          <Form.Item label="Additional Notes" name="additionalNotes">
            <TextArea rows={2} placeholder="Any additional information..." />
          </Form.Item>

          <Form.Item>
            <Space>
              <Button type="primary" htmlType="submit">
                Submit Report
              </Button>
              <Button onClick={() => setShowReportModal(false)}>Cancel</Button>
            </Space>
          </Form.Item>
        </Form>
      </Modal>
    </div>
  );
};

export default TalentLeaderDashboard;
