<?php
/**
 * DOLY LMS - Helper Functions
 */
header('Content-Type: application/json; charset=utf-8');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization');

// Preflight CORS
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit;
}

/**
 * Gui phan hoi JSON thanh cong
 */
function jsonSuccess($data = [], string $message = 'Success', int $code = 200): void {
    http_response_code($code);
    echo json_encode(['success' => true, 'message' => $message, 'data' => $data], JSON_UNESCAPED_UNICODE);
    exit;
}

/**
 * Gui phan hoi JSON that bai
 */
function jsonError(string $message = 'Error', int $code = 400, $errors = null): void {
    http_response_code($code);
    $resp = ['success' => false, 'message' => $message];
    if ($errors !== null) $resp['errors'] = $errors;
    echo json_encode($resp, JSON_UNESCAPED_UNICODE);
    exit;
}

/**
 * Doc JSON body tu request (co cache de tranh doc php://input nhieu lan)
 */
function getJsonBody(): array {
    static $cached = null;
    if ($cached !== null) return $cached;
    $raw = file_get_contents('php://input');
    if (empty($raw)) {
        $cached = [];
        return $cached;
    }
    $data = json_decode($raw, true);
    $cached = is_array($data) ? $data : [];
    return $cached;
}

/**
 * Lay tham so tu request (GET hoac POST/JSON)
 */
function getParam(string $key, $default = null) {
    if ($_SERVER['REQUEST_METHOD'] === 'GET') {
        return $_GET[$key] ?? $default;
    }
    // POST / PUT / DELETE
    $body = getJsonBody();
    return $body[$key] ?? $_POST[$key] ?? $default;
}

/**
 * Kiem tra tham so bat buoc
 */
function requireParams(array $required, array $source): void {
    $missing = [];
    foreach ($required as $field) {
        if (!isset($source[$field]) || (is_string($source[$field]) && trim($source[$field]) === '')) {
            $missing[] = $field;
        }
    }
    if (!empty($missing)) {
        jsonError('Thieu tham so bat buoc: ' . implode(', ', $missing), 400);
    }
}
