import React, { useEffect, useMemo, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import {
  UploadOutlined,
  FileTextOutlined,
  ArrowLeftOutlined,
  CheckCircleOutlined,
  DownloadOutlined,
} from '@ant-design/icons';
import {
  Alert,
  Button,
  Card,
  Col,
  DatePicker,
  Divider,
  Form,
  Input,
  InputNumber,
  Spin,
  Table,
  Tag,
  message,
  Row,
  Select,
  Upload,
} from 'antd';
import type { UploadFile } from 'antd/es/upload/interface';
import type { ColumnsType } from 'antd/es/table';
import TextArea from 'antd/es/input/TextArea';
import dayjs from 'dayjs';
import { mentorService } from '@/services/mentor/mentorService';
import type { IMentorReport } from '@/types/mentor.types';
import styles from './ReportSubmission.module.css';

const ReportSubmission: React.FC = () => {
  const navigate = useNavigate();
  const [form] = Form.useForm();
  const [loading, setLoading] = useState(false);
  const [fileList, setFileList] = useState<UploadFile[]>([]);
  const [submitted, setSubmitted] = useState<{
    report: IMentorReport;
    uploadedFilename?: string;
    hasFile: boolean;
  } | null>(null);
  const [downloading, setDownloading] = useState(false);

  const [reports, setReports] = useState<IMentorReport[]>([]);
  const [reportsLoading, setReportsLoading] = useState(false);
  const [reportsError, setReportsError] = useState<string | null>(null);
  const [downloadingId, setDownloadingId] = useState<string | null>(null);

  const statusColor: Record<IMentorReport['status'], string> = useMemo(
    () => ({
      submitted: 'green',
      pending: 'gold',
      late: 'red',
    }),
    []
  );

  const loadReports = async () => {
    setReportsLoading(true);
    setReportsError(null);
    try {
      const data = await mentorService.getReports();
      setReports(data);
    } catch (err) {
      console.error('Failed to load mentor reports on submission page', err);
      setReportsError('Không thể tải danh sách báo cáo từ hệ thống.');
    } finally {
      setReportsLoading(false);
    }
  };

  useEffect(() => {
    loadReports();
  }, []);

  const tryGetFilename = (contentDisposition?: string, fallback?: string) => {
    if (contentDisposition) {
      const match = /filename\*=UTF-8''([^;]+)|filename="?([^";]+)"?/i.exec(contentDisposition);
      const raw = match?.[1] || match?.[2];
      if (raw) {
        try {
          return decodeURIComponent(raw);
        } catch {
          return raw;
        }
      }
    }
    return fallback || 'report.bin';
  };

  const downloadJustSubmittedFile = async () => {
    if (!submitted?.hasFile) {
      message.info('Báo cáo vừa nộp không có file đính kèm.');
      return;
    }
    setDownloading(true);
    try {
      const res = await mentorService.downloadReportFile(submitted.report.id);
      const blob = res.data as Blob;
      const filename = tryGetFilename(
        res.headers?.['content-disposition'],
        submitted.uploadedFilename || submitted.report.reportName
      );

      const url = window.URL.createObjectURL(blob);
      const a = document.createElement('a');
      a.href = url;
      a.download = filename;
      document.body.appendChild(a);
      a.click();
      a.remove();
      window.URL.revokeObjectURL(url);
    } catch (err) {
      console.error('Failed to download just-submitted report file', err);
      message.error('Tải file thất bại.');
    } finally {
      setDownloading(false);
    }
  };

  const downloadExistingFile = async (report: IMentorReport) => {
    if (!report.fileName && !report.fileSize) {
      message.info('Báo cáo này không có file đính kèm.');
      return;
    }

    setDownloadingId(report.id);
    try {
      const res = await mentorService.downloadReportFile(report.id);
      const blob = res.data as Blob;
      const filename = tryGetFilename(
        res.headers?.['content-disposition'],
        report.fileName || report.reportName
      );

      const url = window.URL.createObjectURL(blob);
      const a = document.createElement('a');
      a.href = url;
      a.download = filename;
      document.body.appendChild(a);
      a.click();
      a.remove();
      window.URL.revokeObjectURL(url);
    } catch (err) {
      console.error('Failed to download existing report file', err);
      message.error('Tải file thất bại.');
    } finally {
      setDownloadingId(null);
    }
  };

  const handleSubmit = async () => {
    try {
      const values = await form.validateFields();

      const uploadedFilename = fileList.length > 0 ? fileList[0]?.name : undefined;
      const hasFile = Boolean(fileList.length > 0 && fileList[0].originFileObj);

      // Create FormData for file upload
      const formData = new FormData();
      formData.append('projectId', values.projectId);
      formData.append('student', values.student);
      formData.append('studentId', values.studentId);
      formData.append('reportName', values.reportName);
      formData.append('submittedDate', values.submittedDate.toISOString());
      formData.append('dueDate', values.dueDate.toISOString());
      formData.append('status', values.status || 'submitted');

      if (values.summary) {
        formData.append('summary', values.summary);
      }

      // Attach file if uploaded
      if (fileList.length > 0 && fileList[0].originFileObj) {
        formData.append('file', fileList[0].originFileObj);
      }

      setLoading(true);
      const report = await mentorService.submitReport(formData);
      setSubmitted({ report, uploadedFilename, hasFile });
      await loadReports();
      message.success('Đã gửi báo cáo thành công!');
      form.resetFields();
      setFileList([]);
    } catch (err) {
      console.error('Failed to submit report', err);
      message.error('Không thể gửi báo cáo. Vui lòng thử lại.');
    } finally {
      setLoading(false);
    }
  };

  const columns: ColumnsType<IMentorReport> = [
    { title: 'Sinh viên', dataIndex: 'student', key: 'student' },
    { title: 'MSSV', dataIndex: 'studentId', key: 'studentId' },
    { title: 'Báo cáo', dataIndex: 'reportName', key: 'reportName' },
    {
      title: 'Tên file',
      dataIndex: 'fileName',
      key: 'fileName',
      render: (v: string | undefined, r) => {
        const hasFile = Boolean(r.fileName || r.fileSize);
        if (!hasFile) return '—';
        const name = v || 'Tải file';
        return (
          <Button
            type="link"
            icon={<DownloadOutlined />}
            loading={downloadingId === r.id}
            onClick={() => downloadExistingFile(r)}
          >
            {name}
          </Button>
        );
      },
    },
    {
      title: 'Trạng thái',
      dataIndex: 'status',
      key: 'status',
      render: (value: IMentorReport['status']) => <Tag color={statusColor[value]}>{value}</Tag>,
    },
    { title: 'Ngày nộp', dataIndex: 'submittedDate', key: 'submittedDate', width: 120 },
    { title: 'Hạn', dataIndex: 'dueDate', key: 'dueDate', width: 120 },
    { title: 'Điểm', dataIndex: 'score', key: 'score', width: 80 },
    { title: 'Dung lượng', dataIndex: 'fileSize', key: 'fileSize', width: 110 },
    {
      title: 'Tệp',
      key: 'file',
      width: 90,
      render: (_, r) => (
        <Button
          type="link"
          icon={<DownloadOutlined />}
          loading={downloadingId === r.id}
          disabled={!r.fileName && !r.fileSize}
          onClick={() => downloadExistingFile(r)}
        />
      ),
    },
  ];

  const uploadProps = {
    beforeUpload: (file: File) => {
      const isPDF = file.type === 'application/pdf';
      const isDoc =
        file.type === 'application/msword' ||
        file.type === 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';

      if (!isPDF && !isDoc) {
        message.error('Chỉ chấp nhận file PDF hoặc Word!');
        return false;
      }

      const isLt10M = file.size / 1024 / 1024 < 10;
      if (!isLt10M) {
        message.error('File phải nhỏ hơn 10MB!');
        return false;
      }

      setFileList([file as unknown as UploadFile]);
      return false; // Prevent auto upload
    },
    fileList,
    onRemove: () => {
      setFileList([]);
    },
    maxCount: 1,
  };

  return (
    <div className={styles.pageWrapper}>
      <div className={styles.dashboardContainer}>
        <div className={styles.header}>
          <div>
            <h1 className={styles.title}>
              Nộp báo cáo sinh viên
              <span className={styles.subtitle}>Gửi báo cáo tiến độ và đánh giá</span>
            </h1>
          </div>
          <Button icon={<ArrowLeftOutlined />} onClick={() => navigate('/mentor/dashboard')}>
            Quay lại
          </Button>
        </div>

        <Divider className={styles.divider} />

        <Alert
          message="Lưu ý"
          description="Báo cáo nên bao gồm: Tiến độ công việc, kỹ năng đạt được, khó khăn gặp phải, và đề xuất hỗ trợ."
          type="info"
          showIcon
          style={{ marginBottom: 24 }}
        />

        {submitted && (
          <Alert
            message="Gửi báo cáo thành công"
            description={
              <div>
                <div style={{ marginBottom: 8 }}>
                  <b>{submitted.report.reportName}</b> — {submitted.report.student} (
                  {submitted.report.studentId})
                </div>
                {submitted.hasFile && (
                  <div style={{ marginBottom: 8, color: '#666' }}>
                    File đã upload: <b>{submitted.report.fileName || submitted.uploadedFilename}</b>
                  </div>
                )}
                <div style={{ display: 'flex', gap: 12, flexWrap: 'wrap' }}>
                  <Button
                    type="primary"
                    icon={<DownloadOutlined />}
                    onClick={downloadJustSubmittedFile}
                    loading={downloading}
                    disabled={!submitted.hasFile}
                  >
                    Tải file vừa nộp
                  </Button>
                  <Button onClick={() => navigate('/mentor/reports')}>Xem danh sách báo cáo</Button>
                  <Button onClick={() => navigate('/mentor/dashboard')}>Về Dashboard</Button>
                </div>
              </div>
            }
            type="success"
            showIcon
            style={{ marginBottom: 24 }}
          />
        )}

        <Form form={form} layout="vertical">
          {/* Project & Student Info */}
          <Card
            title={
              <>
                <FileTextOutlined /> Thông tin báo cáo
              </>
            }
            className={styles.sectionCard}
          >
            <Row gutter={16}>
              <Col span={8}>
                <Form.Item
                  name="projectId"
                  label="Mã dự án"
                  rules={[{ required: true, message: 'Vui lòng nhập mã dự án' }]}
                >
                  <InputNumber placeholder="Nhập mã dự án" style={{ width: '100%' }} min={1} />
                </Form.Item>
              </Col>
              <Col span={8}>
                <Form.Item
                  name="studentId"
                  label="Mã sinh viên"
                  rules={[{ required: true, message: 'Vui lòng nhập MSSV' }]}
                >
                  <Input placeholder="Nhập MSSV" />
                </Form.Item>
              </Col>
              <Col span={8}>
                <Form.Item
                  name="student"
                  label="Tên sinh viên"
                  rules={[{ required: true, message: 'Vui lòng nhập tên sinh viên' }]}
                >
                  <Input placeholder="Nhập tên sinh viên" />
                </Form.Item>
              </Col>
            </Row>

            <Form.Item
              name="reportName"
              label="Tên báo cáo"
              rules={[{ required: true, message: 'Vui lòng nhập tên báo cáo' }]}
            >
              <Input placeholder="VD: Báo cáo tiến độ tháng 2/2026" />
            </Form.Item>

            <Row gutter={16}>
              <Col span={12}>
                <Form.Item
                  name="submittedDate"
                  label="Ngày nộp"
                  initialValue={dayjs()}
                  rules={[{ required: true, message: 'Vui lòng chọn ngày nộp' }]}
                >
                  <DatePicker style={{ width: '100%' }} format="DD/MM/YYYY" />
                </Form.Item>
              </Col>
              <Col span={12}>
                <Form.Item
                  name="dueDate"
                  label="Hạn nộp"
                  rules={[{ required: true, message: 'Vui lòng chọn hạn nộp' }]}
                >
                  <DatePicker style={{ width: '100%' }} format="DD/MM/YYYY" />
                </Form.Item>
              </Col>
            </Row>

            <Form.Item name="status" label="Trạng thái" initialValue="submitted">
              <Select>
                <Select.Option value="submitted">Đã nộp</Select.Option>
                <Select.Option value="pending">Chưa nộp</Select.Option>
                <Select.Option value="late">Nộp trễ</Select.Option>
              </Select>
            </Form.Item>
          </Card>

          {/* Report Content */}
          <Card title="Nội dung báo cáo" className={styles.sectionCard}>
            <Form.Item name="summary" label="Tóm tắt báo cáo">
              <TextArea
                rows={6}
                placeholder="Nhập tóm tắt báo cáo: tiến độ, thành tựu, khó khăn, đề xuất..."
              />
            </Form.Item>

            <Form.Item label="Đính kèm file báo cáo">
              <Upload {...uploadProps}>
                <Button icon={<UploadOutlined />}>Chọn file (PDF hoặc Word, tối đa 10MB)</Button>
              </Upload>
              {fileList.length > 0 && (
                <div style={{ marginTop: 8, color: '#52c41a' }}>
                  <CheckCircleOutlined /> {fileList[0].name}
                </div>
              )}
            </Form.Item>
          </Card>

          {/* Submit Button */}
          <div className={styles.submitRow}>
            <Button
              type="primary"
              size="large"
              icon={<CheckCircleOutlined />}
              onClick={handleSubmit}
              loading={loading}
            >
              Gửi báo cáo
            </Button>
          </div>
        </Form>

        <Divider className={styles.divider} />

        <Card
          title={
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
              <span>
                <FileTextOutlined /> Báo cáo đã nộp (đồng bộ database)
              </span>
              <Button onClick={loadReports} disabled={reportsLoading}>
                Làm mới
              </Button>
            </div>
          }
          className={styles.sectionCard}
        >
          {reportsError && (
            <Alert type="error" showIcon message={reportsError} style={{ marginBottom: 16 }} />
          )}
          {reportsLoading ? (
            <div style={{ display: 'flex', justifyContent: 'center', padding: 24 }}>
              <Spin />
            </div>
          ) : (
            <Table
              rowKey={(r) => r.id}
              columns={columns}
              dataSource={reports}
              pagination={{ pageSize: 8 }}
            />
          )}
        </Card>
      </div>
    </div>
  );
};

export default ReportSubmission;
