<?php
/**
 * DOLY LMS - Lien ket phu huynh
 * POST /api/parent_link.php
 * Body: { auth_token, link_code } - Phu huynh nhap ma lien ket
 * POST /api/parent_link.php?action=generate
 * Body: { auth_token } - Hoc sinh tao ma lien ket
 */

require_once __DIR__ . '/config.php';
require_once __DIR__ . '/helpers.php';
require_once __DIR__ . '/auth.php';

if ($_SERVER['REQUEST_METHOD'] !== 'POST') jsonError('Chi ho tro POST', 405);

$user = authenticate();

$action = getParam('action', '');

try {
    $db = getDB();

    // Hoc sinh tao ma lien ket
    if ($action === 'generate') {
        requireRole(['student'], $user);

        // Kiem tra da co ma pending
        $stmt = $db->prepare('SELECT link_code FROM parent_student_links WHERE student_id = ? AND status = \'pending\' LIMIT 1');
        $stmt->execute([$user['id']]);
        $existing = $stmt->fetch();

        if ($existing) {
            jsonSuccess(['link_code' => $existing['link_code']], 'Ma lien ket hien tai');
        }

        $linkCode = strtoupper(substr(bin2hex(random_bytes(3)), 0, 6));

        $stmt = $db->prepare('INSERT INTO parent_student_links (student_id, link_code, status, linked_at) VALUES (?, ?, \'pending\', NOW())');
        $stmt->execute([$user['id'], $linkCode]);

        jsonSuccess(['link_code' => $linkCode], 'Tao ma lien ket thanh cong', 201);
    }

    // Phu huynh nhap ma lien ket
    $body = getJsonBody();
    requireParams(['link_code'], $body);

    requireRole(['parent'], $user);
    $linkCode = strtoupper(trim($body['link_code']));
    // Bo tien to PH- neu co
    if (strpos($linkCode, 'PH-') === 0) {
        $linkCode = substr($linkCode, 3);
    }

    $stmt = $db->prepare('SELECT * FROM parent_student_links WHERE link_code = ? AND status = \'pending\' LIMIT 1');
    $stmt->execute([$linkCode]);
    $link = $stmt->fetch();

    if (!$link) jsonError('Ma lien ket khong hop le hoac da duoc su dung', 404);

    $stmt = $db->prepare('UPDATE parent_student_links SET parent_id = ?, status = \'active\' WHERE id = ?');
    $stmt->execute([$user['id'], $link['id']]);

    jsonSuccess([], 'Lien ket phu huynh thanh cong');
} catch (PDOException $e) {
    jsonError('Loi he thong', 500);
}
