-- =====================================================
-- Migration: Change project validation from boolean to status string
-- Date: 2026-02-03
-- Purpose: Support pending/approved/rejected status instead of true/false
-- =====================================================

-- Step 1: Add new column with string type
ALTER TABLE projects 
ADD COLUMN validation_status VARCHAR(20);

-- Step 2: Migrate existing data
-- validated = true -> 'approved'
-- validated = false AND rejection_reason IS NOT NULL -> 'rejected'  
-- validated = false AND rejection_reason IS NULL -> 'pending'
UPDATE projects 
SET validation_status = CASE 
    WHEN validated = TRUE THEN 'approved'
    WHEN validated = FALSE AND rejection_reason IS NOT NULL THEN 'rejected'
    WHEN validated = FALSE AND rejection_reason IS NULL THEN 'pending'
    ELSE 'pending'
END;

-- Step 3: Drop old boolean column
ALTER TABLE projects DROP COLUMN validated;

-- Step 4: Rename new column to 'validated'
ALTER TABLE projects RENAME COLUMN validation_status TO validated;

-- Step 5: Set default and not null constraint
ALTER TABLE projects 
ALTER COLUMN validated SET DEFAULT 'pending',
ALTER COLUMN validated SET NOT NULL;

-- Step 6: Add check constraint for valid statuses
ALTER TABLE projects
ADD CONSTRAINT check_validation_status 
CHECK (validated IN ('pending', 'approved', 'rejected'));

-- Create index for filtering
CREATE INDEX idx_projects_validated ON projects(validated);

-- Comments for documentation
COMMENT ON COLUMN projects.validated IS 'Project validation status: pending, approved, or rejected';

-- =====================================================
-- Verify migration
-- =====================================================
-- SELECT validated, COUNT(*) FROM projects GROUP BY validated;
