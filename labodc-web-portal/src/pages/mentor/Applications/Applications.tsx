import React, { useEffect, useState } from 'react';
import { Button, Card, Select, Space, Table, Tag, Modal, Input, message } from 'antd';
import type { ColumnsType } from 'antd/es/table';
import { mentorService } from '@/services/mentor/mentorService';
import type { IMentorApplication, IMentorProjectOption } from '@/types/mentor.types';

const { Option } = Select;
const { TextArea } = Input;

const Applications: React.FC = () => {
  const [projects, setProjects] = useState<IMentorProjectOption[]>([]);
  const [selectedProjectId, setSelectedProjectId] = useState<string | number | undefined>();
  const [applications, setApplications] = useState<IMentorApplication[]>([]);
  const [loading, setLoading] = useState(false);
  const [searchTerm, setSearchTerm] = useState('');
  const [statusFilter, setStatusFilter] = useState('ALL');
  const [rejectModalOpen, setRejectModalOpen] = useState(false);
  const [rejectReason, setRejectReason] = useState('');
  const [activeMemberId, setActiveMemberId] = useState<string | number | null>(null);
  const [closingRecruiting, setClosingRecruiting] = useState(false);

  useEffect(() => {
    loadProjects();
  }, []);

  useEffect(() => {
    if (selectedProjectId != null) {
      loadApplications(selectedProjectId);
    } else {
      setApplications([]);
    }
  }, [selectedProjectId]);

  const loadProjects = async () => {
    try {
      const data = await mentorService.getProjects();
      setProjects(data);
      if (data.length > 0) {
        setSelectedProjectId(data[0].id);
      }
    } catch (err) {
      console.error('Failed to load mentor projects', err);
      message.error('Không thể tải danh sách dự án');
    }
  };

  const loadApplications = async (projectId: string | number) => {
    setLoading(true);
    try {
      const data = await mentorService.getApplications(projectId);
      setApplications(data);
    } catch (err) {
      console.error('Failed to load applications', err);
      message.error('Không thể tải danh sách đơn ứng tuyển');
    } finally {
      setLoading(false);
    }
  };

  const handleApprove = async (memberId: string | number) => {
    if (!selectedProjectId) return;
    try {
      await mentorService.approveApplication(selectedProjectId, memberId);
      message.success('Đã duyệt đơn');
      await loadApplications(selectedProjectId);
    } catch (err) {
      console.error('Approve failed', err);
      message.error('Không thể duyệt đơn');
    }
  };

  const openRejectModal = (memberId: string | number) => {
    setActiveMemberId(memberId);
    setRejectReason('');
    setRejectModalOpen(true);
  };

  const handleReject = async () => {
    if (!selectedProjectId || activeMemberId == null) return;
    try {
      await mentorService.rejectApplication(selectedProjectId, activeMemberId, rejectReason);
      message.success('Đã từ chối đơn');
      setRejectModalOpen(false);
      setActiveMemberId(null);
      await loadApplications(selectedProjectId);
    } catch (err) {
      console.error('Reject failed', err);
      message.error('Không thể từ chối đơn');
    }
  };

  const handleCloseRecruiting = async () => {
    if (!selectedProjectId) return;
    setClosingRecruiting(true);
    try {
      await mentorService.closeRecruiting(selectedProjectId);
      message.success('Đã kết thúc tuyển người');
      await loadProjects();
    } catch (err) {
      console.error('Close recruiting failed', err);
      message.error('Không thể kết thúc tuyển người');
    } finally {
      setClosingRecruiting(false);
    }
  };

  const columns: ColumnsType<IMentorApplication> = [
    {
      title: 'Sinh viên',
      dataIndex: 'fullName',
      key: 'fullName',
      render: (_, record) => (
        <div>
          <div>{record.fullName || '—'}</div>
          <div style={{ color: '#888' }}>{record.studentId || ''}</div>
        </div>
      ),
    },
    {
      title: 'Email',
      dataIndex: 'email',
      key: 'email',
      render: (value) => value || '—',
    },
    {
      title: 'Kỹ năng',
      dataIndex: 'skills',
      key: 'skills',
      render: (skills: string[] | undefined) =>
        skills && skills.length > 0 ? (
          <Space wrap>
            {skills.slice(0, 4).map((s) => (
              <Tag key={s}>{s}</Tag>
            ))}
            {skills.length > 4 && <Tag>+{skills.length - 4}</Tag>}
          </Space>
        ) : (
          '—'
        ),
    },
    {
      title: 'Lời nhắn',
      dataIndex: 'joinMessage',
      key: 'joinMessage',
      render: (value) => value || '—',
    },
    {
      title: 'Trạng thái',
      dataIndex: 'status',
      key: 'status',
      render: (value) => <Tag>{value || 'PENDING'}</Tag>,
    },
    {
      title: 'Hành động',
      key: 'action',
      render: (_, record) => (
        <Space>
          <Button type="primary" onClick={() => handleApprove(record.memberId)}>
            Duyệt
          </Button>
          <Button danger onClick={() => openRejectModal(record.memberId)}>
            Từ chối
          </Button>
        </Space>
      ),
    },
  ];

  const filteredApplications = applications.filter((item) => {
    const term = searchTerm.trim().toLowerCase();
    const matchesTerm =
      term.length === 0 ||
      (item.fullName && item.fullName.toLowerCase().includes(term)) ||
      (item.email && item.email.toLowerCase().includes(term)) ||
      (item.studentId && item.studentId.toLowerCase().includes(term)) ||
      (item.joinMessage && item.joinMessage.toLowerCase().includes(term));

    const matchesStatus = statusFilter === 'ALL' || item.status === statusFilter;
    return matchesTerm && matchesStatus;
  });

  return (
    <div style={{ padding: '24px' }}>
      <Card title="Duyệt đơn tham gia">
        <Space style={{ marginBottom: 16 }} wrap>
          <div>Chọn dự án:</div>
          <Select
            style={{ minWidth: 240 }}
            value={selectedProjectId}
            onChange={(value) => setSelectedProjectId(value)}
          >
            {projects.map((p) => (
              <Option key={p.id} value={p.id}>
                {p.title}
              </Option>
            ))}
          </Select>
          <Input
            placeholder="Tìm theo tên, email, mã SV..."
            style={{ width: 260 }}
            value={searchTerm}
            onChange={(e) => setSearchTerm(e.target.value)}
          />
          <Select
            style={{ minWidth: 160 }}
            value={statusFilter}
            onChange={(value) => setStatusFilter(value)}
          >
            <Option value="ALL">Tất cả trạng thái</Option>
            <Option value="PENDING">Chờ duyệt</Option>
            <Option value="ACTIVE">Đã duyệt</Option>
            <Option value="REJECTED">Từ chối</Option>
          </Select>
          <Button onClick={handleCloseRecruiting} loading={closingRecruiting}>
            Kết thúc tuyển
          </Button>
          <Button onClick={() => selectedProjectId && loadApplications(selectedProjectId)}>
            Làm mới
          </Button>
        </Space>

        <Table
          rowKey="memberId"
          columns={columns}
          dataSource={filteredApplications}
          loading={loading}
        />
      </Card>

      <Modal
        title="Từ chối đơn tham gia"
        open={rejectModalOpen}
        onCancel={() => setRejectModalOpen(false)}
        onOk={handleReject}
        okText="Từ chối"
        okButtonProps={{ danger: true }}
      >
        <TextArea
          rows={4}
          value={rejectReason}
          onChange={(e) => setRejectReason(e.target.value)}
          placeholder="Lý do từ chối (tuỳ chọn)"
        />
      </Modal>
    </div>
  );
};

export default Applications;
