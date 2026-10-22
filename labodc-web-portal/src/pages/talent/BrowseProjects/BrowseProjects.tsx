import React from 'react';
import { Card, Row, Col, Tag, Button } from 'antd';

const mockProjects = [
  {
    id: 1,
    name: 'AI Resume Screening',
    company: 'LabODC',
    description: 'Xây dựng hệ thống AI hỗ trợ lọc CV tự động.',
    tech: ['React', 'NodeJS', 'AI'],
  },
  {
    id: 2,
    name: 'E-Learning Platform',
    company: 'UTH',
    description: 'Nền tảng học trực tuyến cho sinh viên.',
    tech: ['Java', 'Spring', 'MySQL'],
  },
];

const BrowseProjects: React.FC = () => {
  return (
    <div style={{ padding: 24 }}>
      <h1>Duyệt dự án</h1>

      <Row gutter={[16, 16]}>
        {mockProjects.map(project => (
          <Col span={12} key={project.id}>
            <Card
              title={project.name}
              extra={<Button type="primary">Tham gia</Button>}
            >
              <p><strong>Đơn vị:</strong> {project.company}</p>
              <p>{project.description}</p>
              <div>
                {project.tech.map(t => (
                  <Tag key={t} color="blue">{t}</Tag>
                ))}
              </div>
            </Card>
          </Col>
        ))}
      </Row>
    </div>
  );
};

export default BrowseProjects;
