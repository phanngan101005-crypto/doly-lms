<?php
/**
 * DOLY LMS - Admin: Xoa bai viet dien dan
 * POST /api/admin_forum_post_delete.php
 * Body: { auth_token, post_id }
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
requireParams(['post_id'], $body);

$postId = (int)$body['post_id'];

try {
    $db = getDB();

    // Soft delete: dat status = 'deleted'
    $stmt = $db->prepare("UPDATE forum_posts SET status = 'deleted', updated_at = NOW() WHERE id = ?");
    $stmt->execute([$postId]);

    if ($stmt->rowCount() === 0) {
        jsonError('Khong tim thay bai viet', 404);
    }

    jsonSuccess([], 'Xoa bai viet thanh cong');

} catch (PDOException $e) {
    jsonError('Loi he thong', 500);
}
