// Authentication Types
export interface ILoginRequest {
  email: string; // Backend expects email, not username
  password: string;
}

export interface IRegisterRequest {
  email: string;
  password: string;
  confirmPassword: string;
  role: string;
}

// Backend response structure from Spring Boot
export interface IAuthResponse {
  token: string; // Backend returns 'token'
  refreshToken?: string;
  tokenType: string; // "Bearer"
  userId?: number;
  email: string;
  role: string;
  status?: string;
  emailVerified?: boolean;
}

export interface IForgotPasswordRequest {
  email: string;
}

export interface IResetPasswordRequest {
  token: string;
  newPassword: string;
  confirmPassword: string;
}
