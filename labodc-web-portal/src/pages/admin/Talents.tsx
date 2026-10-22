import React, { useState, useEffect } from 'react';
import { Table, Button, Modal, Form, Input, Tag, Space, Tooltip, InputNumber, Select, App, AutoComplete, Spin } from 'antd';
import { EditOutlined, DeleteOutlined, PlusOutlined } from '@ant-design/icons';
import { talentAdminService, TalentDTO } from '../../services/talentAdminService';
import type { ColumnsType } from 'antd/es/table';

const Talents: React.FC = () => {
  const { message: messageApi } = App.useApp();
  const [talents, setTalents] = useState<TalentDTO[]>([]);
  const [loading, setLoading] = useState(false);
  const [pagination, setPagination] = useState({ current: 1, pageSize: 10, total: 0 });
  const [editModalVisible, setEditModalVisible] = useState(false);
  const [createModalVisible, setCreateModalVisible] = useState(false);
  const [selectedTalent, setSelectedTalent] = useState<TalentDTO | null>(null);
  const [form] = Form.useForm();
  const [createForm] = Form.useForm();
  
  // User search states
  const [userSearchOptions, setUserSearchOptions] = useState<Array<{ value: string; label: string; userId: number }>>([]);
  const [selectedUserId, setSelectedUserId] = useState<number | null>(null);
  const [searchingUsers, setSearchingUsers] = useState(false);
  
  // Filter states
  const [searchText, setSearchText] = useState<string>('');
  const [majorFilter, setMajorFilter] = useState<string | undefined>(undefined);

  useEffect(() => {
    fetchTalents(pagination.current - 1, pagination.pageSize);
  }, [searchText, majorFilter]);

  const fetchTalents = async (page: number, size: number) => {
    setLoading(true);
    try {
      const data = await talentAdminService.getAllTalents(page, size);
      
      // Apply client-side filtering
      let filtered = data.content;
      
      if (searchText) {
        const search = searchText.toLowerCase();
        filtered = filtered.filter(talent => 
          talent.fullName?.toLowerCase().includes(search) ||
          talent.userEmail?.toLowerCase().includes(search) ||
          talent.studentId?.toLowerCase().includes(search)
        );
      }
      
      if (majorFilter) {
        filtered = filtered.filter(talent => talent.major === majorFilter);
      }
      
      setTalents(filtered);
      setPagination({
        current: data.number + 1,
        pageSize: data.size,
        total: filtered.length
      });
    } catch (error) {
      messageApi.error('Không thể tải danh sách sinh viên');
      console.error(error);
    } finally {
      setLoading(false);
    }
  };

  const handleUserSearch = async (value: string) => {
    if (!value || value.length < 2) {
      setUserSearchOptions([]);
      return;
    }
    
    setSearchingUsers(true);
    try {
      const users = await talentAdminService.searchUsers(value);
      const options = users.map((user: any) => ({
        value: user.email,
        label: `${user.email} (ID: ${user.id}, Role: ${user.role})`,
        userId: user.id
      }));
      setUserSearchOptions(options);
    } catch (error) {
      console.error('Error searching users:', error);
    } finally {
      setSearchingUsers(false);
    }
  };

  const handleUserSelect = (value: string, option: any) => {
    setSelectedUserId(option.userId);
  };

  const handleCreate = async () => {
    try {
      const values = await createForm.validateFields();
      
      if (!selectedUserId) {
        messageApi.error('Vui lòng chọn user');
        return;
      }
      
      const createData = {
        ...values,
        userId: selectedUserId
      };
      await talentAdminService.createTalent(createData);
      messageApi.success('Thêm sinh viên thành công');
      setCreateModalVisible(false);
      createForm.resetFields();
      setSelectedUserId(null);
      setUserSearchOptions([]);
      fetchTalents(pagination.current - 1, pagination.pageSize);
    } catch (error: any) {
      const errorMessage = error?.response?.data?.message || 
                          error?.response?.data?.error || 
                          error?.message || 
                          'Không thể thêm sinh viên';
      messageApi.error(errorMessage);
      console.error(error);
    }
  };

  const handleTableChange = (newPagination: any) => {
    fetchTalents(newPagination.current - 1, newPagination.pageSize);
  };

  const handleEdit = (record: TalentDTO) => {
    setSelectedTalent(record);
    form.setFieldsValue(record);
    setEditModalVisible(true);
  };

  const handleUpdate = async () => {
    try {
      const values = await form.validateFields();
      if (selectedTalent) {
        // Merge full talent data with form values
        const updateData = {
          ...selectedTalent,
          ...values
        };
        await talentAdminService.updateTalent(selectedTalent.id, updateData);
        messageApi.success('Cập nhật sinh viên thành công');
        setEditModalVisible(false);
        fetchTalents(pagination.current - 1, pagination.pageSize);
      }
    } catch (error: any) {
      const errorMessage = error?.response?.data?.message || 
                          error?.response?.data?.error || 
                          error?.message || 
                          'Không thể cập nhật sinh viên';
      messageApi.error(errorMessage);
      console.error(error);
    }
  };

  const handleDelete = async (id: number) => {
    Modal.confirm({
      title: 'Xác nhận xóa',
      content: 'Bạn có chắc chắn muốn xóa sinh viên này?',
      okText: 'Xóa',
      okType: 'danger',
      cancelText: 'Hủy',
      onOk: async () => {
        try {
          await talentAdminService.deleteTalent(id);
          messageApi.success('Xóa sinh viên thành công');
          fetchTalents(pagination.current - 1, pagination.pageSize);
        } catch (error) {
          messageApi.error('Không thể xóa sinh viên');
          console.error(error);
        }
      }
    });
  };

  const columns: ColumnsType<TalentDTO> = [
    {
      title: 'ID',
      dataIndex: 'id',
      key: 'id',
      width: 60,
    },
    {
      title: 'Sinh viên',
      key: 'student',
      render: (_, record: TalentDTO) => (
        <div>
          <div style={{ fontWeight: 500 }}>{record.fullName}</div>
          <div style={{ fontSize: 12, color: '#999' }}>{record.studentId}</div>
          <div style={{ fontSize: 12, color: '#999' }}>{record.userEmail}</div>
        </div>
      )
    },
    {
      title: 'Khoa/Ngành',
      key: 'academic',
      render: (_, record: TalentDTO) => (
        <div>
          <div>{record.faculty}</div>
          <div style={{ fontSize: 12, color: '#666' }}>{record.major}</div>
        </div>
      )
    },
    {
      title: 'Năm học',
      dataIndex: 'yearOfStudy',
      key: 'yearOfStudy',
    },
    {
      title: 'GPA',
      dataIndex: 'gpa',
      key: 'gpa',
      render: (gpa: number) => gpa?.toFixed(2) || '-'
    },
    {
      title: 'Kỹ năng',
      dataIndex: 'skills',
      key: 'skills',
      render: (skills: string[]) => (
        <div>
          {skills?.slice(0, 3).map(skill => (
            <Tag key={skill} color="blue" style={{ marginBottom: 4 }}>{skill}</Tag>
          ))}
          {skills && skills.length > 3 && <Tag>+{skills.length - 3}</Tag>}
        </div>
      )
    },
    {
      title: 'Đánh giá',
      dataIndex: 'ratingAverage',
      key: 'ratingAverage',
      render: (rating: number) => rating ? `⭐ ${rating.toFixed(1)}` : '-'
    },
    {
      title: 'Dự án',
      dataIndex: 'totalProjects',
      key: 'totalProjects',
    },
    {
      title: 'Trạng thái',
      dataIndex: 'status',
      key: 'status',
      render: (status: string) => {
        const statusConfig = {
          PENDING: { color: 'orange', text: 'Chờ xác minh' },
          ACTIVE: { color: 'green', text: 'Hoạt động' }
        };
        const config = statusConfig[status as keyof typeof statusConfig] || statusConfig.ACTIVE;
        return <Tag color={config.color}>{config.text}</Tag>;
      }
    },
    {
      title: 'Hành động',
      key: 'actions',
      render: (_, record: TalentDTO) => (
        <Space>
          <Tooltip title="Chỉnh sửa">
            <Button icon={<EditOutlined />} size="small" onClick={() => handleEdit(record)} />
          </Tooltip>
          <Tooltip title="Xóa">
            <Button icon={<DeleteOutlined />} size="small" danger onClick={() => handleDelete(record.id)} />
          </Tooltip>
        </Space>
      )
    }
  ];

  return (
    <div style={{ padding: 24 }}>
      <h1>Quản lý Sinh viên</h1>
      
      <div style={{ marginBottom: 16, display: 'flex', gap: 16, alignItems: 'center', justifyContent: 'space-between' }}>
        <div style={{ display: 'flex', gap: 16 }}>
          <Input.Search
            placeholder="Tìm kiếm theo tên, email..."
            style={{ width: 300 }}
            value={searchText}
            onChange={(e) => setSearchText(e.target.value)}
            onSearch={(value) => setSearchText(value)}
            allowClear
          />
          <Select
            placeholder="Lọc theo chuyên ngành"
            style={{ width: 200 }}
            value={majorFilter}
            onChange={(value) => setMajorFilter(value)}
            allowClear
          >
            <Select.Option value="CS">Khoa học máy tính</Select.Option>
            <Select.Option value="IT">Công nghệ thông tin</Select.Option>
            <Select.Option value="SE">Kỹ thuật phần mềm</Select.Option>
          </Select>
        </div>
        
        <Button type="primary" icon={<PlusOutlined />} onClick={() => setCreateModalVisible(true)}>
          Thêm mới
        </Button>
      </div>
      
      <Table
        columns={columns}
        dataSource={talents}
        rowKey="id"
        loading={loading}
        pagination={pagination}
        onChange={handleTableChange}
        locale={{
          emptyText: 'Chưa có talent nào trong hệ thống'
        }}
      />

      <Modal
        title="Chỉnh sửa Sinh viên"
        open={editModalVisible}
        onOk={handleUpdate}
        onCancel={() => setEditModalVisible(false)}
        width={800}
      >
        <Form form={form} layout="vertical">
          <Form.Item name="fullName" label="Họ và tên" rules={[{ required: true }]}>
            <Input />
          </Form.Item>
          <Form.Item name="studentId" label="Mã sinh viên">
            <Input />
          </Form.Item>
          <Form.Item name="faculty" label="Khoa">
            <Input />
          </Form.Item>
          <Form.Item name="major" label="Chuyên ngành">
            <Input />
          </Form.Item>
          <Form.Item name="yearOfStudy" label="Năm học">
            <InputNumber min={1} max={5} style={{ width: '100%' }} />
          </Form.Item>
          <Form.Item name="gpa" label="GPA">
            <InputNumber min={0} max={4} step={0.01} style={{ width: '100%' }} />
          </Form.Item>
          <Form.Item name="skills" label="Kỹ năng">
            <Select mode="tags" placeholder="Nhập kỹ năng" />
          </Form.Item>
          <Form.Item name="githubUrl" label="GitHub">
            <Input />
          </Form.Item>
          <Form.Item name="linkedinUrl" label="LinkedIn">
            <Input />
          </Form.Item>
          <Form.Item name="bio" label="Giới thiệu">
            <Input.TextArea rows={4} />
          </Form.Item>
          <Form.Item name="status" label="Trạng thái">
            <Select>
              <Select.Option value="PENDING">Chờ xác minh</Select.Option>
              <Select.Option value="ACTIVE">Hoạt động</Select.Option>
            </Select>
          </Form.Item>
        </Form>
      </Modal>

      <Modal
        title="Thêm Sinh viên Mới"
        open={createModalVisible}
        onOk={handleCreate}
        onCancel={() => {
          setCreateModalVisible(false);
          createForm.resetFields();
          setSelectedUserId(null);
          setUserSearchOptions([]);
        }}
        width={800}
      >
        <Form form={createForm} layout="vertical">
          <Form.Item 
            name="userEmail" 
            label="Chọn User" 
            rules={[{ required: true, message: 'Vui lòng chọn user' }]}
            tooltip="Tìm kiếm user bằng email để gán sinh viên này cho họ"
          >
            <AutoComplete
              options={userSearchOptions}
              onSearch={handleUserSearch}
              onSelect={handleUserSelect}
              placeholder="Nhập email để tìm kiếm user..."
              notFoundContent={searchingUsers ? <Spin size="small" /> : 'Không tìm thấy user'}
            />
          </Form.Item>
          {selectedUserId && (
            <div style={{ marginBottom: 16, padding: 8, background: '#f0f0f0', borderRadius: 4 }}>
              <strong>User ID đã chọn:</strong> {selectedUserId}
            </div>
          )}
          <Form.Item name="fullName" label="Họ và tên" rules={[{ required: true, message: 'Vui lòng nhập họ tên' }]}>
            <Input placeholder="Nhập họ và tên" />
          </Form.Item>
          <Form.Item name="studentId" label="Mã sinh viên">
            <Input placeholder="Nhập mã sinh viên" />
          </Form.Item>
          <Form.Item name="faculty" label="Khoa">
            <Input placeholder="Nhập tên khoa" />
          </Form.Item>
          <Form.Item name="major" label="Chuyên ngành">
            <Input placeholder="Nhập chuyên ngành" />
          </Form.Item>
          <Form.Item name="yearOfStudy" label="Năm học">
            <InputNumber min={1} max={5} style={{ width: '100%' }} placeholder="Năm học hiện tại" />
          </Form.Item>
          <Form.Item name="gpa" label="GPA">
            <InputNumber min={0} max={4} step={0.01} style={{ width: '100%' }} placeholder="Điểm trung bình" />
          </Form.Item>
          <Form.Item name="skills" label="Kỹ năng">
            <Select mode="tags" placeholder="Nhập kỹ năng (có thể thêm nhiều)" />
          </Form.Item>
          <Form.Item name="githubUrl" label="GitHub">
            <Input placeholder="https://github.com/username" />
          </Form.Item>
          <Form.Item name="linkedinUrl" label="LinkedIn">
            <Input placeholder="https://linkedin.com/in/username" />
          </Form.Item>
          <Form.Item name="bio" label="Giới thiệu">
            <Input.TextArea rows={4} placeholder="Giới thiệu về bản thân" />
          </Form.Item>
        </Form>
      </Modal>
    </div>
  );
};

export default Talents;
