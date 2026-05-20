<?php
/**
 * DOLY LMS - Dang nhap
 * POST /api/login.php
 * Body: { email, password, role }
 */

require_once __DIR__ . '/config.php';
require_once __DIR__ . '/helpers.php';

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    jsonError('Chi ho tro POST', 405);
}

$body = getJsonBody();
requireParams(['email', 'password', 'role'], $body);

$email    = trim($body['email']);
$password = $body['password'];
$role     = $body['role'];

// Validate role
$allowedRoles = ['student', 'teacher', 'parent', 'admin'];
if (!in_array($role, $allowedRoles)) {
    jsonError('Vai tro khong hop le', 400);
}

try {
    $db = getDB();

    // Tim user
    $stmt = $db->prepare('SELECT * FROM users WHERE email = ? AND role = ? LIMIT 1');
    $stmt->execute([$email, $role]);
    $user = $stmt->fetch();

    if (!$user) {
        jsonError('Email hoac mat khau khong dung', 401);
    }

    // Kiem tra trang thai
    if ($user['status'] !== 'active') {
        jsonError('Tai khoan cua ban da bi khoa', 403);
    }

    // Kiem tra mat khau
    if (!password_verify($password, $user['password_hash'])) {
        jsonError('Email hoac mat khau khong dung', 401);
    }

    // Tao session token
    $token = bin2hex(random_bytes(64));
    $expiresAt = date('Y-m-d H:i:s', strtotime('+7 days'));

    $stmt = $db->prepare('INSERT INTO user_sessions (user_id, auth_token, expires_at) VALUES (?, ?, ?)');
    $stmt->execute([$user['id'], $token, $expiresAt]);

    // Cap nhat last_login
    $stmt = $db->prepare('UPDATE users SET last_login = NOW() WHERE id = ?');
    $stmt->execute([$user['id']]);

    jsonSuccess([
        'user_id'    => (int)$user['id'],
        'full_name'  => $user['full_name'],
        'email'      => $user['email'],
        'role'       => $user['role'],
        'avatar_url' => $user['avatar_url'],
        'auth_token' => $token,
        'expires_at' => $expiresAt,
    ], 'Dang nhap thanh cong');

} catch (PDOException $e) {
    jsonError('Loi he thong', 500);
}
