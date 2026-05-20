-- phpMyAdmin SQL Dump

CREATE DATABASE IF NOT EXISTS doly_lms
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE doly_lms;

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `achievements`
--

CREATE TABLE `achievements` (
  `id` int(11) NOT NULL,
  `name` varchar(100) NOT NULL,
  `description` text DEFAULT NULL,
  `icon_url` varchar(255) DEFAULT NULL,
  `xp_reward` int(11) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Đang đổ dữ liệu cho bảng `achievements`
--

INSERT INTO `achievements` (`id`, `name`, `description`, `icon_url`, `xp_reward`) VALUES
(1, 'Tan Thu', 'Hoan thanh bai hoc dau tien', NULL, 50),
(2, 'Cham Chi', 'Duy tri streak 7 ngay', NULL, 100),
(3, 'Hiep Si', 'Tra loi 50 cau hoi tren Dien dan', NULL, 200),
(4, 'Nha Vo Dich', 'Dat TOP 1 Bang xep hang tuan', NULL, 500);

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `ai_chat_history`
--

CREATE TABLE `ai_chat_history` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `role` enum('user','assistant') NOT NULL,
  `message` text NOT NULL,
  `context` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'Bai hoc hien tai (JSON)' CHECK (json_valid(`context`)),
  `created_at` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Đang đổ dữ liệu cho bảng `ai_chat_history`
--

INSERT INTO `ai_chat_history` (`id`, `user_id`, `role`, `message`, `context`, `created_at`) VALUES
(1, 1, 'user', 'rterter', '{\"lesson_id\":\"bai31\"}', '2026-05-16 19:43:36'),
(2, 1, 'assistant', 'Nguyen Van A a, do la mot cau hoi rat hay!\n\nDOLY AI muon giup ban tu tim ra cau tra loi. Ban hay cho minh hoi:\n• Ban da hoc ve chu de nay truoc do chua?\n• Ban nghi van de nay lien quan den kien thuc nao?\n• Ban co the thu phan tich van de tu goc nhin cua minh duoc khong?', '{\"lesson_id\":\"bai31\"}', '2026-05-16 19:43:36'),
(3, 1, 'user', 'fgdfg', '{\"lesson_id\":\"bai31\"}', '2026-05-16 19:43:39'),
(4, 1, 'assistant', 'Nguyen Van A a, do la mot cau hoi rat hay!\n\nDOLY AI muon giup ban tu tim ra cau tra loi. Ban hay cho minh hoi:\n• Ban da hoc ve chu de nay truoc do chua?\n• Ban nghi van de nay lien quan den kien thuc nao?\n• Ban co the thu phan tich van de tu goc nhin cua minh duoc khong?', '{\"lesson_id\":\"bai31\"}', '2026-05-16 19:43:39'),
(5, 1, 'user', 'fgdfgd', '{\"lesson_id\":\"bai31\"}', '2026-05-16 19:43:40'),
(6, 1, 'assistant', 'Nguyen Van A a, do la mot cau hoi rat hay!\n\nDOLY AI muon giup ban tu tim ra cau tra loi. Ban hay cho minh hoi:\n• Ban da hoc ve chu de nay truoc do chua?\n• Ban nghi van de nay lien quan den kien thuc nao?\n• Ban co the thu phan tich van de tu goc nhin cua minh duoc khong?', '{\"lesson_id\":\"bai31\"}', '2026-05-16 19:43:40'),
(7, 1, 'user', 'hi', NULL, '2026-05-16 19:56:10'),
(8, 1, 'assistant', 'Chao Nguyen Van A! Day la DOLY AI. Ban can giup do ve bai hoc nao hom nay?', NULL, '2026-05-16 19:56:10'),
(9, 1, 'user', 'alo', NULL, '2026-05-16 19:56:13'),
(10, 1, 'assistant', 'Nguyen Van A a, do la mot cau hoi rat hay!\n\nDOLY AI muon giup ban tu tim ra cau tra loi. Ban hay cho minh hoi:\n• Ban da hoc ve chu de nay truoc do chua?\n• Ban nghi van de nay lien quan den kien thuc nao?\n• Ban co the thu phan tich van de tu goc nhin cua minh duoc khong?', NULL, '2026-05-16 19:56:13'),
(11, 1, 'user', 'roi', NULL, '2026-05-16 19:56:20'),
(12, 1, 'assistant', 'Nguyen Van A a, do la mot cau hoi rat hay!\n\nDOLY AI muon giup ban tu tim ra cau tra loi. Ban hay cho minh hoi:\n• Ban da hoc ve chu de nay truoc do chua?\n• Ban nghi van de nay lien quan den kien thuc nao?\n• Ban co the thu phan tich van de tu goc nhin cua minh duoc khong?', NULL, '2026-05-16 19:56:20'),
(13, 1, 'user', 'rồi', NULL, '2026-05-16 19:56:25'),
(14, 1, 'assistant', 'Nguyen Van A a, do la mot cau hoi rat hay!\n\nDOLY AI muon giup ban tu tim ra cau tra loi. Ban hay cho minh hoi:\n• Ban da hoc ve chu de nay truoc do chua?\n• Ban nghi van de nay lien quan den kien thuc nao?\n• Ban co the thu phan tich van de tu goc nhin cua minh duoc khong?', NULL, '2026-05-16 19:56:25'),
(15, 1, 'user', 'mình học rồi', NULL, '2026-05-16 19:56:29'),
(16, 1, 'assistant', 'Nguyen Van A a, do la mot cau hoi rat hay!\n\nDOLY AI muon giup ban tu tim ra cau tra loi. Ban hay cho minh hoi:\n• Ban da hoc ve chu de nay truoc do chua?\n• Ban nghi van de nay lien quan den kien thuc nao?\n• Ban co the thu phan tich van de tu goc nhin cua minh duoc khong?', NULL, '2026-05-16 19:56:29');

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `assignments`
--

CREATE TABLE `assignments` (
  `id` int(11) NOT NULL,
  `class_id` int(11) NOT NULL,
  `exam_id` int(11) DEFAULT NULL,
  `title` varchar(200) NOT NULL,
  `assigned_by` int(11) NOT NULL,
  `due_date` datetime DEFAULT NULL,
  `status` enum('draft','published','closed') NOT NULL DEFAULT 'draft',
  `created_at` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `classes`
--

CREATE TABLE `classes` (
  `id` int(11) NOT NULL,
  `name` varchar(100) NOT NULL COMMENT 'VD: 8A1, 9B2',
  `subject` varchar(50) DEFAULT NULL COMMENT 'Mon hoc chinh',
  `grade_level` varchar(20) DEFAULT NULL COMMENT 'VD: Lop 8, Lop 9',
  `teacher_id` int(11) NOT NULL COMMENT 'Giao vien chu nhiem',
  `class_code` varchar(20) NOT NULL COMMENT 'Ma moi hoc sinh',
  `status` enum('active','closed') NOT NULL DEFAULT 'active',
  `created_at` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Đang đổ dữ liệu cho bảng `classes`
--

INSERT INTO `classes` (`id`, `name`, `subject`, `grade_level`, `teacher_id`, `class_code`, `status`, `created_at`) VALUES
(1, 'test class', 'Anh', '8', 2, 'A8X9K2', 'active', '2026-05-16 18:40:04'),
(4, 'sdfsdfsdsd', 'sdfsd', '8', 2, 'M9CBFW', 'active', '2026-05-16 20:23:03');

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `class_members`
--

CREATE TABLE `class_members` (
  `id` int(11) NOT NULL,
  `class_id` int(11) NOT NULL,
  `student_id` int(11) NOT NULL,
  `joined_at` datetime NOT NULL DEFAULT current_timestamp(),
  `status` enum('active','left') NOT NULL DEFAULT 'active'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Đang đổ dữ liệu cho bảng `class_members`
--

INSERT INTO `class_members` (`id`, `class_id`, `student_id`, `joined_at`, `status`) VALUES
(1, 1, 1, '2026-05-16 18:43:24', 'active'),
(2, 4, 1, '2026-05-16 20:23:21', 'active');

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `daily_attendance`
--

CREATE TABLE `daily_attendance` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `attendance_date` date NOT NULL,
  `xp_earned` int(11) NOT NULL DEFAULT 0,
  `created_at` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Đang đổ dữ liệu cho bảng `daily_attendance`
--

INSERT INTO `daily_attendance` (`id`, `user_id`, `attendance_date`, `xp_earned`, `created_at`) VALUES
(1, 1, '2026-05-16', 10, '2026-05-16 19:42:55');

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `documents`
--

CREATE TABLE `documents` (
  `id` int(11) NOT NULL,
  `lesson_id` int(11) DEFAULT NULL,
  `title` varchar(200) NOT NULL,
  `file_url` varchar(500) NOT NULL,
  `type` enum('pdf','mindmap','worksheet') NOT NULL DEFAULT 'pdf',
  `download_count` int(11) NOT NULL DEFAULT 0,
  `created_at` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `exams`
--

CREATE TABLE `exams` (
  `id` int(11) NOT NULL,
  `title` varchar(200) NOT NULL,
  `subject_id` int(11) NOT NULL,
  `created_by` int(11) NOT NULL,
  `time_limit` int(11) DEFAULT NULL COMMENT 'Thoi gian lam bai (phut)',
  `max_score` decimal(5,2) NOT NULL DEFAULT 10.00,
  `type` enum('quiz','midterm','final','practice') NOT NULL DEFAULT 'quiz',
  `is_public` tinyint(1) NOT NULL DEFAULT 0 COMMENT 'Co trong kho de chung?',
  `pass_count` int(11) NOT NULL DEFAULT 0 COMMENT 'So luot lam',
  `created_at` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `exam_questions`
--

CREATE TABLE `exam_questions` (
  `id` int(11) NOT NULL,
  `exam_id` int(11) NOT NULL,
  `question_id` int(11) NOT NULL,
  `order_index` int(11) NOT NULL DEFAULT 0,
  `score` decimal(5,2) NOT NULL DEFAULT 1.00
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `faq`
--

CREATE TABLE `faq` (
  `id` int(11) NOT NULL,
  `category` varchar(100) DEFAULT NULL COMMENT 'VD: Hoc tap, Tai khoan, Ky thuat',
  `question` text NOT NULL,
  `answer` text NOT NULL,
  `order_index` int(11) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Đang đổ dữ liệu cho bảng `faq`
--

INSERT INTO `faq` (`id`, `category`, `question`, `answer`, `order_index`) VALUES
(1, 'Hoc Tap & Trai Nghiem', 'DOLY AI Tutor co giai bai tap ho hoc sinh khong?', 'Khong. DOLY AI duoc thiet lap theo phuong phap Socratic, chi dat cau hoi goi mo de hoc sinh tu suy luan.', 1),
(2, 'Hoc Tap & Trai Nghiem', 'Lam sao de xem duoc Ban do lo hong kien thuc?', 'Sau khi hoan thanh bai Test, vao Khong Gian Hoc Tap > Bao cao ca nhan > Ban do nang luc.', 2),
(3, 'Tai Khoan & Phu Huynh', 'Phu huynh lam sao de theo doi tien do cua con?', 'Tao tai khoan Cong Phu Huynh va nhap ma lien ket cua hoc sinh de nhan thong bao tu dong.', 3),
(4, 'Ky Thuat & Khac Phuc Su Co', 'Phong Lab 3D co chay duoc tren dien thoai khong?', 'Co. DOLY LMS toi uu cho moi thiet bi, Lab 3D chay bang WebGL tren trinh duyet mobile.', 4);

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `fill_blank_answers`
--

CREATE TABLE `fill_blank_answers` (
  `id` int(11) NOT NULL,
  `question_id` int(11) NOT NULL,
  `correct_answer` varchar(255) NOT NULL COMMENT 'Dap an dung cho cho trong',
  `position` int(11) NOT NULL DEFAULT 1 COMMENT 'Thu tu cho trong (1, 2, 3...)'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `forum_comments`
--

CREATE TABLE `forum_comments` (
  `id` int(11) NOT NULL,
  `post_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `content` text NOT NULL,
  `is_best_answer` tinyint(1) NOT NULL DEFAULT 0,
  `created_at` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `forum_posts`
--

CREATE TABLE `forum_posts` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `title` varchar(200) NOT NULL,
  `content` text NOT NULL,
  `topic_id` int(11) DEFAULT NULL COMMENT 'Mon hoc',
  `status` enum('pending','approved','flagged','deleted') NOT NULL DEFAULT 'approved',
  `is_resolved` tinyint(1) NOT NULL DEFAULT 0,
  `view_count` int(11) NOT NULL DEFAULT 0,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Đang đổ dữ liệu cho bảng `forum_posts`
--

INSERT INTO `forum_posts` (`id`, `user_id`, `title`, `content`, `topic_id`, `status`, `is_resolved`, `view_count`, `created_at`, `updated_at`) VALUES
(1, 1, 'xcv', 'xcvxcv', 1, 'approved', 0, 0, '2026-05-16 19:49:56', '2026-05-16 19:49:56'),
(2, 1, 'sdfsdf', 'sdfsdf', 3, 'approved', 0, 0, '2026-05-16 20:00:57', '2026-05-16 20:00:57');

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `forum_topics`
--

CREATE TABLE `forum_topics` (
  `id` int(11) NOT NULL,
  `name` varchar(100) NOT NULL,
  `slug` varchar(50) NOT NULL,
  `description` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Đang đổ dữ liệu cho bảng `forum_topics`
--

INSERT INTO `forum_topics` (`id`, `name`, `slug`, `description`) VALUES
(1, 'Toan Hoc', 'toan-hoc', 'Cac cau hoi ve Toan hoc'),
(2, 'Vat Ly', 'vat-ly', 'Cac cau hoi ve Vat ly'),
(3, 'Hoa Hoc', 'hoa-hoc', 'Cac cau hoi ve Hoa hoc'),
(4, 'Sinh Hoc', 'sinh-hoc', 'Cac cau hoi ve Sinh hoc');

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `forum_votes`
--

CREATE TABLE `forum_votes` (
  `id` int(11) NOT NULL,
  `post_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `vote_type` enum('up','down') NOT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `grades`
--

CREATE TABLE `grades` (
  `id` int(11) NOT NULL,
  `student_id` int(11) NOT NULL,
  `class_id` int(11) NOT NULL,
  `subject_id` int(11) NOT NULL,
  `assignment_id` int(11) DEFAULT NULL,
  `exam_id` int(11) DEFAULT NULL,
  `score` decimal(5,2) NOT NULL,
  `max_score` decimal(5,2) NOT NULL DEFAULT 10.00,
  `graded_at` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `lab_models`
--

CREATE TABLE `lab_models` (
  `id` int(11) NOT NULL,
  `title` varchar(200) NOT NULL,
  `description` text DEFAULT NULL,
  `thumbnail_url` varchar(500) DEFAULT NULL,
  `model_url` varchar(500) DEFAULT NULL COMMENT 'Duong dan file .glb',
  `lesson_id` int(11) DEFAULT NULL,
  `subject_id` int(11) DEFAULT NULL,
  `is_premium` tinyint(1) NOT NULL DEFAULT 0,
  `view_count` int(11) NOT NULL DEFAULT 0,
  `created_at` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `lessons`
--

CREATE TABLE `lessons` (
  `id` int(11) NOT NULL,
  `subject_id` int(11) NOT NULL,
  `title` varchar(200) NOT NULL,
  `content` longtext DEFAULT NULL COMMENT 'Noi dung bai giang (HTML)',
  `order_index` int(11) NOT NULL DEFAULT 0 COMMENT 'Thu tu sap xep',
  `created_at` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Đang đổ dữ liệu cho bảng `lessons`
--

INSERT INTO `lessons` (`id`, `subject_id`, `title`, `content`, `order_index`, `created_at`) VALUES
(1, 1, 'Bai 1: Dao dong dieu hoa', 'Noi dung dao dong dieu hoa', 1, '2026-05-16 18:03:07'),
(2, 2, 'Bai 1: Nguyen tu - Phan tu', 'Noi dung nguyen tu phan tu', 1, '2026-05-16 18:03:07'),
(3, 3, 'Bai 1: Te bao don vi co ban', 'Noi dung te bao', 1, '2026-05-16 18:03:07');

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `matching_pairs`
--

CREATE TABLE `matching_pairs` (
  `id` int(11) NOT NULL,
  `question_id` int(11) NOT NULL,
  `left_text` text NOT NULL COMMENT 'Ve trai (can ghep)',
  `right_text` text NOT NULL COMMENT 'Ve phai (dap an)'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `news`
--

CREATE TABLE `news` (
  `id` int(11) NOT NULL,
  `title` varchar(200) NOT NULL,
  `content` text DEFAULT NULL,
  `thumbnail_url` varchar(500) DEFAULT NULL,
  `category` varchar(50) DEFAULT NULL COMMENT 'VD: Ban cap nhat, Su kien',
  `is_pinned` tinyint(1) NOT NULL DEFAULT 0,
  `status` enum('draft','published') NOT NULL DEFAULT 'draft',
  `view_count` int(11) NOT NULL DEFAULT 0,
  `created_by` int(11) NOT NULL,
  `published_at` datetime DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `notifications`
--

CREATE TABLE `notifications` (
  `id` int(11) NOT NULL,
  `title` varchar(180) NOT NULL,
  `body` text DEFAULT NULL,
  `target_role` enum('all','student','teacher','parent') NOT NULL DEFAULT 'all',
  `created_by` int(11) NOT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `notification_reads`
--

CREATE TABLE `notification_reads` (
  `id` int(11) NOT NULL,
  `notification_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `read_at` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `parent_student_links`
--

CREATE TABLE `parent_student_links` (
  `id` int(11) NOT NULL,
  `parent_id` int(11) DEFAULT NULL,
  `student_id` int(11) NOT NULL,
  `link_code` varchar(20) NOT NULL COMMENT 'Ma lien ket',
  `linked_at` datetime NOT NULL DEFAULT current_timestamp(),
  `status` enum('pending','active','removed') NOT NULL DEFAULT 'pending'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Đang đổ dữ liệu cho bảng `parent_student_links`
--

INSERT INTO `parent_student_links` (`id`, `parent_id`, `student_id`, `link_code`, `linked_at`, `status`) VALUES
(15, 3, 1, '0C6C03', '2026-05-16 20:09:45', 'active'),
(16, NULL, 1, 'C1D721', '2026-05-16 20:14:34', 'pending');

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `question_bank`
--

CREATE TABLE `question_bank` (
  `id` int(11) NOT NULL,
  `subject_id` int(11) NOT NULL,
  `lesson_id` int(11) DEFAULT NULL,
  `question_text` text NOT NULL,
  `question_type` enum('multiple_choice','true_false','fill_blank','matching') NOT NULL,
  `difficulty` enum('easy','medium','hard') NOT NULL DEFAULT 'medium',
  `xp_reward` int(11) NOT NULL DEFAULT 10,
  `explanation` text DEFAULT NULL COMMENT 'Giai thich dap an',
  `created_by` int(11) DEFAULT NULL COMMENT 'Giao vien tao',
  `status` enum('active','inactive') NOT NULL DEFAULT 'active',
  `created_at` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Đang đổ dữ liệu cho bảng `question_bank`
--

INSERT INTO `question_bank` (`id`, `subject_id`, `lesson_id`, `question_text`, `question_type`, `difficulty`, `xp_reward`, `explanation`, `created_by`, `status`, `created_at`) VALUES
(1, 1, 1, 'Dao dong dieu hoa la gi?', 'multiple_choice', 'easy', 10, NULL, NULL, 'active', '2026-05-16 18:03:12'),
(2, 1, 1, 'Chu ky dao dong la?', 'multiple_choice', 'medium', 15, NULL, NULL, 'active', '2026-05-16 18:03:12'),
(3, 2, 2, 'Nguyen tu la gi?', 'multiple_choice', 'easy', 10, NULL, NULL, 'active', '2026-05-16 18:03:12'),
(4, 3, 3, 'Te bao don vi co ban cua co the la?', 'multiple_choice', 'easy', 10, NULL, NULL, 'active', '2026-05-16 18:03:12');

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `question_options`
--

CREATE TABLE `question_options` (
  `id` int(11) NOT NULL,
  `question_id` int(11) NOT NULL,
  `option_text` text NOT NULL,
  `is_correct` tinyint(1) NOT NULL DEFAULT 0,
  `order_index` int(11) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `student_answers`
--

CREATE TABLE `student_answers` (
  `id` int(11) NOT NULL,
  `student_assignment_id` int(11) NOT NULL,
  `question_id` int(11) NOT NULL,
  `answer_text` text DEFAULT NULL COMMENT 'Cau tra loi dang text',
  `selected_option_id` int(11) DEFAULT NULL COMMENT 'ID option da chon',
  `fill_blank_answers` text DEFAULT NULL COMMENT 'Cau tra loi dien khuyet (JSON)',
  `is_correct` tinyint(1) DEFAULT NULL,
  `score_earned` decimal(5,2) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `student_assignments`
--

CREATE TABLE `student_assignments` (
  `id` int(11) NOT NULL,
  `assignment_id` int(11) NOT NULL,
  `student_id` int(11) NOT NULL,
  `submitted_at` datetime DEFAULT NULL,
  `score` decimal(5,2) DEFAULT NULL,
  `status` enum('pending','submitted','graded','late') NOT NULL DEFAULT 'pending',
  `graded_by` int(11) DEFAULT NULL,
  `graded_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `subjects`
--

CREATE TABLE `subjects` (
  `id` int(11) NOT NULL,
  `name` varchar(100) NOT NULL,
  `slug` varchar(50) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Đang đổ dữ liệu cho bảng `subjects`
--

INSERT INTO `subjects` (`id`, `name`, `slug`) VALUES
(1, 'Vat Ly', 'vat-ly'),
(2, 'Hoa Hoc', 'hoa-hoc'),
(3, 'Sinh Hoc', 'sinh-hoc');

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `users`
--

CREATE TABLE `users` (
  `id` int(11) NOT NULL,
  `full_name` varchar(100) NOT NULL,
  `email` varchar(100) NOT NULL,
  `password_hash` varchar(255) NOT NULL,
  `role` enum('admin','student','teacher','parent') NOT NULL,
  `avatar_url` varchar(255) DEFAULT NULL,
  `status` enum('active','inactive','banned') NOT NULL DEFAULT 'active',
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `last_login` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Đang đổ dữ liệu cho bảng `users`
--

INSERT INTO `users` (`id`, `full_name`, `email`, `password_hash`, `role`, `avatar_url`, `status`, `created_at`, `updated_at`, `last_login`) VALUES
(1, 'Nguyen Van A', 'test@doly.edu.vn', '$2y$10$owDinXO7/P0fQMydFzL1TOS1jSDfjbRjClL3aH8O9gZDD9mIJB9xq', 'student', NULL, 'active', '2026-05-16 18:00:05', '2026-05-19 14:30:01', '2026-05-19 14:30:01'),
(2, 'Co Minh Anh', 'teacher@doly.edu.vn', '$2y$10$NGHGwGMkmjogZqhhqjamDu5wFRuCBjk./E5s1qcPd6UbKJJWzmXEK', 'teacher', NULL, 'active', '2026-05-16 18:11:49', '2026-05-17 13:40:55', '2026-05-17 13:40:55'),
(3, 'Phu Huynh Lan', 'parent@doly.edu.vn', '$2y$10$NGHGwGMkmjogZqhhqjamDu5wFRuCBjk./E5s1qcPd6UbKJJWzmXEK', 'parent', NULL, 'active', '2026-05-16 18:11:49', '2026-05-17 13:40:21', '2026-05-17 13:40:21'),
(4, 'Admin Doly', 'admin@doly.edu.vn', '$2y$10$NGHGwGMkmjogZqhhqjamDu5wFRuCBjk./E5s1qcPd6UbKJJWzmXEK', 'admin', NULL, 'active', '2026-05-16 18:11:49', '2026-05-17 13:39:38', '2026-05-17 13:39:38'),
(5, 'Ngọt Phạm', 'phamthingot484@gmail.com', '$2y$10$q6j8rhmb7PdYA7wso5qQ3OT4RNh4nZlOXUcd2VdbC6bb.R9R028jK', 'student', NULL, 'active', '2026-05-19 14:29:43', '2026-05-19 14:30:47', '2026-05-19 14:30:47');

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `user_achievements`
--

CREATE TABLE `user_achievements` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `achievement_id` int(11) NOT NULL,
  `unlocked_at` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `user_sessions`
--

CREATE TABLE `user_sessions` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `auth_token` varchar(255) NOT NULL,
  `expires_at` datetime NOT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Đang đổ dữ liệu cho bảng `user_sessions`
--

INSERT INTO `user_sessions` (`id`, `user_id`, `auth_token`, `expires_at`, `created_at`) VALUES
(1, 1, '4d8122f864ba4f49d916bfc76316cd59fb700f7c5ff1b4fcf03ea1e6ff088bd3b5fa36ab27a07b7c22e5f98373ffa15eb0627e7fc834bcd830fda91bade0eca4', '2026-05-23 13:01:50', '2026-05-16 18:01:50'),
(2, 1, '3e8ceb29fc548f9ce877ba7288f0a509589ee7be49f4cc9ef4e34db3183cb11ce2ff37c3415a5c8cb91dbca58e583ecfd410822ee37e1c28b1b1c8e84eaaf3e3', '2026-05-23 13:02:15', '2026-05-16 18:02:15'),
(3, 1, '0ae879bcdc8d382acd4131ab7435405ffbe649ffc07c733f78f98b0642e45894e107a6a18d64e6f07a223635e654fef7c1025847b5f146622e3578ebb2ef37a8', '2026-05-23 13:02:27', '2026-05-16 18:02:27'),
(4, 1, '95850d4809bac2bd2dee6dfcbc49764f20dc2a74a756e8550b3250598a31597f14bd6de2ea60dcde658824163b84609f466b8a5355643eed88477ff395abe1e4', '2026-05-23 13:03:22', '2026-05-16 18:03:22'),
(5, 1, '497cd8e7bb7f3417a4e77d94928cbbbdd17c8e2a49aa8ce3266cfc062e1c097a2866a2ff8db050cf917fa2d5fab0ab86605d6234b9a89620e60168e478667dfd', '2026-05-23 13:04:32', '2026-05-16 18:04:32'),
(6, 1, '401e0aa8c5b554f711efefc6c433615f90181d9ddaaf956c47b47abaaceeee390c67a8c3a2ff1265e520612c719adbde3620a38e05a61100f1c2af58c4f2c963', '2026-05-23 13:04:49', '2026-05-16 18:04:49'),
(7, 1, '2c6f19ac3bd66475ce86022c1e818938a7aed097dcc762286229c312316844ec3b593494afd79c6244fe67f10b7d2e7c77d44d3da5f3487070c8b510772ab97e', '2026-05-23 13:12:58', '2026-05-16 18:12:58'),
(8, 2, 'c231a76f4c52337df9569508697b38279e7d393a30e2fa96b2463accdaa950e879dcd103838291e341425c73bd3941d9850e189f5ea102fe57fdf0b0705e8dee', '2026-05-23 13:12:58', '2026-05-16 18:12:58'),
(9, 3, '0be98c8eaf9b6850609e574f6af802dbb35f170d44a3e303a7f418ec5de5f469c0b1cb480faa15a507ed15a9cf2a27ede69ad7bda1c7c49e20e302c0e45904f7', '2026-05-23 13:12:58', '2026-05-16 18:12:58'),
(10, 4, 'fa9272b0a5e13774fb10f57df4006fe2f3c399f7d1ae674eb17f262207aaf5c7c0dece667fb1f14e2eac3cd47336c72505214ab7490bb0b04e5f436e3b6dcb38', '2026-05-23 13:12:58', '2026-05-16 18:12:58'),
(11, 1, 'f1ab7f47388b3323fd5638dd6258c16e1c9ab5d47e05815554b4084c1fea975e50abf6f391feada7d08c19d5a3e6e8325b504c29769ff2cf8c6fef0bb7576125', '2026-05-23 13:23:33', '2026-05-16 18:23:33'),
(12, 1, '5a11f6688f19603bc5fb7abee8c3c80d19e671ae71b5e91b82960685bd3d912cac194dd720ac2f0afc00f7d83289df449f880c1e7320196a2b0f732b62e1e41f', '2026-05-23 13:23:52', '2026-05-16 18:23:52'),
(13, 1, 'f787adf1a4908ab5efcad423b57fb71b7be71cad2c21880f4c0b499dc81b448b52c53a20154e764f56c2d45e2443f12873f5b7d58c9a65ca9549d65d33a509f6', '2026-05-23 13:32:02', '2026-05-16 18:32:02'),
(14, 2, '669257e0cef5aa9dc3c5bac61ee4983835b4cb057f4b7c922ae0e7bc432e69c5e92dd17247ce59a850daf2ad60def113f44c7354cb58ab40c5280c63a61d3137', '2026-05-23 13:32:33', '2026-05-16 18:32:33'),
(15, 1, 'a3185e2c57d808ce3ebf19a5c1fd67c3951eb5f6f684da6b88313e3eeba1dcb2bb94c427c14c0880c627a0148f3bbd39d52168d8fdbbedf26fc5e5e0b241efcb', '2026-05-23 13:39:13', '2026-05-16 18:39:13'),
(16, 1, '58892cc40bd0d575545283a81464307e432811b50828e0e378dbdd2be345f640b57314bf149a339b94b2f71fc635598bd6e132aa85f53d4d224799c46e793ef3', '2026-05-23 13:39:15', '2026-05-16 18:39:15'),
(17, 2, '8a42704de944a0d181b6bcf80ac504ded8184bc7e6120a20211b9b54bb27c1dd15e3c33a28e48716701afd821b7de07f1316710fb00086bf85a1eada9c4fb80f', '2026-05-23 13:39:29', '2026-05-16 18:39:29'),
(18, 1, '8ad7b9f2d2a770ad7d4b6c0e8caf74eb7417af5f0fde9a205a9cb07b12357385941b62a749e3dec225fc60ebf6f0ccd1f155463254a85f3f96cd67713fdc0ae7', '2026-05-23 13:40:23', '2026-05-16 18:40:23'),
(19, 1, '052fedad524151bc54cfdeb354874023e935fd24eb57b5cb53b554382a3e4666626871c0fa61b6aa6c9b87f596a86b101de03f61d0c285ed048ae35121e638cb', '2026-05-23 13:40:37', '2026-05-16 18:40:37'),
(20, 1, '17801fb2c2fa558d9340cffbc665d179f986d4592d6103f3cfb5a4dc35ba49df9c5e2185e6c3fc3a09e672dc61b7971d602903a913ae115a652d52d8adbf3eb8', '2026-05-23 14:07:32', '2026-05-16 19:07:32'),
(21, 1, '0940dd8ae2d06e24bcbc22b5d4a761fc571221f2a6a6ff73f236108aa0cfe26a8ed4c61a733b63c30ccaf995b02a021ddabe37851b5686bf6d56305279098818', '2026-05-23 14:09:33', '2026-05-16 19:09:33'),
(22, 1, '968a88c6370445995ad4341b636584a00831490d575ef1baaf9d4c94e73236fb9c84288de17a6827cda28384d938043e32ff9594ee848ccf10973350b2e30b68', '2026-05-23 14:13:25', '2026-05-16 19:13:25'),
(24, 1, 'b313ecefb3eac6a05e24ad2ae357560212753d3c6ce06c4769701fbe0436470e14d1add83141137d5f6fe51192a61410b891661d045a0539161579d04ae99e51', '2026-05-23 15:04:12', '2026-05-16 20:04:12'),
(26, 1, '868c6c66b88fb07f6427658fd886bb0a297a6884c2b4d783b697aaf1c1a1938ef0bb4468093914331cdfbf561c6731f8fea04acfe45c2d80e289ae113ff98390', '2026-05-23 15:09:51', '2026-05-16 20:09:51'),
(27, 3, '4e2b3ca5f4de97e2619598a28b597fa350d105525a165c726a17505ab62e464be4f26f04cc8b2e5ff4c40852dadcce38977f86df5abeeccb06ef0995b67eefa6', '2026-05-23 15:10:04', '2026-05-16 20:10:04'),
(28, 1, 'cb22c5146139087b4505a7cd06a001e1b54422ee574eb1d55f52b5501b58139088bd91200cef6ba865af1f444f8c99f311a3c2c8f1649b6601cfed2679bb8bc1', '2026-05-23 15:13:51', '2026-05-16 20:13:51'),
(30, 1, 'b1c8e0a01a4bb7c2f7f2f7ccbb2ece1a90cf51224ef1a8280cce7174f0002dab937b81fe4bcae191382fb6b632cda7d99604603f944a7b9cdddbca8893b4789f', '2026-05-23 15:16:53', '2026-05-16 20:16:53'),
(32, 1, '02db21fa424fff910cbd6f3d53dff1a6bd3e0658c950f33aba39376ed421bcb3381a5c2bf78ac9f61e946162693277d8c46bf4fd9a589350491dfa064bb96819', '2026-05-23 15:18:33', '2026-05-16 20:18:33'),
(34, 1, '8d6796bd2b2476c86699210ec99ac0ef746dbc61af2359f25be428f4af812a0e3d06a29d79471afcb8af740407820d6118865ee00d30f6a9963cae6a7f616ab6', '2026-05-23 15:22:23', '2026-05-16 20:22:23'),
(36, 1, '501fdc512a96f58dc0737082cc2070c38bec33e02a72170c45a26b48d9ba4621409b00dda5b5c76a6cfc5e8878d0770bf3fb6bc4acb7cde9866f7df818cd220b', '2026-05-23 15:23:09', '2026-05-16 20:23:09'),
(37, 1, 'fc3daf5eb610dbba681ed1313f70216caa1423d4f49c4be87667e3d5e94a84699ad3efd25e77c983912e082b450162a0fd05c80995aed75c796f922e49629433', '2026-05-23 15:23:13', '2026-05-16 20:23:13'),
(38, 1, '5400d1a2c594c13c419ab7d46fd37cbdeb3ea19a2dcbb61ebaa581716487f447dc47558b9b02459498215e6aab64e38c94b426bbb9b9502c8c5a21ac9fd739a2', '2026-05-24 08:08:12', '2026-05-17 13:08:12'),
(39, 1, '0d1bf9b89f78d8fd6c0e305893a1de0273281e63c1a4810e323f06df1e46bb8be6e40400be3f05a540ae9c642f8c06610b3a39c5c897314f15b72e9c18aca124', '2026-05-24 08:25:33', '2026-05-17 13:25:33'),
(40, 1, 'efb9a6e80cb9198f68757008de6fe8a0e4e752dc04e3214f3e928109c30ac278464b7f2067d205d3d96c1ddf6a9d1ff77ff2317b23d3f4fa429dd76013084a99', '2026-05-24 08:26:02', '2026-05-17 13:26:02'),
(41, 1, '282d765e118912e1ffe84822ddf556c4c3d044a6eedf7ac627aedcfdd78a5f3ae55a45717bcda6a9971df704aeae9b2c8ad91acd9205fda0c6e2494f5708e80f', '2026-05-24 08:26:37', '2026-05-17 13:26:37'),
(42, 1, 'c60a2ec5d1dcaeba9f16130ebda24a90eea4d4b32272153fdbc92624a52e81c0c5c760587defa15688fd7e0d36363177dd28744e11085e9b10750ba454186e06', '2026-05-24 08:31:32', '2026-05-17 13:31:32'),
(43, 1, '617372a08050896fc3343419285bc388e42825a5788f36b96802aebbe6e514d59ff60f1a8e62baa6a43c57f767a9c7f8b56309b9efa11af33ad6cd5252697440', '2026-05-24 08:31:52', '2026-05-17 13:31:52'),
(44, 1, 'b316da1e93462115f4767ed693e01108db5de81ed730dbba5fdd2e14f7f179c42110c8ed40c9dd4e0ec4b41f8165e5c38ee86c3228988a249e0aff1d7b360e1f', '2026-05-24 08:35:27', '2026-05-17 13:35:27'),
(45, 1, '8adf287c0d50f84bebd29d1ab5c16d58ba81f947f104abc2a797c4ad1040c3c40c1e2ff9b53a4f59796825aa515bfbeee6806d6be67535d897483195710da1f0', '2026-05-24 08:39:00', '2026-05-17 13:39:00'),
(47, 1, 'ced082f7174dab1d2b6f8f6204c4a5943e12f043f250daedfaabd3f72cf8bd36f81f2260dbc05d5690080552634607845d35b98979dea9585d60c37b11a9c1de', '2026-05-24 08:39:21', '2026-05-17 13:39:21'),
(49, 1, '332d81d1ea0a507f151f4a2225a3ae0692e809c95a8bd3e10c826670fe6509060baf6fad70fd8af68b164d5b6be474a0551fbaf9386236d7ab1736830e51b669', '2026-05-24 08:40:00', '2026-05-17 13:40:00'),
(51, 1, 'acb5ce07717f620a6ca6e9f0fa20ef013a26a729c55d20fff2bacef8146d3290a08c1364336140ae15356023901162c7426a6e6232df717fbaacf4d0f2a1ca32', '2026-05-24 08:40:44', '2026-05-17 13:40:44'),
(52, 2, '80d030f62f16d498972faf593b60a520c2dbdd3aeccbc79264eef37688a19daa81475c99689c7b4c906428b933a7c9912e294fee04e752c034dcf9c574a0995b', '2026-05-24 08:40:55', '2026-05-17 13:40:55'),
(53, 1, '15041c720c176d7cef242841dc56100ae0bc3656267e9cfae88cb8ae2a54a7c8eb92fd444841cc2918514f22694ca0358547ac2c4f5fc6d2f444535959c90e55', '2026-05-24 08:45:20', '2026-05-17 13:45:20'),
(54, 1, 'd793f17ac419b3c7224efb3fdcbd710fd50c71128791f53105742cd2f1e36ee5e00786389ad280a413884168196f54d05a881062c5c7c2b12d97b0d5b2796302', '2026-05-24 08:45:44', '2026-05-17 13:45:44'),
(55, 1, 'ac1a5e3cbee5370b52d1c6a3f774e8030f511d02e568e98f44bf769b4c1675149a8dac687234caade67a284b87da5db752fae54e59086175412770673908b06c', '2026-05-24 08:45:51', '2026-05-17 13:45:51'),
(56, 1, '6c7eaed80a65e28a26f6b199efb8f22775002b8a45d82225dba46464766b9fd16e5584ec2a661685f266aa7044a364fb3113e17fb331c60e4e29e422efd9c528', '2026-05-26 09:17:50', '2026-05-19 14:17:50'),
(57, 1, 'b605fc001d6ca09527a3abeb5900b2db0af101c1950a91b7323944447914a472a1efe2fdf1f6cef90596e6e2dd26245941c05499f45952ab597f34b4d026f75f', '2026-05-26 09:21:04', '2026-05-19 14:21:04'),
(58, 1, 'b80efa46c0bbe734f53b4a1abe1299d2788c7b965a3d1b8e9dc3e2e61adc76bb464d836e270b66cd6b9f0ca985f002facb548f7055de435586c9cd12b415329f', '2026-05-26 09:21:07', '2026-05-19 14:21:07'),
(59, 1, '2b9702cc88a2cfce4db109e016d727129bdc212ad56590c46021033f552e98cc4d7fd0f934b46c196a1224db0b8f7a33091d5009cb85e346bfb710ab7267313d', '2026-05-26 09:21:57', '2026-05-19 14:21:57'),
(60, 1, '927009a1ac340e3c2987fc2e2939b3c2f32e18b8d5734184e4657977c7fb015f02a4d55da0f5700061a746772bf2392c190368ef5ff2225c0951008507b0a97f', '2026-05-26 09:22:01', '2026-05-19 14:22:01'),
(61, 1, 'b176d395f10b37d89a5e9a0bda824a5ba6017c21ab7f22d7edcc7ac36f90716a3092a1a103b5ba4a4cb17392b0c478c15dcfeb464f1726a71a9661be9398d8d6', '2026-05-26 09:22:05', '2026-05-19 14:22:05'),
(62, 1, '58e13b12daae01b48b561f23128787baedcf7d8127e3e1328c0b98cbd1a9c6d7bc7fe29d1432faa121fac13aae3dd4cc8f8f43756b8cc26e648135175704700b', '2026-05-26 09:28:55', '2026-05-19 14:28:55'),
(64, 1, '586258e84e0e85e60d99f72ebada68d9fc3f0a66567ab2b202e8f6cb5efc22c8db684b38be878e0e3bd2aff9444093243a1ee8f80665deb9cde3ddee00b4a640', '2026-05-26 09:29:59', '2026-05-19 14:29:59'),
(65, 1, '87335936f7cda38d40536db9bebf0a51102a132ab82b34c4fd5a3fd4b6a32d4bd6f48316a9edbd7ad9e4dc2926cdd7acb2215c1ef698dd3b129d4ad0d83280a1', '2026-05-26 09:30:01', '2026-05-19 14:30:01'),
(66, 5, '04225db846f2e68a1d4a380b7ce80e3314631a65d27c8344249c49c5c4a8a2d2dd9f8053d570b87a823c3003e8118cd2d34d5b62618766d16490da9054728ce3', '2026-05-26 09:30:47', '2026-05-19 14:30:47');

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `user_streaks`
--

CREATE TABLE `user_streaks` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `current_streak` int(11) NOT NULL DEFAULT 0,
  `longest_streak` int(11) NOT NULL DEFAULT 0,
  `last_active_date` date DEFAULT NULL,
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Đang đổ dữ liệu cho bảng `user_streaks`
--

INSERT INTO `user_streaks` (`id`, `user_id`, `current_streak`, `longest_streak`, `last_active_date`, `updated_at`) VALUES
(1, 1, 1, 30, '2026-05-16', '2026-05-16 19:42:55'),
(2, 5, 0, 0, NULL, '2026-05-19 14:29:43');

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `user_verifications`
--

CREATE TABLE `user_verifications` (
  `id` int(11) NOT NULL,
  `email` varchar(100) NOT NULL,
  `otp_code` varchar(6) NOT NULL,
  `expires_at` datetime NOT NULL,
  `is_verified` tinyint(1) NOT NULL DEFAULT 0,
  `created_at` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `user_xp`
--

CREATE TABLE `user_xp` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `total_xp` int(11) NOT NULL DEFAULT 0,
  `current_rank` varchar(50) DEFAULT NULL COMMENT 'VD: Dong, Bac, Vang',
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Đang đổ dữ liệu cho bảng `user_xp`
--

INSERT INTO `user_xp` (`id`, `user_id`, `total_xp`, `current_rank`, `updated_at`) VALUES
(1, 1, 470, NULL, '2026-05-16 20:00:57'),
(2, 5, 0, NULL, '2026-05-19 14:29:43');

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `videos`
--

CREATE TABLE `videos` (
  `id` int(11) NOT NULL,
  `lesson_id` int(11) DEFAULT NULL COMMENT 'NULL = video doc lap',
  `title` varchar(200) NOT NULL,
  `url` varchar(500) NOT NULL,
  `duration` varchar(20) DEFAULT NULL COMMENT 'VD: 5:20',
  `thumbnail` varchar(500) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `xp_transactions`
--

CREATE TABLE `xp_transactions` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `amount` int(11) NOT NULL COMMENT 'So XP (+/-)',
  `source` enum('quiz','assignment','streak','forum','achievement','admin') NOT NULL,
  `reference_id` int(11) DEFAULT NULL COMMENT 'ID bang lien quan',
  `created_at` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Đang đổ dữ liệu cho bảng `xp_transactions`
--

INSERT INTO `xp_transactions` (`id`, `user_id`, `amount`, `source`, `reference_id`, `created_at`) VALUES
(1, 1, 10, 'streak', NULL, '2026-05-16 19:42:55'),
(2, 1, 0, 'quiz', 0, '2026-05-16 19:43:49'),
(3, 1, 5, 'forum', 1, '2026-05-16 19:49:56'),
(4, 1, 5, 'forum', 2, '2026-05-16 20:00:57');

--
-- Chỉ mục cho các bảng đã đổ
--

--
-- Chỉ mục cho bảng `achievements`
--
ALTER TABLE `achievements`
  ADD PRIMARY KEY (`id`);

--
-- Chỉ mục cho bảng `ai_chat_history`
--
ALTER TABLE `ai_chat_history`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_ach_user` (`user_id`);

--
-- Chỉ mục cho bảng `assignments`
--
ALTER TABLE `assignments`
  ADD PRIMARY KEY (`id`),
  ADD KEY `exam_id` (`exam_id`),
  ADD KEY `assigned_by` (`assigned_by`),
  ADD KEY `idx_assign_class` (`class_id`);

--
-- Chỉ mục cho bảng `classes`
--
ALTER TABLE `classes`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `class_code` (`class_code`),
  ADD KEY `idx_classes_teacher` (`teacher_id`);

--
-- Chỉ mục cho bảng `class_members`
--
ALTER TABLE `class_members`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_cm_class_student` (`class_id`,`student_id`),
  ADD KEY `idx_cm_student` (`student_id`);

--
-- Chỉ mục cho bảng `daily_attendance`
--
ALTER TABLE `daily_attendance`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_da_user_date` (`user_id`,`attendance_date`);

--
-- Chỉ mục cho bảng `documents`
--
ALTER TABLE `documents`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_docs_lesson` (`lesson_id`);

--
-- Chỉ mục cho bảng `exams`
--
ALTER TABLE `exams`
  ADD PRIMARY KEY (`id`),
  ADD KEY `created_by` (`created_by`),
  ADD KEY `idx_exams_subject` (`subject_id`),
  ADD KEY `idx_exams_type` (`type`);

--
-- Chỉ mục cho bảng `exam_questions`
--
ALTER TABLE `exam_questions`
  ADD PRIMARY KEY (`id`),
  ADD KEY `question_id` (`question_id`),
  ADD KEY `idx_eq_exam` (`exam_id`);

--
-- Chỉ mục cho bảng `faq`
--
ALTER TABLE `faq`
  ADD PRIMARY KEY (`id`);

--
-- Chỉ mục cho bảng `fill_blank_answers`
--
ALTER TABLE `fill_blank_answers`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_fba_question` (`question_id`);

--
-- Chỉ mục cho bảng `forum_comments`
--
ALTER TABLE `forum_comments`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_id` (`user_id`),
  ADD KEY `idx_fc_post` (`post_id`);

--
-- Chỉ mục cho bảng `forum_posts`
--
ALTER TABLE `forum_posts`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_fp_user` (`user_id`),
  ADD KEY `idx_fp_topic` (`topic_id`),
  ADD KEY `idx_fp_status` (`status`);

--
-- Chỉ mục cho bảng `forum_topics`
--
ALTER TABLE `forum_topics`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `slug` (`slug`);

--
-- Chỉ mục cho bảng `forum_votes`
--
ALTER TABLE `forum_votes`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_fv_post_user` (`post_id`,`user_id`),
  ADD KEY `user_id` (`user_id`);

--
-- Chỉ mục cho bảng `grades`
--
ALTER TABLE `grades`
  ADD PRIMARY KEY (`id`),
  ADD KEY `subject_id` (`subject_id`),
  ADD KEY `assignment_id` (`assignment_id`),
  ADD KEY `exam_id` (`exam_id`),
  ADD KEY `idx_grades_student` (`student_id`),
  ADD KEY `idx_grades_class` (`class_id`);

--
-- Chỉ mục cho bảng `lab_models`
--
ALTER TABLE `lab_models`
  ADD PRIMARY KEY (`id`),
  ADD KEY `lesson_id` (`lesson_id`),
  ADD KEY `idx_lab_subject` (`subject_id`);

--
-- Chỉ mục cho bảng `lessons`
--
ALTER TABLE `lessons`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_lessons_subject` (`subject_id`);

--
-- Chỉ mục cho bảng `matching_pairs`
--
ALTER TABLE `matching_pairs`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_mp_question` (`question_id`);

--
-- Chỉ mục cho bảng `news`
--
ALTER TABLE `news`
  ADD PRIMARY KEY (`id`),
  ADD KEY `created_by` (`created_by`),
  ADD KEY `idx_news_status` (`status`),
  ADD KEY `idx_news_pinned` (`is_pinned`);

--
-- Chỉ mục cho bảng `notifications`
--
ALTER TABLE `notifications`
  ADD PRIMARY KEY (`id`),
  ADD KEY `created_by` (`created_by`),
  ADD KEY `idx_notif_role` (`target_role`);

--
-- Chỉ mục cho bảng `notification_reads`
--
ALTER TABLE `notification_reads`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_nr_notif_user` (`notification_id`,`user_id`),
  ADD KEY `user_id` (`user_id`);

--
-- Chỉ mục cho bảng `parent_student_links`
--
ALTER TABLE `parent_student_links`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `link_code` (`link_code`),
  ADD UNIQUE KEY `uq_psl_parent_student` (`parent_id`,`student_id`),
  ADD KEY `idx_psl_parent` (`parent_id`),
  ADD KEY `idx_psl_student` (`student_id`);

--
-- Chỉ mục cho bảng `question_bank`
--
ALTER TABLE `question_bank`
  ADD PRIMARY KEY (`id`),
  ADD KEY `created_by` (`created_by`),
  ADD KEY `idx_qb_subject` (`subject_id`),
  ADD KEY `idx_qb_lesson` (`lesson_id`),
  ADD KEY `idx_qb_type` (`question_type`);

--
-- Chỉ mục cho bảng `question_options`
--
ALTER TABLE `question_options`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_qo_question` (`question_id`);

--
-- Chỉ mục cho bảng `student_answers`
--
ALTER TABLE `student_answers`
  ADD PRIMARY KEY (`id`),
  ADD KEY `question_id` (`question_id`),
  ADD KEY `selected_option_id` (`selected_option_id`),
  ADD KEY `idx_sa_assign` (`student_assignment_id`);

--
-- Chỉ mục cho bảng `student_assignments`
--
ALTER TABLE `student_assignments`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_sa_assign_student` (`assignment_id`,`student_id`),
  ADD KEY `student_id` (`student_id`),
  ADD KEY `graded_by` (`graded_by`);

--
-- Chỉ mục cho bảng `subjects`
--
ALTER TABLE `subjects`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `slug` (`slug`);

--
-- Chỉ mục cho bảng `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `email` (`email`),
  ADD KEY `idx_users_role` (`role`),
  ADD KEY `idx_users_status` (`status`);

--
-- Chỉ mục cho bảng `user_achievements`
--
ALTER TABLE `user_achievements`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_ua_user_ach` (`user_id`,`achievement_id`),
  ADD KEY `achievement_id` (`achievement_id`);

--
-- Chỉ mục cho bảng `user_sessions`
--
ALTER TABLE `user_sessions`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `auth_token` (`auth_token`),
  ADD KEY `user_id` (`user_id`),
  ADD KEY `idx_us_token` (`auth_token`);

--
-- Chỉ mục cho bảng `user_streaks`
--
ALTER TABLE `user_streaks`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `user_id` (`user_id`);

--
-- Chỉ mục cho bảng `user_verifications`
--
ALTER TABLE `user_verifications`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_uv_email` (`email`);

--
-- Chỉ mục cho bảng `user_xp`
--
ALTER TABLE `user_xp`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `user_id` (`user_id`);

--
-- Chỉ mục cho bảng `videos`
--
ALTER TABLE `videos`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_videos_lesson` (`lesson_id`);

--
-- Chỉ mục cho bảng `xp_transactions`
--
ALTER TABLE `xp_transactions`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_xp_user` (`user_id`);

--
-- AUTO_INCREMENT cho các bảng đã đổ
--

--
-- AUTO_INCREMENT cho bảng `achievements`
--
ALTER TABLE `achievements`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT cho bảng `ai_chat_history`
--
ALTER TABLE `ai_chat_history`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=17;

--
-- AUTO_INCREMENT cho bảng `assignments`
--
ALTER TABLE `assignments`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT cho bảng `classes`
--
ALTER TABLE `classes`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT cho bảng `class_members`
--
ALTER TABLE `class_members`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT cho bảng `daily_attendance`
--
ALTER TABLE `daily_attendance`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT cho bảng `documents`
--
ALTER TABLE `documents`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT cho bảng `exams`
--
ALTER TABLE `exams`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT cho bảng `exam_questions`
--
ALTER TABLE `exam_questions`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT cho bảng `faq`
--
ALTER TABLE `faq`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT cho bảng `fill_blank_answers`
--
ALTER TABLE `fill_blank_answers`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT cho bảng `forum_comments`
--
ALTER TABLE `forum_comments`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT cho bảng `forum_posts`
--
ALTER TABLE `forum_posts`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT cho bảng `forum_topics`
--
ALTER TABLE `forum_topics`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT cho bảng `forum_votes`
--
ALTER TABLE `forum_votes`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT cho bảng `grades`
--
ALTER TABLE `grades`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT cho bảng `lab_models`
--
ALTER TABLE `lab_models`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT cho bảng `lessons`
--
ALTER TABLE `lessons`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT cho bảng `matching_pairs`
--
ALTER TABLE `matching_pairs`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT cho bảng `news`
--
ALTER TABLE `news`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT cho bảng `notifications`
--
ALTER TABLE `notifications`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT cho bảng `notification_reads`
--
ALTER TABLE `notification_reads`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT cho bảng `parent_student_links`
--
ALTER TABLE `parent_student_links`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=17;

--
-- AUTO_INCREMENT cho bảng `question_bank`
--
ALTER TABLE `question_bank`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT cho bảng `question_options`
--
ALTER TABLE `question_options`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT cho bảng `student_answers`
--
ALTER TABLE `student_answers`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT cho bảng `student_assignments`
--
ALTER TABLE `student_assignments`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT cho bảng `subjects`
--
ALTER TABLE `subjects`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT cho bảng `users`
--
ALTER TABLE `users`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT cho bảng `user_achievements`
--
ALTER TABLE `user_achievements`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT cho bảng `user_sessions`
--
ALTER TABLE `user_sessions`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=67;

--
-- AUTO_INCREMENT cho bảng `user_streaks`
--
ALTER TABLE `user_streaks`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT cho bảng `user_verifications`
--
ALTER TABLE `user_verifications`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT cho bảng `user_xp`
--
ALTER TABLE `user_xp`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT cho bảng `videos`
--
ALTER TABLE `videos`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT cho bảng `xp_transactions`
--
ALTER TABLE `xp_transactions`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- Các ràng buộc cho các bảng đã đổ
--

--
-- Các ràng buộc cho bảng `ai_chat_history`
--
ALTER TABLE `ai_chat_history`
  ADD CONSTRAINT `ai_chat_history_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Các ràng buộc cho bảng `assignments`
--
ALTER TABLE `assignments`
  ADD CONSTRAINT `assignments_ibfk_1` FOREIGN KEY (`class_id`) REFERENCES `classes` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `assignments_ibfk_2` FOREIGN KEY (`exam_id`) REFERENCES `exams` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `assignments_ibfk_3` FOREIGN KEY (`assigned_by`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Các ràng buộc cho bảng `classes`
--
ALTER TABLE `classes`
  ADD CONSTRAINT `classes_ibfk_1` FOREIGN KEY (`teacher_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Các ràng buộc cho bảng `class_members`
--
ALTER TABLE `class_members`
  ADD CONSTRAINT `class_members_ibfk_1` FOREIGN KEY (`class_id`) REFERENCES `classes` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `class_members_ibfk_2` FOREIGN KEY (`student_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Các ràng buộc cho bảng `daily_attendance`
--
ALTER TABLE `daily_attendance`
  ADD CONSTRAINT `daily_attendance_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Các ràng buộc cho bảng `documents`
--
ALTER TABLE `documents`
  ADD CONSTRAINT `documents_ibfk_1` FOREIGN KEY (`lesson_id`) REFERENCES `lessons` (`id`) ON DELETE SET NULL;

--
-- Các ràng buộc cho bảng `exams`
--
ALTER TABLE `exams`
  ADD CONSTRAINT `exams_ibfk_1` FOREIGN KEY (`subject_id`) REFERENCES `subjects` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `exams_ibfk_2` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Các ràng buộc cho bảng `exam_questions`
--
ALTER TABLE `exam_questions`
  ADD CONSTRAINT `exam_questions_ibfk_1` FOREIGN KEY (`exam_id`) REFERENCES `exams` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `exam_questions_ibfk_2` FOREIGN KEY (`question_id`) REFERENCES `question_bank` (`id`) ON DELETE CASCADE;

--
-- Các ràng buộc cho bảng `fill_blank_answers`
--
ALTER TABLE `fill_blank_answers`
  ADD CONSTRAINT `fill_blank_answers_ibfk_1` FOREIGN KEY (`question_id`) REFERENCES `question_bank` (`id`) ON DELETE CASCADE;

--
-- Các ràng buộc cho bảng `forum_comments`
--
ALTER TABLE `forum_comments`
  ADD CONSTRAINT `forum_comments_ibfk_1` FOREIGN KEY (`post_id`) REFERENCES `forum_posts` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `forum_comments_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Các ràng buộc cho bảng `forum_posts`
--
ALTER TABLE `forum_posts`
  ADD CONSTRAINT `forum_posts_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `forum_posts_ibfk_2` FOREIGN KEY (`topic_id`) REFERENCES `forum_topics` (`id`) ON DELETE SET NULL;

--
-- Các ràng buộc cho bảng `forum_votes`
--
ALTER TABLE `forum_votes`
  ADD CONSTRAINT `forum_votes_ibfk_1` FOREIGN KEY (`post_id`) REFERENCES `forum_posts` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `forum_votes_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Các ràng buộc cho bảng `grades`
--
ALTER TABLE `grades`
  ADD CONSTRAINT `grades_ibfk_1` FOREIGN KEY (`student_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `grades_ibfk_2` FOREIGN KEY (`class_id`) REFERENCES `classes` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `grades_ibfk_3` FOREIGN KEY (`subject_id`) REFERENCES `subjects` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `grades_ibfk_4` FOREIGN KEY (`assignment_id`) REFERENCES `assignments` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `grades_ibfk_5` FOREIGN KEY (`exam_id`) REFERENCES `exams` (`id`) ON DELETE SET NULL;

--
-- Các ràng buộc cho bảng `lab_models`
--
ALTER TABLE `lab_models`
  ADD CONSTRAINT `lab_models_ibfk_1` FOREIGN KEY (`lesson_id`) REFERENCES `lessons` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `lab_models_ibfk_2` FOREIGN KEY (`subject_id`) REFERENCES `subjects` (`id`) ON DELETE SET NULL;

--
-- Các ràng buộc cho bảng `lessons`
--
ALTER TABLE `lessons`
  ADD CONSTRAINT `lessons_ibfk_1` FOREIGN KEY (`subject_id`) REFERENCES `subjects` (`id`) ON DELETE CASCADE;

--
-- Các ràng buộc cho bảng `matching_pairs`
--
ALTER TABLE `matching_pairs`
  ADD CONSTRAINT `matching_pairs_ibfk_1` FOREIGN KEY (`question_id`) REFERENCES `question_bank` (`id`) ON DELETE CASCADE;

--
-- Các ràng buộc cho bảng `news`
--
ALTER TABLE `news`
  ADD CONSTRAINT `news_ibfk_1` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Các ràng buộc cho bảng `notifications`
--
ALTER TABLE `notifications`
  ADD CONSTRAINT `notifications_ibfk_1` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Các ràng buộc cho bảng `notification_reads`
--
ALTER TABLE `notification_reads`
  ADD CONSTRAINT `notification_reads_ibfk_1` FOREIGN KEY (`notification_id`) REFERENCES `notifications` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `notification_reads_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Các ràng buộc cho bảng `parent_student_links`
--
ALTER TABLE `parent_student_links`
  ADD CONSTRAINT `parent_student_links_ibfk_1` FOREIGN KEY (`parent_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `parent_student_links_ibfk_2` FOREIGN KEY (`student_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Các ràng buộc cho bảng `question_bank`
--
ALTER TABLE `question_bank`
  ADD CONSTRAINT `question_bank_ibfk_1` FOREIGN KEY (`subject_id`) REFERENCES `subjects` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `question_bank_ibfk_2` FOREIGN KEY (`lesson_id`) REFERENCES `lessons` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `question_bank_ibfk_3` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`) ON DELETE SET NULL;

--
-- Các ràng buộc cho bảng `question_options`
--
ALTER TABLE `question_options`
  ADD CONSTRAINT `question_options_ibfk_1` FOREIGN KEY (`question_id`) REFERENCES `question_bank` (`id`) ON DELETE CASCADE;

--
-- Các ràng buộc cho bảng `student_answers`
--
ALTER TABLE `student_answers`
  ADD CONSTRAINT `student_answers_ibfk_1` FOREIGN KEY (`student_assignment_id`) REFERENCES `student_assignments` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `student_answers_ibfk_2` FOREIGN KEY (`question_id`) REFERENCES `question_bank` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `student_answers_ibfk_3` FOREIGN KEY (`selected_option_id`) REFERENCES `question_options` (`id`) ON DELETE SET NULL;

--
-- Các ràng buộc cho bảng `student_assignments`
--
ALTER TABLE `student_assignments`
  ADD CONSTRAINT `student_assignments_ibfk_1` FOREIGN KEY (`assignment_id`) REFERENCES `assignments` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `student_assignments_ibfk_2` FOREIGN KEY (`student_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `student_assignments_ibfk_3` FOREIGN KEY (`graded_by`) REFERENCES `users` (`id`) ON DELETE SET NULL;

--
-- Các ràng buộc cho bảng `user_achievements`
--
ALTER TABLE `user_achievements`
  ADD CONSTRAINT `user_achievements_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `user_achievements_ibfk_2` FOREIGN KEY (`achievement_id`) REFERENCES `achievements` (`id`) ON DELETE CASCADE;

--
-- Các ràng buộc cho bảng `user_sessions`
--
ALTER TABLE `user_sessions`
  ADD CONSTRAINT `user_sessions_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Các ràng buộc cho bảng `user_streaks`
--
ALTER TABLE `user_streaks`
  ADD CONSTRAINT `user_streaks_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Các ràng buộc cho bảng `user_xp`
--
ALTER TABLE `user_xp`
  ADD CONSTRAINT `user_xp_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Các ràng buộc cho bảng `videos`
--
ALTER TABLE `videos`
  ADD CONSTRAINT `videos_ibfk_1` FOREIGN KEY (`lesson_id`) REFERENCES `lessons` (`id`) ON DELETE SET NULL;

--
-- Các ràng buộc cho bảng `xp_transactions`
--
ALTER TABLE `xp_transactions`
  ADD CONSTRAINT `xp_transactions_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;
COMMIT;


