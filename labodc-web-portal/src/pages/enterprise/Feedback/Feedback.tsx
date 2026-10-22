import React, { useEffect, useState } from 'react';
import { Card, Form, Input, Button, Rate, Select, message, List, Tag, Switch, Divider } from 'antd';
import { MessageOutlined } from '@ant-design/icons';
import { useSearchParams } from 'react-router-dom';
import { getProjects } from '@/services/enterprise/project.service';
import { createFeedback, getFeedbacks, EnterpriseFeedback } from '@/services/enterprise/feedback.service';
import '../enterprise-modern.css';

const Feedback: React.FC = () => {
  const [form] = Form.useForm();
  const [projects, setProjects] = useState<any[]>([]);
  const [feedbacks, setFeedbacks] = useState<EnterpriseFeedback[]>([]);
  const [submitting, setSubmitting] = useState(false);
  const [loading, setLoading] = useState(false);
  const [searchParams] = useSearchParams();

  useEffect(() => {
    const loadProjects = async () => {
      try {
        const list = await getProjects('ALL');
        const allProjects = Array.isArray(list) ? list : [];
        setProjects(allProjects);
      } catch {
        setProjects([]);
      }
    };

    const loadFeedbacks = async () => {
      try {
        setLoading(true);
        const list = await getFeedbacks();
        const all = Array.isArray(list) ? list : [];
        const projectIdParam = searchParams.get('projectId');
        if (projectIdParam) {
          const projectId = Number(projectIdParam);
          setFeedbacks(all.filter((f) => Number(f.projectId) === projectId));
        } else {
          setFeedbacks(all);
        }
      } catch {
        setFeedbacks([]);
      } finally {
        setLoading(false);
      }
    };

    loadProjects();
    loadFeedbacks();
  }, [searchParams]);

  const onSubmit = async () => {
    try {
      const values = await form.validateFields();
      setSubmitting(true);
      await createFeedback({
        projectId: Number(values.projectId),
        overallRating: Number(values.overallRating),
        qualityRating: values.qualityRating ? Number(values.qualityRating) : undefined,
        communicationRating: values.communicationRating
          ? Number(values.communicationRating)
          : undefined,
        timelineRating: values.timelineRating ? Number(values.timelineRating) : undefined,
        professionalismRating: values.professionalismRating
          ? Number(values.professionalismRating)
          : undefined,
        positiveFeedback: values.positiveFeedback,
        negativeFeedback: values.negativeFeedback,
        suggestions: values.suggestions,
        wouldRecommend: values.wouldRecommend ?? false,
        wouldWorkAgain: values.wouldWorkAgain ?? false,
      });
      message.success('Gửi đánh giá thành công');
      form.resetFields();
      const list = await getFeedbacks();
      const all = Array.isArray(list) ? list : [];
      const projectIdParam = searchParams.get('projectId');
      if (projectIdParam) {
        const projectId = Number(projectIdParam);
        setFeedbacks(all.filter((f) => Number(f.projectId) === projectId));
      } else {
        setFeedbacks(all);
      }
    } catch (err: any) {
      if (err?.errorFields) return;
      message.error(err?.message || 'Không thể gửi đánh giá');
    } finally {
      setSubmitting(false);
    }
  };

  return (
    <div className="page-wrapper">
      <div className="page-header">
        <h1>Đánh giá dự án</h1>
        <Button type="primary" icon={<MessageOutlined />} onClick={onSubmit} loading={submitting}>
          Gửi đánh giá
        </Button>
      </div>

      <Card className="modern-card">
        <Form form={form} layout="vertical">
          <Form.Item
            label="Dự án"
            name="projectId"
            rules={[{ required: true, message: 'Chọn dự án' }]}
          >
          <Select
            placeholder="Chọn dự án"
            options={projects.map((p) => ({
                label: String(p?.status || '').toUpperCase() === 'COMPLETED' || Number(p?.progress) >= 100
                  ? p.name
                  : `${p.name} (Chưa hoàn thành)`,
                value: Number(p.key),
                disabled: !(String(p?.status || '').toUpperCase() === 'COMPLETED' || Number(p?.progress) >= 100),
              }))}
          />
          </Form.Item>

          <Form.Item
            label="Đánh giá tổng quan"
            name="overallRating"
            rules={[{ required: true, message: 'Chọn mức đánh giá' }]}
          >
            <Rate />
          </Form.Item>

          <Divider />

          <Form.Item label="Chất lượng" name="qualityRating">
            <Rate />
          </Form.Item>
          <Form.Item label="Giao tiếp" name="communicationRating">
            <Rate />
          </Form.Item>
          <Form.Item label="Đúng tiến độ" name="timelineRating">
            <Rate />
          </Form.Item>
          <Form.Item label="Tác phong" name="professionalismRating">
            <Rate />
          </Form.Item>

          <Form.Item
            label="Phản hồi tích cực"
            name="positiveFeedback"
            rules={[{ required: true, message: 'Nhập nội dung phản hồi' }]}
          >
            <Input.TextArea rows={4} placeholder="Điểm tốt nhất của dự án..." />
          </Form.Item>

          <Form.Item label="Điểm cần cải thiện" name="negativeFeedback">
            <Input.TextArea rows={3} placeholder="Điểm cần cải thiện (nếu có)" />
          </Form.Item>

          <Form.Item label="Gợi ý khác" name="suggestions">
            <Input.TextArea rows={3} placeholder="Gợi ý thêm (nếu có)" />
          </Form.Item>

          <Form.Item
            label="Bạn có muốn giới thiệu dự án này không?"
            name="wouldRecommend"
            valuePropName="checked"
          >
            <Switch />
          </Form.Item>

          <Form.Item
            label="Bạn có muốn hợp tác lại không?"
            name="wouldWorkAgain"
            valuePropName="checked"
          >
            <Switch />
          </Form.Item>
        </Form>
      </Card>

      <Card className="modern-card" style={{ marginTop: 16 }}>
        <List
          loading={loading}
          dataSource={feedbacks}
          locale={{ emptyText: 'Chưa có đánh giá' }}
          renderItem={(item) => (
            <List.Item>
              <List.Item.Meta
                title={
                  <div style={{ display: 'flex', gap: 8, alignItems: 'center' }}>
                    <strong>{item.projectName}</strong>
                    <Tag color="blue">{item.overallRating ?? '-'}/5</Tag>
                  </div>
                }
                description={
                  <div>
                    <div style={{ display: 'flex', gap: 8, flexWrap: 'wrap', marginBottom: 6 }}>
                      {item.qualityRating != null && <Tag>Chất lượng: {item.qualityRating}/5</Tag>}
                      {item.communicationRating != null && <Tag>Giao tiếp: {item.communicationRating}/5</Tag>}
                      {item.timelineRating != null && <Tag>Tiến độ: {item.timelineRating}/5</Tag>}
                      {item.professionalismRating != null && <Tag>Tác phong: {item.professionalismRating}/5</Tag>}
                    </div>
                    {item.positiveFeedback ? (
                      <div style={{ marginBottom: 6 }}>Phản hồi tích cực: {item.positiveFeedback}</div>
                    ) : null}
                    {item.negativeFeedback ? (
                      <div style={{ marginBottom: 6, color: '#b91c1c' }}>
                        Điểm cần cải thiện: {item.negativeFeedback}
                      </div>
                    ) : null}
                    {item.suggestions ? (
                      <div style={{ marginBottom: 6 }}>Gợi ý: {item.suggestions}</div>
                    ) : null}
                    <div style={{ display: 'flex', gap: 12, marginBottom: 6 }}>
                      <span>Giới thiệu: {item.wouldRecommend ? 'Có' : 'Không'}</span>
                      <span>Hợp tác lại: {item.wouldWorkAgain ? 'Có' : 'Không'}</span>
                    </div>
                    <div style={{ color: '#64748b' }}>{item.submittedAt || item.createdAt}</div>
                  </div>
                }
              />
            </List.Item>
          )}
        />
      </Card>
    </div>
  );
};

export default Feedback;
