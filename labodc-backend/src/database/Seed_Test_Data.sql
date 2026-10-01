-- =====================================================
-- SEED DATA FOR LABODC DATABASE - SCHEMA-MATCHED VERSION
-- =====================================================
-- Mục đích: Tạo dữ liệu mẫu phù hợp với schema thực tế
-- Password cho tất cả users: 123123
-- BCrypt hash: $2a$12$8pC/5kx6500tN2HEkDaPLeVR3mg.RWvLDsLADL6lioo53laEWJhXu
-- =====================================================

-- =====================================================
-- CLEANUP: XÓA DỮ LIỆU CŨ (NẾU CÓ)
-- =====================================================
DO $$
BEGIN
    RAISE NOTICE '========================================';
    RAISE NOTICE 'CLEANING UP OLD DATA...';
    RAISE NOTICE '========================================';
END $$;

-- Xóa theo thứ tự ngược lại (child tables trước)
TRUNCATE TABLE project_milestones CASCADE;
TRUNCATE TABLE project_skill_requirements CASCADE;
TRUNCATE TABLE project_technologies CASCADE;
TRUNCATE TABLE project_members CASCADE;
TRUNCATE TABLE projects CASCADE;
TRUNCATE TABLE mentor_expertise CASCADE;
TRUNCATE TABLE mentors CASCADE;
TRUNCATE TABLE talent_skills CASCADE;
TRUNCATE TABLE talents CASCADE;
TRUNCATE TABLE enterprises CASCADE;
TRUNCATE TABLE users CASCADE;

-- Reset sequences
ALTER SEQUENCE IF EXISTS users_id_seq RESTART WITH 1;
ALTER SEQUENCE IF EXISTS enterprises_id_seq RESTART WITH 1;
ALTER SEQUENCE IF EXISTS talents_id_seq RESTART WITH 1;
ALTER SEQUENCE IF EXISTS mentors_id_seq RESTART WITH 1;
ALTER SEQUENCE IF EXISTS projects_id_seq RESTART WITH 1;
ALTER SEQUENCE IF EXISTS project_members_id_seq RESTART WITH 1;
ALTER SEQUENCE IF EXISTS project_milestones_id_seq RESTART WITH 1;
ALTER SEQUENCE IF EXISTS project_technologies_id_seq RESTART WITH 1;
ALTER SEQUENCE IF EXISTS project_skill_requirements_id_seq RESTART WITH 1;
ALTER SEQUENCE IF EXISTS talent_skills_id_seq RESTART WITH 1;
ALTER SEQUENCE IF EXISTS mentor_expertise_id_seq RESTART WITH 1;

DO $$
BEGIN
    RAISE NOTICE 'Cleanup completed!';
    RAISE NOTICE '========================================';
END $$;

-- =====================================================
-- 1. USERS - Người dùng hệ thống
-- =====================================================

DO $$
BEGIN
    RAISE NOTICE 'Creating users...';
END $$;

-- 1.1 System Admin (id = 1)
INSERT INTO users (email, password_hash, role, status, email_verified, email_verified_at, phone, created_at, updated_at)
VALUES 
    ('admin@labodc.com', '$2a$12$8pC/5kx6500tN2HEkDaPLeVR3mg.RWvLDsLADL6lioo53laEWJhXu', 'SYSTEM_ADMIN', 'ACTIVE', true, NOW(), '+84901234567', NOW(), NOW());

-- 1.2 Lab Admins (id = 2, 3)
INSERT INTO users (email, password_hash, role, status, email_verified, email_verified_at, phone, created_at, updated_at)
VALUES 
    ('labadmin1@labodc.com', '$2a$12$8pC/5kx6500tN2HEkDaPLeVR3mg.RWvLDsLADL6lioo53laEWJhXu', 'LAB_ADMIN', 'ACTIVE', true, NOW(), '+84901234568', NOW(), NOW()),
    ('labadmin2@labodc.com', '$2a$12$8pC/5kx6500tN2HEkDaPLeVR3mg.RWvLDsLADL6lioo53laEWJhXu', 'LAB_ADMIN', 'ACTIVE', true, NOW(), '+84901234569', NOW(), NOW());

-- 1.3 Enterprise Users (id = 4, 5, 6, 7)
INSERT INTO users (email, password_hash, role, status, email_verified, email_verified_at, phone, created_at, updated_at)
VALUES 
    ('contact@techcorp.vn', '$2a$12$8pC/5kx6500tN2HEkDaPLeVR3mg.RWvLDsLADL6lioo53laEWJhXu', 'ENTERPRISE', 'ACTIVE', true, NOW(), '+84901111111', NOW(), NOW()),
    ('info@innovatesolutions.vn', '$2a$12$8pC/5kx6500tN2HEkDaPLeVR3mg.RWvLDsLADL6lioo53laEWJhXu', 'ENTERPRISE', 'ACTIVE', true, NOW(), '+84902222222', NOW(), NOW()),
    ('hello@digitalstartup.vn', '$2a$12$8pC/5kx6500tN2HEkDaPLeVR3mg.RWvLDsLADL6lioo53laEWJhXu', 'ENTERPRISE', 'ACTIVE', true, NOW(), '+84903333333', NOW(), NOW()),
    ('enterprise4@example.com', '$2a$12$8pC/5kx6500tN2HEkDaPLeVR3mg.RWvLDsLADL6lioo53laEWJhXu', 'ENTERPRISE', 'PENDING', false, NULL, '+84904444444', NOW(), NOW());

-- 1.4 Talent Users (id = 8-17)
INSERT INTO users (email, password_hash, role, status, email_verified, email_verified_at, phone, created_at, updated_at)
VALUES 
    ('nguyenvana@student.uth.edu.vn', '$2a$12$8pC/5kx6500tN2HEkDaPLeVR3mg.RWvLDsLADL6lioo53laEWJhXu', 'TALENT', 'ACTIVE', true, NOW(), '+84905555551', NOW(), NOW()),
    ('tranthib@student.uth.edu.vn', '$2a$12$8pC/5kx6500tN2HEkDaPLeVR3mg.RWvLDsLADL6lioo53laEWJhXu', 'TALENT', 'ACTIVE', true, NOW(), '+84905555552', NOW(), NOW()),
    ('levanc@student.uth.edu.vn', '$2a$12$8pC/5kx6500tN2HEkDaPLeVR3mg.RWvLDsLADL6lioo53laEWJhXu', 'TALENT', 'ACTIVE', true, NOW(), '+84905555553', NOW(), NOW()),
    ('phamthid@student.uth.edu.vn', '$2a$12$8pC/5kx6500tN2HEkDaPLeVR3mg.RWvLDsLADL6lioo53laEWJhXu', 'TALENT', 'ACTIVE', true, NOW(), '+84905555554', NOW(), NOW()),
    ('hoangvane@student.uth.edu.vn', '$2a$12$8pC/5kx6500tN2HEkDaPLeVR3mg.RWvLDsLADL6lioo53laEWJhXu', 'TALENT', 'ACTIVE', true, NOW(), '+84905555555', NOW(), NOW()),
    ('vuthif@student.uth.edu.vn', '$2a$12$8pC/5kx6500tN2HEkDaPLeVR3mg.RWvLDsLADL6lioo53laEWJhXu', 'TALENT', 'ACTIVE', true, NOW(), '+84905555556', NOW(), NOW()),
    ('danvang@student.uth.edu.vn', '$2a$12$8pC/5kx6500tN2HEkDaPLeVR3mg.RWvLDsLADL6lioo53laEWJhXu', 'TALENT', 'ACTIVE', true, NOW(), '+84905555557', NOW(), NOW()),
    ('ngothih@student.uth.edu.vn', '$2a$12$8pC/5kx6500tN2HEkDaPLeVR3mg.RWvLDsLADL6lioo53laEWJhXu', 'TALENT', 'ACTIVE', true, NOW(), '+84905555558', NOW(), NOW()),
    ('buivani@student.uth.edu.vn', '$2a$12$8pC/5kx6500tN2HEkDaPLeVR3mg.RWvLDsLADL6lioo53laEWJhXu', 'TALENT', 'ACTIVE', true, NOW(), '+84905555559', NOW(), NOW()),
    ('dothik@student.uth.edu.vn', '$2a$12$8pC/5kx6500tN2HEkDaPLeVR3mg.RWvLDsLADL6lioo53laEWJhXu', 'TALENT', 'PENDING', false, NULL, '+84905555560', NOW(), NOW());

-- 1.5 Mentor Users (id = 18-21)
INSERT INTO users (email, password_hash, role, status, email_verified, email_verified_at, phone, created_at, updated_at)
VALUES 
    ('mentor.nguyenquang@uth.edu.vn', '$2a$12$8pC/5kx6500tN2HEkDaPLeVR3mg.RWvLDsLADL6lioo53laEWJhXu', 'MENTOR', 'ACTIVE', true, NOW(), '+84906666661', NOW(), NOW()),
    ('mentor.tranminh@uth.edu.vn', '$2a$12$8pC/5kx6500tN2HEkDaPLeVR3mg.RWvLDsLADL6lioo53laEWJhXu', 'MENTOR', 'ACTIVE', true, NOW(), '+84906666662', NOW(), NOW()),
    ('mentor.lehong@uth.edu.vn', '$2a$12$8pC/5kx6500tN2HEkDaPLeVR3mg.RWvLDsLADL6lioo53laEWJhXu', 'MENTOR', 'ACTIVE', true, NOW(), '+84906666663', NOW(), NOW()),
    ('mentor.phamthao@uth.edu.vn', '$2a$12$8pC/5kx6500tN2HEkDaPLeVR3mg.RWvLDsLADL6lioo53laEWJhXu', 'MENTOR', 'ACTIVE', true, NOW(), '+84906666664', NOW(), NOW());

-- =====================================================
-- 2. ENTERPRISES - Doanh nghiệp
-- =====================================================

DO $$
BEGIN
    RAISE NOTICE 'Creating enterprises...';
END $$;

INSERT INTO enterprises (
    user_id, company_name, tax_code, business_license_number,
    address, city, district, ward,
    representative_name, representative_position,
    contact_email, contact_phone, website,
    industry, company_size, year_established, description,
    status, verified_at, verified_by,
    created_at, updated_at
)
VALUES
    -- Enterprise 1: TechCorp Vietnam
    (
        4, 'TechCorp Vietnam Co., Ltd', '0123456789', 'BL-2020-001',
        '123 Nguyen Hue Street', 'Ho Chi Minh City', 'District 1', 'Ward Ben Nghe',
        'Nguyen Van A', 'CEO',
        'contact@techcorp.vn', '+84901111111', 'https://techcorp.vn',
        'Information Technology', '50-200', 2018,
        'Leading software development company specializing in enterprise solutions, mobile apps, and cloud services.',
        'APPROVED', NOW() - INTERVAL '30 days', 2,
        NOW() - INTERVAL '60 days', NOW()
    ),
    -- Enterprise 2: Innovate Solutions
    (
        5, 'Innovate Solutions JSC', '0987654321', 'BL-2019-002',
        '456 Le Loi Boulevard', 'Ho Chi Minh City', 'District 3', 'Ward 7',
        'Tran Thi B', 'Managing Director',
        'info@innovatesolutions.vn', '+84902222222', 'https://innovatesolutions.vn',
        'Digital Marketing & E-commerce', '10-50', 2019,
        'Digital transformation consulting firm helping businesses modernize their operations and customer engagement.',
        'APPROVED', NOW() - INTERVAL '20 days', 2,
        NOW() - INTERVAL '45 days', NOW()
    ),
    -- Enterprise 3: Digital Startup Hub
    (
        6, 'Digital Startup Hub', '1122334455', 'BL-2021-003',
        '789 Tran Hung Dao', 'Ho Chi Minh City', 'District 5', 'Ward 2',
        'Le Van C', 'Founder & CTO',
        'hello@digitalstartup.vn', '+84903333333', 'https://digitalstartup.vn',
        'Startup & Innovation', '1-10', 2021,
        'Young startup focused on AI/ML solutions for e-commerce and retail industries.',
        'APPROVED', NOW() - INTERVAL '10 days', 2,
        NOW() - INTERVAL '20 days', NOW()
    ),
    -- Enterprise 4: Pending verification
    (
        7, 'Future Tech Solutions', '5566778899', 'BL-2025-004',
        '321 Vo Van Tan', 'Ho Chi Minh City', 'District 3', 'Ward 5',
        'Pham Van D', 'Director',
        'enterprise4@example.com', '+84904444444', 'https://futuretech.vn',
        'Software Development', '10-50', 2023,
        'Emerging tech company focusing on blockchain and fintech solutions.',
        'PENDING', NULL, NULL,
        NOW() - INTERVAL '5 days', NOW()
    );

-- =====================================================
-- 3. TALENTS - Sinh viên/Người tài năng
-- =====================================================

DO $$
BEGIN
    RAISE NOTICE 'Creating talents...';
END $$;

INSERT INTO talents (
    user_id, full_name, student_id, date_of_birth,
    faculty, major, year_of_study, gpa,
    github_url, linkedin_url, portfolio_url,
    bio, expected_graduation,
    available_for_projects, work_availability, hours_per_week,
    rating_average, total_projects, completed_projects,
    created_at, updated_at
)
VALUES 
    -- Talent 1: Frontend Developer
    (8, 'Nguyen Van A', '2020600001', '2002-03-15',
    'Computer Science', 'Software Engineering', 3, 3.45,
    'https://github.com/nguyenvana', 'https://linkedin.com/in/nguyenvana', 'https://nguyenvana.dev',
    'Passionate frontend developer with experience in React, Vue.js, and modern web technologies.',
    '2026-06-30',
    true, 'Full-time', 40,
    4.5, 3, 2,
    NOW() - INTERVAL '180 days', NOW()),
    
    -- Talent 2: Full Stack Developer
    (9, 'Tran Thi B', '2020600002', '2002-05-20',
    'Computer Science', 'Software Engineering', 3, 3.67,
    'https://github.com/tranthib', 'https://linkedin.com/in/tranthib', 'https://tranthib.com',
    'Full-stack developer skilled in MERN stack, Java Spring Boot, and database design.',
    '2026-06-30',
    true, 'Full-time', 40,
    4.7, 4, 3,
    NOW() - INTERVAL '180 days', NOW()),
    
    -- Talent 3: Backend Developer
    (10, 'Le Van C', '2020600003', '2002-01-10',
    'Computer Science', 'Software Engineering', 3, 3.52,
    'https://github.com/levanc', 'https://linkedin.com/in/levanc', NULL,
    'Backend specialist with strong knowledge in microservices, Docker, and cloud platforms.',
    '2026-06-30',
    true, 'Full-time', 40,
    4.3, 2, 2,
    NOW() - INTERVAL '180 days', NOW()),
    
    -- Talent 4: Mobile Developer
    (11, 'Pham Thi D', '2021600004', '2003-07-22',
    'Computer Science', 'Software Engineering', 2, 3.78,
    'https://github.com/phamthid', 'https://linkedin.com/in/phamthid', 'https://phamthid-portfolio.web.app',
    'Mobile app developer proficient in Flutter and React Native with published apps on stores.',
    '2027-06-30',
    true, 'Part-time', 20,
    4.8, 3, 2,
    NOW() - INTERVAL '150 days', NOW()),
    
    -- Talent 5: UI/UX Designer
    (12, 'Hoang Van E', '2021600005', '2003-09-05',
    'Computer Science', 'Information Systems', 2, 3.61,
    'https://github.com/hoangvane', 'https://linkedin.com/in/hoangvane', 'https://behance.net/hoangvane',
    'Creative UI/UX designer with a keen eye for user-centered design and prototyping.',
    '2027-06-30',
    true, 'Part-time', 25,
    4.6, 2, 1,
    NOW() - INTERVAL '150 days', NOW()),
    
    -- Talent 6: Data Analyst
    (13, 'Vu Thi F', '2021600006', '2003-11-18',
    'Computer Science', 'Data Science', 2, 3.85,
    'https://github.com/vuthif', 'https://linkedin.com/in/vuthif', 'https://vuthif-data.github.io',
    'Data enthusiast with skills in Python, R, machine learning, and data visualization.',
    '2027-06-30',
    false, 'Full-time', 40,
    4.9, 2, 2,
    NOW() - INTERVAL '150 days', NOW()),
    
    -- Talent 7: DevOps Engineer
    (14, 'Dan Van G', '2020600007', '2002-04-30',
    'Computer Science', 'Software Engineering', 3, 3.40,
    'https://github.com/danvang', 'https://linkedin.com/in/danvang', NULL,
    'DevOps practitioner experienced with CI/CD, Kubernetes, Terraform, and AWS.',
    '2026-06-30',
    true, 'Full-time', 35,
    4.2, 2, 1,
    NOW() - INTERVAL '180 days', NOW()),
    
    -- Talent 8: QA Tester
    (15, 'Ngo Thi H', '2021600008', '2003-06-12',
    'Computer Science', 'Software Engineering', 2, 3.55,
    'https://github.com/ngothih', 'https://linkedin.com/in/ngothih', NULL,
    'Quality assurance specialist with experience in manual and automated testing.',
    '2027-06-30',
    true, 'Part-time', 20,
    4.4, 1, 1,
    NOW() - INTERVAL '150 days', NOW()),
    
    -- Talent 9: Game Developer
    (16, 'Bui Van I', '2021600009', '2003-02-28',
    'Computer Science', 'Software Engineering', 2, 3.70,
    'https://github.com/buivani', 'https://linkedin.com/in/buivani', 'https://buivani.itch.io',
    'Game developer passionate about Unity, C#, and creating engaging interactive experiences.',
    '2027-06-30',
    true, 'Part-time', 15,
    4.5, 1, 0,
    NOW() - INTERVAL '120 days', NOW()),
    
    -- Talent 10: Pending
    (17, 'Do Thi K', '2022600010', '2004-08-08',
    'Computer Science', 'Software Engineering', 1, 3.20,
    'https://github.com/dothik', NULL, NULL,
    'First-year student eager to learn and gain practical experience.',
    '2028-06-30',
    true, 'Part-time', 10,
    0, 0, 0,
    NOW() - INTERVAL '30 days', NOW());

-- =====================================================
-- 4. TALENT SKILLS - Kỹ năng của sinh viên
-- =====================================================

DO $$
BEGIN
    RAISE NOTICE 'Creating talent skills...';
END $$;

INSERT INTO talent_skills (talent_id, skill_name, proficiency_level, years_of_experience, created_at, updated_at)
VALUES 
    -- Nguyen Van A (Frontend)
    (1, 'React.js', 'ADVANCED', 2, NOW(), NOW()),
    (1, 'Vue.js', 'INTERMEDIATE', 1, NOW(), NOW()),
    (1, 'HTML/CSS', 'ADVANCED', 3, NOW(), NOW()),
    (1, 'JavaScript/TypeScript', 'ADVANCED', 2, NOW(), NOW()),
    (1, 'Tailwind CSS', 'INTERMEDIATE', 1, NOW(), NOW()),
    
    -- Tran Thi B (Full Stack)
    (2, 'React.js', 'ADVANCED', 2, NOW(), NOW()),
    (2, 'Node.js', 'ADVANCED', 2, NOW(), NOW()),
    (2, 'Java Spring Boot', 'INTERMEDIATE', 1, NOW(), NOW()),
    (2, 'MongoDB', 'INTERMEDIATE', 1, NOW(), NOW()),
    (2, 'PostgreSQL', 'ADVANCED', 2, NOW(), NOW()),
    (2, 'Docker', 'INTERMEDIATE', 1, NOW(), NOW()),
    
    -- Le Van C (Backend)
    (3, 'Java', 'ADVANCED', 2, NOW(), NOW()),
    (3, 'Spring Boot', 'ADVANCED', 2, NOW(), NOW()),
    (3, 'Microservices', 'INTERMEDIATE', 1, NOW(), NOW()),
    (3, 'PostgreSQL', 'ADVANCED', 2, NOW(), NOW()),
    (3, 'Redis', 'INTERMEDIATE', 1, NOW(), NOW()),
    (3, 'Docker', 'ADVANCED', 2, NOW(), NOW()),
    (3, 'Kubernetes', 'BEGINNER', 0, NOW(), NOW()),
    
    -- Pham Thi D (Mobile)
    (4, 'Flutter', 'ADVANCED', 2, NOW(), NOW()),
    (4, 'React Native', 'INTERMEDIATE', 1, NOW(), NOW()),
    (4, 'Dart', 'ADVANCED', 2, NOW(), NOW()),
    (4, 'Firebase', 'ADVANCED', 2, NOW(), NOW()),
    (4, 'REST API Integration', 'ADVANCED', 2, NOW(), NOW()),
    
    -- Hoang Van E (UI/UX)
    (5, 'Figma', 'ADVANCED', 2, NOW(), NOW()),
    (5, 'Adobe XD', 'INTERMEDIATE', 1, NOW(), NOW()),
    (5, 'Sketch', 'INTERMEDIATE', 1, NOW(), NOW()),
    (5, 'Prototyping', 'ADVANCED', 2, NOW(), NOW()),
    (5, 'User Research', 'INTERMEDIATE', 1, NOW(), NOW()),
    
    -- Vu Thi F (Data Science)
    (6, 'Python', 'ADVANCED', 2, NOW(), NOW()),
    (6, 'R', 'INTERMEDIATE', 1, NOW(), NOW()),
    (6, 'Machine Learning', 'INTERMEDIATE', 1, NOW(), NOW()),
    (6, 'Data Visualization', 'ADVANCED', 2, NOW(), NOW()),
    (6, 'SQL', 'ADVANCED', 2, NOW(), NOW()),
    (6, 'Tableau', 'INTERMEDIATE', 1, NOW(), NOW()),
    
    -- Dan Van G (DevOps)
    (7, 'Docker', 'ADVANCED', 2, NOW(), NOW()),
    (7, 'Kubernetes', 'INTERMEDIATE', 1, NOW(), NOW()),
    (7, 'CI/CD', 'ADVANCED', 2, NOW(), NOW()),
    (7, 'AWS', 'INTERMEDIATE', 1, NOW(), NOW()),
    (7, 'Terraform', 'INTERMEDIATE', 1, NOW(), NOW()),
    (7, 'Linux', 'ADVANCED', 3, NOW(), NOW()),
    
    -- Ngo Thi H (QA)
    (8, 'Manual Testing', 'ADVANCED', 2, NOW(), NOW()),
    (8, 'Selenium', 'INTERMEDIATE', 1, NOW(), NOW()),
    (8, 'Test Automation', 'INTERMEDIATE', 1, NOW(), NOW()),
    (8, 'Postman', 'ADVANCED', 2, NOW(), NOW()),
    (8, 'JIRA', 'ADVANCED', 2, NOW(), NOW()),
    
    -- Bui Van I (Game Dev)
    (9, 'Unity', 'ADVANCED', 2, NOW(), NOW()),
    (9, 'C#', 'ADVANCED', 2, NOW(), NOW()),
    (9, 'Game Design', 'INTERMEDIATE', 1, NOW(), NOW()),
    (9, 'Blender', 'BEGINNER', 0, NOW(), NOW());

-- =====================================================
-- 5. MENTORS - Người hướng dẫn
-- =====================================================

DO $$
BEGIN
    RAISE NOTICE 'Creating mentors...';
END $$;

INSERT INTO mentors (
    user_id, full_name, title, bio,
    years_of_experience, current_position, current_company,
    linkedin_url, max_concurrent_projects, hourly_rate,
    available, rating_average, total_projects, current_projects_count,
    created_at, updated_at
)
VALUES 
    -- Mentor 1: Java/Backend Expert
    (18, 'Nguyen Quang Huy', 'Senior Backend Engineer',
    'Experienced backend architect with 10+ years in enterprise system development. Specialized in building scalable microservices and cloud-native applications.',
    10, 'Senior Backend Engineer', 'FPT Software',
    'https://linkedin.com/in/nguyenquanghuy', 3, 500000,
    true, 4.8, 15, 1,
    NOW() - INTERVAL '365 days', NOW()),
    
    -- Mentor 2: Full Stack & DevOps
    (19, 'Tran Minh Tuan', 'Tech Lead',
    'Full-stack developer and DevOps engineer with passion for mentoring young talents. Experienced in agile methodologies and modern development practices.',
    8, 'Tech Lead', 'VNG Corporation',
    'https://linkedin.com/in/tranminhtuan', 3, 450000,
    true, 4.7, 12, 2,
    NOW() - INTERVAL '300 days', NOW()),
    
    -- Mentor 3: Mobile Development
    (20, 'Le Hong Anh', 'Mobile Development Lead',
    'Mobile development specialist with expertise in cross-platform frameworks. Published 20+ apps with millions of downloads.',
    7, 'Mobile Development Lead', 'Tiki',
    'https://linkedin.com/in/lehonganh', 2, 480000,
    false, 4.9, 10, 2,
    NOW() - INTERVAL '280 days', NOW()),
    
    -- Mentor 4: Frontend & UI/UX
    (21, 'Pham Thao Nguyen', 'Senior Frontend Developer',
    'Frontend expert passionate about creating beautiful and performant user interfaces. Strong advocate for accessibility and user experience.',
    6, 'Senior Frontend Developer', 'Shopee',
    'https://linkedin.com/in/phamthaonguyen', 3, 420000,
    true, 4.6, 8, 1,
    NOW() - INTERVAL '240 days', NOW());

-- =====================================================
-- 6. MENTOR EXPERTISE - Chuyên môn chi tiết
-- =====================================================

DO $$
BEGIN
    RAISE NOTICE 'Creating mentor expertise...';
END $$;

INSERT INTO mentor_expertise (mentor_id, skill_name, proficiency_level, years_of_experience, can_teach, created_at)
VALUES 
    -- Mentor 1: Nguyen Quang Huy
    (1, 'Java', 'EXPERT', 10, true, NOW()),
    (1, 'Spring Boot', 'EXPERT', 8, true, NOW()),
    (1, 'Microservices', 'EXPERT', 7, true, NOW()),
    (1, 'PostgreSQL', 'EXPERT', 10, true, NOW()),
    (1, 'Docker', 'EXPERT', 6, true, NOW()),
    (1, 'Kubernetes', 'ADVANCED', 5, true, NOW()),
    (1, 'AWS', 'EXPERT', 8, true, NOW()),
    
    -- Mentor 2: Tran Minh Tuan
    (2, 'React.js', 'EXPERT', 6, true, NOW()),
    (2, 'Node.js', 'EXPERT', 7, true, NOW()),
    (2, 'DevOps', 'EXPERT', 5, true, NOW()),
    (2, 'CI/CD', 'EXPERT', 6, true, NOW()),
    (2, 'MongoDB', 'EXPERT', 6, true, NOW()),
    (2, 'AWS', 'ADVANCED', 5, true, NOW()),
    
    -- Mentor 3: Le Hong Anh
    (3, 'Flutter', 'EXPERT', 5, true, NOW()),
    (3, 'React Native', 'EXPERT', 4, true, NOW()),
    (3, 'iOS Development', 'EXPERT', 7, true, NOW()),
    (3, 'Android Development', 'EXPERT', 7, true, NOW()),
    (3, 'Mobile UX', 'EXPERT', 6, true, NOW()),
    (3, 'Firebase', 'EXPERT', 5, true, NOW()),
    
    -- Mentor 4: Pham Thao Nguyen
    (4, 'React.js', 'EXPERT', 5, true, NOW()),
    (4, 'Vue.js', 'EXPERT', 4, true, NOW()),
    (4, 'TypeScript', 'EXPERT', 5, true, NOW()),
    (4, 'UI/UX Design', 'ADVANCED', 4, true, NOW()),
    (4, 'Frontend Architecture', 'EXPERT', 5, true, NOW());

-- =====================================================
-- 7. PROJECTS - Dự án
-- =====================================================

DO $$
BEGIN
    RAISE NOTICE 'Creating projects...';
END $$;

INSERT INTO projects (
    enterprise_id, mentor_id,
    title, slug, description, objectives, requirements,
    start_date, end_date,
    budget, currency,
    number_of_students, current_members_count,
    status, progress_percentage,
    validated, validated_at, validated_by,
    is_public, allow_applications,
    created_at, updated_at
)
VALUES 
    -- Project 1: E-Commerce Platform (IN_PROGRESS)
    (
        1, 1,
        'E-Commerce Platform Development',
        'ecommerce-platform-development',
        'Build a modern e-commerce platform with features including product catalog, shopping cart, payment integration, order management, and admin dashboard.',
        '["Develop responsive web application", "Implement secure payment gateway", "Create admin management system", "Optimize for mobile devices", "Deploy to cloud infrastructure"]'::jsonb,
        'Requirements: Strong knowledge of React, Node.js, and PostgreSQL. Experience with payment gateways is a plus. Team members should be comfortable with agile development practices.',
        '2026-01-15', '2026-06-30',
        120000000, 'VND',
        6, 6,
        'IN_PROGRESS', 40,
        true, NOW() - INTERVAL '40 days', 2,
        true, false,
        NOW() - INTERVAL '45 days', NOW()
    ),
    
    -- Project 2: Mobile Learning App (RECRUITING)
    (
        2, 3,
        'Mobile Learning Application',
        'mobile-learning-application',
        'Develop a cross-platform mobile learning app that provides interactive courses, video lectures, quizzes, and progress tracking for students.',
        '["Create intuitive mobile UI/UX", "Implement video streaming", "Build quiz and assessment system", "Add social learning features", "Integrate push notifications"]'::jsonb,
        'Requirements: Proficiency in Flutter and Firebase. UI/UX design skills are highly valued. Experience with video streaming technologies is beneficial.',
        '2026-02-15', '2026-08-31',
        150000000, 'VND',
        7, 2,
        'RECRUITING', 10,
        true, NOW() - INTERVAL '10 days', 2,
        true, true,
        NOW() - INTERVAL '15 days', NOW()
    ),
    
    -- Project 3: AI-Powered CRM (VALIDATED)
    (
        1, 1,
        'AI-Powered Customer Relationship Management System',
        'ai-powered-crm-system',
        'Build an intelligent CRM system with AI-driven lead scoring, automated email campaigns, sales pipeline management, and analytics dashboard.',
        '["Implement lead management module", "Develop sales pipeline tracking", "Integrate AI for lead scoring", "Create email automation system", "Build comprehensive analytics dashboard"]'::jsonb,
        'Requirements: Advanced React and Java Spring Boot skills required. Python knowledge for ML integration. Strong database design skills needed.',
        '2026-03-01', '2026-08-31',
        180000000, 'VND',
        8, 0,
        'VALIDATED', 0,
        true, NOW() - INTERVAL '5 days', 2,
        true, true,
        NOW() - INTERVAL '10 days', NOW()
    ),
    
    -- Project 4: Smart Inventory System (PENDING_VALIDATION)
    (
        3, NULL,
        'Smart Warehouse Inventory Management',
        'smart-warehouse-inventory-management',
        'Develop a real-time inventory management system with barcode scanning, automated stock alerts, supplier management, and detailed reporting.',
        '["Create inventory tracking system", "Implement barcode scanning", "Build supplier management module", "Add automated alerting", "Generate comprehensive reports"]'::jsonb,
        'Requirements: Vue.js and Node.js proficiency. MongoDB experience required. Mobile development skills for scanning app are advantageous.',
        '2026-03-15', '2026-08-15',
        100000000, 'VND',
        5, 0,
        'PENDING_VALIDATION', 0,
        false, NULL, NULL,
        true, true,
        NOW() - INTERVAL '3 days', NOW()
    ),
    
    -- Project 5: Completed Project
    (
        2, 4,
        'Corporate Website Redesign',
        'corporate-website-redesign',
        'Redesign and redevelop the company website with modern design, improved UX, and better SEO optimization.',
        '["Design modern UI/UX", "Develop responsive website", "Optimize for SEO", "Improve page load speed", "Implement content management"]'::jsonb,
        'Requirements: React and Next.js knowledge. UI/UX design capabilities. Understanding of SEO principles.',
        '2025-10-01', '2025-12-31',
        50000000, 'VND',
        4, 4,
        'COMPLETED', 100,
        true, NOW() - INTERVAL '120 days', 2,
        true, false,
        NOW() - INTERVAL '130 days', NOW() - INTERVAL '30 days'
    );

-- =====================================================
-- 8. PROJECT MEMBERS - Thành viên dự án
-- =====================================================

DO $$
BEGIN
    RAISE NOTICE 'Creating project members...';
END $$;

-- Project 1: E-Commerce Platform (6 members)
INSERT INTO project_members (project_id, talent_id, role, status, joined_at)
VALUES 
    (1, 2, 'LEADER', 'ACTIVE', NOW() - INTERVAL '40 days'),
    (1, 1, 'MEMBER', 'ACTIVE', NOW() - INTERVAL '38 days'),
    (1, 3, 'MEMBER', 'ACTIVE', NOW() - INTERVAL '38 days'),
    (1, 5, 'MEMBER', 'ACTIVE', NOW() - INTERVAL '35 days'),
    (1, 7, 'MEMBER', 'ACTIVE', NOW() - INTERVAL '35 days'),
    (1, 8, 'MEMBER', 'ACTIVE', NOW() - INTERVAL '32 days');

-- Project 2: Mobile Learning App (2 members)
INSERT INTO project_members (project_id, talent_id, role, status, joined_at)
VALUES 
    (2, 4, 'LEADER', 'ACTIVE', NOW() - INTERVAL '10 days'),
    (2, 5, 'MEMBER', 'ACTIVE', NOW() - INTERVAL '8 days');

-- Project 5: Completed project (4 members)
INSERT INTO project_members (project_id, talent_id, role, status, joined_at, left_at)
VALUES 
    (5, 1, 'LEADER', 'ACTIVE', NOW() - INTERVAL '130 days', NULL),
    (5, 5, 'MEMBER', 'ACTIVE', NOW() - INTERVAL '130 days', NULL),
    (5, 2, 'MEMBER', 'ACTIVE', NOW() - INTERVAL '128 days', NULL),
    (5, 8, 'MEMBER', 'ACTIVE', NOW() - INTERVAL '128 days', NULL);

-- =====================================================
-- 9. PROJECT TECHNOLOGIES - Công nghệ sử dụng
-- =====================================================

DO $$
BEGIN
    RAISE NOTICE 'Creating project technologies...';
END $$;

INSERT INTO project_technologies (project_id, technology_name, technology_type, is_required, created_at)
VALUES 
    -- Project 1: E-Commerce
    (1, 'React', 'FRAMEWORK', true, NOW() - INTERVAL '45 days'),
    (1, 'Node.js', 'FRAMEWORK', true, NOW() - INTERVAL '45 days'),
    (1, 'Express', 'FRAMEWORK', true, NOW() - INTERVAL '45 days'),
    (1, 'PostgreSQL', 'DATABASE', true, NOW() - INTERVAL '45 days'),
    (1, 'Docker', 'TOOL', true, NOW() - INTERVAL '45 days'),
    (1, 'AWS', 'PLATFORM', true, NOW() - INTERVAL '45 days'),
    
    -- Project 2: Mobile Learning
    (2, 'Flutter', 'FRAMEWORK', true, NOW() - INTERVAL '15 days'),
    (2, 'Firebase', 'PLATFORM', true, NOW() - INTERVAL '15 days'),
    (2, 'Dart', 'PROGRAMMING_LANGUAGE', true, NOW() - INTERVAL '15 days'),
    
    -- Project 3: AI CRM
    (3, 'React', 'FRAMEWORK', true, NOW() - INTERVAL '10 days'),
    (3, 'TypeScript', 'PROGRAMMING_LANGUAGE', true, NOW() - INTERVAL '10 days'),
    (3, 'Java', 'PROGRAMMING_LANGUAGE', true, NOW() - INTERVAL '10 days'),
    (3, 'Spring Boot', 'FRAMEWORK', true, NOW() - INTERVAL '10 days'),
    (3, 'Python', 'PROGRAMMING_LANGUAGE', true, NOW() - INTERVAL '10 days'),
    (3, 'TensorFlow', 'FRAMEWORK', false, NOW() - INTERVAL '10 days'),
    (3, 'PostgreSQL', 'DATABASE', true, NOW() - INTERVAL '10 days'),
    (3, 'Redis', 'DATABASE', true, NOW() - INTERVAL '10 days'),
    
    -- Project 4: Inventory
    (4, 'Vue.js', 'FRAMEWORK', true, NOW() - INTERVAL '3 days'),
    (4, 'Node.js', 'FRAMEWORK', true, NOW() - INTERVAL '3 days'),
    (4, 'MongoDB', 'DATABASE', true, NOW() - INTERVAL '3 days'),
    
    -- Project 5: Website (Completed)
    (5, 'React', 'FRAMEWORK', true, NOW() - INTERVAL '130 days'),
    (5, 'Next.js', 'FRAMEWORK', true, NOW() - INTERVAL '130 days'),
    (5, 'Tailwind CSS', 'FRAMEWORK', true, NOW() - INTERVAL '130 days');

-- =====================================================
-- 10. PROJECT SKILL REQUIREMENTS - Yêu cầu kỹ năng
-- =====================================================

DO $$
BEGIN
    RAISE NOTICE 'Creating project skill requirements...';
END $$;

INSERT INTO project_skill_requirements (project_id, skill_name, proficiency_level, is_required, priority, created_at)
VALUES 
    -- Project 1: E-Commerce
    (1, 'React.js', 'ADVANCED', true, 1, NOW() - INTERVAL '45 days'),
    (1, 'Node.js', 'INTERMEDIATE', true, 2, NOW() - INTERVAL '45 days'),
    (1, 'PostgreSQL', 'INTERMEDIATE', true, 3, NOW() - INTERVAL '45 days'),
    (1, 'Docker', 'BEGINNER', false, 4, NOW() - INTERVAL '45 days'),
    
    -- Project 2: Mobile Learning
    (2, 'Flutter', 'ADVANCED', true, 1, NOW() - INTERVAL '15 days'),
    (2, 'Firebase', 'INTERMEDIATE', true, 2, NOW() - INTERVAL '15 days'),
    (2, 'UI/UX Design', 'INTERMEDIATE', false, 3, NOW() - INTERVAL '15 days'),
    
    -- Project 3: AI CRM
    (3, 'React.js', 'ADVANCED', true, 1, NOW() - INTERVAL '10 days'),
    (3, 'Java Spring Boot', 'ADVANCED', true, 2, NOW() - INTERVAL '10 days'),
    (3, 'Python', 'INTERMEDIATE', true, 3, NOW() - INTERVAL '10 days'),
    (3, 'PostgreSQL', 'INTERMEDIATE', true, 4, NOW() - INTERVAL '10 days'),
    (3, 'Machine Learning', 'BEGINNER', false, 5, NOW() - INTERVAL '10 days'),
    
    -- Project 4: Inventory
    (4, 'Vue.js', 'INTERMEDIATE', true, 1, NOW() - INTERVAL '3 days'),
    (4, 'Node.js', 'INTERMEDIATE', true, 2, NOW() - INTERVAL '3 days'),
    (4, 'MongoDB', 'INTERMEDIATE', true, 3, NOW() - INTERVAL '3 days'),
    
    -- Project 5: Website
    (5, 'React.js', 'INTERMEDIATE', true, 1, NOW() - INTERVAL '130 days'),
    (5, 'UI/UX Design', 'INTERMEDIATE', true, 2, NOW() - INTERVAL '130 days'),
    (5, 'SEO', 'BEGINNER', false, 3, NOW() - INTERVAL '130 days');

-- =====================================================
-- 11. PROJECT MILESTONES - Các mốc quan trọng
-- =====================================================

DO $$
BEGIN
    RAISE NOTICE 'Creating project milestones...';
END $$;

INSERT INTO project_milestones (
    project_id, name, description,
    due_date, completed_date, status,
    display_order,
    created_at, updated_at
)
VALUES 
    -- Project 1: E-Commerce Platform
    (1, 'Project Setup & Design',
    'Initial setup, database design, and UI/UX mockups. Setup development environment and establish coding standards.',
    '2026-02-15', '2026-02-15', 'COMPLETED',
    1, NOW() - INTERVAL '45 days', NOW() - INTERVAL '15 days'),
    
    (1, 'Backend API Development',
    'Develop all backend APIs and business logic. Implement authentication, product management, and order processing.',
    '2026-04-15', NULL, 'IN_PROGRESS',
    2, NOW() - INTERVAL '40 days', NOW()),
    
    (1, 'Frontend Development',
    'Build all frontend pages and components. Create responsive design for all major pages.',
    '2026-05-15', NULL, 'PENDING',
    3, NOW() - INTERVAL '35 days', NOW()),
    
    (1, 'Testing & Deployment',
    'Complete testing and deploy to production. Conduct user acceptance testing and bug fixes.',
    '2026-06-30', NULL, 'PENDING',
    4, NOW() - INTERVAL '35 days', NOW()),
    
    -- Project 2: Mobile Learning App
    (2, 'UI/UX Design & Prototyping',
    'Complete UI/UX design for all app screens and create interactive prototypes.',
    '2026-03-15', NULL, 'IN_PROGRESS',
    1, NOW() - INTERVAL '15 days', NOW()),
    
    (2, 'Core Features Development',
    'Implement video streaming, quiz system, and user progress tracking.',
    '2026-05-31', NULL, 'PENDING',
    2, NOW() - INTERVAL '15 days', NOW()),
    
    -- Project 5: Website (Completed)
    (5, 'Design Phase',
    'Complete UI/UX design and get client approval.',
    '2025-10-31', '2025-10-28', 'COMPLETED',
    1, NOW() - INTERVAL '130 days', NOW() - INTERVAL '90 days'),
    
    (5, 'Development',
    'Develop website with all features and integrate CMS.',
    '2025-12-15', '2025-12-14', 'COMPLETED',
    2, NOW() - INTERVAL '90 days', NOW() - INTERVAL '45 days'),
    
    (5, 'Launch',
    'Final testing and production launch.',
    '2025-12-31', '2025-12-30', 'COMPLETED',
    3, NOW() - INTERVAL '45 days', NOW() - INTERVAL '30 days');
-- =====================================================