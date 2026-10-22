import React, { useState, useEffect } from 'react';
import { Table, Button, Modal, Form, Input, Tag, Space, Tooltip, InputNumber, Select, DatePicker, App } from 'antd';
import { EditOutlined, DeleteOutlined, CheckCircleOutlined } from '@ant-design/icons';
import { projectAdminService, ProjectDTO } from '../../services/projectAdminService';
import type { ColumnsType } from 'antd/es/table';
import dayjs from 'dayjs';

const Projects: React.FC = () => {
  const { message: messageApi } = App.useApp();
  const [projects, setProjects] = useState<ProjectDTO[]>([]);
  const [loading, setLoading] = useState(false);
  const [pagination, setPagination] = useState({ current: 1, pageSize: 10, total: 0 });
  const [editModalVisible, setEditModalVisible] = useState(false);
  const [selectedProject, setSelectedProject] = useState<ProjectDTO | null>(null);
  const [form] = Form.useForm();
  
  // Filter states
  const [searchText, setSearchText] = useState<string>('');
  const [statusFilter, setStatusFilter] = useState<string | undefined>(undefined);
  const [validatedFilter, setValidatedFilter] = useState<string | undefined>(undefined);

  useEffect(() => {
    fetchProjects(pagination.current - 1, pagination.pageSize);
  }, [searchText, statusFilter, validatedFilter]);

  const fetchProjects = async (page: number, size: number) => {
    setLoading(true);
    try {
      const data = await projectAdminService.getAllProjects(page, size);
      
      // Apply client-side filtering
      let filtered = data.content;
      
      if (searchText) {
        const search = searchText.toLowerCase();
        filtered = filtered.filter(project => 
          project.title?.toLowerCase().includes(search) ||
          project.enterpriseName?.toLowerCase().includes(search) ||
          project.slug?.toLowerCase().includes(search)
        );
      }
      
      if (statusFilter) {
        filtered = filtered.filter(project => project.status === statusFilter);
      }
      
      if (validatedFilter) {
        filtered = filtered.filter(project => {
          const validatedStr = String(project.validated);
          if (validatedFilter === 'pending') return validatedStr === 'pending' || project.validated === false;
          if (validatedFilter === 'approved') return validatedStr === 'approved' || project.validated === true;
          if (validatedFilter === 'rejected') return validatedStr === 'rejected';
          return true;
        });
      }
      
      setProjects(filtered);
      setPagination({
        current: data.number + 1,
        pageSize: data.size,
        total: filtered.length
      });
    } catch (error) {
      messageApi.error('Không thể tải danh sách dự án');
      console.error(error);
    } finally {
      setLoading(false);
    }
  };

  const handleTableChange = (newPagination: any) => {
    fetchProjects(newPagination.current - 1, newPagination.pageSize);
  };

  const handleEdit = (record: ProjectDTO) => {
    setSelectedProject(record);
    const formValues = {
      ...record,
      startDate: record.startDate ? dayjs(record.startDate) : null,
      endDate: record.endDate ? dayjs(record.endDate) : null,
    };
    form.setFieldsValue(formValues);
    setEditModalVisible(true);
  };

  const handleUpdate = async () => {
    try {
      const values = await form.validateFields();
      if (selectedProject) {
        const updateData = {
          ...values,
          startDate: values.startDate ? values.startDate.format('YYYY-MM-DD') : null,
          endDate: values.endDate ? values.endDate.format('YYYY-MM-DD') : null,
        };
        await projectAdminService.updateProject(selectedProject.id, updateData);
        messageApi.success('Cập nhật dự án thành công');
        setEditModalVisible(false);
        fetchProjects(pagination.current - 1, pagination.pageSize);
      }
    } catch (error) {
      messageApi.error('Không thể cập nhật dự án');
      console.error(error);
    }
  };

  const handleDelete = async (id: number) => {
    Modal.confirm({
      title: 'Xác nhận xóa',
      content: 'Bạn có chắc chắn muốn xóa dự án này?',
      okText: 'Xóa',
      okType: 'danger',
      cancelText: 'Hủy',
      onOk: async () => {
        try {
          await projectAdminService.deleteProject(id);
          messageApi.success('Xóa dự án thành công');
          fetchProjects(pagination.current - 1, pagination.pageSize);
        } catch (error) {
          messageApi.error('Không thể xóa dự án');
          console.error(error);
        }
      }
    });
  };
  
  const handleReject = async (id: number) => {
    Modal.confirm({
      title: 'Từ chối dự án',
      content: (
        <Form>
          <Form.Item label="Lý do từ chối" name="reason" rules={[{ required: true }]}>
            <Input.TextArea rows={4} id="reject-reason" />
          </Form.Item>
        </Form>
      ),
      okText: 'Từ chối',
      okType: 'danger',
      cancelText: 'Hủy',
      onOk: async () => {
        try {
          const reason = (document.getElementById('reject-reason') as HTMLTextAreaElement)?.value || 'Không phù hợp';
          await projectAdminService.rejectProject(id, reason);
          messageApi.success('Từ chối dự án thành công');
          fetchProjects(pagination.current - 1, pagination.pageSize);
        } catch (error) {
          messageApi.error('Không thể từ chối dự án');
          console.error(error);
        }
      }
    });
  };

  const handleValidate = async (id: number) => {
    Modal.confirm({
      title: 'Xác nhận duyệt dự án',
      content: 'Bạn có chắc chắn muốn duyệt dự án này?',
      okText: 'Duyệt',
      cancelText: 'Hủy',
      onOk: async () => {
        try {
          await projectAdminService.validateProject(id);
          messageApi.success('Xác thực dự án thành công');
          fetchProjects(pagination.current - 1, pagination.pageSize);
        } catch (error) {
          messageApi.error('Không thể xác thực dự án');
          console.error(error);
        }
      }
    });
  };

  const statusColors: { [key: string]: string } = {
    DRAFT: 'default',
    OPEN: 'blue',
    IN_PROGRESS: 'processing',
    COMPLETED: 'success',
    CANCELLED: 'error',
  };

  const columns: ColumnsType<ProjectDTO> = [
    {
      title: 'ID',
      dataIndex: 'id',
      key: 'id',
      width: 60,
    },
    {
      title: 'Dự án',
      key: 'project',
      render: (_, record: ProjectDTO) => (
        <div>
          <div style={{ fontWeight: 500 }}>{record.title}</div>
          <div style={{ fontSize: 12, color: '#999' }}>{record.slug}</div>
        </div>
      ),
      width: 250,
    },
    {
      title: 'Doanh nghiệp',
      dataIndex: 'enterpriseName',
      key: 'enterpriseName',
    },
    {
      title: 'Mentor',
      dataIndex: 'mentorName',
      key: 'mentorName',
    },
    {
      title: 'Ngân sách',
      key: 'budget',
      render: (_, record: ProjectDTO) => 
        record.budget 
          ? `${record.budget.toLocaleString()} ${record.currency || 'VND'}`
          : '-',
    },
    {
      title: 'Thời gian',
      key: 'timeline',
      render: (_, record: ProjectDTO) => (
        <div>
          <div style={{ fontSize: 12 }}>
            {record.startDate ? dayjs(record.startDate).format('DD/MM/YYYY') : '-'}
          </div>
          <div style={{ fontSize: 12 }}>
            {record.endDate ? dayjs(record.endDate).format('DD/MM/YYYY') : '-'}
          </div>
          {record.durationWeeks && (
            <div style={{ fontSize: 11, color: '#999' }}>{record.durationWeeks} tuần</div>
          )}
        </div>
      ),
    },
    {
      title: 'Tiến độ',
      dataIndex: 'progressPercentage',
      key: 'progressPercentage',
      render: (progress: number) => `${progress || 0}%`,
    },
    {
      title: 'Sinh viên',
      key: 'students',
      render: (_, record: ProjectDTO) => (
        <div>
          {record.currentMembers || 0} / {record.numberOfStudents || 0}
        </div>
      ),
    },
    {
      title: 'Công nghệ',
      dataIndex: 'technologies',
      key: 'technologies',
      render: (technologies: string[]) => (
        <div>
          {technologies?.slice(0, 2).map(tech => (
            <Tag key={tech} color="cyan" style={{ marginBottom: 4 }}>{tech}</Tag>
          ))}
          {technologies && technologies.length > 2 && <Tag>+{technologies.length - 2}</Tag>}
        </div>
      ),
    },
    {
      title: 'Trạng thái',
      dataIndex: 'status',
      key: 'status',
      render: (status: string) => (
        <Tag color={statusColors[status] || 'default'}>
          {status || 'DRAFT'}
        </Tag>
      ),
    },
    {
      title: 'Xác thực',
      dataIndex: 'validated',
      key: 'validated',
      render: (validated: string) => {
        const color = validated === 'approved' ? 'green' : validated === 'rejected' ? 'red' : 'orange';
        const text = validated === 'approved' ? 'Đã xác thực' : validated === 'rejected' ? 'Đã từ chối' : 'Chờ xác thực';
        return <Tag color={color}>{text}</Tag>;
      },
    },
    {
      title: 'Hành động',
      key: 'actions',
      fixed: 'right',
      width: 150,
      render: (_, record: ProjectDTO) => (
        <Space>
          <Tooltip title="Chỉnh sửa">
            <Button icon={<EditOutlined />} size="small" onClick={() => handleEdit(record)} />
          </Tooltip>
          {(record.validated === false || String(record.validated) === 'pending') && (
            <Tooltip title="Duyệt">
              <Button
                icon={<CheckCircleOutlined />}
                size="small"
                type="primary"
                onClick={() => handleValidate(record.id)}
              />
            </Tooltip>
          )}
          {(record.validated === false || String(record.validated) === 'pending') && (
            <Tooltip title="Từ chối">
              <Button icon={<DeleteOutlined />} size="small" danger onClick={() => handleReject(record.id)} />
            </Tooltip>
          )}
        </Space>
      ),
    },
  ];

  return (
    <div style={{ padding: 24 }}>
      <h1>Quản lý Dự án</h1>
      
      <div style={{ marginBottom: 16, display: 'flex', gap: 16, alignItems: 'center' }}>
        <Input.Search
          placeholder="Tìm kiếm theo tên dự án..."
          style={{ width: 300 }}
          value={searchText}
          onChange={(e) => setSearchText(e.target.value)}
          onSearch={(value) => setSearchText(value)}
          allowClear
        />
        <Select
          placeholder="Lọc theo trạng thái"
          style={{ width: 200 }}
          value={statusFilter}
          onChange={(value) => setStatusFilter(value)}
          allowClear
        >
          <Select.Option value="DRAFT">Nháp</Select.Option>
          <Select.Option value="OPEN">Mở</Select.Option>
          <Select.Option value="IN_PROGRESS">Đang thực hiện</Select.Option>
          <Select.Option value="COMPLETED">Hoàn thành</Select.Option>
          <Select.Option value="CANCELLED">Đã hủy</Select.Option>
        </Select>
        <Select
          placeholder="Lọc theo xác thực"
          style={{ width: 200 }}
          value={validatedFilter}
          onChange={(value) => setValidatedFilter(value)}
          allowClear
        >
          <Select.Option value="pending">Chờ duyệt</Select.Option>
          <Select.Option value="approved">Đã duyệt</Select.Option>
          <Select.Option value="rejected">Đã từ chối</Select.Option>
        </Select>
      </div>
      
      <Table
        columns={columns}
        dataSource={projects}
        rowKey="id"
        loading={loading}
        pagination={pagination}
        onChange={handleTableChange}
        scroll={{ x: 1500 }}
        locale={{
          emptyText: 'Chưa có dự án nào trong hệ thống'
        }}
      />

      <Modal
        title="Chỉnh sửa Dự án"
        open={editModalVisible}
        onOk={handleUpdate}
        onCancel={() => setEditModalVisible(false)}
        width={900}
      >
        <Form form={form} layout="vertical">
          <Form.Item name="title" label="Tên dự án" rules={[{ required: true }]}>
            <Input />
          </Form.Item>
          <Form.Item name="description" label="Mô tả">
            <Input.TextArea rows={3} />
          </Form.Item>
          <Form.Item name="objectives" label="Mục tiêu">
            <Input.TextArea rows={2} />
          </Form.Item>
          <Form.Item name="requirements" label="Yêu cầu">
            <Input.TextArea rows={2} />
          </Form.Item>
          <Form.Item name="budget" label="Ngân sách">
            <InputNumber min={0} style={{ width: '100%' }} />
          </Form.Item>
          <Form.Item name="currency" label="Đơn vị tiền tệ">
            <Select>
              <Select.Option value="VND">VND</Select.Option>
              <Select.Option value="USD">USD</Select.Option>
            </Select>
          </Form.Item>
          <Form.Item name="startDate" label="Ngày bắt đầu">
            <DatePicker style={{ width: '100%' }} format="DD/MM/YYYY" />
          </Form.Item>
          <Form.Item name="endDate" label="Ngày kết thúc">
            <DatePicker style={{ width: '100%' }} format="DD/MM/YYYY" />
          </Form.Item>
          <Form.Item name="numberOfStudents" label="Số sinh viên">
            <InputNumber min={1} style={{ width: '100%' }} />
          </Form.Item>
          <Form.Item name="technologies" label="Công nghệ">
            <Select mode="tags" placeholder="Nhập công nghệ" />
          </Form.Item>
          <Form.Item name="status" label="Trạng thái">
            <Select>
              <Select.Option value="DRAFT">Nháp</Select.Option>
              <Select.Option value="OPEN">Mở</Select.Option>
              <Select.Option value="IN_PROGRESS">Đang thực hiện</Select.Option>
              <Select.Option value="COMPLETED">Hoàn thành</Select.Option>
              <Select.Option value="CANCELLED">Đã hủy</Select.Option>
            </Select>
          </Form.Item>
          <Form.Item name="progressPercentage" label="Tiến độ (%)">
            <InputNumber min={0} max={100} style={{ width: '100%' }} />
          </Form.Item>
          <Form.Item name="validated" label="Trạng thái xác thực">
            <Select placeholder="Chọn trạng thái">
              <Select.Option value="pending">Chờ xác thực</Select.Option>
              <Select.Option value="approved">Đã duyệt</Select.Option>
              <Select.Option value="rejected">Đã từ chối</Select.Option>
            </Select>
          </Form.Item>
        </Form>
      </Modal>
    </div>
  );
};

export default Projects;
