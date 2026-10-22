// Login Page
import React, { useEffect } from 'react';
import { Form, Input, Button, Card, message } from 'antd';
import { UserOutlined, LockOutlined, CalendarOutlined, ArrowRightOutlined } from '@ant-design/icons';
import { Link, useNavigate } from 'react-router-dom';
import { useAppDispatch, useAppSelector } from '@/store/hooks';
import { login } from '@/store/slices/authSlice';
import { ILoginRequest } from '@/types/auth.types';
import { TUserRole } from '@/types/user.types';
import { getDefaultRoute } from '@/utils/permissions';
import { getLatestNews, formatNewsDate } from '@/services/news.service';
import styles from './Login.module.css';

const Login: React.FC = () => {
  const [form] = Form.useForm();
  const dispatch = useAppDispatch();
  const navigate = useNavigate();
  const { loading, isAuthenticated, user } = useAppSelector((state) => state.auth);
  const latestNews = getLatestNews(5);

  useEffect(() => {
    if (isAuthenticated && user) {
      const defaultRoute = getDefaultRoute(user.role as TUserRole);
      navigate(defaultRoute);
    }
  }, [isAuthenticated, user, navigate]);

  const onFinish = async (values: any) => {
    try {
      // Transform username field to email for backend
      const loginData: ILoginRequest = {
        email: values.username,  // Form field is 'username' but backend expects 'email'
        password: values.password,
      };
      
      const result = await dispatch(login(loginData)).unwrap();
      console.log('🎯 Login result:', result);
      console.log('Result structure:', JSON.stringify(result, null, 2));
      console.log('👤 User object:', result.user);
      console.log('🎭 User role:', result.user?.role);
      
      message.success('Đăng nhập thành công!');
      // useEffect will handle navigation automatically
    } catch (error: any) {
      console.error('❌ Login error:', error);
      message.error(error || 'Đăng nhập thất bại!');
    }
  };

  return (
    <div className={styles.container}>
      <div className={styles.pageWrapper}>
        {/* LEFT: LOGIN FORM */}
        <div className={styles.loginSection}>
          <div className={styles.loginBox}>
            <div className={styles.logoSection}>
              <img src="/src/images/logo_uth.png" alt="LabOdc" className={styles.logo} />
              <h1 className={styles.title}>LabOdc Web Portal</h1>
              <p className={styles.subtitle}>Hệ thống quản lý kết nối doanh nghiệp - sinh viên</p>
            </div>

            <Card className={styles.card}>
              <h2 className={styles.cardTitle}>Đăng nhập</h2>
              <Form
                form={form}
                name="login"
                onFinish={onFinish}
                layout="vertical"
                requiredMark={false}
              >
                <Form.Item
                  name="username"
                  rules={[{ required: true, message: 'Vui lòng nhập tên đăng nhập!' }]}
                >
                  <Input
                    prefix={<UserOutlined />}
                    placeholder="Tên đăng nhập"
                    size="large"
                  />
                </Form.Item>

                <Form.Item
                  name="password"
                  rules={[{ required: true, message: 'Vui lòng nhập mật khẩu!' }]}
                >
                  <Input.Password
                    prefix={<LockOutlined />}
                    placeholder="Mật khẩu"
                    size="large"
                  />
                </Form.Item>

                <Form.Item>
                  <div className={styles.formFooter}>
                    <Link to="/forgot-password" className={styles.forgotLink}>
                      Quên mật khẩu?
                    </Link>
                  </div>
                </Form.Item>

                <Form.Item>
                  <Button
                    type="primary"
                    htmlType="submit"
                    size="large"
                    loading={loading}
                    block
                  >
                    Đăng nhập
                  </Button>
                </Form.Item>

                <div className={styles.registerLink}>
                  Chưa có tài khoản? <Link to="/register">Đăng ký ngay</Link>
                </div>
              </Form>
            </Card>
          </div>
        </div>

        {/* RIGHT: TIN TỨC - SỰ KIỆN */}
        <div className={styles.newsSection}>
          <div className={styles.newsBox}>
            <div className={styles.heroNewsHeader}>
              <h3>
                <CalendarOutlined /> Tin tức - Sự kiện
              </h3>
              <a
                href="https://ut.edu.vn/tin-tuc-su-kien-1/"
                target="_blank"
                rel="noopener noreferrer"
                className={styles.heroNewsLink}
              >
                Xem thêm <ArrowRightOutlined />
              </a>
            </div>
            <div className={styles.heroNewsList}>
              {latestNews.map((news) => (
                <a
                  key={news.id}
                  href={`https://ut.edu.vn/tin-tuc-su-kien/${news.slug}.html`}
                  target="_blank"
                  rel="noopener noreferrer"
                  className={styles.heroNewsItem}
                >
                  <img
                    src={news.imageUrl}
                    alt={news.title}
                    className={styles.heroNewsImage}
                  />
                  <div className={styles.heroNewsContent}>
                    <p className={styles.heroNewsTitle}>{news.title}</p>
                    <span className={styles.heroNewsDate}>
                      {formatNewsDate(news.publishedAt)}
                    </span>
                  </div>
                </a>
              ))}
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};

export default Login;
