import React, { useState, useEffect } from 'react';
import { Card, List, Tag, Button, Input, Select, Typography, Space, Spin, message, Modal } from 'antd';
import {
  ProjectOutlined,
  CalendarOutlined,
  TeamOutlined,
  DollarOutlined,
  SearchOutlined,
} from '@ant-design/icons';
import { talentService, TalentProject } from '../../services/talent/talentService';

const { Title, Text } = Typography;
const { Search } = Input;
const { Option } = Select;

const STATUS_COLOR: Record<string, string> = {
  RECRUITING: 'green',
  IN_PROGRESS: 'blue',
  COMPLETED: 'purple',
  CANCELLED: 'red',
};

const STATUS_LABEL: Record<string, string> = {
  RECRUITING: 'Đang tuyển',
  IN_PROGRESS: 'Đang thực hiện',
  COMPLETED: 'Đã hoàn thành',
  CANCELLED: 'Đã hủy',
};

const ProjectsBrowse: React.FC = () => {
  const [projects, setProjects] = useState<TalentProject[]>([]);
  const [filteredProjects, setFilteredProjects] = useState<TalentProject[]>([]);
  const [loading, setLoading] = useState(true);
  const [searchTerm, setSearchTerm] = useState('');
  const [statusFilter, setStatusFilter] = useState<string>('');
  const [techFilter, setTechFilter] = useState<string>('');
  const [joinModalVisible, setJoinModalVisible] = useState(false);
  const [selectedProject, setSelectedProject] = useState<TalentProject | null>(null);
  const [joining, setJoining] = useState(false);

  useEffect(() => {
    fetchProjects();
  }, []);

  useEffect(() => {
    filterProjects();
  }, [projects, searchTerm, statusFilter, techFilter]);

  const fetchProjects = async () => {
    try {
      setLoading(true);
      const data = await talentService.browseProjects({ page: 0, size: 50 });
      setProjects(data.content || []);
    } catch {
      message.error('Không thể tải danh sách dự án');
    } finally {
      setLoading(false);
    }
  };

  const filterProjects = () => {
    let filtered = projects;
    if (searchTerm) {
      filtered = filtered.filter(
        (p) =>
          p.title.toLowerCase().includes(searchTerm.toLowerCase()) ||
          p.description.toLowerCase().includes(searchTerm.toLowerCase())
      );
    }
    if (statusFilter) filtered = filtered.filter((p) => p.status === statusFilter);
    if (techFilter) {
      filtered = filtered.filter((p) =>
        p.technologies?.some((t) => t.toLowerCase().includes(techFilter.toLowerCase()))
      );
    }
    setFilteredProjects(filtered);
  };

  const confirmJoinProject = async () => {
    if (!selectedProject) return;
    try {
      setJoining(true);
      await talentService.joinProject(selectedProject.id, { message: 'Tôi muốn tham gia dự án này.' });
      message.success('Đã gửi yêu cầu tham gia dự án!');
      setJoinModalVisible(false);
      setSelectedProject(null);
      fetchProjects();
    } catch {
      message.error('Không thể gửi yêu cầu tham gia');
    } finally {
      setJoining(false);
    }
  };

  const allTechnologies = Array.from(new Set(projects.flatMap((p) => p.technologies || []))).sort();

  if (loading) {
    return (
      <div style={{ display: 'flex', justifyContent: 'center', alignItems: 'center', minHeight: '400px' }}>
        <Spin size="large" />
      </div>
    );
  }

  return (
    <div style={{ padding: '24px' }}>
      <Title level={2}>Tìm kiếm dự án</Title>

      <Card style={{ marginBottom: '24px' }}>
        <Space direction="vertical" style={{ width: '100%' }}>
          <div style={{ display: 'flex', gap: '16px', flexWrap: 'wrap' }}>
            <Search
              placeholder="Tìm kiếm dự án..."
              allowClear
              style={{ width: '300px' }}
              prefix={<SearchOutlined />}
              onSearch={setSearchTerm}
              onChange={(e) => setSearchTerm(e.target.value)}
            />
            <Select
              placeholder="Lọc theo trạng thái"
              allowClear
              style={{ width: '180px' }}
              value={statusFilter || undefined}
              onChange={setStatusFilter}
            >
              <Option value="RECRUITING">Đang tuyển</Option>
              <Option value="IN_PROGRESS">Đang thực hiện</Option>
              <Option value="COMPLETED">Đã hoàn thành</Option>
            </Select>
            <Select
              placeholder="Lọc theo công nghệ"
              allowClear
              style={{ width: '200px' }}
              value={techFilter || undefined}
              onChange={setTechFilter}
            >
              {allTechnologies.map((tech) => (
                <Option key={tech} value={tech}>{tech}</Option>
              ))}
            </Select>
          </div>
          <Text type="secondary">
            Hiển thị {filteredProjects.length} / {projects.length} dự án
          </Text>
        </Space>
      </Card>

      <List
        grid={{ gutter: 16, xs: 1, sm: 1, md: 2, lg: 2, xl: 3 }}
        dataSource={filteredProjects}
        renderItem={(project) => (
          <List.Item>
            <Card
              title={project.title}
              size="small"
              extra={
                <Tag color={STATUS_COLOR[project.status] || 'default'}>
                  {STATUS_LABEL[project.status] || project.status}
                </Tag>
              }
              actions={[
                project.status === 'RECRUITING' ? (
                  <Button
                    key="join"
                    type="primary"
                    size="small"
                    icon={<ProjectOutlined />}
                    onClick={() => { setSelectedProject(project); setJoinModalVisible(true); }}
                  >
                    Tham gia
                  </Button>
                ) : (
                  <Button key="view" type="link" size="small">Xem chi tiết</Button>
                ),
              ]}
            >
              <div style={{ marginBottom: '12px' }}>
                <Text type="secondary">{project.description}</Text>
              </div>
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
                    {project.technologies.slice(0, 3).map((tech, i) => <Tag key={i}>{tech}</Tag>)}
                    {project.technologies.length > 3 && (
                      <Tag>+{project.technologies.length - 3}</Tag>
                    )}
                  </div>
                )}
                <div>
                  <TeamOutlined style={{ marginRight: '8px' }} />
                  <Text>{project.numberOfStudents} thành viên cần tuyển</Text>
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
                {project.skillRequirements && project.skillRequirements.length > 0 && (
                  <div>
                    <Text strong>Yêu cầu: </Text>
                    <Text type="secondary">{project.skillRequirements.join(', ')}</Text>
                  </div>
                )}
              </Space>
            </Card>
          </List.Item>
        )}
      />

      <Modal
        title="Xác nhận tham gia dự án"
        open={joinModalVisible}
        onOk={confirmJoinProject}
        onCancel={() => { setJoinModalVisible(false); setSelectedProject(null); }}
        okText="Gửi yêu cầu"
        cancelText="Hủy"
        confirmLoading={joining}
      >
        {selectedProject && (
          <div>
            <Title level={4}>{selectedProject.title}</Title>
            <Text>{selectedProject.description}</Text>
            <div style={{ marginTop: '16px' }}>
              <Text strong>Bạn có chắc muốn tham gia dự án này không?</Text>
            </div>
            <div style={{ marginTop: '8px', color: '#999' }}>
              Yêu cầu của bạn sẽ được mentor của dự án xét duyệt.
            </div>
          </div>
        )}
      </Modal>
    </div>
  );
};

export default ProjectsBrowse;
