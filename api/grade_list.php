<?php
/**
 * DOLY LMS - Bang diem
 * GET /api/grade_list.php?auth_token=...&class_id=...&student_id=...
 */

require_once __DIR__ . '/config.php';
require_once __DIR__ . '/helpers.php';
require_once __DIR__ . '/auth.php';

$user = authenticate();
$classId = (int)getParam('class_id', 0);

try {
    $db = getDB();

    if ($user['role'] === 'student') {
        // Hoc sinh xem diem cua minh
        $sql = '
            SELECT g.*, a.title as assignment_name, s.name as subject_name, c.name as class_name
            FROM grades g
            JOIN assignments a ON g.assignment_id = a.id
            JOIN subjects s ON g.subject_id = s.id
            JOIN classes c ON g.class_id = c.id
            WHERE g.student_id = ?';
        $params = [$user['id']];
        if ($classId > 0) {
            $sql .= ' AND g.class_id = ?';
            $params[] = $classId;
        }
        $sql .= ' ORDER BY g.graded_at DESC';
        $stmt = $db->prepare($sql);
        $stmt->execute($params);
    } elseif ($user['role'] === 'parent') {
        // Phu huynh xem diem cua con
        $stmt = $db->prepare('
            SELECT g.*, u.full_name as student_name, a.title as assignment_name, s.name as subject_name, c.name as class_name
            FROM grades g
            JOIN parent_student_links psl ON g.student_id = psl.student_id
            JOIN assignments a ON g.assignment_id = a.id
            JOIN subjects s ON g.subject_id = s.id
            JOIN classes c ON g.class_id = c.id
            JOIN users u ON g.student_id = u.id
            WHERE psl.parent_id = ? AND psl.status = \'active\'
            ORDER BY g.graded_at DESC
        ');
        $stmt->execute([$user['id']]);
    } else {
        // Giao vien / admin xem diem lop
        if ($classId <= 0) jsonError('Thieu class_id', 400);
        $stmt = $db->prepare('
            SELECT g.*, u.full_name as student_name, a.title as assignment_name, s.name as subject_name
            FROM grades g
            JOIN users u ON g.student_id = u.id
            JOIN assignments a ON g.assignment_id = a.id
            JOIN subjects s ON g.subject_id = s.id
            WHERE g.class_id = ?
            ORDER BY u.full_name, g.graded_at DESC
        ');
        $stmt->execute([$classId]);
    }

    $grades = $stmt->fetchAll();
    jsonSuccess($grades);
} catch (PDOException $e) {
    jsonError('Loi he thong', 500);
}
