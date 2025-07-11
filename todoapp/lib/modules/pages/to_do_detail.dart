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
                builder: (context) => _buildEditView(todo),
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

  Widget _buildEditView(ToDo todo) {
    TextEditingController titleController = TextEditingController(text: todo.title);
    TextEditingController descriptionController = TextEditingController(text: todo.description);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
        const SizedBox(height: 8),
        TextField(
          controller: titleController,
          decoration: InputDecoration(
            labelText: 'Chỉnh sửa tiêu đề',
            floatingLabelBehavior: FloatingLabelBehavior.always,
            border: OutlineInputBorder(),
          ),
        ),
      
        const SizedBox(height: 24),
      
        TextField(
          controller: descriptionController,
          maxLines: 5,
          decoration: InputDecoration(
            labelText: 'Chỉnh sửa mô tả',
            floatingLabelBehavior: FloatingLabelBehavior.always,
            border: OutlineInputBorder(),
          ),
        ),

        Spacer(),

        Align(
          alignment: Alignment.bottomRight,
          child: TextButton(
            style: TextButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(context, {
                'title': titleController.text,
                'description': descriptionController.text,
              });
            },
            child: const Text('Lưu'),
          ),
        ),

        ],
      ),
    );
  }
}