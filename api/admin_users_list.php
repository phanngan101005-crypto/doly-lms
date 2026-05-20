<?php
/**
 * DOLY LMS - Admin: Danh sach nguoi dung (co phan trang)
 * POST /api/admin_users_list.php
 * Body: { auth_token, limit, offset, role, keyword, status, sort_by }
 * Returns: { items, total }
 */

require_once __DIR__ . '/config.php';
require_once __DIR__ . '/helpers.php';
require_once __DIR__ . '/auth.php';

$user = authenticate();
requireRole(['admin'], $user);

try {
    $db = getDB();
    $body = getJsonBody();

    $limit   = (int)($body['limit'] ?? 15);
    $offset  = (int)($body['offset'] ?? 0);
    $role    = $body['role'] ?? '';
    $keyword = trim($body['keyword'] ?? '');
    $status  = $body['status'] ?? 'all';
    $sortBy  = $body['sort_by'] ?? 'created_at';

    // Xay dung cau truy van
    $where = 'WHERE 1=1';
    $params = [];

    if (!empty($role)) {
        $where .= ' AND u.role = ?';
        $params[] = $role;
    }
    if (!empty($keyword)) {
        $where .= ' AND (u.full_name LIKE ? OR u.email LIKE ?)';
        $params[] = "%$keyword%";
        $params[] = "%$keyword%";
    }
    if ($status !== 'all') {
        $where .= ' AND u.status = ?';
        $params[] = $status;
    }

    // Sap xep
    $orderMap = [
        'created_at' => 'u.created_at DESC',
        'name'       => 'u.full_name ASC',
        'email'      => 'u.email ASC',
        'status'     => 'u.status ASC',
    ];
    $orderClause = $orderMap[$sortBy] ?? 'u.created_at DESC';

    // Dem tong so
    $stmt = $db->prepare("SELECT COUNT(*) as total FROM users u $where");
    $stmt->execute($params);
    $total = (int)$stmt->fetch()['total'];

    // Lay danh sach
    $stmt = $db->prepare("
        SELECT u.id, u.full_name, u.email, u.role, u.status, u.created_at,
               ux.total_xp
        FROM users u
        LEFT JOIN user_xp ux ON u.id = ux.user_id
        $where
        ORDER BY $orderClause
        LIMIT ? OFFSET ?
    ");
    $params[] = $limit;
    $params[] = $offset;
    $stmt->execute($params);
    $items = $stmt->fetchAll();

    // Chuan hoa: them truong 'roles' cho tuong thich frontend
    foreach ($items as &$item) {
        $item['roles'] = $item['role'];
        $item['total_xp'] = (int)($item['total_xp'] ?? 0);
    }

    jsonSuccess([
        'items' => $items,
        'total' => $total,
    ]);

} catch (PDOException $e) {
    jsonError('Loi he thong', 500);
}
