<?php
/**
 * DOLY LMS - Tao lop hoc
 * POST /api/class_create.php
 * Body: { auth_token, name, subject?, grade_level? }
 */

require_once __DIR__ . '/config.php';
require_once __DIR__ . '/helpers.php';
require_once __DIR__ . '/auth.php';

if ($_SERVER['REQUEST_METHOD'] !== 'POST') jsonError('Chi ho tro POST', 405);

$user = authenticate();
requireRole(['teacher', 'admin'], $user);

$body = getJsonBody();
requireParams(['name'], $body);

$name       = trim($body['name']);
$subject    = $body['subject'] ?? null;
$gradeLevel = $body['grade_level'] ?? null;
$classCode  = strtoupper(trim($body['class_code'] ?? ''));

// Neu frontend khong gui class_code, tu sinh
if (empty($classCode)) {
    $classCode = strtoupper(substr(bin2hex(random_bytes(4)), 0, 8));
}

try {
    $db = getDB();
    
    // Thu insert, neu bi trung class_code (UNIQUE) thi thu lai toi da 3 lan
    $maxAttempts = 3;
    $inserted = false;
    for ($attempt = 1; $attempt <= $maxAttempts; $attempt++) {
        try {
            $stmt = $db->prepare('
                INSERT INTO classes (name, subject, grade_level, teacher_id, class_code, status, created_at)
                VALUES (?, ?, ?, ?, ?, \'active\', NOW())
            ');
            $stmt->execute([$name, $subject, $gradeLevel, $user['id'], $classCode]);
            $inserted = true;
            break;
        } catch (PDOException $e) {
            // Neu la loi duplicate entry ($e->errorInfo[1] === 1062) va con luot thu, sinh ma moi
            if ($e->errorInfo[1] === 1062 && $attempt < $maxAttempts) {
                $classCode = strtoupper(substr(bin2hex(random_bytes(4)), 0, 8));
                continue;
            }
            throw $e;
        }
    }
    
    if (!$inserted) {
        jsonError('Khong the tao lop do trung ma. Vui long thu lai!', 500);
    }

    $classId = (int)$db->lastInsertId();
    jsonSuccess([
        'id'         => $classId,
        'name'       => $name,
        'subject'    => $subject,
        'grade_level'=> $gradeLevel,
        'class_code' => $classCode,
        'teacher_id' => (int)$user['id'],
    ], 'Tao lop thanh cong', 201);
} catch (PDOException $e) {
    jsonError('Loi he thong', 500);
}
