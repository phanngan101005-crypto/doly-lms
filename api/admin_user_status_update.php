<?php
/**
 * DOLY LMS - Admin: Cap nhat trang thai nguoi dung
 * POST /api/admin_user_status_update.php
 * Body: { auth_token, target_user_id, status }
 * status: 'active' | 'inactive' | 'banned'
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
requireParams(['target_user_id', 'status'], $body);

$targetUserId = (int)$body['target_user_id'];
$status = $body['status'];

$allowedStatuses = ['active', 'inactive', 'banned'];
if (!in_array($status, $allowedStatuses)) {
    jsonError('Trang thai khong hop le', 400);
}

try {
    $db = getDB();

    // Khong cho admin tu khoa chinh minh
    if ($targetUserId === (int)$user['id']) {
        jsonError('Khong the thay doi trang thai cua chinh ban', 403);
    }

    $stmt = $db->prepare('UPDATE users SET status = ?, updated_at = NOW() WHERE id = ?');
    $stmt->execute([$status, $targetUserId]);

    if ($stmt->rowCount() === 0) {
        jsonError('Khong tim thay nguoi dung', 404);
    }

    jsonSuccess([], 'Cap nhat trang thai thanh cong');

} catch (PDOException $e) {
    jsonError('Loi he thong', 500);
}
