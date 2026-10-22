import React, { useEffect, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { Alert, Button, Card, Col, Divider, Progress, Row, Spin, Statistic } from 'antd';
import {
  ClockCircleOutlined,
  FileDoneOutlined,
  ProjectOutlined,
  ReloadOutlined,
  TeamOutlined,
} from '@ant-design/icons';
import { mentorService } from '@/services/mentor/mentorService';
import { IMentorDashboardPayload } from '@/types/mentor.types';
import styles from './MentorDashboard.module.css';

const iconMap: Record<string, React.ReactNode> = {
  students: <TeamOutlined />, 
  projects: <ProjectOutlined />,
  reports: <FileDoneOutlined />,
  pending: <ClockCircleOutlined />,
};

const MentorDashboard: React.FC = () => {
  const navigate = useNavigate();
  const [overview, setOverview] = useState<IMentorDashboardPayload | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    loadOverview();
  }, []);

  const loadOverview = async () => {
    setLoading(true);
    setError(null);
    try {
      const data = await mentorService.getDashboardOverview();
      setOverview(data);
    } catch (err) {
      console.error('Failed to load mentor dashboard', err);
      setError('Không thể tải dữ liệu dashboard.');
    } finally {
      setLoading(false);
    }
  };

  const handleActionClick = (actionId: string) => {
    switch (actionId) {
      case 'invitations':
        navigate('/mentor/invitations');
        break;
      case 'tasks':
        navigate('/mentor/tasks');
        break;
      case 'evaluation':
        navigate('/mentor/evaluation');
        break;
      case 'reports':
        navigate('/mentor/reports/new');
        break;
      default:
        console.log('Unknown action:', actionId);
    }
  };

  if (loading) {
    return (
      <div className={styles.loadingContainer}>
        <Spin size="large" />
      </div>
    );
  }

  if (!overview || error) {
    return (
      <div className={styles.errorContainer}>
        <Alert
          type="error"
          message="Không thể tải dashboard"
          description={error || 'Vui lòng thử lại sau.'}
          showIcon
        />
      </div>
    );
  }

  return (
    <div className={styles.pageWrapper}>
      <div className={styles.dashboardContainer}>
        <div className={styles.header}>
          <div>
            <h1 className={styles.title}>
              Mentor Dashboard
              <span className={styles.subtitle}>Tổng quan hướng dẫn và tiến độ sinh viên</span>
            </h1>
          </div>
          <Button
            type="primary"
            icon={<ReloadOutlined />}
            onClick={loadOverview}
            className={styles.refreshBtn}
          >
            Làm mới
          </Button>
        </div>

        <Divider className={styles.divider} />

        {/* Stats Row */}
        <Row gutter={[16, 16]} className={styles.statsRow}>
          {overview.stats.map((stat) => (
            <Col key={stat.id} xs={24} sm={12} lg={6}>
              <Card className={styles.statCard}>
                <div className={styles.statTitle}>
                  <span className={styles.statIcon}>{iconMap[stat.id] || <TeamOutlined />}</span>
                  {stat.title}
                </div>
                <Statistic value={stat.value} />
                {stat.trend && (
                  <div
                    className={styles.trend}
                    style={{ color: stat.trend.positive ? '#52c41a' : '#ff4d4f' }}
                  >
                    {stat.trend.positive ? '↑' : '↓'} {stat.trend.value}% so với tháng trước
                  </div>
                )}
              </Card>
            </Col>
          ))}
        </Row>

        {/* Quick Actions */}
        <Card title="Thao tác nhanh" className={styles.quickActions}>
          <div className={styles.actionGrid}>
            {overview.quickActions.map((action) => (
              <Card
                key={action.id}
                className={styles.actionCard}
                hoverable
                onClick={() => handleActionClick(action.id)}
              >
                <Button
                  type={action.variant === 'primary' ? 'primary' : 'default'}
                  size="large"
                  block
                  className={styles.actionButton}
                >
                  {action.title}
                </Button>
              </Card>
            ))}
          </div>
        </Card>

        {/* Recent Activity */}
        <Card title="Hoạt động gần đây" className={styles.recentActivity}>
          <div className={styles.activityList}>
            {overview.recentActivities.map((activity) => (
              <div key={activity.id} className={styles.activityItem}>
                <div className={styles.activityText}>{activity.action}</div>
                <div className={styles.activityMeta}>
                  <span
                    className={styles.activityBadge}
                    style={{
                      borderColor:
                        activity.type === 'success'
                          ? '#52c41a'
                          : activity.type === 'warning'
                          ? '#faad14'
                          : '#1890ff',
                      color:
                        activity.type === 'success'
                          ? '#52c41a'
                          : activity.type === 'warning'
                          ? '#faad14'
                          : '#1890ff',
                    }}
                  >
                    {activity.type.toUpperCase()}
                  </span>
                  <span className={styles.activityTime}>{activity.timeAgo}</span>
                </div>
              </div>
            ))}
          </div>
        </Card>
      </div>
    </div>
  );
};

export default MentorDashboard;