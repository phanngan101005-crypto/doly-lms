<?php
/**
 * DOLY LMS - Danh sach bai tap
 * GET /api/assignment_list.php?auth_token=...&class_id=...
 */

require_once __DIR__ . '/config.php';
require_once __DIR__ . '/helpers.php';
require_once __DIR__ . '/auth.php';

$user = authenticate();
$classId = (int)getParam('class_id', 0);

try {
    $db = getDB();

    if ($user['role'] === 'student') {
        // Hoc sinh xem bai tap cua lop minh
        $sql = 'SELECT a.*, u.full_name as teacher_name
                FROM assignments a
                JOIN users u ON a.assigned_by = u.id
                JOIN class_members cm ON a.class_id = cm.class_id
                WHERE cm.student_id = ? AND cm.status = \'active\'';
        $params = [$user['id']];

        if ($classId > 0) {
            $sql .= ' AND a.class_id = ?';
            $params[] = $classId;
        }

        $sql .= ' ORDER BY a.created_at DESC';
        $stmt = $db->prepare($sql);
        $stmt->execute($params);
        $assignments = $stmt->fetchAll();

        // Kem theo trang thai nop bai
        foreach ($assignments as &$a) {
            $s = $db->prepare('SELECT status, score, submitted_at FROM student_assignments WHERE assignment_id = ? AND student_id = ? LIMIT 1');
            $s->execute([$a['id'], $user['id']]);
            $sub = $s->fetch();
            $a['submission'] = $sub ?: ['status' => 'not_submitted', 'score' => null, 'submitted_at' => null];
        }
    } else {
        // Giao vien / admin xem bai tap cua lop
        $sql = 'SELECT a.*, u.full_name as teacher_name
                FROM assignments a
                JOIN users u ON a.assigned_by = u.id
                WHERE 1=1';
        $params = [];

        if ($classId > 0) {
            $sql .= ' AND a.class_id = ?';
            $params[] = $classId;
        }
        if ($user['role'] === 'teacher') {
            $sql .= ' AND a.assigned_by = ?';
            $params[] = $user['id'];
        }

        $sql .= ' ORDER BY a.created_at DESC';
        $stmt = $db->prepare($sql);
        $stmt->execute($params);
        $assignments = $stmt->fetchAll();
    }

    jsonSuccess($assignments);
} catch (PDOException $e) {
    jsonError('Loi he thong', 500);
}
