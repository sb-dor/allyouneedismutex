import 'package:allyouneedismutex/todo.dart';
import 'package:allyouneedismutex/todos_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:mutex/mutex.dart';

class TodosController with ChangeNotifier {
  TodosController({required final ITodosRepository todosRepository})
    : _iTodosRepository = todosRepository;

  final ITodosRepository _iTodosRepository;

  final _$mutex = Mutex();

  final List<Todo> todos = [];

  /// Queues concurrent load requests so only one runs at a time.
  void load() async => await _$mutex.protect(() async {
    todos.clear();
    todos.addAll(await _iTodosRepository.todos());
    notifyListeners();
  });
}
