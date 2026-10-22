// Custom Auth Hook
import { useAppSelector, useAppDispatch } from '@/store/hooks';
import { logout } from '@/store/slices/authSlice';
import { useNavigate } from 'react-router-dom';
import { App } from 'antd';
import { TUserRole } from '@/types/user.types';

export const useAuth = () => {
  const dispatch = useAppDispatch();
  const navigate = useNavigate();
  const { message } = App.useApp();
  
  const { user, isAuthenticated, loading, error } = useAppSelector((state) => state.auth);

  const handleLogout = async () => {
    try {
      await dispatch(logout()).unwrap();
      message.success('Đăng xuất thành công!');
      navigate('/login');
    } catch (error) {
      // Even if error, still navigate to login since local state is cleared
      message.info('Đã đăng xuất');
      navigate('/login');
    }
  };

  const hasRole = (role: TUserRole): boolean => {
    return user?.role === role;
  };

  const hasAnyRole = (roles: TUserRole[]): boolean => {
    return user ? roles.includes(user.role as TUserRole) : false;
  };

  return {
    user,
    isAuthenticated,
    loading,
    error,
    logout: handleLogout,
    hasRole,
    hasAnyRole,
  };
};
