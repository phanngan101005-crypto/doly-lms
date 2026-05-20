<?php
/**
 * DOLY LMS - Danh sach bai giang
 * GET /api/lesson_list.php?auth_token=...&subject_id=...
 */

require_once __DIR__ . '/config.php';
require_once __DIR__ . '/helpers.php';
require_once __DIR__ . '/auth.php';

$user = authenticate();

try {
    $db = getDB();

    // Danh sach mon hoc
    $stmt = $db->prepare('SELECT * FROM subjects ORDER BY name');
    $stmt->execute();
    $subjects = $stmt->fetchAll();

    $subjectId = (int)getParam('subject_id', 0);

    $lessons = [];
    if ($subjectId > 0) {
        // Kiem tra subject ton tai
        $stmt = $db->prepare('SELECT * FROM subjects WHERE id = ?');
        $stmt->execute([$subjectId]);
        $subject = $stmt->fetch();
        if (!$subject) jsonError('Khong tim thay mon hoc', 404);

        $lessons = $db->prepare('
            SELECT id, title, subject_id, order_index, 
                   DATE_FORMAT(created_at, \'%d/%m/%Y\') as created_at
            FROM lessons WHERE subject_id = ? ORDER BY order_index
        ');
        $lessons->execute([$subjectId]);
        $lessons = $lessons->fetchAll();

        // Dem video, tai lieu kem theo
        foreach ($lessons as &$lesson) {
            $stmt = $db->prepare('SELECT COUNT(*) as cnt FROM videos WHERE lesson_id = ?');
            $stmt->execute([$lesson['id']]);
            $lesson['video_count'] = (int)$stmt->fetch()['cnt'];

            $stmt = $db->prepare('SELECT COUNT(*) as cnt FROM documents WHERE lesson_id = ?');
            $stmt->execute([$lesson['id']]);
            $lesson['doc_count'] = (int)$stmt->fetch()['cnt'];
        }
    }

    jsonSuccess([
        'subjects' => $subjects,
        'lessons'  => $lessons,
    ]);
} catch (PDOException $e) {
    jsonError('Loi he thong', 500);
}
