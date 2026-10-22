import React, { useEffect, useState } from 'react';
import {
  CheckCircleOutlined,
  CloseCircleOutlined,
  CalendarOutlined,
  ClockCircleOutlined,
  TeamOutlined,
  ReloadOutlined,
} from '@ant-design/icons';
import { Alert, Button, Card, Col, Divider, message, Modal, Row, Spin, Statistic, Tag } from 'antd';
import TextArea from 'antd/es/input/TextArea';
import { mentorService } from '@/services/mentor/mentorService';
import { IMentorInvitation } from '@/types/mentor.types';
import styles from './ProjectInvitations.module.css';

const priorityColor = (priority: string) => {
  switch (priority) {
    case 'high':
      return '#ff4d4f';
    case 'medium':
      return '#faad14';
    case 'low':
      return '#52c41a';
    default:
      return '#d9d9d9';
  }
};

const priorityText = (priority: string) => {
  switch (priority) {
    case 'high':
      return 'Ưu tiên cao';
    case 'medium':
      return 'Ưu tiên trung bình';
    case 'low':
      return 'Ưu tiên thấp';
    default:
      return '';
  }
};

const ProjectInvitations: React.FC = () => {
  const [invitations, setInvitations] = useState<IMentorInvitation[]>([]);
  const [loading, setLoading] = useState<boolean>(true);
  const [error, setError] = useState<string | null>(null);
  const [rejectModalVisible, setRejectModalVisible] = useState(false);
  const [selectedInvitationId, setSelectedInvitationId] = useState<string | null>(null);
  const [rejectReason, setRejectReason] = useState('');

  useEffect(() => {
    loadInvitations();
  }, []);

  const loadInvitations = async () => {
    setLoading(true);
    setError(null);
    try {
      const data = await mentorService.getInvitations();
      setInvitations(data);
    } catch (err) {
      console.error('Failed to load invitations', err);
      setError('Không thể tải lời mời từ hệ thống.');
    } finally {
      setLoading(false);
    }
  };

  const handleAccept = async (id: string) => {
    try {
      await mentorService.acceptInvitation(id);
      message.success('Đã chấp nhận lời mời thành công!');
      setInvitations((prev) => prev.filter((inv) => inv.id !== id));
    } catch (err) {
      console.error('Failed to accept invitation', err);
      message.error('Không thể chấp nhận lời mời. Vui lòng thử lại.');
    }
  };

  const handleRejectClick = (id: string) => {
    setSelectedInvitationId(id);
    setRejectModalVisible(true);
  };

  const handleRejectConfirm = async () => {
    if (!selectedInvitationId) return;

    try {
      await mentorService.rejectInvitation(selectedInvitationId, rejectReason);
      message.success('Đã từ chối lời mời');
      setInvitations((prev) => prev.filter((inv) => inv.id !== selectedInvitationId));
      setRejectModalVisible(false);
      setRejectReason('');
      setSelectedInvitationId(null);
    } catch (err) {
      console.error('Failed to reject invitation', err);
      message.error('Không thể từ chối lời mời. Vui lòng thử lại.');
    }
  };

  if (loading) {
    return (
      <div className={styles.loadingContainer}>
        <Spin size="large" />
      </div>
    );
  }

  return (
    <div className={styles.pageWrapper}>
      <div className={styles.dashboardContainer}>
        <div className={styles.header}>
          <div>
            <h1 className={styles.title}>
              Lời mời hướng dẫn
              <span className={styles.subtitle}>Quản lý lời mời & sắp xếp mentor</span>
            </h1>
          </div>
          <Button
            type="primary"
            icon={<ReloadOutlined />}
            onClick={loadInvitations}
            className={styles.refreshBtn}
          >
            Làm mới
          </Button>
        </div>

        <Divider className={styles.divider} />

        {error && (
          <Alert
            type="error"
            message="Lỗi tải lời mời"
            description={error}
            showIcon
            style={{ marginBottom: '24px' }}
          />
        )}

        {/* Stats Row */}
        <Row gutter={[16, 16]} className={styles.statsRow}>
          <Col xs={24} sm={8}>
            <Card className={styles.statCard}>
              <Statistic
                title="Tổng lời mời"
                value={invitations.length}
                prefix="📨"
                valueStyle={{ color: '#1890ff' }}
              />
            </Card>
          </Col>
          <Col xs={24} sm={8}>
            <Card className={styles.statCard}>
              <Statistic
                title="Ưu tiên cao"
                value={invitations.filter((inv) => inv.priority === 'high').length}
                prefix="🔥"
                valueStyle={{ color: '#ff4d4f' }}
              />
            </Card>
          </Col>
          <Col xs={24} sm={8}>
            <Card className={styles.statCard}>
              <Statistic
                title="Sinh viên chờ"
                value={invitations.reduce((sum, inv) => sum + inv.studentCount, 0)}
                prefix="👥"
                valueStyle={{ color: '#52c41a' }}
              />
            </Card>
          </Col>
        </Row>

        {/* Empty State */}
        {invitations.length === 0 && !loading && (
          <Card className={styles.emptyCard}>
            <div style={{ fontSize: '64px', marginBottom: '16px' }}>📭</div>
            <h3 style={{ fontSize: '20px', fontWeight: 600, marginBottom: '8px' }}>
              Không có lời mời mới
            </h3>
            <p style={{ color: '#8c8c8c' }}>
              Các lời mời đang được cập nhật từ hệ thống.
            </p>
          </Card>
        )}

        {/* Invitations List */}
        <div className={styles.list}>
          {invitations.map((invitation) => (
            <Card key={invitation.id} className={styles.invitationCard}>
              <div className={styles.cardHeader}>
                <div>
                  <div className={styles.titleRow}>
                    <h3 className={styles.projectName}>{invitation.projectName}</h3>
                    <Tag
                      color={priorityColor(invitation.priority)}
                      style={{ fontWeight: 600 }}
                    >
                      {priorityText(invitation.priority)}
                    </Tag>
                  </div>
                  <p className={styles.metaText}>
                    <TeamOutlined /> {invitation.groupName} • {invitation.studentCount} sinh viên
                  </p>
                </div>
                <div className={styles.receivedDate}>
                  Nhận {new Date(invitation.receivedDate).toLocaleDateString('vi-VN')}
                </div>
              </div>

              <p className={styles.description}>{invitation.description}</p>

              <div className={styles.skillRow}>
                <span className={styles.skillLabel}>Kỹ năng yêu cầu:</span>
                <div className={styles.skillTags}>
                  {invitation.skills.map((skill) => (
                    <Tag key={skill} color="blue">
                      {skill}
                    </Tag>
                  ))}
                </div>
              </div>

              <Row gutter={16} className={styles.metaRow}>
                <Col span={12}>
                  <div className={styles.metaItem}>
                    <CalendarOutlined />
                    <div>
                      <span className={styles.metaLabel}>Deadline</span>
                      <span className={styles.metaValue}>
                        {new Date(invitation.deadline).toLocaleDateString('vi-VN')}
                      </span>
                    </div>
                  </div>
                </Col>
                <Col span={12}>
                  <div className={styles.metaItem}>
                    <ClockCircleOutlined />
                    <div>
                      <span className={styles.metaLabel}>Thời gian còn lại</span>
                      <span className={styles.metaValue}>
                        {Math.ceil(
                          (new Date(invitation.deadline).getTime() - Date.now()) / (1000 * 60 * 60 * 24)
                        )}{' '}
                        ngày
                      </span>
                    </div>
                  </div>
                </Col>
              </Row>

              <div className={styles.actionRow}>
                <Button
                  type="primary"
                  icon={<CheckCircleOutlined />}
                  size="large"
                  onClick={() => handleAccept(invitation.id)}
                >
                  Chấp nhận
                </Button>
                <Button
                  danger
                  icon={<CloseCircleOutlined />}
                  size="large"
                  onClick={() => handleRejectClick(invitation.id)}
                >
                  Từ chối
                </Button>
              </div>
            </Card>
          ))}
        </div>

        {/* Reject Modal */}
        <Modal
          title="Từ chối lời mời"
          open={rejectModalVisible}
          onOk={handleRejectConfirm}
          onCancel={() => {
            setRejectModalVisible(false);
            setRejectReason('');
            setSelectedInvitationId(null);
          }}
          okText="Xác nhận từ chối"
          cancelText="Hủy"
          okButtonProps={{ danger: true }}
        >
          <p>Vui lòng cho biết lý do từ chối lời mời này:</p>
          <TextArea
            rows={4}
            value={rejectReason}
            onChange={(e) => setRejectReason(e.target.value)}
            placeholder="Nhập lý do từ chối (không bắt buộc)"
          />
        </Modal>
      </div>
    </div>
  );
};

export default ProjectInvitations;