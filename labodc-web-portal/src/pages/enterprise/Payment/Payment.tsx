import React, { useEffect, useState } from 'react';
import {
  Row,
  Col,
  Card,
  Statistic,
  Table,
  Tag,
  Button,
  Modal,
  Form,
  Input,
  DatePicker,
  InputNumber,
  Select,
  message,
} from 'antd';
import {
  DollarOutlined,
  WarningOutlined,
  CheckCircleOutlined,
  RiseOutlined,
} from '@ant-design/icons';
import {
  getPaymentSummary,
  getPayments,
  PaymentItem,
  createPayment,
} from '@/services/enterprise/payment.service';
import { getProjects } from '@/services/enterprise/project.service';
import { formatCurrencyVND } from '@/utils/formatters';
import '../enterprise-modern.css';
import dayjs from 'dayjs';

const Payment: React.FC = () => {
  const [loading, setLoading] = useState(false);
  const [createOpen, setCreateOpen] = useState(false);
  const [creating, setCreating] = useState(false);
  const [projects, setProjects] = useState<any[]>([]);
  const [form] = Form.useForm();

  const [summary, setSummary] = useState({
    paid: 0,
    pending: 0,
    overdue: 0,
    remaining: 0,
  });

  const [payments, setPayments] = useState<PaymentItem[]>([]);

  useEffect(() => {
    const fetchData = async () => {
      setLoading(true);
      try {
        const summaryRes = await getPaymentSummary();
        const paymentsRes = await getPayments();

        setSummary(summaryRes ?? {
          paid: 0,
          pending: 0,
          overdue: 0,
          remaining: 0,
        });
        setPayments(Array.isArray(paymentsRes) ? paymentsRes : []);
      } catch (err) {
        console.error('Load payment data failed:', err);
      } finally {
        setLoading(false);
      }
    };

    fetchData();
  }, []);

  const refresh = async () => {
    try {
      setLoading(true);
      const summaryRes = await getPaymentSummary();
      const paymentsRes = await getPayments();
      setSummary(summaryRes ?? {
        paid: 0,
        pending: 0,
        overdue: 0,
        remaining: 0,
      });
      setPayments(Array.isArray(paymentsRes) ? paymentsRes : []);
    } finally {
      setLoading(false);
    }
  };

  const openCreate = async () => {
    setCreateOpen(true);
    try {
      const list = await getProjects('ALL');
      setProjects(Array.isArray(list) ? list : []);
    } catch {
      setProjects([]);
    }
  };

  const columns = [
    {
      title: 'Mã thanh toán',
      dataIndex: 'code',
    },
    {
      title: 'Dự án',
      dataIndex: 'project',
    },
    {
      title: 'Số tiền',
      dataIndex: 'amount',
      render: (v: number) => formatCurrencyVND(v),
    },
    {
      title: 'Hạn thanh toán',
      dataIndex: 'dueDate',
    },
    {
      title: 'Trạng thái',
      dataIndex: 'status',
      render: (s: string) => {
        const color =
          s === 'PAID'
            ? 'green'
            : s === 'OVERDUE'
            ? 'red'
            : 'orange';
        const label =
          s === 'PAID'
            ? 'Đã thanh toán'
            : s === 'OVERDUE'
            ? 'Quá hạn'
            : s === 'PENDING'
            ? 'Chờ thanh toán'
            : s;
        return <Tag color={color}>{label}</Tag>;
      },
    },
    {
      title: 'Hành động',
      render: (_: any, record: PaymentItem) => (
        <Button type="link">
          Chi tiết
        </Button>
      ),
    },
  ];

  return (
    <div className="page-wrapper">
      {/* HEADER */}
      <div className="page-header">
        <h1>Thanh toán</h1>
        <Button type="primary" onClick={openCreate}>
          Tạo yêu cầu
        </Button>
      </div>

      {/* SUMMARY */}
      <Row gutter={[16, 16]} className="stat-row">
        <Col xs={24} sm={12} lg={6}>
          <Card className="modern-card stat-card">
            <Statistic
              title="Đã thanh toán"
              value={summary.paid}
              prefix={<CheckCircleOutlined />}
              valueStyle={{ color: '#52c41a' }}
            />
          </Card>
        </Col>
        <Col xs={24} sm={12} lg={6}>
          <Card className="modern-card stat-card">
            <Statistic
              title="Chờ thanh toán"
              value={summary.pending}
              prefix={<DollarOutlined />}
              valueStyle={{ color: '#faad14' }}
            />
          </Card>
        </Col>
        <Col xs={24} sm={12} lg={6}>
          <Card className="modern-card stat-card">
            <Statistic
              title="Quá hạn"
              value={summary.overdue}
              prefix={<WarningOutlined />}
              valueStyle={{ color: '#ff4d4f' }}
            />
          </Card>
        </Col>
        <Col xs={24} sm={12} lg={6}>
          <Card className="modern-card stat-card">
            <Statistic
              title="Ngân sách còn lại"
              value={summary.remaining}
              prefix={<RiseOutlined />}
              formatter={(v) => formatCurrencyVND(Number(v))}
              valueStyle={{ color: '#17a2b8' }}
            />
          </Card>
        </Col>
      </Row>

      {/* TABLE */}
      <Card className="table-card">
        <Table
          columns={columns}
          dataSource={payments}
          loading={loading}
          rowKey="key"
        />
      </Card>

      <Modal
        title="Tạo yêu cầu thanh toán"
        open={createOpen}
        onCancel={() => {
          setCreateOpen(false);
          form.resetFields();
        }}
        onOk={async () => {
          try {
            const values = await form.validateFields();
            setCreating(true);

            await createPayment({
              projectId: Number(values.projectId),
              amount: Number(values.amount),
              dueDate: values.dueDate ? dayjs(values.dueDate).format('YYYY-MM-DD') : undefined,
              description: values.description,
              paymentMethod: values.paymentMethod,
            });

            message.success('Tạo yêu cầu thanh toán thành công');
            setCreateOpen(false);
            form.resetFields();
            await refresh();
          } catch (err: any) {
            if (err?.errorFields) return;
            message.error(err?.message || 'Không thể tạo yêu cầu thanh toán');
          } finally {
            setCreating(false);
          }
        }}
        confirmLoading={creating}
        okText="Tạo"
        cancelText="Hủy"
      >
        <Form form={form} layout="vertical">
          <Form.Item
            label="Dự án"
            name="projectId"
            rules={[{ required: true, message: 'Chọn dự án' }]}
          >
            <Select
              placeholder="Chọn dự án"
              options={projects.map((p) => ({
                label: p.name,
                value: Number(p.key),
              }))}
            />
          </Form.Item>

          <Form.Item
            label="Số tiền (VND)"
            name="amount"
            rules={[{ required: true, message: 'Nhập số tiền' }]}
          >
            <InputNumber style={{ width: '100%' }} min={0} />
          </Form.Item>

          <Form.Item label="Hạn thanh toán" name="dueDate">
            <DatePicker style={{ width: '100%' }} />
          </Form.Item>

          <Form.Item label="Phương thức" name="paymentMethod">
            <Select
              placeholder="Chọn phương thức"
              options={[
                { label: 'Bank Transfer', value: 'BANK_TRANSFER' },
                { label: 'Momo', value: 'MOMO' },
                { label: 'Paypal', value: 'PAYPAL' },
                { label: 'Cash', value: 'CASH' },
              ]}
            />
          </Form.Item>

          <Form.Item label="Ghi chú" name="description">
            <Input.TextArea rows={3} placeholder="Nội dung yêu cầu thanh toán" />
          </Form.Item>
        </Form>
      </Modal>
    </div>
  );
};

export default Payment;
