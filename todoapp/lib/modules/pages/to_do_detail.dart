import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:todoapp/modules/blocs/todo_list.state.dart';
import 'package:todoapp/modules/blocs/todo_list_bloc.dart';
import 'package:todoapp/modules/blocs/todo_list_event.dart';
import 'package:todoapp/modules/models/todo.dart';

class TodoDetailPage extends StatefulWidget {
  final String todoId;

  const TodoDetailPage({super.key, required this.todoId});

  @override
  State<TodoDetailPage> createState() => _TodoDetailPageState();
}

class _TodoDetailPageState extends State<TodoDetailPage> {

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TodoListBloc, TodoListState>(
      builder: (context, state) {
        final ToDo todo = state.todos.firstWhere(
          (todo) => todo.id == widget.todoId,
        );
        return Scaffold(
          appBar: AppBar(
            title: Text(todo.title),
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: _buildReadView(todo)
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                builder: (context) => _EditTodoSheet(todo: todo),
              ).then((value) {
                if (value != null && value is Map<String, dynamic>) {
                  final updatedTodo = todo.copyWith(
                    id: todo.id,
                    title: value['title'] ?? todo.title,
                    description: value['description'] ?? todo.description,
                  );
                  context.read<TodoListBloc>().add(UpdateTodoEvent(
                    id: todo.id,
                    title: updatedTodo.title,
                    description: updatedTodo.description,
                  ));
                }
              });
            },
            child: const Icon(Icons.edit),
          ),
        );
      },
    );
  }

  Widget _buildReadView(ToDo todo){
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
        'Tiêu đề:',
        style: Theme.of(context).textTheme.titleLarge,
      ),
      const SizedBox(height: 8),
      Text(
        todo.title,
        style: Theme.of(context).textTheme.bodyLarge,
      ),
      const SizedBox(height: 24),
      Text(
        'Mô tả:',
        style: Theme.of(context).textTheme.titleLarge,
      ),
      const SizedBox(height: 8),
      Text(
        todo.description.isEmpty ? 'Không có mô tả.' : todo.description,
        style: Theme.of(context).textTheme.bodyLarge,
      ),
      const SizedBox(height: 24),
      Row(
        children: [
          Text(
            'Chỉnh sửa lần cuối: ',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          Text(
            DateFormat('dd/MM/yyyy').format(todo.lastModify),
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ],
      ),
      const SizedBox(height: 24),
      Row(
        children: [
          Text(
            'Trạng thái: ',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            Text(
              todo.isCompleted ? 'Đã hoàn thành' : 'Chưa hoàn thành',
              style: TextStyle(
                fontSize: 18,
                color: todo.isCompleted ? Colors.green : Colors.orange,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _EditTodoSheet extends StatefulWidget {
  final ToDo todo;
  const _EditTodoSheet({required this.todo});

  @override
  State<_EditTodoSheet> createState() => _EditTodoSheetState();
}

class _EditTodoSheetState extends State<_EditTodoSheet> {
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.todo.title);
    _descriptionController = TextEditingController(text: widget.todo.description);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
          top: 20,
          left: 16,
          right: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom + 16),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min, 
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Chỉnh sửa công việc',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Tiêu đề',
                border: OutlineInputBorder(),
              ),
              autofocus: true, // Tự động focus vào đây
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _descriptionController,
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: 'Mô tả',
                alignLabelWithHint: true,
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            Align(
              alignment: Alignment.bottomRight,
              child: TextButton(
                style: TextButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  // Trả về dữ liệu đã nhập
                  Navigator.pop(context, {
                    'title': _titleController.text,
                    'description': _descriptionController.text,
                  });
                },
                child: const Text('Lưu'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}