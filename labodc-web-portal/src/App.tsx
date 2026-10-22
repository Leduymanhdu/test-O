// Main App Component
import React from 'react';
import { BrowserRouter } from 'react-router-dom';
import { Provider } from 'react-redux';
import { ConfigProvider, App as AntdApp } from 'antd';
import viVN from 'antd/locale/vi_VN';
import { store } from './store';
import AppRoutes from './routes';
import '@/styles/index.css';
import '@/styles/antd-custom.css';
import '@/styles/responsive.css';

const App: React.FC = () => {
  return (
    <Provider store={store}>
      <ConfigProvider
        locale={viVN}
        theme={{
          token: {
            colorPrimary: '#17a2b8',
            colorSuccess: '#4CAF50',
            colorWarning: '#FFC107',
            colorError: '#F44336',
            colorInfo: '#2196F3',
            borderRadius: 4,
            fontFamily: 'Roboto, Arial, sans-serif',
          },
        }}
      >
        <AntdApp>
          <BrowserRouter>
            <AppRoutes />
          </BrowserRouter>
        </AntdApp>
      </ConfigProvider>
    </Provider>
  );
};

export default App;
