<?php
/**
 * DOLY LMS - Dang xuat
 * POST /api/logout.php
 * Auth token tu Bearer header (qua authenticate)
 */

require_once __DIR__ . '/config.php';
require_once __DIR__ . '/helpers.php';
require_once __DIR__ . '/auth.php';

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    jsonError('Chi ho tro POST', 405);
}

// Dung authenticate() de lay user tu Bearer header
$user = authenticate();

// Xoa session cua user nay
if (!empty($user)) {
    // Lay token tu header
    $authHeader = $_SERVER['HTTP_AUTHORIZATION'] ?? $_SERVER['REDIRECT_HTTP_AUTHORIZATION'] ?? '';
    $token = '';
    if (preg_match('/Bearer\s+(.+)$/i', $authHeader, $m)) {
        $token = trim($m[1]);
    } else {
        $token = getParam('auth_token', '');
    }

    try {
        $db = getDB();
        $stmt = $db->prepare('DELETE FROM user_sessions WHERE auth_token = ?');
        $stmt->execute([$token]);
        jsonSuccess([], 'Dang xuat thanh cong');
    } catch (PDOException $e) {
        jsonError('Loi he thong', 500);
    }
}

jsonSuccess([], 'Dang xuat thanh cong');
