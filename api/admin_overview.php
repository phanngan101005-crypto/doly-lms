<?php
/**
 * DOLY LMS - Admin: Tong quan
 * POST /api/admin_overview.php
 * Body: { auth_token }
 * Returns: { totals, recent_notifications, recent_forum_posts, recent_grades }
 */

require_once __DIR__ . '/config.php';
require_once __DIR__ . '/helpers.php';
require_once __DIR__ . '/auth.php';

$user = authenticate();
requireRole(['admin'], $user);

try {
    $db = getDB();

    // Thong ke nguoi dung
    $stmt = $db->query("
        SELECT
            COUNT(*) as total_users,
            SUM(role = 'teacher') as total_teachers,
            SUM(role = 'student') as total_students,
            SUM(role = 'parent') as total_parents,
            SUM(role = 'admin') as total_admins
        FROM users
    ");
    $counts = $stmt->fetch();

    // So gia dinh da lien ket
    $stmt = $db->query("
        SELECT COUNT(DISTINCT parent_id) as linked_families
        FROM parent_student_links
        WHERE status = 'active'
    ");
    $familyCount = $stmt->fetch();

    $totals = [
        'users'           => (int)$counts['total_users'],
        'teachers'        => (int)$counts['total_teachers'],
        'students'        => (int)$counts['total_students'],
        'parents'         => (int)$counts['total_parents'],
        'admins'          => (int)$counts['total_admins'],
        'linked_families' => (int)$familyCount['linked_families'],
    ];

    // Thong bao gan day (5 cai)
    $stmt = $db->prepare("
        SELECT id, title, body, target_role, created_at
        FROM notifications
        ORDER BY created_at DESC
        LIMIT 5
    ");
    $stmt->execute();
    $recentNotifications = $stmt->fetchAll();

    // Bai dien dan gan day (5 cai)
    $stmt = $db->prepare("
        SELECT fp.id, u.full_name as author_name, ft.name as topic_title,
               LEFT(fp.content, 120) as content
        FROM forum_posts fp
        JOIN users u ON fp.user_id = u.id
        LEFT JOIN forum_topics ft ON fp.topic_id = ft.id
        WHERE fp.status != 'deleted'
        ORDER BY fp.created_at DESC
        LIMIT 5
    ");
    $stmt->execute();
    $recentForumPosts = $stmt->fetchAll();

    // Diem gan day (10 cai)
    $stmt = $db->prepare("
        SELECT g.id, u.full_name as student_name, s.name as subject_name,
               g.score, g.max_score, g.graded_at
        FROM grades g
        JOIN users u ON g.student_id = u.id
        JOIN subjects s ON g.subject_id = s.id
        ORDER BY g.graded_at DESC
        LIMIT 10
    ");
    $stmt->execute();
    $recentGrades = $stmt->fetchAll();

    jsonSuccess([
        'totals'               => $totals,
        'recent_notifications' => $recentNotifications,
        'recent_forum_posts'   => $recentForumPosts,
        'recent_grades'        => $recentGrades,
    ]);

} catch (PDOException $e) {
    jsonError('Loi he thong', 500);
}
