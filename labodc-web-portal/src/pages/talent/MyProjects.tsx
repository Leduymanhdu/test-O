import React, { useState, useEffect } from 'react';
import { Card, List, Tag, Button, Progress, Typography, Space, Empty, Modal, Descriptions, Spin, message } from 'antd';
import { ProjectOutlined, CalendarOutlined, TeamOutlined, DollarOutlined } from '@ant-design/icons';
import { talentService, TalentProject } from '../../services/talent/talentService';
import { useNavigate } from 'react-router-dom';

const { Title, Text } = Typography;

const STATUS_COLOR: Record<string, string> = {
  PENDING: 'orange',
  ACTIVE: 'green',
  INACTIVE: 'purple',
  REJECTED: 'red',
};

const STATUS_LABEL: Record<string, string> = {
  PENDING: 'Chờ duyệt',
  ACTIVE: 'Đang tham gia',
  INACTIVE: 'Đã kết thúc',
  REJECTED: 'Bị từ chối',
};

const STATUS_HELP: Record<string, string> = {
  PENDING: 'Đơn tham gia đang chờ mentor/quản trị duyệt.',
  ACTIVE: 'Bạn đã được duyệt và đang là thành viên của dự án.',
  INACTIVE: 'Bạn đã rời dự án hoặc dự án kết thúc.',
  REJECTED: 'Đơn tham gia đã bị từ chối.',
};

const MyProjects: React.FC = () => {
  const [projects, setProjects] = useState<TalentProject[]>([]);
  const [loading, setLoading] = useState(true);
  const [detailOpen, setDetailOpen] = useState(false);
  const [detailLoading, setDetailLoading] = useState(false);
  const [detailData, setDetailData] = useState<TalentProject | null>(null);
  const navigate = useNavigate();

  useEffect(() => {
    fetchMyProjects();
  }, []);

  const fetchMyProjects = async () => {
    try {
      setLoading(true);
      const data = await talentService.getMyProjects();
      setProjects(data);
    } catch {
      message.error('Không thể tải dự án của bạn từ hệ thống.');
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

  return (
    <div style={{ padding: '24px' }}>
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '24px' }}>
        <Title level={2} style={{ margin: 0 }}>Dự án của tôi</Title>
        <Button type="primary" icon={<ProjectOutlined />} onClick={() => navigate('/talent/projects')}>
          Tìm thêm dự án
        </Button>
      </div>

      {projects.length === 0 ? (
        <Card>
          <Empty description="Bạn chưa tham gia dự án nào" image={Empty.PRESENTED_IMAGE_SIMPLE}>
            <Button type="primary" onClick={() => navigate('/talent/projects')}>
              Tìm kiếm dự án
            </Button>
          </Empty>
        </Card>
      ) : (
        <List
          grid={{ gutter: 16, xs: 1, sm: 1, md: 2, lg: 2, xl: 3 }}
          dataSource={projects}
          renderItem={(project) => (
            <List.Item>
              <Card
                title={project.title}
                size="small"
                extra={
                  <Space>
                    {project.memberRole && (
                      <Tag color={project.memberRole === 'LEADER' ? 'gold' : 'blue'}>
                        {project.memberRole === 'LEADER' ? 'Trưởng nhóm' : 'Thành viên'}
                      </Tag>
                    )}
                    {project.memberStatus && (
                      <Tag color={STATUS_COLOR[project.memberStatus] || 'default'}>
                        {STATUS_LABEL[project.memberStatus] || project.memberStatus}
                      </Tag>
                    )}
                  </Space>
                }
                actions={[
                  <Button
                    key="view"
                    type="link"
                    size="small"
                    onClick={async () => {
                      try {
                        setDetailLoading(true);
                        const detail = await talentService.getProjectDetail(project.id);
                        setDetailData(detail);
                        setDetailOpen(true);
                      } catch {
                        message.error('Không thể tải chi tiết dự án');
                      } finally {
                        setDetailLoading(false);
                      }
                    }}
                  >
                    Xem chi tiết
                  </Button>,
                  project.memberStatus === 'ACTIVE' && (
                    <Button
                      key="tasks"
                      type="link"
                      size="small"
                      onClick={() => navigate(`/talent/tasks?projectId=${project.id}`)}
                    >
                      Nhiệm vụ
                    </Button>
                  ),
                ].filter(Boolean)}
              >
                <div style={{ marginBottom: '8px' }}>
                  <Text type="secondary">{project.description}</Text>
                </div>

                {project.memberStatus && STATUS_HELP[project.memberStatus] && (
                  <div style={{ marginBottom: '8px' }}>
                    <Text type="secondary" style={{ fontSize: '12px' }}>
                      {STATUS_HELP[project.memberStatus]}
                    </Text>
                  </div>
                )}

                <Space direction="vertical" style={{ width: '100%' }}>
                  {project.company && (
                    <div>
                      <Text strong>Công ty: </Text>
                      <Text>{project.company.name}</Text>
                    </div>
                  )}
                  <div>
                    <CalendarOutlined style={{ marginRight: '8px' }} />
                    <Text>
                      {new Date(project.startDate).toLocaleDateString('vi-VN')} -{' '}
                      {new Date(project.endDate).toLocaleDateString('vi-VN')}
                    </Text>
                  </div>
                  {project.technologies && project.technologies.length > 0 && (
                    <div>
                      <Text strong style={{ display: 'block', marginBottom: '4px' }}>Công nghệ:</Text>
                      {project.technologies.map((tech, i) => <Tag key={i}>{tech}</Tag>)}
                    </div>
                  )}
                  <div>
                    <TeamOutlined style={{ marginRight: '8px' }} />
                    <Text>{project.numberOfStudents} thành viên</Text>
                  </div>
                  {project.budget && (
                    <div>
                      <DollarOutlined style={{ marginRight: '8px' }} />
                      <Text>{project.budget.toLocaleString()} VND</Text>
                      {project.allowancePerStudent && (
                        <Text type="secondary"> ({project.allowancePerStudent})</Text>
                      )}
                    </div>
                  )}
                  {project.memberStatus === 'ACTIVE' && (
                    <div>
                      <Text strong>Tiến độ:</Text>
                      <Progress percent={project.status === 'COMPLETED' ? 100 : 0} size="small" />
                    </div>
                  )}
                </Space>
              </Card>
            </List.Item>
          )}
        />
      )}

      <Modal
        title="Chi tiết dự án"
        open={detailOpen}
        onCancel={() => { setDetailOpen(false); setDetailData(null); }}
        footer={null}
        confirmLoading={detailLoading}
      >
        <Descriptions bordered size="small" column={1} labelStyle={{ width: 160 }}>
          <Descriptions.Item label="Tên dự án">{detailData?.title ?? '-'}</Descriptions.Item>
          <Descriptions.Item label="Trạng thái">{detailData?.status ?? '-'}</Descriptions.Item>
          <Descriptions.Item label="Mô tả">{detailData?.description ?? '-'}</Descriptions.Item>
          <Descriptions.Item label="Công ty">{detailData?.company?.name ?? '-'}</Descriptions.Item>
          <Descriptions.Item label="Ngân sách">
            {detailData?.budget ? `${detailData.budget.toLocaleString()} VND` : '-'}
          </Descriptions.Item>
          <Descriptions.Item label="Thời gian">
            {detailData?.startDate
              ? `${new Date(detailData.startDate).toLocaleDateString('vi-VN')} - ${new Date(detailData.endDate).toLocaleDateString('vi-VN')}`
              : '-'}
          </Descriptions.Item>
          <Descriptions.Item label="Công nghệ">
            {detailData?.technologies?.length ? detailData.technologies.join(', ') : '-'}
          </Descriptions.Item>
          <Descriptions.Item label="Yêu cầu kỹ năng">
            {detailData?.skillRequirements?.length ? detailData.skillRequirements.join(', ') : '-'}
          </Descriptions.Item>
        </Descriptions>
      </Modal>
    </div>
  );
};

export default MyProjects;
