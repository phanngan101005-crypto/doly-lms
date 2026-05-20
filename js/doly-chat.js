// Hàm chèn giao diện Chatbot vào body
function initChatbot() {
    const chatHTML = `
    <div class="fixed bottom-8 right-8 z-[100]">
        <button onclick="toggleAIChat()" class="w-16 h-16 bg-white dark:bg-slate-800 border-2 border-slate-100 dark:border-slate-700 rounded-full shadow-[0_15px_30px_rgba(10,47,182,0.2)] flex items-center justify-center hover:scale-110 transition-transform transform hover:-rotate-12 cursor-pointer group relative">
             <img src="../logodoly.png" alt="Doly Logo" class="w-full h-full object-contain">
            <span class="absolute top-0 right-0 w-3 h-3 bg-red-500 border-2 border-white dark:border-slate-800 rounded-full animate-ping"></span>
            <span class="absolute top-0 right-0 w-3 h-3 bg-red-500 border-2 border-white dark:border-slate-800 rounded-full"></span>
            <span class="absolute -top-12 right-0 bg-brand-blue text-white text-[10px] font-black uppercase px-4 py-2 rounded-xl opacity-0 group-hover:opacity-100 transition whitespace-nowrap shadow-lg">Hỏi Doly AI</span>
        </button>
    </div>

    <div id="ai-chat-panel" class="fixed top-0 right-0 w-full md:w-96 h-full bg-white dark:bg-slate-900 shadow-[-10px_0_30px_rgba(0,0,0,0.1)] z-[110] transform translate-x-full transition-transform duration-300 flex flex-col border-l border-slate-200 dark:border-slate-800">
        <div class="p-4 border-b border-slate-100 dark:border-slate-800 flex justify-between items-center bg-slate-50 dark:bg-slate-800/50">
            <div class="flex items-center gap-3">
                <div class="w-10 h-10 bg-brand-cyan rounded-full flex items-center justify-center text-xl shadow-sm">🐬</div>
                <div>
                    <h3 class="font-black text-sm text-brand-dark dark:text-white">Doly Trợ Lý Số</h3>
                    <p class="text-[10px] text-brand-cyan font-bold">Luôn sẵn sàng</p>
                </div>
            </div>
            <button onclick="toggleAIChat()" class="w-8 h-8 flex items-center justify-center text-slate-400 hover:bg-slate-200 rounded-full"><i class="fas fa-times"></i></button>
        </div>
        
        <div id="chat-history" class="flex-1 p-4 overflow-y-auto space-y-4"></div>

        <div class="p-4 border-t border-slate-100 bg-white">
            <div class="relative">
                <input type="text" id="chat-input" placeholder="Hỏi Doly điều gì đó..." class="w-full bg-slate-50 border border-slate-200 rounded-full pl-5 pr-12 py-3.5 text-sm focus:outline-none focus:border-brand-cyan transition" onkeydown="if(event.key === 'Enter') sendMsg()">
                <button onclick="sendMsg()" class="absolute right-2 top-1.5 w-9 h-9 bg-brand-cyan text-white rounded-full flex items-center justify-center hover:bg-blue-400 transition"><i class="fas fa-paper-plane text-xs"></i></button>
            </div>
        </div>
    </div>`;

    document.body.insertAdjacentHTML('beforeend', chatHTML);
}

// Logic điều khiển
function toggleAIChat() {
    const panel = document.getElementById('ai-chat-panel');
    panel.classList.toggle('translate-x-full');
}

async function sendMsg() {
    const input = document.getElementById('chat-input');
    const history = document.getElementById('chat-history');
    const text = input.value.trim();
    if (!text) return;

    // 1. Thêm câu hỏi vào giao diện
    history.innerHTML += `<div class="text-right text-sm bg-blue-600 text-white p-2 rounded-lg mb-2">${text}</div>`;
    input.value = '';

    try {
        // 2. Gọi API thông qua hàm DolyAPI.chat đã có sẵn
        const result = await DolyAPI.chat(text); 
        
        // 3. Kiểm tra xem kết quả có phải là chuỗi lỗi từ server không
        // (Vì server PHP của bạn hiện đang trả về chuỗi "Lỗi kết nối AI...")
        if (result.reply && !result.reply.includes("Lỗi kết nối AI")) {
            history.innerHTML += `<div class="text-left text-sm bg-slate-100 p-2 rounded-lg mb-2">${result.reply}</div>`;
        } else {
            // Hiển thị chi tiết lỗi nếu có
            history.innerHTML += `<div class="text-red-500 text-sm bg-red-50 p-2 rounded-lg mb-2 italic">⚠️ ${result.reply || 'Không nhận được phản hồi từ AI'}</div>`;
        }
    } catch (err) {
        history.innerHTML += `<div class="text-red-500 text-sm p-2">Đã xảy ra lỗi mạng. Vui lòng kiểm tra lại kết nối.</div>`;
    }
    
    // Tự động cuộn xuống dưới cùng
    history.scrollTop = history.scrollHeight;
}