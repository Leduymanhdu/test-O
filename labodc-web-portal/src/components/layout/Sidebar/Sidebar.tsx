// Sidebar Component
import React from 'react';
import { Layout, Menu, MenuProps } from 'antd';
import {
  DashboardOutlined,
  ProjectOutlined,
  FileTextOutlined,
  DollarOutlined,
  TeamOutlined,
  SettingOutlined,
  CheckSquareOutlined,
  FundOutlined,
  MessageOutlined,
} from '@ant-design/icons';
import { useNavigate, useLocation } from 'react-router-dom';
import { useAuth } from '@/hooks/useAuth';
import styles from './Sidebar.module.css';

const { Sider } = Layout;

interface SidebarProps {
  collapsed: boolean;
  isMobile?: boolean;
}

const Sidebar: React.FC<SidebarProps> = ({ collapsed, isMobile = false }) => {
  const navigate = useNavigate();
  const location = useLocation();
  const { user } = useAuth();

  // Menu items based on user role
  const getMenuItems = (): MenuProps['items'] => {
    if (!user) return [];

    // Dashboard item with correct routing based on role
    const getDashboardRoute = () => {
      switch (user.role) {
        case 'LAB_ADMIN':
          return '/admin/dashboard';
        case 'ENTERPRISE':
          return '/enterprise/dashboard';
        case 'TALENT':
        case 'TALENT_LEADER':
          return '/talent/dashboard';
        case 'MENTOR':
          return '/mentor/dashboard';
        default:
          return '/';
      }
    };

    const baseItems: MenuProps['items'] = [
      {
        key: 'dashboard',
        icon: <DashboardOutlined />,
        label: 'Dashboard',
        onClick: () => navigate(getDashboardRoute()),
      },
    ];

    // Enterprise menu
    if (user.role === 'ENTERPRISE') {
      return [
        ...baseItems,
        {
          key: 'projects-list',
          icon: <ProjectOutlined />,
          label: 'Quản lý dự án',
          onClick: () => navigate('/enterprise/projects'),
        },
        {
          key: 'payment',
          icon: <DollarOutlined />,
          label: 'Thanh toán',
          onClick: () => navigate('/enterprise/payment'),
        },
        {
          key: 'feedback',
          icon: <MessageOutlined />,
          label: 'Đánh giá dự án',
          onClick: () => navigate('/enterprise/feedback'),
        },
        {
          key: 'reports',
          icon: <FileTextOutlined />,
          label: 'Báo cáo',
          onClick: () => navigate('/enterprise/reports'),
        },
      ];
    }

    // Talent menu
    if (user.role === 'TALENT' || user.role === 'TALENT_LEADER') {
      return [
        ...baseItems,
        {
          key: 'browse-projects',
          icon: <ProjectOutlined />,
          label: 'Duyệt dự án',
          onClick: () => navigate('/talent/projects/browse'),
        },
        {
          key: 'my-projects',
          icon: <TeamOutlined />,
          label: 'Dự án của tôi',
          onClick: () => navigate('/talent/my-projects'),
        },
        {
          key: 'tasks',
          icon: <CheckSquareOutlined />,
          label: 'Nhiệm vụ',
          onClick: () => navigate('/talent/tasks'),
        },
      ];
    }

    // Mentor menu
    if (user.role === 'MENTOR') {
      return [
        ...baseItems,
        {
          key: 'invitations',
          icon: <ProjectOutlined />,
          label: 'Lời mời dự án',
          onClick: () => navigate('/mentor/invitations'),
        },
        {
          key: 'applications',
          icon: <TeamOutlined />,
          label: 'Duyệt đơn',
          onClick: () => navigate('/mentor/applications'),
        },
        {
          key: 'mentor-tasks',
          icon: <CheckSquareOutlined />,
          label: 'Công việc',
          onClick: () => navigate('/mentor/tasks'),
        },
        {
          key: 'mentor-evaluation',
          icon: <TeamOutlined />,
          label: 'Đánh giá',
          onClick: () => navigate('/mentor/evaluation'),
        },
        {
          key: 'reports',
          icon: <FileTextOutlined />,
          label: 'Báo cáo',
          onClick: () => navigate('/mentor/reports/new'),
        },
      ];
    }

    // Lab Admin menu
    if (user.role === 'LAB_ADMIN') {
      return [
        ...baseItems,
        {
          key: 'management',
          icon: <TeamOutlined />,
          label: 'Quản lý',
          children: [
            {
              key: 'enterprises-crud',
              label: 'Doanh nghiệp',
              onClick: () => navigate('/admin/enterprises-crud'),
            },
            {
              key: 'talents',
              label: 'Sinh viên',
              onClick: () => navigate('/admin/talents'),
            },
            {
              key: 'mentors',
              label: 'Mentor',
              onClick: () => navigate('/admin/mentors'),
            },
            {
              key: 'projects',
              label: 'Dự án',
              onClick: () => navigate('/admin/projects'),
            },
          ],
        },
        {
          key: 'enterprises',
          icon: <CheckSquareOutlined />,
          label: 'Duyệt DN',
          onClick: () => navigate('/admin/enterprises'),
        },
        {
          key: 'projects-validate',
          icon: <ProjectOutlined />,
          label: 'Xác thực dự án',
          onClick: () => navigate('/admin/projects/validate'),
        },
        {
          key: 'funds',
          icon: <FundOutlined />,
          label: 'Phân bổ quỹ',
          onClick: () => navigate('/admin/funds'),
        },
        {
          key: 'reports',
          icon: <FileTextOutlined />,
          label: 'Báo cáo minh bạch',
          onClick: () => navigate('/admin/reports'),
        },
      ];
    }

    return baseItems;
  };

  // Get selected key from current location
  const getSelectedKey = (): string => {
    const path = location.pathname;
    
    // Dashboard
    if (path.includes('/dashboard')) return 'dashboard';
    
    // Lab Admin routes (check these BEFORE enterprise routes to avoid conflicts)
    if (path.includes('/enterprises-crud')) return 'enterprises-crud';
    if (path.includes('/talents')) return 'talents';
    if (path.includes('/mentors')) return 'mentors';
    if (path.includes('/projects/validate')) return 'projects-validate';
    if (path.includes('/admin/projects')) return 'projects';
    if (path.includes('/enterprises')) return 'enterprises';
    if (path.includes('/funds')) return 'funds';
    
    // Enterprise routes
    if (path.includes('/projects/new')) return 'projects-new';
    if (path.includes('/projects') && !path.includes('/validate')) return 'projects-list';
    if (path.includes('/payment')) return 'payment';
    if (path.includes('/feedback')) return 'feedback';
    
    // Talent routes
    if (path.includes('/projects/browse')) return 'browse-projects';
    if (path.includes('/my-projects')) return 'my-projects';
    if (path.includes('/tasks')) return 'tasks';
    
    // Mentor routes
    if (path.includes('/invitations')) return 'invitations';
    if (path.includes('/mentor/applications')) return 'applications';
    if (path.includes('/mentor/tasks')) return 'mentor-tasks';
    if (path.includes('/mentor/evaluation')) return 'mentor-evaluation';

    // Reports (multiple roles use this)
    if (path.includes('/reports')) return 'reports';
    
    return 'dashboard';
  };

  return (
    <Sider
      trigger={null}
      collapsible
      collapsed={collapsed}
      collapsedWidth={isMobile ? 0 : 80}
      className={`${styles.sider} ${isMobile ? styles.mobile : ''}`}
      width={250}
    >
      <Menu
        mode="inline"
        selectedKeys={[getSelectedKey()]}
        defaultOpenKeys={['management']}
        items={getMenuItems()}
        className={styles.menu}
      />
    </Sider>
  );
};

export default Sidebar;


