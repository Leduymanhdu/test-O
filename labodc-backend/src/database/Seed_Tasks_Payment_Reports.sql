-- =====================================================
-- SEED DATA FOR TASKS, PAYMENT & REPORTS
-- =====================================================
-- Mục đích: Tạo dữ liệu mẫu cho Tasks, Payment và Reports
-- Phụ thuộc: Chạy sau Seed_Test_Data.sql
-- =====================================================

-- =====================================================
-- CLEANUP: XÓA DỮ LIỆU CŨ (NẾU CÓ)
-- =====================================================
DO $$
BEGIN
    RAISE NOTICE '========================================';
    RAISE NOTICE 'CLEANING UP OLD TASKS, PAYMENT & REPORTS DATA...';
    RAISE NOTICE '========================================';
END $$;

-- Xóa theo thứ tự ngược lại (child tables trước)
TRUNCATE TABLE task_time_logs CASCADE;
TRUNCATE TABLE task_attachments CASCADE;
TRUNCATE TABLE task_comments CASCADE;
TRUNCATE TABLE task_dependencies CASCADE;
TRUNCATE TABLE tasks CASCADE;

TRUNCATE TABLE disbursements CASCADE;
TRUNCATE TABLE team_member_allocations CASCADE;
TRUNCATE TABLE team_fund_distributions CASCADE;
TRUNCATE TABLE hybrid_fund_advances CASCADE;
TRUNCATE TABLE fund_distributions CASCADE;
TRUNCATE TABLE fund_allocations CASCADE;
TRUNCATE TABLE payment_transactions CASCADE;
TRUNCATE TABLE payments CASCADE;

TRUNCATE TABLE transparency_reports CASCADE;
TRUNCATE TABLE enterprise_feedback CASCADE;
TRUNCATE TABLE talent_evaluations CASCADE;
TRUNCATE TABLE report_attachments CASCADE;
TRUNCATE TABLE team_reports CASCADE;
TRUNCATE TABLE mentor_reports CASCADE;

-- Reset sequences
ALTER SEQUENCE IF EXISTS tasks_id_seq RESTART WITH 1;
ALTER SEQUENCE IF EXISTS task_dependencies_id_seq RESTART WITH 1;
ALTER SEQUENCE IF EXISTS task_comments_id_seq RESTART WITH 1;
ALTER SEQUENCE IF EXISTS task_attachments_id_seq RESTART WITH 1;
ALTER SEQUENCE IF EXISTS task_time_logs_id_seq RESTART WITH 1;

ALTER SEQUENCE IF EXISTS payments_id_seq RESTART WITH 1;
ALTER SEQUENCE IF EXISTS payment_transactions_id_seq RESTART WITH 1;
ALTER SEQUENCE IF EXISTS fund_allocations_id_seq RESTART WITH 1;
ALTER SEQUENCE IF EXISTS fund_distributions_id_seq RESTART WITH 1;
ALTER SEQUENCE IF EXISTS team_fund_distributions_id_seq RESTART WITH 1;
ALTER SEQUENCE IF EXISTS team_member_allocations_id_seq RESTART WITH 1;
ALTER SEQUENCE IF EXISTS hybrid_fund_advances_id_seq RESTART WITH 1;
ALTER SEQUENCE IF EXISTS disbursements_id_seq RESTART WITH 1;

ALTER SEQUENCE IF EXISTS mentor_reports_id_seq RESTART WITH 1;
ALTER SEQUENCE IF EXISTS team_reports_id_seq RESTART WITH 1;
ALTER SEQUENCE IF EXISTS report_attachments_id_seq RESTART WITH 1;
ALTER SEQUENCE IF EXISTS talent_evaluations_id_seq RESTART WITH 1;
ALTER SEQUENCE IF EXISTS enterprise_feedback_id_seq RESTART WITH 1;
ALTER SEQUENCE IF EXISTS transparency_reports_id_seq RESTART WITH 1;

DO $$
BEGIN
    RAISE NOTICE 'Cleanup completed!';
    RAISE NOTICE '========================================';
END $$;

-- =====================================================
-- 1. TASKS - Nhiệm vụ dự án
-- =====================================================

DO $$
BEGIN
    RAISE NOTICE 'Creating tasks...';
END $$;

-- Tasks cho Project 1: E-Commerce Platform (IN_PROGRESS)
INSERT INTO tasks (
    project_id, task_id, task_name, description,
    assigned_to, created_by, priority, status,
    start_date, due_date, completed_date,
    estimated_hours, actual_hours, progress_percentage,
    tags, created_at, updated_at
)
VALUES 
    -- Phase 1: Setup (COMPLETED)
    (1, 'T001', 'Project Setup & Configuration', 
    'Initialize project structure, setup Git repository, configure build tools and dependencies',
    2, 1, 'HIGH', 'COMPLETED',
    '2026-01-15', '2026-01-20', '2026-01-19',
    16, 15, 100,
    'setup,backend', NOW() - INTERVAL '45 days', NOW() - INTERVAL '40 days'),
    
    (1, 'T002', 'Database Schema Design',
    'Design complete database schema for e-commerce system including products, orders, users',
    3, 1, 'HIGH', 'COMPLETED',
    '2026-01-20', '2026-01-25', '2026-01-24',
    24, 22, 100,
    'database,design', NOW() - INTERVAL '40 days', NOW() - INTERVAL '35 days'),
    
    (1, 'T003', 'UI/UX Design Mockups',
    'Create high-fidelity mockups for all main pages: home, product listing, product detail, cart, checkout',
    5, 1, 'HIGH', 'COMPLETED',
    '2026-01-20', '2026-02-05', '2026-02-04',
    40, 38, 100,
    'design,frontend', NOW() - INTERVAL '40 days', NOW() - INTERVAL '28 days'),
    
    -- Phase 2: Backend Development (IN_PROGRESS)
    (1, 'T004', 'Authentication API',
    'Implement user registration, login, JWT token generation and validation',
    3, 1, 'HIGH', 'COMPLETED',
    '2026-01-25', '2026-02-05', '2026-02-04',
    32, 30, 100,
    'backend,api,auth', NOW() - INTERVAL '35 days', NOW() - INTERVAL '28 days'),
    
    (1, 'T005', 'Product Management API',
    'CRUD APIs for products, categories, inventory management',
    3, 1, 'HIGH', 'COMPLETED',
    '2026-02-05', '2026-02-15', '2026-02-14',
    40, 42, 100,
    'backend,api,product', NOW() - INTERVAL '28 days', NOW() - INTERVAL '18 days'),
    
    (1, 'T006', 'Shopping Cart API',
    'Implement cart operations: add to cart, update quantity, remove items, cart persistence',
    2, 1, 'MEDIUM', 'IN_PROGRESS',
    '2026-02-15', '2026-02-25', NULL,
    24, 18, 75,
    'backend,api,cart', NOW() - INTERVAL '18 days', NOW()),
    
    (1, 'T007', 'Order Processing API',
    'Order creation, payment processing integration, order status tracking',
    3, 1, 'HIGH', 'IN_PROGRESS',
    '2026-02-20', '2026-03-05', NULL,
    40, 20, 50,
    'backend,api,order', NOW() - INTERVAL '13 days', NOW()),
    
    (1, 'T008', 'Payment Gateway Integration',
    'Integrate PayOS for payment processing, handle webhooks and callbacks',
    2, 1, 'CRITICAL', 'TODO',
    '2026-03-01', '2026-03-10', NULL,
    32, 0, 0,
    'backend,payment,integration', NOW() - INTERVAL '2 days', NOW()),
    
    -- Phase 3: Frontend Development (PENDING/TODO)
    (1, 'T009', 'Homepage & Product Listing',
    'Implement homepage with featured products and product listing page with filters',
    1, 1, 'HIGH', 'IN_PROGRESS',
    '2026-02-10', '2026-02-25', NULL,
    40, 25, 62,
    'frontend,react', NOW() - INTERVAL '23 days', NOW()),
    
    (1, 'T010', 'Product Detail Page',
    'Product detail view with image gallery, specifications, reviews',
    1, 1, 'MEDIUM', 'TODO',
    '2026-02-25', '2026-03-05', NULL,
    24, 0, 0,
    'frontend,react', NOW() - INTERVAL '8 days', NOW()),
    
    (1, 'T011', 'Shopping Cart UI',
    'Shopping cart page with item management and checkout button',
    1, 1, 'MEDIUM', 'TODO',
    '2026-03-05', '2026-03-15', NULL,
    16, 0, 0,
    'frontend,react', NOW() - INTERVAL '2 days', NOW()),
    
    (1, 'T012', 'Checkout Process',
    'Multi-step checkout: shipping info, payment method, order confirmation',
    1, 1, 'HIGH', 'TODO',
    '2026-03-10', '2026-03-20', NULL,
    32, 0, 0,
    'frontend,react,payment', NOW() - INTERVAL '2 days', NOW()),
    
    -- DevOps & Testing
    (1, 'T013', 'Docker Configuration',
    'Create Dockerfiles and docker-compose for development and production',
    7, 1, 'MEDIUM', 'COMPLETED',
    '2026-02-01', '2026-02-10', '2026-02-09',
    16, 18, 100,
    'devops,docker', NOW() - INTERVAL '32 days', NOW() - INTERVAL '23 days'),
    
    (1, 'T014', 'API Testing',
    'Write integration tests for all API endpoints',
    8, 1, 'MEDIUM', 'IN_PROGRESS',
    '2026-02-20', '2026-03-10', NULL,
    40, 15, 37,
    'testing,backend', NOW() - INTERVAL '13 days', NOW()),
    
    (1, 'T015', 'Frontend Testing',
    'Unit tests for React components and E2E tests',
    8, 1, 'MEDIUM', 'TODO',
    '2026-03-15', '2026-03-30', NULL,
    32, 0, 0,
    'testing,frontend', NOW() - INTERVAL '2 days', NOW());

-- Tasks cho Project 2: Mobile Learning App (RECRUITING)
INSERT INTO tasks (
    project_id, task_id, task_name, description,
    assigned_to, created_by, priority, status,
    start_date, due_date, completed_date,
    estimated_hours, actual_hours, progress_percentage,
    tags, created_at, updated_at
)
VALUES 
    (2, 'T001', 'App Architecture & Setup',
    'Setup Flutter project structure, state management, routing',
    4, 3, 'HIGH', 'COMPLETED',
    '2026-02-10', '2026-02-15', '2026-02-14',
    16, 14, 100,
    'setup,flutter', NOW() - INTERVAL '18 days', NOW() - INTERVAL '14 days'),
    
    (2, 'T002', 'UI Design System',
    'Create reusable widgets, color scheme, typography, design tokens',
    5, 3, 'HIGH', 'COMPLETED',
    '2026-02-10', '2026-02-20', '2026-02-19',
    24, 26, 100,
    'design,ui', NOW() - INTERVAL '18 days', NOW() - INTERVAL '9 days'),
    
    (2, 'T003', 'Authentication Screens',
    'Login, register, forgot password, profile setup screens',
    4, 3, 'HIGH', 'IN_PROGRESS',
    '2026-02-20', '2026-02-28', NULL,
    20, 12, 60,
    'frontend,auth', NOW() - INTERVAL '9 days', NOW()),
    
    (2, 'T004', 'Course Listing & Detail',
    'Course catalog, search, filters, course detail with curriculum',
    4, 3, 'MEDIUM', 'TODO',
    '2026-03-01', '2026-03-15', NULL,
    32, 0, 0,
    'frontend,course', NOW() - INTERVAL '2 days', NOW()),
    
    (2, 'T005', 'Video Player Integration',
    'Integrate video player with controls, progress tracking, quality selection',
    4, 3, 'CRITICAL', 'TODO',
    '2026-03-10', '2026-03-25', NULL,
    40, 0, 0,
    'frontend,video', NOW() - INTERVAL '2 days', NOW()),
    
    (2, 'T006', 'Firebase Backend Setup',
    'Setup Firestore, Authentication, Cloud Storage, Cloud Functions',
    4, 3, 'HIGH', 'IN_PROGRESS',
    '2026-02-15', '2026-02-25', NULL,
    24, 10, 42,
    'backend,firebase', NOW() - INTERVAL '14 days', NOW());

-- =====================================================
-- 2. TASK DEPENDENCIES
-- =====================================================

DO $$
BEGIN
    RAISE NOTICE 'Creating task dependencies...';
END $$;

INSERT INTO task_dependencies (task_id, depends_on_task_id, dependency_type, created_at)
VALUES 
    -- Project 1 dependencies
    (2, 1, 'FINISH_TO_START', NOW() - INTERVAL '40 days'),
    (3, 1, 'FINISH_TO_START', NOW() - INTERVAL '40 days'),
    (4, 2, 'FINISH_TO_START', NOW() - INTERVAL '35 days'),
    (5, 4, 'FINISH_TO_START', NOW() - INTERVAL '28 days'),
    (6, 5, 'FINISH_TO_START', NOW() - INTERVAL '18 days'),
    (7, 5, 'FINISH_TO_START', NOW() - INTERVAL '18 days'),
    (8, 7, 'FINISH_TO_START', NOW() - INTERVAL '2 days'),
    (9, 3, 'FINISH_TO_START', NOW() - INTERVAL '23 days'),
    (10, 9, 'FINISH_TO_START', NOW() - INTERVAL '8 days'),
    (11, 6, 'FINISH_TO_START', NOW() - INTERVAL '2 days'),
    (12, 11, 'FINISH_TO_START', NOW() - INTERVAL '2 days'),
    (12, 8, 'FINISH_TO_START', NOW() - INTERVAL '2 days'),
    (14, 4, 'START_TO_START', NOW() - INTERVAL '13 days'),
    (15, 9, 'START_TO_START', NOW() - INTERVAL '2 days'),
    
    -- Project 2 dependencies
    (17, 16, 'FINISH_TO_START', NOW() - INTERVAL '18 days'),
    (18, 16, 'FINISH_TO_START', NOW() - INTERVAL '9 days'),
    (19, 17, 'FINISH_TO_START', NOW() - INTERVAL '9 days'),
    (20, 19, 'FINISH_TO_START', NOW() - INTERVAL '2 days'),
    (21, 19, 'FINISH_TO_START', NOW() - INTERVAL '2 days');

-- =====================================================
-- 3. TASK COMMENTS
-- =====================================================

DO $$
BEGIN
    RAISE NOTICE 'Creating task comments...';
END $$;

INSERT INTO task_comments (task_id, user_id, comment, parent_comment_id, created_at, updated_at)
VALUES 
    -- Comments on T006 (Shopping Cart API)
    (6, 18, 'Great progress! Make sure to handle edge cases like expired items in cart.', NULL, NOW() - INTERVAL '5 days', NOW() - INTERVAL '5 days'),
    (6, 9, 'Thanks for the feedback! I will add validation for product availability.', 1, NOW() - INTERVAL '4 days', NOW() - INTERVAL '4 days'),
    (6, 18, 'Also consider implementing cart abandonment tracking for analytics.', NULL, NOW() - INTERVAL '3 days', NOW() - INTERVAL '3 days'),
    
    -- Comments on T007 (Order Processing)
    (7, 18, 'Remember to implement proper transaction handling to prevent data inconsistency.', NULL, NOW() - INTERVAL '7 days', NOW() - INTERVAL '7 days'),
    (7, 10, 'Yes, I am using database transactions for order creation and inventory updates.', 4, NOW() - INTERVAL '6 days', NOW() - INTERVAL '6 days'),
    
    -- Comments on T009 (Homepage)
    (9, 8, 'The homepage looks good! Can we add a loading skeleton for better UX?', NULL, NOW() - INTERVAL '2 days', NOW() - INTERVAL '2 days'),
    (9, 8, 'Also, the product filters are not working correctly on mobile.', NULL, NOW() - INTERVAL '1 days', NOW() - INTERVAL '1 days'),
    
    -- Comments on T014 (API Testing)
    (14, 18, 'Aim for at least 80% code coverage for the API layer.', NULL, NOW() - INTERVAL '8 days', NOW() - INTERVAL '8 days'),
    (14, 15, 'Currently at 65% coverage. Will add more test cases this week.', 8, NOW() - INTERVAL '6 days', NOW() - INTERVAL '6 days');

-- =====================================================
-- 4. TASK TIME LOGS
-- =====================================================

DO $$
BEGIN
    RAISE NOTICE 'Creating task time logs...';
END $$;

INSERT INTO task_time_logs (task_id, talent_id, start_time, end_time, duration_minutes, description, created_at)
VALUES 
    -- Time logs for completed tasks
    (1, 2, NOW() - INTERVAL '45 days 8 hours', NOW() - INTERVAL '45 days 4 hours', 240, 'Project initialization and setup', NOW() - INTERVAL '45 days'),
    (1, 2, NOW() - INTERVAL '44 days 9 hours', NOW() - INTERVAL '44 days 5 hours', 240, 'Configuration and dependencies', NOW() - INTERVAL '44 days'),
    
    (2, 3, NOW() - INTERVAL '40 days 10 hours', NOW() - INTERVAL '40 days 6 hours', 240, 'Database design and ERD', NOW() - INTERVAL '40 days'),
    (2, 3, NOW() - INTERVAL '39 days 9 hours', NOW() - INTERVAL '39 days 4 hours', 300, 'Schema implementation and migrations', NOW() - INTERVAL '39 days'),
    
    (3, 5, NOW() - INTERVAL '38 days 10 hours', NOW() - INTERVAL '38 days 6 hours', 240, 'Design research and wireframes', NOW() - INTERVAL '38 days'),
    (3, 5, NOW() - INTERVAL '36 days 8 hours', NOW() - INTERVAL '36 days 3 hours', 300, 'High-fidelity mockups', NOW() - INTERVAL '36 days'),
    
    -- Time logs for in-progress tasks
    (6, 2, NOW() - INTERVAL '10 days 9 hours', NOW() - INTERVAL '10 days 5 hours', 240, 'Cart API implementation', NOW() - INTERVAL '10 days'),
    (6, 2, NOW() - INTERVAL '8 days 10 hours', NOW() - INTERVAL '8 days 6 hours', 240, 'Cart validation logic', NOW() - INTERVAL '8 days'),
    (6, 2, NOW() - INTERVAL '5 days 9 hours', NOW() - INTERVAL '5 days 4 hours', 300, 'Testing and bug fixes', NOW() - INTERVAL '5 days'),
    
    (7, 3, NOW() - INTERVAL '12 days 8 hours', NOW() - INTERVAL '12 days 4 hours', 240, 'Order creation API', NOW() - INTERVAL '12 days'),
    (7, 3, NOW() - INTERVAL '9 days 10 hours', NOW() - INTERVAL '9 days 6 hours', 240, 'Order status management', NOW() - INTERVAL '9 days'),
    (7, 3, NOW() - INTERVAL '4 days 9 hours', NOW() - INTERVAL '4 days 5 hours', 240, 'Integration with payment', NOW() - INTERVAL '4 days'),
    
    (9, 1, NOW() - INTERVAL '20 days 9 hours', NOW() - INTERVAL '20 days 5 hours', 240, 'Homepage layout', NOW() - INTERVAL '20 days'),
    (9, 1, NOW() - INTERVAL '15 days 10 hours', NOW() - INTERVAL '15 days 6 hours', 240, 'Product listing component', NOW() - INTERVAL '15 days'),
    (9, 1, NOW() - INTERVAL '8 days 8 hours', NOW() - INTERVAL '8 days 3 hours', 300, 'Filters and pagination', NOW() - INTERVAL '8 days'),
    
    (14, 8, NOW() - INTERVAL '10 days 10 hours', NOW() - INTERVAL '10 days 6 hours', 240, 'Test setup and configuration', NOW() - INTERVAL '10 days'),
    (14, 8, NOW() - INTERVAL '6 days 9 hours', NOW() - INTERVAL '6 days 4 hours', 300, 'API integration tests', NOW() - INTERVAL '6 days');

-- =====================================================
-- 5. PAYMENTS - Thanh toán từ doanh nghiệp
-- =====================================================

DO $$
BEGIN
    RAISE NOTICE 'Creating payments...';
END $$;

INSERT INTO payments (
    project_id, enterprise_id, payment_code, amount, currency,
    payos_order_id, payos_transaction_id, payos_payment_link,
    status, payment_method,
    created_at, payment_link_expires_at, paid_at,
    description, note
)
VALUES 
    -- Payment 1: Project 1 - COMPLETED (70M VND)
    (1, 1, 'PAY-PRJ001-001', 70000000.00, 'VND',
    'PAYOS-ORD-2026-001', 'PAYOS-TXN-2026-001', 'https://pay.payos.vn/links/2026-001',
    'COMPLETED', 'BANK_TRANSFER',
    NOW() - INTERVAL '40 days', NOW() - INTERVAL '39 days', NOW() - INTERVAL '39 days',
    'Payment for E-Commerce Platform project - First milestone', 
    'Payment received on time'),
    
    -- Payment 2: Project 2 - COMPLETED (50M VND)
    (2, 2, 'PAY-PRJ002-001', 50000000.00, 'VND',
    'PAYOS-ORD-2026-002', 'PAYOS-TXN-2026-002', 'https://pay.payos.vn/links/2026-002',
    'COMPLETED', 'BANK_TRANSFER',
    NOW() - INTERVAL '12 days', NOW() - INTERVAL '11 days', NOW() - INTERVAL '11 days',
    'Payment for Mobile Learning App project - Initial payment', 
    'Payment processed successfully'),
    
    -- Payment 3: Project 5 - COMPLETED (Completed project, 45M VND)
    (5, 2, 'PAY-PRJ005-001', 45000000.00, 'VND',
    'PAYOS-ORD-2025-103', 'PAYOS-TXN-2025-103', 'https://pay.payos.vn/links/2025-103',
    'COMPLETED', 'BANK_TRANSFER',
    NOW() - INTERVAL '120 days', NOW() - INTERVAL '119 days', NOW() - INTERVAL '119 days',
    'Payment for Website Development project - Final payment', 
    'Project completed successfully'),
    
    -- Payment 4: Project 1 - PENDING (Second milestone, 30M VND)
    (1, 1, 'PAY-PRJ001-002', 30000000.00, 'VND',
    'PAYOS-ORD-2026-003', NULL, 'https://pay.payos.vn/links/2026-003',
    'PENDING', NULL,
    NOW() - INTERVAL '3 days', NOW() + INTERVAL '4 days', NULL,
    'Payment for E-Commerce Platform project - Second milestone', 
    'Waiting for enterprise payment');

-- =====================================================
-- 6. PAYMENT TRANSACTIONS
-- =====================================================

DO $$
BEGIN
    RAISE NOTICE 'Creating payment transactions...';
END $$;

INSERT INTO payment_transactions (
    payment_id, transaction_id, transaction_type, amount,
    payos_response, status, created_at
)
VALUES 
    -- Transactions for Payment 1
    (1, 'TXN-2026-001-001', 'PAYMENT', 70000000.00,
    '{"code": "00", "message": "Success", "data": {"accountNumber": "1234567890", "reference": "FT26001234567"}}',
    'SUCCESS', NOW() - INTERVAL '39 days'),
    
    -- Transactions for Payment 2
    (2, 'TXN-2026-002-001', 'PAYMENT', 50000000.00,
    '{"code": "00", "message": "Success", "data": {"accountNumber": "0987654321", "reference": "FT26002234567"}}',
    'SUCCESS', NOW() - INTERVAL '11 days'),
    
    -- Transactions for Payment 3
    (3, 'TXN-2025-103-001', 'PAYMENT', 45000000.00,
    '{"code": "00", "message": "Success", "data": {"accountNumber": "0987654321", "reference": "FT25103234567"}}',
    'SUCCESS', NOW() - INTERVAL '119 days');

-- =====================================================
-- 7. FUND ALLOCATIONS (70/20/10 split)
-- =====================================================

DO $$
BEGIN
    RAISE NOTICE 'Creating fund allocations...';
END $$;

INSERT INTO fund_allocations (
    project_id, payment_id, total_amount,
    team_percentage, team_amount,
    mentor_percentage, mentor_amount,
    lab_percentage, lab_amount,
    status, validated_by, validated_at, created_at
)
VALUES 
    -- Allocation 1: Project 1 - Payment 1 (70M VND)
    (1, 1, 70000000.00,
    70.00, 49000000.00,
    20.00, 14000000.00,
    10.00, 7000000.00,
    'DISTRIBUTED', 2, NOW() - INTERVAL '38 days', NOW() - INTERVAL '39 days'),
    
    -- Allocation 2: Project 2 - Payment 2 (50M VND)
    (2, 2, 50000000.00,
    70.00, 35000000.00,
    20.00, 10000000.00,
    10.00, 5000000.00,
    'DISTRIBUTED', 2, NOW() - INTERVAL '10 days', NOW() - INTERVAL '11 days'),
    
    -- Allocation 3: Project 5 - Payment 3 (45M VND) - COMPLETED
    (5, 3, 45000000.00,
    70.00, 31500000.00,
    20.00, 9000000.00,
    10.00, 4500000.00,
    'COMPLETED', 2, NOW() - INTERVAL '118 days', NOW() - INTERVAL '119 days');

-- =====================================================
-- 8. FUND DISTRIBUTIONS (To mentors and lab)
-- =====================================================

DO $$
BEGIN
    RAISE NOTICE 'Creating fund distributions...';
END $$;

INSERT INTO fund_distributions (
    allocation_id, recipient_type, recipient_id, amount,
    status, disbursed_at, disbursed_by,
    payment_method, transaction_reference, created_at
)
VALUES 
    -- Distributions for Allocation 1 (Project 1)
    (1, 'MENTOR', 1, 14000000.00,
    'COMPLETED', NOW() - INTERVAL '35 days', 2,
    'BANK_TRANSFER', 'MENTOR-DISB-001', NOW() - INTERVAL '38 days'),
    
    (1, 'LAB', NULL, 7000000.00,
    'COMPLETED', NOW() - INTERVAL '35 days', 2,
    'BANK_TRANSFER', 'LAB-DISB-001', NOW() - INTERVAL '38 days'),
    
    -- Distributions for Allocation 2 (Project 2)
    (2, 'MENTOR', 3, 10000000.00,
    'COMPLETED', NOW() - INTERVAL '8 days', 2,
    'BANK_TRANSFER', 'MENTOR-DISB-002', NOW() - INTERVAL '10 days'),
    
    (2, 'LAB', NULL, 5000000.00,
    'COMPLETED', NOW() - INTERVAL '8 days', 2,
    'BANK_TRANSFER', 'LAB-DISB-002', NOW() - INTERVAL '10 days'),
    
    -- Distributions for Allocation 3 (Project 5 - Completed)
    (3, 'MENTOR', 4, 9000000.00,
    'COMPLETED', NOW() - INTERVAL '115 days', 2,
    'BANK_TRANSFER', 'MENTOR-DISB-003', NOW() - INTERVAL '118 days'),
    
    (3, 'LAB', NULL, 4500000.00,
    'COMPLETED', NOW() - INTERVAL '115 days', 2,
    'BANK_TRANSFER', 'LAB-DISB-003', NOW() - INTERVAL '118 days');

-- =====================================================
-- 9. TEAM FUND DISTRIBUTIONS (Leader quản lý 70%)
-- =====================================================

DO $$
BEGIN
    RAISE NOTICE 'Creating team fund distributions...';
END $$;

INSERT INTO team_fund_distributions (
    project_id, allocation_id, submitted_by, total_team_amount, status,
    approved_by_mentor, approved_by_mentor_at,
    approved_by_lab, approved_by_lab_at,
    rejection_reason, created_at, updated_at
)
VALUES 
    -- Team distribution 1: Project 1 (49M VND) - APPROVED & DISBURSED
    (1, 1, 2, 49000000.00, 'DISBURSED',
    1, NOW() - INTERVAL '36 days',
    2, NOW() - INTERVAL '35 days',
    NULL, NOW() - INTERVAL '38 days', NOW() - INTERVAL '35 days'),
    
    -- Team distribution 2: Project 2 (35M VND) - APPROVED BY MENTOR
    (2, 2, 4, 35000000.00, 'APPROVED_BY_MENTOR',
    3, NOW() - INTERVAL '8 days',
    NULL, NULL,
    NULL, NOW() - INTERVAL '10 days', NOW() - INTERVAL '8 days'),
    
    -- Team distribution 3: Project 5 (31.5M VND) - DISBURSED (Completed)
    (5, 3, 1, 31500000.00, 'DISBURSED',
    4, NOW() - INTERVAL '116 days',
    2, NOW() - INTERVAL '115 days',
    NULL, NOW() - INTERVAL '118 days', NOW() - INTERVAL '115 days');

-- =====================================================
-- 10. TEAM MEMBER ALLOCATIONS
-- =====================================================

DO $$
BEGIN
    RAISE NOTICE 'Creating team member allocations...';
END $$;

INSERT INTO team_member_allocations (
    distribution_id, talent_id, percentage, amount, reason,
    tasks_completed, hours_contributed, performance_score, created_at
)
VALUES 
    -- Team members for Project 1 (Total: 49M VND)
    (1, 2, 25.00, 12250000.00, 'Team Leader - Project management, backend development',
    6, 180, 4.8, NOW() - INTERVAL '38 days'),
    
    (1, 1, 20.00, 9800000.00, 'Frontend Lead - Homepage and product listing',
    3, 150, 4.5, NOW() - INTERVAL '38 days'),
    
    (1, 3, 20.00, 9800000.00, 'Backend Developer - API development and database',
    4, 165, 4.6, NOW() - INTERVAL '38 days'),
    
    (1, 5, 15.00, 7350000.00, 'UI/UX Designer - Design mockups and user experience',
    2, 120, 4.4, NOW() - INTERVAL '38 days'),
    
    (1, 7, 12.00, 5880000.00, 'DevOps Engineer - Docker and CI/CD setup',
    2, 90, 4.3, NOW() - INTERVAL '38 days'),
    
    (1, 8, 8.00, 3920000.00, 'QA Tester - Testing and quality assurance',
    1, 60, 4.2, NOW() - INTERVAL '38 days'),
    
    -- Team members for Project 2 (Total: 35M VND)
    (2, 4, 60.00, 21000000.00, 'Team Leader & Main Developer - App architecture and features',
    4, 200, 4.8, NOW() - INTERVAL '10 days'),
    
    (2, 5, 40.00, 14000000.00, 'UI/UX Designer - Complete app design system',
    2, 130, 4.7, NOW() - INTERVAL '10 days'),
    
    -- Team members for Project 5 - Completed (Total: 31.5M VND)
    (3, 1, 35.00, 11025000.00, 'Team Leader - Project coordination and frontend development',
    5, 180, 4.9, NOW() - INTERVAL '118 days'),
    
    (3, 5, 30.00, 9450000.00, 'UI/UX Designer - Design and user interface implementation',
    4, 160, 4.8, NOW() - INTERVAL '118 days'),
    
    (3, 2, 20.00, 6300000.00, 'Full-stack Developer - Backend and frontend support',
    3, 110, 4.6, NOW() - INTERVAL '118 days'),
    
    (3, 8, 15.00, 4725000.00, 'QA Tester - Testing and bug fixes',
    2, 90, 4.5, NOW() - INTERVAL '118 days');

-- =====================================================
-- 11. DISBURSEMENTS (Thực tế giải ngân)
-- =====================================================

DO $$
BEGIN
    RAISE NOTICE 'Creating disbursements...';
END $$;

INSERT INTO disbursements (
    reference_type, reference_id, recipient_type, recipient_id,
    amount, currency, payment_method,
    bank_name, bank_account_number, bank_account_name,
    transaction_reference, transaction_date,
    status, processed_by, processed_at, note, created_at
)
VALUES 
    -- Disbursements for Project 1 mentors
    ('FUND_DISTRIBUTION', 1, 'MENTOR', 1,
    14000000.00, 'VND', 'BANK_TRANSFER',
    'Vietcombank', '1234567890', 'NGUYEN QUANG HUY',
    'VCB-DISB-001', NOW() - INTERVAL '35 days',
    'COMPLETED', 2, NOW() - INTERVAL '35 days', 'Mentor fee for E-Commerce project', NOW() - INTERVAL '38 days'),
    
    -- Disbursements for Project 1 lab
    ('FUND_DISTRIBUTION', 2, 'LAB', NULL,
    7000000.00, 'VND', 'BANK_TRANSFER',
    'Vietcombank', '9876543210', 'LABODC LAB UTH',
    'VCB-DISB-002', NOW() - INTERVAL '35 days',
    'COMPLETED', 2, NOW() - INTERVAL '35 days', 'Lab commission for E-Commerce project', NOW() - INTERVAL '38 days'),
    
    -- Disbursements for Project 1 team members
    ('FUND_DISTRIBUTION', 1, 'TALENT', 2,
    12250000.00, 'VND', 'BANK_TRANSFER',
    'Vietcombank', '2345678901', 'TRAN THI B',
    'VCB-DISB-003', NOW() - INTERVAL '35 days',
    'COMPLETED', 2, NOW() - INTERVAL '35 days', 'Team Leader payment', NOW() - INTERVAL '38 days'),
    
    ('FUND_DISTRIBUTION', 2, 'TALENT', 1,
    9800000.00, 'VND', 'BANK_TRANSFER',
    'Vietcombank', '3456789012', 'NGUYEN VAN A',
    'VCB-DISB-004', NOW() - INTERVAL '35 days',
    'COMPLETED', 2, NOW() - INTERVAL '35 days', 'Frontend developer payment', NOW() - INTERVAL '38 days'),
    
    ('FUND_DISTRIBUTION', 3, 'TALENT', 3,
    9800000.00, 'VND', 'BANK_TRANSFER',
    'Techcombank', '4567890123', 'LE VAN C',
    'TCB-DISB-005', NOW() - INTERVAL '35 days',
    'COMPLETED', 2, NOW() - INTERVAL '35 days', 'Backend developer payment', NOW() - INTERVAL '38 days'),
    
    ('FUND_DISTRIBUTION', 4, 'TALENT', 5,
    7350000.00, 'VND', 'BANK_TRANSFER',
    'MBBank', '5678901234', 'HOANG VAN E',
    'MBB-DISB-006', NOW() - INTERVAL '35 days',
    'COMPLETED', 2, NOW() - INTERVAL '35 days', 'UI/UX designer payment', NOW() - INTERVAL '38 days'),
    
    ('FUND_DISTRIBUTION', 5, 'TALENT', 7,
    5880000.00, 'VND', 'BANK_TRANSFER',
    'ACB', '6789012345', 'DAN VAN G',
    'ACB-DISB-007', NOW() - INTERVAL '35 days',
    'COMPLETED', 2, NOW() - INTERVAL '35 days', 'DevOps engineer payment', NOW() - INTERVAL '38 days'),
    
    ('FUND_DISTRIBUTION', 6, 'TALENT', 8,
    3920000.00, 'VND', 'MOMO',
    NULL, '0905555558', 'NGO THI H',
    'MOMO-DISB-008', NOW() - INTERVAL '35 days',
    'COMPLETED', 2, NOW() - INTERVAL '35 days', 'QA tester payment', NOW() - INTERVAL '38 days'),
    
    -- Disbursements for Project 2 mentors and lab
    ('FUND_DISTRIBUTION', 3, 'MENTOR', 3,
    10000000.00, 'VND', 'BANK_TRANSFER',
    'Vietcombank', '7890123456', 'LE HONG ANH',
    'VCB-DISB-009', NOW() - INTERVAL '8 days',
    'COMPLETED', 2, NOW() - INTERVAL '8 days', 'Mentor fee for Mobile Learning App', NOW() - INTERVAL '10 days'),
    
    ('FUND_DISTRIBUTION', 4, 'LAB', NULL,
    5000000.00, 'VND', 'BANK_TRANSFER',
    'Vietcombank', '9876543210', 'LABODC LAB UTH',
    'VCB-DISB-010', NOW() - INTERVAL '8 days',
    'COMPLETED', 2, NOW() - INTERVAL '8 days', 'Lab commission for Mobile Learning App', NOW() - INTERVAL '10 days');

-- =====================================================
-- 12. MENTOR REPORTS
-- =====================================================

DO $$
BEGIN
    RAISE NOTICE 'Creating mentor reports...';
END $$;

INSERT INTO mentor_reports (
    project_id, mentor_id, report_type, reporting_period,
    project_progress, tasks_completed, tasks_upcoming,
    team_performance, achievements, challenges, risks, next_month_goals,
    budget_usage, meetings_held, code_metrics,
    status, submitted_at, created_at, updated_at
)
VALUES 
    -- Report 1: Project 1 - January 2026
    (1, 1, 'MONTHLY', '2026-01',
    '{"overallCompletion": 45, "plannedCompletion": 40, "variance": 5, "status": "ON_TRACK"}'::jsonb,
    '["Project setup completed", "Database schema implemented", "Authentication API completed", "Product Management API finished"]'::jsonb,
    '["Shopping cart API", "Order processing API", "Payment gateway integration"]'::jsonb,
    '{"teamLeadership": "Excellent", "codeQuality": "Good", "collaboration": "Very Good", "punctuality": "Good"}'::jsonb,
    '["Successfully completed initial phase ahead of schedule", "Team adapted well to agile methodology", "Good code review practices established"]'::jsonb,
    '["Some delays in cart API due to complex validation requirements", "Need more focus on testing coverage"]'::jsonb,
    '["Payment gateway integration complexity", "Timeline pressure for frontend development"]'::jsonb,
    '["Complete shopping cart and order APIs", "Integrate PayOS payment gateway", "Start frontend development", "Achieve 80% test coverage"]'::jsonb,
    '{"totalBudget": 70000000, "spent": 49000000, "remaining": 21000000, "percentageUsed": 70}'::jsonb,
    8,
    '{"linesOfCode": 15000, "pullRequests": 45, "codeReviewsCompleted": 42, "bugsFixed": 18}'::jsonb,
    'PUBLISHED', NOW() - INTERVAL '2 days',
    NOW() - INTERVAL '5 days', NOW() - INTERVAL '2 days'),
    
    -- Report 2: Project 2 - January 2026
    (2, 3, 'MONTHLY', '2026-01',
    '{"overallCompletion": 30, "plannedCompletion": 25, "variance": 5, "status": "ON_TRACK"}'::jsonb,
    '["Flutter project setup completed", "UI design system implemented", "Firebase backend configured"]'::jsonb,
    '["Authentication screens", "Course listing and detail", "Video player integration"]'::jsonb,
    '{"teamLeadership": "Very Good", "designQuality": "Excellent", "collaboration": "Good", "adaptability": "Very Good"}'::jsonb,
    '["Beautiful UI design system created", "Team working efficiently despite small size", "Good progress on Firebase setup"]'::jsonb,
    '["Need more team members for faster progress", "Video player integration is complex"]'::jsonb,
    '["Team size limitation affecting timeline", "Third-party SDK integration challenges"]'::jsonb,
    '["Complete authentication screens", "Recruit 2 more team members", "Start video player integration", "Implement course listing"]'::jsonb,
    '{"totalBudget": 50000000, "spent": 35000000, "remaining": 15000000, "percentageUsed": 70}'::jsonb,
    6,
    '{"linesOfCode": 8000, "commits": 85, "widgetsCreated": 42, "screensCompleted": 8}'::jsonb,
    'PUBLISHED', NOW() - INTERVAL '1 days',
    NOW() - INTERVAL '4 days', NOW() - INTERVAL '1 days'),
    
    -- Report 3: Project 1 - December 2025 (Previous month)
    (1, 1, 'MONTHLY', '2025-12',
    '{"overallCompletion": 20, "plannedCompletion": 20, "variance": 0, "status": "ON_TRACK"}'::jsonb,
    '["Project kickoff and planning", "Team formation and role assignment", "Initial requirements gathering"]'::jsonb,
    '["Project setup", "Database design", "UI/UX mockups"]'::jsonb,
    '{"teamLeadership": "Good", "communication": "Very Good", "enthusiasm": "Excellent"}'::jsonb,
    '["Team formed successfully with diverse skills", "Clear project goals established", "Good client communication"]'::jsonb,
    '["Team members learning curve for some technologies"]'::jsonb,
    '["Scope creep potential", "Timeline optimization needed"]'::jsonb,
    '["Complete project setup", "Finalize database design", "Start API development"]'::jsonb,
    '{"totalBudget": 0, "spent": 0, "remaining": 0, "percentageUsed": 0}'::jsonb,
    4,
    '{}'::jsonb,
    'PUBLISHED', NOW() - INTERVAL '32 days',
    NOW() - INTERVAL '35 days', NOW() - INTERVAL '32 days');

-- =====================================================
-- 13. TEAM REPORTS
-- =====================================================

DO $$
BEGIN
    RAISE NOTICE 'Creating team reports...';
END $$;

INSERT INTO team_reports (
    project_id, submitted_by, report_type, reporting_period, overall_progress,
    tasks_completed, tasks_in_progress, issues, next_month_plan, team_performance,
    status, submitted_at, reviewed_by, reviewed_at, review_comment,
    created_at, updated_at
)
VALUES 
    -- Report 1: Project 1 - January 2026 (by Talent Leader)
    (1, 2, 'MONTHLY', '2026-01', 45,
    '["Setup project structure", "Design database schema", "Implement authentication API", "Complete product management API", "Create UI mockups"]'::jsonb,
    '["Shopping cart API (75% done)", "Order processing API (50% done)", "Homepage development (62% done)", "API testing (37% done)"]'::jsonb,
    '["Shopping cart validation more complex than expected", "Need clarification on payment flow", "Some frontend dependencies delayed"]'::jsonb,
    '["Complete cart and order APIs", "Integrate payment gateway", "Finish homepage and product pages", "Increase test coverage to 80%"]'::jsonb,
    '{"overallRating": 4.5, "collaboration": "Excellent", "productivity": "Very Good", "codeQuality": "Good", "communication": "Very Good"}'::jsonb,
    'REVIEWED', NOW() - INTERVAL '3 days',
    1, NOW() - INTERVAL '2 days', 'Great progress! Team is working well together. Keep up the momentum.',
    NOW() - INTERVAL '5 days', NOW() - INTERVAL '2 days'),
    
    -- Report 2: Project 2 - January 2026
    (2, 4, 'MONTHLY', '2026-01', 30,
    '["Setup Flutter project", "Create UI design system", "Setup Firebase backend", "Started authentication screens"]'::jsonb,
    '["Authentication screens (60% done)", "Firebase integration (42% done)"]'::jsonb,
    '["Need more team members", "Video player SDK selection needed", "Some design iterations taking longer"]'::jsonb,
    '["Complete authentication", "Recruit more developers", "Start course listing", "Research video streaming solutions"]'::jsonb,
    '{"overallRating": 4.3, "collaboration": "Very Good", "designQuality": "Excellent", "efficiency": "Good"}'::jsonb,
    'REVIEWED', NOW() - INTERVAL '2 days',
    3, NOW() - INTERVAL '1 days', 'Good work despite team size. Design quality is excellent. Let''s focus on recruitment.',
    NOW() - INTERVAL '4 days', NOW() - INTERVAL '1 days'),
    
    -- Report 3: Project 5 - November 2025 (Completed project - Final report)
    (5, 1, 'FINAL', '2025-11', 100,
    '["All pages implemented", "Complete testing done", "SEO optimization completed", "Performance optimization done", "Client review addressed"]'::jsonb,
    '[]'::jsonb,
    '[]'::jsonb,
    '["Project delivery and handover", "Documentation finalization"]'::jsonb,
    '{"overallRating": 4.8, "collaboration": "Excellent", "quality": "Excellent", "delivery": "On-time"}'::jsonb,
    'PUBLISHED', NOW() - INTERVAL '90 days',
    4, NOW() - INTERVAL '89 days', 'Excellent work! Project delivered on time with high quality. Well done team!',
    NOW() - INTERVAL '92 days', NOW() - INTERVAL '89 days');

-- =====================================================
-- 14. TALENT EVALUATIONS
-- =====================================================

DO $$
BEGIN
    RAISE NOTICE 'Creating talent evaluations...';
END $$;

INSERT INTO talent_evaluations (
    project_id, talent_id, mentor_id, evaluation_period,
    overall_score,
    technical_skills, problem_solving, teamwork, communication, code_quality, punctuality,
    strengths, weaknesses, recommendations,
    tasks_completed, tasks_total, hours_worked,
    grade, created_at
)
VALUES 
    -- Evaluations for Project 1 - January 2026
    (1, 2, 1, '2026-01', 8.5,
    '{"score": 9.0, "comment": "Strong full-stack skills, excellent backend implementation"}'::jsonb,
    '{"score": 8.5, "comment": "Good problem-solving approach, handles complex issues well"}'::jsonb,
    '{"score": 9.0, "comment": "Excellent team leadership and collaboration skills"}'::jsonb,
    '{"score": 8.0, "comment": "Clear communication, good at explaining technical concepts"}'::jsonb,
    '{"score": 8.5, "comment": "Clean code, follows best practices, good documentation"}'::jsonb,
    '{"score": 9.0, "comment": "Always on time, reliable team member"}'::jsonb,
    '["Strong technical skills", "Excellent leadership abilities", "Good code quality", "Reliable and punctual"]'::jsonb,
    '["Could improve frontend design skills", "Sometimes over-engineers solutions"]'::jsonb,
    '["Continue developing leadership skills", "Learn more about frontend frameworks", "Focus on simple solutions first"]'::jsonb,
    6, 8, 180,
    'A', NOW() - INTERVAL '2 days'),
    
    (1, 1, 1, '2026-01', 8.0,
    '{"score": 8.5, "comment": "Strong React skills, good understanding of frontend architecture"}'::jsonb,
    '{"score": 7.5, "comment": "Solid problem-solving, sometimes needs guidance on complex issues"}'::jsonb,
    '{"score": 8.5, "comment": "Great team player, helpful to others"}'::jsonb,
    '{"score": 8.0, "comment": "Good communication, actively participates in discussions"}'::jsonb,
    '{"score": 8.0, "comment": "Good code quality, could improve on edge case handling"}'::jsonb,
    '{"score": 8.5, "comment": "Punctual and committed"}'::jsonb,
    '["Strong frontend skills", "Good team collaboration", "Quick learner", "Positive attitude"]'::jsonb,
    '["Edge case handling needs improvement", "Could be more proactive in asking questions"]'::jsonb,
    '["Focus more on testing edge cases", "Be more proactive in seeking clarification", "Keep up the good work"]'::jsonb,
    3, 5, 150,
    'B', NOW() - INTERVAL '2 days'),
    
    (1, 3, 1, '2026-01', 8.3,
    '{"score": 9.0, "comment": "Excellent Java and Spring Boot skills, strong backend knowledge"}'::jsonb,
    '{"score": 8.5, "comment": "Excellent problem-solving skills, thinks through solutions carefully"}'::jsonb,
    '{"score": 7.5, "comment": "Good teamwork, but could communicate more frequently"}'::jsonb,
    '{"score": 7.5, "comment": "Communication is good but could be more proactive"}'::jsonb,
    '{"score": 9.0, "comment": "Excellent code quality, well-structured and maintainable"}'::jsonb,
    '{"score": 8.5, "comment": "Very reliable and punctual"}'::jsonb,
    '["Outstanding technical skills", "Excellent code quality", "Strong database knowledge", "Detail-oriented"]'::jsonb,
    '["Could communicate progress more frequently", "Sometimes works in isolation"]'::jsonb,
    '["Improve communication frequency", "Share knowledge more with team", "Continue excellent technical work"]'::jsonb,
    4, 6, 165,
    'A', NOW() - INTERVAL '2 days'),
    
    (1, 5, 1, '2026-01', 8.0,
    '{"score": 8.5, "comment": "Excellent design skills, great eye for UI/UX"}'::jsonb,
    '{"score": 7.5, "comment": "Good at solving design challenges"}'::jsonb,
    '{"score": 8.5, "comment": "Very collaborative, works well with developers"}'::jsonb,
    '{"score": 8.5, "comment": "Excellent communication of design decisions"}'::jsonb,
    '{"score": 8.0, "comment": "Good CSS quality, well-organized styles"}'::jsonb,
    '{"score": 8.0, "comment": "Generally punctual and reliable"}'::jsonb,
    '["Excellent design skills", "Great user-centered thinking", "Good collaboration with developers"]'::jsonb,
    '["Could learn more about responsive design edge cases", "Design iterations sometimes take longer"]'::jsonb,
    '["Improve time management on design iterations", "Learn more about accessibility", "Keep up the creative work"]'::jsonb,
    2, 3, 120,
    'B', NOW() - INTERVAL '2 days'),
    
    -- Evaluations for Project 2 - January 2026
    (2, 4, 3, '2026-01', 8.7,
    '{"score": 9.0, "comment": "Excellent Flutter skills, strong mobile development knowledge"}'::jsonb,
    '{"score": 8.5, "comment": "Great problem-solving abilities, handles complex challenges well"}'::jsonb,
    '{"score": 9.0, "comment": "Excellent leadership and collaboration"}'::jsonb,
    '{"score": 9.0, "comment": "Outstanding communication with team and mentor"}'::jsonb,
    '{"score": 8.5, "comment": "High-quality code, well-structured and maintainable"}'::jsonb,
    '{"score": 9.0, "comment": "Extremely reliable and punctual"}'::jsonb,
    '["Outstanding Flutter expertise", "Excellent leadership", "Strong communication", "High productivity"]'::jsonb,
    '["Could delegate more tasks to team members"]'::jsonb,
    '["Work on delegation skills", "Continue excellent technical leadership", "Mentor junior developers more"]'::jsonb,
    4, 5, 200,
    'A', NOW() - INTERVAL '1 days'),
    
    (2, 5, 3, '2026-01', 8.4,
    '{"score": 9.0, "comment": "Exceptional design skills, beautiful and functional UI"}'::jsonb,
    '{"score": 8.0, "comment": "Good at solving design challenges creatively"}'::jsonb,
    '{"score": 8.5, "comment": "Great collaboration with developer"}'::jsonb,
    '{"score": 8.5, "comment": "Clear communication of design concepts"}'::jsonb,
    '{"score": 8.0, "comment": "Good implementation of designs in Flutter"}'::jsonb,
    '{"score": 9.0, "comment": "Very punctual and committed"}'::jsonb,
    '["Exceptional design quality", "Great attention to detail", "Good Flutter widget implementation"]'::jsonb,
    '["Could learn more about mobile-specific design patterns"]'::jsonb,
    '["Study mobile design best practices", "Continue excellent design work", "Explore animation and micro-interactions"]'::jsonb,
    2, 3, 130,
    'A', NOW() - INTERVAL '1 days');

-- =====================================================
-- 15. ENTERPRISE FEEDBACK
-- =====================================================

DO $$
BEGIN
    RAISE NOTICE 'Creating enterprise feedback...';
END $$;

INSERT INTO enterprise_feedback (
    project_id, enterprise_id,
    overall_rating, quality_rating, communication_rating, timeline_rating, professionalism_rating,
    positive_feedback, negative_feedback, suggestions,
    would_recommend, would_work_again,
    status, submitted_at, created_at
)
VALUES 
    -- Feedback 1: Project 1 - Mid-project feedback
    (1, 1,
    4.5, 4.5, 5.0, 4.0, 5.0,
    'The team is doing an excellent job so far. Communication has been outstanding, and the quality of work is very high. The backend APIs are well-designed and documented. Team is very professional and responsive to feedback.',
    'Some delays in frontend development, but understandable given the complexity. Would appreciate more frequent demo sessions.',
    'More frequent demos would help us provide feedback earlier. Consider adding more comprehensive error handling in APIs.',
    true, true,
    'PUBLISHED', NOW() - INTERVAL '5 days',
    NOW() - INTERVAL '7 days'),
    
    -- Feedback 2: Project 5 - Final feedback (Completed project)
    (5, 2,
    4.8, 5.0, 4.5, 5.0, 5.0,
    'Outstanding work! The website exceeded our expectations in terms of design and functionality. The team delivered on time and the quality is excellent. Very professional throughout the entire project. The SEO optimization work was particularly impressive.',
    'Minor: Initial communication could have been more detailed. But this improved significantly as project progressed.',
    'None - we are very satisfied with the outcome. Would definitely work with this team again.',
    true, true,
    'PUBLISHED', NOW() - INTERVAL '85 days',
    NOW() - INTERVAL '87 days');

-- =====================================================
-- 16. TRANSPARENCY REPORTS
-- =====================================================

DO $$
BEGIN
    RAISE NOTICE 'Creating transparency reports...';
END $$;

INSERT INTO transparency_reports (
    report_type, period, statistics, charts_data,
    publish_note, status, public_url, pdf_url,
    created_by, published_at, created_at
)
VALUES 
    -- Report 1: January 2026 Monthly Report
    ('MONTHLY', '2026-01',
    '{
        "projects": {
            "total": 5,
            "newProjects": 1,
            "ongoing": 2,
            "completed": 1,
            "cancelled": 0,
            "successRate": 20.0
        },
        "enterprises": {
            "total": 4,
            "newEnterprises": 0,
            "active": 4,
            "verified": 4
        },
        "talents": {
            "total": 10,
            "newTalents": 2,
            "active": 8,
            "averageRating": 4.5
        },
        "mentors": {
            "total": 4,
            "active": 3,
            "averageRating": 4.7
        },
        "financials": {
            "totalRevenue": 165000000,
            "teamDisbursed": 115500000,
            "mentorDisbursed": 33000000,
            "labRevenue": 16500000,
            "hybridFundAdvanced": 0,
            "hybridFundRepaid": 0
        },
        "performance": {
            "avgProjectCompletion": 85.5,
            "onTimeDelivery": 78.3,
            "customerSatisfaction": 4.6
        }
    }'::jsonb,
    '{
        "projectsByStatus": [
            {"status": "IN_PROGRESS", "count": 2},
            {"status": "RECRUITING", "count": 1},
            {"status": "VALIDATED", "count": 1},
            {"status": "PENDING_VALIDATION", "count": 1}
        ],
        "revenueByMonth": [
            {"month": "2025-12", "amount": 0},
            {"month": "2026-01", "amount": 120000000}
        ],
        "studentParticipation": [
            {"month": "2025-12", "count": 4},
            {"month": "2026-01", "count": 8}
        ],
        "enterpriseSatisfaction": [
            {"rating": 5, "count": 1},
            {"rating": 4, "count": 1}
        ]
    }'::jsonb,
    'Monthly transparency report for January 2026 - Strong growth in student participation and project activity',
    'PUBLISHED',
    'https://labodc.uth.edu.vn/transparency/2026-01',
    'https://labodc.uth.edu.vn/transparency/2026-01.pdf',
    2, NOW() - INTERVAL '1 days',
    NOW() - INTERVAL '3 days'),
    
    -- Report 2: December 2025 Monthly Report
    ('MONTHLY', '2025-12',
    '{
        "projects": {
            "total": 5,
            "newProjects": 0,
            "ongoing": 1,
            "completed": 0,
            "cancelled": 0,
            "successRate": 0.0
        },
        "enterprises": {
            "total": 4,
            "newEnterprises": 0,
            "active": 4,
            "verified": 4
        },
        "talents": {
            "total": 10,
            "newTalents": 0,
            "active": 4,
            "averageRating": 0.0
        },
        "mentors": {
            "total": 4,
            "active": 2,
            "averageRating": 0.0
        },
        "financials": {
            "totalRevenue": 0,
            "teamDisbursed": 0,
            "mentorDisbursed": 0,
            "labRevenue": 0,
            "hybridFundAdvanced": 0,
            "hybridFundRepaid": 0
        },
        "performance": {
            "avgProjectCompletion": 0.0,
            "onTimeDelivery": 0.0,
            "customerSatisfaction": 0.0
        }
    }'::jsonb,
    '{
        "projectsByStatus": [
            {"status": "IN_PROGRESS", "count": 1},
            {"status": "RECRUITING", "count": 1},
            {"status": "VALIDATED", "count": 0},
            {"status": "PENDING_VALIDATION", "count": 0}
        ],
        "revenueByMonth": [
            {"month": "2025-11", "amount": 45000000},
            {"month": "2025-12", "amount": 0}
        ],
        "studentParticipation": [
            {"month": "2025-11", "count": 4},
            {"month": "2025-12", "count": 4}
        ]
    }'::jsonb,
    'Monthly transparency report for December 2025 - Project initiation phase',
    'PUBLISHED',
    'https://labodc.uth.edu.vn/transparency/2025-12',
    'https://labodc.uth.edu.vn/transparency/2025-12.pdf',
    2, NOW() - INTERVAL '32 days',
    NOW() - INTERVAL '34 days');

-- =====================================================
-- SUMMARY & VERIFICATION
-- =====================================================

DO $$
DECLARE
    task_count INTEGER;
    payment_count INTEGER;
    report_count INTEGER;
    evaluation_count INTEGER;
BEGIN
    RAISE NOTICE '========================================';
    RAISE NOTICE 'DATA SEEDING COMPLETED!';
    RAISE NOTICE '========================================';
    
    SELECT COUNT(*) INTO task_count FROM tasks;
    SELECT COUNT(*) INTO payment_count FROM payments;
    SELECT COUNT(*) INTO report_count FROM mentor_reports;
    SELECT COUNT(*) INTO evaluation_count FROM talent_evaluations;
    
    RAISE NOTICE 'Tasks created: %', task_count;
    RAISE NOTICE 'Payments created: %', payment_count;
    RAISE NOTICE 'Mentor reports created: %', report_count;
    RAISE NOTICE 'Talent evaluations created: %', evaluation_count;
    RAISE NOTICE '========================================';
    RAISE NOTICE 'You can now test payment and reporting features!';
    RAISE NOTICE '========================================';
END $$;

-- =====================================================
-- USEFUL QUERIES FOR TESTING
-- =====================================================

-- View all tasks by project
-- SELECT p.title, t.task_id, t.task_name, t.status, t.assigned_to, tal.full_name
-- FROM tasks t
-- JOIN projects p ON t.project_id = p.id
-- LEFT JOIN talents tal ON t.assigned_to = tal.id
-- ORDER BY p.id, t.task_id;

-- View payment summary
-- SELECT p.title, pay.payment_code, pay.amount, pay.status, pay.paid_at
-- FROM payments pay
-- JOIN projects p ON pay.project_id = p.id
-- ORDER BY pay.created_at DESC;

-- View fund allocations
-- SELECT p.title, fa.total_amount, fa.team_amount, fa.mentor_amount, fa.lab_amount, fa.status
-- FROM fund_allocations fa
-- JOIN projects p ON fa.project_id = p.id;

-- View team member allocations
-- SELECT p.title, t.full_name, tma.percentage, tma.amount, tma.reason
-- FROM team_member_allocations tma
-- JOIN team_fund_distributions tfd ON tma.distribution_id = tfd.id
-- JOIN talents t ON tma.talent_id = t.id
-- JOIN projects p ON tfd.project_id = p.id
-- ORDER BY p.id, tma.amount DESC;

-- View mentor reports
-- SELECT p.title, m.full_name as mentor, mr.reporting_period, mr.status, mr.submitted_at
-- FROM mentor_reports mr
-- JOIN projects p ON mr.project_id = p.id
-- JOIN mentors m ON mr.mentor_id = m.id
-- ORDER BY mr.reporting_period DESC;

-- View talent evaluations
-- SELECT p.title, t.full_name as talent, te.evaluation_period, te.overall_score, te.grade
-- FROM talent_evaluations te
-- JOIN projects p ON te.project_id = p.id
-- JOIN talents t ON te.talent_id = t.id
-- ORDER BY te.overall_score DESC;

-- =====================================================
-- END OF SEED DATA
-- =====================================================
