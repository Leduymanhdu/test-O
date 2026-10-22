// Footer Component
import React from 'react';
import { Layout } from 'antd';
import styles from './Footer.module.css';

const { Footer: AntFooter } = Layout;

const Footer: React.FC = () => {
  const currentYear = new Date().getFullYear();

  return (
    <AntFooter className={styles.footer}>
      <div className={styles.content}>
        <div className={styles.copyright}>
          © {currentYear} LabOdc - Đại học Giao thông Vận tải TP.HCM. All rights reserved.
        </div>
        <div className={styles.links}>
          <a href="/about">Giới thiệu</a>
          <span className={styles.divider}>|</span>
          <a href="/contact">Liên hệ</a>
          <span className={styles.divider}>|</span>
          <a href="/privacy">Chính sách bảo mật</a>
        </div>
      </div>
    </AntFooter>
  );
};

export default Footer;
