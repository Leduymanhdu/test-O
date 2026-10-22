// Register Page
import React from 'react';
import { Form, Input, Button, Card, Select, message } from 'antd';
import { UserOutlined, LockOutlined, MailOutlined, PhoneOutlined } from '@ant-design/icons';
import { Link, useNavigate } from 'react-router-dom';
import { useAppDispatch, useAppSelector } from '@/store/hooks';
import { register } from '@/store/slices/authSlice';
import { IRegisterRequest } from '@/types/auth.types';
import { ROLE_LABELS } from '@/utils/constants';
import styles from './Register.module.css';

const { Option } = Select;

const Register: React.FC = () => {
  const [form] = Form.useForm();
  const dispatch = useAppDispatch();
  const navigate = useNavigate();
  const { loading } = useAppSelector((state) => state.auth);

  const onFinish = async (values: IRegisterRequest) => {
    try {
      await dispatch(register(values)).unwrap();
      message.success('Đăng ký thành công! Vui lòng chờ xác thực.');
      navigate('/login');
    } catch (error: any) {
      message.error(error || 'Đăng ký thất bại!');
    }
  };

  return (
    <div className={styles.container}>
      <div className={styles.registerBox}>
        <div className={styles.logoSection}>
          <img src="/src/images/logo_uth.png" alt="LabOdc" className={styles.logo} />
          <h1 className={styles.title}>Đăng ký tài khoản</h1>
        </div>

        <Card className={styles.card}>
          <Form
            form={form}
            name="register"
            onFinish={onFinish}
            layout="vertical"
            requiredMark={false}
            scrollToFirstError
          >
            <Form.Item
              name="email"
              rules={[
                { required: true, message: 'Vui lòng nhập email!' },
                { type: 'email', message: 'Email không hợp lệ!' },
              ]}
            >
              <Input
                prefix={<MailOutlined />}
                placeholder="Email"
                size="large"
              />
            </Form.Item>

            <Form.Item
              name="role"
              rules={[{ required: true, message: 'Vui lòng chọn vai trò!' }]}
            >
              <Select placeholder="Chọn vai trò" size="large">
                <Option value="ENTERPRISE">{ROLE_LABELS.ENTERPRISE}</Option>
                <Option value="TALENT">{ROLE_LABELS.TALENT}</Option>
                <Option value="MENTOR">{ROLE_LABELS.MENTOR}</Option>
              </Select>
            </Form.Item>

            <Form.Item
              name="password"
              rules={[
                { required: true, message: 'Vui lòng nhập mật khẩu!' },
                { min: 6, message: 'Mật khẩu phải có ít nhất 6 ký tự!' },
              ]}
            >
              <Input.Password
                prefix={<LockOutlined />}
                placeholder="Mật khẩu"
                size="large"
              />
            </Form.Item>

            <Form.Item
              name="confirmPassword"
              dependencies={['password']}
              rules={[
                { required: true, message: 'Vui lòng xác nhận mật khẩu!' },
                ({ getFieldValue }) => ({
                  validator(_, value) {
                    if (!value || getFieldValue('password') === value) {
                      return Promise.resolve();
                    }
                    return Promise.reject(new Error('Mật khẩu không khớp!'));
                  },
                }),
              ]}
            >
              <Input.Password
                prefix={<LockOutlined />}
                placeholder="Xác nhận mật khẩu"
                size="large"
              />
            </Form.Item>

            <Form.Item>
              <Button
                type="primary"
                htmlType="submit"
                size="large"
                loading={loading}
                block
              >
                Đăng ký
              </Button>
            </Form.Item>

            <div className={styles.loginLink}>
              Đã có tài khoản? <Link to="/login">Đăng nhập ngay</Link>
            </div>
          </Form>
        </Card>
      </div>
    </div>
  );
};

export default Register;
