<?php
/**
 * DOLY LMS - Nop bai kiem tra (tu dong cham)
 * POST /api/exam_submit.php
 * Body: { auth_token, exam_id, answers: [{ question_id, selected_option_id?, answer_text?, fill_blank_answers?, matching_pairs? }] }
 */

require_once __DIR__ . '/config.php';
require_once __DIR__ . '/helpers.php';
require_once __DIR__ . '/auth.php';

if ($_SERVER['REQUEST_METHOD'] !== 'POST') jsonError('Chi ho tro POST', 405);

$user = authenticate();
requireRole(['student'], $user);

$body = getJsonBody();
requireParams(['exam_id', 'answers'], $body);

$examId = (int)$body['exam_id'];

try {
    $db = getDB();
    $db->beginTransaction();

    // Lay cau hoi + dap an dung
    $stmt = $db->prepare('
        SELECT eq.*, qb.question_type, qb.xp_reward
        FROM exam_questions eq
        JOIN question_bank qb ON eq.question_id = qb.id
        WHERE eq.exam_id = ?
    ');
    $stmt->execute([$examId]);
    $examQuestions = $stmt->fetchAll();

    $totalScore = 0;
    $earnedScore = 0;
    $totalXP = 0;
    $results = [];

    foreach ($examQuestions as $eq) {
        $qId = $eq['question_id'];
        $totalScore += $eq['score'];
        $totalXP += $eq['xp_reward'];

        // Tim cau tra loi tuong ung
        $answer = null;
        foreach ($body['answers'] as $a) {
            if ((int)$a['question_id'] === (int)$qId) {
                $answer = $a;
                break;
            }
        }
        if (!$answer) continue;

        $isCorrect = null;

        switch ($eq['question_type']) {
            case 'multiple_choice':
            case 'true_false':
                $selectedId = (int)($answer['selected_option_id'] ?? 0);
                $s = $db->prepare('SELECT is_correct FROM question_options WHERE id = ? AND question_id = ?');
                $s->execute([$selectedId, $qId]);
                $opt = $s->fetch();
                $isCorrect = $opt ? (bool)$opt['is_correct'] : false;

                $scoreEarned = $isCorrect ? $eq['score'] : 0;
                $earnedScore += $scoreEarned;

                $results[] = [
                    'question_id' => $qId,
                    'selected_option_id' => $selectedId,
                    'is_correct' => $isCorrect,
                    'score_earned' => $scoreEarned,
                ];
                break;

            case 'fill_blank':
                $userAnswers = $answer['fill_blank_answers'] ?? [];
                $s = $db->prepare('SELECT position, correct_answer FROM fill_blank_answers WHERE question_id = ?');
                $s->execute([$qId]);
                $corrects = $s->fetchAll();

                $correctCount = 0;
                $totalBlanks = count($corrects);
                foreach ($corrects as $c) {
                    $userAns = $userAnswers[$c['position']] ?? '';
                    if (strcasecmp(trim($userAns), trim($c['correct_answer'])) === 0) {
                        $correctCount++;
                    }
                }

                $isCorrect = ($correctCount === $totalBlanks && $totalBlanks > 0);
                $scoreEarned = $totalBlanks > 0 ? ($eq['score'] * $correctCount / $totalBlanks) : 0;
                $earnedScore += $scoreEarned;

                $results[] = [
                    'question_id' => $qId,
                    'fill_blank_answers' => json_encode($userAnswers),
                    'is_correct' => $isCorrect,
                    'score_earned' => $scoreEarned,
                    'correct_count' => "$correctCount/$totalBlanks",
                ];
                break;

            case 'matching':
                $userPairs = $answer['matching_pairs'] ?? [];
                $s = $db->prepare('SELECT id, left_text, right_text FROM matching_pairs WHERE question_id = ?');
                $s->execute([$qId]);
                $correctPairs = $s->fetchAll();

                $correctCount = 0;
                $totalPairs = count($correctPairs);
                foreach ($correctPairs as $cp) {
                    $userRight = $userPairs[$cp['id']] ?? '';
                    if (strcasecmp(trim($userRight), trim($cp['right_text'])) === 0) {
                        $correctCount++;
                    }
                }

                $isCorrect = ($correctCount === $totalPairs && $totalPairs > 0);
                $scoreEarned = $totalPairs > 0 ? ($eq['score'] * $correctCount / $totalPairs) : 0;
                $earnedScore += $scoreEarned;

                $results[] = [
                    'question_id' => $qId,
                    'is_correct' => $isCorrect,
                    'score_earned' => $scoreEarned,
                    'correct_count' => "$correctCount/$totalPairs",
                ];
                break;
        }
    }

    // Cap nhat pass_count
    $stmt = $db->prepare('UPDATE exams SET pass_count = pass_count + 1 WHERE id = ?');
    $stmt->execute([$examId]);

    // Tinh XP nhan duoc
    $xpEarned = $totalScore > 0 ? (int)(($earnedScore / $totalScore) * $totalXP) : 0;

    // Ghi nhan XP
    $stmt = $db->prepare('INSERT INTO xp_transactions (user_id, amount, source, reference_id, created_at) VALUES (?, ?, \'quiz\', ?, NOW())');
    $stmt->execute([$user['id'], $xpEarned, $examId]);

    $stmt = $db->prepare('UPDATE user_xp SET total_xp = total_xp + ?, updated_at = NOW() WHERE user_id = ?');
    $stmt->execute([$xpEarned, $user['id']]);

    $db->commit();

    jsonSuccess([
        'score'       => round($earnedScore, 2),
        'max_score'   => round($totalScore, 2),
        'xp_earned'   => $xpEarned,
        'details'     => $results,
    ], 'Nop bai thanh cong');

} catch (PDOException $e) {
    if ($db->inTransaction()) $db->rollBack();
    jsonError('Loi he thong', 500);
}
