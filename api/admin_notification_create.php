<?php
/**
 * DOLY LMS - Admin: Tao thong bao
 * POST /api/admin_notification_create.php
 * Body: { auth_token, title, body, target_role }
 */

require_once __DIR__ . '/config.php';
require_once __DIR__ . '/helpers.php';
require_once __DIR__ . '/auth.php';

$user = authenticate();
requireRole(['admin'], $user);

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    jsonError('Chi ho tro POST', 405);
}

$body = getJsonBody();
requireParams(['title', 'target_role'], $body);

$allowedRoles = ['all', 'student', 'teacher', 'parent'];
if (!in_array($body['target_role'], $allowedRoles)) {
    jsonError('Doi tuong khong hop le', 400);
}

try {
    $db = getDB();

    $stmt = $db->prepare("
        INSERT INTO notifications (title, body, target_role, created_by, created_at, updated_at)
        VALUES (?, ?, ?, ?, NOW(), NOW())
    ");
    $stmt->execute([
        $body['title'],
        $body['body'] ?? null,
        $body['target_role'],
        $user['id'],
    ]);

    jsonSuccess([
        'notification_id' => (int)$db->lastInsertId(),
    ], 'Tao thong bao thanh cong', 201);

} catch (PDOException $e) {
    jsonError('Loi he thong', 500);
}
