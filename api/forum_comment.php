<?php
/**
 * DOLY LMS - Dien dan: Binh luan
 * GET /api/forum_comment.php?auth_token=...&post_id=... - Danh sach binh luan
 * POST /api/forum_comment.php - Them binh luan
 */

require_once __DIR__ . '/config.php';
require_once __DIR__ . '/helpers.php';
require_once __DIR__ . '/auth.php';

$user = authenticate();

try {
    $db = getDB();

    // GET
    if ($_SERVER['REQUEST_METHOD'] === 'GET') {
        $postId = (int)getParam('post_id', 0);
        if ($postId <= 0) jsonError('Thieu post_id', 400);

        // Tang view
        $stmt = $db->prepare('UPDATE forum_posts SET view_count = view_count + 1 WHERE id = ?');
        $stmt->execute([$postId]);

        // Lay binh luan
        $stmt = $db->prepare('
            SELECT fc.*, u.full_name, u.avatar_url
            FROM forum_comments fc
            JOIN users u ON fc.user_id = u.id
            WHERE fc.post_id = ?
            ORDER BY fc.is_best_answer DESC, fc.created_at ASC
        ');
        $stmt->execute([$postId]);
        $comments = $stmt->fetchAll();

        // Lay thong tin bai viet
        $stmt = $db->prepare('
            SELECT fp.*, u.full_name, u.avatar_url, ft.name as topic_name
            FROM forum_posts fp
            JOIN users u ON fp.user_id = u.id
            LEFT JOIN forum_topics ft ON fp.topic_id = ft.id
            WHERE fp.id = ?
        ');
        $stmt->execute([$postId]);
        $post = $stmt->fetch();

        jsonSuccess(['post' => $post, 'comments' => $comments]);
    }

    // POST
    if ($_SERVER['REQUEST_METHOD'] === 'POST') {
        $body = getJsonBody();
        requireParams(['post_id', 'content'], $body);

        $stmt = $db->prepare('INSERT INTO forum_comments (post_id, user_id, content, created_at) VALUES (?, ?, ?, NOW())');
        $stmt->execute([(int)$body['post_id'], $user['id'], $body['content']]);

        $commentId = (int)$db->lastInsertId();

        // +XP
        $stmt = $db->prepare('INSERT INTO xp_transactions (user_id, amount, source, reference_id, created_at) VALUES (?, 2, \'forum\', ?, NOW())');
        $stmt->execute([$user['id'], $commentId]);
        $stmt = $db->prepare('UPDATE user_xp SET total_xp = total_xp + 2, updated_at = NOW() WHERE user_id = ?');
        $stmt->execute([$user['id']]);

        jsonSuccess(['comment_id' => $commentId], 'Binh luan thanh cong', 201);
    }

    jsonError('Phuong thuc khong ho tro', 405);
} catch (PDOException $e) {
    jsonError('Loi he thong', 500);
}
