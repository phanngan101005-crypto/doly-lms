<?php
/**
 * DOLY LMS - Get user XP & Rank
 * GET /api/xp_get.php?auth_token=...
 */

require_once __DIR__ . '/config.php';
require_once __DIR__ . '/helpers.php';
require_once __DIR__ . '/auth.php';

$user = authenticate();

try {
    $db = getDB();

    $stmt = $db->prepare('SELECT total_xp, current_rank, updated_at FROM user_xp WHERE user_id = ?');
    $stmt->execute([$user['id']]);
    $xp = $stmt->fetch();

    // Lich su giao dich gan nhat
    $stmt = $db->prepare('SELECT * FROM xp_transactions WHERE user_id = ? ORDER BY created_at DESC LIMIT 20');
    $stmt->execute([$user['id']]);
    $history = $stmt->fetchAll();

    // Bang xep hang (top 20)
    $stmt = $db->prepare('
        SELECT u.id, u.full_name, u.avatar_url, ux.total_xp, ux.current_rank,
               RANK() OVER (ORDER BY ux.total_xp DESC) as ranking
        FROM user_xp ux
        JOIN users u ON ux.user_id = u.id
        ORDER BY ux.total_xp DESC
        LIMIT 20
    ');
    $stmt->execute();
    $leaderboard = $stmt->fetchAll();

    jsonSuccess([
        'xp'          => $xp ?: ['total_xp' => 0, 'current_rank' => null],
        'history'     => $history,
        'leaderboard' => $leaderboard,
    ]);
} catch (PDOException $e) {
    jsonError('Loi he thong', 500);
}
