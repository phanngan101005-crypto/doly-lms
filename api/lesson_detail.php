<?php
/**
 * DOLY LMS - Chi tiet bai giang
 * GET /api/lesson_detail.php?auth_token=...&lesson_id=...
 */

require_once __DIR__ . '/config.php';
require_once __DIR__ . '/helpers.php';
require_once __DIR__ . '/auth.php';

$user = authenticate();
$lessonId = (int)getParam('lesson_id', 0);
if ($lessonId <= 0) jsonError('Thieu lesson_id', 400);

try {
    $db = getDB();

    // Bai giang
    $stmt = $db->prepare('
        SELECT l.*, s.name as subject_name
        FROM lessons l
        JOIN subjects s ON l.subject_id = s.id
        WHERE l.id = ?
        LIMIT 1
    ');
    $stmt->execute([$lessonId]);
    $lesson = $stmt->fetch();
    if (!$lesson) jsonError('Khong tim thay bai giang', 404);

    // Video
    $stmt = $db->prepare('SELECT * FROM videos WHERE lesson_id = ? ORDER BY id');
    $stmt->execute([$lessonId]);
    $videos = $stmt->fetchAll();

    // Tai lieu
    $stmt = $db->prepare('SELECT * FROM documents WHERE lesson_id = ? ORDER BY type');
    $stmt->execute([$lessonId]);
    $documents = $stmt->fetchAll();

    // Mo hinh 3D
    $stmt = $db->prepare('SELECT * FROM lab_models WHERE lesson_id = ? OR subject_id = ?');
    $stmt->execute([$lessonId, $lesson['subject_id']]);
    $labModels = $stmt->fetchAll();

    jsonSuccess([
        'lesson'    => $lesson,
        'videos'    => $videos,
        'documents' => $documents,
        'lab_models'=> $labModels,
    ]);
} catch (PDOException $e) {
    jsonError('Loi he thong', 500);
}
