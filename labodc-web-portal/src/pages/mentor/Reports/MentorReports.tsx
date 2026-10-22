import React, { useEffect, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { Alert, Button, Card, Divider, Spin, Table, Tag, message } from 'antd';
import {
  DownloadOutlined,
  FileTextOutlined,
  PlusOutlined,
  ReloadOutlined,
} from '@ant-design/icons';
import type { ColumnsType } from 'antd/es/table';
import { mentorService } from '@/services/mentor/mentorService';
import type { IMentorReport } from '@/types/mentor.types';

const statusColor: Record<IMentorReport['status'], string> = {
  submitted: 'green',
  pending: 'gold',
  late: 'red',
};

const MentorReports: React.FC = () => {
  const navigate = useNavigate();
  const [items, setItems] = useState<IMentorReport[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [downloadingId, setDownloadingId] = useState<string | null>(null);

  const load = async () => {
    setLoading(true);
    setError(null);
    try {
      const data = await mentorService.getReports();
      setItems(data);
    } catch (err) {
      console.error('Failed to load mentor reports', err);
      setError('Không thể tải danh sách báo cáo.');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    load();
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

  const downloadFile = async (report: IMentorReport) => {
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
    } catch (e) {
      console.error('Failed to download report file', e);
      message.error('Tải file thất bại.');
    } finally {
      setDownloadingId(null);
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
            onClick={() => downloadFile(r)}
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
    { title: 'Ngày nộp', dataIndex: 'submittedDate', key: 'submittedDate' },
    { title: 'Hạn', dataIndex: 'dueDate', key: 'dueDate' },
    { title: 'Điểm', dataIndex: 'score', key: 'score' },
    { title: 'Dung lượng', dataIndex: 'fileSize', key: 'fileSize' },
    {
      title: 'Tệp',
      key: 'file',
      width: 90,
      render: (_, r) => (
        <Button
          type="link"
          icon={<DownloadOutlined />}
          loading={downloadingId === r.id}
          disabled={!r.fileSize}
          onClick={() => downloadFile(r)}
        />
      ),
    },
  ];

  if (loading) {
    return (
      <div style={{ display: 'flex', justifyContent: 'center', padding: 40 }}>
        <Spin size="large" />
      </div>
    );
  }

  return (
    <div style={{ padding: 24 }}>
      <Card>
        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
          <div>
            <h2 style={{ margin: 0 }}>
              <FileTextOutlined /> Báo cáo mentor
            </h2>
            <div style={{ color: '#666' }}>Danh sách báo cáo đã/đang nộp</div>
          </div>
          <div style={{ display: 'flex', gap: 12 }}>
            <Button icon={<ReloadOutlined />} onClick={load}>
              Làm mới
            </Button>
            <Button
              type="primary"
              icon={<PlusOutlined />}
              onClick={() => navigate('/mentor/reports/new')}
            >
              Nộp báo cáo
            </Button>
          </div>
        </div>

        <Divider />

        {error && <Alert type="error" showIcon message={error} style={{ marginBottom: 16 }} />}

        <Table
          rowKey={(r) => r.id}
          columns={columns}
          dataSource={items}
          pagination={{ pageSize: 10 }}
        />
      </Card>
    </div>
  );
};

export default MentorReports;
