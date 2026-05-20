<?php
/**
 * DOLY LMS - Ngan hang cau hoi
 * GET /api/question_bank.php?auth_token=...&subject_id=...&type=...
 * POST /api/question_bank.php - Tao cau hoi moi
 */

require_once __DIR__ . '/config.php';
require_once __DIR__ . '/helpers.php';
require_once __DIR__ . '/auth.php';

$user = authenticate();

try {
    $db = getDB();

    // GET: Lay danh sach cau hoi
    if ($_SERVER['REQUEST_METHOD'] === 'GET') {
        $subjectId = (int)getParam('subject_id', 0);
        $type = getParam('type', '');
        $lessonId = (int)getParam('lesson_id', 0);

        $sql = 'SELECT qb.*, s.name as subject_name FROM question_bank qb JOIN subjects s ON qb.subject_id = s.id WHERE 1=1';
        $params = [];

        if ($subjectId > 0) { $sql .= ' AND qb.subject_id = ?'; $params[] = $subjectId; }
        if (!empty($type)) { $sql .= ' AND qb.question_type = ?'; $params[] = $type; }
        if ($lessonId > 0) { $sql .= ' AND qb.lesson_id = ?'; $params[] = $lessonId; }

        $sql .= ' ORDER BY qb.created_at DESC';

        $stmt = $db->prepare($sql);
        $stmt->execute($params);
        $questions = $stmt->fetchAll();

        // Lay dap an kem theo
        foreach ($questions as &$q) {
            if ($q['question_type'] === 'multiple_choice' || $q['question_type'] === 'true_false') {
                $s = $db->prepare('SELECT * FROM question_options WHERE question_id = ? ORDER BY order_index');
                $s->execute([$q['id']]);
                $q['options'] = $s->fetchAll();
            } elseif ($q['question_type'] === 'fill_blank') {
                $s = $db->prepare('SELECT * FROM fill_blank_answers WHERE question_id = ? ORDER BY position');
                $s->execute([$q['id']]);
                $q['answers'] = $s->fetchAll();
            } elseif ($q['question_type'] === 'matching') {
                $s = $db->prepare('SELECT * FROM matching_pairs WHERE question_id = ?');
                $s->execute([$q['id']]);
                $q['pairs'] = $s->fetchAll();
            }
        }

        jsonSuccess($questions);
    }

    // POST: Tao cau hoi moi
    if ($_SERVER['REQUEST_METHOD'] === 'POST') {
        requireRole(['teacher', 'admin'], $user);

        $body = getJsonBody();
        requireParams(['subject_id', 'question_text', 'question_type'], $body);

        $type = $body['question_type'];
        $allowedTypes = ['multiple_choice', 'true_false', 'fill_blank', 'matching'];
        if (!in_array($type, $allowedTypes)) jsonError('Loai cau hoi khong hop le', 400);

        $db->beginTransaction();

        $stmt = $db->prepare('
            INSERT INTO question_bank (subject_id, lesson_id, question_text, question_type, difficulty, xp_reward, explanation, created_by, status, created_at)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, \'active\', NOW())
        ');
        $stmt->execute([
            (int)$body['subject_id'],
            !empty($body['lesson_id']) ? (int)$body['lesson_id'] : null,
            $body['question_text'],
            $type,
            $body['difficulty'] ?? 'medium',
            (int)($body['xp_reward'] ?? 10),
            $body['explanation'] ?? null,
            $user['id'],
        ]);
        $questionId = (int)$db->lastInsertId();

        // Luu dap an theo loai
        if (in_array($type, ['multiple_choice', 'true_false']) && isset($body['options'])) {
            foreach ($body['options'] as $i => $opt) {
                $s = $db->prepare('INSERT INTO question_options (question_id, option_text, is_correct, order_index) VALUES (?, ?, ?, ?)');
                $s->execute([$questionId, $opt['text'], !empty($opt['is_correct']) ? 1 : 0, $i]);
            }
        } elseif ($type === 'fill_blank' && isset($body['answers'])) {
            foreach ($body['answers'] as $ans) {
                $s = $db->prepare('INSERT INTO fill_blank_answers (question_id, correct_answer, position) VALUES (?, ?, ?)');
                $s->execute([$questionId, $ans['correct_answer'], $ans['position'] ?? 1]);
            }
        } elseif ($type === 'matching' && isset($body['pairs'])) {
            foreach ($body['pairs'] as $pair) {
                $s = $db->prepare('INSERT INTO matching_pairs (question_id, left_text, right_text) VALUES (?, ?, ?)');
                $s->execute([$questionId, $pair['left_text'], $pair['right_text']]);
            }
        }

        $db->commit();
        jsonSuccess(['question_id' => $questionId], 'Tao cau hoi thanh cong', 201);
    }

    jsonError('Phuong thuc khong ho tro', 405);
} catch (PDOException $e) {
    if ($db->inTransaction()) $db->rollBack();
    jsonError('Loi he thong', 500);
}
