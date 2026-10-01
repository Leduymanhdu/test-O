-- =====================================================
-- Migration: Convert enterprise.verified (boolean) to status (enum)
-- Date: 2026-02-02
-- Purpose: Change verification model to status-based approach
-- =====================================================

-- Step 1: Create enterprise_status enum type
DO $$ BEGIN
    CREATE TYPE enterprise_status_enum AS ENUM ('PENDING', 'APPROVED', 'REJECTED');
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

-- Step 2: Add new status column
ALTER TABLE enterprises ADD COLUMN IF NOT EXISTS status enterprise_status_enum;

-- Step 3: Migrate existing data
-- NULL verified -> PENDING
-- TRUE verified -> APPROVED  
-- FALSE verified -> REJECTED
UPDATE enterprises 
SET status = CASE 
    WHEN verified IS NULL THEN 'PENDING'::enterprise_status_enum
    WHEN verified = TRUE THEN 'APPROVED'::enterprise_status_enum
    WHEN verified = FALSE THEN 'REJECTED'::enterprise_status_enum
END
WHERE status IS NULL;

-- Step 4: Set status as NOT NULL with default
ALTER TABLE enterprises ALTER COLUMN status SET DEFAULT 'PENDING'::enterprise_status_enum;
ALTER TABLE enterprises ALTER COLUMN status SET NOT NULL;

-- Step 5: Create index on status
CREATE INDEX IF NOT EXISTS idx_enterprises_status ON enterprises(status);

-- Step 6: Drop old verified column and index
DROP INDEX IF EXISTS idx_enterprises_verified;
ALTER TABLE enterprises DROP COLUMN IF EXISTS verified;

-- Step 7: Add comment
COMMENT ON COLUMN enterprises.status IS 'Enterprise verification status: PENDING (chờ xác thực), APPROVED (đã duyệt), REJECTED (từ chối)';

-- =====================================================
-- Verification: Check migration results
-- =====================================================
-- Run this to verify the migration:
-- SELECT status, COUNT(*) FROM enterprises GROUP BY status;
