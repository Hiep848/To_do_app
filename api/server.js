
const express = require('express');
const { v4: uuidv4 } = require('uuid'); // Dùng uuid để tạo ID duy nhất
const fs = require('fs');
const path = require('path');
const cors = require('cors');
const app = express();
const port = 3000;
app.use(cors());

app.use(express.json());

const CACHE_FILE = path.join(__dirname, 'todos_cache.json');

// Hàm đọc todos từ file cache (nếu có), nếu không thì tạo dữ liệu mặc định
function loadTodos() {
    if (fs.existsSync(CACHE_FILE)) {
        try {
            const data = fs.readFileSync(CACHE_FILE, 'utf-8');
            return JSON.parse(data);
        } catch (err) {
            console.error('Lỗi khi đọc cache:', err);
        }
    }
    // Dữ liệu mặc định nếu chưa có cache
    return [
        { 
            id: uuidv4(), 
            title: 'Học Node.js API', 
            description: 'Tìm hiểu cách xây dựng API RESTful với Node.js và Express', 
            isCompleted: false, 
            lastModify: new Date().toISOString() 
        },
        { 
            id: uuidv4(), 
            title: 'Viết ứng dụng To-Do Flutter', 
            description: 'Phát triển ứng dụng quản lý công việc bằng Flutter', 
            isCompleted: false, 
            lastModify: new Date().toISOString() 
        },
        { 
            id: uuidv4(), 
            title: 'Triển khai API To-Do', 
            description: 'Deploy API lên server và kết nối với ứng dụng Flutter', 
            isCompleted: true, 
            lastModify: new Date().toISOString() 
        },
    ];
}

// Hàm ghi todos vào file cache
function saveTodos() {
    try {
        fs.writeFileSync(CACHE_FILE, JSON.stringify(todos, null, 2), 'utf-8');
    } catch (err) {
        console.error('Lỗi khi ghi cache:', err);
    }
}

let todos = loadTodos();

// --- Định nghĩa các Endpoint API (CRUD) ---

// Unified GET /todos to fetch and filter tasks
app.get('/todos', (req, res) => {
    // Get the query parameters
    const { q, status } = req.query;

    // Start with the full list of tasks
    let results = [...todos]; 

    console.log(`GET /todos with parameters: q='${q}', status='${status}'`);

    // 1. Filter by search keyword (if it exists)
    if (q && q !== '*' && q !== 'all' && typeof q === 'string' && q.trim() !== '') {
        const keyword = q.trim().toLowerCase();
        results = results.filter(todo => 
            todo.title.toLowerCase().includes(keyword)
        );
        console.log(`-> After searching for '${q}', ${results.length} tasks remain.`);
    }

    // 2. Filter by completion status (if it exists)
    // This filter is applied to the results already filtered by the search
    if (status) {
        if (status === 'completed') {
            results = results.filter(todo => todo.isCompleted === true);
            console.log(`-> After filtering by status 'completed', ${results.length} tasks remain.`);
        } else if (status === 'incomplete') {
            results = results.filter(todo => todo.isCompleted === false);
            console.log(`-> After filtering by status 'incomplete', ${results.length} tasks remain.`);
        }
        // If 'status' has another value, we ignore it
    }

    // Return the final result as JSON
    res.status(200).json(results);
});

// 2. READ ONE: Lấy một công việc theo ID
app.get('/todos/:id', (req, res) => {
    const { id } = req.params; // Lấy ID từ URL params
    const todo = todos.find(t => t.id === id); // Tìm công việc trong mảng

    if (todo) {
        console.log(`GET /todos/${id} - Tìm thấy công việc: ${todo.title}`);
        res.status(200).json(todo); // Trả về công việc tìm thấy
    } else {
        console.log(`GET /todos/${id} - Không tìm thấy công việc.`);
        res.status(404).json({ message: 'Không tìm thấy công việc.' }); // Trả về lỗi 404 nếu không tìm thấy
    }
});

// 3. CREATE: Thêm một công việc mới
app.post('/todos', (req, res) => {
    const { title, description } = req.body; // Lấy title và description từ body của request (JSON)

    if (!title || typeof title !== 'string' || title.trim() === '') {
        console.log('POST /todos - Yêu cầu không hợp lệ: Title bị thiếu hoặc không hợp lệ.');
        return res.status(400).json({ message: 'Title không được để trống.' });
    }

    const newTodo = {
        id: uuidv4(),
        title: title.trim(),
        description: description ? description.trim() : '',
        isCompleted: false,
        lastModify: new Date().toISOString()
    };
    todos.push(newTodo); // Thêm công việc mới vào mảng
    saveTodos(); // Ghi cache sau khi thêm công việc mới
    console.log('POST /todos - Đã thêm công việc mới:', newTodo.title);
    res.status(201).json(newTodo); // Trả về công việc vừa tạo với mã 201 Created
});

// 4. UPDATE: Cập nhật một phần của công việc theo ID
app.patch('/todos/reorder', (req, res) => {
    const { oldIndex, newIndex } = req.body;

    // Kiểm tra nếu danh sách todos rỗng
    if (!Array.isArray(todos) || todos.length === 0) {
        return res.status(404).json({ message: 'Không có công việc nào để sắp xếp.' });
    }

    // Kiểm tra tính hợp lệ của chỉ số
    if (typeof oldIndex !== 'number' || typeof newIndex !== 'number' || 
        oldIndex < 0 || oldIndex >= todos.length || 
        newIndex < 0 || newIndex >= todos.length) {
        return res.status(400).json({ message: 'Chỉ số không hợp lệ.' });
    }

    if (oldIndex === newIndex) {
        return res.status(200).json(todos);
    }
    // Hoán đổi vị trí của hai công việc
    const temp = todos[oldIndex];
    todos[oldIndex] = todos[newIndex];
    todos[newIndex] = temp;
    saveTodos(); 

    console.log(`PATCH /todos/reorder - Đã đổi chỗ công việc từ vị trí ${oldIndex} sang ${newIndex}.`);
    res.status(200).json(todos); // Trả về danh sách ToDo đã được sắp xếp lại
});

app.patch('/todos/:id', (req, res) => {
    // 1. Lấy ID từ URL và tất cả các trường có thể có từ body
    const { id } = req.params;
    const { title, description, isCompleted } = req.body;

    // 2. Tìm vị trí của công việc (logic này không đổi)
    const todoIndex = todos.findIndex(t => t.id === id);

    // 3. Nếu không tìm thấy, trả về lỗi 404 (logic này không đổi)
    if (todoIndex === -1) {
        console.log(`PATCH /todos/${id} - Không tìm thấy công việc.`);
        return res.status(404).json({ message: 'Không tìm thấy công việc.' });
    }

    // 4. Tạo bản sao và một biến để theo dõi xem có thay đổi không
    const updatedTodo = { ...todos[todoIndex] };
    let hasBeenModified = false;

    // 5. Logic cập nhật được gộp lại
    // Cập nhật 'title' nếu có
    if (title !== undefined) {
        if (typeof title !== 'string' || title.trim() === '') {
            return res.status(400).json({ message: 'Title không hợp lệ.' });
        }
        updatedTodo.title = title.trim();
        hasBeenModified = true;
    }
    
    // Cập nhật 'description' nếu có
    if (description !== undefined) {
        if (typeof description !== 'string') {
            return res.status(400).json({ message: 'Description không hợp lệ.' });
        }
        updatedTodo.description = description.trim();
        hasBeenModified = true;
    }

    // Cập nhật 'isCompleted' nếu có
    if (isCompleted !== undefined) {
        if (typeof isCompleted !== 'boolean') {
            return res.status(400).json({ message: 'isCompleted phải là true hoặc false.' });
        }
        updatedTodo.isCompleted = isCompleted;
        hasBeenModified = true;
    }
    
    // 6. Nếu không có trường nào hợp lệ được gửi lên để cập nhật
    if (!hasBeenModified) {
        return res.status(400).json({ message: 'Không có trường nào hợp lệ để cập nhật.' });
    }

    // 7. Chỉ cập nhật thời gian nếu có sự thay đổi
    updatedTodo.lastModify = new Date().toISOString();

    // 8. Cập nhật công việc trong mảng và lưu lại
    todos[todoIndex] = updatedTodo;
    saveTodos(); 
    console.log(`PATCH /todos/${id} - Đã cập nhật công việc: ${updatedTodo.title}`);

    // 9. Trả về công việc đã cập nhật
    res.status(200).json(updatedTodo);
});



// 5. DELETE: Xóa một công việc theo ID
app.delete('/todos/:id', (req, res) => {
    const { id } = req.params;
    const initialLength = todos.length;
    // Lọc ra các công việc có ID không khớp với ID cần xóa
    todos = todos.filter(t => t.id !== id);
    saveTodos(); // Ghi cache sau khi xóa công việc

    if (todos.length < initialLength) {
        console.log(`DELETE /todos/${id} - Đã xóa công việc.`);
        res.status(204).send(); // Trả về 204 No Content nếu xóa thành công (không có nội dung trả về)
    } else {
        console.log(`DELETE /todos/${id} - Không tìm thấy công việc để xóa.`);
        res.status(404).json({ message: 'Không tìm thấy công việc để xóa.' });
    }
});

// 6. DELETE ALL: Xóa tất cả công việc
app.delete('/todos', (req, res) => {
    todos = [];
    saveTodos(); // Ghi cache sau khi xóa tất cả công việc
    console.log('DELETE /todos - Đã xóa tất cả công việc.');
    res.status(204).send(); // Trả về 204 No Content nếu xóa thành công
})
// Khởi động server
app.listen(port, () => {
    console.log(`Server API To-Do đang chạy tại http://localhost:${port}`);
    console.log('Các endpoints có sẵn:');
    console.log('GET    /todos');
    console.log('GET    /todos?q=keyword');
    console.log('GET    /todos?status=completed');
    console.log('GET    /todos?status=incomplete');
    console.log('GET    /todos/search?q= "Từ khóa"');
    console.log('GET    /todos/:id');
    console.log('POST   /todos (body: { "title": "Tiêu đề", "description": "Mô tả" })');
    console.log('PATCH  /todos/:id (body: { "title": "Tiêu đề mới", "description": "Mô tả mới", "isCompleted": true/false })');
    console.log('PATCH  /todos/reorder (body: { "oldIndex": 0, "newIndex": 1 })');
    console.log('DELETE /todos/:id');
    console.log('DELETE /todos (xóa tất cả công việc)');
});