import 'dart:convert';

import 'package:allyouneedismutex/todo.dart';
import 'package:http/http.dart';

abstract interface class ITodosRepository {
  Future<List<Todo>> todos();
}

final class TodosRepositoryImpl implements ITodosRepository {
  TodosRepositoryImpl({final Client? client}) : _client = client ?? Client();

  final Client _client;

  @override
  Future<List<Todo>> todos() async {
    final response = await _client.get(Uri.parse('https://jsonplaceholder.typicode.com/todos/'));

    if (response.statusCode == 200) {
      final dTodos = jsonDecode(response.body) as List;
      return dTodos.map((el) {
        final asJson = el as Map<String, Object?>;
        return Todo(
          userId: asJson['userId'] as int,
          id: asJson['id'] as int,
          title: asJson['title'] as String,
          completed: asJson['completed'] as bool,
        );
      }).toList();
    }

    throw Exception("Couldn't get todos due to a server error: ${response.body}");
  }
}
