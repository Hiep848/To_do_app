import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:todoapp/modules/blocs/todo_list.state.dart';
import 'package:todoapp/modules/blocs/todo_list_bloc.dart';
import 'package:todoapp/modules/blocs/todo_list_event.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _currentQuery = '';
  int _selectedFilterIndex = 0;
  Timer? _debouncer;
  bool _isSearching = false;
  final List<String> _filters = ['Tất cả', 'Đã hoàn thành', 'Chưa hoàn thành'];

  @override
  initState() {
      super.initState();
      context.read<TodoListBloc>().add(const LoadTodosEvent());
    }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Danh sách công việc'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildFilteredChips(),

          Expanded(
            child: BlocConsumer<TodoListBloc, TodoListState>(
              listener: (context, state) {
                if (state.status == TodoStatus.error) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Lỗi: ${state.errorMessage}')),
                  );
                }
              },
              builder: (context, state) {
                if (state.status == TodoStatus.loading) {
                  return const Center(child: CircularProgressIndicator());
                } if (state.status == TodoStatus.error) {
                  return Center(child: Text('Đã xảy ra lỗi: ${state.errorMessage}'));
                } if (state.todos.isEmpty) {
                  return const Center(
                    child: Text(
                      'Chưa có công việc nào!',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  );
                }
                return ReorderableListView.builder(
                  itemCount: state.todos.length,
                  onReorder: (int oldIndex, int newIndex) {
                    context.read<TodoListBloc>().add(ReorderTodoEvent(oldIndex, newIndex));
                  },
                  itemBuilder: (context, index) {
                    final todo = state.todos[index];
                    return Dismissible(
                      key: ValueKey(todo.id),
                      background: Container(
                        color: Colors.red,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20.0),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      direction: DismissDirection.endToStart,
                      onDismissed: (direction) {
                        context.read<TodoListBloc>().add(RemoveTodoEvent(todo.id));
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Đã xóa "${todo.title}"'),
                            // action: SnackBarAction(
                            //   label: 'Hoàn tác',
                            //   onPressed: () {
                            //     context.read<TodoListBloc>().add(UndoRemoveTodoEvent(todo.title, todo.description));
                            //   },
                            // ),
                            duration: const Duration(seconds: 3),
                          ),
                        );
                        
                      },
                      child: Card(
                        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        elevation: 2,
                        child: ListTile(
                          onTap: () {
                            context.push('/todos/${todo.id}');
                          },
                          title: Text(
                            todo.title,
                            style: TextStyle(
                              decoration: todo.isCompleted
                                  ? TextDecoration.lineThrough
                                  : TextDecoration.none,
                              color: todo.isCompleted ? Colors.grey : Colors.black,
                            ),
                          ),
                          leading: Checkbox(
                            value: todo.isCompleted,
                            onChanged: (bool? newValue) {
                              context.read<TodoListBloc>().add(ToggleTodoEvent(todo.id));
                            },
                          ),
                          trailing: ReorderableDragStartListener(
                            index: index,
                            child: const Icon(Icons.drag_handle),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),

      floatingActionButton: Align(
        alignment: Alignment.bottomRight,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            FloatingActionButton(
              heroTag: null,
              onPressed: () {
                context.read<TodoListBloc>().add(LoadTodosEvent());
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Tải lại trang thành công'),
                    duration: const Duration(seconds: 1),
                  ),
                );
              },
              child: const Icon(Icons.refresh),
            ),
            const SizedBox(height: 8,),
            FloatingActionButton(
              heroTag: null,
              onPressed: () async {
                final bool? isConfirmed = await showDialog(
                  context: context,
                  builder: (BuildContext dialogContext) {
                    return AlertDialog(
                      title: const Text('Xóa tất cả công việc'),
                      content: const Text('Bạn có chắc chắn muốn xóa tất cả công việc không?'),
                      actions: <Widget>[
                        TextButton(
                          child: const Text('Hủy'),
                          onPressed: () {
                            Navigator.of(dialogContext).pop(false);
                          },
                        ),
                        ElevatedButton(
                          child: const Text('Xóa', style: TextStyle(color: Colors.red),),
                          onPressed: () {
                            Navigator.of(dialogContext).pop(true);
                          },
                        ),
                      ],
                    );
                  },
                );
                if (isConfirmed == true) {
                  context.read<TodoListBloc>().add(ClearTodosEvent());
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Đã xóa tất cả công việc'),
                      duration: const Duration(seconds: 1),
                    ),
                  );
                }
              },
              child: const Icon(Icons.delete_forever),
            ),
            const SizedBox(height: 8,),
            FloatingActionButton(
              heroTag: null,
              onPressed: () {
                _showAddTodoDialog(context);
              },
              child: const Icon(Icons.add),
            ),
          ],
        ),
      )
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        onChanged: (value) {
          if (_debouncer?.isActive ?? false) _debouncer!.cancel();
          _debouncer = Timer(const Duration(milliseconds: 500), () {
          if (value.trim().isEmpty) {
            setState(() => _currentQuery = '');
            context.read<TodoListBloc>().add(const LoadTodosEvent());
            return;
          }
          setState(() => _currentQuery = value.trim());
          context.read<TodoListBloc>().add(SearchTodoEvent(_currentQuery)); 
          });
        },
        decoration: InputDecoration(
          hintText: 'Tìm kiếm công việc...',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20.0),
            borderSide: const BorderSide(color: Colors.grey, width: 1.0),
          ),
          prefixIcon: const Icon(Icons.search),
        ),
      ),
    );
  }

  Widget _buildFilteredChips() {
    return BlocBuilder<TodoListBloc, TodoListState>(
      builder: (context, state) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Wrap(
            spacing: 8.0,
            children: List.generate(_filters.length, (index) {
              return ChoiceChip(
                label: Text(_filters[index]),
                selected: _selectedFilterIndex == index,
                onSelected: (selected) {
                  setState(() {
                    _selectedFilterIndex = index;
                  });
                  _applyFilter(index);
                },
              );
            }),
          ),
        );
      },
    );
  }

 void _applyFilter(int index) {
    switch (index) {
      case 0: // Tất cả
        if (_currentQuery.isEmpty)
          {context.read<TodoListBloc>().add(const LoadTodosEvent());}
        else
          {context.read<TodoListBloc>().add(SearchTodoEvent(_currentQuery));}
        break;
      case 1: // Đã hoàn thành
        context.read<TodoListBloc>().add(LoadTodosCompletedEvent(_currentQuery));
        break;
      case 2: // Chưa hoàn thành
        context.read<TodoListBloc>().add(LoadTodosIncompleteEvent(_currentQuery));
        break;
    }
  }

  void _showAddTodoDialog(BuildContext context) {
    TextEditingController titleFieldController = TextEditingController();
    TextEditingController descriptionFieldController = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Tiêu đề',
                style: TextStyle(fontSize: 20),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: titleFieldController,
                decoration: const InputDecoration(
                  hintText: "Nhập tiêu đề công việc",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20.0)),
                  ),
                ),
                autofocus: true,
              ),
              const SizedBox(height: 10),
              const Text(
                'Mô tả',
                style: TextStyle(fontSize: 20),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: descriptionFieldController,
                keyboardType: TextInputType.multiline,
                maxLines: 18,
                minLines: 3,
                decoration: const InputDecoration(
                  hintText: "Nhập mô tả công việc",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20.0)),
                  ),
                  alignLabelWithHint: true,
                ),
                autofocus: true,
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Hủy'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            ElevatedButton(
              child: const Text('Thêm'),
              onPressed: () {
                if (titleFieldController.text.isNotEmpty) {
                  descriptionFieldController.text.isEmpty ? descriptionFieldController.text = "" : descriptionFieldController.text;
                  context.read<TodoListBloc>().add(AddTodoEvent(titleFieldController.text, descriptionFieldController.text));
                  Navigator.of(dialogContext).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }
}