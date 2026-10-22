import React, { useState, useEffect } from 'react';
import { Table, Button, Modal, Form, Input, Tag, Space, Tooltip, Select, App, AutoComplete, Spin } from 'antd';
import { EditOutlined, CheckOutlined, CloseCircleOutlined, PlusOutlined } from '@ant-design/icons';
import { enterpriseAdminService, EnterpriseDTO } from '../../services/enterpriseAdminService';
import type { ColumnsType } from 'antd/es/table';

const Enterprises: React.FC = () => {
  const { message: messageApi } = App.useApp();
  const [enterprises, setEnterprises] = useState<EnterpriseDTO[]>([]);
  const [allEnterprises, setAllEnterprises] = useState<EnterpriseDTO[]>([]); // Store all data for filtering
  const [loading, setLoading] = useState(false);
  const [pagination, setPagination] = useState({ current: 1, pageSize: 10, total: 0 });
  const [editModalVisible, setEditModalVisible] = useState(false);
  const [createModalVisible, setCreateModalVisible] = useState(false);
  const [selectedEnterprise, setSelectedEnterprise] = useState<EnterpriseDTO | null>(null);
  const [form] = Form.useForm();
  const [createForm] = Form.useForm();
  
  // User search states
  const [userSearchOptions, setUserSearchOptions] = useState<Array<{ value: string; label: string; userId: number }>>([]);
  const [selectedUserId, setSelectedUserId] = useState<number | null>(null);
  const [searchingUsers, setSearchingUsers] = useState(false);
  
  // Search and filter states
  const [searchText, setSearchText] = useState('');
  const [statusFilter, setStatusFilter] = useState<string | undefined>();
  const [industryFilter, setIndustryFilter] = useState<string | undefined>();

  useEffect(() => {
    fetchEnterprises(pagination.current - 1, pagination.pageSize);
  }, []);

  const fetchEnterprises = async (page: number, size: number) => {
    setLoading(true);
    try {
      const data = await enterpriseAdminService.getAllEnterprises(page, size);
      setAllEnterprises(data.content); // Store all data
      applyFilters(data.content); // Apply current filters
      setPagination({
        current: data.number + 1,
        pageSize: data.size,
        total: data.totalElements
      });
    } catch (error) {
      messageApi.error('Không thể tải danh sách doanh nghiệp');
      console.error('❌ Fetch error:', error);
    } finally {
      setLoading(false);
    }
  };

  const applyFilters = (data: EnterpriseDTO[]) => {
    let filtered = [...data];
    
    // Search filter
    if (searchText) {
      filtered = filtered.filter(item =>
        item.companyName?.toLowerCase().includes(searchText.toLowerCase()) ||
        item.contactEmail?.toLowerCase().includes(searchText.toLowerCase()) ||
        item.taxCode?.toLowerCase().includes(searchText.toLowerCase())
      );
    }
    
    // Status filter
    if (statusFilter) {
      filtered = filtered.filter(item => item.status === statusFilter);
    }
    
    // Industry filter
    if (industryFilter) {
      filtered = filtered.filter(item => item.industry === industryFilter);
    }
    
    setEnterprises(filtered);
  };

  // Re-apply filters when search/filter values change
  useEffect(() => {
    applyFilters(allEnterprises);
  }, [searchText, statusFilter, industryFilter, allEnterprises]);

  const handleUserSearch = async (value: string) => {
    if (!value || value.length < 2) {
      setUserSearchOptions([]);
      return;
    }
    
    setSearchingUsers(true);
    try {
      const users = await enterpriseAdminService.searchUsers(value);
      const options = users.map(user => ({
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

  const handleTableChange = (newPagination: any) => {
    fetchEnterprises(newPagination.current - 1, newPagination.pageSize);
  };

  const handleEdit = (record: EnterpriseDTO) => {
    setSelectedEnterprise(record);
    form.setFieldsValue(record);
    setEditModalVisible(true);
  };

  const handleUpdate = async () => {
    try {
      const values = await form.validateFields();
      if (selectedEnterprise) {
        // Merge with existing data to ensure all fields are sent
        const updateData = {
          ...selectedEnterprise,
          ...values
        };
        await enterpriseAdminService.updateEnterprise(selectedEnterprise.id, updateData);
        messageApi.success('Cập nhật doanh nghiệp thành công');
        setEditModalVisible(false);
        fetchEnterprises(pagination.current - 1, pagination.pageSize);
      }
    } catch (error: any) {
      const errorMessage = error?.response?.data?.message || 
                          error?.response?.data?.error || 
                          error?.message || 
                          'Không thể cập nhật doanh nghiệp';
      messageApi.error(errorMessage);
      console.error(error);
    }
  };

  const handleVerify = async (id: number) => {
    Modal.confirm({
      title: 'Xác nhận duyệt doanh nghiệp',
      content: 'Bạn có chắc chắn muốn duyệt doanh nghiệp này?',
      okText: 'Duyệt',
      cancelText: 'Hủy',
      onOk: async () => {
        try {
          await enterpriseAdminService.verifyEnterprise(id);
          messageApi.success('Xác minh doanh nghiệp thành công');
          fetchEnterprises(pagination.current - 1, pagination.pageSize);
        } catch (error) {
          messageApi.error('Không thể xác minh doanh nghiệp');
          console.error(error);
        }
      }
    });
  };

  const handleDelete = async (id: number) => {
    Modal.confirm({
      title: 'Từ chối doanh nghiệp',
      content: (
        <Form>
          <Form.Item label="Lý do từ chối" name="reason" rules={[{ required: true }]}>
            <Input.TextArea rows={4} id="reason" />
          </Form.Item>
        </Form>
      ),
      onOk: async () => {
        try {
          const reason = (document.getElementById('reason') as HTMLTextAreaElement)?.value || 'Không phù hợp';
          await enterpriseAdminService.deleteEnterprise(id, reason);
          messageApi.success('Từ chối doanh nghiệp thành công');
          fetchEnterprises(pagination.current - 1, pagination.pageSize);
        } catch (error) {
          messageApi.error('Không thể từ chối doanh nghiệp');
          console.error(error);
        }
      }
    });
  };

  const handleCreate = async () => {
    try {
      const values = await createForm.validateFields();
      
      if (!selectedUserId) {
        messageApi.error('Vui lòng chọn user');
        return;
      }
      
      // Ensure userId is a number
      const createData = {
        ...values,
        userId: selectedUserId
      };
      await enterpriseAdminService.createEnterprise(createData);
      messageApi.success('Thêm doanh nghiệp thành công');
      setCreateModalVisible(false);
      createForm.resetFields();
      setSelectedUserId(null);
      setUserSearchOptions([]);
      fetchEnterprises(pagination.current - 1, pagination.pageSize);
    } catch (error: any) {
      // Extract error message from response
      const errorMessage = error?.response?.data?.message || 
                          error?.response?.data?.error || 
                          error?.message || 
                          'Không thể thêm doanh nghiệp';
      messageApi.error(errorMessage);
      console.error(error);
    }
  };

  const columns: ColumnsType<EnterpriseDTO> = [
    {
      title: 'ID',
      dataIndex: 'id',
      key: 'id',
      width: 60,
    },
    {
      title: 'Công ty',
      dataIndex: 'companyName',
      key: 'companyName',
      render: (text: string, record: EnterpriseDTO) => (
        <div>
          <div style={{ fontWeight: 500 }}>{text}</div>
          <div style={{ fontSize: 12, color: '#999' }}>{record.userEmail}</div>
        </div>
      )
    },
    {
      title: 'Mã số thuế',
      dataIndex: 'taxCode',
      key: 'taxCode',
    },
    {
      title: 'Ngành',
      dataIndex: 'industry',
      key: 'industry',
    },
    {
      title: 'Quy mô',
      dataIndex: 'companySize',
      key: 'companySize',
    },
    {
      title: 'Dự án',
      key: 'projects',
      render: (_, record: EnterpriseDTO) => (
        <div>
          <div>Tổng: {record.totalProjects || 0}</div>
          <div style={{ fontSize: 12, color: '#52c41a' }}>Đang hoạt động: {record.activeProjects || 0}</div>
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
          APPROVED: { color: 'green', text: 'Đã duyệt' },
          REJECTED: { color: 'red', text: 'Đã từ chối' }
        };
        const config = statusConfig[status as keyof typeof statusConfig] || statusConfig.PENDING;
        return <Tag color={config.color}>{config.text}</Tag>;
      }
    },
    {
      title: 'Hành động',
      key: 'actions',
      render: (_, record: EnterpriseDTO) => (
        <Space>
          <Tooltip title="Chỉnh sửa">
            <Button icon={<EditOutlined />} size="small" onClick={() => handleEdit(record)} />
          </Tooltip>
          {record.status === 'PENDING' && (
            <>
              <Tooltip title="Duyệt">
                <Button icon={<CheckOutlined />} size="small" type="primary" onClick={() => handleVerify(record.id)} />
              </Tooltip>
              <Tooltip title="Từ chối">
                <Button icon={<CloseCircleOutlined />} size="small" danger onClick={() => handleDelete(record.id)} />
              </Tooltip>
            </>
          )}
        </Space>
      )
    }
  ];

  return (
    <div style={{ padding: 24 }}>
      <h1>Quản lý Doanh nghiệp</h1>
      
      <div style={{ marginBottom: 16, display: 'flex', gap: 16, alignItems: 'center', justifyContent: 'space-between' }}>
        <div style={{ display: 'flex', gap: 16 }}>
          <Input.Search
            placeholder="Tìm kiếm theo tên công ty, email..."
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
            <Select.Option value="PENDING">Chờ xác minh</Select.Option>
            <Select.Option value="APPROVED">Đã duyệt</Select.Option>
            <Select.Option value="REJECTED">Đã từ chối</Select.Option>
          </Select>
          
          <Select
            placeholder="Lọc theo ngành"
            style={{ width: 200 }}
            value={industryFilter}
            onChange={(value) => setIndustryFilter(value)}
            allowClear
          >
            <Select.Option value="TECHNOLOGY">Công nghệ</Select.Option>
            <Select.Option value="FINANCE">Tài chính</Select.Option>
            <Select.Option value="EDUCATION">Giáo dục</Select.Option>
            <Select.Option value="HEALTHCARE">Y tế</Select.Option>
          </Select>
        </div>
        
        <Button type="primary" icon={<PlusOutlined />} onClick={() => setCreateModalVisible(true)}>
          Thêm mới
        </Button>
      </div>
      
      <Table
        columns={columns}
        dataSource={enterprises}
        rowKey="id"
        loading={loading}
        pagination={pagination}
        onChange={handleTableChange}
        locale={{
          emptyText: 'Chưa có doanh nghiệp nào trong hệ thống'
        }}
      />

      <Modal
        title="Chỉnh sửa Doanh nghiệp"
        open={editModalVisible}
        onOk={handleUpdate}
        onCancel={() => setEditModalVisible(false)}
        width={800}
      >
        <Form form={form} layout="vertical">
          <Form.Item name="companyName" label="Tên công ty" rules={[{ required: true }]}>
            <Input />
          </Form.Item>
          <Form.Item name="taxCode" label="Mã số thuế">
            <Input />
          </Form.Item>
          <Form.Item name="businessLicenseNumber" label="Số giấy phép kinh doanh">
            <Input />
          </Form.Item>
          <Form.Item name="representativeName" label="Tên người đại diện" rules={[{ required: true, message: 'Vui lòng nhập tên người đại diện' }]}>
            <Input />
          </Form.Item>
          <Form.Item name="representativePosition" label="Chức vụ người đại diện">
            <Input />
          </Form.Item>
          <Form.Item name="industry" label="Ngành">
            <Input />
          </Form.Item>
          <Form.Item name="companySize" label="Quy mô">
            <Input />
          </Form.Item>
          <Form.Item name="address" label="Địa chỉ">
            <Input />
          </Form.Item>
          <Form.Item name="city" label="Thành phố">
            <Input />
          </Form.Item>
          <Form.Item name="contactEmail" label="Email liên hệ">
            <Input />
          </Form.Item>
          <Form.Item name="contactPhone" label="Điện thoại liên hệ">
            <Input />
          </Form.Item>
          <Form.Item name="website" label="Website">
            <Input />
          </Form.Item>
          <Form.Item name="description" label="Mô tả">
            <Input.TextArea rows={4} />
          </Form.Item>
          <Form.Item name="status" label="Trạng thái xác minh">
            <Select placeholder="Chọn trạng thái">
              <Select.Option value="PENDING">Chờ xác minh</Select.Option>
              <Select.Option value="APPROVED">Đã duyệt</Select.Option>
              <Select.Option value="REJECTED">Đã từ chối</Select.Option>
            </Select>
          </Form.Item>
        </Form>
      </Modal>

      <Modal
        title="Thêm Doanh nghiệp Mới"
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
            tooltip="Tìm kiếm user bằng email để gán doanh nghiệp này cho họ"
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
          <Form.Item name="companyName" label="Tên công ty" rules={[{ required: true, message: 'Vui lòng nhập tên công ty' }]}>
            <Input placeholder="Nhập tên công ty" />
          </Form.Item>
          <Form.Item name="taxCode" label="Mã số thuế" rules={[{ required: true, message: 'Vui lòng nhập mã số thuế' }]}>
            <Input placeholder="Nhập mã số thuế" />
          </Form.Item>
          <Form.Item name="businessLicenseNumber" label="Số giấy phép kinh doanh">
            <Input placeholder="Nhập số giấy phép" />
          </Form.Item>
          <Form.Item name="representativeName" label="Tên người đại diện" rules={[{ required: true, message: 'Vui lòng nhập tên người đại diện' }]}>
            <Input placeholder="Nhập tên người đại diện" />
          </Form.Item>
          <Form.Item name="representativePosition" label="Chức vụ người đại diện">
            <Input placeholder="Nhập chức vụ (VD: Giám đốc, CEO)" />
          </Form.Item>
          <Form.Item name="industry" label="Ngành" rules={[{ required: true }]}>
            <Select placeholder="Chọn ngành">
              <Select.Option value="TECHNOLOGY">Công nghệ</Select.Option>
              <Select.Option value="FINANCE">Tài chính</Select.Option>
              <Select.Option value="EDUCATION">Giáo dục</Select.Option>
              <Select.Option value="HEALTHCARE">Y tế</Select.Option>
            </Select>
          </Form.Item>
          <Form.Item name="companySize" label="Quy mô">
            <Select placeholder="Chọn quy mô">
              <Select.Option value="1-50">1-50 nhân viên</Select.Option>
              <Select.Option value="51-200">51-200 nhân viên</Select.Option>
              <Select.Option value="201-500">201-500 nhân viên</Select.Option>
              <Select.Option value="500+">500+ nhân viên</Select.Option>
            </Select>
          </Form.Item>
          <Form.Item name="address" label="Địa chỉ" rules={[{ required: true }]}>
            <Input placeholder="Nhập địa chỉ" />
          </Form.Item>
          <Form.Item name="city" label="Thành phố" rules={[{ required: true }]}>
            <Input placeholder="Nhập thành phố" />
          </Form.Item>
          <Form.Item name="contactEmail" label="Email liên hệ" rules={[{ required: true, type: 'email' }]}>
            <Input placeholder="Nhập email liên hệ" />
          </Form.Item>
          <Form.Item name="contactPhone" label="Điện thoại liên hệ" rules={[{ required: true }]}>
            <Input placeholder="Nhập số điện thoại" />
          </Form.Item>
          <Form.Item name="website" label="Website">
            <Input placeholder="Nhập website" />
          </Form.Item>
          <Form.Item name="description" label="Mô tả">
            <Input.TextArea rows={4} placeholder="Nhập mô tả về doanh nghiệp" />
          </Form.Item>
        </Form>
      </Modal>
    </div>
  );
};

export default Enterprises;
