<?php
/**
 * DOLY LMS - Dien dan: Bai viet
 * GET /api/forum_post.php?auth_token=...&topic_id=... - Danh sach bai viet
 * POST /api/forum_post.php - Tao bai viet moi
 */

require_once __DIR__ . '/config.php';
require_once __DIR__ . '/helpers.php';
require_once __DIR__ . '/auth.php';

$user = authenticate();

try {
    $db = getDB();

    // GET: Danh sach bai viet
    if ($_SERVER['REQUEST_METHOD'] === 'GET') {
        $topicId = (int)getParam('topic_id', 0);
        $search = getParam('search', '');

        $sql = 'SELECT fp.*, u.full_name, u.avatar_url, ft.name as topic_name,
                       (SELECT COUNT(*) FROM forum_comments WHERE post_id = fp.id) as comment_count,
                       (SELECT COUNT(*) FROM forum_votes WHERE post_id = fp.id AND vote_type = \'up\') as upvotes,
                       (SELECT COUNT(*) FROM forum_votes WHERE post_id = fp.id AND vote_type = \'down\') as downvotes
                FROM forum_posts fp
                JOIN users u ON fp.user_id = u.id
                LEFT JOIN forum_topics ft ON fp.topic_id = ft.id
                WHERE fp.status = \'approved\'';

        $params = [];
        if ($topicId > 0) { $sql .= ' AND fp.topic_id = ?'; $params[] = $topicId; }
        if (!empty($search)) { $sql .= ' AND (fp.title LIKE ? OR fp.content LIKE ?)'; $params[] = "%$search%"; $params[] = "%$search%"; }

        $sql .= ' ORDER BY fp.is_resolved ASC, fp.created_at DESC';
        $stmt = $db->prepare($sql);
        $stmt->execute($params);
        $posts = $stmt->fetchAll();

        // Lay danh sach topics
        $stmt = $db->prepare('SELECT * FROM forum_topics ORDER BY name');
        $stmt->execute();
        $topics = $stmt->fetchAll();

        jsonSuccess(['posts' => $posts, 'topics' => $topics]);
    }

    // POST: Tao bai viet
    if ($_SERVER['REQUEST_METHOD'] === 'POST') {
        $body = getJsonBody();
        requireParams(['title', 'content'], $body);

        $stmt = $db->prepare('
            INSERT INTO forum_posts (user_id, title, content, topic_id, status, view_count, created_at, updated_at)
            VALUES (?, ?, ?, ?, \'approved\', 0, NOW(), NOW())
        ');
        $stmt->execute([
            $user['id'],
            $body['title'],
            $body['content'],
            !empty($body['topic_id']) ? (int)$body['topic_id'] : null,
        ]);

        $postId = (int)$db->lastInsertId();

        // +XP cho dien dan
        $stmt = $db->prepare('INSERT INTO xp_transactions (user_id, amount, source, reference_id, created_at) VALUES (?, 5, \'forum\', ?, NOW())');
        $stmt->execute([$user['id'], $postId]);
        $stmt = $db->prepare('UPDATE user_xp SET total_xp = total_xp + 5, updated_at = NOW() WHERE user_id = ?');
        $stmt->execute([$user['id']]);

        jsonSuccess(['post_id' => $postId], 'Dang bai thanh cong', 201);
    }

    jsonError('Phuong thuc khong ho tro', 405);
} catch (PDOException $e) {
    jsonError('Loi he thong', 500);
}
