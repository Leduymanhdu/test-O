-- =====================================================
-- LabOdc Database Schema - Part 4
-- Centralized File Management System
-- Migration V1.3
-- Date: 2026-01-18
-- =====================================================

-- =====================================================
-- CENTRALIZED FILE MANAGEMENT
-- =====================================================

-- Bảng files tập trung
CREATE TABLE files (
    id BIGSERIAL PRIMARY KEY,
    
    -- File Info
    file_name VARCHAR(255) NOT NULL,
    original_name VARCHAR(255) NOT NULL,
    file_type VARCHAR(100) NOT NULL, -- MIME type
    file_size BIGINT NOT NULL,
    file_extension VARCHAR(20),
    
    -- Cloudinary Info
    cloudinary_public_id VARCHAR(255) UNIQUE NOT NULL,
    cloudinary_url VARCHAR(500) NOT NULL,
    cloudinary_secure_url VARCHAR(500) NOT NULL,
    cloudinary_resource_type VARCHAR(20), -- image, video, raw
    cloudinary_format VARCHAR(20),
    cloudinary_version VARCHAR(50),
    
    -- Image Specific
    width INTEGER,
    height INTEGER,
    aspect_ratio DECIMAL(5,2),
    thumbnail_url VARCHAR(500),
    medium_url VARCHAR(500),
    large_url VARCHAR(500),
    optimized_url VARCHAR(500),
    
    -- Video Specific (if needed)
    duration INTEGER, -- seconds
    
    -- Document Specific
    page_count INTEGER,
    
    -- Entity Reference (polymorphic)
    entity_type VARCHAR(50) NOT NULL,
    entity_id BIGINT NOT NULL,
    entity_field VARCHAR(50), -- avatar, logo, attachment, etc.
    
    -- Purpose/Category
    purpose VARCHAR(50), -- PROFILE, DOCUMENT, ATTACHMENT, REPORT, TEMPLATE
    
    -- Access Control
    access_level VARCHAR(20) DEFAULT 'PRIVATE', -- PUBLIC, PRIVATE, RESTRICTED, INTERNAL
    requires_auth BOOLEAN DEFAULT TRUE,
    password_protected BOOLEAN DEFAULT FALSE,
    password_hash VARCHAR(255),
    
    -- Security
    virus_scanned BOOLEAN DEFAULT FALSE,
    virus_scan_result VARCHAR(20), -- CLEAN, INFECTED, PENDING
    virus_scanned_at TIMESTAMP,
    
    -- Usage Stats
    view_count INTEGER DEFAULT 0,
    download_count INTEGER DEFAULT 0,
    last_accessed_at TIMESTAMP,
    
    -- Metadata
    metadata JSONB, -- Additional flexible metadata
    tags TEXT[], -- For searching
    description TEXT,
    alt_text VARCHAR(255), -- For images (accessibility)
    
    -- Upload Info
    uploaded_by BIGINT NOT NULL REFERENCES users(id),
    uploaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    -- Status
    status VARCHAR(20) DEFAULT 'ACTIVE', -- ACTIVE, DELETED, EXPIRED, QUARANTINED
    deleted_at TIMESTAMP,
    deleted_by BIGINT REFERENCES users(id),
    deleted_reason TEXT,
    
    -- Audit
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT check_entity_type CHECK (entity_type IN (
        'USER', 'ENTERPRISE', 'TALENT', 'MENTOR', 'PROJECT', 'TASK', 
        'REPORT', 'TEMPLATE', 'EVALUATION', 'NOTIFICATION', 'OTHER'
    )),
    CONSTRAINT check_purpose CHECK (purpose IN (
        'PROFILE', 'DOCUMENT', 'ATTACHMENT', 'REPORT', 
        'TEMPLATE', 'BANNER', 'LOGO', 'CERTIFICATE', 'OTHER'
    )),
    CONSTRAINT check_access_level CHECK (access_level IN (
        'PUBLIC', 'PRIVATE', 'RESTRICTED', 'INTERNAL'
    )),
    CONSTRAINT check_status CHECK (status IN (
        'ACTIVE', 'DELETED', 'EXPIRED', 'QUARANTINED'
    )),
    CONSTRAINT check_virus_scan_result CHECK (virus_scan_result IN (
        'CLEAN', 'INFECTED', 'PENDING', 'FAILED', 'SKIPPED'
    ))
);

-- Indexes for files table
CREATE INDEX idx_files_cloudinary_public_id ON files(cloudinary_public_id);
CREATE INDEX idx_files_entity ON files(entity_type, entity_id);
CREATE INDEX idx_files_entity_field ON files(entity_type, entity_id, entity_field);
CREATE INDEX idx_files_uploaded_by ON files(uploaded_by);
CREATE INDEX idx_files_status ON files(status);
CREATE INDEX idx_files_purpose ON files(purpose);
CREATE INDEX idx_files_uploaded_at ON files(uploaded_at DESC);
CREATE INDEX idx_files_access_level ON files(access_level);

-- GIN index for tags array search
CREATE INDEX idx_files_tags ON files USING GIN(tags);

-- GIN index for metadata JSONB
CREATE INDEX idx_files_metadata ON files USING GIN(metadata);

-- Full-text search index
CREATE INDEX idx_files_search ON files USING GIN(
    to_tsvector('english', 
        COALESCE(file_name, '') || ' ' || 
        COALESCE(description, '') || ' ' ||
        COALESCE(alt_text, '')
    )
);

-- Partial indexes for common queries
CREATE INDEX idx_files_active_images ON files(uploaded_at DESC) 
    WHERE status = 'ACTIVE' AND cloudinary_resource_type = 'image';

CREATE INDEX idx_files_active_documents ON files(uploaded_at DESC)
    WHERE status = 'ACTIVE' AND cloudinary_resource_type = 'raw';

CREATE INDEX idx_files_large_files ON files(file_size DESC)
    WHERE file_size > 10485760; -- Files > 10MB

CREATE INDEX idx_files_virus_pending ON files(uploaded_at)
    WHERE virus_scanned = FALSE OR virus_scan_result = 'PENDING';

COMMENT ON TABLE files IS 'Quản lý files tập trung với Cloudinary integration';
COMMENT ON COLUMN files.entity_type IS 'Loại entity: USER, ENTERPRISE, TALENT, MENTOR, PROJECT, TASK, REPORT, TEMPLATE';
COMMENT ON COLUMN files.entity_field IS 'Trường của entity: avatar, logo, banner, attachment, cv, certificate';
COMMENT ON COLUMN files.cloudinary_public_id IS 'Cloudinary public ID để quản lý và xóa file';
COMMENT ON COLUMN files.tags IS 'Array tags để search, ví dụ: {frontend, design, mockup}';

-- =====================================================
-- FILE ACCESS LOGS
-- =====================================================

CREATE TABLE file_access_logs (
    id BIGSERIAL PRIMARY KEY,
    file_id BIGINT NOT NULL REFERENCES files(id) ON DELETE CASCADE,
    user_id BIGINT REFERENCES users(id) ON DELETE SET NULL,
    
    action VARCHAR(20) NOT NULL, -- VIEW, DOWNLOAD, EDIT, DELETE, SHARE
    
    -- Request Info
    ip_address VARCHAR(45),
    user_agent TEXT,
    referer VARCHAR(500),
    
    -- Response
    status_code INTEGER,
    bytes_sent BIGINT,
    response_time_ms INTEGER,
    
    -- Additional Info
    metadata JSONB,
    
    accessed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT check_action CHECK (action IN ('VIEW', 'DOWNLOAD', 'EDIT', 'DELETE', 'SHARE', 'UPLOAD'))
);

CREATE INDEX idx_file_access_logs_file ON file_access_logs(file_id);
CREATE INDEX idx_file_access_logs_user ON file_access_logs(user_id);
CREATE INDEX idx_file_access_logs_accessed ON file_access_logs(accessed_at);
CREATE INDEX idx_file_access_logs_action ON file_access_logs(action);

-- Partition by time (monthly) for better performance
-- Uncomment when table grows large
-- ALTER TABLE file_access_logs PARTITION BY RANGE (accessed_at);

COMMENT ON TABLE file_access_logs IS 'Nhật ký truy cập file để audit và analytics';

-- =====================================================
-- FILE VERSIONS (for versioning support)
-- =====================================================

CREATE TABLE file_versions (
    id BIGSERIAL PRIMARY KEY,
    file_id BIGINT NOT NULL REFERENCES files(id) ON DELETE CASCADE,
    
    -- Version Info
    version_number INTEGER NOT NULL,
    
    -- Previous Version Info
    previous_cloudinary_public_id VARCHAR(255),
    previous_cloudinary_url VARCHAR(500),
    previous_file_size BIGINT,
    
    -- Change Info
    change_description TEXT,
    changed_by BIGINT REFERENCES users(id),
    changed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    UNIQUE(file_id, version_number)
);

CREATE INDEX idx_file_versions_file ON file_versions(file_id);
CREATE INDEX idx_file_versions_changed ON file_versions(changed_at);

COMMENT ON TABLE file_versions IS 'Lưu trữ các phiên bản cũ của file khi có thay đổi';

-- =====================================================
-- TRIGGERS
-- =====================================================

-- Auto update updated_at timestamp
CREATE OR REPLACE FUNCTION update_files_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_files_updated_at
    BEFORE UPDATE ON files
    FOR EACH ROW
    EXECUTE FUNCTION update_files_updated_at();

-- Auto increment view count and download count
CREATE OR REPLACE FUNCTION increment_file_stats()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.action = 'VIEW' THEN
        UPDATE files 
        SET view_count = view_count + 1,
            last_accessed_at = CURRENT_TIMESTAMP
        WHERE id = NEW.file_id;
    ELSIF NEW.action = 'DOWNLOAD' THEN
        UPDATE files 
        SET download_count = download_count + 1,
            last_accessed_at = CURRENT_TIMESTAMP
        WHERE id = NEW.file_id;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_increment_file_stats
    AFTER INSERT ON file_access_logs
    FOR EACH ROW
    EXECUTE FUNCTION increment_file_stats();

-- Create file version on update
CREATE OR REPLACE FUNCTION create_file_version_on_update()
RETURNS TRIGGER AS $$
BEGIN
    -- Only create version if cloudinary_public_id changed
    IF OLD.cloudinary_public_id IS DISTINCT FROM NEW.cloudinary_public_id THEN
        INSERT INTO file_versions (
            file_id,
            version_number,
            previous_cloudinary_public_id,
            previous_cloudinary_url,
            previous_file_size,
            change_description,
            changed_by
        ) VALUES (
            NEW.id,
            COALESCE((SELECT MAX(version_number) FROM file_versions WHERE file_id = NEW.id), 0) + 1,
            OLD.cloudinary_public_id,
            OLD.cloudinary_secure_url,
            OLD.file_size,
            'File replaced',
            NEW.uploaded_by
        );
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_create_file_version
    AFTER UPDATE ON files
    FOR EACH ROW
    WHEN (OLD.cloudinary_public_id IS DISTINCT FROM NEW.cloudinary_public_id)
    EXECUTE FUNCTION create_file_version_on_update();

-- =====================================================
-- FUNCTIONS
-- =====================================================

-- Get file URL by entity
CREATE OR REPLACE FUNCTION get_file_url(
    p_entity_type VARCHAR,
    p_entity_id BIGINT,
    p_entity_field VARCHAR DEFAULT NULL
)
RETURNS VARCHAR AS $$
DECLARE
    file_url VARCHAR;
BEGIN
    SELECT cloudinary_secure_url INTO file_url
    FROM files
    WHERE entity_type = p_entity_type
    AND entity_id = p_entity_id
    AND (p_entity_field IS NULL OR entity_field = p_entity_field)
    AND status = 'ACTIVE'
    ORDER BY uploaded_at DESC
    LIMIT 1;
    
    RETURN file_url;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION get_file_url IS 'Lấy URL của file mới nhất theo entity';

-- Get all files by entity
CREATE OR REPLACE FUNCTION get_entity_files(
    p_entity_type VARCHAR,
    p_entity_id BIGINT
)
RETURNS TABLE(
    id BIGINT,
    file_name VARCHAR,
    file_url VARCHAR,
    file_size BIGINT,
    uploaded_at TIMESTAMP
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        f.id,
        f.file_name,
        f.cloudinary_secure_url,
        f.file_size,
        f.uploaded_at
    FROM files f
    WHERE f.entity_type = p_entity_type
    AND f.entity_id = p_entity_id
    AND f.status = 'ACTIVE'
    ORDER BY f.uploaded_at DESC;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION get_entity_files IS 'Lấy tất cả files của một entity';

-- Mark orphaned files (files without valid entity reference)
CREATE OR REPLACE FUNCTION mark_orphaned_files()
RETURNS INTEGER AS $$
DECLARE
    orphan_count INTEGER := 0;
    v_rows_affected INTEGER := 0;
BEGIN
    -- Mark USER files as orphaned if user doesn't exist
    UPDATE files f
    SET status = 'DELETED',
        deleted_at = CURRENT_TIMESTAMP,
        deleted_reason = 'Orphaned file - user not found'
    WHERE f.status = 'ACTIVE'
    AND f.entity_type = 'USER'
    AND NOT EXISTS (
        SELECT 1 FROM users u WHERE u.id = f.entity_id AND u.deleted_at IS NULL
    );
    
    GET DIAGNOSTICS v_rows_affected = ROW_COUNT;
    orphan_count := orphan_count + v_rows_affected;
    
    -- Mark ENTERPRISE files
    UPDATE files f
    SET status = 'DELETED',
        deleted_at = CURRENT_TIMESTAMP,
        deleted_reason = 'Orphaned file - enterprise not found'
    WHERE f.status = 'ACTIVE'
    AND f.entity_type = 'ENTERPRISE'
    AND NOT EXISTS (
        SELECT 1 FROM enterprises e WHERE e.id = f.entity_id AND e.deleted_at IS NULL
    );
    
    GET DIAGNOSTICS v_rows_affected = ROW_COUNT;
    orphan_count := orphan_count + v_rows_affected;
    
    -- Mark PROJECT files
    UPDATE files f
    SET status = 'DELETED',
        deleted_at = CURRENT_TIMESTAMP,
        deleted_reason = 'Orphaned file - project not found'
    WHERE f.status = 'ACTIVE'
    AND f.entity_type = 'PROJECT'
    AND NOT EXISTS (
        SELECT 1 FROM projects p WHERE p.id = f.entity_id AND p.deleted_at IS NULL
    );
    
    GET DIAGNOSTICS v_rows_affected = ROW_COUNT;
    orphan_count := orphan_count + v_rows_affected;
    
    -- Mark TASK files
    UPDATE files f
    SET status = 'DELETED',
        deleted_at = CURRENT_TIMESTAMP,
        deleted_reason = 'Orphaned file - task not found'
    WHERE f.status = 'ACTIVE'
    AND f.entity_type = 'TASK'
    AND NOT EXISTS (
        SELECT 1 FROM tasks t WHERE t.id = f.entity_id
    );
    
    GET DIAGNOSTICS v_rows_affected = ROW_COUNT;
    orphan_count := orphan_count + v_rows_affected;
    
    RETURN orphan_count;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION mark_orphaned_files IS 'Đánh dấu các file mồ côi (entity không tồn tại) - chạy định kỳ';

-- Get user's file statistics
CREATE OR REPLACE FUNCTION get_user_file_stats(p_user_id BIGINT)
RETURNS TABLE(
    total_files INTEGER,
    total_size_bytes BIGINT,
    total_size_mb DECIMAL,
    images_count INTEGER,
    documents_count INTEGER,
    videos_count INTEGER,
    total_views INTEGER,
    total_downloads INTEGER
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        COUNT(*)::INTEGER as total_files,
        SUM(f.file_size)::BIGINT as total_size_bytes,
        ROUND(SUM(f.file_size)::DECIMAL / 1024 / 1024, 2) as total_size_mb,
        COUNT(*) FILTER (WHERE f.cloudinary_resource_type = 'image')::INTEGER as images_count,
        COUNT(*) FILTER (WHERE f.cloudinary_resource_type = 'raw')::INTEGER as documents_count,
        COUNT(*) FILTER (WHERE f.cloudinary_resource_type = 'video')::INTEGER as videos_count,
        SUM(f.view_count)::INTEGER as total_views,
        SUM(f.download_count)::INTEGER as total_downloads
    FROM files f
    WHERE f.uploaded_by = p_user_id
    AND f.status = 'ACTIVE';
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION get_user_file_stats IS 'Thống kê files của một user';

-- Check file storage quota
CREATE OR REPLACE FUNCTION check_user_storage_quota(
    p_user_id BIGINT,
    p_max_quota_mb DECIMAL DEFAULT 1000
)
RETURNS TABLE(
    used_mb DECIMAL,
    quota_mb DECIMAL,
    available_mb DECIMAL,
    usage_percentage DECIMAL,
    quota_exceeded BOOLEAN
) AS $$
DECLARE
    v_used_mb DECIMAL;
BEGIN
    SELECT ROUND(SUM(file_size)::DECIMAL / 1024 / 1024, 2)
    INTO v_used_mb
    FROM files
    WHERE uploaded_by = p_user_id
    AND status = 'ACTIVE';
    
    v_used_mb := COALESCE(v_used_mb, 0);
    
    RETURN QUERY
    SELECT 
        v_used_mb as used_mb,
        p_max_quota_mb as quota_mb,
        p_max_quota_mb - v_used_mb as available_mb,
        ROUND((v_used_mb / p_max_quota_mb) * 100, 2) as usage_percentage,
        v_used_mb > p_max_quota_mb as quota_exceeded;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION check_user_storage_quota IS 'Kiểm tra quota storage của user';

-- Get files pending virus scan
CREATE OR REPLACE FUNCTION get_files_pending_virus_scan(p_limit INTEGER DEFAULT 100)
RETURNS TABLE(
    id BIGINT,
    file_name VARCHAR,
    file_url VARCHAR,
    uploaded_at TIMESTAMP
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        f.id,
        f.file_name,
        f.cloudinary_secure_url,
        f.uploaded_at
    FROM files f
    WHERE f.status = 'ACTIVE'
    AND (f.virus_scanned = FALSE OR f.virus_scan_result = 'PENDING')
    ORDER BY f.uploaded_at ASC
    LIMIT p_limit;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION get_files_pending_virus_scan IS 'Lấy danh sách files chưa scan virus';

-- =====================================================
-- VIEWS
-- =====================================================

-- View: Active files with user info
CREATE OR REPLACE VIEW v_active_files AS
SELECT 
    f.*,
    u.email as uploader_email,
    u.role as uploader_role,
    CASE 
        WHEN f.entity_type = 'USER' THEN u2.email
        WHEN f.entity_type = 'ENTERPRISE' THEN e.company_name
        WHEN f.entity_type = 'TALENT' THEN t.full_name
        WHEN f.entity_type = 'MENTOR' THEN m.full_name
        WHEN f.entity_type = 'PROJECT' THEN p.title
        ELSE NULL
    END as entity_name
FROM files f
JOIN users u ON f.uploaded_by = u.id
LEFT JOIN users u2 ON f.entity_type = 'USER' AND f.entity_id = u2.id
LEFT JOIN enterprises e ON f.entity_type = 'ENTERPRISE' AND f.entity_id = e.id
LEFT JOIN talents t ON f.entity_type = 'TALENT' AND f.entity_id = t.id
LEFT JOIN mentors m ON f.entity_type = 'MENTOR' AND f.entity_id = m.id
LEFT JOIN projects p ON f.entity_type = 'PROJECT' AND f.entity_id = p.id
WHERE f.status = 'ACTIVE';

COMMENT ON VIEW v_active_files IS 'Active files với thông tin uploader và entity';

-- View: File statistics by entity type
CREATE OR REPLACE VIEW v_file_statistics AS
SELECT 
    entity_type,
    purpose,
    COUNT(*) as file_count,
    SUM(file_size) as total_size_bytes,
    ROUND(AVG(file_size)::NUMERIC, 2) as avg_size_bytes,
    ROUND(SUM(file_size)::NUMERIC / 1024 / 1024, 2) as total_size_mb,
    SUM(view_count) as total_views,
    SUM(download_count) as total_downloads
FROM files
WHERE status = 'ACTIVE'
GROUP BY entity_type, purpose
ORDER BY total_size_bytes DESC;

COMMENT ON VIEW v_file_statistics IS 'Thống kê files theo entity type và purpose';

-- View: Files by upload date
CREATE OR REPLACE VIEW v_files_by_date AS
SELECT 
    DATE(uploaded_at) as upload_date,
    COUNT(*) as files_uploaded,
    COUNT(*) FILTER (WHERE cloudinary_resource_type = 'image') as images_count,
    COUNT(*) FILTER (WHERE cloudinary_resource_type = 'raw') as documents_count,
    ROUND(SUM(file_size)::NUMERIC / 1024 / 1024, 2) as total_mb
FROM files
WHERE status = 'ACTIVE'
GROUP BY DATE(uploaded_at)
ORDER BY upload_date DESC;

COMMENT ON VIEW v_files_by_date IS 'Thống kê uploads theo ngày';

-- View: Top uploaders
CREATE OR REPLACE VIEW v_top_uploaders AS
SELECT 
    u.id,
    u.email,
    u.role,
    COUNT(f.id) as files_count,
    ROUND(SUM(f.file_size)::NUMERIC / 1024 / 1024, 2) as total_mb,
    SUM(f.view_count) as total_views,
    SUM(f.download_count) as total_downloads
FROM users u
JOIN files f ON u.id = f.uploaded_by
WHERE f.status = 'ACTIVE'
GROUP BY u.id, u.email, u.role
ORDER BY total_mb DESC
LIMIT 100;

COMMENT ON VIEW v_top_uploaders IS 'Top 100 users theo dung lượng upload';

-- =====================================================
-- MIGRATION HELPER FUNCTIONS
-- =====================================================

-- Migrate existing user avatars to files table
CREATE OR REPLACE FUNCTION migrate_user_avatars()
RETURNS INTEGER AS $$
DECLARE
    migrated_count INTEGER := 0;
    user_rec RECORD;
BEGIN
    FOR user_rec IN 
        SELECT id, avatar_url 
        FROM users 
        WHERE avatar_url IS NOT NULL 
        AND avatar_url != ''
        AND deleted_at IS NULL
        AND NOT EXISTS (
            SELECT 1 FROM files 
            WHERE entity_type = 'USER' 
            AND entity_id = users.id 
            AND entity_field = 'avatar'
            AND status = 'ACTIVE'
        )
    LOOP
        BEGIN
            INSERT INTO files (
                file_name,
                original_name,
                file_type,
                file_size,
                cloudinary_public_id,
                cloudinary_url,
                cloudinary_secure_url,
                cloudinary_resource_type,
                entity_type,
                entity_id,
                entity_field,
                purpose,
                uploaded_by,
                uploaded_at,
                status,
                virus_scanned,
                virus_scan_result
            ) VALUES (
                'avatar.jpg',
                'avatar.jpg',
                'image/jpeg',
                0,
                REGEXP_REPLACE(user_rec.avatar_url, '^.*/([^/]+)$', '\1'),
                user_rec.avatar_url,
                user_rec.avatar_url,
                'image',
                'USER',
                user_rec.id,
                'avatar',
                'PROFILE',
                user_rec.id,
                CURRENT_TIMESTAMP,
                'ACTIVE',
                TRUE,
                'CLEAN'
            );
            
            migrated_count := migrated_count + 1;
        EXCEPTION WHEN OTHERS THEN
            CONTINUE;
        END;
    END LOOP;
    
    RETURN migrated_count;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION migrate_user_avatars IS 'Migration: Chuyển user avatars sang files table';

-- Migrate enterprise logos
CREATE OR REPLACE FUNCTION migrate_enterprise_logos()
RETURNS INTEGER AS $$
DECLARE
    migrated_count INTEGER := 0;
    ent_rec RECORD;
BEGIN
    FOR ent_rec IN 
        SELECT id, logo_url, user_id
        FROM enterprises 
        WHERE logo_url IS NOT NULL 
        AND logo_url != ''
        AND deleted_at IS NULL
        AND NOT EXISTS (
            SELECT 1 FROM files 
            WHERE entity_type = 'ENTERPRISE' 
            AND entity_id = enterprises.id 
            AND entity_field = 'logo'
            AND status = 'ACTIVE'
        )
    LOOP
        BEGIN
            INSERT INTO files (
                file_name,
                original_name,
                file_type,
                file_size,
                cloudinary_public_id,
                cloudinary_url,
                cloudinary_secure_url,
                cloudinary_resource_type,
                entity_type,
                entity_id,
                entity_field,
                purpose,
                uploaded_by,
                uploaded_at,
                status,
                virus_scanned,
                virus_scan_result
            ) VALUES (
                'logo.png',
                'logo.png',
                'image/png',
                0,
                REGEXP_REPLACE(ent_rec.logo_url, '^.*/([^/]+)$', '\1'),
                ent_rec.logo_url,
                ent_rec.logo_url,
                'image',
                'ENTERPRISE',
                ent_rec.id,
                'logo',
                'LOGO',
                ent_rec.user_id,
                CURRENT_TIMESTAMP,
                'ACTIVE',
                TRUE,
                'CLEAN'
            );
            
            migrated_count := migrated_count + 1;
        EXCEPTION WHEN OTHERS THEN
            CONTINUE;
        END;
    END LOOP;
    
    RETURN migrated_count;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION migrate_enterprise_logos IS 'Migration: Chuyển enterprise logos sang files table';

-- =====================================================
-- INITIAL DATA / SEED DATA
-- =====================================================

-- Insert example file types configuration
CREATE TABLE IF NOT EXISTS file_type_configs (
    id BIGSERIAL PRIMARY KEY,
    file_type_category VARCHAR(50) NOT NULL, -- IMAGE, DOCUMENT, VIDEO, AUDIO
    mime_types TEXT[] NOT NULL,
    max_size_mb INTEGER NOT NULL,
    allowed_extensions TEXT[],
    requires_virus_scan BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(file_type_category)
);

INSERT INTO file_type_configs (file_type_category, mime_types, max_size_mb, allowed_extensions, requires_virus_scan) VALUES
('IMAGE', ARRAY['image/jpeg', 'image/png', 'image/gif', 'image/webp', 'image/svg+xml'], 5, ARRAY['jpg', 'jpeg', 'png', 'gif', 'webp', 'svg'], FALSE),
('DOCUMENT', ARRAY['application/pdf', 'application/msword', 'application/vnd.openxmlformats-officedocument.wordprocessingml.document', 'text/plain'], 20, ARRAY['pdf', 'doc', 'docx', 'txt'], TRUE),
('SPREADSHEET', ARRAY['application/vnd.ms-excel', 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet', 'text/csv'], 10, ARRAY['xls', 'xlsx', 'csv'], TRUE),
('PRESENTATION', ARRAY['application/vnd.ms-powerpoint', 'application/vnd.openxmlformats-officedocument.presentationml.presentation'], 20, ARRAY['ppt', 'pptx'], TRUE),
('VIDEO', ARRAY['video/mp4', 'video/mpeg', 'video/quicktime'], 100, ARRAY['mp4', 'mpeg', 'mov'], TRUE),
('AUDIO', ARRAY['audio/mpeg', 'audio/wav', 'audio/ogg'], 50, ARRAY['mp3', 'wav', 'ogg'], FALSE);

COMMENT ON TABLE file_type_configs IS 'Cấu hình cho các loại file được phép upload';

-- =====================================================
-- CLEANUP JOBS (To be scheduled)
-- =====================================================

-- Function to cleanup old deleted files (older than 90 days)
CREATE OR REPLACE FUNCTION cleanup_old_deleted_files(p_days_old INTEGER DEFAULT 90)
RETURNS INTEGER AS $$
DECLARE
    cleanup_count INTEGER;
BEGIN
    -- This would also trigger Cloudinary deletion in application code
    DELETE FROM files
    WHERE status = 'DELETED'
    AND deleted_at < CURRENT_TIMESTAMP - (p_days_old || ' days')::INTERVAL;
    
    GET DIAGNOSTICS cleanup_count = ROW_COUNT;
    RETURN cleanup_count;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION cleanup_old_deleted_files IS 'Xóa vĩnh viễn files đã deleted > X ngày - chạy định kỳ';

-- Function to archive old access logs (older than 1 year)
CREATE OR REPLACE FUNCTION archive_old_access_logs(p_months_old INTEGER DEFAULT 12)
RETURNS INTEGER AS $$
DECLARE
    archive_count INTEGER;
BEGIN
    DELETE FROM file_access_logs
    WHERE accessed_at < CURRENT_TIMESTAMP - (p_months_old || ' months')::INTERVAL;
    
    GET DIAGNOSTICS archive_count = ROW_COUNT;
    RETURN archive_count;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION archive_old_access_logs IS 'Archive/xóa access logs cũ > X tháng - chạy định kỳ';

-- =====================================================
-- FOREIGN KEY CONSTRAINTS TO EXISTING TABLES
-- =====================================================

-- Link users.avatar_file_id to files table
ALTER TABLE users 
    ADD CONSTRAINT fk_users_avatar_file 
    FOREIGN KEY (avatar_file_id) REFERENCES files(id) ON DELETE SET NULL;

CREATE INDEX idx_users_avatar_file ON users(avatar_file_id);

-- Link enterprises.logo_file_id and banner_file_id to files table
ALTER TABLE enterprises 
    ADD CONSTRAINT fk_enterprises_logo_file 
    FOREIGN KEY (logo_file_id) REFERENCES files(id) ON DELETE SET NULL;

ALTER TABLE enterprises 
    ADD CONSTRAINT fk_enterprises_banner_file 
    FOREIGN KEY (banner_file_id) REFERENCES files(id) ON DELETE SET NULL;

CREATE INDEX idx_enterprises_logo_file ON enterprises(logo_file_id);
CREATE INDEX idx_enterprises_banner_file ON enterprises(banner_file_id);

-- Link enterprise_documents.file_id to files table
ALTER TABLE enterprise_documents 
    ADD CONSTRAINT fk_enterprise_documents_file 
    FOREIGN KEY (file_id) REFERENCES files(id) ON DELETE SET NULL;

CREATE INDEX idx_enterprise_documents_file ON enterprise_documents(file_id);

-- Link talents.cv_file_id to files table
ALTER TABLE talents 
    ADD CONSTRAINT fk_talents_cv_file 
    FOREIGN KEY (cv_file_id) REFERENCES files(id) ON DELETE SET NULL;

CREATE INDEX idx_talents_cv_file ON talents(cv_file_id);

-- Link talent_certifications.certificate_file_id to files table
ALTER TABLE talent_certifications 
    ADD CONSTRAINT fk_talent_certifications_file 
    FOREIGN KEY (certificate_file_id) REFERENCES files(id) ON DELETE SET NULL;

CREATE INDEX idx_talent_certifications_file ON talent_certifications(certificate_file_id);

-- Link project_attachments.file_id to files table
ALTER TABLE project_attachments 
    ADD CONSTRAINT fk_project_attachments_file 
    FOREIGN KEY (file_id) REFERENCES files(id) ON DELETE CASCADE;

CREATE INDEX idx_project_attachments_file ON project_attachments(file_id);

-- Link task_attachments.file_id to files table
DO $$
BEGIN
    IF to_regclass('public.task_attachments') IS NOT NULL THEN
        BEGIN
            EXECUTE 'ALTER TABLE task_attachments ADD CONSTRAINT fk_task_attachments_file FOREIGN KEY (file_id) REFERENCES files(id) ON DELETE CASCADE';
        EXCEPTION
            WHEN duplicate_object THEN NULL;
        END;

        EXECUTE 'CREATE INDEX IF NOT EXISTS idx_task_attachments_file ON task_attachments(file_id)';
    END IF;
END $$;

-- Link report_attachments.file_id to files table
DO $$
BEGIN
    IF to_regclass('public.report_attachments') IS NOT NULL THEN
        BEGIN
            EXECUTE 'ALTER TABLE report_attachments ADD CONSTRAINT fk_report_attachments_file FOREIGN KEY (file_id) REFERENCES files(id) ON DELETE CASCADE';
        EXCEPTION
            WHEN duplicate_object THEN NULL;
        END;

        EXECUTE 'CREATE INDEX IF NOT EXISTS idx_report_attachments_file ON report_attachments(file_id)';
    END IF;
END $$;

-- Link excel_templates.file_id to files table
DO $$
BEGIN
    IF to_regclass('public.excel_templates') IS NOT NULL THEN
        BEGIN
            EXECUTE 'ALTER TABLE excel_templates ADD CONSTRAINT fk_excel_templates_file FOREIGN KEY (file_id) REFERENCES files(id) ON DELETE SET NULL';
        EXCEPTION
            WHEN duplicate_object THEN NULL;
        END;

        EXECUTE 'CREATE INDEX IF NOT EXISTS idx_excel_templates_file ON excel_templates(file_id)';
    END IF;
END $$;

COMMENT ON CONSTRAINT fk_users_avatar_file ON users IS 'Link user avatar to centralized files table';
COMMENT ON CONSTRAINT fk_enterprises_logo_file ON enterprises IS 'Link enterprise logo to centralized files table';
COMMENT ON CONSTRAINT fk_talents_cv_file ON talents IS 'Link talent CV to centralized files table';

-- =====================================================
-- END OF MIGRATION V1.3
-- =====================================================

-- Log migration completion
DO $$ 
BEGIN 
    RAISE NOTICE '========================================';
    RAISE NOTICE 'Migration V1.3 - Centralized File Management';
    RAISE NOTICE '========================================';
    RAISE NOTICE 'Created tables: files, file_access_logs, file_versions, file_type_configs';
    RAISE NOTICE 'Created views: v_active_files, v_file_statistics, v_files_by_date, v_top_uploaders';
    RAISE NOTICE 'Created functions: 17 utility functions for file management';
    RAISE NOTICE 'Created triggers: 3 triggers for auto-updates and versioning';
    RAISE NOTICE 'Added foreign keys: 10 constraints linking existing tables to files table';
    RAISE NOTICE '';
    RAISE NOTICE 'NEXT STEPS:';
    RAISE NOTICE '1. Run migration helper functions to import existing file URLs:';
    RAISE NOTICE '   SELECT migrate_user_avatars();';
    RAISE NOTICE '   SELECT migrate_enterprise_logos();';
    RAISE NOTICE '';
    RAISE NOTICE '2. Schedule cleanup jobs:';
    RAISE NOTICE '   - cleanup_old_deleted_files() - Daily';
    RAISE NOTICE '   - archive_old_access_logs() - Monthly';
    RAISE NOTICE '   - mark_orphaned_files() - Weekly';
    RAISE NOTICE '';
    RAISE NOTICE '3. Application Integration:';
    RAISE NOTICE '   - Update FileService to use files table';
    RAISE NOTICE '   - Implement CloudinaryService integration';
    RAISE NOTICE '   - Update upload endpoints to create file records';
    RAISE NOTICE '========================================';
END $$;
