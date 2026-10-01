-- =====================================================
-- Tasks, Payment, Fund, Reports, Evaluations
-- =====================================================

-- =====================================================
-- DATABASE ENUMS FOR TASKS, PAYMENT, REPORTS
-- =====================================================

-- Task related enums
CREATE TYPE task_priority_enum AS ENUM ('LOW', 'MEDIUM', 'HIGH', 'CRITICAL');
CREATE TYPE task_status_enum AS ENUM ('TODO', 'IN_PROGRESS', 'IN_REVIEW', 'COMPLETED', 'BLOCKED', 'CANCELLED');
CREATE TYPE dependency_type_enum AS ENUM ('FINISH_TO_START', 'START_TO_START', 'FINISH_TO_FINISH', 'START_TO_FINISH');

-- Payment related enums
CREATE TYPE payment_status_enum AS ENUM ('PENDING', 'PROCESSING', 'COMPLETED', 'FAILED', 'CANCELLED', 'REFUNDED', 'EXPIRED');
CREATE TYPE transaction_type_enum AS ENUM ('PAYMENT', 'REFUND', 'CHARGEBACK');
CREATE TYPE transaction_status_enum AS ENUM ('SUCCESS', 'FAILED', 'PENDING');
CREATE TYPE fund_allocation_status_enum AS ENUM ('ALLOCATED', 'DISTRIBUTED', 'COMPLETED');
CREATE TYPE fund_distribution_status_enum AS ENUM ('PENDING', 'PROCESSING', 'COMPLETED', 'FAILED', 'ON_HOLD');
CREATE TYPE recipient_type_enum AS ENUM ('TEAM', 'MENTOR', 'LAB', 'TALENT');
CREATE TYPE team_fund_status_enum AS ENUM ('DRAFT', 'SUBMITTED', 'APPROVED_BY_MENTOR', 'APPROVED_BY_LAB', 'REJECTED', 'DISBURSED');
CREATE TYPE advance_reason_enum AS ENUM ('PAYMENT_DELAY', 'EMERGENCY', 'OTHER');
CREATE TYPE repayment_status_enum AS ENUM ('OUTSTANDING', 'PARTIALLY_REPAID', 'FULLY_REPAID');
CREATE TYPE disbursement_reference_enum AS ENUM ('FUND_DISTRIBUTION', 'HYBRID_ADVANCE', 'REFUND');
CREATE TYPE payment_method_enum AS ENUM ('BANK_TRANSFER', 'MOMO', 'PAYPAL', 'CASH');

-- Report related enums
CREATE TYPE report_type_enum AS ENUM ('WEEKLY', 'MONTHLY', 'MILESTONE', 'FINAL', 'QUARTERLY', 'ANNUAL');
CREATE TYPE report_status_enum AS ENUM ('DRAFT', 'SUBMITTED', 'REVIEWED', 'PUBLISHED', 'ARCHIVED');
CREATE TYPE evaluation_grade_enum AS ENUM ('A', 'B', 'C', 'D', 'F');

-- =====================================================
-- 6. TASK MODULE
-- =====================================================

-- 6.1 Tasks table
CREATE TABLE tasks (
    id BIGSERIAL PRIMARY KEY,
    project_id BIGINT NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
    
    -- Task Info
    task_id VARCHAR(20) NOT NULL, -- T001, T002, etc.
    task_name VARCHAR(255) NOT NULL,
    description TEXT,
    
    -- Assignment
    assigned_to BIGINT REFERENCES talents(id) ON DELETE SET NULL,
    created_by BIGINT NOT NULL REFERENCES mentors(id) ON DELETE CASCADE,
    
    -- Priority & Status
    priority task_priority_enum DEFAULT 'MEDIUM',
    status task_status_enum DEFAULT 'TODO',
    
    -- Timeline
    start_date DATE,
    due_date DATE,
    completed_date DATE,
    
    -- Effort
    estimated_hours INTEGER,
    actual_hours INTEGER,
    
    -- Dependencies
    dependencies TEXT, -- Comma-separated task IDs
    
    -- Tags
    tags TEXT, -- Comma-separated tags
    
    -- Progress
    progress_percentage INTEGER DEFAULT 0,
    
    -- Audit
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    UNIQUE(project_id, task_id),
    CONSTRAINT check_dates CHECK (due_date >= start_date),
    CONSTRAINT check_progress CHECK (progress_percentage BETWEEN 0 AND 100)
);

CREATE INDEX idx_tasks_project ON tasks(project_id);
CREATE INDEX idx_tasks_assigned ON tasks(assigned_to);
CREATE INDEX idx_tasks_status ON tasks(status);
CREATE INDEX idx_tasks_priority ON tasks(priority);
CREATE INDEX idx_tasks_due_date ON tasks(due_date);
CREATE INDEX idx_tasks_created_by ON tasks(created_by);

COMMENT ON TABLE tasks IS 'Nhiệm vụ trong dự án (từ Excel upload)';

-- 6.2 Task dependencies
CREATE TABLE task_dependencies (
    id BIGSERIAL PRIMARY KEY,
    task_id BIGINT NOT NULL REFERENCES tasks(id) ON DELETE CASCADE,
    depends_on_task_id BIGINT NOT NULL REFERENCES tasks(id) ON DELETE CASCADE,
    dependency_type dependency_type_enum DEFAULT 'FINISH_TO_START',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(task_id, depends_on_task_id),
    CONSTRAINT check_no_self_dependency CHECK (task_id != depends_on_task_id)
);

CREATE INDEX idx_task_dependencies_task ON task_dependencies(task_id);
CREATE INDEX idx_task_dependencies_depends ON task_dependencies(depends_on_task_id);

-- 6.3 Task comments
CREATE TABLE task_comments (
    id BIGSERIAL PRIMARY KEY,
    task_id BIGINT NOT NULL REFERENCES tasks(id) ON DELETE CASCADE,
    user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    comment TEXT NOT NULL,
    parent_comment_id BIGINT REFERENCES task_comments(id) ON DELETE CASCADE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP
);

CREATE INDEX idx_task_comments_task ON task_comments(task_id);
CREATE INDEX idx_task_comments_user ON task_comments(user_id);
CREATE INDEX idx_task_comments_parent ON task_comments(parent_comment_id);

-- 6.4 Task attachments
CREATE TABLE task_attachments (
    id BIGSERIAL PRIMARY KEY,
    task_id BIGINT NOT NULL REFERENCES tasks(id) ON DELETE CASCADE,
    
    -- File reference (centralized)
    file_id BIGINT, -- References files table
    
    uploaded_by BIGINT REFERENCES users(id) ON DELETE SET NULL,
    uploaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_task_attachments_task ON task_attachments(task_id);

-- 6.5 Task time logs
CREATE TABLE task_time_logs (
    id BIGSERIAL PRIMARY KEY,
    task_id BIGINT NOT NULL REFERENCES tasks(id) ON DELETE CASCADE,
    talent_id BIGINT NOT NULL REFERENCES talents(id) ON DELETE CASCADE,
    
    -- Time
    start_time TIMESTAMP NOT NULL,
    end_time TIMESTAMP,
    duration_minutes INTEGER,
    
    -- Description
    description TEXT,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT check_time_range CHECK (end_time IS NULL OR end_time > start_time)
);

CREATE INDEX idx_task_time_logs_task ON task_time_logs(task_id);
CREATE INDEX idx_task_time_logs_talent ON task_time_logs(talent_id);

-- =====================================================
-- 7. PAYMENT & FUND MODULE
-- =====================================================

-- 7.1 Payments table
CREATE TABLE payments (
    id BIGSERIAL PRIMARY KEY,
    project_id BIGINT NOT NULL REFERENCES projects(id) ON DELETE RESTRICT,
    enterprise_id BIGINT NOT NULL REFERENCES enterprises(id) ON DELETE RESTRICT,
    
    -- Payment Info
    payment_code VARCHAR(50) UNIQUE NOT NULL,
    amount DECIMAL(15,2) NOT NULL,
    currency VARCHAR(10) DEFAULT 'VND',
    
    -- PayOS Integration
    payos_order_id VARCHAR(100) UNIQUE,
    payos_transaction_id VARCHAR(100),
    payos_payment_link VARCHAR(500),
    
    -- Status
    status payment_status_enum NOT NULL DEFAULT 'PENDING',
    payment_method VARCHAR(50),
    
    -- Timeline
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    payment_link_expires_at TIMESTAMP,
    paid_at TIMESTAMP,
    
    -- Notes
    description TEXT,
    note TEXT,
    
    CONSTRAINT check_amount CHECK (amount > 0)
);

CREATE INDEX idx_payments_project ON payments(project_id);
CREATE INDEX idx_payments_enterprise ON payments(enterprise_id);
CREATE INDEX idx_payments_status ON payments(status);
CREATE INDEX idx_payments_code ON payments(payment_code);
CREATE INDEX idx_payments_payos_order ON payments(payos_order_id);

COMMENT ON TABLE payments IS 'Thanh toán từ doanh nghiệp';

-- 7.2 Payment transactions
CREATE TABLE payment_transactions (
    id BIGSERIAL PRIMARY KEY,
    payment_id BIGINT NOT NULL REFERENCES payments(id) ON DELETE RESTRICT,
    
    -- Transaction Info
    transaction_id VARCHAR(100) UNIQUE NOT NULL,
    transaction_type transaction_type_enum NOT NULL,
    amount DECIMAL(15,2) NOT NULL,
    
    -- PayOS Response
    payos_response JSONB,
    
    -- Status
    status transaction_status_enum NOT NULL,
    
    -- Audit
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_payment_transactions_payment ON payment_transactions(payment_id);
CREATE INDEX idx_payment_transactions_transaction ON payment_transactions(transaction_id);

-- 7.3 Fund allocations (70/20/10 split)
CREATE TABLE fund_allocations (
    id BIGSERIAL PRIMARY KEY,
    project_id BIGINT UNIQUE NOT NULL REFERENCES projects(id) ON DELETE RESTRICT,
    payment_id BIGINT NOT NULL REFERENCES payments(id) ON DELETE RESTRICT,
    
    -- Total Amount
    total_amount DECIMAL(15,2) NOT NULL,
    
    -- 70/20/10 Split
    team_percentage DECIMAL(5,2) DEFAULT 70.00,
    team_amount DECIMAL(15,2) NOT NULL,
    
    mentor_percentage DECIMAL(5,2) DEFAULT 20.00,
    mentor_amount DECIMAL(15,2) NOT NULL,
    
    lab_percentage DECIMAL(5,2) DEFAULT 10.00,
    lab_amount DECIMAL(15,2) NOT NULL,
    
    -- Status
    status fund_allocation_status_enum DEFAULT 'ALLOCATED',
    
    -- Validation
    validated_by BIGINT REFERENCES users(id) ON DELETE SET NULL,
    validated_at TIMESTAMP,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT check_percentages CHECK (team_percentage + mentor_percentage + lab_percentage = 100),
    CONSTRAINT check_amounts CHECK (team_amount + mentor_amount + lab_amount = total_amount)
);

CREATE INDEX idx_fund_allocations_project ON fund_allocations(project_id);
CREATE INDEX idx_fund_allocations_payment ON fund_allocations(payment_id);

COMMENT ON TABLE fund_allocations IS 'Phân bổ quỹ theo tỷ lệ 70/20/10';

-- 7.4 Fund distributions
CREATE TABLE fund_distributions (
    id BIGSERIAL PRIMARY KEY,
    allocation_id BIGINT NOT NULL REFERENCES fund_allocations(id) ON DELETE RESTRICT,
    
    -- Recipient
    recipient_type recipient_type_enum NOT NULL,
    recipient_id BIGINT, -- talent_id or mentor_id (NULL for LAB)
    
    -- Amount
    amount DECIMAL(15,2) NOT NULL,
    
    -- Disbursement
    status fund_distribution_status_enum DEFAULT 'PENDING',
    disbursed_at TIMESTAMP,
    disbursed_by BIGINT REFERENCES users(id) ON DELETE SET NULL,
    
    -- Payment Info
    payment_method VARCHAR(50),
    transaction_reference VARCHAR(100),
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_fund_distributions_allocation ON fund_distributions(allocation_id);
CREATE INDEX idx_fund_distributions_recipient ON fund_distributions(recipient_type, recipient_id);
CREATE INDEX idx_fund_distributions_status ON fund_distributions(status);

-- 7.5 Team fund distributions (Leader quản lý)
CREATE TABLE team_fund_distributions (
    id BIGSERIAL PRIMARY KEY,
    project_id BIGINT NOT NULL REFERENCES projects(id) ON DELETE RESTRICT,
    allocation_id BIGINT NOT NULL REFERENCES fund_allocations(id) ON DELETE RESTRICT,
    
    -- Submitted by Talent Leader
    submitted_by BIGINT NOT NULL REFERENCES talents(id),
    
    -- Total for team (70%)
    total_team_amount DECIMAL(15,2) NOT NULL,
    
    -- Status
    status team_fund_status_enum DEFAULT 'DRAFT',
    
    -- Approval
    approved_by_mentor BIGINT REFERENCES mentors(id) ON DELETE SET NULL,
    approved_by_mentor_at TIMESTAMP,
    
    approved_by_lab BIGINT REFERENCES users(id) ON DELETE SET NULL,
    approved_by_lab_at TIMESTAMP,
    
    rejection_reason TEXT,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_team_fund_distributions_project ON team_fund_distributions(project_id);
CREATE INDEX idx_team_fund_distributions_submitted ON team_fund_distributions(submitted_by);

COMMENT ON TABLE team_fund_distributions IS 'Phân phối quỹ nhóm do Talent Leader quản lý';

-- 7.6 Team member allocations
CREATE TABLE team_member_allocations (
    id BIGSERIAL PRIMARY KEY,
    distribution_id BIGINT NOT NULL REFERENCES team_fund_distributions(id) ON DELETE CASCADE,
    talent_id BIGINT NOT NULL REFERENCES talents(id) ON DELETE RESTRICT,
    
    -- Allocation
    percentage DECIMAL(5,2) NOT NULL,
    amount DECIMAL(15,2) NOT NULL,
    reason TEXT,
    
    -- Performance basis
    tasks_completed INTEGER,
    hours_contributed INTEGER,
    performance_score DECIMAL(3,2),
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT check_percentage CHECK (percentage BETWEEN 5 AND 100),
    UNIQUE(distribution_id, talent_id)
);

CREATE INDEX idx_team_member_allocations_distribution ON team_member_allocations(distribution_id);
CREATE INDEX idx_team_member_allocations_talent ON team_member_allocations(talent_id);

-- 7.7 Hybrid fund advances (Lab tạm ứng)
CREATE TABLE hybrid_fund_advances (
    id BIGSERIAL PRIMARY KEY,
    project_id BIGINT NOT NULL REFERENCES projects(id) ON DELETE RESTRICT,
    payment_id BIGINT NOT NULL REFERENCES payments(id) ON DELETE RESTRICT,
    
    -- Advance Info
    advance_reason advance_reason_enum NOT NULL,
    advance_amount DECIMAL(15,2) NOT NULL,
    
    -- Timeline
    advanced_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    expected_repayment_date DATE NOT NULL,
    
    -- Repayment
    repayment_status repayment_status_enum DEFAULT 'OUTSTANDING',
    repaid_amount DECIMAL(15,2) DEFAULT 0,
    repaid_at TIMESTAMP,
    
    -- Approval
    approved_by BIGINT NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
    approval_note TEXT
);

CREATE INDEX idx_hybrid_fund_advances_project ON hybrid_fund_advances(project_id);
CREATE INDEX idx_hybrid_fund_advances_payment ON hybrid_fund_advances(payment_id);
CREATE INDEX idx_hybrid_fund_advances_status ON hybrid_fund_advances(repayment_status);

COMMENT ON TABLE hybrid_fund_advances IS 'Tạm ứng quỹ khi doanh nghiệp chậm thanh toán';

-- 7.8 Disbursements (Thực tế giải ngân)
CREATE TABLE disbursements (
    id BIGSERIAL PRIMARY KEY,
    
    -- Reference
    reference_type disbursement_reference_enum NOT NULL,
    reference_id BIGINT NOT NULL,
    
    -- Recipient
    recipient_type recipient_type_enum NOT NULL,
    recipient_id BIGINT,
    
    -- Amount
    amount DECIMAL(15,2) NOT NULL,
    currency VARCHAR(10) DEFAULT 'VND',
    
    -- Payment Method
    payment_method payment_method_enum NOT NULL,
    
    -- Bank Details (if applicable)
    bank_name VARCHAR(100),
    bank_account_number VARCHAR(50),
    bank_account_name VARCHAR(255),
    
    -- Transaction
    transaction_reference VARCHAR(100),
    transaction_date TIMESTAMP,
    
    -- Status
    status fund_distribution_status_enum DEFAULT 'PENDING',
    
    -- Processing
    processed_by BIGINT REFERENCES users(id) ON DELETE SET NULL,
    processed_at TIMESTAMP,
    
    -- Notes
    note TEXT,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_disbursements_reference ON disbursements(reference_type, reference_id);
CREATE INDEX idx_disbursements_recipient ON disbursements(recipient_type, recipient_id);
CREATE INDEX idx_disbursements_status ON disbursements(status);

COMMENT ON TABLE disbursements IS 'Giải ngân thực tế cho các bên';

-- =====================================================
-- 8. REPORT & EVALUATION MODULE
-- =====================================================

-- 8.1 Mentor reports
CREATE TABLE mentor_reports (
    id BIGSERIAL PRIMARY KEY,
    project_id BIGINT NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
    mentor_id BIGINT NOT NULL REFERENCES mentors(id) ON DELETE CASCADE,
    
    -- Report Info
    report_type report_type_enum NOT NULL,
    reporting_period VARCHAR(7) NOT NULL, -- YYYY-MM
    
    -- Progress
    project_progress JSONB NOT NULL, -- {overallCompletion, plannedCompletion, variance, status}
    
    -- Tasks
    tasks_completed JSONB,
    tasks_upcoming JSONB,
    
    -- Team
    team_performance JSONB,
    
    -- Details
    achievements JSONB,
    challenges JSONB,
    risks JSONB,
    next_month_goals JSONB,
    
    -- Budget
    budget_usage JSONB,
    
    -- Metrics
    meetings_held INTEGER,
    code_metrics JSONB,
    
    -- Status
    status report_status_enum DEFAULT 'DRAFT',
    submitted_at TIMESTAMP,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    UNIQUE(project_id, reporting_period)
);

CREATE INDEX idx_mentor_reports_project ON mentor_reports(project_id);
CREATE INDEX idx_mentor_reports_mentor ON mentor_reports(mentor_id);
CREATE INDEX idx_mentor_reports_period ON mentor_reports(reporting_period);

COMMENT ON TABLE mentor_reports IS 'Báo cáo của Mentor';

-- 8.2 Team reports
CREATE TABLE team_reports (
    id BIGSERIAL PRIMARY KEY,
    project_id BIGINT NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
    submitted_by BIGINT NOT NULL REFERENCES talents(id) ON DELETE CASCADE, -- Talent Leader
    
    -- Report Info
    report_type report_type_enum NOT NULL,
    reporting_period VARCHAR(7) NOT NULL,
    overall_progress INTEGER CHECK (overall_progress BETWEEN 0 AND 100),
    
    -- Tasks
    tasks_completed JSONB,
    tasks_in_progress JSONB,
    
    -- Issues & Plans
    issues JSONB,
    next_month_plan JSONB,
    
    -- Performance
    team_performance JSONB,
    
    -- Status
    status report_status_enum DEFAULT 'DRAFT',
    submitted_at TIMESTAMP,
    
    -- Review
    reviewed_by BIGINT REFERENCES mentors(id) ON DELETE SET NULL,
    reviewed_at TIMESTAMP,
    review_comment TEXT,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    UNIQUE(project_id, reporting_period)
);

CREATE INDEX idx_team_reports_project ON team_reports(project_id);
CREATE INDEX idx_team_reports_submitted ON team_reports(submitted_by);

COMMENT ON TABLE team_reports IS 'Báo cáo của Talent Leader';

-- 8.3 Report attachments
CREATE TABLE report_attachments (
    id BIGSERIAL PRIMARY KEY,
    
    -- Reference (can be mentor_report or team_report)
    report_type VARCHAR(20) NOT NULL, -- MENTOR_REPORT, TEAM_REPORT
    report_id BIGINT NOT NULL,
    
    -- File reference (centralized)
    file_id BIGINT, -- References files table
    
    uploaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT check_report_type CHECK (report_type IN ('MENTOR_REPORT', 'TEAM_REPORT'))
);

CREATE INDEX idx_report_attachments_report ON report_attachments(report_type, report_id);

-- 8.4 Talent evaluations
CREATE TABLE talent_evaluations (
    id BIGSERIAL PRIMARY KEY,
    project_id BIGINT NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
    talent_id BIGINT NOT NULL REFERENCES talents(id) ON DELETE CASCADE,
    mentor_id BIGINT NOT NULL REFERENCES mentors(id) ON DELETE CASCADE,
    
    -- Period
    evaluation_period VARCHAR(7) NOT NULL, -- YYYY-MM
    
    -- Scores (0-10)
    overall_score DECIMAL(3,1) CHECK (overall_score BETWEEN 0 AND 10),
    
    -- Criteria
    technical_skills JSONB, -- {score, comment}
    problem_solving JSONB,
    teamwork JSONB,
    communication JSONB,
    code_quality JSONB,
    punctuality JSONB,
    
    -- Feedback
    strengths JSONB,
    weaknesses JSONB,
    recommendations JSONB,
    
    -- Performance Data
    tasks_completed INTEGER,
    tasks_total INTEGER,
    hours_worked INTEGER,
    
    -- Grade
    grade evaluation_grade_enum,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    UNIQUE(project_id, talent_id, evaluation_period)
);

CREATE INDEX idx_talent_evaluations_talent ON talent_evaluations(talent_id);
CREATE INDEX idx_talent_evaluations_project ON talent_evaluations(project_id);
CREATE INDEX idx_talent_evaluations_period ON talent_evaluations(evaluation_period);

COMMENT ON TABLE talent_evaluations IS 'Đánh giá sinh viên bởi Mentor';

-- 8.5 Enterprise feedback
CREATE TABLE enterprise_feedback (
    id BIGSERIAL PRIMARY KEY,
    project_id BIGINT NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
    enterprise_id BIGINT NOT NULL REFERENCES enterprises(id) ON DELETE CASCADE,
    
    -- Overall Rating
    overall_rating DECIMAL(3,2) CHECK (overall_rating BETWEEN 0 AND 5),
    
    -- Specific Ratings
    quality_rating DECIMAL(3,2),
    communication_rating DECIMAL(3,2),
    timeline_rating DECIMAL(3,2),
    professionalism_rating DECIMAL(3,2),
    
    -- Feedback
    positive_feedback TEXT,
    negative_feedback TEXT,
    suggestions TEXT,
    
    -- Recommendation
    would_recommend BOOLEAN,
    would_work_again BOOLEAN,
    
    -- Status
    status report_status_enum DEFAULT 'DRAFT',
    submitted_at TIMESTAMP,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_enterprise_feedback_project ON enterprise_feedback(project_id);
CREATE INDEX idx_enterprise_feedback_enterprise ON enterprise_feedback(enterprise_id);

COMMENT ON TABLE enterprise_feedback IS 'Đánh giá của doanh nghiệp về dự án';

-- 8.6 Transparency reports
CREATE TABLE transparency_reports (
    id BIGSERIAL PRIMARY KEY,
    
    -- Report Info
    report_type report_type_enum NOT NULL,
    period VARCHAR(7) NOT NULL, -- YYYY-MM
    
    -- Statistics
    statistics JSONB NOT NULL,
    charts_data JSONB,
    
    -- Publication
    publish_note TEXT,
    status report_status_enum DEFAULT 'DRAFT',
    
    -- URLs
    public_url VARCHAR(500),
    pdf_url VARCHAR(500),
    
    -- Audit
    created_by BIGINT REFERENCES users(id) ON DELETE SET NULL,
    published_at TIMESTAMP,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    UNIQUE(period)
);

CREATE INDEX idx_transparency_reports_period ON transparency_reports(period);
CREATE INDEX idx_transparency_reports_status ON transparency_reports(status);

COMMENT ON TABLE transparency_reports IS 'Báo cáo minh bạch công khai';

-- =====================================================
-- FOREIGN KEY CONSTRAINTS FOR CENTRALIZED FILE MANAGEMENT
-- (To be added after files table is created in V1_3 migration)
-- =====================================================

-- Note: These constraints will be added in V1_3__Centralized_File_Management.sql
-- after the files table is created:
--
-- ALTER TABLE task_attachments ADD CONSTRAINT fk_task_attachments_file 
--     FOREIGN KEY (file_id) REFERENCES files(id) ON DELETE CASCADE;
--
-- ALTER TABLE report_attachments ADD CONSTRAINT fk_report_attachments_file 
--     FOREIGN KEY (file_id) REFERENCES files(id) ON DELETE CASCADE;

-- =====================================================
-- END OF TASKS, PAYMENT, REPORTS MODULE
-- =====================================================
