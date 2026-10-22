// Talent Dashboard
import React from 'react';
import { Row, Col, Card, Statistic, Button } from 'antd';
import { ProjectOutlined, CheckSquareOutlined, TrophyOutlined } from '@ant-design/icons';
import { useNavigate } from 'react-router-dom';

const TalentDashboard: React.FC = () => {
  const navigate = useNavigate();

  return (
    <div>
      <div style={{ display: 'flex', justifyContent: 'space-between', marginBottom: 24 }}>
        <h1 className="page-title">Dashboard Talent</h1>
        <Button type="primary" onClick={() => navigate('/talent/projects/browse')}>
          Duyệt dự án
        </Button>
      </div>

      <Row gutter={[16, 16]}>
        <Col xs={24} sm={8}>
          <Card>
            <Statistic
              title="Dự án tham gia"
              value={3}
              prefix={<ProjectOutlined />}
              valueStyle={{ color: '#17a2b8' }}
            />
          </Card>
        </Col>
        <Col xs={24} sm={8}>
          <Card>
            <Statistic
              title="Nhiệm vụ hoàn thành"
              value={25}
              prefix={<CheckSquareOutlined />}
              valueStyle={{ color: '#4CAF50' }}
            />
          </Card>
        </Col>
        <Col xs={24} sm={8}>
          <Card>
            <Statistic
              title="Điểm đánh giá"
              value={4.5}
              suffix="/ 5"
              prefix={<TrophyOutlined />}
              valueStyle={{ color: '#FFC107' }}
            />
          </Card>
        </Col>
      </Row>
    </div>
  );
};

export default TalentDashboard;
