// Main Layout Component
import React, { useState, useEffect } from 'react';
import { Layout } from 'antd';
import { Outlet } from 'react-router-dom';
import Header from '../Header';
import Sidebar from '../Sidebar';
import Footer from '../Footer';
import { useAppSelector, useAppDispatch } from '@/store/hooks';
import { setSidebarCollapsed } from '@/store/slices/uiSlice';
import styles from './MainLayout.module.css';

const { Content } = Layout;

const MOBILE_BREAKPOINT = 768;

const MainLayout: React.FC = () => {
  const dispatch = useAppDispatch();
  const sidebarCollapsed = useAppSelector((state) => state.ui.sidebarCollapsed);
  const [isMobile, setIsMobile] = useState(window.innerWidth < MOBILE_BREAKPOINT);

  useEffect(() => {
    const handleResize = () => {
      const mobile = window.innerWidth < MOBILE_BREAKPOINT;
      setIsMobile(mobile);
      if (mobile) {
        dispatch(setSidebarCollapsed(true));
      }
    };

    if (window.innerWidth < MOBILE_BREAKPOINT) {
      dispatch(setSidebarCollapsed(true));
    }

    window.addEventListener('resize', handleResize);
    return () => window.removeEventListener('resize', handleResize);
  }, [dispatch]);

  return (
    <Layout className={styles.layout}>
      <Header />
      <Layout className={styles.body}>
        {/* Backdrop — mobile only, closes sidebar on tap */}
        {isMobile && !sidebarCollapsed && (
          <div
            className={styles.overlay}
            onClick={() => dispatch(setSidebarCollapsed(true))}
          />
        )}

        {/* Sidebar: inline on desktop, fixed overlay on mobile */}
        <Sidebar collapsed={sidebarCollapsed} isMobile={isMobile} />

        {/*
          Desktop: Ant Design Layout is a flex row.
          Sider takes its own width (250px / 80px) and animates via CSS.
          This flex child fills the rest — no marginLeft needed.

          Mobile: Sider is position:fixed (out of flow), so this fills 100%.
        */}
        <Layout className={styles.contentLayout}>
          <Content className={styles.content}>
            <Outlet />
          </Content>
          <Footer />
        </Layout>
      </Layout>
    </Layout>
  );
};

export default MainLayout;
