// ignore_for_file: cascade_invocations

import 'dart:async';

import 'package:allyouneedismutex/todos_controller.dart';
import 'package:allyouneedismutex/todos_repository.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() => runZonedGuarded(
  () async {
    WidgetsFlutterBinding.ensureInitialized();
    final dependencies = Dependencies()..httpClient = http.Client();

    runApp(Application(dependencies: dependencies));
  },
  (error, stackTrace) {
    debugPrint('Zone error ${error.toString()}');
    debugPrint('Zone stacktrace: ${stackTrace.toString()}');
  },
);

class Dependencies {
  late final http.Client httpClient;
}

/// {@template main}
/// DependenciesScope widget.
/// {@endtemplate}
class DependenciesScope extends InheritedWidget {
  /// {@macro main}
  const DependenciesScope({
    required this.dependencies,
    required super.child,
    super.key, // ignore: unused_element_parameter
  });

  static Dependencies of(BuildContext context) {
    final widget = context.getElementForInheritedWidgetOfExactType<DependenciesScope>()?.widget;
    assert(widget != null, 'No DependenciesScope was found in element tree');
    return (widget as DependenciesScope).dependencies;
  }

  final Dependencies dependencies;

  @override
  bool updateShouldNotify(covariant DependenciesScope oldWidget) => false;
}

/// {@template main}
/// Application widget.
/// {@endtemplate}
class Application extends StatefulWidget {
  /// {@macro main}
  const Application({
    super.key, // ignore: unused_element_parameter
    required this.dependencies,
  });

  final Dependencies dependencies;

  @override
  State<Application> createState() => _ApplicationState();
}

/// State for widget Application.
class _ApplicationState extends State<Application> {
  @override
  Widget build(BuildContext context) => DependenciesScope(
    dependencies: widget.dependencies,
    child: const MaterialApp(home: HomeScreen()),
  );
}

/// {@template main}
/// HomeScreen widget.
/// {@endtemplate}
class HomeScreen extends StatefulWidget {
  /// {@macro main}
  const HomeScreen({
    super.key, // ignore: unused_element_parameter
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

/// State for widget HomeScreen.
class _HomeScreenState extends State<HomeScreen> {
  late final DroppableTodosControllerExample _todosController;

  /* #region Lifecycle */
  @override
  void initState() {
    super.initState();
    // Initial state initialization
    final dependencies = DependenciesScope.of(context);
    _todosController = DroppableTodosControllerExample(
      todosRepository: TodosRepositoryImpl(client: dependencies.httpClient),
    )..load();
  }

  @override
  void dispose() {
    // Permanent removal of a tree stent
    _todosController.dispose();
    super.dispose();
  }
  /* #endregion */

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFFF6F7F9),
    appBar: AppBar(
      title: const Text('Todos'),
      centerTitle: false,
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      foregroundColor: const Color(0xFF171A1F),
      elevation: 0,
      actions: [
        IconButton(
          onPressed: () {
            _todosController.load();
          },
          icon: const Icon(Icons.refresh),
        ),
      ],
    ),
    body: SafeArea(
      child: ListenableBuilder(
        listenable: _todosController,
        builder: (context, child) {
          if (_todosController.todos.isEmpty) {
            return const _TodosLoadingView();
          }

          return RefreshIndicator(
            onRefresh: _todosController.load,
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _todosController.todos.length,
              separatorBuilder: (context, index) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final todo = _todosController.todos[index];
                return _TodoTile(title: todo.title, completed: todo.completed, id: todo.id);
              },
            ),
          );
        },
      ),
    ),
  );
}

class _TodosLoadingView extends StatelessWidget {
  const _TodosLoadingView();

  @override
  Widget build(BuildContext context) => const Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox.square(dimension: 36, child: CircularProgressIndicator(strokeWidth: 3)),
        SizedBox(height: 16),
        Text(
          'Loading todos...',
          style: TextStyle(color: Color(0xFF555E6D), fontSize: 16, fontWeight: FontWeight.w500),
        ),
      ],
    ),
  );
}

class _TodoTile extends StatelessWidget {
  const _TodoTile({required this.title, required this.completed, required this.id});

  final String title;
  final bool completed;
  final int id;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: const Color(0xFFE3E6EA)),
    ),
    child: ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: Icon(
        completed ? Icons.check_circle : Icons.radio_button_unchecked,
        color: completed ? const Color(0xFF178F5D) : const Color(0xFF98A1B0),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: const Color(0xFF171A1F),
          fontSize: 15,
          fontWeight: FontWeight.w600,
          decoration: completed ? TextDecoration.lineThrough : null,
        ),
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Text('Task #$id', style: const TextStyle(color: Color(0xFF6D7684))),
      ),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: completed ? const Color(0xFFEAF8F1) : const Color(0xFFFFF4D8),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          completed ? 'Done' : 'Open',
          style: TextStyle(
            color: completed ? const Color(0xFF126B47) : const Color(0xFF8B6200),
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    ),
  );
}
