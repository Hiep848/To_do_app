import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todoapp/modules/blocs/todo_list.state.dart';
import 'package:todoapp/modules/blocs/todo_list_event.dart';
import 'package:todoapp/modules/models/todo.dart';
import 'package:todoapp/modules/repository/todo_app_service.dart';

class TodoListBloc extends Bloc<TodoListEvent, TodoListState> {
  final TodoApiService _apiService;

  TodoListBloc(this._apiService) : super(const TodoListState()) {
    on<LoadTodosEvent>(_onLoadTodos); 
    on<LoadTodosCompletedEvent>(_onLoadTodosCompleted);
    on<LoadTodosIncompleteEvent>(_onLoadTodosIncomplete);
    on<SearchTodoEvent>(_onSearchTodos);
    on<AddTodoEvent>(_onAddTodo);
    on<ToggleTodoEvent>(_onToggleTodo);
    on<RemoveTodoEvent>(_onRemoveTodo);
    on<ClearTodosEvent>(_onClearTodos);
    on<UpdateTodoEvent>(_onUpdateTodo);
    on<ReorderTodoEvent>(_onReorderTodo);
  }

  Future<void> _onLoadTodos(LoadTodosEvent event, Emitter<TodoListState> emit) async {
    emit(state.copyWith(status: TodoStatus.loading));

    try {
      final todos = await _apiService.getTodos(); 
      emit(state.copyWith(todos: todos, status: TodoStatus.success));
    } catch (e) {
      emit(state.copyWith(status: TodoStatus.error, errorMessage: e.toString()));
      print('Error loading todos: $e'); 
    }
  }

  Future<void> _onLoadTodosCompleted(LoadTodosCompletedEvent event, Emitter<TodoListState> emit) async {
    emit(state.copyWith(status: TodoStatus.loading));

    try {
      final todos = await _apiService.getTodosCompleted(event.query); 
      emit(state.copyWith(todos: todos, status: TodoStatus.success));
    } catch (e) {
      emit(state.copyWith(status: TodoStatus.error, errorMessage: e.toString()));
      print('Error loading todos: $e'); 
    }
  }
  
  Future<void> _onLoadTodosIncomplete(LoadTodosIncompleteEvent event, Emitter<TodoListState> emit) async {
    emit(state.copyWith(status: TodoStatus.loading));

    try {
      final todos = await _apiService.getTodosIncomplete(event.query); 
      emit(state.copyWith(todos: todos, status: TodoStatus.success));
    } catch (e) {
      emit(state.copyWith(status: TodoStatus.error, errorMessage: e.toString()));
      print('Error loading todos: $e'); 
    }
  }
  
  Future<void> _onSearchTodos(SearchTodoEvent event, Emitter<TodoListState> emit) async {
    final todos = await _apiService.searchTodos(event.query);

    try{
      if (todos.isEmpty) {
        emit(state.copyWith(status: TodoStatus.success, todos: []));
      } else {
        emit(state.copyWith(status: TodoStatus.success, todos: todos));
      }
    } catch (e) {
      emit(state.copyWith(status: TodoStatus.error, errorMessage: e.toString()));
      print('Error searching todos: $e');
    } 
  }

  Future<void> _onAddTodo(AddTodoEvent event, Emitter<TodoListState> emit) async {
    try {
      final newTodo = await _apiService.createTodo(event.title, event.description); 
      emit(state.copyWith(todos: [...state.todos, newTodo])); 
    } catch (e) {
      print('Error adding todo: $e');

    }
  }

  Future<void> _onToggleTodo(ToggleTodoEvent event, Emitter<TodoListState> emit) async {
    final originalTodo = state.todos.firstWhere((todo) => todo.id == event.id);
    final toggledTodo = originalTodo.copyWith(isCompleted: !originalTodo.isCompleted);

    final optimisticTodos = state.todos.map((todo) => todo.id == event.id ? toggledTodo : todo).toList();
    emit(state.copyWith(todos: optimisticTodos));

    try {
      await _apiService.updateTodoStatus(event.id, toggledTodo.isCompleted);
    } catch (e) {
      print('Error toggling todo: $e');
      emit(state.copyWith(todos: state.todos.map((todo) => todo.id == event.id ? originalTodo : todo).toList()));
    }
  }

  Future<void> _onRemoveTodo(RemoveTodoEvent event, Emitter<TodoListState> emit) async {
    final originalTodos = state.todos;
    final optimisticTodos = state.todos.where((todo) => todo.id != event.id).toList();
    
    emit(state.copyWith(todos: optimisticTodos));

    try {
      await _apiService.deleteTodo(event.id);
    } catch (e) {
      print('Error removing todo: $e');
      emit(state.copyWith(todos: originalTodos));
    }
  }

  Future<void> _onClearTodos(ClearTodosEvent event, Emitter<TodoListState> emit) async {
    try {
      await _apiService.clearTodos(); 
      emit(state.copyWith(todos: []));
    } catch (e) {
      print('Error clearing todos: $e');
    }
  }

  Future<void> _onUpdateTodo(UpdateTodoEvent event, Emitter<TodoListState> emit) async {
    final originalTodos = state.todos;
    final updatedTodos = originalTodos.map((todo) {
      if (todo.id == event.id) {
        return todo.copyWith(id: event.id, title: event.title, description: event.description);
      }
      return todo;
    }).toList();

    emit(state.copyWith(todos: updatedTodos));

    try {
      await _apiService.updateTodoDetail(event.id, event.title, event.description);
    } catch (e) {
      print('Error updating todo: $e');
      emit(state.copyWith(todos: originalTodos));
    }
  }

  Future<void> _onReorderTodo(ReorderTodoEvent event, Emitter<TodoListState> emit) async {
    final List<ToDo> originalTodos = List.from(state.todos);
    final List<ToDo> backupTodos = List.from(state.todos);
    int oldIndex = event.oldIndex;
    int newIndex = event.newIndex;

    if (newIndex > oldIndex) {
      newIndex -= 1;
    }

    final ToDo item = originalTodos.removeAt(oldIndex);
    originalTodos.insert(newIndex, item);

    emit(state.copyWith(todos: originalTodos, status: TodoStatus.success));
  
  

    try {
      await _apiService.reorderTodos(oldIndex, newIndex);
    } catch (e) {
      print('Error updating todo: $e');
      emit(state.copyWith(todos: backupTodos, status: TodoStatus.error));
    }
  }
}