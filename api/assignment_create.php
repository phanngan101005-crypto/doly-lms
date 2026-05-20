<?php
/**
 * DOLY LMS - Giao bai tap
 * POST /api/assignment_create.php
 * Body: { auth_token, class_id, exam_id?, title, due_date? }
 */

require_once __DIR__ . '/config.php';
require_once __DIR__ . '/helpers.php';
require_once __DIR__ . '/auth.php';

if ($_SERVER['REQUEST_METHOD'] !== 'POST') jsonError('Chi ho tro POST', 405);

$user = authenticate();
requireRole(['teacher', 'admin'], $user);

$body = getJsonBody();
requireParams(['class_id', 'title'], $body);

try {
    $db = getDB();
    $stmt = $db->prepare('
        INSERT INTO assignments (class_id, exam_id, title, assigned_by, due_date, status, created_at)
        VALUES (?, ?, ?, ?, ?, \'published\', NOW())
    ');
    $stmt->execute([
        (int)$body['class_id'],
        !empty($body['exam_id']) ? (int)$body['exam_id'] : null,
        $body['title'],
        $user['id'],
        !empty($body['due_date']) ? $body['due_date'] : null,
    ]);

    jsonSuccess(['assignment_id' => (int)$db->lastInsertId()], 'Giao bai thanh cong', 201);
} catch (PDOException $e) {
    jsonError('Loi he thong', 500);
}
