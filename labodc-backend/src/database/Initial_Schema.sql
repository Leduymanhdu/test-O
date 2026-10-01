
-- Enable extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pg_trgm"; -- For text search optimization
CREATE EXTENSION IF NOT EXISTS "btree_gin"; -- For multi-column indexes

-- =====================================================
-- DATABASE ENUMS (Type Safety)
-- =====================================================

-- User related enums
CREATE TYPE user_role_enum AS ENUM ('SYSTEM_ADMIN', 'LAB_ADMIN', 'ENTERPRISE', 'TALENT', 'MENTOR');
CREATE TYPE user_status_enum AS ENUM ('PENDING', 'ACTIVE', 'INACTIVE', 'LOCKED', 'SUSPENDED');

-- Enterprise related enums
CREATE TYPE document_type_enum AS ENUM ('BUSINESS_LICENSE', 'TAX_REGISTRATION', 'COMPANY_PROFILE', 'OTHER');
CREATE TYPE verification_action_enum AS ENUM ('APPROVED', 'REJECTED', 'REQUEST_INFO', 'REVOKED');

-- Talent related enums
CREATE TYPE proficiency_level_enum AS ENUM ('BEGINNER', 'INTERMEDIATE', 'ADVANCED', 'EXPERT');
CREATE TYPE employment_type_enum AS ENUM ('FULL_TIME', 'PART_TIME', 'INTERNSHIP', 'FREELANCE', 'CONTRACT');

-- Mentor related enums
CREATE TYPE invitation_status_enum AS ENUM ('PENDING', 'ACCEPTED', 'REJECTED', 'EXPIRED');

-- Project related enums
CREATE TYPE project_status_enum AS ENUM ('DRAFT', 'PENDING_VALIDATION', 'VALIDATED', 'REJECTED', 'RECRUITING', 'IN_PROGRESS', 'ON_HOLD', 'COMPLETED', 'CANCELLED', 'ARCHIVED');
CREATE TYPE project_member_role_enum AS ENUM ('MEMBER', 'LEADER');
CREATE TYPE project_member_status_enum AS ENUM ('ACTIVE', 'LEFT', 'REMOVED');
CREATE TYPE milestone_status_enum AS ENUM ('PENDING', 'IN_PROGRESS', 'COMPLETED', 'DELAYED');
CREATE TYPE change_request_type_enum AS ENUM ('SCOPE_CHANGE', 'TIMELINE_CHANGE', 'BUDGET_CHANGE', 'CANCELLATION');
CREATE TYPE change_request_status_enum AS ENUM ('PENDING', 'APPROVED', 'REJECTED', 'CANCELLED');

-- =====================================================
-- 1. AUTHENTICATION & AUTHORIZATION MODULE
-- =====================================================

-- 1.1 Users table
CREATE TABLE users (
    id BIGSERIAL PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    role user_role_enum NOT NULL,
    status user_status_enum NOT NULL DEFAULT 'PENDING',
    email_verified BOOLEAN DEFAULT FALSE,
    email_verified_at TIMESTAMP,
    verification_token VARCHAR(255),
    two_factor_enabled BOOLEAN DEFAULT FALSE,
    two_factor_secret VARCHAR(255),
    failed_login_attempts INTEGER DEFAULT 0,
    locked_until TIMESTAMP,
    last_login_at TIMESTAMP,
    last_login_ip VARCHAR(45),
    
    -- Avatar (centralized file management)
    avatar_file_id BIGINT, -- References files table (added later)
    
    phone VARCHAR(20),
    timezone VARCHAR(50) DEFAULT 'Asia/Ho_Chi_Minh',
    language VARCHAR(10) DEFAULT 'vi',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP,
    CONSTRAINT check_email_format CHECK (email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$')
);

CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_role ON users(role);
CREATE INDEX idx_users_status ON users(status);
CREATE INDEX idx_users_deleted ON users(deleted_at) WHERE deleted_at IS NULL;

COMMENT ON TABLE users IS 'Bảng chính lưu thông tin người dùng của hệ thống';

-- 1.2 Roles table
CREATE TABLE roles (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(50) UNIQUE NOT NULL,
    display_name VARCHAR(100) NOT NULL,
    description TEXT,
    editable BOOLEAN DEFAULT TRUE,
    system_role BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by BIGINT REFERENCES users(id),
    updated_by BIGINT REFERENCES users(id)
);

CREATE INDEX idx_roles_name ON roles(name);

-- 1.3 Permissions table
CREATE TABLE permissions (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(100) UNIQUE NOT NULL,
    resource VARCHAR(50) NOT NULL,
    action VARCHAR(50) NOT NULL,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_permissions_resource ON permissions(resource);
CREATE INDEX idx_permissions_name ON permissions(name);

-- 1.4 Role permissions mapping
CREATE TABLE role_permissions (
    id BIGSERIAL PRIMARY KEY,
    role_id BIGINT NOT NULL REFERENCES roles(id) ON DELETE CASCADE,
    permission_id BIGINT NOT NULL REFERENCES permissions(id) ON DELETE CASCADE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by BIGINT REFERENCES users(id),
    UNIQUE(role_id, permission_id)
);

CREATE INDEX idx_role_permissions_role ON role_permissions(role_id);
CREATE INDEX idx_role_permissions_permission ON role_permissions(permission_id);

-- 1.5 User roles mapping
CREATE TABLE user_roles (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    role_id BIGINT NOT NULL REFERENCES roles(id) ON DELETE CASCADE,
    context VARCHAR(50),
    context_id BIGINT,
    valid_from TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    valid_until TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by BIGINT REFERENCES users(id),
    UNIQUE(user_id, role_id, context, context_id)
);

CREATE INDEX idx_user_roles_user ON user_roles(user_id);
CREATE INDEX idx_user_roles_role ON user_roles(role_id);

-- 1.6 Password reset tokens
CREATE TABLE password_reset_tokens (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    token VARCHAR(255) UNIQUE NOT NULL,
    otp VARCHAR(6),
    expires_at TIMESTAMP NOT NULL,
    used_at TIMESTAMP,
    attempts INTEGER DEFAULT 0,
    max_attempts INTEGER DEFAULT 3,
    ip_address VARCHAR(45),
    user_agent TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_password_reset_tokens_user ON password_reset_tokens(user_id);
CREATE INDEX idx_password_reset_tokens_token ON password_reset_tokens(token);

-- 1.7 Login attempts
CREATE TABLE login_attempts (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT REFERENCES users(id) ON DELETE SET NULL,
    email VARCHAR(255) NOT NULL,
    success BOOLEAN NOT NULL,
    failure_reason VARCHAR(100),
    ip_address VARCHAR(45),
    user_agent TEXT,
    device_info JSONB,
    location_info JSONB,
    attempted_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_login_attempts_user ON login_attempts(user_id);
CREATE INDEX idx_login_attempts_email ON login_attempts(email);
CREATE INDEX idx_login_attempts_attempted ON login_attempts(attempted_at);

-- =====================================================
-- 2. ENTERPRISE MODULE
-- =====================================================

-- 2.1 Enterprises table
CREATE TABLE enterprises (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT UNIQUE NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    company_name VARCHAR(255) NOT NULL,
    tax_code VARCHAR(20) UNIQUE NOT NULL,
    business_license_number VARCHAR(50),
    address TEXT,
    city VARCHAR(100),
    district VARCHAR(100),
    ward VARCHAR(100),
    representative_name VARCHAR(255) NOT NULL,
    representative_position VARCHAR(100),
    contact_email VARCHAR(255),
    contact_phone VARCHAR(20),
    website VARCHAR(255),
    industry VARCHAR(100),
    company_size VARCHAR(50),
    year_established INTEGER,
    description TEXT,
    
    -- Logo & Banner (centralized file management)
    logo_file_id BIGINT, -- References files table
    banner_file_id BIGINT, -- References files table
    
    verified BOOLEAN DEFAULT FALSE,
    verified_at TIMESTAMP,
    verified_by BIGINT REFERENCES users(id) ON DELETE SET NULL,
    verification_note TEXT,
    rating_average DECIMAL(3,2) DEFAULT 0.00,
    total_projects INTEGER DEFAULT 0,
    successful_projects INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP,
    CONSTRAINT check_tax_code CHECK (tax_code ~* '^[0-9]{10,13}$'),
    CONSTRAINT check_rating CHECK (rating_average BETWEEN 0 AND 5)
);

CREATE INDEX idx_enterprises_user ON enterprises(user_id);
CREATE INDEX idx_enterprises_tax_code ON enterprises(tax_code);
CREATE INDEX idx_enterprises_verified ON enterprises(verified);

-- 2.2 Enterprise documents
CREATE TABLE enterprise_documents (
    id BIGSERIAL PRIMARY KEY,
    enterprise_id BIGINT NOT NULL REFERENCES enterprises(id) ON DELETE CASCADE,
    document_type document_type_enum NOT NULL,
    document_name VARCHAR(255) NOT NULL,
    
    -- File reference (centralized)
    file_id BIGINT, -- References files table
    
    verified BOOLEAN DEFAULT FALSE,
    verified_at TIMESTAMP,
    verified_by BIGINT REFERENCES users(id) ON DELETE SET NULL,
    verification_note TEXT,
    uploaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    uploaded_by BIGINT REFERENCES users(id) ON DELETE SET NULL
);

CREATE INDEX idx_enterprise_docs_enterprise ON enterprise_documents(enterprise_id);

-- 2.3 Enterprise verification history
CREATE TABLE enterprise_verification_history (
    id BIGSERIAL PRIMARY KEY,
    enterprise_id BIGINT NOT NULL REFERENCES enterprises(id) ON DELETE CASCADE,
    action verification_action_enum NOT NULL,
    performed_by BIGINT NOT NULL REFERENCES users(id) ON DELETE SET NULL,
    note TEXT,
    previous_status VARCHAR(20),
    new_status VARCHAR(20),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_enterprise_verification_enterprise ON enterprise_verification_history(enterprise_id);

-- =====================================================
-- 3. TALENT MODULE
-- =====================================================

-- 3.1 Talents table
CREATE TABLE talents (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT UNIQUE NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    full_name VARCHAR(255) NOT NULL,
    date_of_birth DATE,
    gender VARCHAR(10),
    student_id VARCHAR(20) UNIQUE NOT NULL,
    faculty VARCHAR(100),
    major VARCHAR(100),
    year_of_study INTEGER,
    gpa DECIMAL(3,2),
    expected_graduation DATE,
    address TEXT,
    city VARCHAR(100),
    emergency_contact VARCHAR(20),
    emergency_contact_name VARCHAR(255),
    bio TEXT,
    portfolio_url VARCHAR(500),
    github_url VARCHAR(500),
    linkedin_url VARCHAR(500),
    
    -- CV file (centralized)
    cv_file_id BIGINT, -- References files table
    
    career_goals TEXT,
    preferred_technologies JSONB,
    work_availability VARCHAR(50),
    hours_per_week INTEGER,
    rating_average DECIMAL(3,2) DEFAULT 0.00,
    total_projects INTEGER DEFAULT 0,
    completed_projects INTEGER DEFAULT 0,
    total_tasks_completed INTEGER DEFAULT 0,
    available_for_projects BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP,
    CONSTRAINT check_gpa CHECK (gpa BETWEEN 0 AND 4.0),
    CONSTRAINT check_rating CHECK (rating_average BETWEEN 0 AND 10),
    CONSTRAINT check_year_of_study CHECK (year_of_study BETWEEN 1 AND 6)
);

CREATE INDEX idx_talents_user ON talents(user_id);
CREATE INDEX idx_talents_student_id ON talents(student_id);
CREATE INDEX idx_talents_faculty ON talents(faculty);

-- 3.2 Talent skills
CREATE TABLE talent_skills (
    id BIGSERIAL PRIMARY KEY,
    talent_id BIGINT NOT NULL REFERENCES talents(id) ON DELETE CASCADE,
    skill_name VARCHAR(100) NOT NULL,
    skill_category VARCHAR(50),
    proficiency_level proficiency_level_enum NOT NULL,
    years_of_experience DECIMAL(3,1),
    last_used_date DATE,
    verified BOOLEAN DEFAULT FALSE,
    verified_by BIGINT REFERENCES users(id) ON DELETE SET NULL,
    verified_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(talent_id, skill_name)
);

CREATE INDEX idx_talent_skills_talent ON talent_skills(talent_id);
CREATE INDEX idx_talent_skills_name ON talent_skills(skill_name);

-- 3.3 Talent certifications
CREATE TABLE talent_certifications (
    id BIGSERIAL PRIMARY KEY,
    talent_id BIGINT NOT NULL REFERENCES talents(id) ON DELETE CASCADE,
    certification_name VARCHAR(255) NOT NULL,
    issuing_organization VARCHAR(255),
    credential_id VARCHAR(100),
    credential_url VARCHAR(500),
    issue_date DATE NOT NULL,
    expiration_date DATE,
    
    -- Certificate file (centralized)
    certificate_file_id BIGINT, -- References files table
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_talent_certifications_talent ON talent_certifications(talent_id);

-- 3.4 Talent educations
CREATE TABLE talent_educations (
    id BIGSERIAL PRIMARY KEY,
    talent_id BIGINT NOT NULL REFERENCES talents(id) ON DELETE CASCADE,
    institution_name VARCHAR(255) NOT NULL,
    degree VARCHAR(100),
    field_of_study VARCHAR(100),
    start_date DATE NOT NULL,
    end_date DATE,
    is_current BOOLEAN DEFAULT FALSE,
    grade VARCHAR(50),
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_talent_educations_talent ON talent_educations(talent_id);

-- 3.5 Talent work experiences
CREATE TABLE talent_work_experiences (
    id BIGSERIAL PRIMARY KEY,
    talent_id BIGINT NOT NULL REFERENCES talents(id) ON DELETE CASCADE,
    company_name VARCHAR(255) NOT NULL,
    position VARCHAR(100) NOT NULL,
    employment_type employment_type_enum,
    location VARCHAR(255),
    is_remote BOOLEAN DEFAULT FALSE,
    start_date DATE NOT NULL,
    end_date DATE,
    is_current BOOLEAN DEFAULT FALSE,
    description TEXT,
    achievements TEXT,
    technologies_used JSONB,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_talent_work_exp_talent ON talent_work_experiences(talent_id);

-- =====================================================
-- 4. MENTOR MODULE
-- =====================================================

-- 4.1 Mentors table
CREATE TABLE mentors (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT UNIQUE NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
    full_name VARCHAR(255) NOT NULL,
    title VARCHAR(100),
    bio TEXT,
    years_of_experience INTEGER,
    current_position VARCHAR(255),
    current_company VARCHAR(255),
    specialization TEXT,
    industries JSONB,
    linkedin_url VARCHAR(500),
    github_url VARCHAR(500),
    personal_website VARCHAR(500),
    max_concurrent_projects INTEGER DEFAULT 3,
    current_projects_count INTEGER DEFAULT 0,
    hours_per_week_available INTEGER,
    hourly_rate DECIMAL(10,2),
    preferred_payment_method VARCHAR(50),
    bank_account_info JSONB,
    rating_average DECIMAL(3,2) DEFAULT 0.00,
    total_projects INTEGER DEFAULT 0,
    total_students_mentored INTEGER DEFAULT 0,
    available BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP,
    CONSTRAINT check_rating CHECK (rating_average BETWEEN 0 AND 5)
);

CREATE INDEX idx_mentors_user ON mentors(user_id);
CREATE INDEX idx_mentors_available ON mentors(available);

-- 4.2 Mentor expertise
CREATE TABLE mentor_expertise (
    id BIGSERIAL PRIMARY KEY,
    mentor_id BIGINT NOT NULL REFERENCES mentors(id) ON DELETE CASCADE,
    skill_name VARCHAR(100) NOT NULL,
    skill_category VARCHAR(50),
    proficiency_level proficiency_level_enum NOT NULL,
    years_of_experience DECIMAL(4,1),
    can_teach BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(mentor_id, skill_name),
    CONSTRAINT check_mentor_proficiency CHECK (proficiency_level IN ('INTERMEDIATE', 'ADVANCED', 'EXPERT'))
);

CREATE INDEX idx_mentor_expertise_mentor ON mentor_expertise(mentor_id);
CREATE INDEX idx_mentor_expertise_skill ON mentor_expertise(skill_name);

-- 4.3 Mentor invitations
CREATE TABLE mentor_invitations (
    id BIGSERIAL PRIMARY KEY,
    project_id BIGINT NOT NULL, -- Will be created later
    mentor_id BIGINT NOT NULL REFERENCES mentors(id) ON DELETE CASCADE,
    invited_by BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    invitation_message TEXT,
    compensation_amount DECIMAL(15,2),
    expected_effort_hours INTEGER,
    status invitation_status_enum DEFAULT 'PENDING',
    response_message TEXT,
    responded_at TIMESTAMP,
    availability_info JSONB,
    expires_at TIMESTAMP NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_mentor_invitations_mentor ON mentor_invitations(mentor_id);
CREATE INDEX idx_mentor_invitations_status ON mentor_invitations(status);

-- 4.4 Mentor availability
CREATE TABLE mentor_availability (
    id BIGSERIAL PRIMARY KEY,
    mentor_id BIGINT NOT NULL REFERENCES mentors(id) ON DELETE CASCADE,
    day_of_week INTEGER NOT NULL,
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    is_recurring BOOLEAN DEFAULT TRUE,
    valid_from DATE,
    valid_until DATE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT check_day_of_week CHECK (day_of_week BETWEEN 0 AND 6),
    CONSTRAINT check_time_range CHECK (end_time > start_time)
);

CREATE INDEX idx_mentor_availability_mentor ON mentor_availability(mentor_id);

-- =====================================================
-- 5. PROJECT MODULE
-- =====================================================

-- 5.1 Projects table
CREATE TABLE projects (
    id BIGSERIAL PRIMARY KEY,
    enterprise_id BIGINT NOT NULL REFERENCES enterprises(id) ON DELETE CASCADE,
    mentor_id BIGINT REFERENCES mentors(id) ON DELETE SET NULL,
    
    -- Project Info
    title VARCHAR(255) NOT NULL,
    slug VARCHAR(255) UNIQUE NOT NULL,
    description TEXT NOT NULL,
    objectives JSONB,
    requirements TEXT,
    
    -- Timeline
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    actual_start_date DATE,
    actual_end_date DATE,
    
    -- Budget
    budget DECIMAL(15,2) NOT NULL,
    currency VARCHAR(10) DEFAULT 'VND',
    
    -- Team
    number_of_students INTEGER NOT NULL,
    current_members_count INTEGER DEFAULT 0,
    
    -- Status
    status project_status_enum NOT NULL DEFAULT 'DRAFT',
    progress_percentage INTEGER DEFAULT 0,
    
    -- Validation
    validated BOOLEAN DEFAULT FALSE,
    validated_at TIMESTAMP,
    validated_by BIGINT REFERENCES users(id),
    validation_note TEXT,
    rejection_reason TEXT,
    
    -- Settings
    is_public BOOLEAN DEFAULT TRUE,
    allow_applications BOOLEAN DEFAULT TRUE,
    
    -- Audit
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    published_at TIMESTAMP,
    deleted_at TIMESTAMP,
    
    CONSTRAINT check_budget CHECK (budget > 0),
    CONSTRAINT check_dates CHECK (end_date > start_date),
    CONSTRAINT check_students CHECK (number_of_students BETWEEN 3 AND 10),
    CONSTRAINT check_progress CHECK (progress_percentage BETWEEN 0 AND 100)
);

CREATE INDEX idx_projects_enterprise ON projects(enterprise_id);
CREATE INDEX idx_projects_mentor ON projects(mentor_id);
CREATE INDEX idx_projects_status ON projects(status);
CREATE INDEX idx_projects_slug ON projects(slug);
CREATE INDEX idx_projects_dates ON projects(start_date, end_date);
CREATE INDEX idx_projects_public ON projects(is_public) WHERE is_public = TRUE;

COMMENT ON TABLE projects IS 'Bảng chính lưu thông tin dự án';

-- 5.2 Project technologies
CREATE TABLE project_technologies (
    id BIGSERIAL PRIMARY KEY,
    project_id BIGINT NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
    technology_name VARCHAR(100) NOT NULL,
    technology_type VARCHAR(50), -- PROGRAMMING_LANGUAGE, FRAMEWORK, DATABASE, TOOL, PLATFORM
    is_required BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(project_id, technology_name)
);

CREATE INDEX idx_project_technologies_project ON project_technologies(project_id);
CREATE INDEX idx_project_technologies_name ON project_technologies(technology_name);

-- 5.3 Project skill requirements
CREATE TABLE project_skill_requirements (
    id BIGSERIAL PRIMARY KEY,
    project_id BIGINT NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
    skill_name VARCHAR(100) NOT NULL,
    proficiency_level proficiency_level_enum NOT NULL,
    is_required BOOLEAN DEFAULT TRUE,
    priority INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(project_id, skill_name)
);

CREATE INDEX idx_project_skill_reqs_project ON project_skill_requirements(project_id);

-- 5.4 Project attachments
CREATE TABLE project_attachments (
    id BIGSERIAL PRIMARY KEY,
    project_id BIGINT NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
    
    -- File reference (centralized)
    file_id BIGINT, -- References files table
    
    description TEXT,
    uploaded_by BIGINT REFERENCES users(id) ON DELETE SET NULL,
    uploaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_project_attachments_project ON project_attachments(project_id);

-- 5.5 Project members
CREATE TABLE project_members (
    id BIGSERIAL PRIMARY KEY,
    project_id BIGINT NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
    talent_id BIGINT NOT NULL REFERENCES talents(id) ON DELETE CASCADE,
    
    -- Role
    role project_member_role_enum DEFAULT 'MEMBER',
    
    -- Join Info
    joined_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    left_at TIMESTAMP,
    
    -- Status
    status project_member_status_enum DEFAULT 'ACTIVE',
    
    -- Performance
    tasks_assigned INTEGER DEFAULT 0,
    tasks_completed INTEGER DEFAULT 0,
    hours_contributed INTEGER DEFAULT 0,
    
    UNIQUE(project_id, talent_id)
);

CREATE INDEX idx_project_members_project ON project_members(project_id);
CREATE INDEX idx_project_members_talent ON project_members(talent_id);
CREATE INDEX idx_project_members_role ON project_members(role);

COMMENT ON TABLE project_members IS 'Thành viên tham gia dự án';

-- 5.6 Project milestones
CREATE TABLE project_milestones (
    id BIGSERIAL PRIMARY KEY,
    project_id BIGINT NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
    
    -- Milestone Info
    name VARCHAR(255) NOT NULL,
    description TEXT,
    
    -- Timeline
    due_date DATE NOT NULL,
    completed_date DATE,
    
    -- Status
    status milestone_status_enum DEFAULT 'PENDING',
    
    -- Order
    display_order INTEGER,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_project_milestones_project ON project_milestones(project_id);
CREATE INDEX idx_project_milestones_status ON project_milestones(status);

-- 5.7 Project change requests
CREATE TABLE project_change_requests (
    id BIGSERIAL PRIMARY KEY,
    project_id BIGINT NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
    
    -- Request Info
    request_type change_request_type_enum NOT NULL,
    requested_by BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    reason TEXT NOT NULL,
    
    -- Changes Detail
    changes_detail JSONB,
    
    -- Status
    status change_request_status_enum DEFAULT 'PENDING',
    
    -- Review
    reviewed_by BIGINT REFERENCES users(id) ON DELETE SET NULL,
    reviewed_at TIMESTAMP,
    review_note TEXT,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_project_change_requests_project ON project_change_requests(project_id);
CREATE INDEX idx_project_change_requests_status ON project_change_requests(status);

-- Add foreign key to mentor_invitations (deferred from earlier)
ALTER TABLE mentor_invitations 
    ADD CONSTRAINT fk_mentor_invitations_project 
    FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE;

CREATE INDEX idx_mentor_invitations_project ON mentor_invitations(project_id);

-- =====================================================
-- FOREIGN KEY CONSTRAINTS FOR CENTRALIZED FILE MANAGEMENT
-- (To be added after files table is created in V1_3 migration)
-- =====================================================

-- Note: These constraints will be added in V1_3__Centralized_File_Management.sql
-- after the files table is created:
--
-- ALTER TABLE users ADD CONSTRAINT fk_users_avatar_file 
--     FOREIGN KEY (avatar_file_id) REFERENCES files(id) ON DELETE SET NULL;
--
-- ALTER TABLE enterprises ADD CONSTRAINT fk_enterprises_logo_file 
--     FOREIGN KEY (logo_file_id) REFERENCES files(id) ON DELETE SET NULL;
--
-- ALTER TABLE enterprises ADD CONSTRAINT fk_enterprises_banner_file 
--     FOREIGN KEY (banner_file_id) REFERENCES files(id) ON DELETE SET NULL;
--
-- ALTER TABLE enterprise_documents ADD CONSTRAINT fk_enterprise_documents_file 
--     FOREIGN KEY (file_id) REFERENCES files(id) ON DELETE SET NULL;
--
-- ALTER TABLE talents ADD CONSTRAINT fk_talents_cv_file 
--     FOREIGN KEY (cv_file_id) REFERENCES files(id) ON DELETE SET NULL;
--
-- ALTER TABLE talent_certifications ADD CONSTRAINT fk_talent_certifications_file 
--     FOREIGN KEY (certificate_file_id) REFERENCES files(id) ON DELETE SET NULL;
--
-- ALTER TABLE project_attachments ADD CONSTRAINT fk_project_attachments_file 
--     FOREIGN KEY (file_id) REFERENCES files(id) ON DELETE CASCADE;

-- =====================================================
-- END OF INITIAL SCHEMA
-- =====================================================
