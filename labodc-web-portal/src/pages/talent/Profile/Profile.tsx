import React from 'react';
import { Card, Avatar, Descriptions } from 'antd';
import { UserOutlined } from '@ant-design/icons';

const Profile: React.FC = () => {
  return (
    <div style={{ padding: 24 }}>
        
      <h1> Hồ sơ cá nhân </h1>

      <Card>
        <Avatar
          size={80}
          icon={<UserOutlined />}
          style={{ marginBottom: 16 }}
        />

        <Descriptions column={1} bordered>
          <Descriptions.Item label="Họ tên">
            Huỳnh Cao Đức
          </Descriptions.Item>
          <Descriptions.Item label="Vai trò">
            Talent / Sinh viên
          </Descriptions.Item>
          <Descriptions.Item label="Email">
            duc@example.com
          </Descriptions.Item>
          <Descriptions.Item label="Kỹ năng">
            React, TypeScript, Java, SQL
          </Descriptions.Item>
        </Descriptions>
      </Card>
    </div>
  );
};

export default Profile;
