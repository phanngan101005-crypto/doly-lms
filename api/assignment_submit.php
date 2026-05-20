<?php
/**
 * DOLY LMS - Nop bai tap
 * POST /api/assignment_submit.php
 * Body: { auth_token, assignment_id, answers: [{ question_id, selected_option_id?, answer_text?, ... }] }
 */

require_once __DIR__ . '/config.php';
require_once __DIR__ . '/helpers.php';
require_once __DIR__ . '/auth.php';

if ($_SERVER['REQUEST_METHOD'] !== 'POST') jsonError('Chi ho tro POST', 405);

$user = authenticate();
requireRole(['student'], $user);

$body = getJsonBody();
requireParams(['assignment_id'], $body);

$assignId = (int)$body['assignment_id'];

try {
    $db = getDB();

    // Kiem tra bai tap
    $stmt = $db->prepare('SELECT a.*, e.id as exam_id FROM assignments a LEFT JOIN exams e ON a.exam_id = e.id WHERE a.id = ? LIMIT 1');
    $stmt->execute([$assignId]);
    $assign = $stmt->fetch();
    if (!$assign) jsonError('Khong tim thay bai tap', 404);

    // Kiem tra da nop chua
    $stmt = $db->prepare('SELECT id FROM student_assignments WHERE assignment_id = ? AND student_id = ?');
    $stmt->execute([$assignId, $user['id']]);
    if ($stmt->fetch()) jsonError('Ban da nop bai tap nay', 409);

    // Xac dinh trang thai
    $status = 'submitted';
    if ($assign['due_date'] && strtotime($assign['due_date']) < time()) {
        $status = 'late';
    }

    $db->beginTransaction();

    // Tao student_assignment
    $stmt = $db->prepare('INSERT INTO student_assignments (assignment_id, student_id, submitted_at, status) VALUES (?, ?, NOW(), ?)');
    $stmt->execute([$assignId, $user['id'], $status]);
    $saId = (int)$db->lastInsertId();

    // Luu cau tra loi (neu co)
    if (!empty($body['answers']) && is_array($body['answers'])) {
        foreach ($body['answers'] as $ans) {
            $stmt = $db->prepare('
                INSERT INTO student_answers (student_assignment_id, question_id, answer_text, selected_option_id, fill_blank_answers)
                VALUES (?, ?, ?, ?, ?)
            ');
            $stmt->execute([
                $saId,
                (int)($ans['question_id'] ?? 0),
                $ans['answer_text'] ?? null,
                !empty($ans['selected_option_id']) ? (int)$ans['selected_option_id'] : null,
                !empty($ans['fill_blank_answers']) ? (is_string($ans['fill_blank_answers']) ? $ans['fill_blank_answers'] : json_encode($ans['fill_blank_answers'])) : null,
            ]);
        }
    }

    $db->commit();
    jsonSuccess(['student_assignment_id' => $saId], 'Nop bai thanh cong');
} catch (PDOException $e) {
    if ($db->inTransaction()) $db->rollBack();
    jsonError('Loi he thong', 500);
}
