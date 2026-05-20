<?php
/**
 * DOLY LMS - Tin tuc (public GET)
 * GET /api/admin_news.php - Lay danh sach (public)
 * POST /api/admin_news.php - Tao bai moi (admin)
 */

require_once __DIR__ . '/config.php';
require_once __DIR__ . '/helpers.php';
require_once __DIR__ . '/auth.php';

try {
    $db = getDB();

    // GET: Ai cung xem duoc
    if ($_SERVER['REQUEST_METHOD'] === 'GET') {
        $stmt = $db->prepare("
            SELECT n.*, u.full_name as author_name
            FROM news n
            JOIN users u ON n.created_by = u.id
            WHERE n.status = 'published'
            ORDER BY n.is_pinned DESC, n.created_at DESC
        ");
        $stmt->execute();
        jsonSuccess($stmt->fetchAll());
    }

    // POST: Chi admin
    $user = authenticate();
    requireRole(['admin'], $user);

    if ($_SERVER['REQUEST_METHOD'] === 'POST') {
        $body = getJsonBody();
        requireParams(['title', 'content'], $body);

        $stmt = $db->prepare('
            INSERT INTO news (title, content, thumbnail_url, category, is_pinned, status, created_by, published_at, created_at)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, NOW())
        ');
        $stmt->execute([
            $body['title'],
            $body['content'],
            $body['thumbnail_url'] ?? null,
            $body['category'] ?? null,
            !empty($body['is_pinned']) ? 1 : 0,
            $body['status'] ?? 'draft',
            $user['id'],
            !empty($body['status']) && $body['status'] === 'published' ? date('Y-m-d H:i:s') : null,
        ]);

        jsonSuccess(['news_id' => (int)$db->lastInsertId()], 'Tao tin tuc thanh cong', 201);
    }

    jsonError('Phuong thuc khong ho tro', 405);
} catch (PDOException $e) {
    jsonError('Loi he thong', 500);
}
