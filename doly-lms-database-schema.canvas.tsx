import { Card, CardHeader, CardBody, CollapsibleCard, Divider, Grid, H1, H2, H3, Stack, Text, Tag, Pill, Table, Row, Callout } from "qoder/canvas";

const groups = [
  {
    title: "Nhom 1: Auth & Nguoi Dung (3 bang)",
    tables: [
      { name: "users", desc: "Tai khoan trung tam (4 vai tro: admin, student, teacher, parent)", cols: 10, fks: [] },
      { name: "user_verifications", desc: "Ma OTP gui qua email khi dang ky", cols: 6, fks: [] },
      { name: "user_sessions", desc: "Token phien dang nhap", cols: 5, fks: ["users.id"] },
    ]
  },
  {
    title: "Nhom 2: Lop Hoc (2 bang)",
    tables: [
      { name: "classes", desc: "Lop hoc do giao vien tao (kem ma moi)", cols: 8, fks: ["users.id (teacher)"] },
      { name: "class_members", desc: "Hoc sinh trong lop", cols: 5, fks: ["classes.id", "users.id (student)"] },
    ]
  },
  {
    title: "Nhom 3: Bai Giang & Hoc Lieu (5 bang)",
    tables: [
      { name: "subjects", desc: "Danh muc mon hoc (Vat Ly, Hoa Hoc, Sinh Hoc)", cols: 3, fks: [] },
      { name: "lessons", desc: "Bai giang ly thuyet (HTML content)", cols: 6, fks: ["subjects.id"] },
      { name: "videos", desc: "Video bai giang", cols: 6, fks: ["lessons.id"] },
      { name: "documents", desc: "Tai lieu PDF, Mindmap, Phieu BT", cols: 7, fks: ["lessons.id"] },
      { name: "lab_models", desc: "Mo hinh 3D Lab (file .glb)", cols: 9, fks: ["lessons.id", "subjects.id"] },
    ]
  },
  {
    title: "Nhom 4: Cau Hoi & Kiem Tra (6 bang)",
    tables: [
      { name: "question_bank", desc: "Ngan hang cau hoi (4 loai)", cols: 11, fks: ["subjects.id", "lessons.id", "users.id"] },
      { name: "question_options", desc: "Dap an cho cau trac nghiem / dung-sai", cols: 5, fks: ["question_bank.id"] },
      { name: "fill_blank_answers", desc: "Dap an cho cau dien khuyet", cols: 5, fks: ["question_bank.id"] },
      { name: "matching_pairs", desc: "Cap ghep cho cau Matching", cols: 4, fks: ["question_bank.id"] },
      { name: "exams", desc: "Bai kiem tra / de thi", cols: 10, fks: ["subjects.id", "users.id"] },
      { name: "exam_questions", desc: "Cau hoi trong de thi", cols: 5, fks: ["exams.id", "question_bank.id"] },
    ]
  },
  {
    title: "Nhom 5: Giao Bai & Cham Diem (4 bang)",
    tables: [
      { name: "assignments", desc: "Bai tap giao vien giao cho lop", cols: 8, fks: ["classes.id", "exams.id", "users.id"] },
      { name: "student_assignments", desc: "Bai nop cua hoc sinh", cols: 8, fks: ["assignments.id", "users.id"] },
      { name: "student_answers", desc: "Chi tiet cau tra loi", cols: 8, fks: ["student_assignments.id", "question_bank.id"] },
      { name: "grades", desc: "Bang diem tong hop", cols: 8, fks: ["users.id", "classes.id", "subjects.id"] },
    ]
  },
  {
    title: "Nhom 6: Dien Dan (4 bang)",
    tables: [
      { name: "forum_topics", desc: "Chu de / tag mon hoc", cols: 4, fks: [] },
      { name: "forum_posts", desc: "Bai viet dien dan", cols: 9, fks: ["users.id", "forum_topics.id"] },
      { name: "forum_comments", desc: "Cau tra loi / binh luan", cols: 6, fks: ["forum_posts.id", "users.id"] },
      { name: "forum_votes", desc: "Vote up/down cho bai viet", cols: 5, fks: ["forum_posts.id", "users.id"] },
    ]
  },
  {
    title: "Nhom 7: Gamification (6 bang)",
    tables: [
      { name: "user_xp", desc: "Diem kinh nghiem va rank", cols: 6, fks: ["users.id"] },
      { name: "xp_transactions", desc: "Lich su cong/tru XP", cols: 7, fks: ["users.id"] },
      { name: "user_streaks", desc: "Chuoi ngay hoc lien tiep", cols: 6, fks: ["users.id"] },
      { name: "daily_attendance", desc: "Diem danh hang ngay", cols: 6, fks: ["users.id"] },
      { name: "achievements", desc: "Danh sach huy hieu", cols: 5, fks: [] },
      { name: "user_achievements", desc: "Huy hieu nguoi dung da mo", cols: 4, fks: ["users.id", "achievements.id"] },
    ]
  },
  {
    title: "Nhom 8: Phu Huynh (1 bang)",
    tables: [
      { name: "parent_student_links", desc: "Lien ket phu huynh - hoc sinh", cols: 7, fks: ["users.id (parent)", "users.id (student)"] },
    ]
  },
  {
    title: "Nhom 9: Quan Tri & He Thong (4 bang)",
    tables: [
      { name: "notifications", desc: "Thong bao he thong (Admin tao)", cols: 7, fks: ["users.id"] },
      { name: "notification_reads", desc: "Trang thai da doc", cols: 4, fks: ["notifications.id", "users.id"] },
      { name: "news", desc: "Tin tuc giao duc", cols: 9, fks: ["users.id"] },
      { name: "faq", desc: "Cau hoi thuong gap", cols: 5, fks: [] },
    ]
  },
  {
    title: "Nhom 10: AI Chat (1 bang)",
    tables: [
      { name: "ai_chat_history", desc: "Lich su tro chuyen voi Doly AI", cols: 7, fks: ["users.id"] },
    ]
  },
];

const summaryStats = [
  { label: "Tong so bang", value: "36" },
  { label: "Khoa ngoai", value: "40+" },
  { label: "Bang trung tam", value: "users (10 cot)" },
  { label: "Nhom chuc nang", value: "10" },
  { label: "Seed data", value: "Da co san" },
];

export default function DatabaseSchema() {
  return (
    <Stack gap={24}>
      <Stack gap={8}>
        <H1>DOLY LMS — So do Co so Du lieu</H1>
        <Text tone="secondary" size="body">
          Thiet ke day du 36 bang, chia 10 nhom chuc nang, dam bao phu song toan bo tinh nang cua he thong.
        </Text>
      </Stack>

      <Divider />

      <Row gap={12} wrap>
        {summaryStats.map((s) => (
          <Card key={s.label} variant="borderless" size="sm">
            <CardBody>
              <Stack gap={4} align="center">
                <Text weight="bold" size="body">{s.value}</Text>
                <Text tone="secondary" size="small">{s.label}</Text>
              </Stack>
            </CardBody>
          </Card>
        ))}
      </Row>

      <Callout tone="info">
        File SQL day du da duoc tao tai: <strong>database_schema.sql</strong> — gom create table, index, foreign key, seed data va comment chi tiet.
      </Callout>

      <Divider />

      {groups.map((group) => (
        <CollapsibleCard key={group.title} defaultOpen>
          <CardHeader title={group.title} />
          <CardBody>
            <Table
              headers={["STT", "Ten bang", "Mo ta", "So cot", "Khoa ngoai (FK)"]}
              rows={group.tables.map((t, i) => [
                String(i + 1),
                t.name,
                t.desc,
                String(t.cols),
                t.fks.length > 0 ? t.fks.join(", ") : "--",
              ])}
            />
          </CardBody>
        </CollapsibleCard>
      ))}

      <Divider />

      <H2>So do quan he giua cac bang</H2>
      <Text tone="secondary" size="small" style={{ marginBottom: 12 }}>
        Chi tiet cac moi quan he khoa ngoai (Foreign Key) giua cac bang
      </Text>

      <Table
        headers={["Nhom", "Bang cha", "Bang con", "Quan he"]}
        rows={[
          ["Auth", "users", "user_sessions", "user_sessions.user_id -> users.id"],
          ["Auth", "users", "user_verifications", "(doc lap, chi dung email)"],
          ["Lop", "users (teacher)", "classes", "classes.teacher_id -> users.id"],
          ["Lop", "classes", "class_members", "class_members.class_id -> classes.id"],
          ["Lop", "users (student)", "class_members", "class_members.student_id -> users.id"],
          ["Hoc lieu", "subjects", "lessons", "lessons.subject_id -> subjects.id"],
          ["Hoc lieu", "lessons", "videos", "videos.lesson_id -> lessons.id"],
          ["Hoc lieu", "lessons", "documents", "documents.lesson_id -> lessons.id"],
          ["Hoc lieu", "subjects", "lab_models", "lab_models.subject_id -> subjects.id"],
          ["Cau hoi", "subjects", "question_bank", "question_bank.subject_id -> subjects.id"],
          ["Cau hoi", "lessons", "question_bank", "question_bank.lesson_id -> lessons.id"],
          ["Cau hoi", "question_bank", "question_options", "question_options.question_id -> question_bank.id"],
          ["Cau hoi", "question_bank", "fill_blank_answers", "fill_blank_answers.question_id -> question_bank.id"],
          ["Cau hoi", "question_bank", "matching_pairs", "matching_pairs.question_id -> question_bank.id"],
          ["Kiem tra", "exams", "exam_questions", "exam_questions.exam_id -> exams.id"],
          ["Kiem tra", "question_bank", "exam_questions", "exam_questions.question_id -> question_bank.id"],
          ["Giao bai", "classes", "assignments", "assignments.class_id -> classes.id"],
          ["Giao bai", "exams", "assignments", "assignments.exam_id -> exams.id"],
          ["Giao bai", "assignments", "student_assignments", "student_assignments.assignment_id -> assignments.id"],
          ["Giao bai", "student_assignments", "student_answers", "student_answers.student_assignment_id -> student_assignments.id"],
          ["Diem", "users (student)", "grades", "grades.student_id -> users.id"],
          ["Diem", "classes", "grades", "grades.class_id -> classes.id"],
          ["Dien dan", "users", "forum_posts", "forum_posts.user_id -> users.id"],
          ["Dien dan", "forum_posts", "forum_comments", "forum_comments.post_id -> forum_posts.id"],
          ["Dien dan", "forum_posts", "forum_votes", "forum_votes.post_id -> forum_posts.id"],
          ["Game", "users", "user_xp", "user_xp.user_id -> users.id"],
          ["Game", "users", "user_streaks", "user_streaks.user_id -> users.id"],
          ["Game", "users", "xp_transactions", "xp_transactions.user_id -> users.id"],
          ["Game", "users", "daily_attendance", "daily_attendance.user_id -> users.id"],
          ["Game", "users", "user_achievements", "user_achievements.user_id -> users.id"],
          ["Game", "achievements", "user_achievements", "user_achievements.achievement_id -> achievements.id"],
          ["Phu huynh", "users (parent)", "parent_student_links", "parent_student_links.parent_id -> users.id"],
          ["Phu huynh", "users (student)", "parent_student_links", "parent_student_links.student_id -> users.id"],
          ["He thong", "users (admin)", "notifications", "notifications.created_by -> users.id"],
          ["He thong", "notifications", "notification_reads", "notification_reads.notification_id -> notifications.id"],
          ["He thong", "users (admin)", "news", "news.created_by -> users.id"],
          ["AI Chat", "users", "ai_chat_history", "ai_chat_history.user_id -> users.id"],
        ]}
      />

      <Divider />

      <Stack gap={8}>
        <H2>Luu y ky thuat</H2>
        <Stack gap={4}>
          <Row gap={8} align="center">
            <Pill tone="info">Engine</Pill>
            <Text size="small">InnoDB — ho tro khoa ngoai va transaction</Text>
          </Row>
          <Row gap={8} align="center">
            <Pill tone="info">Charset</Pill>
            <Text size="small">utf8mb4 + utf8mb4_unicode_ci — ho tro tieng Viet day du</Text>
          </Row>
          <Row gap={8} align="center">
            <Pill tone="info">Index</Pill>
            <Text size="small">Da tao index cho cac cot thuong xuyen truy van (WHERE, JOIN, ORDER BY)</Text>
          </Row>
          <Row gap={8} align="center">
            <Pill tone="info">FK</Pill>
            <Text size="small">ON DELETE CASCADE cho bang con, SET NULL cho bang tuy chon</Text>
          </Row>
          <Row gap={8} align="center">
            <Pill tone="info">Security</Pill>
            <Text size="small">Mat khau luu bang password_hash (bcrypt), auth_token ngau nhien 255 ky tu</Text>
          </Row>
          <Row gap={8} align="center">
            <Pill tone="info">Seed</Pill>
            <Text size="small">Co san du lieu: mon hoc, chu de dien dan, FAQ, thanh tich (huy hieu)</Text>
          </Row>
        </Stack>
      </Stack>
    </Stack>
  );
}
