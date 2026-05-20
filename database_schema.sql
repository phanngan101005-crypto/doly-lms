-- ===============================================================
-- DOLY LMS - Database Schema (MySQL)
-- Phiên bản: 1.0
-- Mô tả: Toàn bộ cấu trúc CSDL cho hệ thống DOLY LMS
-- Gồm 36 bảng, chia 10 nhóm chức năng
-- ===============================================================

CREATE DATABASE IF NOT EXISTS doly_lms
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE doly_lms;

-- ===============================================================
-- NHOM 1: AUTH & NGUOI DUNG (3 bang)
-- ===============================================================

-- 1.1 users: Tai khoan trung tam, ho tro 4 vai tro
CREATE TABLE users (
    id            INT             AUTO_INCREMENT PRIMARY KEY,
    full_name     VARCHAR(100)    NOT NULL,
    email         VARCHAR(100)    NOT NULL UNIQUE,
    password_hash VARCHAR(255)    NOT NULL,
    role          ENUM('admin', 'student', 'teacher', 'parent') NOT NULL,
    avatar_url    VARCHAR(255)    DEFAULT NULL,
    status        ENUM('active', 'inactive', 'banned') NOT NULL DEFAULT 'active',
    created_at    DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at    DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    last_login    DATETIME        DEFAULT NULL,
    INDEX idx_users_role (role),
    INDEX idx_users_status (status)
) ENGINE=InnoDB;

-- 1.2 user_verifications: Ma OTP gui qua EmailJS khi dang ky
CREATE TABLE user_verifications (
    id          INT          AUTO_INCREMENT PRIMARY KEY,
    email       VARCHAR(100) NOT NULL,
    otp_code    VARCHAR(6)   NOT NULL,
    expires_at  DATETIME     NOT NULL,
    is_verified BOOLEAN      NOT NULL DEFAULT FALSE,
    created_at  DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_uv_email (email)
) ENGINE=InnoDB;

-- 1.3 user_sessions: Token phien dang nhap
CREATE TABLE user_sessions (
    id          INT          AUTO_INCREMENT PRIMARY KEY,
    user_id     INT          NOT NULL,
    auth_token  VARCHAR(255) NOT NULL UNIQUE,
    expires_at  DATETIME     NOT NULL,
    created_at  DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_us_token (auth_token)
) ENGINE=InnoDB;


-- ===============================================================
-- NHOM 2: LOP HOC (2 bang)
-- ===============================================================

-- 2.1 classes: Thong tin lop hoc do giao vien tao
CREATE TABLE classes (
    id          INT             AUTO_INCREMENT PRIMARY KEY,
    name        VARCHAR(100)    NOT NULL COMMENT 'VD: 8A1, 9B2',
    subject     VARCHAR(50)     DEFAULT NULL COMMENT 'Mon hoc chinh',
    grade_level VARCHAR(20)     DEFAULT NULL COMMENT 'VD: Lop 8, Lop 9',
    teacher_id  INT             NOT NULL COMMENT 'Giao vien chu nhiem',
    class_code  VARCHAR(20)     NOT NULL UNIQUE COMMENT 'Ma moi hoc sinh',
    status      ENUM('active', 'closed') NOT NULL DEFAULT 'active',
    created_at  DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (teacher_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_classes_teacher (teacher_id)
) ENGINE=InnoDB;

-- 2.2 class_members: Hoc sinh trong lop
CREATE TABLE class_members (
    id          INT                    AUTO_INCREMENT PRIMARY KEY,
    class_id    INT                    NOT NULL,
    student_id  INT                    NOT NULL,
    joined_at   DATETIME               NOT NULL DEFAULT CURRENT_TIMESTAMP,
    status      ENUM('active', 'left') NOT NULL DEFAULT 'active',
    FOREIGN KEY (class_id)   REFERENCES classes(id)   ON DELETE CASCADE,
    FOREIGN KEY (student_id) REFERENCES users(id)     ON DELETE CASCADE,
    UNIQUE KEY uq_cm_class_student (class_id, student_id),
    INDEX idx_cm_student (student_id)
) ENGINE=InnoDB;


-- ===============================================================
-- NHOM 3: BAI GIANG & HOC LIEU (5 bang)
-- ===============================================================

-- 3.1 subjects: Danh muc mon hoc (Ly, Hoa, Sinh...)
CREATE TABLE subjects (
    id   INT          AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    slug VARCHAR(50)  NOT NULL UNIQUE
) ENGINE=InnoDB;

-- 3.2 lessons: Bai giang ly thuyet
CREATE TABLE lessons (
    id          INT          AUTO_INCREMENT PRIMARY KEY,
    subject_id  INT          NOT NULL,
    title       VARCHAR(200) NOT NULL,
    content     LONGTEXT     DEFAULT NULL COMMENT 'Noi dung bai giang (HTML)',
    order_index INT          NOT NULL DEFAULT 0 COMMENT 'Thu tu sap xep',
    created_at  DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (subject_id) REFERENCES subjects(id) ON DELETE CASCADE,
    INDEX idx_lessons_subject (subject_id)
) ENGINE=InnoDB;

-- 3.3 videos: Video bai giang
CREATE TABLE videos (
    id          INT          AUTO_INCREMENT PRIMARY KEY,
    lesson_id   INT          DEFAULT NULL COMMENT 'NULL = video doc lap',
    title       VARCHAR(200) NOT NULL,
    url         VARCHAR(500) NOT NULL,
    duration    VARCHAR(20)  DEFAULT NULL COMMENT 'VD: 5:20',
    thumbnail   VARCHAR(500) DEFAULT NULL,
    FOREIGN KEY (lesson_id) REFERENCES lessons(id) ON DELETE SET NULL,
    INDEX idx_videos_lesson (lesson_id)
) ENGINE=InnoDB;

-- 3.4 documents: Tai lieu PDF, Mindmap, Phieu BT
CREATE TABLE documents (
    id          INT                            AUTO_INCREMENT PRIMARY KEY,
    lesson_id   INT                            DEFAULT NULL,
    title       VARCHAR(200)                   NOT NULL,
    file_url    VARCHAR(500)                   NOT NULL,
    type        ENUM('pdf', 'mindmap', 'worksheet') NOT NULL DEFAULT 'pdf',
    download_count INT                         NOT NULL DEFAULT 0,
    created_at  DATETIME                       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (lesson_id) REFERENCES lessons(id) ON DELETE SET NULL,
    INDEX idx_docs_lesson (lesson_id)
) ENGINE=InnoDB;

-- 3.5 lab_models: Mo hinh 3D (Lab)
CREATE TABLE lab_models (
    id            INT          AUTO_INCREMENT PRIMARY KEY,
    title         VARCHAR(200) NOT NULL,
    description   TEXT         DEFAULT NULL,
    thumbnail_url VARCHAR(500) DEFAULT NULL,
    model_url     VARCHAR(500) DEFAULT NULL COMMENT 'Duong dan file .glb',
    lesson_id     INT          DEFAULT NULL,
    subject_id    INT          DEFAULT NULL,
    is_premium    BOOLEAN      NOT NULL DEFAULT FALSE,
    view_count    INT          NOT NULL DEFAULT 0,
    created_at    DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (lesson_id)  REFERENCES lessons(id)  ON DELETE SET NULL,
    FOREIGN KEY (subject_id) REFERENCES subjects(id) ON DELETE SET NULL,
    INDEX idx_lab_subject (subject_id)
) ENGINE=InnoDB;


-- ===============================================================
-- NHOM 4: NGAN HANG CAU HOI & BAI KIEM TRA (6 bang)
-- ===============================================================

-- 4.1 question_bank: Ngan hang cau hoi tap trung
CREATE TABLE question_bank (
    id              INT                                    AUTO_INCREMENT PRIMARY KEY,
    subject_id      INT                                    NOT NULL,
    lesson_id       INT                                    DEFAULT NULL,
    question_text   TEXT                                   NOT NULL,
    question_type   ENUM('multiple_choice', 'true_false', 'fill_blank', 'matching') NOT NULL,
    difficulty      ENUM('easy', 'medium', 'hard')         NOT NULL DEFAULT 'medium',
    xp_reward       INT                                    NOT NULL DEFAULT 10,
    explanation     TEXT                                   DEFAULT NULL COMMENT 'Giai thich dap an',
    created_by      INT                                    DEFAULT NULL COMMENT 'Giao vien tao',
    status          ENUM('active', 'inactive')             NOT NULL DEFAULT 'active',
    created_at      DATETIME                               NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (subject_id)  REFERENCES subjects(id)      ON DELETE CASCADE,
    FOREIGN KEY (lesson_id)   REFERENCES lessons(id)       ON DELETE SET NULL,
    FOREIGN KEY (created_by)  REFERENCES users(id)         ON DELETE SET NULL,
    INDEX idx_qb_subject (subject_id),
    INDEX idx_qb_lesson (lesson_id),
    INDEX idx_qb_type (question_type)
) ENGINE=InnoDB;

-- 4.2 question_options: Dap an cho cau hoi (trac nghiem / dung-sai)
CREATE TABLE question_options (
    id            INT    AUTO_INCREMENT PRIMARY KEY,
    question_id   INT    NOT NULL,
    option_text   TEXT   NOT NULL,
    is_correct    BOOLEAN NOT NULL DEFAULT FALSE,
    order_index   INT    NOT NULL DEFAULT 0,
    FOREIGN KEY (question_id) REFERENCES question_bank(id) ON DELETE CASCADE,
    INDEX idx_qo_question (question_id)
) ENGINE=InnoDB;

-- 4.3 fill_blank_answers: Dap an cho cau dien khuyet
CREATE TABLE fill_blank_answers (
    id             INT          AUTO_INCREMENT PRIMARY KEY,
    question_id    INT          NOT NULL,
    correct_answer VARCHAR(255) NOT NULL COMMENT 'Dap an dung cho cho trong',
    position       INT          NOT NULL DEFAULT 1 COMMENT 'Thu tu cho trong (1, 2, 3...)',
    FOREIGN KEY (question_id) REFERENCES question_bank(id) ON DELETE CASCADE,
    INDEX idx_fba_question (question_id)
) ENGINE=InnoDB;

-- 4.4 matching_pairs: Cap ghep cho cau hoi Matching
CREATE TABLE matching_pairs (
    id          INT  AUTO_INCREMENT PRIMARY KEY,
    question_id INT  NOT NULL,
    left_text   TEXT NOT NULL COMMENT 'Ve trai (can ghep)',
    right_text  TEXT NOT NULL COMMENT 'Ve phai (dap an)',
    FOREIGN KEY (question_id) REFERENCES question_bank(id) ON DELETE CASCADE,
    INDEX idx_mp_question (question_id)
) ENGINE=InnoDB;

-- 4.5 exams: Bai kiem tra / de thi
CREATE TABLE exams (
    id          INT                                    AUTO_INCREMENT PRIMARY KEY,
    title       VARCHAR(200)                           NOT NULL,
    subject_id  INT                                    NOT NULL,
    created_by  INT                                    NOT NULL,
    time_limit  INT                                    DEFAULT NULL COMMENT 'Thoi gian lam bai (phut)',
    max_score   DECIMAL(5,2)                           NOT NULL DEFAULT 10.00,
    type        ENUM('quiz', 'midterm', 'final', 'practice') NOT NULL DEFAULT 'quiz',
    is_public   BOOLEAN                                NOT NULL DEFAULT FALSE COMMENT 'Co trong kho de chung?',
    pass_count  INT                                    NOT NULL DEFAULT 0 COMMENT 'So luot lam',
    created_at  DATETIME                               NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (subject_id)  REFERENCES subjects(id)  ON DELETE CASCADE,
    FOREIGN KEY (created_by)  REFERENCES users(id)     ON DELETE CASCADE,
    INDEX idx_exams_subject (subject_id),
    INDEX idx_exams_type (type)
) ENGINE=InnoDB;

-- 4.6 exam_questions: Cau hoi trong de thi
CREATE TABLE exam_questions (
    id          INT            AUTO_INCREMENT PRIMARY KEY,
    exam_id     INT            NOT NULL,
    question_id INT            NOT NULL,
    order_index INT            NOT NULL DEFAULT 0,
    score       DECIMAL(5,2)  NOT NULL DEFAULT 1.00,
    FOREIGN KEY (exam_id)     REFERENCES exams(id)         ON DELETE CASCADE,
    FOREIGN KEY (question_id) REFERENCES question_bank(id) ON DELETE CASCADE,
    INDEX idx_eq_exam (exam_id)
) ENGINE=InnoDB;


-- ===============================================================
-- NHOM 5: GIAO BAI & CHAM DIEM (4 bang)
-- ===============================================================

-- 5.1 assignments: Bai tap giao vien giao cho lop
CREATE TABLE assignments (
    id            INT                                    AUTO_INCREMENT PRIMARY KEY,
    class_id      INT                                    NOT NULL,
    exam_id       INT                                    DEFAULT NULL,
    title         VARCHAR(200)                           NOT NULL,
    assigned_by   INT                                    NOT NULL,
    due_date      DATETIME                               DEFAULT NULL,
    status        ENUM('draft', 'published', 'closed')   NOT NULL DEFAULT 'draft',
    created_at    DATETIME                               NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (class_id)    REFERENCES classes(id)     ON DELETE CASCADE,
    FOREIGN KEY (exam_id)     REFERENCES exams(id)       ON DELETE SET NULL,
    FOREIGN KEY (assigned_by) REFERENCES users(id)       ON DELETE CASCADE,
    INDEX idx_assign_class (class_id)
) ENGINE=InnoDB;

-- 5.2 student_assignments: Bai nop cua tung hoc sinh
CREATE TABLE student_assignments (
    id              INT                                AUTO_INCREMENT PRIMARY KEY,
    assignment_id   INT                                NOT NULL,
    student_id      INT                                NOT NULL,
    submitted_at    DATETIME                           DEFAULT NULL,
    score           DECIMAL(5,2)                       DEFAULT NULL,
    status          ENUM('pending', 'submitted', 'graded', 'late') NOT NULL DEFAULT 'pending',
    graded_by       INT                                DEFAULT NULL,
    graded_at       DATETIME                           DEFAULT NULL,
    FOREIGN KEY (assignment_id) REFERENCES assignments(id) ON DELETE CASCADE,
    FOREIGN KEY (student_id)    REFERENCES users(id)       ON DELETE CASCADE,
    FOREIGN KEY (graded_by)     REFERENCES users(id)       ON DELETE SET NULL,
    UNIQUE KEY uq_sa_assign_student (assignment_id, student_id)
) ENGINE=InnoDB;

-- 5.3 student_answers: Chi tiet cau tra loi cua hoc sinh
CREATE TABLE student_answers (
    id                      INT          AUTO_INCREMENT PRIMARY KEY,
    student_assignment_id   INT          NOT NULL,
    question_id             INT          NOT NULL,
    answer_text             TEXT         DEFAULT NULL COMMENT 'Cau tra loi dang text',
    selected_option_id      INT          DEFAULT NULL COMMENT 'ID option da chon',
    fill_blank_answers      TEXT         DEFAULT NULL COMMENT 'Cau tra loi dien khuyet (JSON)',
    is_correct              BOOLEAN      DEFAULT NULL,
    score_earned            DECIMAL(5,2) DEFAULT NULL,
    FOREIGN KEY (student_assignment_id) REFERENCES student_assignments(id) ON DELETE CASCADE,
    FOREIGN KEY (question_id)           REFERENCES question_bank(id)       ON DELETE CASCADE,
    FOREIGN KEY (selected_option_id)    REFERENCES question_options(id)    ON DELETE SET NULL,
    INDEX idx_sa_assign (student_assignment_id)
) ENGINE=InnoDB;

-- 5.4 grades: Bang diem tong hop (cho bang diem giao vien)
CREATE TABLE grades (
    id              INT            AUTO_INCREMENT PRIMARY KEY,
    student_id      INT            NOT NULL,
    class_id        INT            NOT NULL,
    subject_id      INT            NOT NULL,
    assignment_id   INT            DEFAULT NULL,
    exam_id         INT            DEFAULT NULL,
    score           DECIMAL(5,2)   NOT NULL,
    max_score       DECIMAL(5,2)   NOT NULL DEFAULT 10.00,
    graded_at       DATETIME       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (student_id)  REFERENCES users(id)     ON DELETE CASCADE,
    FOREIGN KEY (class_id)    REFERENCES classes(id)   ON DELETE CASCADE,
    FOREIGN KEY (subject_id)  REFERENCES subjects(id)  ON DELETE CASCADE,
    FOREIGN KEY (assignment_id) REFERENCES assignments(id) ON DELETE SET NULL,
    FOREIGN KEY (exam_id)     REFERENCES exams(id)     ON DELETE SET NULL,
    INDEX idx_grades_student (student_id),
    INDEX idx_grades_class (class_id)
) ENGINE=InnoDB;


-- ===============================================================
-- NHOM 6: DIEN DAN (4 bang)
-- ===============================================================

-- 6.1 forum_topics: Chu de / tag mon hoc
CREATE TABLE forum_topics (
    id          INT          AUTO_INCREMENT PRIMARY KEY,
    name        VARCHAR(100) NOT NULL,
    slug        VARCHAR(50)  NOT NULL UNIQUE,
    description TEXT         DEFAULT NULL
) ENGINE=InnoDB;

-- 6.2 forum_posts: Bai viet dien dan
CREATE TABLE forum_posts (
    id            INT                                    AUTO_INCREMENT PRIMARY KEY,
    user_id       INT                                    NOT NULL,
    title         VARCHAR(200)                           NOT NULL,
    content       TEXT                                   NOT NULL,
    topic_id      INT                                    DEFAULT NULL COMMENT 'Mon hoc',
    status        ENUM('pending', 'approved', 'flagged', 'deleted') NOT NULL DEFAULT 'approved',
    is_resolved   BOOLEAN                                NOT NULL DEFAULT FALSE,
    view_count    INT                                    NOT NULL DEFAULT 0,
    created_at    DATETIME                               NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at    DATETIME                               NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id)  REFERENCES users(id)         ON DELETE CASCADE,
    FOREIGN KEY (topic_id) REFERENCES forum_topics(id)  ON DELETE SET NULL,
    INDEX idx_fp_user (user_id),
    INDEX idx_fp_topic (topic_id),
    INDEX idx_fp_status (status)
) ENGINE=InnoDB;

-- 6.3 forum_comments: Cau tra loi / binh luan
CREATE TABLE forum_comments (
    id            INT      AUTO_INCREMENT PRIMARY KEY,
    post_id       INT      NOT NULL,
    user_id       INT      NOT NULL,
    content       TEXT     NOT NULL,
    is_best_answer BOOLEAN NOT NULL DEFAULT FALSE,
    created_at    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (post_id) REFERENCES forum_posts(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(id)       ON DELETE CASCADE,
    INDEX idx_fc_post (post_id)
) ENGINE=InnoDB;

-- 6.4 forum_votes: Vote bai viet (upvote / downvote)
CREATE TABLE forum_votes (
    id         INT                      AUTO_INCREMENT PRIMARY KEY,
    post_id    INT                      NOT NULL,
    user_id    INT                      NOT NULL,
    vote_type  ENUM('up', 'down')       NOT NULL,
    created_at DATETIME                 NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (post_id) REFERENCES forum_posts(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(id)       ON DELETE CASCADE,
    UNIQUE KEY uq_fv_post_user (post_id, user_id)
) ENGINE=InnoDB;


-- ===============================================================
-- NHOM 7: GAMIFICATION (6 bang)
-- ===============================================================

-- 7.1 user_xp: Diem kinh nghiem
CREATE TABLE user_xp (
    id            INT          AUTO_INCREMENT PRIMARY KEY,
    user_id       INT          NOT NULL UNIQUE,
    total_xp      INT          NOT NULL DEFAULT 0,
    current_rank  VARCHAR(50)  DEFAULT NULL COMMENT 'VD: Dong, Bac, Vang',
    updated_at    DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- 7.2 xp_transactions: Lich su +- XP
CREATE TABLE xp_transactions (
    id            INT                                                AUTO_INCREMENT PRIMARY KEY,
    user_id       INT                                                NOT NULL,
    amount        INT                                                NOT NULL COMMENT 'So XP (+/-)',
    source        ENUM('quiz', 'assignment', 'streak', 'forum', 'achievement', 'admin') NOT NULL,
    reference_id  INT                                                DEFAULT NULL COMMENT 'ID bang lien quan',
    created_at    DATETIME                                           NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_xp_user (user_id)
) ENGINE=InnoDB;

-- 7.3 user_streaks: Chuoi ngay hoc
CREATE TABLE user_streaks (
    id              INT      AUTO_INCREMENT PRIMARY KEY,
    user_id         INT      NOT NULL UNIQUE,
    current_streak  INT      NOT NULL DEFAULT 0,
    longest_streak  INT      NOT NULL DEFAULT 0,
    last_active_date DATE    DEFAULT NULL,
    updated_at      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- 7.4 daily_attendance: Diem danh hang ngay
CREATE TABLE daily_attendance (
    id              INT      AUTO_INCREMENT PRIMARY KEY,
    user_id         INT      NOT NULL,
    attendance_date DATE     NOT NULL,
    xp_earned       INT      NOT NULL DEFAULT 0,
    created_at      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    UNIQUE KEY uq_da_user_date (user_id, attendance_date)
) ENGINE=InnoDB;

-- 7.5 achievements: Danh sach huy hieu / thanh tich
CREATE TABLE achievements (
    id          INT          AUTO_INCREMENT PRIMARY KEY,
    name        VARCHAR(100) NOT NULL,
    description TEXT         DEFAULT NULL,
    icon_url    VARCHAR(255) DEFAULT NULL,
    xp_reward   INT          NOT NULL DEFAULT 0
) ENGINE=InnoDB;

-- 7.6 user_achievements: Huy hieu nguoi dung da mo
CREATE TABLE user_achievements (
    id              INT      AUTO_INCREMENT PRIMARY KEY,
    user_id         INT      NOT NULL,
    achievement_id  INT      NOT NULL,
    unlocked_at     DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id)        REFERENCES users(id)         ON DELETE CASCADE,
    FOREIGN KEY (achievement_id) REFERENCES achievements(id)  ON DELETE CASCADE,
    UNIQUE KEY uq_ua_user_ach (user_id, achievement_id)
) ENGINE=InnoDB;


-- ===============================================================
-- NHOM 8: PHU HUYNH (1 bang)
-- ===============================================================

-- 8.1 parent_student_links: Lien ket phu huynh - hoc sinh
CREATE TABLE parent_student_links (
    id            INT                                    AUTO_INCREMENT PRIMARY KEY,
    parent_id     INT                                    DEFAULT NULL,
    student_id    INT                                    NOT NULL,
    link_code     VARCHAR(20)                            NOT NULL UNIQUE COMMENT 'Ma lien ket',
    linked_at     DATETIME                               NOT NULL DEFAULT CURRENT_TIMESTAMP,
    status        ENUM('pending', 'active', 'removed')   NOT NULL DEFAULT 'pending',
    FOREIGN KEY (parent_id)  REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (student_id) REFERENCES users(id) ON DELETE CASCADE,
    UNIQUE KEY uq_psl_parent_student (parent_id, student_id),
    INDEX idx_psl_parent (parent_id),
    INDEX idx_psl_student (student_id)
) ENGINE=InnoDB;


-- ===============================================================
-- NHOM 9: QUAN TRI & HE THONG (4 bang)
-- ===============================================================

-- 9.1 notifications: Thong bao he thong (Admin tao)
CREATE TABLE notifications (
    id            INT                                        AUTO_INCREMENT PRIMARY KEY,
    title         VARCHAR(180)                               NOT NULL,
    body          TEXT                                       DEFAULT NULL,
    target_role   ENUM('all', 'student', 'teacher', 'parent') NOT NULL DEFAULT 'all',
    created_by    INT                                        NOT NULL,
    created_at    DATETIME                                   NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at    DATETIME                                   NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (created_by) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_notif_role (target_role)
) ENGINE=InnoDB;

-- 9.2 notification_reads: Trang thai da doc
CREATE TABLE notification_reads (
    id              INT      AUTO_INCREMENT PRIMARY KEY,
    notification_id INT      NOT NULL,
    user_id         INT      NOT NULL,
    read_at         DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (notification_id) REFERENCES notifications(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id)         REFERENCES users(id)         ON DELETE CASCADE,
    UNIQUE KEY uq_nr_notif_user (notification_id, user_id)
) ENGINE=InnoDB;

-- 9.3 news: Tin tuc
CREATE TABLE news (
    id            INT                                    AUTO_INCREMENT PRIMARY KEY,
    title         VARCHAR(200)                           NOT NULL,
    content       TEXT                                   DEFAULT NULL,
    thumbnail_url VARCHAR(500)                           DEFAULT NULL,
    category      VARCHAR(50)                            DEFAULT NULL COMMENT 'VD: Ban cap nhat, Su kien',
    is_pinned     BOOLEAN                                NOT NULL DEFAULT FALSE,
    status        ENUM('draft', 'published')             NOT NULL DEFAULT 'draft',
    view_count    INT                                    NOT NULL DEFAULT 0,
    created_by    INT                                    NOT NULL,
    published_at  DATETIME                               DEFAULT NULL,
    created_at    DATETIME                               NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (created_by) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_news_status (status),
    INDEX idx_news_pinned (is_pinned)
) ENGINE=InnoDB;

-- 9.4 faq: Cau hoi thuong gap
CREATE TABLE faq (
    id          INT          AUTO_INCREMENT PRIMARY KEY,
    category    VARCHAR(100) DEFAULT NULL COMMENT 'VD: Hoc tap, Tai khoan, Ky thuat',
    question    TEXT         NOT NULL,
    answer      TEXT         NOT NULL,
    order_index INT          NOT NULL DEFAULT 0
) ENGINE=InnoDB;


-- ===============================================================
-- NHOM 10: AI CHAT (1 bang)
-- ===============================================================

-- 10.1 ai_chat_history: Lich su tro chuyen voi Doly AI
CREATE TABLE ai_chat_history (
    id          INT          AUTO_INCREMENT PRIMARY KEY,
    user_id     INT          NOT NULL,
    role        ENUM('user', 'assistant') NOT NULL,
    message     TEXT         NOT NULL,
    context     JSON         DEFAULT NULL COMMENT 'Bai hoc hien tai (JSON)',
    created_at  DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_ach_user (user_id)
) ENGINE=InnoDB;


-- ===============================================================
-- DU LIEU MAC DINH (Seed Data)
-- ===============================================================

-- Mon hoc
INSERT INTO subjects (name, slug) VALUES
('Vat Ly', 'vat-ly'),
('Hoa Hoc', 'hoa-hoc'),
('Sinh Hoc', 'sinh-hoc');

-- Chu de dien dan
INSERT INTO forum_topics (name, slug, description) VALUES
('Toan Hoc', 'toan-hoc', 'Cac cau hoi ve Toan hoc'),
('Vat Ly', 'vat-ly', 'Cac cau hoi ve Vat ly'),
('Hoa Hoc', 'hoa-hoc', 'Cac cau hoi ve Hoa hoc'),
('Sinh Hoc', 'sinh-hoc', 'Cac cau hoi ve Sinh hoc');

-- FAQ mac dinh
INSERT INTO faq (category, question, answer, order_index) VALUES
('Hoc Tap & Trai Nghiem', 'DOLY AI Tutor co giai bai tap ho hoc sinh khong?', 'Khong. DOLY AI duoc thiet lap theo phuong phap Socratic, chi dat cau hoi goi mo de hoc sinh tu suy luan.', 1),
('Hoc Tap & Trai Nghiem', 'Lam sao de xem duoc Ban do lo hong kien thuc?', 'Sau khi hoan thanh bai Test, vao Khong Gian Hoc Tap > Bao cao ca nhan > Ban do nang luc.', 2),
('Tai Khoan & Phu Huynh', 'Phu huynh lam sao de theo doi tien do cua con?', 'Tao tai khoan Cong Phu Huynh va nhap ma lien ket cua hoc sinh de nhan thong bao tu dong.', 3),
('Ky Thuat & Khac Phuc Su Co', 'Phong Lab 3D co chay duoc tren dien thoai khong?', 'Co. DOLY LMS toi uu cho moi thiet bi, Lab 3D chay bang WebGL tren trinh duyet mobile.', 4);

-- Thanh tich / Huy hieu mac dinh
INSERT INTO achievements (name, description, icon_url, xp_reward) VALUES
('Tan Thu', 'Hoan thanh bai hoc dau tien', NULL, 50),
('Cham Chi', 'Duy tri streak 7 ngay', NULL, 100),
('Hiep Si', 'Tra loi 50 cau hoi tren Dien dan', NULL, 200),
('Nha Vo Dich', 'Dat TOP 1 Bang xep hang tuan', NULL, 500);
