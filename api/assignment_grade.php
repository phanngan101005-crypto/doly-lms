<?php
/**
 * DOLY LMS - Cham diem bai tap
 * POST /api/assignment_grade.php
 * Body: { auth_token, student_assignment_id, score, answers?: [{ id, score_earned, is_correct }] }
 */

require_once __DIR__ . '/config.php';
require_once __DIR__ . '/helpers.php';
require_once __DIR__ . '/auth.php';

if ($_SERVER['REQUEST_METHOD'] !== 'POST') jsonError('Chi ho tro POST', 405);

$user = authenticate();
requireRole(['teacher', 'admin'], $user);

$body = getJsonBody();
requireParams(['student_assignment_id', 'score'], $body);

$saId = (int)$body['student_assignment_id'];
$score = (float)$body['score'];

try {
    $db = getDB();

    // Kiem tra bai nop
    $stmt = $db->prepare('
        SELECT sa.*, a.class_id, a.title
        FROM student_assignments sa
        JOIN assignments a ON sa.assignment_id = a.id
        WHERE sa.id = ?
        LIMIT 1
    ');
    $stmt->execute([$saId]);
    $sa = $stmt->fetch();
    if (!$sa) jsonError('Khong tim thay bai nop', 404);

    $db->beginTransaction();

    // Cap nhat diem
    $stmt = $db->prepare('UPDATE student_assignments SET score = ?, status = \'graded\', graded_by = ?, graded_at = NOW() WHERE id = ?');
    $stmt->execute([$score, $user['id'], $saId]);

    // Cap nhat chi tiet (neu co)
    if (!empty($body['answers']) && is_array($body['answers'])) {
        foreach ($body['answers'] as $ans) {
            $stmt = $db->prepare('UPDATE student_answers SET is_correct = ?, score_earned = ? WHERE id = ?');
            $stmt->execute([
                !empty($ans['is_correct']) ? 1 : 0,
                isset($ans['score_earned']) ? (float)$ans['score_earned'] : null,
                (int)$ans['id'],
            ]);
        }
    }

    // Ghi vao bang diem tong hop
    $stmt = $db->prepare('SELECT subject_id FROM classes WHERE id = ?');
    $stmt->execute([$sa['class_id']]);
    $class = $stmt->fetch();

    if ($class && $class['subject_id']) {
        $stmt = $db->prepare('
            INSERT INTO grades (student_id, class_id, subject_id, assignment_id, score, max_score, graded_at)
            VALUES (?, ?, ?, ?, ?, 10.00, NOW())
            ON DUPLICATE KEY UPDATE score = VALUES(score), graded_at = NOW()
        ');
        $stmt->execute([$sa['student_id'], $sa['class_id'], $class['subject_id'], $sa['assignment_id'], $score]);
    }

    // Tinh XP
    $xpEarned = (int)($score * 2);
    $stmt = $db->prepare('INSERT INTO xp_transactions (user_id, amount, source, reference_id, created_at) VALUES (?, ?, \'assignment\', ?, NOW())');
    $stmt->execute([$sa['student_id'], $xpEarned, $sa['assignment_id']]);

    $stmt = $db->prepare('UPDATE user_xp SET total_xp = total_xp + ?, updated_at = NOW() WHERE user_id = ?');
    $stmt->execute([$xpEarned, $sa['student_id']]);

    $db->commit();
    jsonSuccess([], 'Cham diem thanh cong');
} catch (PDOException $e) {
    if ($db->inTransaction()) $db->rollBack();
    jsonError('Loi he thong', 500);
}
