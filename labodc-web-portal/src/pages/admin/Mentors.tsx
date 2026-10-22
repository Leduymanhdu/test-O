import React, { useState, useEffect } from 'react';
import { Table, Button, Modal, Form, Input, Tag, Space, Tooltip, InputNumber, Select, App, AutoComplete, Spin } from 'antd';
import { EditOutlined, DeleteOutlined, PlusOutlined } from '@ant-design/icons';
import { mentorAdminService, MentorDTO } from '../../services/mentorAdminService';
import type { ColumnsType } from 'antd/es/table';

const Mentors: React.FC = () => {
  const { message: messageApi } = App.useApp();
  const [mentors, setMentors] = useState<MentorDTO[]>([]);
  const [loading, setLoading] = useState(false);
  const [pagination, setPagination] = useState({ current: 1, pageSize: 10, total: 0 });
  const [editModalVisible, setEditModalVisible] = useState(false);
  const [createModalVisible, setCreateModalVisible] = useState(false);
  const [selectedMentor, setSelectedMentor] = useState<MentorDTO | null>(null);
  const [form] = Form.useForm();
  const [createForm] = Form.useForm();
  
  // User search states
  const [userSearchOptions, setUserSearchOptions] = useState<Array<{ value: string; label: string; userId: number }>>([]);
  const [selectedUserId, setSelectedUserId] = useState<number | null>(null);
  const [searchingUsers, setSearchingUsers] = useState(false);
  
  // Expertise states
  const [expertiseOptions, setExpertiseOptions] = useState<string[]>([]);
  const [loadingExpertise, setLoadingExpertise] = useState(false);
  
  // Filter states
  const [searchText, setSearchText] = useState<string>('');
  const [expertiseFilter, setExpertiseFilter] = useState<string | undefined>(undefined);

  useEffect(() => {
    fetchMentors(pagination.current - 1, pagination.pageSize);
  }, [searchText, expertiseFilter]);

  useEffect(() => {
    fetchExpertiseOptions();
  }, []);

  const fetchExpertiseOptions = async () => {
    setLoadingExpertise(true);
    try {
      const expertise = await mentorAdminService.getAllExpertise();
      setExpertiseOptions(expertise);
    } catch (error) {
      console.error('Error fetching expertise options:', error);
    } finally {
      setLoadingExpertise(false);
    }
  };

  const fetchMentors = async (page: number, size: number) => {
    setLoading(true);
    try {
      const data = await mentorAdminService.getAllMentors(page, size);
      
      // Apply client-side filtering
      let filtered = data.content;
      
      if (searchText) {
        const search = searchText.toLowerCase();
        filtered = filtered.filter(mentor => 
          mentor.fullName?.toLowerCase().includes(search) ||
          mentor.userEmail?.toLowerCase().includes(search) ||
          mentor.currentPosition?.toLowerCase().includes(search)
        );
      }
      
      if (expertiseFilter) {
        filtered = filtered.filter(mentor => 
          mentor.expertise?.some(exp => exp.toLowerCase().includes(expertiseFilter.toLowerCase()))
        );
      }
      
      setMentors(filtered);
      setPagination({
        current: data.number + 1,
        pageSize: data.size,
        total: filtered.length
      });
    } catch (error) {
      messageApi.error('Không thể tải danh sách mentor');
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
      const users = await mentorAdminService.searchUsers(value);
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
      await mentorAdminService.createMentor(createData);
      messageApi.success('Thêm mentor thành công');
      setCreateModalVisible(false);
      createForm.resetFields();
      setSelectedUserId(null);
      setUserSearchOptions([]);
      fetchMentors(pagination.current - 1, pagination.pageSize);
    } catch (error: any) {
      const errorMessage = error?.response?.data?.message || 
                          error?.response?.data?.error || 
                          error?.message || 
                          'Không thể thêm mentor';
      messageApi.error(errorMessage);
      console.error(error);
    }
  };

  const handleTableChange = (newPagination: any) => {
    fetchMentors(newPagination.current - 1, newPagination.pageSize);
  };

  const handleEdit = (record: MentorDTO) => {
    setSelectedMentor(record);
    form.setFieldsValue(record);
    setEditModalVisible(true);
  };

  const handleUpdate = async () => {
    try {
      const values = await form.validateFields();
      if (selectedMentor) {
        // Merge full mentor data with form values
        const updateData = {
          ...selectedMentor,
          ...values
        };
        await mentorAdminService.updateMentor(selectedMentor.id, updateData);
        messageApi.success('Cập nhật mentor thành công');
        setEditModalVisible(false);
        fetchMentors(pagination.current - 1, pagination.pageSize);
      }
    } catch (error: any) {
      const errorMessage = error?.response?.data?.message || 
                          error?.response?.data?.error || 
                          error?.message || 
                          'Không thể cập nhật mentor';
      messageApi.error(errorMessage);
      console.error(error);
    }
  };

  const handleDelete = async (id: number) => {
    Modal.confirm({
      title: 'Xác nhận xóa',
      content: 'Bạn có chắc chắn muốn xóa mentor này?',
      okText: 'Xóa',
      okType: 'danger',
      cancelText: 'Hủy',
      onOk: async () => {
        try {
          await mentorAdminService.deleteMentor(id);
          messageApi.success('Xóa mentor thành công');
          fetchMentors(pagination.current - 1, pagination.pageSize);
        } catch (error) {
          messageApi.error('Không thể xóa mentor');
          console.error(error);
        }
      }
    });
  };

  const columns: ColumnsType<MentorDTO> = [
    {
      title: 'ID',
      dataIndex: 'id',
      key: 'id',
      width: 60,
    },
    {
      title: 'Mentor',
      key: 'mentor',
      render: (_, record: MentorDTO) => (
        <div>
          <div style={{ fontWeight: 500 }}>
            {record.title ? `${record.title} ` : ''}{record.fullName}
          </div>
          <div style={{ fontSize: 12, color: '#999' }}>{record.userEmail}</div>
        </div>
      )
    },
    {
      title: 'Vị trí hiện tại',
      key: 'position',
      render: (_, record: MentorDTO) => (
        <div>
          <div>{record.currentPosition}</div>
          <div style={{ fontSize: 12, color: '#666' }}>{record.currentCompany}</div>
        </div>
      )
    },
    {
      title: 'Kinh nghiệm',
      dataIndex: 'yearsOfExperience',
      key: 'yearsOfExperience',
      render: (years: number) => `${years || 0} năm`
    },
    {
      title: 'Chuyên môn',
      dataIndex: 'expertise',
      key: 'expertise',
      render: (expertise: string[]) => (
        <div>
          {expertise?.slice(0, 3).map(exp => (
            <Tag key={exp} color="purple" style={{ marginBottom: 4 }}>{exp}</Tag>
          ))}
          {expertise && expertise.length > 3 && <Tag>+{expertise.length - 3}</Tag>}
        </div>
      )
    },
    {
      title: 'Giá/giờ',
      key: 'rate',
      render: (_, record: MentorDTO) => 
        record.hourlyRate 
          ? `${record.hourlyRate.toLocaleString()} ${record.currency || 'VND'}`
          : '-'
    },
    {
      title: 'Đánh giá',
      dataIndex: 'ratingAverage',
      key: 'ratingAverage',
      render: (rating: number) => rating ? `⭐ ${rating.toFixed(1)}` : '-'
    },
    {
      title: 'Dự án',
      key: 'projects',
      render: (_, record: MentorDTO) => (
        <div>
          <div>Tổng: {record.totalProjects || 0}</div>
          <div style={{ fontSize: 12, color: '#1890ff' }}>Hiện tại: {record.currentProjects || 0}</div>
        </div>
      )
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
      render: (_, record: MentorDTO) => (
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
      <h1>Quản lý Mentor</h1>
      
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
            placeholder="Lọc theo chuyên môn"
            style={{ width: 200 }}
            value={expertiseFilter}
            onChange={(value) => setExpertiseFilter(value)}
            allowClear
          >
            <Select.Option value="Backend">Backend</Select.Option>
            <Select.Option value="Frontend">Frontend</Select.Option>
            <Select.Option value="Mobile">Mobile</Select.Option>
            <Select.Option value="DevOps">DevOps</Select.Option>
          </Select>
        </div>
      </div>
      
      <Table
        columns={columns}
        dataSource={mentors}
        rowKey="id"
        loading={loading}
        pagination={pagination}
        onChange={handleTableChange}
        locale={{
          emptyText: 'Chưa có mentor nào trong hệ thống'
        }}
      />

      <Modal
        title="Chỉnh sửa Mentor"
        open={editModalVisible}
        onOk={handleUpdate}
        onCancel={() => setEditModalVisible(false)}
        width={800}
      >
        <Form form={form} layout="vertical">
          <Form.Item name="title" label="Danh xưng">
            <Input placeholder="Dr., Mr., Ms., etc." />
          </Form.Item>
          <Form.Item name="fullName" label="Họ và tên" rules={[{ required: true }]}>
            <Input />
          </Form.Item>
          <Form.Item name="currentPosition" label="Vị trí hiện tại">
            <Input />
          </Form.Item>
          <Form.Item name="currentCompany" label="Công ty hiện tại">
            <Input />
          </Form.Item>
          <Form.Item name="yearsOfExperience" label="Năm kinh nghiệm">
            <InputNumber min={0} style={{ width: '100%' }} />
          </Form.Item>
          <Form.Item name="expertise" label="Chuyên môn">
            <Select 
              mode="tags" 
              placeholder="Chọn hoặc nhập chuyên môn"
              loading={loadingExpertise}
              options={expertiseOptions.map(exp => ({ label: exp, value: exp }))}
            />
          </Form.Item>
          <Form.Item name="hourlyRate" label="Giá theo giờ">
            <InputNumber min={0} style={{ width: '100%' }} />
          </Form.Item>
          <Form.Item name="currency" label="Đơn vị tiền tệ">
            <Select>
              <Select.Option value="VND">VND</Select.Option>
              <Select.Option value="USD">USD</Select.Option>
            </Select>
          </Form.Item>
          <Form.Item name="maxConcurrentProjects" label="Số dự án tối đa">
            <InputNumber min={1} style={{ width: '100%' }} />
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
        title="Thêm Mentor Mới"
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
            tooltip="Tìm kiếm user bằng email để gán mentor này cho họ"
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
          <Form.Item name="title" label="Danh xưng">
            <Input placeholder="Dr., Mr., Ms., etc." />
          </Form.Item>
          <Form.Item name="fullName" label="Họ và tên" rules={[{ required: true, message: 'Vui lòng nhập họ tên' }]}>
            <Input placeholder="Nhập họ và tên" />
          </Form.Item>
          <Form.Item name="currentPosition" label="Vị trí hiện tại">
            <Input placeholder="Ví dụ: Senior Developer" />
          </Form.Item>
          <Form.Item name="currentCompany" label="Công ty hiện tại">
            <Input placeholder="Tên công ty" />
          </Form.Item>
          <Form.Item name="yearsOfExperience" label="Năm kinh nghiệm">
            <InputNumber min={0} style={{ width: '100%' }} placeholder="Số năm kinh nghiệm" />
          </Form.Item>
          <Form.Item name="expertise" label="Chuyên môn">
            <Select 
              mode="tags" 
              placeholder="Chọn hoặc nhập chuyên môn (có thể thêm nhiều)"
              loading={loadingExpertise}
              options={expertiseOptions.map(exp => ({ label: exp, value: exp }))}
            />
          </Form.Item>
          <Form.Item name="hourlyRate" label="Giá theo giờ">
            <InputNumber min={0} style={{ width: '100%' }} placeholder="Giá theo giờ" />
          </Form.Item>
          <Form.Item name="currency" label="Đơn vị tiền tệ">
            <Select placeholder="Chọn đơn vị tiền tệ">
              <Select.Option value="VND">VND</Select.Option>
              <Select.Option value="USD">USD</Select.Option>
            </Select>
          </Form.Item>
          <Form.Item name="maxConcurrentProjects" label="Số dự án tối đa">
            <InputNumber min={1} style={{ width: '100%' }} placeholder="Số dự án có thể nhận cùng lúc" />
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

export default Mentors;
