<?php
/**
 * DOLY LMS - Admin: Xoa thong bao
 * POST /api/admin_notification_delete.php
 * Body: { auth_token, notification_id }
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
requireParams(['notification_id'], $body);

try {
    $db = getDB();

    $stmt = $db->prepare("DELETE FROM notifications WHERE id = ?");
    $stmt->execute([(int)$body['notification_id']]);

    if ($stmt->rowCount() === 0) {
        jsonError('Khong tim thay thong bao', 404);
    }

    jsonSuccess([], 'Xoa thong bao thanh cong');

} catch (PDOException $e) {
    jsonError('Loi he thong', 500);
}
