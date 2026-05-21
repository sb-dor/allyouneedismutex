import 'package:allyouneedismutex/todo.dart';
import 'package:allyouneedismutex/todos_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:mutex/mutex.dart';

/// Base example for controllers that run async operations one after another.
class SequentialControllerHandler with ChangeNotifier {
  final _$mutex = Mutex();

  /// Handles a given operation sequentially.
  ///
  /// Operations are queued and executed one at a time.
  Future<T?> handle<T>(final Future<T> Function() handler) => _$mutex.protect(handler);
}

/// Base example for controllers that drop new async operations while busy.
class DroppableControllerHandler with ChangeNotifier {
  final _$mutex = Mutex();

  /// Handles a given operation with droppable behavior.
  ///
  /// If an operation is already running, the new one is dropped and null
  /// is returned.
  Future<T?> handle<T>(final Future<T> Function() handler) async {
    if (_$mutex.isLocked) return Future<T?>.value(null);
    return _$mutex.protect(handler);
  }
}

/// Mutex example: drops duplicate todo load requests while one is in progress.
class DroppableMutexTodosControllerExample extends DroppableControllerHandler {
  DroppableMutexTodosControllerExample({required final ITodosRepository todosRepository})
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
class SequentialMutexTodosControllerExample extends SequentialControllerHandler {
  SequentialMutexTodosControllerExample({required final ITodosRepository todosRepository})
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

class TodoController extends ChangeNotifier {
  TodoController({required final ITodosRepository todosRepository})
    : _iTodosRepository = todosRepository;

  final ITodosRepository _iTodosRepository;

  final List<Todo> todos = [];

  final _$mutex = Mutex();

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
