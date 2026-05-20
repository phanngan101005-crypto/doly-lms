/**
 * DOLY LMS - API Client
 * Centralized HTTP client for all backend endpoints.
 * Auto-detects API base URL from its own <script> tag location.
 * Usage: <script src="../api/client.js"></script>
 *        Then call DolyAPI.login(), DolyAPI.getSubjects(), etc.
 */
(function () {
    'use strict';

    // ───────── Auto-detect API base URL ─────────
    var apiBase;
    
    // Ưu tiên dùng origin của trang web nếu chạy trên Render
    if (window.location.hostname.includes('onrender.com')) {
        apiBase = window.location.origin + '/api';
    } else {
        // Fallback về cách dò tự động cho Localhost (XAMPP)
        var scripts = document.getElementsByTagName('script');
        for (var i = 0; i < scripts.length; i++) {
            if (scripts[i].src.indexOf('client.js') !== -1) {
                apiBase = scripts[i].src.substring(0, scripts[i].src.lastIndexOf('/'));
                break;
            }
        }
        if (!apiBase) apiBase = '/api';
    }
    
    console.log('[DolyAPI] Base URL detected:', apiBase);

    // ... (Giữ nguyên toàn bộ phần còn lại từ đoạn // ───────── Session Management ───────── trở xuống)

    // ───────── Session Management ─────────
    var STORAGE_KEY = 'doly_user';

    function saveSession(userData) {
        try {
            localStorage.setItem(STORAGE_KEY, JSON.stringify(userData));
        } catch (e) { /* ignore */ }
    }

    function loadSession() {
        try {
            var raw = localStorage.getItem(STORAGE_KEY);
            return raw ? JSON.parse(raw) : null;
        } catch (e) { return null; }
    }

    function clearSession() {
        try { localStorage.removeItem(STORAGE_KEY); } catch (e) { /* ignore */ }
    }

    function isLoggedIn() {
        var s = loadSession();
        return !!(s && s.auth_token);
    }

    function requireAuth() {
        if (!isLoggedIn()) {
            var loginUrl = apiBase.replace('/api', '/login.html');
            window.location.href = loginUrl;
            return false;
        }
        return true;
    }

    // ───────── Generic Request ─────────
    function apiRequest(endpoint, method, data) {
        var url = apiBase + '/' + endpoint;
        console.log('[DolyAPI] Request:', method, url, data ? JSON.stringify(data) : '');
        var options = {
            method: method || 'GET',
            headers: { 'Content-Type': 'application/json' },
        };

        // Inject auth token
        var session = loadSession();
        if (session && session.auth_token) {
            options.headers['Authorization'] = 'Bearer ' + session.auth_token;
        }

        if (data) {
            options.body = JSON.stringify(data);
        }

        return fetch(url, options)
            .then(function (res) {
                return res.json().then(function (json) {
                    if (!res.ok || !json.success) {
                        var err = new Error(json.message || 'Request failed');
                        err.status = res.status;
                        err.data = json;
                        console.error('[DolyAPI] Response error:', res.status, json);
                        throw err;
                    }
                    return json.data;
                });
            })
            .catch(function (e) {
                // Network error (Failed to fetch)
                console.error('[DolyAPI] Network error:', e.name, '-', e.message);
                console.error('[DolyAPI] URL that failed:', url);
                console.error('[DolyAPI] Method:', method);
                console.error('[DolyAPI] Check: Apache dang chay? Duong dan dung? CORS?');
                throw e;
            });
    }

    // ───────── DOM Helpers ─────────
    function $(selector, ctx) {
        return (ctx || document).querySelector(selector);
    }

    function $$(selector, ctx) {
        return (ctx || document).querySelectorAll(selector);
    }

    function renderHTML(selector, html) {
        var el = $(selector);
        if (el) el.innerHTML = html;
    }

    function showError(selector, message) {
        var el = $(selector);
        if (el) el.innerHTML = '<div class="text-red-500 text-sm font-bold p-4 text-center">' + (message || 'Loi he thong') + '</div>';
    }

    function showLoading(selector) {
        var el = $(selector);
        if (el) el.innerHTML = '<div class="flex justify-center py-8"><div class="w-8 h-8 border-4 border-blue-200 border-t-blue-600 rounded-full animate-spin"></div></div>';
    }

    function hideElement(selector) {
        var el = $(selector);
        if (el) el.style.display = 'none';
    }

    function showElement(selector, display) {
        var el = $(selector);
        if (el) el.style.display = display || 'block';
    }

    // ───────── Escape HTML ─────────
    function esc(str) {
        if (!str) return '';
        var div = document.createElement('div');
        div.appendChild(document.createTextNode(str));
        return div.innerHTML;
    }

    function timeAgo(dateStr) {
        if (!dateStr) return '';
        var now = new Date();
        var d = new Date(dateStr.replace(' ', 'T'));
        var diff = Math.floor((now - d) / 1000);
        if (diff < 60) return 'Vua xong';
        if (diff < 3600) return Math.floor(diff / 60) + ' phut truoc';
        if (diff < 86400) return Math.floor(diff / 3600) + ' gio truoc';
        if (diff < 604800) return Math.floor(diff / 86400) + ' ngay truoc';
        return d.toLocaleDateString('vi-VN');
    }

    // ───────── API Functions ─────────

    var API = {
        // ========== Auth ==========
        login: function (email, password, role) {
            return apiRequest('auth_login.php', 'POST', { email: email, password: password, role: role });
        },
        register: function (fullName, email, password, role) {
            return apiRequest('auth_register.php', 'POST', { full_name: fullName, email: email, password: password, role: role });
        },
        logout: function () {
            return apiRequest('auth_logout.php', 'POST');
        },

        // ========== Classes ==========
        getClasses: function () {
            return apiRequest('class_list.php', 'GET');
        },
        createClass: function (name, subject, gradeLevel, classCode) {
            return apiRequest('class_create.php', 'POST', { name: name, subject: subject, grade_level: gradeLevel, class_code: classCode });
        },
        joinClass: function (code) {
            return apiRequest('class_join.php', 'POST', { class_code: code });
        },
        getClassMembers: function (classId) {
            return apiRequest('class_members.php?class_id=' + classId, 'GET');
        },

        // ========== Lessons ==========
        getSubjects: function () {
            return apiRequest('lesson_list.php', 'GET');
        },
        getLessons: function (subjectId) {
            return apiRequest('lesson_list.php?subject_id=' + (subjectId || 0), 'GET');
        },
        getLessonDetail: function (lessonId) {
            return apiRequest('lesson_detail.php?id=' + (lessonId || 0), 'GET');
        },

        // ========== Questions & Exams ==========
        getQuestionBank: function (subjectId, type, lessonId) {
            var qs = '?';
            if (subjectId) qs += 'subject_id=' + subjectId + '&';
            if (type) qs += 'type=' + type + '&';
            if (lessonId) qs += 'lesson_id=' + lessonId + '&';
            return apiRequest('question_bank.php' + qs, 'GET');
        },
        createQuestion: function (data) {
            return apiRequest('question_bank.php', 'POST', data);
        },
        getExams: function (subjectId) {
            var qs = subjectId ? '?subject_id=' + subjectId : '';
            return apiRequest('exam_take.php' + qs, 'GET');
        },
        submitExam: function (examId, answers) {
            return apiRequest('exam_submit.php', 'POST', { exam_id: examId, answers: answers });
        },

        // ========== Assignments ==========
        getAssignments: function (classId) {
            var qs = classId ? '?class_id=' + classId : '';
            return apiRequest('assignment_list.php' + qs, 'GET');
        },
        createAssignment: function (data) {
            return apiRequest('assignment_create.php', 'POST', data);
        },
        submitAssignment: function (assignmentId, data) {
            return apiRequest('assignment_submit.php', 'POST', { assignment_id: assignmentId, data: data });
        },
        gradeAssignment: function (studentAssignmentId, score) {
            return apiRequest('assignment_grade.php', 'POST', { student_assignment_id: studentAssignmentId, score: score });
        },

        // ========== Grades ==========
        getGrades: function (classId) {
            var qs = classId ? '?class_id=' + classId : '';
            return apiRequest('grade_list.php' + qs, 'GET');
        },

        // ========== Forum ==========
        getForumPosts: function (params) {
            var qs = '';
            if (params) {
                var parts = [];
                if (typeof params === 'number' || typeof params === 'string') {
                    qs = '?topic_id=' + params;
                } else {
                    if (params.topic_id) parts.push('topic_id=' + params.topic_id);
                    if (params.search) parts.push('search=' + encodeURIComponent(params.search));
                    if (parts.length > 0) qs = '?' + parts.join('&');
                }
            }
            return apiRequest('forum_post.php' + qs, 'GET');
        },
        createForumPost: function (title, content, topicId) {
            return apiRequest('forum_post.php', 'POST', { title: title, content: content, topic_id: topicId });
        },
        getComments: function (postId) {
            return apiRequest('forum_comment.php?post_id=' + postId, 'GET');
        },
        postComment: function (postId, content) {
            return apiRequest('forum_comment.php', 'POST', { post_id: postId, content: content });
        },
        votePost: function (postId, voteType) {
            return apiRequest('forum_vote.php', 'POST', { post_id: postId, vote_type: voteType });
        },

        // ========== Gamification ==========
        getXP: function () {
            return apiRequest('xp_get.php', 'GET');
        },
        getStreak: function () {
            return apiRequest('streak_get.php', 'GET');
        },
        checkIn: function () {
            return apiRequest('attendance_daily.php', 'POST');
        },
        getAchievements: function () {
            return apiRequest('achievement_list.php', 'GET');
        },

        // ========== Parent ==========
        generateLinkCode: function () {
            return apiRequest('parent_link.php', 'POST', { action: 'generate' });
        },
        linkParent: function (code) {
            return apiRequest('parent_link.php', 'POST', { link_code: code });
        },
        getChildren: function () {
            return apiRequest('parent_children.php', 'GET');
        },

        // ========== Admin ==========
        getOverview: function () {
            return apiRequest('admin_overview.php', 'POST');
        },
        listUsers: function (params) {
            return apiRequest('admin_users_list.php', 'POST', params || {});
        },
        updateUserStatus: function (targetUserId, status) {
            return apiRequest('admin_user_status_update.php', 'POST', { target_user_id: targetUserId, status: status });
        },
        createNotification: function (title, body, targetRole) {
            return apiRequest('admin_notification_create.php', 'POST', { title: title, body: body, target_role: targetRole });
        },
        updateNotification: function (notificationId, title, body, targetRole) {
            return apiRequest('admin_notification_update.php', 'POST', { notification_id: notificationId, title: title, body: body, target_role: targetRole });
        },
        deleteNotification: function (notificationId) {
            return apiRequest('admin_notification_delete.php', 'POST', { notification_id: notificationId });
        },
        deleteForumPost: function (postId) {
            return apiRequest('admin_forum_post_delete.php', 'POST', { post_id: postId });
        },

        // ========== News & FAQ ==========
        getNews: function () {
            return apiRequest('admin_news.php', 'GET');
        },
        getFAQ: function () {
            return apiRequest('admin_faq.php', 'GET');
        },

        // ========== AI Chat ==========
        chat: function (message, context) {
            return apiRequest('ai_chat.php', 'POST', { message: message, context: context || null });
        },

        // ========== Session helpers (exposed) ==========
        saveSession: saveSession,
        loadSession: loadSession,
        clearSession: clearSession,
        isLoggedIn: isLoggedIn,
        requireAuth: requireAuth,

        // ========== DOM helpers ==========
        $: $,
        $$: $$,
        renderHTML: renderHTML,
        showError: showError,
        showLoading: showLoading,
        hideElement: hideElement,
        showElement: showElement,
        esc: esc,
        timeAgo: timeAgo,
    };

    // Expose globally
    window.DolyAPI = API;
})();
