-- Task submissions for mentor tasks (talent uploads)
CREATE TABLE IF NOT EXISTS mentor_task_submissions (
    id BIGSERIAL PRIMARY KEY,
    task_id BIGINT NOT NULL REFERENCES mentor_tasks(id) ON DELETE CASCADE,
    talent_id BIGINT NOT NULL REFERENCES talents(id) ON DELETE CASCADE,
    file_name VARCHAR(255) NOT NULL,
    file_path VARCHAR(500) NOT NULL,
    file_size BIGINT,
    submitted_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_mentor_task_submissions_task
    ON mentor_task_submissions(task_id);

CREATE INDEX IF NOT EXISTS idx_mentor_task_submissions_talent
    ON mentor_task_submissions(talent_id);
