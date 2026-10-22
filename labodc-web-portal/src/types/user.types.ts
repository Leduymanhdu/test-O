// User Types
export type TUserRole =
  | 'LAB_ADMIN'
  | 'ENTERPRISE'
  | 'MENTOR'
  | 'TALENT'
  | 'TALENT_LEADER';

export type TUserStatus = 'ACTIVE' | 'INACTIVE' | 'PENDING' | 'SUSPENDED';

export interface IUser {
  id: string;
  username: string;
  email: string;
  fullName: string;
  role: TUserRole;
  status: TUserStatus;
  avatar?: string;
  phone?: string;
  address?: string;
  createdAt: string;
  updatedAt: string;
}

export interface IUserProfile extends IUser {
  bio?: string;
  skills?: string[];
  experience?: string;
  education?: string;
  achievements?: string[];
}

export interface IUpdateProfileRequest {
  fullName?: string;
  phone?: string;
  address?: string;
  bio?: string;
  avatar?: string;
}
