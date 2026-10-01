-- =====================================================
-- Rejection Management Tables
-- Purpose: Store rejection reasons and history for enterprises and projects
-- =====================================================

-- Table: enterprise_rejections
-- Purpose: Track rejection history for enterprise verification requests
CREATE TABLE IF NOT EXISTS enterprise_rejections (
    id BIGSERIAL PRIMARY KEY,
    enterprise_id BIGINT,
    rejected_by BIGINT NOT NULL,
    rejection_reason TEXT,
    rejected_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    -- Store enterprise info before deletion
    company_name VARCHAR(255),
    tax_code VARCHAR(50),
    contact_email VARCHAR(255),
    
    CONSTRAINT fk_enterprise_rejection_enterprise 
        FOREIGN KEY (enterprise_id) REFERENCES enterprises(id) ON DELETE SET NULL,
    CONSTRAINT fk_enterprise_rejection_admin 
        FOREIGN KEY (rejected_by) REFERENCES users(id) ON DELETE SET NULL
);

-- Table: project_rejections  
-- Purpose: Track rejection history for project validation requests
CREATE TABLE IF NOT EXISTS project_rejections (
    id BIGSERIAL PRIMARY KEY,
    project_id BIGINT,
    rejected_by BIGINT NOT NULL,
    rejection_reason TEXT,
    rejected_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    -- Store project info before deletion
    title VARCHAR(255),
    slug VARCHAR(255),
    enterprise_name VARCHAR(255),
    
    CONSTRAINT fk_project_rejection_project 
        FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE SET NULL,
    CONSTRAINT fk_project_rejection_admin 
        FOREIGN KEY (rejected_by) REFERENCES users(id) ON DELETE SET NULL
);

-- Indexes for performance
CREATE INDEX IF NOT EXISTS idx_enterprise_rejections_enterprise_id 
    ON enterprise_rejections(enterprise_id);
CREATE INDEX IF NOT EXISTS idx_enterprise_rejections_rejected_at 
    ON enterprise_rejections(rejected_at DESC);

CREATE INDEX IF NOT EXISTS idx_project_rejections_project_id 
    ON project_rejections(project_id);
CREATE INDEX IF NOT EXISTS idx_project_rejections_rejected_at 
    ON project_rejections(rejected_at DESC);

-- Comments for documentation
COMMENT ON TABLE enterprise_rejections IS 'Stores rejection history for enterprise verification requests with reasons';
COMMENT ON TABLE project_rejections IS 'Stores rejection history for project validation requests with reasons';

COMMENT ON COLUMN enterprise_rejections.rejection_reason IS 'Optional explanation for why the enterprise was rejected';
COMMENT ON COLUMN project_rejections.rejection_reason IS 'Optional explanation for why the project was rejected';
