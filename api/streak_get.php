<?php
/**
 * DOLY LMS - Get streak
 * GET /api/streak_get.php?auth_token=...
 */

require_once __DIR__ . '/config.php';
require_once __DIR__ . '/helpers.php';
require_once __DIR__ . '/auth.php';

$user = authenticate();

try {
    $db = getDB();

    $stmt = $db->prepare('SELECT current_streak, longest_streak, last_active_date FROM user_streaks WHERE user_id = ?');
    $stmt->execute([$user['id']]);
    $streak = $stmt->fetch();

    // 7 ngay gan nhat
    $stmt = $db->prepare('SELECT attendance_date, xp_earned FROM daily_attendance WHERE user_id = ? ORDER BY attendance_date DESC LIMIT 7');
    $stmt->execute([$user['id']]);
    $attendance = $stmt->fetchAll();

    jsonSuccess([
        'streak'     => $streak ?: ['current_streak' => 0, 'longest_streak' => 0, 'last_active_date' => null],
        'attendance' => $attendance,
    ]);
} catch (PDOException $e) {
    jsonError('Loi he thong', 500);
}
