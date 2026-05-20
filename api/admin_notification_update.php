<?php
/**
 * DOLY LMS - Admin: Cap nhat thong bao
 * POST /api/admin_notification_update.php
 * Body: { auth_token, notification_id, title, body, target_role }
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
requireParams(['notification_id', 'title', 'body', 'target_role'], $body);

$allowedRoles = ['all', 'student', 'teacher', 'parent'];
if (!in_array($body['target_role'], $allowedRoles)) {
    jsonError('Doi tuong khong hop le', 400);
}

try {
    $db = getDB();

    $stmt = $db->prepare("
        UPDATE notifications
        SET title = ?, body = ?, target_role = ?, updated_at = NOW()
        WHERE id = ? AND created_by = ?
    ");
    $stmt->execute([
        $body['title'],
        $body['body'],
        $body['target_role'],
        (int)$body['notification_id'],
        $user['id'],
    ]);

    if ($stmt->rowCount() === 0) {
        jsonError('Khong tim thay thong bao', 404);
    }

    jsonSuccess([], 'Cap nhat thong bao thanh cong');

} catch (PDOException $e) {
    jsonError('Loi he thong', 500);
}
