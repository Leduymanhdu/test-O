-- =====================================================
-- LabODC UTH — Clean Database Schema
-- Chỉ gồm các table đang được sử dụng trong code
-- =====================================================

-- Xoá nếu đã tồn tại (reset sạch)
DROP SCHEMA IF EXISTS public CASCADE;
CREATE SCHEMA public;

-- =====================================================
-- ENUMS
-- =====================================================

CREATE TYPE user_role_enum AS ENUM (
    'SYSTEM_ADMIN', 'LAB_ADMIN', 'ENTERPRISE', 'TALENT', 'TALENT_LEADER', 'MENTOR'
);

CREATE TYPE user_status_enum AS ENUM (
    'PENDING', 'ACTIVE', 'INACTIVE', 'LOCKED', 'SUSPENDED'
);

CREATE TYPE enterprise_status_enum AS ENUM (
    'PENDING', 'APPROVED', 'REJECTED'
);

CREATE TYPE invitation_status_enum AS ENUM (
    'PENDING', 'ACCEPTED', 'REJECTED', 'EXPIRED'
);

CREATE TYPE proficiency_level_enum AS ENUM (
    'BEGINNER', 'INTERMEDIATE', 'ADVANCED', 'EXPERT'
);

CREATE TYPE project_status_enum AS ENUM (
    'DRAFT', 'PENDING_VALIDATION', 'VALIDATED', 'REJECTED',
    'RECRUITING', 'IN_PROGRESS', 'ON_HOLD', 'COMPLETED', 'CANCELLED', 'ARCHIVED'
);

CREATE TYPE project_member_role_enum AS ENUM ('MEMBER', 'LEADER');

CREATE TYPE project_member_status_enum AS ENUM ('ACTIVE', 'LEFT', 'REMOVED');

CREATE TYPE payment_status_enum AS ENUM (
    'PENDING', 'PROCESSING', 'COMPLETED', 'FAILED', 'CANCELLED', 'REFUNDED', 'EXPIRED'
);

CREATE TYPE fund_allocation_status_enum AS ENUM (
    'ALLOCATED', 'DISTRIBUTED', 'COMPLETED'
);

CREATE TYPE fund_distribution_status_enum AS ENUM (
    'PENDING', 'PROCESSING', 'COMPLETED', 'FAILED', 'ON_HOLD'
);

CREATE TYPE team_fund_status_enum AS ENUM (
    'DRAFT', 'SUBMITTED', 'APPROVED_BY_MENTOR', 'APPROVED_BY_LAB', 'REJECTED', 'DISBURSED'
);

CREATE TYPE recipient_type_enum AS ENUM ('TEAM', 'MENTOR', 'LAB', 'TALENT');

CREATE TYPE advance_reason_enum AS ENUM ('PAYMENT_DELAY', 'EMERGENCY', 'OTHER');

CREATE TYPE repayment_status_enum AS ENUM (
    'OUTSTANDING', 'PARTIALLY_REPAID', 'FULLY_REPAID'
);

CREATE TYPE report_status_enum AS ENUM (
    'DRAFT', 'SUBMITTED', 'REVIEWED', 'PUBLISHED', 'ARCHIVED'
);

CREATE TYPE report_type_enum AS ENUM (
    'WEEKLY', 'MONTHLY', 'MILESTONE', 'FINAL', 'QUARTERLY', 'ANNUAL'
);

CREATE TYPE evaluation_grade_enum AS ENUM ('A', 'B', 'C', 'D', 'F');

-- =====================================================
-- 1. USERS
-- =====================================================

CREATE TABLE users (
    id          BIGSERIAL PRIMARY KEY,
    email       VARCHAR(255) NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    role        user_role_enum NOT NULL,
    status      user_status_enum NOT NULL DEFAULT 'PENDING',
    email_verified          BOOLEAN DEFAULT FALSE,
    email_verified_at       TIMESTAMP,
    verification_token      VARCHAR(255),
    phone                   VARCHAR(20),
    failed_login_attempts   INTEGER DEFAULT 0,
    locked_until            TIMESTAMP,
    last_login_at           TIMESTAMP,
    avatar_url              VARCHAR(500),           -- lưu URL trực tiếp thay vì FK files
    timezone                VARCHAR(50) DEFAULT 'Asia/Ho_Chi_Minh',
    language                VARCHAR(10) DEFAULT 'vi',
    created_at              TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at              TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    deleted_at              TIMESTAMP,
    CONSTRAINT check_email_format CHECK (email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$')
);

CREATE UNIQUE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_role   ON users(role);
CREATE INDEX idx_users_status ON users(status);

-- =====================================================
-- 2. ENTERPRISES
-- =====================================================

CREATE TABLE enterprises (
    id                      BIGSERIAL PRIMARY KEY,
    user_id                 BIGINT NOT NULL UNIQUE REFERENCES users(id) ON DELETE CASCADE,
    company_name            VARCHAR(255) NOT NULL,
    tax_code                VARCHAR(20)  NOT NULL UNIQUE,
    business_license_number VARCHAR(50),
    address                 TEXT,
    city                    VARCHAR(100),
    district                VARCHAR(100),
    ward                    VARCHAR(100),
    representative_name     VARCHAR(255) NOT NULL,
    representative_position VARCHAR(100),
    contact_email           VARCHAR(255),
    contact_phone           VARCHAR(20),
    website                 VARCHAR(255),
    industry                VARCHAR(100),
    company_size            VARCHAR(50),
    year_established        INTEGER,
    description             TEXT,
    logo_url                VARCHAR(500),           -- URL trực tiếp thay vì FK files
    status                  enterprise_status_enum NOT NULL DEFAULT 'PENDING',
    verified_at             TIMESTAMP,
    verified_by             BIGINT REFERENCES users(id) ON DELETE SET NULL,
    verification_note       TEXT,
    rating_average          NUMERIC(3,2) DEFAULT 0.00,
    total_projects          INTEGER DEFAULT 0,
    successful_projects     INTEGER DEFAULT 0,
    created_at              TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at              TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    deleted_at              TIMESTAMP,
    CONSTRAINT check_tax_code  CHECK (tax_code ~* '^[0-9]{10,13}$'),
    CONSTRAINT check_rating    CHECK (rating_average >= 0 AND rating_average <= 5)
);

CREATE INDEX idx_enterprises_status  ON enterprises(status);
CREATE INDEX idx_enterprises_user_id ON enterprises(user_id);

-- =====================================================
-- 3. ENTERPRISE REJECTIONS
-- =====================================================

CREATE TABLE enterprise_rejections (
    id               BIGSERIAL PRIMARY KEY,
    enterprise_id    BIGINT REFERENCES enterprises(id) ON DELETE SET NULL,
    rejected_by      BIGINT NOT NULL REFERENCES users(id) ON DELETE SET NULL,
    rejection_reason TEXT,
    rejected_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    company_name     VARCHAR(255),
    tax_code         VARCHAR(50),
    contact_email    VARCHAR(255)
);

-- =====================================================
-- 4. MENTORS
-- =====================================================

CREATE TABLE mentors (
    id                      BIGSERIAL PRIMARY KEY,
    user_id                 BIGINT NOT NULL UNIQUE REFERENCES users(id) ON DELETE RESTRICT,
    full_name               VARCHAR(255) NOT NULL,
    title                   VARCHAR(100),
    bio                     TEXT,
    years_of_experience     INTEGER,
    current_position        VARCHAR(255),
    current_company         VARCHAR(255),
    specialization          TEXT,
    industries              JSONB,
    linkedin_url            VARCHAR(500),
    github_url              VARCHAR(500),
    personal_website        VARCHAR(500),
    max_concurrent_projects INTEGER DEFAULT 3,
    current_projects_count  INTEGER DEFAULT 0,
    hours_per_week_available INTEGER,
    hourly_rate             NUMERIC(10,2),
    preferred_payment_method VARCHAR(50),
    bank_account_info       JSONB,
    rating_average          NUMERIC(3,2) DEFAULT 0.00,
    total_projects          INTEGER DEFAULT 0,
    total_students_mentored INTEGER DEFAULT 0,
    available               BOOLEAN DEFAULT TRUE,
    created_at              TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at              TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    deleted_at              TIMESTAMP,
    CONSTRAINT check_rating CHECK (rating_average >= 0 AND rating_average <= 5)
);

CREATE INDEX idx_mentors_available ON mentors(available);

-- =====================================================
-- 5. MENTOR EXPERTISE
-- =====================================================

CREATE TABLE mentor_expertise (
    id                  BIGSERIAL PRIMARY KEY,
    mentor_id           BIGINT NOT NULL REFERENCES mentors(id) ON DELETE CASCADE,
    skill_name          VARCHAR(100) NOT NULL,
    skill_category      VARCHAR(50),
    proficiency_level   proficiency_level_enum NOT NULL,
    years_of_experience NUMERIC(4,1),
    can_teach           BOOLEAN DEFAULT TRUE,
    created_at          TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (mentor_id, skill_name),
    CONSTRAINT check_mentor_proficiency CHECK (
        proficiency_level IN ('INTERMEDIATE', 'ADVANCED', 'EXPERT')
    )
);

-- =====================================================
-- 6. TALENTS
-- =====================================================

CREATE TABLE talents (
    id                      BIGSERIAL PRIMARY KEY,
    user_id                 BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    full_name               VARCHAR(255) NOT NULL,
    student_id              VARCHAR(20)  NOT NULL,
    date_of_birth           DATE,
    gender                  VARCHAR(10),
    faculty                 VARCHAR(100),
    major                   VARCHAR(100),
    year_of_study           INTEGER,
    gpa                     NUMERIC(3,2),
    expected_graduation     DATE,
    address                 TEXT,
    city                    VARCHAR(100),
    emergency_contact       VARCHAR(20),
    emergency_contact_name  VARCHAR(255),
    bio                     TEXT,
    portfolio_url           VARCHAR(500),
    github_url              VARCHAR(500),
    linkedin_url            VARCHAR(500),
    cv_url                  VARCHAR(500),           -- URL trực tiếp thay vì FK files
    career_goals            TEXT,
    preferred_technologies  JSONB,
    work_availability       VARCHAR(50),
    hours_per_week          INTEGER,
    rating_average          NUMERIC(3,2) DEFAULT 0.00,
    total_projects          INTEGER DEFAULT 0,
    completed_projects      INTEGER DEFAULT 0,
    total_tasks_completed   INTEGER DEFAULT 0,
    available_for_projects  BOOLEAN DEFAULT TRUE,
    created_at              TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at              TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    deleted_at              TIMESTAMP,
    CONSTRAINT check_gpa           CHECK (gpa >= 0 AND gpa <= 4.0),
    CONSTRAINT check_rating        CHECK (rating_average >= 0 AND rating_average <= 10),
    CONSTRAINT check_year_of_study CHECK (year_of_study >= 1 AND year_of_study <= 6)
);

CREATE INDEX idx_talents_user_id    ON talents(user_id);
CREATE INDEX idx_talents_student_id ON talents(student_id);
CREATE INDEX idx_talents_available  ON talents(available_for_projects);

-- =====================================================
-- 7. TALENT SKILLS
-- =====================================================

CREATE TABLE talent_skills (
    id                  BIGSERIAL PRIMARY KEY,
    talent_id           BIGINT NOT NULL REFERENCES talents(id) ON DELETE CASCADE,
    skill_name          VARCHAR(100) NOT NULL,
    skill_category      VARCHAR(50),
    proficiency_level   proficiency_level_enum NOT NULL,
    years_of_experience NUMERIC(3,1),
    last_used_date      DATE,
    verified            BOOLEAN DEFAULT FALSE,
    verified_by         BIGINT REFERENCES users(id) ON DELETE SET NULL,
    verified_at         TIMESTAMP,
    created_at          TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at          TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (talent_id, skill_name)
);

-- =====================================================
-- 8. TALENT CERTIFICATIONS
-- =====================================================

CREATE TABLE talent_certifications (
    id                  BIGSERIAL PRIMARY KEY,
    talent_id           BIGINT NOT NULL REFERENCES talents(id) ON DELETE CASCADE,
    name                VARCHAR(255) NOT NULL,
    issuer              VARCHAR(255),
    credential_id       VARCHAR(100),
    credential_url      VARCHAR(500),
    issue_date          DATE NOT NULL,
    expiry_date         DATE,
    certificate_url     VARCHAR(500),           -- URL trực tiếp thay vì FK files
    description         TEXT,
    created_at          TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at          TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- =====================================================
-- 9. PROJECTS
-- =====================================================

CREATE TABLE projects (
    id                      BIGSERIAL PRIMARY KEY,
    enterprise_id           BIGINT NOT NULL REFERENCES enterprises(id) ON DELETE CASCADE,
    mentor_id               BIGINT REFERENCES mentors(id) ON DELETE SET NULL,
    title                   VARCHAR(255) NOT NULL,
    slug                    VARCHAR(255) NOT NULL UNIQUE,
    description             TEXT NOT NULL,
    objectives              JSONB,
    requirements            TEXT,
    start_date              DATE NOT NULL,
    end_date                DATE NOT NULL,
    actual_start_date       DATE,
    actual_end_date         DATE,
    budget                  NUMERIC(15,2) NOT NULL,
    currency                VARCHAR(10) DEFAULT 'VND',
    number_of_students      INTEGER NOT NULL,
    current_members_count   INTEGER DEFAULT 0,
    status                  project_status_enum NOT NULL DEFAULT 'DRAFT',
    validated               VARCHAR(20) NOT NULL DEFAULT 'pending',
    progress_percentage     INTEGER DEFAULT 0,
    validated_at            TIMESTAMP,
    validated_by            BIGINT REFERENCES users(id),
    validation_note         TEXT,
    rejection_reason        TEXT,
    is_public               BOOLEAN DEFAULT TRUE,
    allow_applications      BOOLEAN DEFAULT TRUE,
    published_at            TIMESTAMP,
    created_at              TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at              TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    deleted_at              TIMESTAMP,
    CONSTRAINT check_budget          CHECK (budget > 0),
    CONSTRAINT check_dates           CHECK (end_date > start_date),
    CONSTRAINT check_progress        CHECK (progress_percentage >= 0 AND progress_percentage <= 100),
    CONSTRAINT check_students        CHECK (number_of_students >= 3 AND number_of_students <= 10),
    CONSTRAINT check_validation_status CHECK (validated IN ('pending', 'approved', 'rejected'))
);

CREATE INDEX idx_projects_enterprise ON projects(enterprise_id);
CREATE INDEX idx_projects_mentor     ON projects(mentor_id);
CREATE INDEX idx_projects_status     ON projects(status);
CREATE INDEX idx_projects_deleted    ON projects(deleted_at) WHERE deleted_at IS NULL;

-- =====================================================
-- 10. PROJECT MEMBERS
-- =====================================================

CREATE TABLE project_members (
    id              BIGSERIAL PRIMARY KEY,
    project_id      BIGINT NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
    talent_id       BIGINT NOT NULL REFERENCES talents(id) ON DELETE CASCADE,
    role            project_member_role_enum DEFAULT 'MEMBER',
    status          project_member_status_enum DEFAULT 'ACTIVE',
    join_message    TEXT,
    joined_at       TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    left_at         TIMESTAMP,
    tasks_assigned  INTEGER DEFAULT 0,
    tasks_completed INTEGER DEFAULT 0,
    hours_contributed INTEGER DEFAULT 0,
    approved_by     BIGINT,
    approved_at     TIMESTAMP,
    created_at      TIMESTAMP DEFAULT now(),
    updated_at      TIMESTAMP DEFAULT now(),
    UNIQUE (project_id, talent_id)
);

CREATE INDEX idx_project_members_project ON project_members(project_id);
CREATE INDEX idx_project_members_talent  ON project_members(talent_id);
CREATE INDEX idx_project_members_status  ON project_members(status);

-- =====================================================
-- 11. PROJECT SKILL REQUIREMENTS
-- =====================================================

CREATE TABLE project_skill_requirements (
    id                BIGSERIAL PRIMARY KEY,
    project_id        BIGINT NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
    skill_name        VARCHAR(100) NOT NULL,
    proficiency_level proficiency_level_enum NOT NULL,
    is_required       BOOLEAN DEFAULT TRUE,
    priority          INTEGER DEFAULT 0,
    created_at        TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (project_id, skill_name)
);

-- =====================================================
-- 12. PROJECT TECHNOLOGIES
-- =====================================================

CREATE TABLE project_technologies (
    id               BIGSERIAL PRIMARY KEY,
    project_id       BIGINT NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
    technology_name  VARCHAR(100) NOT NULL,
    technology_type  VARCHAR(50),
    is_required      BOOLEAN DEFAULT TRUE,
    created_at       TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (project_id, technology_name)
);

-- =====================================================
-- 13. PROJECT REJECTIONS
-- =====================================================

CREATE TABLE project_rejections (
    id               BIGSERIAL PRIMARY KEY,
    project_id       BIGINT REFERENCES projects(id) ON DELETE SET NULL,
    rejected_by      BIGINT NOT NULL REFERENCES users(id) ON DELETE SET NULL,
    rejection_reason TEXT,
    rejected_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    title            VARCHAR(255),
    slug             VARCHAR(255),
    enterprise_name  VARCHAR(255)
);

-- =====================================================
-- 14. MENTOR INVITATIONS
-- =====================================================

CREATE TABLE mentor_invitations (
    id                    BIGSERIAL PRIMARY KEY,
    project_id            BIGINT NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
    mentor_id             BIGINT NOT NULL REFERENCES mentors(id) ON DELETE CASCADE,
    invited_by            BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    invitation_message    TEXT,
    compensation_amount   NUMERIC(15,2),
    expected_effort_hours INTEGER,
    status                invitation_status_enum DEFAULT 'PENDING',
    response_message      TEXT,
    responded_at          TIMESTAMP,
    availability_info     JSONB,
    expires_at            TIMESTAMP NOT NULL,
    created_at            TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_mentor_invitations_mentor  ON mentor_invitations(mentor_id);
CREATE INDEX idx_mentor_invitations_status  ON mentor_invitations(status);
CREATE INDEX idx_mentor_invitations_project ON mentor_invitations(project_id);

-- =====================================================
-- 15. MENTOR TASKS
-- =====================================================

CREATE TABLE mentor_tasks (
    id           BIGSERIAL PRIMARY KEY,
    mentor_id    BIGINT NOT NULL REFERENCES mentors(id) ON DELETE CASCADE,
    project_id   BIGINT REFERENCES projects(id) ON DELETE SET NULL,
    title        VARCHAR(255) NOT NULL,
    description  TEXT,
    status       VARCHAR(50) NOT NULL DEFAULT 'pending',
    progress     INTEGER NOT NULL DEFAULT 0,
    assigned_to  JSONB DEFAULT '[]',
    due_date     DATE,
    priority     VARCHAR(50) NOT NULL DEFAULT 'medium',
    project_name VARCHAR(255),
    created_at   TIMESTAMP NOT NULL DEFAULT now(),
    updated_at   TIMESTAMP NOT NULL DEFAULT now()
);

CREATE INDEX idx_mentor_tasks_mentor  ON mentor_tasks(mentor_id);
CREATE INDEX idx_mentor_tasks_project ON mentor_tasks(project_id);

-- =====================================================
-- 16. MENTOR TASK SUBMISSIONS
-- =====================================================

CREATE TABLE mentor_task_submissions (
    id           BIGSERIAL PRIMARY KEY,
    task_id      BIGINT NOT NULL REFERENCES mentor_tasks(id) ON DELETE CASCADE,
    talent_id    BIGINT NOT NULL REFERENCES talents(id) ON DELETE CASCADE,
    file_name    VARCHAR(255) NOT NULL,
    file_path    VARCHAR(500) NOT NULL,
    file_size    BIGINT,
    submitted_at TIMESTAMP DEFAULT now()
);

-- =====================================================
-- 17. MENTOR REPORTS
-- =====================================================

CREATE TABLE mentor_reports (
    id                BIGSERIAL PRIMARY KEY,
    project_id        BIGINT NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
    mentor_id         BIGINT NOT NULL REFERENCES mentors(id) ON DELETE CASCADE,
    report_type       report_type_enum NOT NULL,
    reporting_period  VARCHAR(7) NOT NULL,
    project_progress  JSONB NOT NULL,
    tasks_completed   JSONB,
    tasks_upcoming    JSONB,
    team_performance  JSONB,
    achievements      JSONB,
    challenges        JSONB,
    risks             JSONB,
    next_month_goals  JSONB,
    budget_usage      JSONB,
    meetings_held     INTEGER,
    code_metrics      JSONB,
    status            report_status_enum DEFAULT 'DRAFT',
    submitted_at      TIMESTAMP,
    created_at        TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at        TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (project_id, reporting_period)
);

-- =====================================================
-- 18. TALENT EVALUATIONS
-- =====================================================

CREATE TABLE talent_evaluations (
    id                BIGSERIAL PRIMARY KEY,
    project_id        BIGINT NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
    talent_id         BIGINT NOT NULL REFERENCES talents(id) ON DELETE CASCADE,
    mentor_id         BIGINT NOT NULL REFERENCES mentors(id) ON DELETE CASCADE,
    evaluation_period VARCHAR(7) NOT NULL,
    overall_score     NUMERIC(3,1),
    technical_skills  JSONB,
    problem_solving   JSONB,
    teamwork          JSONB,
    communication     JSONB,
    code_quality      JSONB,
    punctuality       JSONB,
    strengths         JSONB,
    weaknesses        JSONB,
    recommendations   JSONB,
    tasks_completed   INTEGER,
    tasks_total       INTEGER,
    hours_worked      INTEGER,
    grade             evaluation_grade_enum,
    created_at        TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (project_id, talent_id, evaluation_period),
    CONSTRAINT check_score CHECK (overall_score >= 0 AND overall_score <= 10)
);

-- =====================================================
-- 19. ENTERPRISE FEEDBACK
-- =====================================================

CREATE TABLE enterprise_feedback (
    id                       BIGSERIAL PRIMARY KEY,
    project_id               BIGINT NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
    enterprise_id            BIGINT NOT NULL REFERENCES enterprises(id) ON DELETE CASCADE,
    overall_rating           NUMERIC(3,2),
    quality_rating           NUMERIC(3,2),
    communication_rating     NUMERIC(3,2),
    timeline_rating          NUMERIC(3,2),
    professionalism_rating   NUMERIC(3,2),
    positive_feedback        TEXT,
    negative_feedback        TEXT,
    suggestions              TEXT,
    would_recommend          BOOLEAN,
    would_work_again         BOOLEAN,
    status                   report_status_enum DEFAULT 'DRAFT',
    submitted_at             TIMESTAMP,
    created_at               TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT check_overall_rating CHECK (overall_rating >= 0 AND overall_rating <= 5)
);

-- =====================================================
-- 20. PAYMENTS
-- =====================================================

CREATE TABLE payments (
    id                    BIGSERIAL PRIMARY KEY,
    project_id            BIGINT NOT NULL REFERENCES projects(id) ON DELETE RESTRICT,
    enterprise_id         BIGINT NOT NULL REFERENCES enterprises(id) ON DELETE RESTRICT,
    payment_code          VARCHAR(50) NOT NULL UNIQUE,
    amount                NUMERIC(15,2) NOT NULL,
    currency              VARCHAR(10) DEFAULT 'VND',
    payos_order_id        VARCHAR(100) UNIQUE,
    payos_transaction_id  VARCHAR(100),
    payos_payment_link    VARCHAR(500),
    status                payment_status_enum NOT NULL DEFAULT 'PENDING',
    payment_method        VARCHAR(50),
    description           TEXT,
    note                  TEXT,
    payment_link_expires_at TIMESTAMP,
    paid_at               TIMESTAMP,
    created_at            TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT check_amount CHECK (amount > 0)
);

CREATE INDEX idx_payments_project    ON payments(project_id);
CREATE INDEX idx_payments_enterprise ON payments(enterprise_id);
CREATE INDEX idx_payments_status     ON payments(status);

-- =====================================================
-- 21. FUND ALLOCATIONS
-- =====================================================

CREATE TABLE fund_allocations (
    id                BIGSERIAL PRIMARY KEY,
    project_id        BIGINT NOT NULL UNIQUE REFERENCES projects(id) ON DELETE RESTRICT,
    payment_id        BIGINT NOT NULL REFERENCES payments(id) ON DELETE RESTRICT,
    total_amount      NUMERIC(15,2) NOT NULL,
    team_percentage   NUMERIC(5,2) DEFAULT 70.00,
    team_amount       NUMERIC(15,2) NOT NULL,
    mentor_percentage NUMERIC(5,2) DEFAULT 20.00,
    mentor_amount     NUMERIC(15,2) NOT NULL,
    lab_percentage    NUMERIC(5,2) DEFAULT 10.00,
    lab_amount        NUMERIC(15,2) NOT NULL,
    status            fund_allocation_status_enum DEFAULT 'ALLOCATED',
    validated_by      BIGINT REFERENCES users(id) ON DELETE SET NULL,
    validated_at      TIMESTAMP,
    created_at        TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT check_percentages CHECK (team_percentage + mentor_percentage + lab_percentage = 100),
    CONSTRAINT check_amounts     CHECK (team_amount + mentor_amount + lab_amount = total_amount)
);

-- =====================================================
-- 22. FUND DISTRIBUTIONS
-- =====================================================

CREATE TABLE fund_distributions (
    id                    BIGSERIAL PRIMARY KEY,
    allocation_id         BIGINT NOT NULL REFERENCES fund_allocations(id) ON DELETE RESTRICT,
    recipient_type        recipient_type_enum NOT NULL,
    recipient_id          BIGINT,
    amount                NUMERIC(15,2) NOT NULL,
    status                fund_distribution_status_enum DEFAULT 'PENDING',
    disbursed_at          TIMESTAMP,
    disbursed_by          BIGINT REFERENCES users(id) ON DELETE SET NULL,
    payment_method        VARCHAR(50),
    transaction_reference VARCHAR(100),
    created_at            TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- =====================================================
-- 23. HYBRID FUND ADVANCES
-- =====================================================

CREATE TABLE hybrid_fund_advances (
    id                      BIGSERIAL PRIMARY KEY,
    project_id              BIGINT NOT NULL REFERENCES projects(id) ON DELETE RESTRICT,
    payment_id              BIGINT NOT NULL REFERENCES payments(id) ON DELETE RESTRICT,
    advance_reason          advance_reason_enum NOT NULL,
    advance_amount          NUMERIC(15,2) NOT NULL,
    advanced_at             TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    expected_repayment_date DATE NOT NULL,
    repayment_status        repayment_status_enum DEFAULT 'OUTSTANDING',
    repaid_amount           NUMERIC(15,2) DEFAULT 0,
    repaid_at               TIMESTAMP,
    approved_by             BIGINT NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
    approval_note           TEXT
);

-- =====================================================
-- 24. TEAM FUND DISTRIBUTIONS
-- =====================================================

CREATE TABLE team_fund_distributions (
    id                    BIGSERIAL PRIMARY KEY,
    project_id            BIGINT NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
    allocation_id         BIGINT NOT NULL REFERENCES fund_allocations(id) ON DELETE RESTRICT,
    submitted_by          BIGINT NOT NULL,
    total_team_amount     NUMERIC(15,2) NOT NULL,
    status                team_fund_status_enum DEFAULT 'DRAFT',
    approved_by_mentor    BIGINT,
    approved_by_mentor_at TIMESTAMP,
    approved_by_lab       BIGINT,
    approved_by_lab_at    TIMESTAMP,
    rejection_reason      TEXT,
    created_at            TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at            TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- =====================================================
-- 25. TEAM MEMBER ALLOCATIONS
-- =====================================================

CREATE TABLE team_member_allocations (
    id                BIGSERIAL PRIMARY KEY,
    distribution_id   BIGINT NOT NULL REFERENCES team_fund_distributions(id) ON DELETE CASCADE,
    talent_id         BIGINT NOT NULL REFERENCES talents(id) ON DELETE CASCADE,
    percentage        NUMERIC(5,2) NOT NULL,
    amount            NUMERIC(15,2) NOT NULL,
    reason            TEXT,
    tasks_completed   INTEGER,
    hours_contributed INTEGER,
    performance_score NUMERIC(3,2),
    created_at        TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT check_percentage CHECK (percentage >= 5 AND percentage <= 100)
);

-- =====================================================
-- 26. TRANSPARENCY REPORTS
-- =====================================================

CREATE TABLE transparency_reports (
    id           BIGSERIAL PRIMARY KEY,
    report_type  report_type_enum NOT NULL,
    period       VARCHAR(7) NOT NULL,
    statistics   JSONB NOT NULL,
    charts_data  JSONB,
    publish_note TEXT,
    status       report_status_enum DEFAULT 'DRAFT',
    public_url   VARCHAR(500),
    pdf_url      VARCHAR(500),
    created_by   BIGINT REFERENCES users(id) ON DELETE SET NULL,
    published_at TIMESTAMP,
    created_at   TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- =====================================================
-- AUTO-UPDATE updated_at TRIGGER
-- =====================================================

CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_users_updated_at               BEFORE UPDATE ON users               FOR EACH ROW EXECUTE FUNCTION update_updated_at();
CREATE TRIGGER trg_enterprises_updated_at          BEFORE UPDATE ON enterprises          FOR EACH ROW EXECUTE FUNCTION update_updated_at();
CREATE TRIGGER trg_mentors_updated_at              BEFORE UPDATE ON mentors              FOR EACH ROW EXECUTE FUNCTION update_updated_at();
CREATE TRIGGER trg_talents_updated_at              BEFORE UPDATE ON talents              FOR EACH ROW EXECUTE FUNCTION update_updated_at();
CREATE TRIGGER trg_projects_updated_at             BEFORE UPDATE ON projects             FOR EACH ROW EXECUTE FUNCTION update_updated_at();
CREATE TRIGGER trg_project_members_updated_at      BEFORE UPDATE ON project_members      FOR EACH ROW EXECUTE FUNCTION update_updated_at();
CREATE TRIGGER trg_talent_skills_updated_at        BEFORE UPDATE ON talent_skills        FOR EACH ROW EXECUTE FUNCTION update_updated_at();
CREATE TRIGGER trg_talent_certifications_updated_at BEFORE UPDATE ON talent_certifications FOR EACH ROW EXECUTE FUNCTION update_updated_at();
CREATE TRIGGER trg_mentor_tasks_updated_at         BEFORE UPDATE ON mentor_tasks         FOR EACH ROW EXECUTE FUNCTION update_updated_at();
CREATE TRIGGER trg_mentor_reports_updated_at       BEFORE UPDATE ON mentor_reports       FOR EACH ROW EXECUTE FUNCTION update_updated_at();
CREATE TRIGGER trg_payments_updated_at             BEFORE UPDATE ON payments             FOR EACH ROW EXECUTE FUNCTION update_updated_at();
CREATE TRIGGER trg_team_fund_distributions_updated_at BEFORE UPDATE ON team_fund_distributions FOR EACH ROW EXECUTE FUNCTION update_updated_at();

-- ============================================================
-- SEED DATA (exported from production DB)
-- ============================================================

COPY public.enterprises (id, user_id, company_name, tax_code, business_license_number, address, city, district, ward, representative_name, representative_position, contact_email, contact_phone, website, industry, company_size, year_established, description, logo_file_id, banner_file_id, verified_at, verified_by, verification_note, rating_average, total_projects, successful_projects, created_at, updated_at, deleted_at, status) FROM stdin;
4	4	Công ty contact	0000000004	\N	\N	\N	\N	\N	Đại diện contact	\N	contact@techcorp.vn	\N	\N	Information Technology	10-50	2020	Tài khoản doanh nghiệp	\N	\N	\N	\N	\N	0.00	0	0	2026-10-01 07:54:30.600558	2026-10-01 07:54:30.600558	\N	APPROVED
5	5	Công ty info	0000000005	\N	\N	\N	\N	\N	Đại diện info	\N	info@innovatesolutions.vn	\N	\N	Information Technology	10-50	2020	Tài khoản doanh nghiệp	\N	\N	\N	\N	\N	0.00	0	0	2026-10-01 07:54:30.600558	2026-10-01 07:54:30.600558	\N	APPROVED
6	6	Công ty hello	0000000006	\N	\N	\N	\N	\N	Đại diện hello	\N	hello@digitalstartup.vn	\N	\N	Information Technology	10-50	2020	Tài khoản doanh nghiệp	\N	\N	\N	\N	\N	0.00	0	0	2026-10-01 07:54:30.600558	2026-10-01 07:54:30.600558	\N	APPROVED
7	7	Công ty enterprise4	0000000007	\N	\N	\N	\N	\N	Đại diện enterprise4	\N	enterprise4@example.com	\N	\N	Information Technology	10-50	2020	Tài khoản doanh nghiệp	\N	\N	\N	\N	\N	0.00	0	0	2026-10-01 07:54:30.600558	2026-10-01 07:54:30.600558	\N	APPROVED
\.

COPY public.mentor_expertise (id, mentor_id, skill_name, skill_category, proficiency_level, years_of_experience, can_teach, created_at) FROM stdin;
1	1	Java	\N	EXPERT	10.0	t	2026-10-01 06:22:57.437324
2	1	Spring Boot	\N	EXPERT	8.0	t	2026-10-01 06:22:57.437324
3	1	Microservices	\N	EXPERT	7.0	t	2026-10-01 06:22:57.437324
4	1	PostgreSQL	\N	EXPERT	10.0	t	2026-10-01 06:22:57.437324
5	1	Docker	\N	EXPERT	6.0	t	2026-10-01 06:22:57.437324
6	1	Kubernetes	\N	ADVANCED	5.0	t	2026-10-01 06:22:57.437324
7	1	AWS	\N	EXPERT	8.0	t	2026-10-01 06:22:57.437324
8	2	React.js	\N	EXPERT	6.0	t	2026-10-01 06:22:57.437324
9	2	Node.js	\N	EXPERT	7.0	t	2026-10-01 06:22:57.437324
10	2	DevOps	\N	EXPERT	5.0	t	2026-10-01 06:22:57.437324
11	2	CI/CD	\N	EXPERT	6.0	t	2026-10-01 06:22:57.437324
12	2	MongoDB	\N	EXPERT	6.0	t	2026-10-01 06:22:57.437324
13	2	AWS	\N	ADVANCED	5.0	t	2026-10-01 06:22:57.437324
14	3	Flutter	\N	EXPERT	5.0	t	2026-10-01 06:22:57.437324
15	3	React Native	\N	EXPERT	4.0	t	2026-10-01 06:22:57.437324
16	3	iOS Development	\N	EXPERT	7.0	t	2026-10-01 06:22:57.437324
17	3	Android Development	\N	EXPERT	7.0	t	2026-10-01 06:22:57.437324
18	3	Mobile UX	\N	EXPERT	6.0	t	2026-10-01 06:22:57.437324
19	3	Firebase	\N	EXPERT	5.0	t	2026-10-01 06:22:57.437324
20	4	React.js	\N	EXPERT	5.0	t	2026-10-01 06:22:57.437324
21	4	Vue.js	\N	EXPERT	4.0	t	2026-10-01 06:22:57.437324
22	4	TypeScript	\N	EXPERT	5.0	t	2026-10-01 06:22:57.437324
23	4	UI/UX Design	\N	ADVANCED	4.0	t	2026-10-01 06:22:57.437324
24	4	Frontend Architecture	\N	EXPERT	5.0	t	2026-10-01 06:22:57.437324
\.

COPY public.mentors (id, user_id, full_name, title, bio, years_of_experience, current_position, current_company, specialization, industries, linkedin_url, github_url, personal_website, max_concurrent_projects, current_projects_count, hours_per_week_available, hourly_rate, preferred_payment_method, bank_account_info, rating_average, total_projects, total_students_mentored, available, created_at, updated_at, deleted_at) FROM stdin;
1	18	Nguyen Quang Huy	Senior Backend Engineer	Experienced backend architect with 10+ years in enterprise system development. Specialized in building scalable microservices and cloud-native applications.	10	Senior Backend Engineer	FPT Software	\N	\N	https://linkedin.com/in/nguyenquanghuy	\N	\N	3	1	\N	500000.00	\N	\N	4.80	15	0	t	2025-10-01 06:22:57.433628	2026-10-01 06:22:57.433628	\N
2	19	Tran Minh Tuan	Tech Lead	Full-stack developer and DevOps engineer with passion for mentoring young talents. Experienced in agile methodologies and modern development practices.	8	Tech Lead	VNG Corporation	\N	\N	https://linkedin.com/in/tranminhtuan	\N	\N	3	2	\N	450000.00	\N	\N	4.70	12	0	t	2025-12-05 06:22:57.433628	2026-10-01 06:22:57.433628	\N
3	20	Le Hong Anh	Mobile Development Lead	Mobile development specialist with expertise in cross-platform frameworks. Published 20+ apps with millions of downloads.	7	Mobile Development Lead	Tiki	\N	\N	https://linkedin.com/in/lehonganh	\N	\N	2	2	\N	480000.00	\N	\N	4.90	10	0	f	2025-12-25 06:22:57.433628	2026-10-01 06:22:57.433628	\N
4	21	Pham Thao Nguyen	Senior Frontend Developer	Frontend expert passionate about creating beautiful and performant user interfaces. Strong advocate for accessibility and user experience.	6	Senior Frontend Developer	Shopee	\N	\N	https://linkedin.com/in/phamthaonguyen	\N	\N	3	1	\N	420000.00	\N	\N	4.60	8	0	t	2026-02-03 06:22:57.433628	2026-10-01 06:22:57.433628	\N
\.

COPY public.talent_skills (id, talent_id, skill_name, skill_category, proficiency_level, years_of_experience, last_used_date, verified, verified_by, verified_at, created_at, updated_at) FROM stdin;
1	1	React.js	\N	ADVANCED	2.0	\N	f	\N	\N	2026-10-01 06:22:57.42879	2026-10-01 06:22:57.42879
2	1	Vue.js	\N	INTERMEDIATE	1.0	\N	f	\N	\N	2026-10-01 06:22:57.42879	2026-10-01 06:22:57.42879
3	1	HTML/CSS	\N	ADVANCED	3.0	\N	f	\N	\N	2026-10-01 06:22:57.42879	2026-10-01 06:22:57.42879
4	1	JavaScript/TypeScript	\N	ADVANCED	2.0	\N	f	\N	\N	2026-10-01 06:22:57.42879	2026-10-01 06:22:57.42879
5	1	Tailwind CSS	\N	INTERMEDIATE	1.0	\N	f	\N	\N	2026-10-01 06:22:57.42879	2026-10-01 06:22:57.42879
6	2	React.js	\N	ADVANCED	2.0	\N	f	\N	\N	2026-10-01 06:22:57.42879	2026-10-01 06:22:57.42879
7	2	Node.js	\N	ADVANCED	2.0	\N	f	\N	\N	2026-10-01 06:22:57.42879	2026-10-01 06:22:57.42879
8	2	Java Spring Boot	\N	INTERMEDIATE	1.0	\N	f	\N	\N	2026-10-01 06:22:57.42879	2026-10-01 06:22:57.42879
9	2	MongoDB	\N	INTERMEDIATE	1.0	\N	f	\N	\N	2026-10-01 06:22:57.42879	2026-10-01 06:22:57.42879
10	2	PostgreSQL	\N	ADVANCED	2.0	\N	f	\N	\N	2026-10-01 06:22:57.42879	2026-10-01 06:22:57.42879
11	2	Docker	\N	INTERMEDIATE	1.0	\N	f	\N	\N	2026-10-01 06:22:57.42879	2026-10-01 06:22:57.42879
12	3	Java	\N	ADVANCED	2.0	\N	f	\N	\N	2026-10-01 06:22:57.42879	2026-10-01 06:22:57.42879
13	3	Spring Boot	\N	ADVANCED	2.0	\N	f	\N	\N	2026-10-01 06:22:57.42879	2026-10-01 06:22:57.42879
14	3	Microservices	\N	INTERMEDIATE	1.0	\N	f	\N	\N	2026-10-01 06:22:57.42879	2026-10-01 06:22:57.42879
15	3	PostgreSQL	\N	ADVANCED	2.0	\N	f	\N	\N	2026-10-01 06:22:57.42879	2026-10-01 06:22:57.42879
16	3	Redis	\N	INTERMEDIATE	1.0	\N	f	\N	\N	2026-10-01 06:22:57.42879	2026-10-01 06:22:57.42879
17	3	Docker	\N	ADVANCED	2.0	\N	f	\N	\N	2026-10-01 06:22:57.42879	2026-10-01 06:22:57.42879
18	3	Kubernetes	\N	BEGINNER	0.0	\N	f	\N	\N	2026-10-01 06:22:57.42879	2026-10-01 06:22:57.42879
19	4	Flutter	\N	ADVANCED	2.0	\N	f	\N	\N	2026-10-01 06:22:57.42879	2026-10-01 06:22:57.42879
20	4	React Native	\N	INTERMEDIATE	1.0	\N	f	\N	\N	2026-10-01 06:22:57.42879	2026-10-01 06:22:57.42879
21	4	Dart	\N	ADVANCED	2.0	\N	f	\N	\N	2026-10-01 06:22:57.42879	2026-10-01 06:22:57.42879
22	4	Firebase	\N	ADVANCED	2.0	\N	f	\N	\N	2026-10-01 06:22:57.42879	2026-10-01 06:22:57.42879
23	4	REST API Integration	\N	ADVANCED	2.0	\N	f	\N	\N	2026-10-01 06:22:57.42879	2026-10-01 06:22:57.42879
24	5	Figma	\N	ADVANCED	2.0	\N	f	\N	\N	2026-10-01 06:22:57.42879	2026-10-01 06:22:57.42879
25	5	Adobe XD	\N	INTERMEDIATE	1.0	\N	f	\N	\N	2026-10-01 06:22:57.42879	2026-10-01 06:22:57.42879
26	5	Sketch	\N	INTERMEDIATE	1.0	\N	f	\N	\N	2026-10-01 06:22:57.42879	2026-10-01 06:22:57.42879
27	5	Prototyping	\N	ADVANCED	2.0	\N	f	\N	\N	2026-10-01 06:22:57.42879	2026-10-01 06:22:57.42879
28	5	User Research	\N	INTERMEDIATE	1.0	\N	f	\N	\N	2026-10-01 06:22:57.42879	2026-10-01 06:22:57.42879
29	6	Python	\N	ADVANCED	2.0	\N	f	\N	\N	2026-10-01 06:22:57.42879	2026-10-01 06:22:57.42879
30	6	R	\N	INTERMEDIATE	1.0	\N	f	\N	\N	2026-10-01 06:22:57.42879	2026-10-01 06:22:57.42879
31	6	Machine Learning	\N	INTERMEDIATE	1.0	\N	f	\N	\N	2026-10-01 06:22:57.42879	2026-10-01 06:22:57.42879
32	6	Data Visualization	\N	ADVANCED	2.0	\N	f	\N	\N	2026-10-01 06:22:57.42879	2026-10-01 06:22:57.42879
33	6	SQL	\N	ADVANCED	2.0	\N	f	\N	\N	2026-10-01 06:22:57.42879	2026-10-01 06:22:57.42879
34	6	Tableau	\N	INTERMEDIATE	1.0	\N	f	\N	\N	2026-10-01 06:22:57.42879	2026-10-01 06:22:57.42879
35	7	Docker	\N	ADVANCED	2.0	\N	f	\N	\N	2026-10-01 06:22:57.42879	2026-10-01 06:22:57.42879
36	7	Kubernetes	\N	INTERMEDIATE	1.0	\N	f	\N	\N	2026-10-01 06:22:57.42879	2026-10-01 06:22:57.42879
37	7	CI/CD	\N	ADVANCED	2.0	\N	f	\N	\N	2026-10-01 06:22:57.42879	2026-10-01 06:22:57.42879
38	7	AWS	\N	INTERMEDIATE	1.0	\N	f	\N	\N	2026-10-01 06:22:57.42879	2026-10-01 06:22:57.42879
39	7	Terraform	\N	INTERMEDIATE	1.0	\N	f	\N	\N	2026-10-01 06:22:57.42879	2026-10-01 06:22:57.42879
40	7	Linux	\N	ADVANCED	3.0	\N	f	\N	\N	2026-10-01 06:22:57.42879	2026-10-01 06:22:57.42879
41	8	Manual Testing	\N	ADVANCED	2.0	\N	f	\N	\N	2026-10-01 06:22:57.42879	2026-10-01 06:22:57.42879
42	8	Selenium	\N	INTERMEDIATE	1.0	\N	f	\N	\N	2026-10-01 06:22:57.42879	2026-10-01 06:22:57.42879
43	8	Test Automation	\N	INTERMEDIATE	1.0	\N	f	\N	\N	2026-10-01 06:22:57.42879	2026-10-01 06:22:57.42879
44	8	Postman	\N	ADVANCED	2.0	\N	f	\N	\N	2026-10-01 06:22:57.42879	2026-10-01 06:22:57.42879
45	8	JIRA	\N	ADVANCED	2.0	\N	f	\N	\N	2026-10-01 06:22:57.42879	2026-10-01 06:22:57.42879
46	9	Unity	\N	ADVANCED	2.0	\N	f	\N	\N	2026-10-01 06:22:57.42879	2026-10-01 06:22:57.42879
47	9	C#	\N	ADVANCED	2.0	\N	f	\N	\N	2026-10-01 06:22:57.42879	2026-10-01 06:22:57.42879
48	9	Game Design	\N	INTERMEDIATE	1.0	\N	f	\N	\N	2026-10-01 06:22:57.42879	2026-10-01 06:22:57.42879
49	9	Blender	\N	BEGINNER	0.0	\N	f	\N	\N	2026-10-01 06:22:57.42879	2026-10-01 06:22:57.42879
\.

COPY public.talents (id, user_id, full_name, date_of_birth, gender, student_id, faculty, major, year_of_study, gpa, expected_graduation, address, city, emergency_contact, emergency_contact_name, bio, portfolio_url, github_url, linkedin_url, cv_file_id, career_goals, preferred_technologies, work_availability, hours_per_week, rating_average, total_projects, completed_projects, total_tasks_completed, available_for_projects, created_at, updated_at, deleted_at) FROM stdin;
1	8	Nguyen Van A	2002-03-15	\N	2020600001	Computer Science	Software Engineering	3	3.45	2026-06-30	\N	\N	\N	\N	Passionate frontend developer with experience in React, Vue.js, and modern web technologies.	https://nguyenvana.dev	https://github.com/nguyenvana	https://linkedin.com/in/nguyenvana	\N	\N	\N	Full-time	40	4.50	3	2	0	t	2026-04-04 06:22:57.424352	2026-10-01 06:22:57.424352	\N
2	9	Tran Thi B	2002-05-20	\N	2020600002	Computer Science	Software Engineering	3	3.67	2026-06-30	\N	\N	\N	\N	Full-stack developer skilled in MERN stack, Java Spring Boot, and database design.	https://tranthib.com	https://github.com/tranthib	https://linkedin.com/in/tranthib	\N	\N	\N	Full-time	40	4.70	4	3	0	t	2026-04-04 06:22:57.424352	2026-10-01 06:22:57.424352	\N
3	10	Le Van C	2002-01-10	\N	2020600003	Computer Science	Software Engineering	3	3.52	2026-06-30	\N	\N	\N	\N	Backend specialist with strong knowledge in microservices, Docker, and cloud platforms.	\N	https://github.com/levanc	https://linkedin.com/in/levanc	\N	\N	\N	Full-time	40	4.30	2	2	0	t	2026-04-04 06:22:57.424352	2026-10-01 06:22:57.424352	\N
4	11	Pham Thi D	2003-07-22	\N	2021600004	Computer Science	Software Engineering	2	3.78	2027-06-30	\N	\N	\N	\N	Mobile app developer proficient in Flutter and React Native with published apps on stores.	https://phamthid-portfolio.web.app	https://github.com/phamthid	https://linkedin.com/in/phamthid	\N	\N	\N	Part-time	20	4.80	3	2	0	t	2026-05-04 06:22:57.424352	2026-10-01 06:22:57.424352	\N
5	12	Hoang Van E	2003-09-05	\N	2021600005	Computer Science	Information Systems	2	3.61	2027-06-30	\N	\N	\N	\N	Creative UI/UX designer with a keen eye for user-centered design and prototyping.	https://behance.net/hoangvane	https://github.com/hoangvane	https://linkedin.com/in/hoangvane	\N	\N	\N	Part-time	25	4.60	2	1	0	t	2026-05-04 06:22:57.424352	2026-10-01 06:22:57.424352	\N
6	13	Vu Thi F	2003-11-18	\N	2021600006	Computer Science	Data Science	2	3.85	2027-06-30	\N	\N	\N	\N	Data enthusiast with skills in Python, R, machine learning, and data visualization.	https://vuthif-data.github.io	https://github.com/vuthif	https://linkedin.com/in/vuthif	\N	\N	\N	Full-time	40	4.90	2	2	0	f	2026-05-04 06:22:57.424352	2026-10-01 06:22:57.424352	\N
7	14	Dan Van G	2002-04-30	\N	2020600007	Computer Science	Software Engineering	3	3.40	2026-06-30	\N	\N	\N	\N	DevOps practitioner experienced with CI/CD, Kubernetes, Terraform, and AWS.	\N	https://github.com/danvang	https://linkedin.com/in/danvang	\N	\N	\N	Full-time	35	4.20	2	1	0	t	2026-04-04 06:22:57.424352	2026-10-01 06:22:57.424352	\N
8	15	Ngo Thi H	2003-06-12	\N	2021600008	Computer Science	Software Engineering	2	3.55	2027-06-30	\N	\N	\N	\N	Quality assurance specialist with experience in manual and automated testing.	\N	https://github.com/ngothih	https://linkedin.com/in/ngothih	\N	\N	\N	Part-time	20	4.40	1	1	0	t	2026-05-04 06:22:57.424352	2026-10-01 06:22:57.424352	\N
9	16	Bui Van I	2003-02-28	\N	2021600009	Computer Science	Software Engineering	2	3.70	2027-06-30	\N	\N	\N	\N	Game developer passionate about Unity, C#, and creating engaging interactive experiences.	https://buivani.itch.io	https://github.com/buivani	https://linkedin.com/in/buivani	\N	\N	\N	Part-time	15	4.50	1	0	0	t	2026-06-03 06:22:57.424352	2026-10-01 06:22:57.424352	\N
10	17	Do Thi K	2004-08-08	\N	2022600010	Computer Science	Software Engineering	1	3.20	2028-06-30	\N	\N	\N	\N	First-year student eager to learn and gain practical experience.	\N	https://github.com/dothik	\N	\N	\N	\N	Part-time	10	0.00	0	0	0	t	2026-09-01 06:22:57.424352	2026-10-01 06:22:57.424352	\N
\.

COPY public.transparency_reports (id, report_type, period, statistics, charts_data, publish_note, status, public_url, pdf_url, created_by, published_at, created_at) FROM stdin;
1	MONTHLY	2026-01	{"mentors": {"total": 4, "active": 3, "averageRating": 4.7}, "talents": {"total": 10, "active": 8, "newTalents": 2, "averageRating": 4.5}, "projects": {"total": 5, "ongoing": 2, "cancelled": 0, "completed": 1, "newProjects": 1, "successRate": 20.0}, "financials": {"labRevenue": 16500000, "totalRevenue": 165000000, "teamDisbursed": 115500000, "mentorDisbursed": 33000000, "hybridFundRepaid": 0, "hybridFundAdvanced": 0}, "enterprises": {"total": 4, "active": 4, "verified": 4, "newEnterprises": 0}, "performance": {"onTimeDelivery": 78.3, "avgProjectCompletion": 85.5, "customerSatisfaction": 4.6}}	{"revenueByMonth": [{"month": "2025-12", "amount": 0}, {"month": "2026-01", "amount": 120000000}], "projectsByStatus": [{"count": 2, "status": "IN_PROGRESS"}, {"count": 1, "status": "RECRUITING"}, {"count": 1, "status": "VALIDATED"}, {"count": 1, "status": "PENDING_VALIDATION"}], "studentParticipation": [{"count": 4, "month": "2025-12"}, {"count": 8, "month": "2026-01"}], "enterpriseSatisfaction": [{"count": 1, "rating": 5}, {"count": 1, "rating": 4}]}	Monthly transparency report for January 2026 - Strong growth in student participation and project activity	PUBLISHED	https://labodc.uth.edu.vn/transparency/2026-01	https://labodc.uth.edu.vn/transparency/2026-01.pdf	2	2026-09-30 06:22:58.025583	2026-09-28 06:22:58.025583
2	MONTHLY	2025-12	{"mentors": {"total": 4, "active": 2, "averageRating": 0.0}, "talents": {"total": 10, "active": 4, "newTalents": 0, "averageRating": 0.0}, "projects": {"total": 5, "ongoing": 1, "cancelled": 0, "completed": 0, "newProjects": 0, "successRate": 0.0}, "financials": {"labRevenue": 0, "totalRevenue": 0, "teamDisbursed": 0, "mentorDisbursed": 0, "hybridFundRepaid": 0, "hybridFundAdvanced": 0}, "enterprises": {"total": 4, "active": 4, "verified": 4, "newEnterprises": 0}, "performance": {"onTimeDelivery": 0.0, "avgProjectCompletion": 0.0, "customerSatisfaction": 0.0}}	{"revenueByMonth": [{"month": "2025-11", "amount": 45000000}, {"month": "2025-12", "amount": 0}], "projectsByStatus": [{"count": 1, "status": "IN_PROGRESS"}, {"count": 1, "status": "RECRUITING"}, {"count": 0, "status": "VALIDATED"}, {"count": 0, "status": "PENDING_VALIDATION"}], "studentParticipation": [{"count": 4, "month": "2025-11"}, {"count": 4, "month": "2025-12"}]}	Monthly transparency report for December 2025 - Project initiation phase	PUBLISHED	https://labodc.uth.edu.vn/transparency/2025-12	https://labodc.uth.edu.vn/transparency/2025-12.pdf	2	2026-08-30 06:22:58.025583	2026-08-28 06:22:58.025583
\.

COPY public.users (id, email, password_hash, role, status, email_verified, email_verified_at, verification_token, two_factor_enabled, two_factor_secret, failed_login_attempts, locked_until, last_login_at, last_login_ip, avatar_file_id, phone, timezone, language, created_at, updated_at, deleted_at) FROM stdin;
3	labadmin2@labodc.com	$2a$12$8pC/5kx6500tN2HEkDaPLeVR3mg.RWvLDsLADL6lioo53laEWJhXu	LAB_ADMIN	ACTIVE	t	2026-10-01 06:22:57.419033	\N	f	\N	0	\N	\N	\N	\N	+84901234569	Asia/Ho_Chi_Minh	vi	2026-10-01 06:22:57.419033	2026-10-01 06:22:57.419033	\N
6	hello@digitalstartup.vn	$2a$12$8pC/5kx6500tN2HEkDaPLeVR3mg.RWvLDsLADL6lioo53laEWJhXu	ENTERPRISE	ACTIVE	t	2026-10-01 06:22:57.420229	\N	f	\N	0	\N	\N	\N	\N	+84903333333	Asia/Ho_Chi_Minh	vi	2026-10-01 06:22:57.420229	2026-10-01 06:22:57.420229	\N
7	enterprise4@example.com	$2a$12$8pC/5kx6500tN2HEkDaPLeVR3mg.RWvLDsLADL6lioo53laEWJhXu	ENTERPRISE	PENDING	f	\N	\N	f	\N	0	\N	\N	\N	\N	+84904444444	Asia/Ho_Chi_Minh	vi	2026-10-01 06:22:57.420229	2026-10-01 06:22:57.420229	\N
9	tranthib@student.uth.edu.vn	$2a$12$8pC/5kx6500tN2HEkDaPLeVR3mg.RWvLDsLADL6lioo53laEWJhXu	TALENT	ACTIVE	t	2026-10-01 06:22:57.421273	\N	f	\N	0	\N	\N	\N	\N	+84905555552	Asia/Ho_Chi_Minh	vi	2026-10-01 06:22:57.421273	2026-10-01 06:22:57.421273	\N
10	levanc@student.uth.edu.vn	$2a$12$8pC/5kx6500tN2HEkDaPLeVR3mg.RWvLDsLADL6lioo53laEWJhXu	TALENT	ACTIVE	t	2026-10-01 06:22:57.421273	\N	f	\N	0	\N	\N	\N	\N	+84905555553	Asia/Ho_Chi_Minh	vi	2026-10-01 06:22:57.421273	2026-10-01 06:22:57.421273	\N
11	phamthid@student.uth.edu.vn	$2a$12$8pC/5kx6500tN2HEkDaPLeVR3mg.RWvLDsLADL6lioo53laEWJhXu	TALENT	ACTIVE	t	2026-10-01 06:22:57.421273	\N	f	\N	0	\N	\N	\N	\N	+84905555554	Asia/Ho_Chi_Minh	vi	2026-10-01 06:22:57.421273	2026-10-01 06:22:57.421273	\N
12	hoangvane@student.uth.edu.vn	$2a$12$8pC/5kx6500tN2HEkDaPLeVR3mg.RWvLDsLADL6lioo53laEWJhXu	TALENT	ACTIVE	t	2026-10-01 06:22:57.421273	\N	f	\N	0	\N	\N	\N	\N	+84905555555	Asia/Ho_Chi_Minh	vi	2026-10-01 06:22:57.421273	2026-10-01 06:22:57.421273	\N
13	vuthif@student.uth.edu.vn	$2a$12$8pC/5kx6500tN2HEkDaPLeVR3mg.RWvLDsLADL6lioo53laEWJhXu	TALENT	ACTIVE	t	2026-10-01 06:22:57.421273	\N	f	\N	0	\N	\N	\N	\N	+84905555556	Asia/Ho_Chi_Minh	vi	2026-10-01 06:22:57.421273	2026-10-01 06:22:57.421273	\N
14	danvang@student.uth.edu.vn	$2a$12$8pC/5kx6500tN2HEkDaPLeVR3mg.RWvLDsLADL6lioo53laEWJhXu	TALENT	ACTIVE	t	2026-10-01 06:22:57.421273	\N	f	\N	0	\N	\N	\N	\N	+84905555557	Asia/Ho_Chi_Minh	vi	2026-10-01 06:22:57.421273	2026-10-01 06:22:57.421273	\N
15	ngothih@student.uth.edu.vn	$2a$12$8pC/5kx6500tN2HEkDaPLeVR3mg.RWvLDsLADL6lioo53laEWJhXu	TALENT	ACTIVE	t	2026-10-01 06:22:57.421273	\N	f	\N	0	\N	\N	\N	\N	+84905555558	Asia/Ho_Chi_Minh	vi	2026-10-01 06:22:57.421273	2026-10-01 06:22:57.421273	\N
16	buivani@student.uth.edu.vn	$2a$12$8pC/5kx6500tN2HEkDaPLeVR3mg.RWvLDsLADL6lioo53laEWJhXu	TALENT	ACTIVE	t	2026-10-01 06:22:57.421273	\N	f	\N	0	\N	\N	\N	\N	+84905555559	Asia/Ho_Chi_Minh	vi	2026-10-01 06:22:57.421273	2026-10-01 06:22:57.421273	\N
17	dothik@student.uth.edu.vn	$2a$12$8pC/5kx6500tN2HEkDaPLeVR3mg.RWvLDsLADL6lioo53laEWJhXu	TALENT	PENDING	f	\N	\N	f	\N	0	\N	\N	\N	\N	+84905555560	Asia/Ho_Chi_Minh	vi	2026-10-01 06:22:57.421273	2026-10-01 06:22:57.421273	\N
19	mentor.tranminh@uth.edu.vn	$2a$12$8pC/5kx6500tN2HEkDaPLeVR3mg.RWvLDsLADL6lioo53laEWJhXu	MENTOR	ACTIVE	t	2026-10-01 06:22:57.422411	\N	f	\N	0	\N	\N	\N	\N	+84906666662	Asia/Ho_Chi_Minh	vi	2026-10-01 06:22:57.422411	2026-10-01 06:22:57.422411	\N
20	mentor.lehong@uth.edu.vn	$2a$12$8pC/5kx6500tN2HEkDaPLeVR3mg.RWvLDsLADL6lioo53laEWJhXu	MENTOR	ACTIVE	t	2026-10-01 06:22:57.422411	\N	f	\N	0	\N	\N	\N	\N	+84906666663	Asia/Ho_Chi_Minh	vi	2026-10-01 06:22:57.422411	2026-10-01 06:22:57.422411	\N
21	mentor.phamthao@uth.edu.vn	$2a$12$8pC/5kx6500tN2HEkDaPLeVR3mg.RWvLDsLADL6lioo53laEWJhXu	MENTOR	ACTIVE	t	2026-10-01 06:22:57.422411	\N	f	\N	0	\N	\N	\N	\N	+84906666664	Asia/Ho_Chi_Minh	vi	2026-10-01 06:22:57.422411	2026-10-01 06:22:57.422411	\N
1	admin@labodc.com	$2a$12$8pC/5kx6500tN2HEkDaPLeVR3mg.RWvLDsLADL6lioo53laEWJhXu	SYSTEM_ADMIN	ACTIVE	t	2026-10-01 06:22:57.416546	\N	f	\N	0	\N	2026-10-01 13:26:38.935257	\N	\N	+84901234567	Asia/Ho_Chi_Minh	vi	2026-10-01 06:22:57.416546	2026-10-01 13:26:38.604539	\N
5	info@innovatesolutions.vn	$2a$12$8pC/5kx6500tN2HEkDaPLeVR3mg.RWvLDsLADL6lioo53laEWJhXu	ENTERPRISE	ACTIVE	t	2026-10-01 06:22:57.420229	\N	f	\N	0	\N	2026-10-01 14:31:43.256033	\N	\N	+84902222222	Asia/Ho_Chi_Minh	vi	2026-10-01 06:22:57.420229	2026-10-01 14:31:42.968971	\N
2	labadmin1@labodc.com	$2a$12$8pC/5kx6500tN2HEkDaPLeVR3mg.RWvLDsLADL6lioo53laEWJhXu	LAB_ADMIN	ACTIVE	t	2026-10-01 06:22:57.419033	\N	f	\N	0	\N	2026-10-01 14:33:21.46957	\N	\N	+84901234568	Asia/Ho_Chi_Minh	vi	2026-10-01 06:22:57.419033	2026-10-01 14:33:21.186539	\N
18	mentor.nguyenquang@uth.edu.vn	$2a$12$8pC/5kx6500tN2HEkDaPLeVR3mg.RWvLDsLADL6lioo53laEWJhXu	MENTOR	ACTIVE	t	2026-10-01 06:22:57.422411	\N	f	\N	0	\N	2026-10-01 13:33:03.307197	\N	\N	+84906666661	Asia/Ho_Chi_Minh	vi	2026-10-01 06:22:57.422411	2026-10-01 13:33:03.016807	\N
4	contact@techcorp.vn	$2a$12$8pC/5kx6500tN2HEkDaPLeVR3mg.RWvLDsLADL6lioo53laEWJhXu	ENTERPRISE	ACTIVE	t	2026-10-01 06:22:57.420229	\N	f	\N	0	\N	2026-10-01 14:55:02.782092	\N	\N	+84901111111	Asia/Ho_Chi_Minh	vi	2026-10-01 06:22:57.420229	2026-10-01 14:55:02.49057	\N
8	nguyenvana@student.uth.edu.vn	$2a$12$8pC/5kx6500tN2HEkDaPLeVR3mg.RWvLDsLADL6lioo53laEWJhXu	TALENT	ACTIVE	t	2026-10-01 06:22:57.421273	\N	f	\N	0	\N	2026-10-01 15:12:55.009904	\N	\N	+84905555551	Asia/Ho_Chi_Minh	vi	2026-10-01 06:22:57.421273	2026-10-01 15:12:54.699288	\N
\.

