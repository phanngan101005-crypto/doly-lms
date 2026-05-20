<?php
/**
 * DOLY LMS - Lam bai kiem tra
 * GET /api/exam_take.php?auth_token=...&exam_id=...
 * Tra ve cau hoi + dap an (an dap an dung)
 */

require_once __DIR__ . '/config.php';
require_once __DIR__ . '/helpers.php';
require_once __DIR__ . '/auth.php';

$user = authenticate();
$examId = (int)getParam('exam_id', 0);
if ($examId <= 0) jsonError('Thieu exam_id', 400);

try {
    $db = getDB();

    // Thong tin de thi
    $stmt = $db->prepare('
        SELECT e.*, s.name as subject_name, u.full_name as creator_name
        FROM exams e
        JOIN subjects s ON e.subject_id = s.id
        JOIN users u ON e.created_by = u.id
        WHERE e.id = ?
        LIMIT 1
    ');
    $stmt->execute([$examId]);
    $exam = $stmt->fetch();
    if (!$exam) jsonError('Khong tim thay de thi', 404);

    // Danh sach cau hoi (an dap an dung)
    $stmt = $db->prepare('
        SELECT eq.id as eq_id, eq.order_index, eq.score,
               qb.id as question_id, qb.question_text, qb.question_type, qb.difficulty, qb.xp_reward
        FROM exam_questions eq
        JOIN question_bank qb ON eq.question_id = qb.id
        WHERE eq.exam_id = ?
        ORDER BY eq.order_index
    ');
    $stmt->execute([$examId]);
    $questions = $stmt->fetchAll();

    foreach ($questions as &$q) {
        $qId = $q['question_id'];

        // Lay options (an dap an dung)
        if (in_array($q['question_type'], ['multiple_choice', 'true_false'])) {
            $s = $db->prepare('SELECT id as option_id, option_text, order_index FROM question_options WHERE question_id = ? ORDER BY order_index');
            $s->execute([$qId]);
            $q['options'] = $s->fetchAll();
        } elseif ($q['question_type'] === 'fill_blank') {
            $s = $db->prepare('SELECT DISTINCT position FROM fill_blank_answers WHERE question_id = ? ORDER BY position');
            $s->execute([$qId]);
            $q['blank_positions'] = array_column($s->fetchAll(), 'position');
        } elseif ($q['question_type'] === 'matching') {
            // Xao tron
            $s = $db->prepare('SELECT id as pair_id, left_text, right_text FROM matching_pairs WHERE question_id = ?');
            $s->execute([$qId]);
            $pairs = $s->fetchAll();

            $rightTexts = array_column($pairs, 'right_text');
            shuffle($rightTexts);

            $q['pairs'] = $pairs;
            $q['shuffled_rights'] = $rightTexts;
        }
    }

    jsonSuccess([
        'exam'      => $exam,
        'questions' => $questions,
        'total'     => count($questions),
    ]);
} catch (PDOException $e) {
    jsonError('Loi he thong', 500);
}
