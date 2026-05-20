<?php
/**
 * DOLY LMS - Authentication Middleware
 * Xac thuc token va lay thong tin user
 */

require_once __DIR__ . '/config.php';
require_once __DIR__ . '/helpers.php';

/**
 * Xac thuc auth_token tu header Authorization hoac request body
 * Tra ve mang user neu hop le
 */
function authenticate(): array {
    $token = '';

    // Lay tu header Authorization: Bearer <token>
    $authHeader = $_SERVER['HTTP_AUTHORIZATION'] ?? $_SERVER['REDIRECT_HTTP_AUTHORIZATION'] ?? '';
    if (preg_match('/Bearer\s+(.+)$/i', $authHeader, $m)) {
        $token = trim($m[1]);
    }

    // Fallback: lay tu request body hoac GET
    if (empty($token)) {
        $token = getParam('auth_token', '');
    }

    if (empty($token)) {
        jsonError('Thieu auth_token', 401);
    }

    try {
        $db = getDB();
        $stmt = $db->prepare('
            SELECT u.id, u.full_name, u.email, u.role, u.status, u.avatar_url,
                   s.expires_at as session_expires
            FROM user_sessions s
            JOIN users u ON s.user_id = u.id
            WHERE s.auth_token = ? AND s.expires_at > NOW()
            LIMIT 1
        ');
        $stmt->execute([$token]);
        $user = $stmt->fetch();

        if (!$user) {
            jsonError('auth_token khong hop le hoac da het han', 401);
        }
        if ($user['status'] !== 'active') {
            jsonError('Tai khoan da bi khoa', 403);
        }

        return $user;
    } catch (PDOException $e) {
        jsonError('Loi xac thuc', 500);
    }
}

/**
 * Kiem tra vai tro nguoi dung (role check)
 */
function requireRole(array $allowedRoles, array $user): void {
    if (!in_array($user['role'], $allowedRoles)) {
        jsonError('Ban khong co quyen thuc hien hanh dong nay', 403);
    }
}
