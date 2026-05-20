<?php
/**
 * DOLY LMS - Danh sach thanh vien lop
 * GET /api/class_members.php?auth_token=...&class_id=...
 */

require_once __DIR__ . '/config.php';
require_once __DIR__ . '/helpers.php';
require_once __DIR__ . '/auth.php';

$user = authenticate();
$classId = (int)getParam('class_id', 0);
if ($classId <= 0) jsonError('Thieu class_id', 400);

try {
    $db = getDB();

    // Kiem tra quyen truy cap
    if ($user['role'] === 'student') {
        $stmt = $db->prepare('SELECT id FROM class_members WHERE class_id = ? AND student_id = ? AND status = \'active\'');
        $stmt->execute([$classId, $user['id']]);
        if (!$stmt->fetch()) jsonError('Ban khong phai thanh vien lop nay', 403);
    }

    // Lay thong tin lop
    $stmt = $db->prepare('SELECT * FROM classes WHERE id = ?');
    $stmt->execute([$classId]);
    $class = $stmt->fetch();
    if (!$class) jsonError('Khong tim thay lop', 404);

    // Danh sach hoc sinh
    $stmt = $db->prepare('
        SELECT u.id, u.full_name, u.email, u.avatar_url, cm.joined_at, cm.status
        FROM class_members cm
        JOIN users u ON cm.student_id = u.id
        WHERE cm.class_id = ?
        ORDER BY cm.joined_at ASC
    ');
    $stmt->execute([$classId]);
    $members = $stmt->fetchAll();

    jsonSuccess([
        'class'   => $class,
        'members' => $members,
        'count'   => count($members),
    ]);
} catch (PDOException $e) {
    jsonError('Loi he thong', 500);
}
