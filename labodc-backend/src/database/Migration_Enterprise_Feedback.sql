-- Ensure enum exists
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'report_status_enum') THEN
        CREATE TYPE report_status_enum AS ENUM ('DRAFT', 'SUBMITTED', 'REVIEWED', 'PUBLISHED', 'ARCHIVED');
    END IF;
END $$;

-- Create table if missing
CREATE TABLE IF NOT EXISTS enterprise_feedback (
    id BIGSERIAL PRIMARY KEY,
    project_id BIGINT NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
    enterprise_id BIGINT NOT NULL REFERENCES enterprises(id) ON DELETE CASCADE,

    overall_rating DECIMAL(3,2) CHECK (overall_rating BETWEEN 0 AND 5),
    quality_rating DECIMAL(3,2),
    communication_rating DECIMAL(3,2),
    timeline_rating DECIMAL(3,2),
    professionalism_rating DECIMAL(3,2),

    positive_feedback TEXT,
    negative_feedback TEXT,
    suggestions TEXT,

    would_recommend BOOLEAN,
    would_work_again BOOLEAN,

    status report_status_enum DEFAULT 'DRAFT',
    submitted_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Add any missing columns if table already existed
ALTER TABLE enterprise_feedback
    ADD COLUMN IF NOT EXISTS project_id BIGINT,
    ADD COLUMN IF NOT EXISTS enterprise_id BIGINT,
    ADD COLUMN IF NOT EXISTS overall_rating DECIMAL(3,2),
    ADD COLUMN IF NOT EXISTS quality_rating DECIMAL(3,2),
    ADD COLUMN IF NOT EXISTS communication_rating DECIMAL(3,2),
    ADD COLUMN IF NOT EXISTS timeline_rating DECIMAL(3,2),
    ADD COLUMN IF NOT EXISTS professionalism_rating DECIMAL(3,2),
    ADD COLUMN IF NOT EXISTS positive_feedback TEXT,
    ADD COLUMN IF NOT EXISTS negative_feedback TEXT,
    ADD COLUMN IF NOT EXISTS suggestions TEXT,
    ADD COLUMN IF NOT EXISTS would_recommend BOOLEAN,
    ADD COLUMN IF NOT EXISTS would_work_again BOOLEAN,
    ADD COLUMN IF NOT EXISTS status report_status_enum DEFAULT 'DRAFT',
    ADD COLUMN IF NOT EXISTS submitted_at TIMESTAMP,
    ADD COLUMN IF NOT EXISTS created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP;

-- Indexes
CREATE INDEX IF NOT EXISTS idx_enterprise_feedback_project ON enterprise_feedback(project_id);
CREATE INDEX IF NOT EXISTS idx_enterprise_feedback_enterprise ON enterprise_feedback(enterprise_id);

COMMENT ON TABLE enterprise_feedback IS 'Ðánh giá c?a doanh nghi?p v? d? án';
