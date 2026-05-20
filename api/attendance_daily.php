<?php
/**
 * DOLY LMS - Diem danh hang ngay
 * POST /api/attendance_daily.php
 * Body: { auth_token }
 */

require_once __DIR__ . '/config.php';
require_once __DIR__ . '/helpers.php';
require_once __DIR__ . '/auth.php';

if ($_SERVER['REQUEST_METHOD'] !== 'POST') jsonError('Chi ho tro POST', 405);

$user = authenticate();

try {
    $db = getDB();

    $today = date('Y-m-d');

    // Kiem tra da diem danh hom nay chua
    $stmt = $db->prepare('SELECT id FROM daily_attendance WHERE user_id = ? AND attendance_date = ?');
    $stmt->execute([$user['id'], $today]);
    if ($stmt->fetch()) {
        jsonError('Ban da diem danh hom nay', 409);
    }

    $db->beginTransaction();

    // Tinh XP thuong
    $xpEarned = 10;

    // Ghi nhan diem danh
    $stmt = $db->prepare('INSERT INTO daily_attendance (user_id, attendance_date, xp_earned, created_at) VALUES (?, ?, ?, NOW())');
    $stmt->execute([$user['id'], $today, $xpEarned]);

    // Cap nhat streak
    $stmt = $db->prepare('SELECT current_streak, longest_streak, last_active_date FROM user_streaks WHERE user_id = ?');
    $stmt->execute([$user['id']]);
    $streak = $stmt->fetch();

    $yesterday = date('Y-m-d', strtotime('-1 day'));
    $currentStreak = 1;
    $longestStreak = (int)($streak['longest_streak'] ?? 0);

    if ($streak && $streak['last_active_date'] === $yesterday) {
        $currentStreak = (int)$streak['current_streak'] + 1;
    }
    $longestStreak = max($longestStreak, $currentStreak);

    // Bonus XP cho streak
    if ($currentStreak >= 7) $xpEarned += 20;
    elseif ($currentStreak >= 3) $xpEarned += 10;

    $stmt = $db->prepare('UPDATE user_streaks SET current_streak = ?, longest_streak = ?, last_active_date = ?, updated_at = NOW() WHERE user_id = ?');
    $stmt->execute([$currentStreak, $longestStreak, $today, $user['id']]);

    // Ghi nhan XP
    $stmt = $db->prepare('INSERT INTO xp_transactions (user_id, amount, source, created_at) VALUES (?, ?, \'streak\', NOW())');
    $stmt->execute([$user['id'], $xpEarned]);

    $stmt = $db->prepare('UPDATE user_xp SET total_xp = total_xp + ?, updated_at = NOW() WHERE user_id = ?');
    $stmt->execute([$xpEarned, $user['id']]);

    $db->commit();

    jsonSuccess([
        'xp_earned'      => $xpEarned,
        'current_streak' => $currentStreak,
        'longest_streak' => $longestStreak,
    ], 'Diem danh thanh cong');
} catch (PDOException $e) {
    if ($db->inTransaction()) $db->rollBack();
    jsonError('Loi he thong', 500);
}
