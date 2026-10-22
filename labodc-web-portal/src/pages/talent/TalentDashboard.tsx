import React, { useState, useEffect } from 'react';
import { Card, Row, Col, Statistic, List, Progress, Tag, Typography, Button, Space, Empty, Spin, Alert } from 'antd';
import {
  ProjectOutlined,
  TrophyOutlined,
  StarOutlined,
  ToolOutlined,
  SafetyCertificateOutlined,
  UserOutlined,
} from '@ant-design/icons';
import {
  talentService,
  TalentDashboard as TalentDashboardType,
} from '../../services/talent/talentService';
import { useNavigate } from 'react-router-dom';

const { Title, Text } = Typography;

const STATUS_COLOR: Record<string, string> = {
  RECRUITING: 'green',
  IN_PROGRESS: 'blue',
  COMPLETED: 'purple',
  PENDING: 'orange',
  APPROVED: 'green',
  ACTIVE: 'blue',
};

const TalentDashboard: React.FC = () => {
  const [dashboard, setDashboard] = useState<TalentDashboardType | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const navigate = useNavigate();

  useEffect(() => {
    fetchDashboard();
  }, []);

  const fetchDashboard = async () => {
    try {
      setLoading(true);
      setError(null);
      const data = await talentService.getDashboard();
      setDashboard(data);
    } catch (err: any) {
      setError(err?.message || 'Không thể tải dữ liệu dashboard. Vui lòng thử lại.');
    } finally {
      setLoading(false);
    }
  };

  if (loading) {
    return (
      <div style={{ display: 'flex', justifyContent: 'center', alignItems: 'center', minHeight: '400px' }}>
        <Spin size="large" />
      </div>
    );
  }

  if (error || !dashboard) {
    return (
      <div style={{ padding: '24px' }}>
        <Alert
          type="error"
          message="Không thể tải dữ liệu"
          description={error}
          showIcon
          action={<Button size="small" onClick={fetchDashboard}>Thử lại</Button>}
        />
      </div>
    );
  }

  return (
    <div style={{ padding: '24px' }}>
      <Title level={2}>Dashboard Sinh viên</Title>

      <Row gutter={[16, 16]} style={{ marginBottom: '24px' }}>
        <Col xs={24} sm={12} lg={8}>
          <Card>
            <Statistic
              title="Tổng dự án"
              value={dashboard.stats.totalProjects}
              prefix={<ProjectOutlined />}
              valueStyle={{ color: '#1890ff' }}
            />
          </Card>
        </Col>
        <Col xs={24} sm={12} lg={8}>
          <Card>
            <Statistic
              title="Đã hoàn thành"
              value={dashboard.stats.completedProjects}
              prefix={<TrophyOutlined />}
              valueStyle={{ color: '#52c41a' }}
            />
          </Card>
        </Col>
        <Col xs={24} sm={12} lg={8}>
          <Card>
            <Statistic
              title="Đang thực hiện"
              value={dashboard.stats.ongoingProjects}
              prefix={<ProjectOutlined />}
              valueStyle={{ color: '#faad14' }}
            />
          </Card>
        </Col>
        <Col xs={24} sm={12} lg={8}>
          <Card>
            <Statistic
              title="Đánh giá trung bình"
              value={dashboard.stats.averageRating}
              precision={1}
              prefix={<StarOutlined />}
              suffix="/ 5"
              valueStyle={{ color: '#fadb14' }}
            />
          </Card>
        </Col>
        <Col xs={24} sm={12} lg={8}>
          <Card>
            <Statistic
              title="Kỹ năng"
              value={dashboard.stats.totalSkills}
              prefix={<ToolOutlined />}
              valueStyle={{ color: '#722ed1' }}
            />
          </Card>
        </Col>
        <Col xs={24} sm={12} lg={8}>
          <Card>
            <Statistic
              title="Chứng chỉ"
              value={dashboard.stats.totalCertifications}
              prefix={<SafetyCertificateOutlined />}
              valueStyle={{ color: '#13c2c2' }}
            />
          </Card>
        </Col>
      </Row>

      <Row gutter={[16, 16]}>
        <Col xs={24} lg={8}>
          <Card title="Hoàn thiện hồ sơ" size="small">
            <div style={{ textAlign: 'center', marginBottom: '16px' }}>
              <Progress
                type="circle"
                percent={dashboard.profileCompletion.percentage}
                size={120}
                strokeColor={{ '0%': '#108ee9', '100%': '#87d068' }}
              />
            </div>
            {dashboard.profileCompletion.missingFields.length > 0 && (
              <div>
                <Text strong>Thông tin còn thiếu:</Text>
                <div style={{ marginTop: '8px' }}>
                  {dashboard.profileCompletion.missingFields.map((field, index) => (
                    <Tag key={index} color="orange" style={{ marginBottom: '4px' }}>
                      {field}
                    </Tag>
                  ))}
                </div>
                <Button
                  type="primary"
                  size="small"
                  style={{ marginTop: '12px' }}
                  onClick={() => navigate('/talent/profile')}
                >
                  Hoàn thiện hồ sơ
                </Button>
              </div>
            )}
          </Card>
        </Col>

        <Col xs={24} lg={8}>
          <Card title="Thông báo" size="small">
            {dashboard.notifications && dashboard.notifications.length > 0 ? (
              <List
                size="small"
                dataSource={dashboard.notifications}
                renderItem={(item) => <List.Item>{item}</List.Item>}
              />
            ) : (
              <Empty description="Chưa có thông báo" image={Empty.PRESENTED_IMAGE_SIMPLE} />
            )}
          </Card>
        </Col>

        <Col xs={24} lg={16}>
          <Card
            title="Dự án gần đây"
            size="small"
            extra={
              <Space>
                <Button size="small" onClick={() => navigate('/talent/projects')}>
                  Tìm dự án
                </Button>
                <Button size="small" onClick={() => navigate('/talent/my-projects')}>
                  Dự án của tôi
                </Button>
              </Space>
            }
          >
            <List
              itemLayout="horizontal"
              dataSource={dashboard.recentProjects.slice(0, 5)}
              renderItem={(project) => (
                <List.Item
                  actions={[
                    <Tag color={STATUS_COLOR[project.status] || 'default'}>{project.status}</Tag>,
                    project.memberRole && <Tag color="blue">{project.memberRole}</Tag>,
                  ]}
                >
                  <List.Item.Meta
                    title={project.title}
                    description={project.description?.substring(0, 80) + '...'}
                  />
                </List.Item>
              )}
            />
          </Card>
        </Col>
      </Row>

      <Card title="Thao tác nhanh" style={{ marginTop: '16px' }}>
        <Space wrap>
          <Button type="primary" icon={<ProjectOutlined />} onClick={() => navigate('/talent/projects')}>
            Tìm dự án
          </Button>
          <Button icon={<UserOutlined />} onClick={() => navigate('/talent/profile')}>
            Chỉnh sửa hồ sơ
          </Button>
          <Button icon={<ToolOutlined />} onClick={() => navigate('/talent/profile?tab=skills')}>
            Quản lý kỹ năng
          </Button>
          <Button
            icon={<SafetyCertificateOutlined />}
            onClick={() => navigate('/talent/profile?tab=certifications')}
          >
            Thêm chứng chỉ
          </Button>
        </Space>
      </Card>
    </div>
  );
};

export default TalentDashboard;
