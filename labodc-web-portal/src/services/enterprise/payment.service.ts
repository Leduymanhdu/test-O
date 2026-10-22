// payment.service.ts
import axios from '@/services/api/axios.config';

export interface PaymentItem {
  key: string;
  code: string;
  project: string;
  amount: number;
  dueDate: string;
  status: 'PAID' | 'PENDING' | 'OVERDUE';
}

export interface CreatePaymentRequest {
  projectId: number;
  amount: number;
  dueDate?: string; // YYYY-MM-DD
  description?: string;
  paymentMethod?: string;
}

export const getPaymentSummary = async () => {
  const res = await axios.get('/enterprise/payments/summary');
  return res.data?.data ?? res.data ?? null;
};

export const getPayments = async () => {
  const res = await axios.get('/enterprise/payments');
  return res.data?.data ?? res.data ?? [];
};

export const createPayment = async (payload: CreatePaymentRequest) => {
  const res = await axios.post('/enterprise/payments', payload);
  return res.data?.data ?? res.data ?? null;
};
