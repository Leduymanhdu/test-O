import React from 'react';
import { Table, Tag } from 'antd';

interface Task {
  key: number;
  name: string;
  project: string;
  status: string;
}

const tasks: Task[] = [
  {
    key: 1,
    name: 'Thiết kế giao diện trang đăng nhập',
    project: 'AI Resume Screening',
    status: 'Hoàn thành',
  },
  {
    key: 2,
    name: 'Kết nối API đăng ký',
    project: 'AI Resume Screening',
    status: 'Đang làm',
  },
];

const Tasks: React.FC = () => {
  return (
    <div style={{ padding: 24 }}>
      <h1>Nhiệm vụ</h1>

      <Table
        dataSource={tasks}
        pagination={false}
        columns={[
          {
            title: 'Tên nhiệm vụ',
            dataIndex: 'name',
          },
          {
            title: 'Dự án',
            dataIndex: 'project',
          },
          {
            title: 'Trạng thái',
            dataIndex: 'status',
            render: (status: string) => (
              <Tag color={status === 'Hoàn thành' ? 'green' : 'blue'}>
                {status}
              </Tag>
            ),
          },
        ]}
      />
    </div>
  );
};

export default Tasks;
