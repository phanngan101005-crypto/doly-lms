/**
 * DOLY LMS - Auth Middleware
 * Kiem tra dang nhap truoc khi vao cac trang can xac thuc.
 * Include: <script src="../auth-middleware.js"></script>
 */
(function () {
    'use strict';

    var session = null;
    try {
        var raw = localStorage.getItem('doly_user');
        if (raw) session = JSON.parse(raw);
    } catch (e) { /* ignore */ }

    if (!session || !session.auth_token) {
        // Chua dang nhap -> ve trang login
        var currentPath = window.location.pathname;
        var loginPath = currentPath.substring(0, currentPath.lastIndexOf('/')) + '/login.html';
        // Neu o thu muc con (vd /layerhocsinh/), can ../login.html
        if (currentPath.indexOf('/layer') !== -1 || currentPath.indexOf('/trang') !== -1) {
            loginPath = currentPath.substring(0, currentPath.indexOf('/', 1)) + '/login.html';
        }
        window.location.href = loginPath || '../login.html';
        return;
    }

    // Kiem tra role neu co data-required-role
    var body = document.body;
    var requiredRole = body ? body.getAttribute('data-required-role') : null;
    if (requiredRole && session.role !== requiredRole) {
        alert('Ban khong co quyen truy cap trang nay!');
        var roleRedirects = {
            student: 'layerhocsinh/dashboad.html',
            teacher: 'layergiaovien/tongquan.html',
            parent: 'layerphuhuynh/tongquan.html',
            admin: 'quantri.html'
        };
        window.location.href = roleRedirects[session.role] || 'login.html';
    }
})();
