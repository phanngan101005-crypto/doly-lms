<?php
/**
 * DOLY LMS - Phu huynh xem thong tin con
 * GET /api/parent_children.php?auth_token=...
 */

require_once __DIR__ . '/config.php';
require_once __DIR__ . '/helpers.php';
require_once __DIR__ . '/auth.php';

$user = authenticate();
requireRole(['parent'], $user);

try {
    $db = getDB();

    // Danh sach con
    $stmt = $db->prepare('
        SELECT u.id, u.full_name, u.email, u.avatar_url, psl.linked_at,
               ux.total_xp, ux.current_rank,
               us.current_streak
        FROM parent_student_links psl
        JOIN users u ON psl.student_id = u.id
        LEFT JOIN user_xp ux ON ux.user_id = u.id
        LEFT JOIN user_streaks us ON us.user_id = u.id
        WHERE psl.parent_id = ? AND psl.status = \'active\'
    ');
    $stmt->execute([$user['id']]);
    $children = $stmt->fetchAll();

    // Diem gan nhat cho moi con
    foreach ($children as &$child) {
        $s = $db->prepare('
            SELECT g.score, g.max_score, a.title, g.graded_at, s.name as subject_name
            FROM grades g
            JOIN assignments a ON g.assignment_id = a.id
            JOIN subjects s ON g.subject_id = s.id
            WHERE g.student_id = ?
            ORDER BY g.graded_at DESC
            LIMIT 5
        ');
        $s->execute([$child['id']]);
        $child['recent_grades'] = $s->fetchAll();
    }

    jsonSuccess(['children' => $children]);
} catch (PDOException $e) {
    jsonError('Loi he thong', 500);
}
