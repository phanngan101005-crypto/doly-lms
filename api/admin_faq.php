<?php
/**
 * DOLY LMS - FAQ (public)
 * GET /api/admin_faq.php?auth_token=... - Lay danh sach FAQ
 * POST /api/admin_faq.php?action=update - Cap nhat FAQ
 */

require_once __DIR__ . '/config.php';
require_once __DIR__ . '/helpers.php';
require_once __DIR__ . '/auth.php';

try {
    $db = getDB();

    // GET: Ai cung xem duoc
    if ($_SERVER['REQUEST_METHOD'] === 'GET') {
        $stmt = $db->prepare('SELECT * FROM faq ORDER BY order_index');
        $stmt->execute();
        jsonSuccess($stmt->fetchAll());
    }

    // POST: Chi admin
    $user = authenticate();
    requireRole(['admin'], $user);

    if ($_SERVER['REQUEST_METHOD'] === 'POST') {
        $body = getJsonBody();
        requireParams(['question', 'answer'], $body);

        if (!empty($body['id'])) {
            // Update
            $stmt = $db->prepare('UPDATE faq SET category = ?, question = ?, answer = ?, order_index = ? WHERE id = ?');
            $stmt->execute([
                $body['category'] ?? null,
                $body['question'],
                $body['answer'],
                (int)($body['order_index'] ?? 0),
                (int)$body['id'],
            ]);
        } else {
            // Insert
            $stmt = $db->prepare('INSERT INTO faq (category, question, answer, order_index) VALUES (?, ?, ?, ?)');
            $stmt->execute([
                $body['category'] ?? null,
                $body['question'],
                $body['answer'],
                (int)($body['order_index'] ?? 0),
            ]);
        }

        jsonSuccess([], 'Luu FAQ thanh cong');
    }

    jsonError('Phuong thuc khong ho tro', 405);
} catch (PDOException $e) {
    jsonError('Loi he thong', 500);
}
