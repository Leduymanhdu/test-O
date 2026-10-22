/*
 * NOTE: This file was left in a corrupted state during a refactor.
 * It is kept only to avoid breaking any stale imports.
 * The actual implementation lives in EvaluationPage.tsx.
 */

export { default } from './EvaluationPage';

/*
import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import {
  import React, { useEffect, useMemo, useState } from 'react';
  import { useNavigate } from 'react-router-dom';
  import {
    ArrowLeftOutlined,
    EditOutlined,
    ReloadOutlined,
  } from '@ant-design/icons';
  import {
    Button,
    Card,
    Col,
    DatePicker,
    Divider,
    Form,
    Input,
    InputNumber,
    message,
    Modal,
    Row,
    Select,
    Space,
    Table,
    Tag,
    Typography,
  } from 'antd';
  import dayjs, { Dayjs } from 'dayjs';
  import { mentorService } from '@/services/mentor/mentorService';
  import type {
    IMentorEvaluationCriterion,
    IMentorProjectOption,
    IMentorTalentEvaluation,
    IMentorTalentOption,
  } from '@/types/mentor.types';
  import styles from './Evaluation.module.css';

  const { Text } = Typography;

  const criteriaConfig = [
    { key: 'technicalSkills', label: 'Kỹ năng kỹ thuật' },
    { key: 'problemSolving', label: 'Giải quyết vấn đề' },
    { key: 'teamwork', label: 'Làm việc nhóm' },
    { key: 'communication', label: 'Giao tiếp' },
    { key: 'codeQuality', label: 'Chất lượng code' },
    { key: 'punctuality', label: 'Đúng hạn / Kỷ luật' },
  ] as const;

  type CriteriaKey = (typeof criteriaConfig)[number]['key'];

  const clampScore = (value: unknown): number | undefined => {
    if (value === undefined || value === null) return undefined;
    const v = Number(value);
    if (Number.isNaN(v)) return undefined;
    return Math.max(0, Math.min(10, v));
  };

  const calculateGrade10 = (score?: number): IMentorTalentEvaluation['grade'] | undefined => {
    if (score === undefined || score === null || Number.isNaN(score)) return undefined;
    if (score >= 9) return 'A';
    if (score >= 8) return 'B';
    if (score >= 7) return 'C';
    if (score >= 6) return 'D';
    return 'F';
  };

  type TalentRow = IMentorTalentOption & {
    key: string;
    evaluation?: IMentorTalentEvaluation;
  };

  const Evaluation: React.FC = () => {
    const navigate = useNavigate();
    const [form] = Form.useForm();

    const [projects, setProjects] = useState<IMentorProjectOption[]>([]);
    const [selectedProjectId, setSelectedProjectId] = useState<string | undefined>(undefined);
    const [period, setPeriod] = useState<Dayjs>(dayjs());

    const [talents, setTalents] = useState<IMentorTalentOption[]>([]);
    const [evaluations, setEvaluations] = useState<IMentorTalentEvaluation[]>([]);

    const [loadingProjects, setLoadingProjects] = useState(false);
    const [loadingList, setLoadingList] = useState(false);
    const [saving, setSaving] = useState(false);

    const [modalOpen, setModalOpen] = useState(false);
    const [activeTalent, setActiveTalent] = useState<IMentorTalentOption | null>(null);

    const periodString = useMemo(() => period.format('YYYY-MM'), [period]);

    useEffect(() => {
      const run = async () => {
        setLoadingProjects(true);
        try {
          const data = await mentorService.getProjects();
          setProjects(data);
        } catch (err) {
          console.error('Failed to load mentor projects', err);
          message.error('Không thể tải danh sách dự án.');
        } finally {
          setLoadingProjects(false);
        }
      };
      void run();
    }, []);

    const loadForProject = async (projectId: string) => {
      setLoadingList(true);
      try {
        const [talentList, evalList] = await Promise.all([
          mentorService.getProjectTalents(projectId),
          mentorService.getEvaluations(projectId),
        ]);
        setTalents(talentList);
        setEvaluations(evalList);
      } catch (err) {
        console.error('Failed to load evaluation data', err);
        message.error('Không thể tải dữ liệu đánh giá.');
      } finally {
        setLoadingList(false);
      }
    };

    useEffect(() => {
      if (!selectedProjectId) {
        setTalents([]);
        setEvaluations([]);
        return;
      }
      void loadForProject(selectedProjectId);
    }, [selectedProjectId]);

    const evaluationForTalentPeriod = useMemo(() => {
      const map = new Map<number, IMentorTalentEvaluation>();
      for (const e of evaluations) {
        if (e.evaluationPeriod === periodString) {
          map.set(Number(e.talentId), e);
        }
      }
      return map;
    }, [evaluations, periodString]);

    const rows: TalentRow[] = useMemo(() => {
      return talents.map((t) => {
        const evaluation = evaluationForTalentPeriod.get(Number(t.talentId));
        return {
          ...t,
          key: String(t.talentId),
          evaluation,
        };
      });
    }, [talents, evaluationForTalentPeriod]);

    const watched = Form.useWatch([], form) as Record<string, any> | undefined;
    const computedOverall = useMemo(() => {
      const scores: number[] = [];
      for (const c of criteriaConfig) {
        const v = clampScore(watched?.[c.key]?.score);
        if (v !== undefined) scores.push(v);
      }
      if (!scores.length) return undefined;
      const avg = scores.reduce((a, b) => a + b, 0) / scores.length;
      return Math.round(avg * 10) / 10;
    }, [watched]);
    const computedGrade = useMemo(() => calculateGrade10(computedOverall), [computedOverall]);

    const openModal = (talent: IMentorTalentOption) => {
      setActiveTalent(talent);

      const existing = evaluationForTalentPeriod.get(Number(talent.talentId));
      const existingPeriod = existing?.evaluationPeriod
        ? dayjs(existing.evaluationPeriod, 'YYYY-MM')
        : period;

      form.resetFields();
      form.setFieldsValue({
        evaluationPeriod: existingPeriod,

        technicalSkills: existing?.technicalSkills,
        problemSolving: existing?.problemSolving,
        teamwork: existing?.teamwork,
        communication: existing?.communication,
        codeQuality: existing?.codeQuality,
        punctuality: existing?.punctuality,

        strengths: existing?.strengths || [],
        weaknesses: existing?.weaknesses || [],
        recommendations: existing?.recommendations || [],
        tasksCompleted: existing?.tasksCompleted,
        tasksTotal: existing?.tasksTotal,
        hoursWorked: existing?.hoursWorked,
      });

      setModalOpen(true);
    };

    const closeModal = () => {
      setModalOpen(false);
      setActiveTalent(null);
      form.resetFields();
    };

    const submit = async () => {
      if (!selectedProjectId) {
        message.error('Vui lòng chọn dự án.');
        return;
      }
      if (!activeTalent) {
        message.error('Không tìm thấy sinh viên.');
        return;
      }

      try {
        const values = await form.validateFields();
        const evalPeriod: Dayjs | undefined = values.evaluationPeriod;
        const evaluationPeriod = (evalPeriod || period).format('YYYY-MM');

        const payload: Partial<IMentorTalentEvaluation> & {
          talentId: string | number;
          evaluationPeriod: string;
        } = {
          talentId: activeTalent.talentId,
          evaluationPeriod,
          overallScore: computedOverall,

          technicalSkills: values.technicalSkills,
          problemSolving: values.problemSolving,
          teamwork: values.teamwork,
          communication: values.communication,
          codeQuality: values.codeQuality,
          punctuality: values.punctuality,

          strengths: values.strengths || [],
          weaknesses: values.weaknesses || [],
          recommendations: values.recommendations || [],

          tasksCompleted: values.tasksCompleted,
          tasksTotal: values.tasksTotal,
          hoursWorked: values.hoursWorked,
        };

        setSaving(true);
        await mentorService.submitEvaluation(selectedProjectId, payload);
        message.success('Đã lưu đánh giá.');
        closeModal();
        await loadForProject(selectedProjectId);
      } catch (err) {
        console.error('Failed to submit evaluation', err);
        message.error('Không thể lưu đánh giá.');
      } finally {
        setSaving(false);
      }
    };

    const renderCriterion = (key: CriteriaKey, label: string) => (
      <Row gutter={12} key={key} style={{ marginBottom: 12 }}>
        <Col xs={24} md={8}>
          <Form.Item
            label={`${label} (điểm)`}
            name={[key, 'score']}
            rules={[{ required: true, message: 'Vui lòng nhập điểm' }]}
          >
            <InputNumber min={0} max={10} step={0.5} style={{ width: '100%' }} />
          </Form.Item>
        </Col>
        <Col xs={24} md={16}>
          <Form.Item label={`${label} (nhận xét)`} name={[key, 'comment']}>
            <Input placeholder="Ghi chú ngắn (tuỳ chọn)" />
          </Form.Item>
        </Col>
      </Row>
    );

    return (
      <div className={styles.pageWrapper}>
        <div className={styles.dashboardContainer}>
          <div className={styles.header}>
            <div>
              <h1 className={styles.title}>
                Đánh giá sinh viên
                <span className={styles.subtitle}>
                  Lưu theo kỳ (YYYY-MM) và tiêu chí (JSONB)
                </span>
              </h1>
            </div>
            <Space>
              <Button icon={<ArrowLeftOutlined />} onClick={() => navigate('/mentor/dashboard')}>
                Quay lại
              </Button>
            </Space>
          </div>

          <Divider className={styles.divider} />

          <Card title="Bộ lọc" className={styles.sectionCard}>
            <Row gutter={12} align="middle">
              <Col xs={24} md={12}>
                <Space direction="vertical" style={{ width: '100%' }} size={4}>
                  <Text strong>Dự án</Text>
                  <Select
                    showSearch
                    placeholder="Chọn dự án"
                    loading={loadingProjects}
                    value={selectedProjectId}
                    onChange={(v) => setSelectedProjectId(String(v))}
                    optionFilterProp="label"
                    options={projects.map((p) => ({
                      value: String(p.id),
                      label: p.title,
                    }))}
                  />
                </Space>
              </Col>
              <Col xs={24} md={8}>
                <Space direction="vertical" style={{ width: '100%' }} size={4}>
                  <Text strong>Kỳ đánh giá</Text>
                  <DatePicker
                    picker="month"
                    value={period}
                    onChange={(v) => setPeriod(v || dayjs())}
                    style={{ width: '100%' }}
                    format="YYYY-MM"
                  />
                </Space>
              </Col>
              <Col xs={24} md={4}>
                <Space direction="vertical" style={{ width: '100%' }} size={4}>
                  <Text strong>&nbsp;</Text>
                  <Button
                    icon={<ReloadOutlined />}
                    disabled={!selectedProjectId}
                    loading={loadingList}
                    onClick={() => selectedProjectId && loadForProject(selectedProjectId)}
                    block
                  >
                    Làm mới
                  </Button>
                </Space>
              </Col>
            </Row>
          </Card>

          <Card
            title={
              <Space>
                <span>Danh sách sinh viên</span>
                <Tag color="blue">{periodString}</Tag>
              </Space>
            }
            className={styles.sectionCard}
          >
            <Table<TalentRow>
              loading={loadingList}
              dataSource={rows}
              pagination={{ pageSize: 10 }}
              columns={[
                {
                  title: 'Họ tên',
                  dataIndex: 'fullName',
                  key: 'fullName',
                  render: (v) => v || '—',
                },
                {
                  title: 'MSSV',
                  dataIndex: 'studentId',
                  key: 'studentId',
                  width: 140,
                  render: (v) => v || '—',
                },
                {
                  title: 'Điểm',
                  key: 'score',
                  width: 100,
                  render: (_, r) => (r.evaluation?.overallScore ?? '—'),
                },
                {
                  title: 'Xếp loại',
                  key: 'grade',
                  width: 100,
                  render: (_, r) => {
                    const g = r.evaluation?.grade;
                    if (!g) return '—';
                    const color = g === 'A' ? 'green' : g === 'B' ? 'lime' : g === 'C' ? 'gold' : g === 'D' ? 'orange' : 'red';
                    return <Tag color={color}>{g}</Tag>;
                  },
                },
                {
                  title: 'Trạng thái',
                  key: 'status',
                  width: 130,
                  render: (_, r) =>
                    r.evaluation ? <Tag color="green">Đã đánh giá</Tag> : <Tag>Chưa đánh giá</Tag>,
                },
                {
                  title: 'Hành động',
                  key: 'actions',
                  width: 140,
                  render: (_, r) => (
                    <Button
                      type="primary"
                      icon={<EditOutlined />}
                      disabled={!selectedProjectId}
                      onClick={() => openModal(r)}
                    >
                      Đánh giá
                    </Button>
                  ),
                },
              ]}
              locale={{
                emptyText: selectedProjectId
                  ? 'Không có sinh viên trong dự án.'
                  : 'Vui lòng chọn dự án để xem danh sách.',
              }}
            />
          </Card>

          <Modal
            open={modalOpen}
            onCancel={closeModal}
            onOk={submit}
            okButtonProps={{ loading: saving }}
            width={900}
            title={
              <Space direction="vertical" size={0}>
                <Text strong>Đánh giá sinh viên</Text>
                <Text type="secondary">
                  {activeTalent?.fullName || '—'} {activeTalent?.studentId ? `• ${activeTalent.studentId}` : ''}
                </Text>
              </Space>
            }
          >
            <Form form={form} layout="vertical">
              <Card size="small" style={{ marginBottom: 12 }}>
                <Row gutter={12} align="middle">
                  <Col xs={24} md={8}>
                    <Form.Item name="evaluationPeriod" label="Kỳ đánh giá" rules={[{ required: true }]}>
                      <DatePicker picker="month" format="YYYY-MM" style={{ width: '100%' }} />
                    </Form.Item>
                  </Col>
                  <Col xs={24} md={16}>
                    <Space direction="vertical" size={0} style={{ width: '100%' }}>
                      <Text type="secondary">Điểm tổng kết (tự tính từ 6 tiêu chí)</Text>
                      <Space>
                        <Tag color="blue">{computedOverall ?? '—'}/10</Tag>
                        <Tag color={computedGrade === 'A' ? 'green' : computedGrade === 'B' ? 'lime' : computedGrade === 'C' ? 'gold' : computedGrade === 'D' ? 'orange' : computedGrade ? 'red' : 'default'}>
                          {computedGrade ?? '—'}
                        </Tag>
                      </Space>
                    </Space>
                  </Col>
                </Row>
              </Card>

              <Card size="small" title="Tiêu chí" style={{ marginBottom: 12 }}>
                {criteriaConfig.map((c) => renderCriterion(c.key, c.label))}
              </Card>

              <Card size="small" title="Tiến độ" style={{ marginBottom: 12 }}>
                <Row gutter={12}>
                  <Col xs={24} md={8}>
                    <Form.Item name="tasksCompleted" label="Số task đã hoàn thành">
                      <InputNumber min={0} style={{ width: '100%' }} />
                    </Form.Item>
                  </Col>
                  <Col xs={24} md={8}>
                    <Form.Item name="tasksTotal" label="Tổng số task">
                      <InputNumber min={0} style={{ width: '100%' }} />
                    </Form.Item>
                  </Col>
                  <Col xs={24} md={8}>
                    <Form.Item name="hoursWorked" label="Số giờ làm việc">
                      <InputNumber min={0} style={{ width: '100%' }} />
                    </Form.Item>
                  </Col>
                </Row>
              </Card>

              <Card size="small" title="Nhận xét">
                <Form.Item name="strengths" label="Điểm mạnh">
                  <Select mode="tags" tokenSeparators={[',']} placeholder="Nhập và nhấn Enter" />
                </Form.Item>
                <Form.Item name="weaknesses" label="Điểm cần cải thiện">
                  <Select mode="tags" tokenSeparators={[',']} placeholder="Nhập và nhấn Enter" />
                </Form.Item>
                <Form.Item name="recommendations" label="Đề xuất">
                  <Select mode="tags" tokenSeparators={[',']} placeholder="Nhập và nhấn Enter" />
                </Form.Item>
              </Card>
            </Form>
          </Modal>
        </div>
      </div>
    );
  };

  export default Evaluation;
                                      title: 'Sinh viên',
                                      dataIndex: 'fullName',
                                      render: (_, r) => (
                                        <div>
                                          <div style={{ fontWeight: 600 }}>{r.fullName}</div>
                                          <div style={{ color: '#8c8c8c' }}>{r.studentId || ''}</div>
                                        </div>
                                      ),
                                    },
                                    {
                                      title: 'Điểm',
                                      width: 120,
                                      render: (_, r) => {
                                        const e = evaluationForTalentPeriod.get(Number(r.talentId));
                                        return e?.overallScore !== undefined ? (
                                          <span>{e.overallScore}/10</span>
                                        ) : (
                                          <span style={{ color: '#8c8c8c' }}>—</span>
                                        );
                                      },
                                    },
                                    {
                                      title: 'Xếp loại',
                                      width: 110,
                                      render: (_, r) => {
                                        const e = evaluationForTalentPeriod.get(Number(r.talentId));
                                        const g = e?.grade;
                                        if (!g) return <span style={{ color: '#8c8c8c' }}>—</span>;
                                        const color = g === 'A' ? 'green' : g === 'B' ? 'blue' : g === 'C' ? 'gold' : g === 'D' ? 'orange' : 'red';
                                        return <Tag color={color}>{g}</Tag>;
                                      },
                                    },
                                    {
                                      title: 'Hành động',
                                      width: 160,
                                      render: (_, r) => {
                                        const existing = evaluationForTalentPeriod.get(Number(r.talentId));
                                        return (
                                          <Button type="primary" onClick={() => openModal(r)}>
                                            {existing ? 'Cập nhật' : 'Đánh giá'}
                                          </Button>
                                        );
                                      },
                                    },
                                  ]}
                                  locale={{ emptyText: selectedProjectId ? 'Chưa có sinh viên trong dự án' : 'Chọn dự án để xem danh sách' }}
                                />
                              </Card>

                              <Modal
                                title={
                                  <div>
                                    <div style={{ fontWeight: 700 }}>Phiếu đánh giá</div>
                                    <div style={{ color: '#8c8c8c' }}>
                                      {activeTalent?.fullName} {activeTalent?.studentId ? `(${activeTalent.studentId})` : ''}
                                    </div>
                                  </div>
                                }
                                open={modalOpen}
                                onCancel={() => {
                                  setModalOpen(false);
                                  setActiveTalent(null);
                                }}
                                onOk={submit}
                                okText="Lưu"
                                confirmLoading={loading}
                                width={900}
                              >
                                <Form form={form} layout="vertical">
                                  <Row gutter={16}>
                                    <Col span={8}>
                                      <Form.Item name="evaluationPeriod" label="Kỳ đánh giá" rules={[{ required: true }]}>
                                        <DatePicker picker="month" format="YYYY-MM" style={{ width: '100%' }} />
                                      </Form.Item>
                                    </Col>
                                    <Col span={8}>
                                      <Form.Item label="Điểm tổng (0-10)">
                                        <Space>
                                          <Typography.Text strong>{computedOverall ?? '—'}</Typography.Text>
                                          {computedGrade && <Tag color={computedGrade === 'A' ? 'green' : computedGrade === 'B' ? 'blue' : computedGrade === 'C' ? 'gold' : computedGrade === 'D' ? 'orange' : 'red'}>{computedGrade}</Tag>}
                                        </Space>
                                      </Form.Item>
                                    </Col>
                                    <Col span={8}>
                                      <Form.Item name="hoursWorked" label="Số giờ làm">
                                        <InputNumber min={0} style={{ width: '100%' }} />
                                      </Form.Item>
                                    </Col>
                                  </Row>

                                  <Divider style={{ marginTop: 0 }} />

                                  <Row gutter={16}>
                                    {criteriaConfig.map((c) => (
                                      <Col span={12} key={c.key}>
                                        <Card size="small" title={c.label} style={{ marginBottom: 12 }}>
                                          <Row gutter={12}>
                                            <Col span={8}>
                                              <Form.Item name={[c.key, 'score']} label="Điểm" rules={[{ type: 'number', min: 0, max: 10 }]}>
                                                <InputNumber min={0} max={10} step={0.5} style={{ width: '100%' }} />
                                              </Form.Item>
                                            </Col>
                                            <Col span={16}>
                                              <Form.Item name={[c.key, 'comment']} label="Nhận xét">
                                                <Typography.Textarea
                                                  rows={2}
                                                  placeholder="Nhận xét ngắn (tuỳ chọn)"
                                                  style={{ width: '100%' }}
                                                />
                                              </Form.Item>
                                            </Col>
                                          </Row>
                                        </Card>
                                      </Col>
                                    ))}
                                  </Row>

                                  <Divider />

                                  <Row gutter={16}>
                                    <Col span={8}>
                                      <Form.Item name="tasksCompleted" label="Task đã hoàn thành">
                                        <InputNumber min={0} style={{ width: '100%' }} />
                                      </Form.Item>
                                    </Col>
                                    <Col span={8}>
                                      <Form.Item name="tasksTotal" label="Tổng task">
                                        <InputNumber min={0} style={{ width: '100%' }} />
                                      </Form.Item>
                                    </Col>
                                    <Col span={8}>
                                      <Form.Item label="Tỉ lệ">
                                        <Typography.Text>
                                          {(() => {
                                            const completed = watched?.tasksCompleted;
                                            const total = watched?.tasksTotal;
                                            const cNum = completed !== undefined ? Number(completed) : undefined;
                                            const tNum = total !== undefined ? Number(total) : undefined;
                                            if (!cNum && !tNum) return '—';
                                            if (!tNum) return '—';
                                            const pct = Math.round((Math.max(0, cNum || 0) / Math.max(1, tNum)) * 100);
                                            return `${pct}%`;
                                          })()}
                                        </Typography.Text>
                                      </Form.Item>
                                    </Col>
                                  </Row>

                                  <Row gutter={16}>
                                    <Col span={8}>
                                      <Form.Item name="strengths" label="Điểm mạnh">
                                        <Select mode="tags" placeholder="Nhập và Enter" tokenSeparators={[',']} />
                                      </Form.Item>
                                    </Col>
                                    <Col span={8}>
                                      <Form.Item name="weaknesses" label="Điểm cần cải thiện">
                                        <Select mode="tags" placeholder="Nhập và Enter" tokenSeparators={[',']} />
                                      </Form.Item>
                                    </Col>
                                    <Col span={8}>
                                      <Form.Item name="recommendations" label="Đề xuất">
                                        <Select mode="tags" placeholder="Nhập và Enter" tokenSeparators={[',']} />
                                      </Form.Item>
                                    </Col>
                                  </Row>
                                </Form>
                              </Modal>

*/
