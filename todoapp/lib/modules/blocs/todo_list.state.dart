import 'package:equatable/equatable.dart';
import 'package:todoapp/modules/models/todo.dart';

// Enum để biểu thị trạng thái tải dữ liệu
enum TodoStatus { initial, loading, success, error }
enum TodoFilter { all, completed, incomplete }


class TodoListState extends Equatable {
  final List<ToDo> todos;
  final TodoStatus status;
  final String? errorMessage;

  const TodoListState({
    this.todos = const [],
    this.status = TodoStatus.initial,
    this.errorMessage,
  });

  TodoListState copyWith({
    List<ToDo>? todos,
    TodoStatus? status,
    String? errorMessage,
  }) {
    return TodoListState(
      todos: todos ?? this.todos,
      status: status ?? this.status,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [todos, status, errorMessage];
}