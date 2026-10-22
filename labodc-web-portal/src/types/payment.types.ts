// Payment Types
export type TPaymentStatus = 
  | 'PENDING'
  | 'PROCESSING'
  | 'COMPLETED'
  | 'FAILED'
  | 'REFUNDED';

export type TPaymentMethod = 'PAYOS' | 'BANK_TRANSFER' | 'CREDIT_CARD';

export interface IPayment {
  id: string;
  projectId: string;
  projectName: string;
  amount: number;
  status: TPaymentStatus;
  method: TPaymentMethod;
  transactionId?: string;
  paidBy: string;
  paidAt?: string;
  createdAt: string;
  updatedAt: string;
}

export interface ICreatePaymentRequest {
  projectId: string;
  amount: number;
  method: TPaymentMethod;
  returnUrl: string;
  cancelUrl: string;
}

export interface IPaymentResponse {
  paymentId: string;
  checkoutUrl: string;
  qrCode?: string;
  transactionId: string;
}

export interface IPaymentHistory {
  payments: IPayment[];
  totalAmount: number;
  totalPaid: number;
  totalPending: number;
}

export interface IInvoice {
  id: string;
  paymentId: string;
  invoiceNumber: string;
  projectName: string;
  amount: number;
  issuedDate: string;
  dueDate: string;
  paidDate?: string;
  status: TPaymentStatus;
  items: IInvoiceItem[];
}

export interface IInvoiceItem {
  description: string;
  quantity: number;
  unitPrice: number;
  amount: number;
}
