<?php
/**
 * DOLY LMS - Dang ky
 * POST /api/register.php
 * Body: { full_name, email, password, role }
 */

require_once __DIR__ . '/config.php';
require_once __DIR__ . '/helpers.php';

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    jsonError('Chi ho tro POST', 405);
}

$body = getJsonBody();
requireParams(['full_name', 'email', 'password', 'role'], $body);

$fullName  = trim($body['full_name']);
$email     = trim($body['email']);
$password  = $body['password'];
$role      = $body['role'];

// Validate role
$allowedRoles = ['student', 'teacher', 'parent'];
if (!in_array($role, $allowedRoles)) {
    jsonError('Vai tro khong hop le', 400);
}

// Validate email
if (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
    jsonError('Email khong hop le', 400);
}

// Validate password length
if (strlen($password) < 6) {
    jsonError('Mat khau phai co it nhat 6 ky tu', 400);
}

try {
    $db = getDB();

    // Kiem tra email da ton tai
    $stmt = $db->prepare('SELECT id FROM users WHERE email = ? LIMIT 1');
    $stmt->execute([$email]);
    if ($stmt->fetch()) {
        jsonError('Email nay da duoc dang ky', 409);
    }

    // Tao tai khoan
    $hash = password_hash($password, PASSWORD_BCRYPT);
    $stmt = $db->prepare('
        INSERT INTO users (full_name, email, password_hash, role, status, created_at, updated_at)
        VALUES (?, ?, ?, ?, \'active\', NOW(), NOW())
    ');
    $stmt->execute([$fullName, $email, $hash, $role]);

    $userId = (int)$db->lastInsertId();

    // Tao session token
    $token = bin2hex(random_bytes(64));
    $expiresAt = date('Y-m-d H:i:s', strtotime('+7 days'));
    $stmt = $db->prepare('INSERT INTO user_sessions (user_id, auth_token, expires_at) VALUES (?, ?, ?)');
    $stmt->execute([$userId, $token, $expiresAt]);

    // Khoi tao bang XP va Streak
    $stmt = $db->prepare('INSERT INTO user_xp (user_id, total_xp, updated_at) VALUES (?, 0, NOW())');
    $stmt->execute([$userId]);

    $stmt = $db->prepare('INSERT INTO user_streaks (user_id, current_streak, longest_streak, updated_at) VALUES (?, 0, 0, NOW())');
    $stmt->execute([$userId]);

    jsonSuccess([
        'user_id'    => $userId,
        'full_name'  => $fullName,
        'email'      => $email,
        'role'       => $role,
        'auth_token' => $token,
        'expires_at' => $expiresAt,
    ], 'Dang ky thanh cong', 201);

} catch (PDOException $e) {
    jsonError('Loi he thong', 500);
}
