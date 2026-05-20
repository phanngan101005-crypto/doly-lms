<?php
/**
 * DOLY LMS - Danh sach lop
 * GET /api/class_list.php?auth_token=...
 * Hoc sinh: xem lop da tham gia
 * Giao vien: xem lop da tao
 * Admin: xem tat ca
 */

require_once __DIR__ . '/config.php';
require_once __DIR__ . '/helpers.php';
require_once __DIR__ . '/auth.php';

$user = authenticate();

try {
    $db = getDB();

    if ($user['role'] === 'student') {
        $stmt = $db->prepare('
            SELECT c.*, u.full_name as teacher_name
            FROM class_members cm
            JOIN classes c ON cm.class_id = c.id
            JOIN users u ON c.teacher_id = u.id
            WHERE cm.student_id = ? AND cm.status = \'active\'
            ORDER BY c.created_at DESC
        ');
        $stmt->execute([$user['id']]);
    } elseif ($user['role'] === 'teacher') {
        $stmt = $db->prepare('
            SELECT c.*, (SELECT COUNT(*) FROM class_members WHERE class_id = c.id AND status = \'active\') as member_count
            FROM classes c
            WHERE c.teacher_id = ?
            ORDER BY c.created_at DESC
        ');
        $stmt->execute([$user['id']]);
    } else {
        // Admin
        $stmt = $db->prepare('
            SELECT c.*, u.full_name as teacher_name,
                   (SELECT COUNT(*) FROM class_members WHERE class_id = c.id AND status = \'active\') as member_count
            FROM classes c
            JOIN users u ON c.teacher_id = u.id
            ORDER BY c.created_at DESC
        ');
        $stmt->execute();
    }

    $classes = $stmt->fetchAll();
    jsonSuccess($classes);
} catch (PDOException $e) {
    jsonError('Loi he thong', 500);
}
