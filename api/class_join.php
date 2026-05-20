<?php
/**
 * DOLY LMS - Tham gia lop hoc bang ma moi
 * POST /api/class_join.php
 * Body: { auth_token, class_code }
 */

require_once __DIR__ . '/config.php';
require_once __DIR__ . '/helpers.php';
require_once __DIR__ . '/auth.php';

if ($_SERVER['REQUEST_METHOD'] !== 'POST') jsonError('Chi ho tro POST', 405);

$user = authenticate();
requireRole(['student'], $user);

$body = getJsonBody();
requireParams(['class_code'], $body);

$classCode = strtoupper(trim($body['class_code']));

try {
    $db = getDB();

    // Tim lop
    $stmt = $db->prepare('SELECT id, name, status FROM classes WHERE class_code = ? LIMIT 1');
    $stmt->execute([$classCode]);
    $class = $stmt->fetch();

    if (!$class) jsonError('Ma lop khong ton tai', 404);
    if ($class['status'] !== 'active') jsonError('Lop hoc da dong', 400);

    // Kiem tra da tham gia chua
    $stmt = $db->prepare('SELECT id FROM class_members WHERE class_id = ? AND student_id = ?');
    $stmt->execute([$class['id'], $user['id']]);
    if ($stmt->fetch()) jsonError('Ban da tham gia lop nay', 409);

    // Them thanh vien
    $stmt = $db->prepare('INSERT INTO class_members (class_id, student_id, joined_at, status) VALUES (?, ?, NOW(), \'active\')');
    $stmt->execute([$class['id'], $user['id']]);

    jsonSuccess([
        'class_id' => (int)$class['id'],
        'name'     => $class['name'],
    ], 'Tham gia lop thanh cong');
} catch (PDOException $e) {
    jsonError('Loi he thong', 500);
}
