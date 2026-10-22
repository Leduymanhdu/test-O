// Permissions Hook
import { useAuth } from './useAuth';
import { hasPermission, canAccessRoute, PERMISSIONS } from '@/utils/permissions';
import { TUserRole } from '@/types/user.types';

export const usePermissions = () => {
  const { user } = useAuth();

  const checkPermission = (permission: keyof typeof PERMISSIONS): boolean => {
    if (!user) return false;
    return hasPermission(user.role as TUserRole, permission);
  };

  const checkRouteAccess = (routePath: string): boolean => {
    if (!user) return false;
    return canAccessRoute(user.role as TUserRole, routePath);
  };

  return {
    checkPermission,
    checkRouteAccess,
  };
};
