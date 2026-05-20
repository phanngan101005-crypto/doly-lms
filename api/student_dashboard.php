<?php
/**
 * DOLY LMS - Student Dashboard
 * POST /api/student_dashboard.php
 * Body: { auth_token }
 * Returns: { user, stats }
 */

require_once __DIR__ . '/config.php';
require_once __DIR__ . '/helpers.php';
require_once __DIR__ . '/auth.php';

$user = authenticate();

if ($user['role'] !== 'student') {
    jsonError('Chi danh cho hoc sinh', 403);
}

try {
    $db = getDB();
    $userId = (int)$user['id'];

    // Thong tin user + XP
    $stmt = $db->prepare('
        SELECT u.full_name, u.email, u.avatar_url, ux.total_xp, ux.current_rank
        FROM users u
        LEFT JOIN user_xp ux ON u.id = ux.user_id
        WHERE u.id = ?
    ');
    $stmt->execute([$userId]);
    $userInfo = $stmt->fetch();

    // Diem trung binh tu bai tap da cham
    $stmt = $db->prepare('
        SELECT AVG(score) as avg_score,
               COUNT(*) as graded_count
        FROM student_assignments
        WHERE student_id = ? AND status = \'graded\' AND score IS NOT NULL
    ');
    $stmt->execute([$userId]);
    $scoreData = $stmt->fetch();
    $avgScore = $scoreData['avg_score'] !== null ? (float)$scoreData['avg_score'] : 0.0;

    // Tien do: so assignment da hoan thanh
    $stmt = $db->prepare('
        SELECT COUNT(*) as completed
        FROM student_assignments
        WHERE student_id = ? AND (status = \'submitted\' OR status = \'graded\')
    ');
    $stmt->execute([$userId]);
    $progress = $stmt->fetch();
    $avgProgress = (int)$progress['completed'];

    // Thong tin lop hoc
    $stmt = $db->prepare('
        SELECT cm.class_id, c.name as class_name
        FROM class_members cm
        JOIN classes c ON cm.class_id = c.id
        WHERE cm.student_id = ? AND cm.status = \'active\'
    ');
    $stmt->execute([$userId]);
    $classes = $stmt->fetchAll();

    // So bai kiem tra da lam
    $stmt = $db->prepare('
        SELECT COUNT(*) as exam_count
        FROM student_assignments sa
        JOIN assignments a ON sa.assignment_id = a.id
        WHERE sa.student_id = ? AND a.exam_id IS NOT NULL AND sa.status != \'pending\'
    ');
    $stmt->execute([$userId]);
    $examData = $stmt->fetch();

    // Streak
    $stmt = $db->prepare('
        SELECT current_streak, longest_streak
        FROM user_streaks WHERE user_id = ?
    ');
    $stmt->execute([$userId]);
    $streak = $stmt->fetch();

    jsonSuccess([
        'user' => [
            'full_name'  => $userInfo['full_name'],
            'email'      => $userInfo['email'],
            'avatar_url' => $userInfo['avatar_url'],
            'xp'         => (int)($userInfo['total_xp'] ?? 0),
            'rank'       => $userInfo['current_rank'],
        ],
        'stats' => [
            'avg_score'          => round($avgScore, 2),
            'total_xp'           => (int)($userInfo['total_xp'] ?? 0),
            'current_streak'     => (int)($streak['current_streak'] ?? 0),
            'longest_streak'     => (int)($streak['longest_streak'] ?? 0),
            'graded_assignments' => (int)$scoreData['graded_count'],
            'exam_count'         => (int)($examData['exam_count'] ?? 0),
            'classes'            => $classes,
            'learning_progress'  => [
                'avg_progress' => $avgProgress,
            ],
        ],
    ]);

} catch (PDOException $e) {
    jsonError('Loi he thong', 500);
}
