-- =====================================================
-- Notifications, System Configuration, Audit
-- =====================================================

-- =====================================================
-- DATABASE ENUMS FOR NOTIFICATIONS & SYSTEM
-- =====================================================

-- Notification related enums
CREATE TYPE notification_type_enum AS ENUM (
    'INFO', 'SUCCESS', 'WARNING', 'ERROR', 
    'PROJECT_UPDATE', 'TASK_ASSIGNED', 'PAYMENT_RECEIVED', 
    'REPORT_DUE', 'EVALUATION_RECEIVED', 'MENTOR_INVITATION', 'SYSTEM_ALERT'
);
CREATE TYPE notification_priority_enum AS ENUM ('LOW', 'NORMAL', 'HIGH', 'URGENT');
CREATE TYPE notification_entity_enum AS ENUM ('PROJECT', 'TASK', 'PAYMENT', 'REPORT', 'EVALUATION', 'USER', 'ENTERPRISE', 'OTHER');
CREATE TYPE digest_frequency_enum AS ENUM ('IMMEDIATE', 'DAILY', 'WEEKLY');

-- Email & Queue related enums
CREATE TYPE email_status_enum AS ENUM ('QUEUED', 'SENDING', 'SENT', 'FAILED', 'CANCELLED');

-- System related enums
CREATE TYPE data_type_enum AS ENUM ('STRING', 'INTEGER', 'BOOLEAN', 'DECIMAL', 'JSON');
CREATE TYPE template_type_enum AS ENUM ('TASK_BREAKDOWN', 'FUND_DISTRIBUTION', 'REPORT', 'EVALUATION', 'OTHER');
CREATE TYPE audit_action_enum AS ENUM (
    'CREATE', 'UPDATE', 'DELETE', 'LOGIN', 'LOGOUT', 
    'APPROVE', 'REJECT', 'VALIDATE', 'DISBURSE', 'DOWNLOAD', 'UPLOAD'
);
CREATE TYPE audit_status_enum AS ENUM ('SUCCESS', 'FAILED', 'ERROR');

-- =====================================================
-- 9. NOTIFICATION MODULE
-- =====================================================

-- 9.1 Notifications table
CREATE TABLE notifications (
    id BIGSERIAL PRIMARY KEY,
    
    -- Recipient
    user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    
    -- Notification Info
    type notification_type_enum NOT NULL,
    title VARCHAR(255) NOT NULL,
    message TEXT NOT NULL,
    
    -- Related Entity
    entity_type notification_entity_enum,
    entity_id BIGINT,
    
    -- Action Link
    action_url VARCHAR(500),
    action_text VARCHAR(100),
    
    -- Priority
    priority notification_priority_enum DEFAULT 'NORMAL',
    
    -- Status
    is_read BOOLEAN DEFAULT FALSE,
    read_at TIMESTAMP,
    
    -- Delivery
    delivery_channels JSONB, -- ["EMAIL", "PUSH", "SMS"]
    email_sent BOOLEAN DEFAULT FALSE,
    push_sent BOOLEAN DEFAULT FALSE,
    sms_sent BOOLEAN DEFAULT FALSE,
    
    -- Metadata
    metadata JSONB,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    expires_at TIMESTAMP
);

CREATE INDEX idx_notifications_user ON notifications(user_id);
CREATE INDEX idx_notifications_type ON notifications(type);
CREATE INDEX idx_notifications_read ON notifications(is_read);
CREATE INDEX idx_notifications_created ON notifications(created_at);
CREATE INDEX idx_notifications_entity ON notifications(entity_type, entity_id);

COMMENT ON TABLE notifications IS 'Thông báo cho người dùng';

-- 9.2 Notification preferences
CREATE TABLE notification_preferences (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT UNIQUE NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    
    -- Channel Preferences
    email_enabled BOOLEAN DEFAULT TRUE,
    push_enabled BOOLEAN DEFAULT TRUE,
    sms_enabled BOOLEAN DEFAULT FALSE,
    
    -- Notification Types Preferences
    project_updates BOOLEAN DEFAULT TRUE,
    task_assignments BOOLEAN DEFAULT TRUE,
    payment_notifications BOOLEAN DEFAULT TRUE,
    report_reminders BOOLEAN DEFAULT TRUE,
    evaluation_notifications BOOLEAN DEFAULT TRUE,
    system_alerts BOOLEAN DEFAULT TRUE,
    
    -- Frequency
    digest_frequency digest_frequency_enum DEFAULT 'IMMEDIATE',
    
    -- Quiet Hours
    quiet_hours_enabled BOOLEAN DEFAULT FALSE,
    quiet_hours_start TIME,
    quiet_hours_end TIME,
    
    -- Timezone
    timezone VARCHAR(50) DEFAULT 'Asia/Ho_Chi_Minh',
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_notification_preferences_user ON notification_preferences(user_id);

COMMENT ON TABLE notification_preferences IS 'Tùy chọn thông báo của người dùng';

-- 9.3 Email queue
CREATE TABLE email_queue (
    id BIGSERIAL PRIMARY KEY,
    
    -- Recipient
    to_email VARCHAR(255) NOT NULL,
    to_name VARCHAR(255),
    
    -- CC & BCC
    cc_emails TEXT,
    bcc_emails TEXT,
    
    -- Email Content
    subject VARCHAR(500) NOT NULL,
    body_html TEXT NOT NULL,
    body_text TEXT,
    
    -- Related
    notification_id BIGINT REFERENCES notifications(id) ON DELETE SET NULL,
    
    -- Template
    template_name VARCHAR(100),
    template_data JSONB,
    
    -- Priority
    priority INTEGER DEFAULT 0,
    
    -- Status
    status email_status_enum DEFAULT 'QUEUED',
    
    -- Sending
    attempts INTEGER DEFAULT 0,
    max_attempts INTEGER DEFAULT 3,
    next_attempt_at TIMESTAMP,
    
    sent_at TIMESTAMP,
    error_message TEXT,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_email_queue_status ON email_queue(status);
CREATE INDEX idx_email_queue_next_attempt ON email_queue(next_attempt_at) WHERE status = 'QUEUED';
CREATE INDEX idx_email_queue_created ON email_queue(created_at);

COMMENT ON TABLE email_queue IS 'Hàng đợi gửi email';

-- =====================================================
-- 10. SYSTEM & CONFIGURATION MODULE
-- =====================================================

-- 10.1 System configs
CREATE TABLE system_configs (
    id BIGSERIAL PRIMARY KEY,
    config_key VARCHAR(100) UNIQUE NOT NULL,
    config_value TEXT NOT NULL,
    data_type data_type_enum NOT NULL,
    description TEXT,
    
    -- Settings
    editable BOOLEAN DEFAULT TRUE,
    category VARCHAR(50), -- FUND_DISTRIBUTION, PAYMENT, PROJECT, SECURITY, NOTIFICATION, UPLOAD
    
    -- Validation
    validation_rules JSONB, -- {min: 0, max: 100, pattern: "^[0-9]+$"}
    
    -- Audit
    updated_by BIGINT REFERENCES users(id) ON DELETE SET NULL,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_system_configs_key ON system_configs(config_key);
CREATE INDEX idx_system_configs_category ON system_configs(category);

COMMENT ON TABLE system_configs IS 'Cấu hình hệ thống';

-- 10.2 Config change history
CREATE TABLE config_change_history (
    id BIGSERIAL PRIMARY KEY,
    config_key VARCHAR(100) NOT NULL,
    old_value TEXT,
    new_value TEXT,
    reason TEXT,
    changed_by BIGINT NOT NULL REFERENCES users(id) ON DELETE SET NULL,
    changed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_config_change_history_key ON config_change_history(config_key);
CREATE INDEX idx_config_change_history_changed ON config_change_history(changed_at);

COMMENT ON TABLE config_change_history IS 'Lịch sử thay đổi cấu hình';

-- 10.3 Excel templates
CREATE TABLE excel_templates (
    id BIGSERIAL PRIMARY KEY,
    
    -- Template Info
    template_name VARCHAR(100) UNIQUE NOT NULL,
    template_type template_type_enum NOT NULL,
    description TEXT,
    
    -- File (centralized)
    file_id BIGINT, -- References files table
    version VARCHAR(20) NOT NULL,
    
    -- Schema Definition (for parsing)
    column_mapping JSONB NOT NULL, -- {taskName: "B", description: "C", assignedTo: "D"}
    validation_rules JSONB,
    
    -- Status
    is_active BOOLEAN DEFAULT TRUE,
    
    -- Audit
    created_by BIGINT REFERENCES users(id) ON DELETE SET NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_excel_templates_name ON excel_templates(template_name);
CREATE INDEX idx_excel_templates_type ON excel_templates(template_type);
CREATE INDEX idx_excel_templates_active ON excel_templates(is_active);

COMMENT ON TABLE excel_templates IS 'Mẫu Excel cho hệ thống';

-- 10.4 Audit logs
CREATE TABLE audit_logs (
    id BIGSERIAL PRIMARY KEY,
    
    -- User
    user_id BIGINT REFERENCES users(id) ON DELETE SET NULL,
    user_email VARCHAR(255),
    user_role VARCHAR(50),
    
    -- Action
    action audit_action_enum NOT NULL,
    entity_type VARCHAR(50) NOT NULL, -- USER, PROJECT, PAYMENT, TASK, REPORT
    entity_id BIGINT,
    
    -- Details
    description TEXT,
    
    -- Changes (for UPDATE actions)
    old_values JSONB,
    new_values JSONB,
    
    -- Request Info
    ip_address VARCHAR(45),
    user_agent TEXT,
    request_method VARCHAR(10),
    request_path VARCHAR(500),
    
    -- Result
    status audit_status_enum,
    error_message TEXT,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_audit_logs_user ON audit_logs(user_id);
CREATE INDEX idx_audit_logs_action ON audit_logs(action);
CREATE INDEX idx_audit_logs_entity ON audit_logs(entity_type, entity_id);
CREATE INDEX idx_audit_logs_created ON audit_logs(created_at);

-- Partition by time (monthly)
-- ALTER TABLE audit_logs PARTITION BY RANGE (created_at);

COMMENT ON TABLE audit_logs IS 'Logs audit toàn hệ thống';

-- 10.5 System statistics
CREATE TABLE system_statistics (
    id BIGSERIAL PRIMARY KEY,
    
    -- Date
    stat_date DATE UNIQUE NOT NULL,
    
    -- Users
    total_users INTEGER DEFAULT 0,
    active_users INTEGER DEFAULT 0,
    new_users INTEGER DEFAULT 0,
    
    -- By Role
    total_enterprises INTEGER DEFAULT 0,
    total_talents INTEGER DEFAULT 0,
    total_mentors INTEGER DEFAULT 0,
    
    -- Projects
    total_projects INTEGER DEFAULT 0,
    active_projects INTEGER DEFAULT 0,
    completed_projects INTEGER DEFAULT 0,
    new_projects INTEGER DEFAULT 0,
    
    -- Tasks
    total_tasks INTEGER DEFAULT 0,
    completed_tasks INTEGER DEFAULT 0,
    overdue_tasks INTEGER DEFAULT 0,
    
    -- Finance
    total_payments DECIMAL(15,2) DEFAULT 0,
    total_disbursed DECIMAL(15,2) DEFAULT 0,
    pending_disbursements DECIMAL(15,2) DEFAULT 0,
    
    -- Performance
    avg_project_completion_rate DECIMAL(5,2) DEFAULT 0,
    avg_task_completion_rate DECIMAL(5,2) DEFAULT 0,
    avg_talent_rating DECIMAL(3,2) DEFAULT 0,
    avg_enterprise_rating DECIMAL(3,2) DEFAULT 0,
    
    -- System Health
    api_uptime_percentage DECIMAL(5,2) DEFAULT 100,
    avg_response_time_ms INTEGER DEFAULT 0,
    error_rate DECIMAL(5,2) DEFAULT 0,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_system_statistics_date ON system_statistics(stat_date);

COMMENT ON TABLE system_statistics IS 'Thống kê hệ thống theo ngày';

-- =====================================================
-- VIEWS FOR REPORTING
-- =====================================================

-- View: Active projects summary
CREATE OR REPLACE VIEW v_active_projects AS
SELECT 
    p.id,
    p.title,
    p.slug,
    p.status,
    p.progress_percentage,
    e.company_name as enterprise_name,
    m.full_name as mentor_name,
    p.number_of_students,
    p.current_members_count,
    p.budget,
    p.start_date,
    p.end_date,
    CASE 
        WHEN p.end_date < CURRENT_DATE THEN 'OVERDUE'
        WHEN p.end_date <= CURRENT_DATE + INTERVAL '7 days' THEN 'DUE_SOON'
        ELSE 'ON_TRACK'
    END as timeline_status
FROM projects p
LEFT JOIN enterprises e ON p.enterprise_id = e.id
LEFT JOIN mentors m ON p.mentor_id = m.id
WHERE p.status IN ('IN_PROGRESS', 'RECRUITING')
AND p.deleted_at IS NULL;

-- View: Fund allocation summary
CREATE OR REPLACE VIEW v_fund_allocation_summary AS
SELECT 
    fa.id,
    fa.project_id,
    p.title as project_title,
    e.company_name,
    fa.total_amount,
    fa.team_amount,
    fa.mentor_amount,
    fa.lab_amount,
    fa.status,
    COALESCE(SUM(CASE WHEN fd.status = 'COMPLETED' THEN fd.amount ELSE 0 END), 0) as total_disbursed,
    fa.total_amount - COALESCE(SUM(CASE WHEN fd.status = 'COMPLETED' THEN fd.amount ELSE 0 END), 0) as remaining_amount
FROM fund_allocations fa
JOIN projects p ON fa.project_id = p.id
JOIN enterprises e ON p.enterprise_id = e.id
LEFT JOIN fund_distributions fd ON fa.id = fd.allocation_id
GROUP BY fa.id, p.title, e.company_name;

-- View: Talent performance
CREATE OR REPLACE VIEW v_talent_performance AS
SELECT 
    t.id,
    t.full_name,
    t.student_id,
    t.faculty,
    t.rating_average,
    t.total_projects,
    t.completed_projects,
    COUNT(DISTINCT pm.project_id) as current_projects,
    COALESCE(SUM(CASE WHEN task.status = 'COMPLETED' THEN 1 ELSE 0 END), 0) as tasks_completed,
    COALESCE(AVG(te.overall_score), 0) as avg_evaluation_score
FROM talents t
LEFT JOIN project_members pm ON t.id = pm.talent_id AND pm.status = 'ACTIVE'
LEFT JOIN tasks task ON t.id = task.assigned_to
LEFT JOIN talent_evaluations te ON t.id = te.talent_id
GROUP BY t.id, t.full_name, t.student_id, t.faculty, t.rating_average, t.total_projects, t.completed_projects;

-- View: Mentor workload
CREATE OR REPLACE VIEW v_mentor_workload AS
SELECT 
    m.id,
    m.full_name,
    m.max_concurrent_projects,
    m.current_projects_count,
    COUNT(DISTINCT p.id) as active_projects,
    COUNT(DISTINCT pm.talent_id) as total_students,
    m.rating_average,
    m.available
FROM mentors m
LEFT JOIN projects p ON m.id = p.mentor_id AND p.status IN ('IN_PROGRESS', 'RECRUITING')
LEFT JOIN project_members pm ON p.id = pm.project_id AND pm.status = 'ACTIVE'
GROUP BY m.id, m.full_name, m.max_concurrent_projects, m.current_projects_count, m.rating_average, m.available;

-- =====================================================
-- TRIGGERS
-- =====================================================

-- Trigger: Update timestamps
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Apply to all tables with updated_at
CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_enterprises_updated_at BEFORE UPDATE ON enterprises
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_talents_updated_at BEFORE UPDATE ON talents
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_mentors_updated_at BEFORE UPDATE ON mentors
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_projects_updated_at BEFORE UPDATE ON projects
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_tasks_updated_at BEFORE UPDATE ON tasks
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Trigger: Log audit for important actions
CREATE OR REPLACE FUNCTION log_project_changes()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'UPDATE' THEN
        INSERT INTO audit_logs (user_id, action, entity_type, entity_id, description, old_values, new_values)
        VALUES (
            NEW.enterprise_id,
            'UPDATE',
            'PROJECT',
            NEW.id,
            'Project updated',
            to_jsonb(OLD),
            to_jsonb(NEW)
        );
    ELSIF TG_OP = 'INSERT' THEN
        INSERT INTO audit_logs (user_id, action, entity_type, entity_id, description, new_values)
        VALUES (
            NEW.enterprise_id,
            'CREATE',
            'PROJECT',
            NEW.id,
            'Project created',
            to_jsonb(NEW)
        );
    END IF;
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER log_project_changes_trigger
    AFTER INSERT OR UPDATE ON projects
    FOR EACH ROW EXECUTE FUNCTION log_project_changes();

-- =====================================================
-- FUNCTIONS
-- =====================================================

-- Function: Calculate fund split (70/20/10)
CREATE OR REPLACE FUNCTION calculate_fund_split(total_amount DECIMAL)
RETURNS TABLE(team_amount DECIMAL, mentor_amount DECIMAL, lab_amount DECIMAL) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        ROUND(total_amount * 0.70, 2) as team_amount,
        ROUND(total_amount * 0.20, 2) as mentor_amount,
        ROUND(total_amount * 0.10, 2) as lab_amount;
END;
$$ LANGUAGE plpgsql;

-- Function: Check project member availability
CREATE OR REPLACE FUNCTION check_talent_availability(talent_id_param BIGINT)
RETURNS BOOLEAN AS $$
DECLARE
    current_projects INTEGER;
    max_projects INTEGER := 2; -- Configurable
BEGIN
    SELECT COUNT(*)
    INTO current_projects
    FROM project_members
    WHERE talent_id = talent_id_param
    AND status = 'ACTIVE';
    
    RETURN current_projects < max_projects;
END;
$$ LANGUAGE plpgsql;

-- Function: Update project progress
CREATE OR REPLACE FUNCTION update_project_progress(project_id_param BIGINT)
RETURNS VOID AS $$
DECLARE
    total_tasks INTEGER;
    completed_tasks INTEGER;
    progress INTEGER;
BEGIN
    SELECT COUNT(*), COUNT(*) FILTER (WHERE status = 'COMPLETED')
    INTO total_tasks, completed_tasks
    FROM tasks
    WHERE project_id = project_id_param;
    
    IF total_tasks > 0 THEN
        progress := ROUND((completed_tasks::DECIMAL / total_tasks) * 100);
        
        UPDATE projects
        SET progress_percentage = progress,
            updated_at = CURRENT_TIMESTAMP
        WHERE id = project_id_param;
    END IF;
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- INITIAL DATA
-- =====================================================

-- Insert default roles
INSERT INTO roles (name, display_name, description, editable, system_role) VALUES
('SYSTEM_ADMIN', 'System Administrator', 'Toàn quyền quản trị hệ thống', FALSE, TRUE),
('LAB_ADMIN', 'Lab Administrator', 'Quản lý nghiệp vụ Lab', TRUE, TRUE),
('ENTERPRISE', 'Enterprise', 'Doanh nghiệp', TRUE, TRUE),
('TALENT', 'Talent', 'Sinh viên/Người tài năng', TRUE, TRUE),
('TALENT_LEADER', 'Talent Leader', 'Trưởng nhóm sinh viên', TRUE, FALSE),
('MENTOR', 'Mentor', 'Người hướng dẫn', TRUE, TRUE);

-- Insert default permissions
INSERT INTO permissions (name, resource, action, description) VALUES
-- User permissions
('user.view', 'user', 'view', 'Xem thông tin người dùng'),
('user.create', 'user', 'create', 'Tạo người dùng mới'),
('user.update', 'user', 'update', 'Cập nhật người dùng'),
('user.delete', 'user', 'delete', 'Xóa người dùng'),

-- Project permissions
('project.view', 'project', 'view', 'Xem dự án'),
('project.create', 'project', 'create', 'Tạo dự án'),
('project.update', 'project', 'update', 'Cập nhật dự án'),
('project.delete', 'project', 'delete', 'Xóa dự án'),
('project.validate', 'project', 'validate', 'Xác thực dự án'),
('project.join', 'project', 'join', 'Tham gia dự án'),

-- Payment permissions
('payment.view', 'payment', 'view', 'Xem thanh toán'),
('payment.create', 'payment', 'create', 'Tạo thanh toán'),
('payment.process', 'payment', 'process', 'Xử lý thanh toán'),

-- Fund permissions
('fund.view', 'fund', 'view', 'Xem quỹ'),
('fund.allocate', 'fund', 'allocate', 'Phân bổ quỹ'),
('fund.disburse', 'fund', 'disburse', 'Giải ngân'),

-- Report permissions
('report.view', 'report', 'view', 'Xem báo cáo'),
('report.create', 'report', 'create', 'Tạo báo cáo'),
('report.publish', 'report', 'publish', 'Công bố báo cáo'),

-- System permissions
('system.config', 'system', 'config', 'Cấu hình hệ thống'),
('system.audit', 'system', 'audit', 'Xem audit logs');

-- Insert default system configs
INSERT INTO system_configs (config_key, config_value, data_type, description, editable, category) VALUES
-- Fund distribution (FIXED - not editable)
('fund.team_percentage', '70', 'DECIMAL', 'Phần trăm quỹ cho nhóm', FALSE, 'FUND_DISTRIBUTION'),
('fund.mentor_percentage', '20', 'DECIMAL', 'Phần trăm quỹ cho mentor', FALSE, 'FUND_DISTRIBUTION'),
('fund.lab_percentage', '10', 'DECIMAL', 'Phần trăm quỹ cho lab', FALSE, 'FUND_DISTRIBUTION'),

-- Payment settings
('payment.delay_warning_days', '7', 'INTEGER', 'Số ngày cảnh báo trễ thanh toán', TRUE, 'PAYMENT'),
('payment.hybrid_fund_trigger_days', '14', 'INTEGER', 'Số ngày kích hoạt tạm ứng', TRUE, 'PAYMENT'),
('payment.link_expire_minutes', '15', 'INTEGER', 'Thời gian hết hạn link thanh toán (phút)', TRUE, 'PAYMENT'),

-- Project settings
('project.min_budget', '10000000', 'INTEGER', 'Ngân sách tối thiểu (VND)', TRUE, 'PROJECT'),
('project.max_budget', '1000000000', 'INTEGER', 'Ngân sách tối đa (VND)', TRUE, 'PROJECT'),
('project.min_students', '3', 'INTEGER', 'Số sinh viên tối thiểu', TRUE, 'PROJECT'),
('project.max_students', '10', 'INTEGER', 'Số sinh viên tối đa', TRUE, 'PROJECT'),

-- Security settings
('security.jwt_expiration_minutes', '30', 'INTEGER', 'Thời gian hết hạn JWT (phút)', TRUE, 'SECURITY'),
('security.refresh_token_days', '7', 'INTEGER', 'Thời gian hết hạn refresh token (ngày)', TRUE, 'SECURITY'),
('security.max_login_attempts', '5', 'INTEGER', 'Số lần đăng nhập sai tối đa', TRUE, 'SECURITY'),
('security.account_lock_minutes', '30', 'INTEGER', 'Thời gian khóa tài khoản (phút)', TRUE, 'SECURITY'),

-- Upload settings
('upload.max_image_size_mb', '5', 'INTEGER', 'Kích thước ảnh tối đa (MB)', TRUE, 'UPLOAD'),
('upload.max_document_size_mb', '20', 'INTEGER', 'Kích thước tài liệu tối đa (MB)', TRUE, 'UPLOAD'),
('upload.max_excel_size_mb', '10', 'INTEGER', 'Kích thước Excel tối đa (MB)', TRUE, 'UPLOAD');

-- =====================================================
-- COMMENTS & DOCUMENTATION
-- =====================================================

COMMENT ON DATABASE labodc IS 'LabOdc - Hệ thống quản lý kết nối doanh nghiệp với sinh viên UTH';

-- =====================================================
-- FOREIGN KEY CONSTRAINTS FOR CENTRALIZED FILE MANAGEMENT
-- (To be added after files table is created in V1_3 migration)
-- =====================================================

-- Note: These constraints will be added in V1_3__Centralized_File_Management.sql
-- after the files table is created:
--
-- ALTER TABLE excel_templates ADD CONSTRAINT fk_excel_templates_file 
--     FOREIGN KEY (file_id) REFERENCES files(id) ON DELETE SET NULL;

-- =====================================================
-- END OF NOTIFICATIONS & SYSTEM CONFIG MODULE
-- =====================================================
