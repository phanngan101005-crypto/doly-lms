<?php
/**
 * DOLY LMS - AI Chat
 * POST /api/ai_chat.php
 * Body: { auth_token, message, context?: { lesson_id?, subject_id? } }
 * Tra ve: { reply, history? }
 *
 * Mo phong AI tra loi theo phuong phap Socratic (goi mo).
 * Trong thuc te, ban co the thay the bang call API GPT/Claude tai day.
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

    // 2. Lay lich su chat (20 tin nhan gan nhat)
    $stmt = $db->prepare('SELECT role, message FROM ai_chat_history WHERE user_id = ? ORDER BY created_at DESC LIMIT 20');
    $stmt->execute([$user['id']]);
    $history = $stmt->fetchAll();
    $history = array_reverse($history);

    // 3. Lay thong tin bai hoc (neu co context)
    $lessonInfo = '';
    if (!empty($context['lesson_id'])) {
        $stmt = $db->prepare('SELECT title FROM lessons WHERE id = ?');
        $stmt->execute([(int)$context['lesson_id']]);
        $lesson = $stmt->fetch();
        if ($lesson) $lessonInfo = " (Bai hoc: {$lesson['title']})";
    }

    // 4. Sinh câu trả lời bằng Google Gemini AI    //    
    $reply = callGeminiAI($userMessage, $history, $lessonInfo, $user['full_name']);    
    // 5. Luu tin nhan AI
    $stmt = $db->prepare('INSERT INTO ai_chat_history (user_id, role, message, context, created_at) VALUES (?, \'assistant\', ?, ?, NOW())');
    $stmt->execute([$user['id'], $reply, !empty($context) ? json_encode($context) : null]);

    jsonSuccess([
        'reply'   => $reply,
        'history' => array_slice($history, -10),
    ]);

} catch (PDOException $e) {
    jsonError('Loi he thong', 500);
}

/**
 * Goi API Google Gemini de tao cau tra loi thong minh
 * Đã tối ưu hóa xử lý lỗi và cấu trúc kết nối
 */
function callGeminiAI(string $message, array $history, string $lessonInfo, string $userName): string {
    
    $apiKey = getenv('OPENROUTER_API_KEY'); 
    
    // URL của OpenRouter
    $url = "https://openrouter.ai/api/v1/chat/completions";

    $contents = [];
    foreach ($history as $h) {
        $contents[] = ["role" => ($h['role'] === 'user' ? 'user' : 'assistant'), "content" => $h['message']];
    }
    $contents[] = ["role" => "user", "content" => "Trả lời trực tiếp, gạch đầu dòng, xuống dòng, in đậm từ khóa. Câu hỏi: " . $message];

    $payload = json_encode([
        "model" => "google/gemini-2.0-flash-exp"
        "messages" => $contents
    ]);

    $ch = curl_init($url);
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
    curl_setopt($ch, CURLOPT_POST, true);
    curl_setopt($ch, CURLOPT_POSTFIELDS, $payload);
    curl_setopt($ch, CURLOPT_HTTPHEADER, [
        'Content-Type: application/json',
        'Authorization: Bearer ' . $apiKey,
        'HTTP-Referer: https://doly.vn', // Tên miền website của bạn
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