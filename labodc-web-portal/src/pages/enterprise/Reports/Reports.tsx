import React, { useEffect, useState } from 'react';
import {
  Row,
  Col,
  Card,
  Statistic,
  Table,
  Progress,
  Button,
  message,
  Select,
  Space,
} from 'antd';
import { DollarOutlined, DownloadOutlined } from '@ant-design/icons';
import {
  getReportSummary,
  getProjectReports,
  ProjectReport,
} from '@/services/enterprise/report.service';
import { getPayments, PaymentItem } from '@/services/enterprise/payment.service';
import { getProjectById } from '@/services/enterprise/project.service';
import { formatCurrencyVND } from '@/utils/formatters';
import {
  ResponsiveContainer,
  BarChart,
  Bar,
  LineChart,
  Line,
  XAxis,
  YAxis,
  Tooltip,
  CartesianGrid,
} from 'recharts';
import '../enterprise-modern.css';

const escapeCsv = (value: string | number) => {
  const raw = String(value ?? '');
  if (raw.includes('"') || raw.includes(',') || raw.includes('\n')) {
    return `"${raw.replace(/"/g, '""')}"`;
  }
  return raw;
};

const Reports: React.FC = () => {
  const [loading, setLoading] = useState(false);
  const [selectedProjectKeys, setSelectedProjectKeys] = useState<string[]>([]);

  const [summary, setSummary] = useState({
    projects: 0,
    totalCost: 0,
    performance: 0,
    completedRate: 0,
  });

  const [data, setData] = useState<ProjectReport[]>([]);

  useEffect(() => {
    const fetchData = async () => {
      setLoading(true);
      try {
        const summaryRes = await getReportSummary();
        const reportRes = await getProjectReports();

        setSummary(summaryRes ?? {
          projects: 0,
          totalCost: 0,
          performance: 0,
          completedRate: 0,
        });
        setData(Array.isArray(reportRes) ? reportRes : []);
      } catch (err) {
        console.error('Load report data failed:', err);
      } finally {
        setLoading(false);
      }
    };

    fetchData();
  }, []);

  const handleExport = async () => {
    if (!data.length) {
      message.info('Không có dữ liệu để xuất');
      return;
    }

    const selectedForExport = selectedProjectKeys.length
      ? data.filter((item) => selectedProjectKeys.includes(String(item.key)))
      : data;

    const [payments, details] = await Promise.all([
      getPayments()
        .then((rows) => (Array.isArray(rows) ? rows : []) as PaymentItem[])
        .catch(() => []),
      Promise.all(
        selectedForExport.map(async (project) => {
          try {
            const detail = await getProjectById(project.key);
            return { project, detail };
          } catch {
            return { project, detail: null };
          }
        }),
      ),
    ]);

    const header = [
      'Tên dự án',
      'Trạng thái',
      'Chi phí',
      'Ngân sách',
      'Đã thanh toán',
      'Chưa thanh toán',
      'Tiến độ',
      'Bắt đầu',
      'Kết thúc',
      'Mô tả',
      'Yêu cầu',
      'Mục tiêu',
      'Công nghệ',
      'Kỹ năng',
    ];
    const rows = details.map(({ project, detail }) => {
      const paidTotal = payments
        .filter(
          (p) =>
            p.status === 'PAID' &&
            (p.project?.trim?.() ?? p.project) === (project.name ?? ''),
        )
        .reduce((sum, p) => sum + (Number(p.amount) || 0), 0);
      const budgetValue =
        typeof detail?.budget === 'number'
          ? detail.budget
          : typeof project.cost === 'number'
            ? project.cost
            : 0;
      const unpaidValue =
        typeof budgetValue === 'number' ? Math.max(0, budgetValue - paidTotal) : 0;
      const objectives = Array.isArray(detail?.objectives)
        ? detail.objectives.join(', ')
        : detail?.objective ?? '-';
      const technologies = Array.isArray(detail?.technologies)
        ? detail.technologies.join(', ')
        : '-';
      const skills = Array.isArray(detail?.requiredSkills)
        ? detail.requiredSkills.join(', ')
        : '-';

      return [
        project.name ?? '-',
        project.status ?? '-',
        typeof project.cost === 'number' ? formatCurrencyVND(project.cost) : '-',
        typeof budgetValue === 'number' ? formatCurrencyVND(budgetValue) : '-',
        formatCurrencyVND(paidTotal),
        typeof budgetValue === 'number' ? formatCurrencyVND(unpaidValue) : '-',
        typeof project.progress === 'number' ? `${project.progress}%` : '-',
        detail?.startDate ?? '-',
        detail?.endDate ?? '-',
        detail?.description ?? '-',
        detail?.requirements ?? '-',
        objectives,
        technologies,
        skills,
      ];
    });
    const csv = [header, ...rows]
      .map((row) => row.map(escapeCsv).join(','))
      .join('\n');

    const blob = new Blob([`\ufeff${csv}`], { type: 'text/csv;charset=utf-8;' });
    const url = URL.createObjectURL(blob);
    const link = document.createElement('a');
    const date = new Date();
    const fileName = `enterprise-report-${date.getFullYear()}-${String(
      date.getMonth() + 1,
    ).padStart(2, '0')}-${String(date.getDate()).padStart(2, '0')}.csv`;
    link.href = url;
    link.setAttribute('download', fileName);
    document.body.appendChild(link);
    link.click();
    document.body.removeChild(link);
    URL.revokeObjectURL(url);
  };

  const handleExportPdf = async () => {
    if (!data.length) {
      message.info('Không có dữ liệu để xuất');
      return;
    }
    if (!selectedProjectKeys.length) {
      message.info('Vui lòng chọn dự án');
      return;
    }
    const selected = data.filter((item) =>
      selectedProjectKeys.includes(String(item.key)),
    );
    if (!selected.length) {
      message.info('Không tìm thấy dự án');
      return;
    }

    const now = new Date();
    const dateLabel = `${now.getFullYear()}-${String(now.getMonth() + 1).padStart(2, '0')}-${String(
      now.getDate(),
    ).padStart(2, '0')}`;
    const [payments, details] = await Promise.all([
      getPayments()
        .then((rows) => (Array.isArray(rows) ? rows : []) as PaymentItem[])
        .catch(() => []),
      Promise.all(
        selected.map(async (project) => {
          try {
            const detail = await getProjectById(project.key);
            return { project, detail };
          } catch {
            return { project, detail: null };
          }
        }),
      ),
    ]);

    const rowsHtml = details
      .map(({ project, detail }) => {
        const paidTotal = payments
          .filter(
            (p) =>
              p.status === 'PAID' &&
              (p.project?.trim?.() ?? p.project) === (project.name ?? ''),
          )
          .reduce((sum, p) => sum + (Number(p.amount) || 0), 0);
        const statusLabel = project.status ?? '-';
        const progressValue =
          typeof project.progress === 'number' ? Number(project.progress) : 0;
        const progressLabel =
          typeof project.progress === 'number' ? `${project.progress}%` : '-';
        const budgetValue =
          typeof detail?.budget === 'number'
            ? detail.budget
            : typeof project.cost === 'number'
              ? project.cost
              : 0;
        const costLabel =
          typeof project.cost === 'number' ? formatCurrencyVND(project.cost) : '-';
        const budgetLabel =
          typeof budgetValue === 'number' ? formatCurrencyVND(budgetValue) : '-';
        const paidLabel = formatCurrencyVND(paidTotal);
        const unpaidValue =
          typeof budgetValue === 'number' ? Math.max(0, budgetValue - paidTotal) : 0;
        const unpaidLabel =
          typeof budgetValue === 'number' ? formatCurrencyVND(unpaidValue) : '-';
        const startDate = detail?.startDate ?? '-';
        const endDate = detail?.endDate ?? '-';
        const objectives = Array.isArray(detail?.objectives)
          ? detail.objectives.join(', ')
          : detail?.objective ?? '-';
        const technologies = Array.isArray(detail?.technologies)
          ? detail.technologies.join(', ')
          : '-';
        const skills = Array.isArray(detail?.requiredSkills)
          ? detail.requiredSkills.join(', ')
          : '-';
        const description = detail?.description ?? '-';
        const requirements = detail?.requirements ?? '-';

        return `
          <div class="section">
            <h2>${project.name ?? '-'}</h2>
            <table>
              <tr><th>Trạng thái</th><td>${statusLabel}</td></tr>
              <tr><th>Chi phí</th><td>${costLabel}</td></tr>
              <tr><th>Ngân sách</th><td>${budgetLabel}</td></tr>
              <tr><th>Đã thanh toán</th><td>${paidLabel}</td></tr>
              <tr><th>Chưa thanh toán</th><td>${unpaidLabel}</td></tr>
              <tr><th>Tiến độ</th><td>${progressLabel}</td></tr>
              <tr><th>Bắt đầu</th><td>${startDate}</td></tr>
              <tr><th>Kết thúc</th><td>${endDate}</td></tr>
              <tr><th>Mô tả</th><td>${description}</td></tr>
              <tr><th>Yêu cầu</th><td>${requirements}</td></tr>
              <tr><th>Mục tiêu</th><td>${objectives}</td></tr>
              <tr><th>Công nghệ</th><td>${technologies}</td></tr>
              <tr><th>Kỹ năng</th><td>${skills}</td></tr>
            </table>
            <div class="process">
              <div class="label">Quá trình</div>
              <div class="bar">
                <div class="bar-fill" style="width: ${progressValue}%;"></div>
              </div>
              <div class="bar-text">${progressLabel}</div>
            </div>
            <div class="chart">
              <div class="chart-title">Biểu đồ (Chi phí)</div>
              <div class="chart-bar">
                <div class="chart-bar-fill" style="width: ${Math.min(
                  100,
                  Math.max(5, Math.round((project.cost || 0) / 1000000)),
                )}%;"></div>
              </div>
              <div class="chart-note">${costLabel}</div>
            </div>
          </div>
        `;
      })
      .join('');

    const html = `
      <html>
        <head>
          <title>Báo cáo dự án</title>
          <style>
            body { font-family: Arial, sans-serif; padding: 24px; }
            h1 { font-size: 20px; margin: 0 0 8px; }
            h2 { font-size: 16px; margin: 12px 0 8px; }
            .meta { color: #666; margin-bottom: 16px; }
            table { width: 100%; border-collapse: collapse; margin-bottom: 12px; }
            th, td { border: 1px solid #ddd; padding: 8px; text-align: left; font-size: 12px; }
            th { background: #f5f5f5; width: 160px; }
            .section { margin-bottom: 24px; page-break-inside: avoid; }
            .process { margin: 8px 0 12px; }
            .label { font-size: 12px; font-weight: 600; margin-bottom: 6px; }
            .bar { width: 100%; height: 10px; background: #e5e7eb; border-radius: 6px; overflow: hidden; }
            .bar-fill { height: 10px; background: #2f80ed; }
            .bar-text { font-size: 12px; color: #555; margin-top: 4px; }
            .chart { margin-top: 8px; }
            .chart-title { font-size: 12px; font-weight: 600; margin-bottom: 6px; }
            .chart-bar { width: 100%; height: 10px; background: #f1f5f9; border-radius: 6px; overflow: hidden; }
            .chart-bar-fill { height: 10px; background: #f59e0b; }
            .chart-note { font-size: 12px; color: #555; margin-top: 4px; }
          </style>
        </head>
        <body>
          <h1>Báo cáo dự án</h1>
          <div class="meta">Ngày: ${dateLabel}</div>
          ${rowsHtml}
        </body>
      </html>
    `;

    const win = window.open('', '_blank');
    if (!win) {
      message.error('Không thể mở cửa sổ in PDF');
      return;
    }
    win.document.open();
    win.document.write(html);
    win.document.close();
    win.focus();
    win.print();
  };

  const columns = [
    {
      title: 'Dự án',
      dataIndex: 'name',
    },
    {
      title: 'Chi phí',
      dataIndex: 'cost',
      render: (v: number) => formatCurrencyVND(v),
    },
    {
      title: 'Tiến độ',
      dataIndex: 'progress',
      render: (v: number) => <Progress percent={v} />,
    },
    {
      title: 'Trạng thái',
      dataIndex: 'status',
      render: (s: string) => {
        switch (s) {
          case 'PENDING_VALIDATION':
            return 'Chờ duyệt';
          case 'VALIDATED':
            return 'Đã duyệt';
          case 'RECRUITING':
            return 'Đang tuyển';
          case 'IN_PROGRESS':
            return 'Đang thực hiện';
          case 'COMPLETED':
            return 'Hoàn thành';
          case 'ON_HOLD':
            return 'Tạm dừng';
          case 'REJECTED':
            return 'Từ chối';
          default:
            return s || '-';
        }
      },
    },
  ];

  const projectLegend = data.map((item, index) => ({
    key: index + 1,
    name: item.name ?? '-',
  }));

  return (
    <div className="page-wrapper">
      {/* HEADER */}
      <div className="page-header">
        <h1>Báo cáo & Thống kê</h1>
        <Space>
          <Select
            allowClear
            mode="multiple"
            placeholder="Chọn dự án"
            style={{ minWidth: 220 }}
            value={selectedProjectKeys}
            onChange={(value) => setSelectedProjectKeys(value)}
            options={data.map((item) => ({
              label: item.name,
              value: String(item.key),
            }))}
          />
          <Button icon={<DownloadOutlined />} onClick={handleExport}>
            Xuất báo cáo
          </Button>
          <Button icon={<DownloadOutlined />} onClick={handleExportPdf}>
            Xuất PDF
          </Button>
        </Space>
      </div>

      {/* SUMMARY */}
      <Row gutter={[16, 16]} className="stat-row">
        <Col xs={24} sm={12} lg={6}>
          <Card className="modern-card stat-card">
            <Statistic
              title="Tổng dự án"
              value={summary.projects}
              valueStyle={{ color: '#17a2b8' }}
            />
          </Card>
        </Col>
        <Col xs={24} sm={12} lg={6}>
          <Card className="modern-card stat-card">
            <Statistic
              title="Tổng chi phí"
              value={summary.totalCost}
              prefix={<DollarOutlined />}
              formatter={(v) => formatCurrencyVND(Number(v))}
            />
          </Card>
        </Col>
        <Col xs={24} sm={12} lg={6}>
          <Card className="modern-card stat-card">
            <Statistic
              title="Hiệu suất"
              value={summary.performance}
              suffix="%"
              valueStyle={{ color: '#faad14' }}
            />
          </Card>
        </Col>
        <Col xs={24} sm={12} lg={6}>
          <Card className="modern-card stat-card">
            <Statistic
              title="Hoàn thành"
              value={summary.completedRate}
              suffix="%"
              valueStyle={{ color: '#52c41a' }}
            />
          </Card>
        </Col>
      </Row>

      <Row gutter={16} style={{ marginBottom: 16 }}>
        <Col span={12}>
          <Card className="modern-card">
            <div style={{ fontWeight: 600, marginBottom: 12 }}>Chi phí theo dự án</div>
            <div style={{ width: '100%', height: 320 }}>
              <ResponsiveContainer width="100%" height="100%">
                <BarChart data={data}>
                  <CartesianGrid strokeDasharray="3 3" />
                  <XAxis
                    dataKey="name"
                    tick={{ fontSize: 12 }}
                    interval={0}
                    tickFormatter={(_, index) => `${index + 1}`}
                  />
                  <YAxis
                    tickFormatter={(value) => `${Number(value) / 1000000}`}
                    label={{
                      value: 'Triệu đồng',
                      angle: -90,
                      position: 'insideLeft',
                    }}
                  />
                  <Tooltip
                    formatter={(value) => `${(Number(value) / 1000000).toFixed(1)} triệu`}
                  />
                  <Bar dataKey="cost" fill="#2f80ed" radius={[6, 6, 0, 0]} />
                </BarChart>
              </ResponsiveContainer>
            </div>
            {projectLegend.length ? (
              <div style={{ marginTop: 12, fontSize: 12, color: '#475569' }}>
                {projectLegend.map((item) => `${item.key}: ${item.name}`).join(' | ')}
              </div>
            ) : null}
          </Card>
        </Col>
        <Col span={12}>
          <Card className="modern-card">
            <div style={{ fontWeight: 600, marginBottom: 12 }}>Tiến độ theo dự án</div>
            <div style={{ width: '100%', height: 320 }}>
              <ResponsiveContainer width="100%" height="100%">
                <LineChart data={data}>
                  <CartesianGrid strokeDasharray="3 3" />
                  <XAxis
                    dataKey="name"
                    tick={{ fontSize: 12 }}
                    interval={0}
                    tickFormatter={(_, index) => `${index + 1}`}
                  />
                  <YAxis domain={[0, 100]} />
                  <Tooltip formatter={(value) => `${Number(value)}%`} />
                  <Line type="monotone" dataKey="progress" stroke="#f59e0b" strokeWidth={2} />
                </LineChart>
              </ResponsiveContainer>
            </div>
            {projectLegend.length ? (
              <div style={{ marginTop: 12, fontSize: 12, color: '#475569' }}>
                {projectLegend.map((item) => `${item.key}: ${item.name}`).join(' | ')}
              </div>
            ) : null}
          </Card>
        </Col>
      </Row>

      {/* TABLE */}
      <Card className="table-card">
        <Table
          columns={columns}
          dataSource={data}
          loading={loading}
          rowKey="key"
        />
      </Card>
    </div>
  );
};

export default Reports;
