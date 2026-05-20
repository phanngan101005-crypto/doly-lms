<?php
/**
 * DOLY LMS - Tao de kiem tra
 * POST /api/exam_create.php
 * Body: { auth_token, title, subject_id, time_limit?, max_score?, type?, questions: [{question_id, score}] }
 */

require_once __DIR__ . '/config.php';
require_once __DIR__ . '/helpers.php';
require_once __DIR__ . '/auth.php';

if ($_SERVER['REQUEST_METHOD'] !== 'POST') jsonError('Chi ho tro POST', 405);

$user = authenticate();
requireRole(['teacher', 'admin'], $user);

$body = getJsonBody();
requireParams(['title', 'subject_id'], $body);

try {
    $db = getDB();
    $db->beginTransaction();

    // Tao exam
    $stmt = $db->prepare('
        INSERT INTO exams (title, subject_id, created_by, time_limit, max_score, type, is_public, created_at)
        VALUES (?, ?, ?, ?, ?, ?, ?, NOW())
    ');
    $stmt->execute([
        $body['title'],
        (int)$body['subject_id'],
        $user['id'],
        !empty($body['time_limit']) ? (int)$body['time_limit'] : null,
        (float)($body['max_score'] ?? 10.00),
        $body['type'] ?? 'quiz',
        !empty($body['is_public']) ? 1 : 0,
    ]);
    $examId = (int)$db->lastInsertId();

    // Them cau hoi
    if (!empty($body['questions']) && is_array($body['questions'])) {
        foreach ($body['questions'] as $i => $q) {
            $stmt = $db->prepare('INSERT INTO exam_questions (exam_id, question_id, order_index, score) VALUES (?, ?, ?, ?)');
            $stmt->execute([$examId, (int)$q['question_id'], $i, (float)($q['score'] ?? 1.00)]);
        }
    }

    $db->commit();
    jsonSuccess(['exam_id' => $examId], 'Tao de kiem tra thanh cong', 201);
} catch (PDOException $e) {
    if ($db->inTransaction()) $db->rollBack();
    jsonError('Loi he thong', 500);
}
