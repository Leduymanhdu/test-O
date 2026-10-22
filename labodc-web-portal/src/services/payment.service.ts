// Payment Service
import axiosInstance from './api/axios.config';
import {
  IPayment,
  ICreatePaymentRequest,
  IPaymentResponse,
  IPaymentHistory,
  IInvoice,
} from '@/types/payment.types';
import { IApiResponse } from '@/types/api.types';

const PAYMENT_ENDPOINTS = {
  BASE: '/payments',
  HISTORY: '/payments/history',
  INVOICE: '/payments/invoice',
  VERIFY: '/payments/verify',
};

export const paymentService = {
  /**
   * Create payment
   */
  createPayment: async (data: ICreatePaymentRequest): Promise<IPaymentResponse> => {
    const response = await axiosInstance.post<IApiResponse<IPaymentResponse>>(
      PAYMENT_ENDPOINTS.BASE,
      data
    );
    return response.data.data;
  },

  /**
   * Get payment by ID
   */
  getPaymentById: async (id: string): Promise<IPayment> => {
    const response = await axiosInstance.get<IApiResponse<IPayment>>(
      `${PAYMENT_ENDPOINTS.BASE}/${id}`
    );
    return response.data.data;
  },

  /**
   * Get payment history
   */
  getPaymentHistory: async (projectId?: string): Promise<IPaymentHistory> => {
    const response = await axiosInstance.get<IApiResponse<IPaymentHistory>>(
      PAYMENT_ENDPOINTS.HISTORY,
      { params: { projectId } }
    );
    return response.data.data;
  },

  /**
   * Get invoice
   */
  getInvoice: async (invoiceId: string): Promise<IInvoice> => {
    const response = await axiosInstance.get<IApiResponse<IInvoice>>(
      `${PAYMENT_ENDPOINTS.INVOICE}/${invoiceId}`
    );
    return response.data.data;
  },

  /**
   * Verify payment (PayOS callback)
   */
  verifyPayment: async (transactionId: string): Promise<IPayment> => {
    const response = await axiosInstance.post<IApiResponse<IPayment>>(
      `${PAYMENT_ENDPOINTS.VERIFY}/${transactionId}`
    );
    return response.data.data;
  },

  /**
   * Download invoice PDF
   */
  downloadInvoice: async (invoiceId: string): Promise<Blob> => {
    const response = await axiosInstance.get(
      `${PAYMENT_ENDPOINTS.INVOICE}/${invoiceId}/download`,
      {
        responseType: 'blob',
      }
    );
    return response.data;
  },
};
