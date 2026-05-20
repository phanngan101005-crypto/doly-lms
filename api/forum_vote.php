<?php
/**
 * DOLY LMS - Dien dan: Vote bai viet
 * POST /api/forum_vote.php
 * Body: { auth_token, post_id, vote_type: "up" | "down" }
 */

require_once __DIR__ . '/config.php';
require_once __DIR__ . '/helpers.php';
require_once __DIR__ . '/auth.php';

if ($_SERVER['REQUEST_METHOD'] !== 'POST') jsonError('Chi ho tro POST', 405);

$user = authenticate();

$body = getJsonBody();
requireParams(['post_id', 'vote_type'], $body);

$postId = (int)$body['post_id'];
$voteType = $body['vote_type'];

if (!in_array($voteType, ['up', 'down'])) jsonError('vote_type phai la "up" hoac "down"', 400);

try {
    $db = getDB();

    // Kiem tra bai viet ton tai
    $stmt = $db->prepare('SELECT id FROM forum_posts WHERE id = ?');
    $stmt->execute([$postId]);
    if (!$stmt->fetch()) jsonError('Khong tim thay bai viet', 404);

    // Upsert vote
    $stmt = $db->prepare('
        INSERT INTO forum_votes (post_id, user_id, vote_type, created_at)
        VALUES (?, ?, ?, NOW())
        ON DUPLICATE KEY UPDATE vote_type = VALUES(vote_type), created_at = NOW()
    ');
    $stmt->execute([$postId, $user['id'], $voteType]);

    jsonSuccess([], 'Vote thanh cong');
} catch (PDOException $e) {
    jsonError('Loi he thong', 500);
}
