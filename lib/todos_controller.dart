import 'package:allyouneedismutex/controller.dart';
import 'package:allyouneedismutex/todo.dart';
import 'package:allyouneedismutex/todos_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:mutex/mutex.dart';

/// Mutex example: drops duplicate todo load requests while one is in progress.
class DroppableTodosControllerExample extends DroppableControllerHandler {
  DroppableTodosControllerExample({required final ITodosRepository todosRepository})
    : _iTodosRepository = todosRepository;

  final ITodosRepository _iTodosRepository;

  final List<Todo> todos = [];

  /// Loads todos only when another load operation is not already running.
  ///
  /// Repeated calls during an active load are ignored.
  Future<void> load() => handle(() async {
    await Future.delayed(const Duration(seconds: 3));
    debugPrint('isInProgress');
    final loadedTodos = await _iTodosRepository.todos();
    todos
      ..clear()
      ..addAll(loadedTodos);
    notifyListeners();
  });
}

/// Mutex example: queues todo load requests and runs them sequentially.
class SequentialTodosControllerExample extends SequentialControllerHandler {
  SequentialTodosControllerExample({required final ITodosRepository todosRepository})
    : _iTodosRepository = todosRepository;

  final ITodosRepository _iTodosRepository;

  final List<Todo> todos = [];

  /// Handles a given operation sequentially.
  ///
  /// Operations are queued and executed one at a time.
  Future<void> load() => handle(() async {
    await Future.delayed(const Duration(seconds: 3));
    debugPrint('isInProgress');
    final loadedTodos = await _iTodosRepository.todos();
    todos
      ..clear()
      ..addAll(loadedTodos);
    notifyListeners();
  });
}

/// This controller is concurrent by default
class TodoController extends ChangeNotifier {
  TodoController({required final ITodosRepository todosRepository})
    : _iTodosRepository = todosRepository;
  final _$mutex = Mutex();

  final ITodosRepository _iTodosRepository;

  final List<Todo> todos = [];

  /// Handles a given operation sequentially.
  ///
  /// Operations are queued and executed one at a time.
  Future<void> load() => _$mutex.protect(() async {
    await Future.delayed(const Duration(seconds: 3));
    debugPrint('isInProgress');
    final loadedTodos = await _iTodosRepository.todos();
    todos
      ..clear()
      ..addAll(loadedTodos);
    notifyListeners();
  });
}
