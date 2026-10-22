import React from 'react';
import { Card, Tag, Progress } from 'antd';

const myProjects = [
  {
    id: 1,
    name: 'AI Resume Screening',
    role: 'Frontend Developer',
    progress: 65,
    status: 'Đang thực hiện',
  },
  {
    id: 2,
    name: 'E-Commerce Website',
    role: 'Backend Developer',
    progress: 100,
    status: 'Hoàn thành',
  },
];

const MyProjects: React.FC = () => {
  return (
    <div style={{ padding: 24 }}>
      <h1>Dự án của tôi</h1>

      {myProjects.map(project => (
        <Card key={project.id} style={{ marginBottom: 16 }}>
          <h3>{project.name}</h3>
          <p><strong>Vai trò:</strong> {project.role}</p>
          <Tag color={project.progress === 100 ? 'green' : 'orange'}>
            {project.status}
          </Tag>
          <Progress percent={project.progress} />
        </Card>
      ))}
    </div>
  );
};

export default MyProjects;
