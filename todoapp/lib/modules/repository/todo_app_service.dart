import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:todoapp/modules/models/todo.dart';
import 'package:todoapp/modules/common/api_constants.dart';

class TodoApiService {
  final String _baseUrl = ApiConstants.baseUrl; 

  Future<List<ToDo>> getTodos() async {
    final response = await http.get(Uri.parse('$_baseUrl/todos'));

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse.map((todo) => ToDo.fromJson(todo)).toList();
    } else {
      throw Exception('Failed to load todos: ${response.statusCode}');
    }
  }

  Future<List<ToDo>> getTodosCompleted(String query) async {
    final response = await http.get(Uri.parse('$_baseUrl/todos?q=${query}&status=completed'));

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse.map((todo) => ToDo.fromJson(todo)).toList();
    } else {
      throw Exception('Failed to load todos: ${response.statusCode}');
    }
  }

  Future<List<ToDo>> getTodosIncomplete(String query) async {
    final response = await http.get(Uri.parse('$_baseUrl/todos?q=${query}&status=incomplete'));

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse.map((todo) => ToDo.fromJson(todo)).toList();
    } else {
      throw Exception('Failed to load todos: ${response.statusCode}');
    }
  }

  Future<ToDo> createTodo(String title, String description) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/todos'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'title': title,
        'description': description,
        'lastModify': DateTime.now().toIso8601String(),
      }),
    );

    if (response.statusCode == 201) {
      return ToDo.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to create todo: ${response.statusCode}');
    }
  }

  Future<ToDo> updateTodoStatus(String id, bool isCompleted) async {
    final response = await http.patch(
      Uri.parse('$_baseUrl/todos/$id'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, bool>{'isCompleted': isCompleted}),
    );

    if (response.statusCode == 200) {
      return ToDo.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to update todo status: ${response.statusCode}');
    }
  }

  Future<void> deleteTodo(String id) async {
    final response = await http.delete(Uri.parse('$_baseUrl/todos/$id'));

    if (response.statusCode != 204) {
      throw Exception('Failed to delete todo: ${response.statusCode}');
    }
  }

  Future<void> clearTodos() async {
    final response = await http.delete(Uri.parse('$_baseUrl/todos'));

    if (response.statusCode != 204) {
      throw Exception('Failed to clear todos: ${response.statusCode}');
    }
  }

  Future<ToDo> updateTodoDetail(String id, String title, String description) async {
    final response = await http.patch(
      Uri.parse('$_baseUrl/todos/$id'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'title': title,
        'description': description,
        'last_modify': DateTime.now().toIso8601String(),
      }),
    );
    if (response.statusCode == 200) {
      return ToDo.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to update todo detail: ${response.statusCode}');
    }
  }

  Future<void> reorderTodos(int oldIndex, int newIndex) async {
    final response = await http.patch(
      Uri.parse('$_baseUrl/todos/reorder'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, int>{
        'oldIndex': oldIndex,
        'newIndex': newIndex,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to reorder todos: ${response.statusCode}');
    }
  }

  Future<List<ToDo>> searchTodos(String query) async {
    final response = await http.get(Uri.parse('$_baseUrl/todos?q=$query'));

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse.map((todo) => ToDo.fromJson(todo)).toList();
    } else {
      throw Exception('Failed to search todos: ${response.statusCode}');
    }
  }
}