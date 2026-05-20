<?php
/**
 * DOLY LMS - AI Chat
 */

require_once __DIR__ . '/config.php';
require_once __DIR__ . '/helpers.php';
require_once __DIR__ . '/auth.php';

if ($_SERVER['REQUEST_METHOD'] !== 'POST') jsonError('Chi ho tro POST', 405);

$user = authenticate();

$body = getJsonBody();
requireParams(['message'], $body);

$userMessage = trim($body['message']);
$context = $body['context'] ?? [];

try {
    $db = getDB();

    // 1. Luu tin nhan user
    $stmt = $db->prepare('INSERT INTO ai_chat_history (user_id, role, message, context, created_at) VALUES (?, \'user\', ?, ?, NOW())');
    $stmt->execute([$user['id'], $userMessage, !empty($context) ? json_encode($context) : null]);

    // 2. Lay lich su chat
    $stmt = $db->prepare('SELECT role, message FROM ai_chat_history WHERE user_id = ? ORDER BY created_at DESC LIMIT 20');
    $stmt->execute([$user['id']]);
    $history = $stmt->fetchAll();
    $history = array_reverse($history);

    // 3. Lay thong tin bai hoc
    $lessonInfo = '';
    if (!empty($context['lesson_id'])) {
        $stmt = $db->prepare('SELECT title FROM lessons WHERE id = ?');
        $stmt->execute([(int)$context['lesson_id']]);
        $lesson = $stmt->fetch();
        if ($lesson) $lessonInfo = " (Bai hoc: {$lesson['title']})";
    }

    // 4. Sinh câu trả lời
    $reply = callGeminiAI($userMessage, $history, $lessonInfo, $user['full_name']);    
    
    // 5. Luu tin nhan AI
    $stmt = $db->prepare('INSERT INTO ai_chat_history (user_id, role, message, context, created_at) VALUES (?, \'assistant\', ?, ?, NOW())');
    $stmt->execute([$user['id'], $reply, !empty($context) ? json_encode($context) : null]);

    jsonSuccess([
        'reply'   => $reply,
        'history' => array_slice($history, -10),
    ]);

} catch (PDOException $e) {
    jsonError('Loi he thong: ' . $e->getMessage(), 500);
}

function callGeminiAI(string $message, array $history, string $lessonInfo, string $userName): string {
    $apiKey = getenv('OPENROUTER_API_KEY'); 
    $url = "https://openrouter.ai/api/v1/chat/completions";

    $contents = [];
    foreach ($history as $h) {
        $contents[] = ["role" => ($h['role'] === 'user' ? 'user' : 'assistant'), "content" => $h['message']];
    }
    $contents[] = ["role" => "user", "content" => "Trả lời trực tiếp, gạch đầu dòng, xuống dòng, in đậm từ khóa. Câu hỏi: " . $message . $lessonInfo];

    // ĐÃ SỬA: Thêm dấu phẩy giữa model và messages
    $payload = json_encode([
        "model" => "google/gemini-2.0-flash-exp", 
        "messages" => $contents
    ]);

    $ch = curl_init($url);
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
    curl_setopt($ch, CURLOPT_POST, true);
    curl_setopt($ch, CURLOPT_POSTFIELDS, $payload);
    curl_setopt($ch, CURLOPT_HTTPHEADER, [
        'Content-Type: application/json',
        'Authorization: Bearer ' . $apiKey,
        'HTTP-Referer: https://doly.vn', 
        'X-Title: DOLY LMS'
    ]);
    
    curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, false);
    curl_setopt($ch, CURLOPT_TIMEOUT, 60);
    
    $response = curl_exec($ch);
    $httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
    $error = curl_error($ch);
    curl_close($ch);

    if ($error) return "Lỗi kết nối: " . $error;
    if ($httpCode !== 200) return "Lỗi OpenRouter ($httpCode): " . $response;

    $result = json_decode($response, true);
    return $result['choices'][0]['message']['content'] ?? "Doly chưa có phản hồi.";
}