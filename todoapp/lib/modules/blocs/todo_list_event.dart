import 'package:equatable/equatable.dart';

abstract class TodoListEvent extends Equatable {
  const TodoListEvent();

  @override
  List<Object> get props => [];
}

class LoadTodosEvent extends TodoListEvent {
  const LoadTodosEvent();

  @override
  List<Object> get props => [];
}

class AddTodoEvent extends TodoListEvent {
  final String title;
  final String description;
  const AddTodoEvent(this.title, this.description);

  @override
  List<Object> get props => [description];
}

class ToggleTodoEvent extends TodoListEvent {
  final String id;
  const ToggleTodoEvent(this.id);

  @override
  List<Object> get props => [id];
}

class RemoveTodoEvent extends TodoListEvent {
  final String id;
  const RemoveTodoEvent(this.id);

  @override
  List<Object> get props => [id];
}

class ClearTodosEvent extends TodoListEvent {
  const ClearTodosEvent();

  @override
  List<Object> get props => [];
}

class UpdateTodoEvent extends TodoListEvent {
  final String id;
  final String title;
  final String description;

  const UpdateTodoEvent({
    required this.id,
    required this.title,
    required this.description,
  });

  @override
  List<Object> get props => [title, description];
}

class SearchTodoEvent extends TodoListEvent {
  final String query;

  const SearchTodoEvent(this.query);

  @override
  List<Object> get props => [query];
}

class LoadTodosCompletedEvent extends TodoListEvent {
  const LoadTodosCompletedEvent();

  @override
  List<Object> get props => [];
}

class LoadTodosIncompleteEvent extends TodoListEvent {
  const LoadTodosIncompleteEvent();

  @override
  List<Object> get props => [];
}

class ReorderTodoEvent extends TodoListEvent {
  final int oldIndex;
  final int newIndex;

  const ReorderTodoEvent(this.oldIndex, this.newIndex);

  @override
  List<Object> get props => [oldIndex, newIndex];
}
