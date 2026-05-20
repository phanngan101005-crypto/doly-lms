<?php
/**
 * DOLY LMS - Danh sach huy hieu
 * GET /api/achievement_list.php?auth_token=...
 */

require_once __DIR__ . '/config.php';
require_once __DIR__ . '/helpers.php';
require_once __DIR__ . '/auth.php';

$user = authenticate();

try {
    $db = getDB();

    // Tat ca huy hieu
    $stmt = $db->prepare('SELECT * FROM achievements ORDER BY xp_reward ASC');
    $stmt->execute();
    $all = $stmt->fetchAll();

    // Huy hieu nguoi dung da mo
    $stmt = $db->prepare('SELECT achievement_id, unlocked_at FROM user_achievements WHERE user_id = ?');
    $stmt->execute([$user['id']]);
    $unlocked = [];
    foreach ($stmt->fetchAll() as $ua) {
        $unlocked[$ua['achievement_id']] = $ua['unlocked_at'];
    }

    foreach ($all as &$ach) {
        $ach['unlocked'] = isset($unlocked[$ach['id']]);
        $ach['unlocked_at'] = $unlocked[$ach['id']] ?? null;
    }

    jsonSuccess([
        'achievements' => $all,
        'unlocked_count' => count($unlocked),
        'total_count' => count($all),
    ]);
} catch (PDOException $e) {
    jsonError('Loi he thong', 500);
}
